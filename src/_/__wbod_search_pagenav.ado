*******************************************************************************
*! __wbod_search_pagenav v1.0.0  20Apr2026
*! Render clickable SMCL pagination navigation for indicator search results.
*! Called by __wbopendata_search and __wbopendata_search_cache after displaying
*! a page of results. Emits nothing when total_pages <= 1.
*******************************************************************************

program define __wbod_search_pagenav
    version 14.0
    syntax , PAGE(integer 1) TOTAL_PAGES(integer 1) ///
        [ KEYWORD(string) SOURCE(string) TOPIC(string) ///
          FIELD(string) LIMIT(integer 20) EXACT DETAIL ]

    if (`total_pages' <= 1) exit 0

    * Build the invariant part of the command (all filters minus page).
    * Quote keyword to handle multi-word/regex strings; omit search() entirely
    * for browse-mode calls that only use searchsource()/searchtopic().
    if "`keyword'" != "" {
        local base `"wbopendata, search(`keyword')"'
    }
    else {
        local base "wbopendata,"
    }
    if ("`source'" != "") local base `"`base' searchsource(`source')"'
    if ("`topic'"  != "") local base `"`base' searchtopic(`topic')"'
    if ("`field'"  != "") local base `"`base' searchfield(`field')"'
    if ("`exact'"  != "") local base `"`base' exact"'
    if ("`detail'" != "") local base `"`base' detail"'
    local base `"`base' limit(`limit')"'

    di as text ""

    * Line 1: [Prev] Page X of Y [Next]
    if (`page' > 1) {
        local prev_p = `page' - 1
        local prev_cmd `"`base' page(`prev_p')"'
        local prev_link `"{stata "`prev_cmd'":[Prev]}"'
    }
    else {
        local prev_link "[Prev]"
    }
    if (`page' < `total_pages') {
        local next_p = `page' + 1
        local next_cmd `"`base' page(`next_p')"'
        local next_link `"{stata "`next_cmd'":[Next]}"'
    }
    else {
        local next_link "[Next]"
    }
    di as text "`prev_link'  " as result "Page `page' of `total_pages'" as text "  `next_link'"

    * Line 2: compact page list. Show all if <=10 pages; otherwise show
    * first 2, a window around current page, and last 2, with ... separators.
    local plist ""

    if (`total_pages' <= 10) {
        forvalues p = 1/`total_pages' {
            if (`p' == `page') {
                local plist `"`plist' [`p']"'
            }
            else {
                local p_cmd `"`base' page(`p')"'
                local plist `"`plist' {stata "`p_cmd'":[`p']}"'
            }
        }
    }
    else {
        local win_lo = max(1, `page' - 1)
        local win_hi = min(`total_pages', `page' + 1)

        * Leading: page 1 and 2
        forvalues p = 1/2 {
            if (`p' < `win_lo') {
                if (`p' == `page') {
                    local plist `"`plist' [`p']"'
                }
                else {
                    local p_cmd `"`base' page(`p')"'
                    local plist `"`plist' {stata "`p_cmd'":[`p']}"'
                }
            }
        }
        if (`win_lo' > 3) local plist `"`plist' ..."'

        * Middle window
        forvalues p = `win_lo'/`win_hi' {
            if (`p' == `page') {
                local plist `"`plist' [`p']"'
            }
            else {
                local p_cmd `"`base' page(`p')"'
                local plist `"`plist' {stata "`p_cmd'":[`p']}"'
            }
        }

        if (`win_hi' < `total_pages' - 2) local plist `"`plist' ..."'

        * Trailing: last two pages
        local tail_lo = max(`win_hi' + 1, `total_pages' - 1)
        forvalues p = `tail_lo'/`total_pages' {
            if (`p' == `page') {
                local plist `"`plist' [`p']"'
            }
            else {
                local p_cmd `"`base' page(`p')"'
                local plist `"`plist' {stata "`p_cmd'":[`p']}"'
            }
        }
    }
    di as text "Go to page:`plist'"
end
