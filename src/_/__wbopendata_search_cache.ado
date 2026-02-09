*******************************************************************************
*! __wbopendata_search_cache v3.1.0  04Feb2026
*! Search indicators with frame-based session caching (Stata 16+)
*! Uses __wbod_parse_yaml_ind, caches processed dataset in frame for speed
*******************************************************************************

program define __wbopendata_search_cache, rclass
    version 16.0
    syntax [anything(name=keyword)] [, LIMIT(integer 20) SOURCE(string) ///
        TOPIC(string) FIELD(string) EXACT DETAIL NOcache DEBUG]

    * Strip surrounding quotes from keyword
    local kw `keyword'
    local kw = subinstr(`"`kw'"', `"""', "", .)
    local kw = strtrim("`kw'")
    local kw_lower = lower("`kw'")
    local limit = cond(`limit' <= 0, 20, `limit')

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
        di as text "  wbopendata, search() source(2)"
        di as text "  wbopendata, search(poverty) topic(11)"
        exit 198
    }

    _wbopendata_get_yaml_path, type(indicators)
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
    * Frame cache: parse once, reuse across calls
    *---------------------------------------------------------------------------
    local use_cache = ("`nocache'" == "")
    local cache_method = "frames"
    local parser_version "1.0.10"

    preserve

    if (`use_cache') {
        *-----------------------------------------------------------------------
        * FRAME CACHE approach
        * First call: parse YAML via __wbod_parse_yaml_ind, save to frame
        * Subsequent calls: load from cached frame
        *-----------------------------------------------------------------------
        local frame_name "_wbod_indicators"
        local cache_loaded = 0

        * Check if frame already exists with valid data
        * Cache validity: frame exists + has expected variables + parser version matches
        * No content-based guards - trust parser version for invalidation
        capture frame `frame_name': count
        if (_rc == 0 & r(N) > 0) {
            capture frame `frame_name': confirm variable ind_code field_name field_source_id field_source_name field_unit field_limited_data _parser_version
            if (_rc == 0) {
                local cache_loaded = 1
                frame `frame_name' {
                    local cache_version = _parser_version[1]
                }
                if ("`cache_version'" != "`parser_version'") {
                    local cache_loaded = 0
                }
                * Show cache message if cache is valid
                if (`cache_loaded') {
                    di as text "(Using cached metadata from memory)"
                }
            }
        }

        if (!`cache_loaded') {
            * First call or invalid cache - parse YAML and cache result
            di as text "(Caching metadata in memory...)"

            __wbod_parse_yaml_ind "`yaml_path'"
            gen str10 _parser_version = "`parser_version'"

            * Save processed dataset to frame for future use
            capture frame drop `frame_name'
            frame put *, into(`frame_name')

            if ("`debug'" != "") {
                count
                di as text "(Cached `r(N)' indicators to frame)"
            }
        }
        else {
            * Load cached data from frame via tempfile
            tempfile cache_tmp
            frame `frame_name' {
                quietly save `cache_tmp', replace
            }
            quietly use `cache_tmp', clear
        }
    }
    else {
        *-----------------------------------------------------------------------
        * NO CACHE: parse YAML each call (nocache option)
        *-----------------------------------------------------------------------
        local cache_method = "nocache"
        if ("`debug'" != "") {
            di as text "(Parsing YAML - no cache)"
        }
        __wbod_parse_yaml_ind "`yaml_path'"
    }

    *---------------------------------------------------------------------------
    * Apply filters and search
    *---------------------------------------------------------------------------
    quietly {
        * Apply source filter (by ID)
        * Zero-pad single-digit IDs to match YAML format (e.g. "2" -> "02")
        if ("`source'" != "") {
            local src_filter "`source'"
            if (length("`src_filter'") == 1 & real("`src_filter'") != .) {
                local src_filter "0`src_filter'"
            }
            keep if field_source_id == "`src_filter'" | field_source_id == "`source'"
        }

        * Apply topic filter (by ID - check if ID is in semicolon-separated list)
        * Must use word-boundary matching to avoid "1" matching "11", "14", "21" etc.
        if ("`topic'" != "") {
            gen byte topic_match = 0
            * Exact match (single topic)
            replace topic_match = 1 if field_topic_ids == "`topic'"
            * First in list: "1;..."
            replace topic_match = 1 if strpos(field_topic_ids, "`topic';") == 1
            * Middle of list: "...;1;..."
            replace topic_match = 1 if strpos(field_topic_ids, ";`topic';") > 0
            * End of list: "...;1" - use regex for end anchor
            replace topic_match = 1 if regexm(field_topic_ids, ";`topic'$")
            keep if topic_match
            drop topic_match
        }

        * Apply keyword search
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

    quietly count
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
        return local keyword = "`kw'"
        return local source_filter = "`source'"
        return local topic_filter = "`topic'"
        return local field_filter = "`field'"
        return local yaml_path = "`yaml_path'"
        return local cache_method = "`cache_method'"
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
        return local cache_method = "`cache_method'"
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

    * Smart limit: if total ≤ 30, show all; otherwise use specified limit
    local lim = cond(`n' <= 30, `n', cond(`limit' < `n', `limit', `n'))

    * Build header
    di as text ""
    if ("`kw'" != "") {
        di as result "Search results for " as text `""`kw'""' as result " (showing `lim' of `n' matches)"
    }
    else if ("`source'" != "") {
        di as result "Indicators from source `source'" as text " (showing `lim' of `n')"
    }
    else if ("`topic'" != "") {
        di as result "Indicators in topic `topic'" as text " (showing `lim' of `n')"
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

        forvalues i = 1/`lim' {
            local code = ind_code[`i']
            local nm = field_name[`i']
            local src_id = field_source_id[`i']
            local topic_nm = field_topic[`i']
            local topic_id = field_topic_ids[`i']
            if ("`topic_nm'" == "") local topic_nm "-"

            * Build clickable links
            local info_cmd `"wbopendata, info(`code')"'
            local get_cmd `"wbopendata, indicator(`code') clear"'
            local src_cmd `"wbopendata, search() source(`src_id')"'
            local topic_cmd `"wbopendata, search() topic(`topic_id')"'

            * Display block with wrapped fields
            di as result "`code'" as text "  " ///
               `"{stata `"`info_cmd'"':[Info]}"' " " ///
               `"{stata `"`get_cmd'"':[Get]}"'
            di in smcl `"{p 4 4 4}{result:Name}: `nm'{p_end}"'
            di in smcl `"{p 4 4 4}{result:Source}: {stata `"`src_cmd'"':`src_id'}  {result:Topic}: {stata `"`topic_cmd'"':`topic_nm'}{p_end}"'
            di as text "{hline}"

            * Build return values
            local codes "`codes' `code'"
            local names `"`names' "`nm'""'
            local sources "`sources' `src_id'"
            local topics `"`topics' "`topic_nm'""'
        }

        if (`lim' < `n') {
            di as text "Showing `lim' of `n' results. Use " as result "limit(#)" as text " to see more."
        }

        * Navigation tips for detail format
        di as text ""
        di as text "Click " as result "[Info]" as text " for full metadata, " as result "[Get]" as text " to download"
    }
    else {
        *-----------------------------------------------------------------------
        * TABLE format: compact columns with dynamic widths
        *-----------------------------------------------------------------------
        local linesize = c(linesize)
        local fixed_width = 44
        local avail = `linesize' - `fixed_width'

        local name_width = max(30, floor(`avail' * 0.6))
        local topic_width = max(18, `avail' - `name_width')

        local name_width = min(`name_width', 80)
        local topic_width = min(`topic_width', 50)

        local name_trunc = `name_width' - 2
        local topic_trunc = `topic_width' - 2

        di as text "{hline}"
        di as text %-22s "Code" " " %-`name_width's "Name" " " %6s "Source" " " %-`topic_width's "Topic" " " "[Info]" " " "[Get]"
        di as text "{hline}"

        forvalues i = 1/`lim' {
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
            local src_cmd `"wbopendata, search() source(`src_id')"'
            local topic_cmd `"wbopendata, search() topic(`topic_id')"'

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

            * Display row with SMCL links
                di as result %-22s "`code'" as text " " %-`name_width's "`nm_disp'" " " ///
               `"{stata `"`src_cmd'"':`src_disp'}"' " " ///
               `"{stata `"`topic_cmd'"':`topic_pad'}"' " " ///
               `"{stata `"`info_cmd'"':[Info]}"' " " ///
               `"{stata `"`get_cmd'"':[Get]}"'

            * Build return values
            local codes "`codes' `code'"
            local names `"`names' "`nm'""'
            local sources "`sources' `src_id'"
            local topics `"`topics' "`topic_nm'""'
        }

        di as text "{hline}"

        if (`lim' < `n') {
            di as text "Showing `lim' of `n' results. Use " as result "limit(#)" as text " to see more."
        }

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
    return local cache_method = "`cache_method'"

    * Build reproducible command
    local cmd "wbopendata, search(`kw')"
    if ("`source'" != "") local cmd "`cmd' source(`source')"
    if ("`topic'" != "")  local cmd "`cmd' topic(`topic')"
    if ("`field'" != "")  local cmd "`cmd' field(`field')"
    if ("`exact'" != "")  local cmd "`cmd' exact"
    if ("`detail'" != "") local cmd "`cmd' detail"
    local cmd "`cmd' limit(`limit')"
    return local cmd = "`cmd'"

    restore
    exit 0
end
