*******************************************************************************
*! _wbopendata_search v1.1.0  21Jan2026
*! Search indicators from cached YAML - direct file parse
*******************************************************************************

program define _wbopendata_search, rclass
    version 14.0
    syntax anything(name=keyword) [, LIMIT(integer 20) SOURCE(string)]

    * Strip surrounding quotes from keyword
    local kw `keyword'
    local kw = subinstr(`"`kw'"', `"""', "", .)
    local kw = strtrim(lower("`kw'"))
    local limit = cond(`limit' <= 0, 20, `limit')

    _wbopendata_get_yaml_path, type(indicators)
    local yaml_path = r(path)

    *-----------------------------------------------------------------------
    * Direct file parse - use infix to avoid macro evaluation issues
    * Note: infix strips leading whitespace, so we detect structure by content
    *-----------------------------------------------------------------------
    preserve
    quietly {
        * Use infix to read each line as a single fixed-width string
        infix str244 rawline 1-244 using "`yaml_path'", clear
        gen long linenum = _n
        
        * Detect indicator lines (format: INDICATOR_CODE:)
        * These are lines that end with : and don't start with known field names
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
            (substr(field_val,1,1) == `"""' | substr(field_val,1,1) == "'")
        
        * Assign to specific field columns
        gen str244 field_name = ""
        gen str244 field_desc = ""
        gen str244 field_source = ""
        gen str244 field_topic = ""
        gen str244 field_note = ""
        replace field_name = field_val if field_type == "name"
        replace field_desc = field_val if field_type == "description"
        replace field_source = field_val if field_type == "source_org"
        replace field_topic = field_val if field_type == "topic_names"
        replace field_note = field_val if field_type == "note"
        
        * Collapse to one row per indicator
        collapse (firstnm) ind_code (firstnm) field_name (firstnm) field_desc ///
                 (firstnm) field_source (firstnm) field_topic (firstnm) field_note, by(ind_group)
        drop if ind_code == ""
        
        * Search
        gen byte hit = 0
        replace hit = 1 if strpos(lower(ind_code), "`kw'") > 0
        replace hit = 1 if strpos(lower(field_name), "`kw'") > 0
        replace hit = 1 if strpos(lower(field_desc), "`kw'") > 0
        replace hit = 1 if strpos(lower(field_source), "`kw'") > 0
        replace hit = 1 if strpos(lower(field_topic), "`kw'") > 0
        replace hit = 1 if strpos(lower(field_note), "`kw'") > 0
        
        * Source filter
        if ("`source'" != "") {
            local src_l = lower("`source'")
            replace hit = 0 if strpos(lower(field_source), "`src_l'") == 0
        }
        
        keep if hit
        sort ind_code
    }
    
    count
    local n = r(N)
    if (`n' == 0) {
        di as text "No indicators matched: `kw'"
        restore
        return scalar n_results = 0
        return local yaml_path = "`yaml_path'"
        exit 0
    }
    
    * Display results
    quietly {
        replace field_name = "N/A" if field_name == ""
        replace field_source = "N/A" if field_source == ""
    }
    
    local lim = cond(`limit' < `n', `limit', `n')
    di as text "Matches (showing `lim' of `n'):"
    
    * Build return values
    local codes ""
    local names ""
    local sources ""
    forvalues i = 1/`lim' {
        local code = ind_code[`i']
        local nm : di field_name[`i']
        local src : di field_source[`i']
        di as text `"  `code'  `nm'"'
        local codes "`codes' `code'"
        local names `"`names' "`nm'""'
        local sources `"`sources' "`src'""'
    }
    
    return scalar n_results = `n'
    local first = ind_code[1]
    return local first_code = "`first'"
    return local codes = strtrim("`codes'")
    return local names = strtrim(`"`names'"')
    return local sources = strtrim(`"`sources'"')
    return local yaml_path = "`yaml_path'"
    
    restore
end
