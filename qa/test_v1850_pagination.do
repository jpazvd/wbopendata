/*******************************************************************************
* test_v1850_pagination.do  — v18.5.0 pagination tests
* Usage (via run_test_v1850.do wrapper which sets adopath):
*   do qa/run_test_v1850.do
*   do qa/run_test_v1850.do verbose
*******************************************************************************/

clear all
set more off
cap log close _all

*-------------------------------------------------------------------------------
* Detect installed version
*-------------------------------------------------------------------------------
local version "unknown"
capture {
    findfile wbopendata.ado
    file open _vf using "`r(fn)'", read text
    forvalues i = 1/10 {
        file read _vf line
        if r(eof) continue, break
        if substr(trim("`line'"), 1, 2) == "*!" {
            local line = itrim(subinstr(trim(substr("`line'", 3, .)), char(9), " ", .))
            if substr("`line'", 1, 1) == "v" & wordcount("`line'") >= 2 {
                local version = word(trim(substr("`line'", 2, .)), 1)
            }
            continue, break
        }
    }
    file close _vf
}

local datestr = subinstr(c(current_date), " ", "", .)
log using "qa/test_v1850_pagination_`datestr'.log", replace text

di as text "======================================================================"
di as text "WBOPENDATA PAGINATION TESTS  (v18.5.0)"
di as text "Installed: `version'   Stata: `c(stata_version)'   `c(current_date)'"
di as text "======================================================================"

local pass = 0
local fail = 0
local skip = 0
local failed_list ""

*-------------------------------------------------------------------------------
* Warmup: trigger YAML load once so all tests use cached frame
*-------------------------------------------------------------------------------
di as text _n "--- INIT: warming up YAML cache ---"
cap qui wbopendata, search(GDP) limit(1)
local _init_rc = _rc
if `_init_rc' != 0 {
    di as error "WARNING: warmup search failed r(`_init_rc') — tests may fail"
}
else {
    di as text "(YAML cache ready)"
}

*-------------------------------------------------------------------------------
* PAGE-01: Large result set → multiple pages
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-01: Large result set produces multiple pages ---"
cap qui wbopendata, search(GDP) limit(5)
local myrc = _rc
if `myrc' != 0 {
    di as error "FAIL: search(GDP) limit(5) returned r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-01"
}
else if r(n_pages) <= 1 {
    di as error "FAIL: Expected n_pages>1, got `r(n_pages)'"
    local ++fail
    local failed_list "`failed_list' PAGE-01"
}
else if r(page) != 1 {
    di as error "FAIL: Expected r(page)=1, got `r(page)'"
    local ++fail
    local failed_list "`failed_list' PAGE-01"
}
else {
    di as result "PASS  [n_results=`r(n_results)' n_pages=`r(n_pages)']"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-02: Small result set stays on single page
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-02: Small result set stays on single page ---"
cap qui wbopendata, search(SP.POP.TOTL) limit(20)
local myrc = _rc
if `myrc' != 0 {
    di as error "FAIL: search(SP.POP.TOTL) returned r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-02"
}
else if r(n_pages) != 1 {
    di as error "FAIL: Expected n_pages=1, got `r(n_pages)'"
    local ++fail
    local failed_list "`failed_list' PAGE-02"
}
else {
    di as result "PASS  [n_results=`r(n_results)' n_pages=`r(n_pages)']"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-03: Explicit page(1) matches default
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-03: Explicit page(1) matches default ---"
cap qui wbopendata, search(GDP) limit(5)
local n_default  = r(n_results)
local np_default = r(n_pages)
cap qui wbopendata, search(GDP) limit(5) page(1)
local myrc = _rc
if `myrc' != 0 {
    di as error "FAIL: page(1) returned r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-03"
}
else if r(n_results) != `n_default' {
    di as error "FAIL: n_results differs: default=`n_default' page(1)=`r(n_results)'"
    local ++fail
    local failed_list "`failed_list' PAGE-03"
}
else {
    di as result "PASS"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-04: page(2) returns different codes than page(1)
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-04: Page 2 returns different indicators than page 1 ---"
cap qui wbopendata, search(GDP) limit(5) page(1)
local myrc  = _rc
local np    = r(n_pages)
local codes_p1 = r(codes)
if `myrc' != 0 {
    di as error "FAIL: page(1) returned r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-04"
}
else if `np' < 2 {
    di as text "SKIP: not enough pages (n_pages=`np')"
    local ++skip
}
else {
    cap qui wbopendata, search(GDP) limit(5) page(2)
    local myrc2 = _rc
    if `myrc2' != 0 {
        di as error "FAIL: page(2) returned r(`myrc2')"
        local ++fail
        local failed_list "`failed_list' PAGE-04"
    }
    else if r(page) != 2 {
        di as error "FAIL: Expected r(page)=2, got `r(page)'"
        local ++fail
        local failed_list "`failed_list' PAGE-04"
    }
    else if `"`r(codes)'"' == `"`codes_p1'"' {
        di as error "FAIL: Page 2 returned same codes as page 1"
        local ++fail
        local failed_list "`failed_list' PAGE-04"
    }
    else {
        di as result "PASS"
        local ++pass
    }
}

