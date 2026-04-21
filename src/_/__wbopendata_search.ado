*******************************************************************************
*! __wbopendata_search v2.6.0  20Apr2026
*! Search indicators from YAML with wildcards, filters, and SMCL nav
*! v2.6.0: Add page() option with clickable [Prev]/[Next] pagination
*! v2.5.1: Use searchsource/searchtopic in SMCL clickable links
*! Standard implementation: parses YAML each call (works on all Stata versions)
*******************************************************************************

program define __wbopendata_search, rclass
    version 14.0
    syntax [anything(name=keyword)] [, LIMIT(integer 20) PAGE(integer 1) ///
        SOURCE(string) TOPIC(string) FIELD(string) EXACT DETAIL NOcache DEBUG]

    * Strip surrounding quotes from keyword
    local kw `keyword'
    local kw = subinstr(`"`kw'"', `"""', "", .)
    local kw = strtrim("`kw'")
    local kw_lower = lower("`kw'")
    local limit = cond(`limit' <= 0, 20, `limit')
    if (`page' < 1) local page = 1

    * Check for multi-keyword AND search (keyword1+keyword2+keyword3)
    local multi_kw = 0
    local n_keywords = 1
    if (strpos("`kw'", "+") > 0 & substr("`kw'", 1, 1) != "~" & ///
        strpos("`kw'", "*") == 0 & strpos("`kw'", "?") == 0 & strpos("`kw'", "[") == 0) {
        local multi_kw = 1
        * Count and extract keywords
        local kw_remaining = "`kw'"
        local n_keywords = 0
        while ("`kw_remaining'" != "") {
            local n_keywords = `n_keywords' + 1
            local plus_pos = strpos("`kw_remaining'", "+")
            if (`plus_pos' > 0) {
                local kw`n_keywords' = lower(strtrim(substr("`kw_remaining'", 1, `plus_pos' - 1)))
                local kw_remaining = strtrim(substr("`kw_remaining'", `plus_pos' + 1, .))
            }
            else {
                local kw`n_keywords' = lower(strtrim("`kw_remaining'"))
                local kw_remaining ""
            }
        }
    }

    * Validate: either keyword or source/topic filter required
    if ("`kw'" == "" & "`source'" == "" & "`topic'" == "") {
        di as error "search() requires a keyword, or source()/topic() filter"
        di as text "Examples:"
        di as text "  wbopendata, search(GDP)"
        di as text "  wbopendata, search(learning+poverty)     // AND search: both keywords"
        di as text "  wbopendata, search() searchsource(2)"
        di as text "  wbopendata, search(poverty) searchtopic(11)"
        exit 198
    }

    __wbod_get_yaml_path, type(indicators)
    local yaml_path = r(path)

    if (!fileexists("`yaml_path'")) {
        di as error "Indicators metadata not found. Run: wbopendata, sync"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Convert wildcard pattern to regex
    *---------------------------------------------------------------------------
    local use_regex = 0
    local regex_pattern = ""

    if ("`kw'" != "") {
        * Check for regex mode (prefix with ~)
        if (substr("`kw'", 1, 1) == "~") {
            local use_regex = 1
            local regex_pattern = substr("`kw'", 2, .)
        }
        * Check for wildcards (* ? [ ])
        else if (strpos("`kw'", "*") > 0 | strpos("`kw'", "?") > 0 | ///
                 strpos("`kw'", "[") > 0) {
            local use_regex = 1
            * Convert glob to regex
            local regex_pattern = "`kw'"
            * Escape regex special chars (except * ? [ ])
            local regex_pattern = subinstr("`regex_pattern'", ".", "\.", .)
            local regex_pattern = subinstr("`regex_pattern'", "^", "\^", .)
            local regex_pattern = subinstr("`regex_pattern'", "$", "\$", .)
            local regex_pattern = subinstr("`regex_pattern'", "+", "\+", .)
            local regex_pattern = subinstr("`regex_pattern'", "(", "\(", .)
            local regex_pattern = subinstr("`regex_pattern'", ")", "\)", .)
            local regex_pattern = subinstr("`regex_pattern'", "{", "\{", .)
            local regex_pattern = subinstr("`regex_pattern'", "}", "\}", .)
            * Convert wildcards: * → .*, ? → .
            local regex_pattern = subinstr("`regex_pattern'", "*", ".*", .)
            local regex_pattern = subinstr("`regex_pattern'", "?", ".", .)
        }
    }

    *---------------------------------------------------------------------------
    * Parse field() option - default is "all"
    *---------------------------------------------------------------------------
    local search_code = 1
    local search_name = 1
    local search_desc = 1
    local search_source = 1
    local search_topic = 1
    local search_note = 1

    if ("`field'" != "") {
        * Reset all to 0, then enable requested fields
        local search_code = 0
        local search_name = 0
        local search_desc = 0
        local search_source = 0
        local search_topic = 0
        local search_note = 0

        * Parse semicolon-separated field list
        local fields = lower("`field'")
        local fields = subinstr("`fields'", ";", " ", .)
        foreach f of local fields {
            if ("`f'" == "all") {
                local search_code = 1
                local search_name = 1
                local search_desc = 1
                local search_source = 1
                local search_topic = 1
                local search_note = 1
            }
            else if ("`f'" == "code")        local search_code = 1
            else if ("`f'" == "name")        local search_name = 1
            else if ("`f'" == "description") local search_desc = 1
            else if ("`f'" == "source")      local search_source = 1
            else if ("`f'" == "topic")       local search_topic = 1
            else if ("`f'" == "note")        local search_note = 1
            else {
                di as error "Unknown field: `f'"
                di as text "Valid fields: code, name, description, source, topic, note, all"
                exit 198
            }
        }
    }

    *---------------------------------------------------------------------------
    * Direct file parse (inline infix - no caching)
    *---------------------------------------------------------------------------
    preserve
    quietly {
        * Use infix to read each line as a single fixed-width string
        infix str244 rawline 1-244 using "`yaml_path'", clear
        gen long linenum = _n
        gen str244 raw_trim = strtrim(subinstr(rawline, char(13), "", .))

        * Detect indicator lines (format: INDICATOR_CODE:)
        gen byte is_indicator = 0
        replace is_indicator = 1 if regexm(raw_trim, ":$") & ///
            substr(raw_trim,1,5) != "code:" & ///
            substr(raw_trim,1,5) != "name:" & ///
            substr(raw_trim,1,10) != "source_id:" & ///
            substr(raw_trim,1,12) != "source_name:" & ///
            substr(raw_trim,1,11) != "source_org:" & ///
            substr(raw_trim,1,10) != "topic_ids:" & ///
            substr(raw_trim,1,12) != "topic_names:" & ///
            substr(raw_trim,1,12) != "description:" & ///
            substr(raw_trim,1,5) != "unit:" & ///
            substr(raw_trim,1,5) != "note:" & ///
            substr(raw_trim,1,13) != "limited_data:" & ///
            substr(raw_trim,1,9) != "_metadata" & ///
            substr(raw_trim,1,11) != "indicators:" & ///
            substr(raw_trim,1,1) != "-"

        * Detect field lines
        gen byte is_field = 0
        replace is_field = 1 if strpos(rawline, ":") > 0 & is_indicator == 0 & linenum > 9

        * Extract indicator code (everything before the colon)
        gen str100 ind_code = ""
        replace ind_code = strtrim(substr(rawline, 1, length(rawline) - 1)) if is_indicator

        * Propagate indicator code down to its fields
        gen long ind_group = sum(is_indicator)
        bysort ind_group: replace ind_code = ind_code[1]

        * Extract field type and value
        gen str20 field_type = ""
        gen int colon_pos = strpos(rawline, ":")
        replace field_type = strtrim(substr(rawline, 1, colon_pos - 1)) if is_field & colon_pos > 0

        * Extract field value after the colon
        gen str244 field_val = ""
        replace field_val = strtrim(substr(rawline, colon_pos + 1, .)) if is_field & colon_pos > 0
        * Remove surrounding quotes
        replace field_val = substr(field_val, 2, length(field_val)-2) if is_field & ///
            length(field_val) >= 2 & ///
            ((substr(field_val,1,1) == `"""' & substr(field_val,length(field_val),1) == `"""') | ///
             (substr(field_val,1,1) == "'" & substr(field_val,length(field_val),1) == "'"))

        * Assign to specific field columns
        gen str244 field_name = ""
        gen str244 field_desc = ""
        gen str244 field_source = ""
        gen str244 field_topic = ""
        gen str244 field_note = ""
        gen str20 field_source_id = ""
        gen str50 field_topic_ids = ""
        replace field_name = field_val if field_type == "name"
        replace field_desc = field_val if field_type == "description"
        replace field_source = field_val if field_type == "source_org"
        replace field_topic = field_val if field_type == "topic_names"
        replace field_note = field_val if field_type == "note"
        replace field_source_id = field_val if field_type == "source_id"
        replace field_topic_ids = field_val if field_type == "topic_ids"

        * Normalize empty list markers for topic fields
        replace field_topic_ids = "" if field_topic_ids == "[]"
        replace field_topic = "" if field_topic == "[]"

        *-------------------------------------------------------------------
        * Handle YAML list format: topic_ids and topic_names are lists
        *-------------------------------------------------------------------
        gen byte is_list_item = substr(strtrim(rawline), 1, 2) == "- "
        gen str100 list_item_val = ""
        replace list_item_val = strtrim(substr(rawline, strpos(rawline, "- ") + 2, .)) if is_list_item
        * Remove surrounding quotes from list values
        replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
            length(list_item_val) >= 2 & ///
            ((substr(list_item_val,1,1) == "'" & substr(list_item_val,length(list_item_val),1) == "'") | ///
             (substr(list_item_val,1,1) == `"""' & substr(list_item_val,length(list_item_val),1) == `"""'))

        * Track which field header introduces the current list context
        gen str20 last_field_header = ""
        replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
        * Forward-fill the context
        replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

        * Assign list item values to the appropriate fields
        replace field_topic_ids = list_item_val if is_list_item & last_field_header == "topic_ids"
        replace field_topic = list_item_val if is_list_item & last_field_header == "topic_names"

        drop is_list_item list_item_val last_field_header

        * Collapse to one row per indicator
        collapse (firstnm) ind_code (firstnm) field_name (firstnm) field_desc ///
                 (firstnm) field_source (firstnm) field_topic (firstnm) field_note ///
                 (firstnm) field_source_id (firstnm) field_topic_ids, by(ind_group)
        drop if ind_code == ""

        *-----------------------------------------------------------------------
        * Apply source filter (by ID)
        * Zero-pad single-digit IDs to match YAML format (e.g. "2" -> "02")
        *-----------------------------------------------------------------------
        if ("`source'" != "") {
            local src_filter "`source'"
            if (length("`src_filter'") == 1 & real("`src_filter'") != .) {
                local src_filter "0`src_filter'"
            }
            keep if field_source_id == "`src_filter'" | field_source_id == "`source'"
        }

        *-----------------------------------------------------------------------
        * Apply topic filter (by ID - check if ID is in semicolon-separated list)
        *-----------------------------------------------------------------------
        if ("`topic'" != "") {
            gen byte topic_match = 0
            replace topic_match = 1 if field_topic_ids == "`topic'"
            replace topic_match = 1 if strpos(field_topic_ids, "`topic';") > 0
            replace topic_match = 1 if strpos(field_topic_ids, ";`topic'") > 0
            keep if topic_match
            drop topic_match
        }

        *-----------------------------------------------------------------------
        * Apply keyword search
        *-----------------------------------------------------------------------
        gen byte hit = 0

        if ("`kw'" != "") {
            if ("`exact'" != "") {
                * Exact match on code only
                replace hit = 1 if upper(ind_code) == upper("`kw'")
            }
            else if (`use_regex') {
                * Regex/wildcard search
                if (`search_code')   replace hit = 1 if regexm(lower(ind_code), lower("`regex_pattern'"))
                if (`search_name')   replace hit = 1 if regexm(lower(field_name), lower("`regex_pattern'"))
                if (`search_desc')   replace hit = 1 if regexm(lower(field_desc), lower("`regex_pattern'"))
                if (`search_source') replace hit = 1 if regexm(lower(field_source), lower("`regex_pattern'"))
                if (`search_topic')  replace hit = 1 if regexm(lower(field_topic), lower("`regex_pattern'"))
                if (`search_note')   replace hit = 1 if regexm(lower(field_note), lower("`regex_pattern'"))
            }
            else if (`multi_kw') {
                * Multi-keyword AND search: all keywords must match
                gen str1000 all_text = ""
                if (`search_code')   replace all_text = all_text + " " + lower(ind_code)
                if (`search_name')   replace all_text = all_text + " " + lower(field_name)
                if (`search_desc')   replace all_text = all_text + " " + lower(field_desc)
                if (`search_source') replace all_text = all_text + " " + lower(field_source)
                if (`search_topic')  replace all_text = all_text + " " + lower(field_topic)
                if (`search_note')   replace all_text = all_text + " " + lower(field_note)

                * Check each keyword matches
                replace hit = 1
                forvalues k = 1/`n_keywords' {
                    replace hit = 0 if strpos(all_text, "`kw`k''") == 0
                }
                drop all_text
            }
            else {
                * Simple single-keyword substring search
                if (`search_code')   replace hit = 1 if strpos(lower(ind_code), "`kw_lower'") > 0
                if (`search_name')   replace hit = 1 if strpos(lower(field_name), "`kw_lower'") > 0
                if (`search_desc')   replace hit = 1 if strpos(lower(field_desc), "`kw_lower'") > 0
                if (`search_source') replace hit = 1 if strpos(lower(field_source), "`kw_lower'") > 0
                if (`search_topic')  replace hit = 1 if strpos(lower(field_topic), "`kw_lower'") > 0
                if (`search_note')   replace hit = 1 if strpos(lower(field_note), "`kw_lower'") > 0
            }
            keep if hit
        }

        drop hit
        sort ind_code
    }

    if ("`debug'" != "") {
        di as text "[debug] Parsed YAML and applied filters."
    }

    count
    local n = r(N)

    if ("`debug'" != "") {
        di as text "[debug] Match count: " `n'
    }

    *---------------------------------------------------------------------------
    * Handle no results
    *---------------------------------------------------------------------------
    if (`n' == 0) {
        if ("`kw'" != "") {
            di as text "No indicators matched: " as result "`kw'"
            * Suggest AND search if keyword contains spaces
            if (strpos("`kw'", " ") > 0) {
                local kw_plus = subinstr("`kw'", " ", "+", .)
                di as text ""
                di as text "Tip: Use " as result "`kw_plus'" as text " to find indicators matching ALL words"
            }
        }
        else {
            di as text "No indicators found with specified filters"
        }
        if ("`source'" != "") di as text "  Source filter: `source'"
        if ("`topic'" != "")  di as text "  Topic filter: `topic'"
        if ("`field'" != "")  di as text "  Field filter: `field'"

        restore
        return scalar n_results = 0
        return scalar n_displayed = 0
        return scalar page = 1
        return scalar n_pages = 0
        return local keyword = "`kw'"
        return local source_filter = "`source'"
        return local topic_filter = "`topic'"
        return local field_filter = "`field'"
        return local yaml_path = "`yaml_path'"
        return local cache_method = "none"
        exit 0
    }

    if ("`debug'" != "") {
        restore
        return scalar n_results = `n'
        return scalar n_displayed = min(`n', `limit')
        return local keyword = "`kw'"
        return local source_filter = "`source'"
        return local topic_filter = "`topic'"
        return local field_filter = "`field'"
        return local yaml_path = "`yaml_path'"
        return local cache_method = "none"
        exit 0
    }

    *---------------------------------------------------------------------------
    * Display results with SMCL navigation
    *---------------------------------------------------------------------------
    * Sanitize strings: replace embedded double-quotes with single-quotes
    * so that local macro expansion never encounters unmatched quotes (r(132))
    quietly {
        foreach var of varlist field_name field_desc field_source field_topic field_note {
            capture replace `var' = subinstr(`var', char(34), "'", .)
        }
        replace field_name = "N/A" if field_name == ""
        replace field_source = "N/A" if field_source == ""
    }

    * Pagination: small result sets display on a single page (matching the
    * pre-pagination UX); larger sets honor `limit' as per-page size.
    if (`n' <= 30) {
        local total_pages = 1
        local page = 1
        local pg_start = 1
        local pg_end = `n'
    }
    else {
        local total_pages = ceil(`n' / `limit')
        if (`total_pages' < 1) local total_pages = 1
        if (`page' > `total_pages') local page = `total_pages'
        local pg_start = (`page' - 1) * `limit' + 1
        local pg_end = min(`page' * `limit', `n')
    }
    local lim = `pg_end' - `pg_start' + 1

    * Build header: show pagination info only when there is more than one page
    if (`total_pages' > 1) {
        local hdr_tail "(page `page' of `total_pages' — showing `pg_start'-`pg_end' of `n')"
    }
    else {
        local hdr_tail "(showing `n' of `n')"
    }
    di as text ""
    if ("`kw'" != "") {
        di as result "Search results for " as text `""`kw'""' as result " `hdr_tail'"
    }
    else if ("`source'" != "") {
        di as result "Indicators from source `source'" as text " `hdr_tail'"
    }
    else if ("`topic'" != "") {
        di as result "Indicators in topic `topic'" as text " `hdr_tail'"
    }

    * Build return values
    local codes ""
    local names ""
    local sources ""
    local topics ""

    *---------------------------------------------------------------------------
    * Display format: DETAIL (wrapped) vs TABLE (compact)
    *---------------------------------------------------------------------------
    if ("`detail'" != "") {
        *-----------------------------------------------------------------------
        * DETAIL format: one block per indicator with wrapped text
        *-----------------------------------------------------------------------
        di as text "{hline}"

        forvalues i = `pg_start'/`pg_end' {
            local code = ind_code[`i']
            local nm = field_name[`i']
            local src_id = field_source_id[`i']
            local topic_nm = field_topic[`i']
            local topic_id = field_topic_ids[`i']
            if ("`topic_nm'" == "") local topic_nm "-"

            * Build clickable links
            local info_cmd `"wbopendata, info(`code')"'
            local get_cmd `"wbopendata, indicator(`code') clear"'
            local src_cmd `"wbopendata, search() searchsource(`src_id')"'
            local topic_cmd `"wbopendata, search() searchtopic(`topic_id')"'

            * Display block with wrapped fields
            di as result "`code'" as text "  " ///
               `"{stata "`info_cmd'":[Info]}"' " " ///
               `"{stata "`get_cmd'":[Get]}"'
            di in smcl `"{p 4 4 4}{result:Name}: `nm'{p_end}"'
            di in smcl `"{p 4 4 4}{result:Source}: {stata "`src_cmd'":`src_id'}  {result:Topic}: {stata "`topic_cmd'":`topic_nm'}{p_end}"'
            di as text "{hline}"

            * Build return values
            local codes "`codes' `code'"
            local names `"`names' "`nm'""'
            local sources "`sources' `src_id'"
            local topics `"`topics' "`topic_nm'""'
        }

        * Pagination nav (shown only when there is more than one page)
        __wbod_search_pagenav, page(`page') total_pages(`total_pages') ///
            keyword(`"`kw'"') source("`source'") topic("`topic'") ///
            field("`field'") limit(`limit') `exact' `detail'

        * Navigation tips for detail format
        di as text ""
        di as text "Click " as result "[Info]" as text " for full metadata, " as result "[Get]" as text " to download"
    }
    else {
        *-----------------------------------------------------------------------
        * TABLE format: compact columns with dynamic widths
        *-----------------------------------------------------------------------
        * Calculate dynamic column widths based on linesize
        * Fixed columns: Code(22) + Source(6) + [Info](6) + [Get](5) + spaces(5) = 44
        * Remaining space split: Name(60%) + Topic(40%)
        local linesize = c(linesize)
        local fixed_width = 44
        local avail = `linesize' - `fixed_width'

        * Set minimum widths and calculate dynamic widths
        local name_width = max(30, floor(`avail' * 0.6))
        local topic_width = max(18, `avail' - `name_width')

        * Cap at reasonable maximums to avoid overly wide columns
        local name_width = min(`name_width', 80)
        local topic_width = min(`topic_width', 50)

        * Calculate truncation points (leave room for "...")
        local name_trunc = `name_width' - 2
        local topic_trunc = `topic_width' - 2

        di as text "{hline}"
        di as text %-22s "Code" " " %-`name_width's "Name" " " %6s "Source" " " %-`topic_width's "Topic" " " "[Info]" " " "[Get]"
        di as text "{hline}"

        forvalues i = `pg_start'/`pg_end' {
            local code = ind_code[`i']
            local nm = field_name[`i']
            local src_id = field_source_id[`i']
            local topic_nm = field_topic[`i']
            local topic_id = field_topic_ids[`i']

            * Truncate long names for display (based on dynamic width)
            local nm_disp = "`nm'"
            if (strlen("`nm_disp'") > `name_trunc') {
                local nm_disp = substr("`nm_disp'", 1, `name_trunc' - 3) + "..."
            }

            * Truncate topic for display (based on dynamic width)
            local topic_disp = "`topic_nm'"
            if (strlen("`topic_disp'") > `topic_trunc') {
                local topic_disp = substr("`topic_disp'", 1, `topic_trunc' - 3) + "..."
            }
            if ("`topic_disp'" == "") local topic_disp "-"

            * Build clickable links
            local info_cmd `"wbopendata, info(`code')"'
            local get_cmd `"wbopendata, indicator(`code') clear"'
            local src_cmd `"wbopendata, search() searchsource(`src_id')"'
            local topic_cmd `"wbopendata, search() searchtopic(`topic_id')"'

            * Pad source ID for alignment (6 chars, right-aligned)
            local src_disp = "`src_id'"
            while (strlen("`src_disp'") < 6) {
                local src_disp " `src_disp'"
            }

            * Pad topic for alignment (dynamic width, left-padded)
            local topic_pad = "`topic_disp'"
            while (strlen("`topic_pad'") < `topic_width') {
                local topic_pad "`topic_pad' "
            }

            * Display row with SMCL links (Source and Topic are now clickable)
            di as result %-22s "`code'" as text " " %-`name_width's "`nm_disp'" " " ///
               `"{stata "`src_cmd'":`src_disp'}"' " " ///
               `"{stata "`topic_cmd'":`topic_pad'}"' " " ///
               `"{stata "`info_cmd'":[Info]}"' " " ///
               `"{stata "`get_cmd'":[Get]}"'

            * Build return values
            local codes "`codes' `code'"
            local names `"`names' "`nm'""'
            local sources "`sources' `src_id'"
            local topics `"`topics' "`topic_nm'""'
        }

        di as text "{hline}"

        * Pagination nav (shown only when there is more than one page)
        __wbod_search_pagenav, page(`page') total_pages(`total_pages') ///
            keyword(`"`kw'"') source("`source'") topic("`topic'") ///
            field("`field'") limit(`limit') `exact' `detail'

        * Navigation tips
        di as text ""
        di as text "Click " as result "[Info]" as text " for details, " as result "[Get]" as text " to download, " ///
            as result "Source" as text "/" as result "Topic" as text " to browse similar"
    }

    *---------------------------------------------------------------------------
    * Return values
    *---------------------------------------------------------------------------
    return scalar n_results = `n'
    return scalar n_displayed = `lim'
    return scalar page = `page'
    return scalar n_pages = `total_pages'
    local first = ind_code[1]
    return local first_code = "`first'"
    return local codes = strtrim("`codes'")
    local names_trim = strtrim(`"`names'"')
    local topics_trim = strtrim(`"`topics'"')
    return local names = `"`names_trim'"'
    return local sources = strtrim("`sources'")
    return local topics = `"`topics_trim'"'
    return local keyword = "`kw'"
    return local source_filter = "`source'"
    return local topic_filter = "`topic'"
    return local field_filter = "`field'"
    return local yaml_path = "`yaml_path'"
    return local cache_method = "none"

    * Build reproducible command
    local cmd "wbopendata, search(`kw')"
    if ("`source'" != "") local cmd "`cmd' source(`source')"
    if ("`topic'" != "")  local cmd "`cmd' topic(`topic')"
    if ("`field'" != "")  local cmd "`cmd' field(`field')"
    if ("`exact'" != "")  local cmd "`cmd' exact"
    if ("`detail'" != "") local cmd "`cmd' detail"
    local cmd "`cmd' limit(`limit') page(`page')"
    return local cmd = "`cmd'"

    restore
end
