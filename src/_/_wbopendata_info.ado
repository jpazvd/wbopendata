*******************************************************************************
*! _wbopendata_info v1.6.1  04Feb2026
*! Return indicator metadata from cached YAML (Pathway C)
*! Fix: Increase string width for description/note fields (str2045)
*******************************************************************************

program define _wbopendata_info, rclass
    version 14.0
    syntax , INDICATOR(string)

    local code_raw = strtrim("`indicator'")
    if ("`code_raw'" == "") {
        di as err "indicator() required"
        exit 198
    }

    _wbopendata_get_yaml_path, type(indicators)
    local yaml_path = r(path)

    if (!fileexists("`yaml_path'")) {
        di as error "Indicators metadata not found. Run: wbopendata, sync"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Direct YAML parse using infix (same approach as search)
    *---------------------------------------------------------------------------
    preserve
    quietly {
        infix str2045 rawline 1-2045 using "`yaml_path'", clear
        gen long linenum = _n

        * Detect indicator lines (lines ending with : that aren't field names)
        gen byte is_indicator = 0
        replace is_indicator = 1 if substr(rawline,-1,1) == ":" & ///
            substr(rawline,1,5) != "code:" & ///
            substr(rawline,1,5) != "name:" & ///
            substr(rawline,1,10) != "source_id:" & ///
            substr(rawline,1,12) != "source_name:" & ///
            substr(rawline,1,11) != "source_org:" & ///
            substr(rawline,1,10) != "topic_ids:" & ///
            substr(rawline,1,12) != "topic_names:" & ///
            substr(rawline,1,12) != "description:" & ///
            substr(rawline,1,5) != "unit:" & ///
            substr(rawline,1,5) != "note:" & ///
            substr(rawline,1,13) != "limited_data:" & ///
            substr(rawline,1,9) != "_metadata" & ///
            substr(rawline,1,11) != "indicators:" & ///
            substr(rawline,1,1) != "-"

        * Extract indicator code
        gen str100 ind_code = ""
        replace ind_code = strtrim(substr(rawline, 1, length(rawline) - 1)) if is_indicator

        * Propagate indicator code
        gen long ind_group = sum(is_indicator)
        bysort ind_group: replace ind_code = ind_code[1]

        * Extract field type and value
        gen byte is_field = strpos(rawline, ":") > 0 & is_indicator == 0 & linenum > 9
        gen str20 field_type = ""
        gen int colon_pos = strpos(rawline, ":")
        replace field_type = strtrim(substr(rawline, 1, colon_pos - 1)) if is_field & colon_pos > 0

        gen str2045 field_val = ""
        replace field_val = strtrim(substr(rawline, colon_pos + 1, .)) if is_field & colon_pos > 0
        * Remove surrounding quotes
        replace field_val = substr(field_val, 2, length(field_val)-2) if is_field & ///
            (substr(field_val,1,1) == `"""' | substr(field_val,1,1) == "'")

        * Assign to specific field columns
        gen str244 field_name = ""
        gen str2045 field_desc = ""
        gen str244 field_source = ""
        gen str244 field_source_name = ""
        gen str244 field_topic = ""
        gen str2045 field_note = ""
        gen str20 field_source_id = ""
        replace field_name = field_val if field_type == "name"
        replace field_desc = field_val if field_type == "description"
        replace field_source = field_val if field_type == "source_org"
        replace field_source_name = field_val if field_type == "source_name"
        replace field_topic = field_val if field_type == "topic_names"
        replace field_note = field_val if field_type == "note"
        replace field_source_id = field_val if field_type == "source_id"

        *-------------------------------------------------------------------
        * Handle YAML list format: topic_ids and topic_names are lists
        * Format:  topic_ids:
        *          - '11'
        *          topic_names:
        *          - 'Poverty '
        *-------------------------------------------------------------------
        gen byte is_list_item = substr(strtrim(rawline), 1, 2) == "- "
        gen str244 list_item_val = ""
        replace list_item_val = strtrim(substr(rawline, strpos(rawline, "- ") + 2, .)) if is_list_item
        * Remove surrounding quotes from list values
        replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
            (substr(list_item_val,1,1) == "'" | substr(list_item_val,1,1) == `"""')

        * Track which field header introduces the current list context
        gen str20 last_field_header = ""
        replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
        * Forward-fill the context
        replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

        * Assign list item values to the appropriate fields
        gen str244 field_topic_list = ""
        replace field_topic_list = list_item_val if is_list_item & last_field_header == "topic_names"
        * Also capture topic_ids for completeness
        gen str50 field_topic_ids_list = ""
        replace field_topic_ids_list = list_item_val if is_list_item & last_field_header == "topic_ids"

        drop is_list_item list_item_val last_field_header

        * Collapse to one row per indicator
        collapse (firstnm) ind_code (firstnm) field_name (firstnm) field_desc ///
                 (firstnm) field_source (firstnm) field_source_name (firstnm) field_topic ///
                 (firstnm) field_topic_list (firstnm) field_topic_ids_list (firstnm) field_note ///
                 (firstnm) field_source_id, by(ind_group)

        * Find the requested indicator (case-insensitive)
        gen byte match = upper(ind_code) == upper("`code_raw'")
        keep if match
    }

    count
    if (r(N) == 0) {
        di as error "Indicator not found: `code_raw'"
        restore
        exit 111
    }

    * Extract values safely
    local ind = ind_code[1]
    local name = field_name[1]
    local desc = field_desc[1]
    local src = field_source[1]
    local src_name = field_source_name[1]
    local topics = field_topic[1]
    local topics_list = field_topic_list[1]
    local topic_id = field_topic_ids_list[1]
    local note = field_note[1]
    local src_id = field_source_id[1]

    * Handle YAML multi-line markers
    if ("`src'" == "|-" | "`src'" == "|" | "`src'" == ">-" | "`src'" == ">") {
        local src ""
    }
    if ("`topics'" == "" | substr("`topics'", 1, 1) == "[") {
        * Use list format if inline is empty or array marker
        local topics "`topics_list'"
    }

    * Use source_name as fallback for source_org
    if ("`src'" == "" & "`src_name'" != "") {
        local src "`src_name'"
    }

    * Fallbacks
    if ("`name'" == "") local name "N/A"
    if ("`src'" == "") local src "N/A"
    if ("`topics'" == "") local topics "N/A"
    if ("`desc'" == "") local desc "N/A"
    if ("`note'" == "") local note "N/A"

    *---------------------------------------------------------------------------
    * Display with SMCL navigation (using {p 4 4 4} format like _query_metadata)
    *---------------------------------------------------------------------------
    di as text ""
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Indicator}: `ind'{p_end}"'
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Name}: `name'{p_end}"'
    di as text "{hline}"
    if ("`src_id'" != "" & "`src_name'" != "") {
        di in smcl `"{p 4 4 4}{result:Source}: `src_name' (ID: `src_id') {stata `"wbopendata, search() source(`src_id')"':[Browse]}{p_end}"'
    }
    else {
        di in smcl `"{p 4 4 4}{result:Source}: `src'{p_end}"'
    }
    di as text "{hline}"
    if ("`topic_id'" != "") {
        di in smcl `"{p 4 4 4}{result:Topics}: `topics' {stata `"wbopendata, search() topic(`topic_id')"':[Browse]}{p_end}"'
    }
    else {
        di in smcl `"{p 4 4 4}{result:Topics}: `topics'{p_end}"'
    }
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Description}: `desc'{p_end}"'
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Note}: `note'{p_end}"'
    di as text "{hline}"
    di as result "Download:"
    di `"  {stata `"wbopendata, indicator(`ind') clear"':[Wide format]}"'
    di `"  {stata `"wbopendata, indicator(`ind') clear long"':[Long format]}"'
    di `"  {stata `"wbopendata, indicator(`ind') country(BRA;USA;CHN) clear long"':[Specific countries]}"'
    di as text "{hline}"

    *---------------------------------------------------------------------------
    * Return values
    *---------------------------------------------------------------------------
    return local indicator = "`ind'"
    return local name = "`name'"
    return local source_name = "`src_name'"
    return local source_org = "`src'"
    return local source_id = "`src_id'"
    return local topics = "`topics'"
    return local description = "`desc'"
    return local note = "`note'"
    return local yaml_path = "`yaml_path'"
    return local cmd = "wbopendata, info(`ind')"

    restore
end
