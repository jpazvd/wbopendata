*******************************************************************************
*! _parameters v2.0.0  04Feb2026
*! Read wbopendata parameters from YAML (replaces hardcoded return values)
*! Returns identical r() interface for backward compatibility
*******************************************************************************

program define _parameters, rclass

    version 14.0

    return add

    *---------------------------------------------------------------------------
    * Locate the parameters YAML file
    *---------------------------------------------------------------------------
    _wbopendata_get_yaml_path, type(parameters)
    local yaml_path = r(path)

    if (!fileexists("`yaml_path'")) {
        di as error "_wbopendata_parameters.yaml not found"
        di as text "Expected at: `yaml_path'"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Parse the YAML file using infix
    *---------------------------------------------------------------------------
    preserve
    quietly {
        infix str500 rawline 1-500 using "`yaml_path'", clear
        gen long linenum = _n

        * Skip comment lines
        gen byte is_comment = substr(strtrim(rawline), 1, 1) == "#"

        *-----------------------------------------------------------------------
        * Track which section we're in (sources vs topics vs top-level)
        *-----------------------------------------------------------------------
        gen str10 sec_type = ""
        replace sec_type = "sources" if rawline == "sources:"
        replace sec_type = "topics"  if rawline == "topics:"
        replace sec_type = "flat"    if inlist(rawline, "_metadata:", ///
            "total:", "number_indicators:", "dt_update:", "dt_lastcheck:", ///
            "ctrymetadata:", "dt_ctrylastupdate:", "dt_ctrylastcheck:", ///
            "dt_ctryupdate:")
        * Forward-fill section type
        replace sec_type = sec_type[_n-1] if sec_type == "" & _n > 1

        *-----------------------------------------------------------------------
        * Extract key-value pairs
        *-----------------------------------------------------------------------
        gen int colon_pos = strpos(rawline, ":")
        gen str30 field_key = ""
        gen str244 field_val = ""
        replace field_key = strtrim(substr(rawline, 1, colon_pos - 1)) ///
            if colon_pos > 0 & !is_comment
        replace field_val = strtrim(substr(rawline, colon_pos + 1, .)) ///
            if colon_pos > 0 & !is_comment
        * Remove surrounding quotes from values
        replace field_val = substr(field_val, 2, length(field_val) - 2) ///
            if (substr(field_val, 1, 1) == "'" | substr(field_val, 1, 1) == `"""') ///
            & length(field_val) >= 2

        *-----------------------------------------------------------------------
        * Extract flat scalars (top-level key-value pairs)
        *-----------------------------------------------------------------------
        local total = ""
        local number_indicators = ""
        local dt_update = ""
        local dt_lastcheck = ""
        local ctrymetadata = ""
        local dt_ctrylastupdate = ""
        local dt_ctrylastcheck = ""
        local dt_ctryupdate = ""

        count if field_key == "total" & sec_type != "sources" & sec_type != "topics"
        if (r(N) > 0) {
            sum linenum if field_key == "total" & sec_type != "sources" & sec_type != "topics", meanonly
            local total = field_val[`r(min)']
        }
        count if field_key == "number_indicators"
        if (r(N) > 0) {
            sum linenum if field_key == "number_indicators", meanonly
            local number_indicators = field_val[`r(min)']
        }
        count if field_key == "dt_update"
        if (r(N) > 0) {
            sum linenum if field_key == "dt_update", meanonly
            local dt_update = field_val[`r(min)']
        }
        count if field_key == "dt_lastcheck"
        if (r(N) > 0) {
            sum linenum if field_key == "dt_lastcheck", meanonly
            local dt_lastcheck = field_val[`r(min)']
        }
        count if field_key == "ctrymetadata"
        if (r(N) > 0) {
            sum linenum if field_key == "ctrymetadata", meanonly
            local ctrymetadata = field_val[`r(min)']
        }
        count if field_key == "dt_ctrylastupdate"
        if (r(N) > 0) {
            sum linenum if field_key == "dt_ctrylastupdate", meanonly
            local dt_ctrylastupdate = field_val[`r(min)']
        }
        count if field_key == "dt_ctrylastcheck"
        if (r(N) > 0) {
            sum linenum if field_key == "dt_ctrylastcheck", meanonly
            local dt_ctrylastcheck = field_val[`r(min)']
        }
        count if field_key == "dt_ctryupdate"
        if (r(N) > 0) {
            sum linenum if field_key == "dt_ctryupdate", meanonly
            local dt_ctryupdate = field_val[`r(min)']
        }

        *-----------------------------------------------------------------------
        * Extract source/topic entries (code, count, name)
        *-----------------------------------------------------------------------
        * Detect entry lines: lines matching pattern 'CODE':
        gen byte is_entry = regexm(rawline, "^'[0-9a-zA-Z]+':")
        gen str20 entry_code = ""
        replace entry_code = regexs(1) if regexm(rawline, "^'([0-9a-zA-Z]+)':")

        * Propagate entry code to its child fields
        gen long entry_group = sum(is_entry)
        bysort entry_group: replace entry_code = entry_code[1] if entry_code == ""

        * Extract count and name for entries
        gen str10 entry_count = ""
        gen str244 entry_name = ""
        replace entry_count = field_val if field_key == "count" & (sec_type == "sources" | sec_type == "topics")
        replace entry_name = field_val if field_key == "name" & (sec_type == "sources" | sec_type == "topics")

        * Collapse to one row per entry
        tempfile parsed
        collapse (firstnm) entry_code (firstnm) entry_count (firstnm) entry_name ///
                 (firstnm) sec_type, by(entry_group)
        drop if entry_code == ""
        save `parsed'

        *-----------------------------------------------------------------------
        * Build source return values
        *-----------------------------------------------------------------------
        use `parsed' if sec_type == "sources", clear
        destring entry_code, gen(sort_num) force
        sort sort_num
        drop sort_num

        local sourcereturn = ""
        local sourceid = ""
        count
        local n_sources = r(N)

        forvalues i = 1/`n_sources' {
            local scode = entry_code[`i']
            local scount = entry_count[`i']
            local sname = entry_name[`i']

            * Pad source code to 2 digits for sourceidNN format
            local scode_pad = "`scode'"
            if (strlen("`scode_pad'") == 1) local scode_pad "0`scode_pad'"

            * Return individual source count: r(sourceidNN)
            return local sourceid`scode_pad' = `scount'

            * Build sourcereturn list
            if ("`sourcereturn'" == "") {
                local sourcereturn "sourceid`scode_pad'"
            }
            else {
                local sourcereturn "`sourcereturn' sourceid`scode_pad'"
            }

            * Build sourceid compound-quoted list
            local sourceid `"`sourceid' `"`scode_pad' `sname'"'"'
        }
        local sourceid = strtrim(`"`sourceid'"')

        *-----------------------------------------------------------------------
        * Build topic return values
        *-----------------------------------------------------------------------
        use `parsed' if sec_type == "topics", clear
        * Sort: numeric topics first, then topicID last
        gen byte is_special = entry_code == "topicID"
        destring entry_code, gen(sort_num) force
        replace sort_num = 999 if is_special
        sort sort_num
        drop is_special sort_num

        local topicreturn = ""
        local topicid = ""
        count
        local n_topics = r(N)

        forvalues i = 1/`n_topics' {
            local tcode = entry_code[`i']
            local tcount = entry_count[`i']
            local tname = entry_name[`i']

            * Pad numeric topic codes to 2 digits, keep topicID as-is
            local tcode_pad = "`tcode'"
            if (strlen("`tcode_pad'") == 1) local tcode_pad "0`tcode_pad'"

            * Return individual topic count: r(topicidNN) or r(topicidtopicID)
            return local topicid`tcode_pad' = `tcount'

            * Build topicreturn list
            if ("`topicreturn'" == "") {
                local topicreturn "topicid`tcode_pad'"
            }
            else {
                local topicreturn "`topicreturn' topicid`tcode_pad'"
            }

            * Build topicid compound-quoted list
            local topicid `"`topicid' `"`tcode_pad' `tname'"'"'
        }
        local topicid = strtrim(`"`topicid'"')
    }

    *---------------------------------------------------------------------------
    * Return all values (identical interface to old hardcoded version)
    *---------------------------------------------------------------------------
    return local total = `total'

    return local sourcereturn "`sourcereturn'"
    return local topicreturn "`topicreturn'"
    return local sourceid `"`sourceid'"'
    return local topicid `"`topicid'"'

    return local number_indicators = `number_indicators'
    return local dt_update "`dt_update'"
    return local dt_lastcheck "`dt_lastcheck'"

    return local ctrymetadata = `ctrymetadata'
    return local dt_ctrylastupdate "`dt_ctrylastupdate'"
    return local dt_ctrylastcheck "`dt_ctrylastcheck'"
    return local dt_ctryupdate "`dt_ctryupdate'"

    restore
end
