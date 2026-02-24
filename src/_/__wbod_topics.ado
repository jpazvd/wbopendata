*******************************************************************************
*! __wbod_topics v1.2.2  22Feb2026
*! List all World Bank topic categories with navigation (Pathway C)
*******************************************************************************

program define __wbod_topics, rclass
    version 14.0
    syntax [, LIMIT(integer -1)]

    * Get YAML paths
    __wbod_get_yaml_path, type(topics)
    local topic_yaml = r(path)

    __wbod_get_yaml_path, type(indicators)
    local ind_yaml = r(path)

    if (!fileexists("`topic_yaml'")) {
        di as error "Topics metadata not found. Run: wbopendata, sync"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Parse topics YAML - direct file parse
    * Note: infix strips leading whitespace, so detect by content pattern
    *---------------------------------------------------------------------------
    preserve
    quietly {
        * Read topics YAML
        infix str500 rawline 1-500 using "`topic_yaml'", clear
        gen long linenum = _n

        * Detect topic entry lines: lines like '1': or '21':
        * After infix strips whitespace, these start with quote and end with colon
        gen byte is_topic = regexm(strtrim(rawline), "^'[0-9]+':")

        * Extract topic code
        gen str10 topic_code = ""
        replace topic_code = regexs(1) if regexm(strtrim(rawline), "^'([0-9]+)':")

        * Propagate topic code to field lines
        gen long topic_group = sum(is_topic)
        bysort topic_group: replace topic_code = topic_code[1]

        * Extract field values (look for field: value pattern)
        gen str100 topic_name = ""
        replace topic_name = strtrim(substr(rawline, strpos(rawline, ":") + 1, .)) ///
            if regexm(rawline, "^name:")

        * Collapse to one row per topic
        collapse (firstnm) topic_code (firstnm) topic_name, by(topic_group)
        drop if topic_code == ""

        * Clean up name (remove surrounding quotes)
        replace topic_name = subinstr(topic_name, "'", "", .)
        replace topic_name = subinstr(topic_name, `"""', "", .)

        * Sort by topic code (numeric)
        destring topic_code, gen(topic_num) force
        sort topic_num

        count
        local n_topics = r(N)
    }

    *---------------------------------------------------------------------------
    * Count indicators per topic (from indicators YAML)
    * Handle YAML list format: topic_ids are stored as lists, not inline values
    *---------------------------------------------------------------------------
    tempfile topic_data
    quietly save `topic_data'

    quietly {
        * Parse indicators YAML - handle list format
        infix str244 rawline 1-244 using "`ind_yaml'", clear
        gen long linenum = _n

        * Extract field type (for lines with colon)
        gen int colon_pos = strpos(rawline, ":")
        gen str20 field_type = strtrim(substr(rawline, 1, colon_pos - 1)) if colon_pos > 0

        * Track which field header introduces the current list context
        gen str20 last_field_header = ""
        replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
        * Forward-fill the context
        replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

        * Detect list items (lines starting with "- ")
        gen byte is_list_item = substr(strtrim(rawline), 1, 2) == "- "
        gen str100 list_item_val = ""
        replace list_item_val = strtrim(substr(rawline, strpos(rawline, "- ") + 2, .)) if is_list_item
        * Remove surrounding quotes from list values
        replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
            (substr(list_item_val,1,1) == "'" | substr(list_item_val,1,1) == `"""')

        * Keep only topic_ids list items
        keep if is_list_item & last_field_header == "topic_ids"
        keep list_item_val
        rename list_item_val topic_code

        * Handle empty topic_ids
        drop if topic_code == "" | topic_code == "N/A"
        replace topic_code = strtrim(topic_code)

        * Count by topic (each row is one indicator-topic pair)
        gen n = 1
        collapse (sum) n_indicators = n, by(topic_code)

        tempfile topic_counts
        save `topic_counts'

        * Merge back
        use `topic_data', clear
        merge 1:1 topic_code using `topic_counts', nogenerate
        replace n_indicators = 0 if missing(n_indicators)
        sort topic_num
    }

    *---------------------------------------------------------------------------
    * Display with SMCL navigation
    *---------------------------------------------------------------------------
    local total_ind = 0
    forvalues i = 1/`n_topics' {
        local total_ind = `total_ind' + n_indicators[`i']
    }

    di as text ""
    di as result "World Bank Topics" as text " (`n_topics' categories)"
    di as text "{hline}"
    di as text %4s "ID" "  " %-45s "Name" %10s "Indicators" "  " "[Browse]"
    di as text "{hline}"

    * Default: show all topics unless a limit was explicitly provided
    local lim = `n_topics'
    if (`limit' > 0) {
        local lim = cond(`limit' < `n_topics', `limit', `n_topics')
    }
    local ids ""
    local names ""

    forvalues i = 1/`lim' {
        local code = topic_code[`i']
        local name = topic_name[`i']
        local nind = n_indicators[`i']

        * Truncate long names
        if (strlen("`name'") > 42) {
            local name = substr("`name'", 1, 39) + "..."
        }

        * Build clickable link
        local browse_cmd `"wbopendata, search() searchtopic(`code')"'

        * Display with formatting
        di as text %4s "`code'" "  " as result %-45s "`name'" as text %10s "`nind'" "  " `"{stata `"`browse_cmd'"':[Browse]}"'

        * Build return values
        local ids "`ids' `code'"
        local names `"`names' "`name'""'
    }

    di as text "{hline}"

    if (`lim' < `n_topics') {
        di as text "Showing `lim' of `n_topics' topics. Use " as result "limit(#)" as text " to see more."
    }

    di as text ""
    di as text "Tip: Click " as result "[Browse]" as text " to see all indicators in a topic"
    di as text "     Use " as result `"search(keyword) searchtopic(#)"' as text " to filter within a topic"

    *---------------------------------------------------------------------------
    * Return values
    *---------------------------------------------------------------------------
    return scalar n_topics = `n_topics'
    return local topic_ids = strtrim("`ids'")
    return local topic_names = strtrim(`"`names'"')
    return local cmd = "wbopendata, alltopics"

    restore
end


