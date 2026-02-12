*******************************************************************************
*! _wbopendata_sources v1.1.0  04Feb2026
*! List all World Bank data sources with navigation (Pathway C)
*******************************************************************************

program define _wbopendata_sources, rclass
    version 14.0
    syntax [, LIMIT(integer -1)]

    * Get YAML paths
    _wbopendata_get_yaml_path, type(sources)
    local src_yaml = r(path)

    _wbopendata_get_yaml_path, type(indicators)
    local ind_yaml = r(path)

    if (!fileexists("`src_yaml'")) {
        di as error "Sources metadata not found. Run: wbopendata, sync"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Parse sources YAML - direct file parse
    * Note: infix strips leading whitespace, so detect by content pattern
    *---------------------------------------------------------------------------
    preserve
    quietly {
        * Read sources YAML
        infix str244 rawline 1-244 using "`src_yaml'", clear
        gen long linenum = _n

        * Detect source entry lines: lines like '1': or '37':
        * After infix strips whitespace, these start with quote and end with colon
        gen byte is_source = regexm(strtrim(rawline), "^'[0-9]+':")

        * Extract source code
        gen str10 src_code = ""
        replace src_code = regexs(1) if regexm(strtrim(rawline), "^'([0-9]+)':")

        * Propagate source code to field lines
        gen long src_group = sum(is_source)
        bysort src_group: replace src_code = src_code[1]

        * Extract field values (look for field: value pattern)
        gen str100 src_name = ""
        gen str10 src_avail = ""

        replace src_name = strtrim(substr(rawline, strpos(rawline, ":") + 1, .)) ///
            if regexm(rawline, "^name:")
        replace src_avail = strtrim(substr(rawline, strpos(rawline, ":") + 1, .)) ///
            if regexm(rawline, "^data_availability:")

        * Collapse to one row per source
        collapse (firstnm) src_code (firstnm) src_name (firstnm) src_avail, by(src_group)
        drop if src_code == ""

        * Clean up name (remove surrounding quotes)
        replace src_name = subinstr(src_name, "'", "", .)
        replace src_name = subinstr(src_name, `"""', "", .)

        * Sort by source code (numeric)
        destring src_code, gen(src_num) force
        sort src_num

        count
        local n_sources = r(N)
    }

    *---------------------------------------------------------------------------
    * Count indicators per source (from indicators YAML)
    *---------------------------------------------------------------------------
    tempfile src_data
    quietly save `src_data'

    quietly {
        * Parse indicators YAML for source_id
        infix str244 rawline 1-244 using "`ind_yaml'", clear
        keep if strpos(rawline, "source_id:") > 0
        gen str10 ind_src = strtrim(substr(rawline, strpos(rawline, "source_id:") + 10, .))
        replace ind_src = subinstr(ind_src, "'", "", .)
        replace ind_src = subinstr(ind_src, `"""', "", .)

        * Count by source
        gen n = 1
        collapse (sum) n_indicators = n, by(ind_src)
        rename ind_src src_code

        tempfile ind_counts
        save `ind_counts'

        * Merge back
        use `src_data', clear
        merge 1:1 src_code using `ind_counts', nogenerate
        replace n_indicators = 0 if missing(n_indicators)
        sort src_num
    }

    *---------------------------------------------------------------------------
    * Display with SMCL navigation
    *---------------------------------------------------------------------------
    local total_ind = 0
    forvalues i = 1/`n_sources' {
        local total_ind = `total_ind' + n_indicators[`i']
    }

    di as text ""
    di as result "World Bank Data Sources" as text " (`n_sources' sources, " as result "`total_ind'" as text " indicators)"
    di as text "{hline}"
    di as text %6s "Code" "  " %-45s "Name" %10s "Indicators" "  " "[Browse]"
    di as text "{hline}"

    * Default: show all sources unless a limit was explicitly provided
    local lim = `n_sources'
    if (`limit' > 0) {
        local lim = cond(`limit' < `n_sources', `limit', `n_sources')
    }
    local codes ""
    local names ""
    local n_available = 0

    forvalues i = 1/`lim' {
        local code = src_code[`i']
        local name = src_name[`i']
        local nind = n_indicators[`i']
        local avail = src_avail[`i']

        * Truncate long names
        if (strlen("`name'") > 42) {
            local name = substr("`name'", 1, 39) + "..."
        }

        * Build clickable link
        local browse_cmd `"wbopendata, search() searchsource(`code')"'

        * Display with formatting
        di as text %6s "`code'" "  " as result %-45s "`name'" as text %10s "`nind'" "  " `"{stata `"`browse_cmd'"':[Browse]}"'

        * Build return values
        local codes "`codes' `code'"
        local names `"`names' "`name'""'
        if ("`avail'" == "Y") local n_available = `n_available' + 1
    }

    di as text "{hline}"

    if (`lim' < `n_sources') {
        di as text "Showing `lim' of `n_sources' sources. Use " as result "limit(#)" as text " to see more."
    }

    di as text ""
    di as text "Tip: Click " as result "[Browse]" as text " to see all indicators from a source"
    di as text "     Use " as result `"search(keyword) searchsource(#)"' as text " to filter within a source"

    *---------------------------------------------------------------------------
    * Return values
    *---------------------------------------------------------------------------
    return scalar n_sources = `n_sources'
    return scalar n_available = `n_available'
    return scalar n_indicators = `total_ind'
    return local source_codes = strtrim("`codes'")
    return local source_names = strtrim(`"`names'"')
    return local cmd = "wbopendata, sources"

    restore
end