*-------------------------------------------------------------------------------
* PAGE-05: r(n_displayed) never exceeds limit
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-05: r(n_displayed) never exceeds limit() ---"
cap qui wbopendata, search(GDP) limit(5) page(1)
local myrc = _rc
local nd   = r(n_displayed)
if `myrc' != 0 {
    di as error "FAIL: r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-05"
}
else if `nd' > 5 {
    di as error "FAIL: n_displayed=`nd' > limit=5"
    local ++fail
    local failed_list "`failed_list' PAGE-05"
}
else {
    di as result "PASS  [n_displayed=`nd']"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-06: Noisily multi-page search does not throw r(197)
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-06: Noisily multi-page search does not throw r(197) ---"
cap noi wbopendata, search(GDP) limit(5) page(1)
local myrc = _rc
if `myrc' == 197 {
    di as error "FAIL: r(197) — SMCL link quoting broken in pagenav or table rows"
    local ++fail
    local failed_list "`failed_list' PAGE-06"
}
else if `myrc' != 0 {
    di as error "FAIL: unexpected r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-06"
}
else {
    di as result "PASS"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-07: Noisily small result set does not throw r(197)
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-07: Noisily small result set does not throw r(197) ---"
cap noi wbopendata, search(SP.POP.TOTL) limit(20)
local myrc = _rc
if `myrc' == 197 {
    di as error "FAIL: r(197) — TABLE row SMCL link quoting broken"
    local ++fail
    local failed_list "`failed_list' PAGE-07"
}
else if `myrc' != 0 {
    di as error "FAIL: unexpected r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-07"
}
else {
    di as result "PASS"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-08: page(0) → r(198)
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-08: page(0) returns r(198) ---"
cap noi wbopendata, search(GDP) page(0)
local myrc = _rc
if `myrc' == 198 {
    di as result "PASS"
    local ++pass
}
else {
    di as error "FAIL: Expected r(198) for page(0), got r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-08"
}

*-------------------------------------------------------------------------------
* PAGE-09: page(-1) → r(198)
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-09: page(-1) returns r(198) ---"
cap noi wbopendata, search(GDP) page(-1)
local myrc = _rc
if `myrc' == 198 {
    di as result "PASS"
    local ++pass
}
else {
    di as error "FAIL: Expected r(198) for page(-1), got r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-09"
}

*-------------------------------------------------------------------------------
* PAGE-10: Page beyond last → no r(197) crash
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-10: Page beyond last does not crash ---"
cap qui wbopendata, search(GDP) limit(5)
local np     = r(n_pages)
local beyond = `np' + 100
cap noi wbopendata, search(GDP) limit(5) page(`beyond')
local myrc = _rc
if `myrc' == 197 {
    di as error "FAIL: r(197) SMCL error on out-of-range page"
    local ++fail
    local failed_list "`failed_list' PAGE-10"
}
else {
    di as result "PASS  [page `beyond' of `np' returned r(`myrc'), no crash]"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-11: Main command routes page() correctly
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-11: wbopendata, search() page() routes correctly ---"
cap qui wbopendata, search(GDP) limit(5) page(1)
local myrc = _rc
local npg  = r(n_pages)
if `myrc' != 0 {
    di as error "FAIL: r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-11"
}
else if `npg' == . {
    di as error "FAIL: r(n_pages) is missing"
    local ++fail
    local failed_list "`failed_list' PAGE-11"
}
else {
    di as result "PASS  [r(n_pages)=`npg']"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-12: Browse by source with pagination
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-12: Browse by source with pagination ---"
cap qui wbopendata, searchsource(2) limit(5) page(1)
local myrc = _rc
if `myrc' != 0 {
    di as error "FAIL: searchsource(2) limit(5) page(1) returned r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-12"
}
else {
    di as result "PASS  [n_results=`r(n_results)']"
    local ++pass
}

*-------------------------------------------------------------------------------
* PAGE-13: Browse by source SMCL — no r(197)
*-------------------------------------------------------------------------------
di as text _n "--- PAGE-13: Browse by source SMCL renders without r(197) ---"
cap noi wbopendata, searchsource(2) limit(5) page(1)
local myrc = _rc
if `myrc' == 197 {
    di as error "FAIL: r(197) in browse-mode SMCL links"
    local ++fail
    local failed_list "`failed_list' PAGE-13"
}
else if `myrc' != 0 {
    di as error "FAIL: unexpected r(`myrc')"
    local ++fail
    local failed_list "`failed_list' PAGE-13"
}
else {
    di as result "PASS"
    local ++pass
}

*-------------------------------------------------------------------------------
* Summary
*-------------------------------------------------------------------------------
local total = `pass' + `fail' + `skip'
di as text _n "======================================================================"
di as text "PAGINATION TEST SUMMARY"
di as text "======================================================================"
di as text  "Total:   `total'"
di as result "Passed:  `pass'"
if `fail' > 0 {
    di as error "Failed:  `fail'"
    di as error "Tests:   `failed_list'"
}
else {
    di as text "Failed:  0"
}
if `skip' > 0 {
    di as text "Skipped: `skip'"
}
di as text "======================================================================"

log close
if `fail' > 0 exit 1
