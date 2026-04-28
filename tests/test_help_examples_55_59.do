*******************************************************************************
* Focused test: HELP-55..HELP-59 (closes coverage gaps from sthlp audit)
* Validates v18.5 pagination + v18.2 cachedays/verbose + allsources
*******************************************************************************

clear all
set more off
capture log close _all

local logname "C:/GitHub/myados/wbopendata-dev/tests/test_help_55_59.log"
log using "`logname'", replace text name(helptest5559)

* Add dev source to FRONT of adopath
local src_path "C:/GitHub/myados/wbopendata-dev/src"
adopath ++ "`src_path'/y"
adopath ++ "`src_path'/_"
adopath ++ "`src_path'/w"

discard
which wbopendata

di as result _n _dup(78) "="
di as result "FOCUSED TEST: HELP-55..HELP-59"
di as result _dup(78) "="

* Counters
local pass 0
local fail 0
local failed_list ""

*-------------------------------------------------------------------------------
* Local helpers (programs would have their own scope, locals work in caller)
*-------------------------------------------------------------------------------
local sep "{hline 70}"

*-------------------------------------------------------------------------------
* HELP-55: searchtopic(11) limit(20) page(2) (v18.5 pagination)
*-------------------------------------------------------------------------------
di as text _n "`sep'"
di as text "HELP-55: searchtopic(11) limit(20) page(2)"
di as text "`sep'"

cap noi {
    qui wbopendata, searchtopic(11) limit(20) page(2)
    assert r(n_results) > 0
    assert r(page) == 2
    di as text "  PASS — page " r(page) " of " r(n_pages) ", " r(n_results) " total results"
}
if _rc == 0 {
    local pass = `pass' + 1
}
else {
    local fail = `fail' + 1
    local failed_list "`failed_list', HELP-55"
    di as error "  FAIL — rc=`=_rc'"
}

*-------------------------------------------------------------------------------
* HELP-56: search(poverty) limit(10) page(3) (v18.5 pagination)
*-------------------------------------------------------------------------------
di as text _n "`sep'"
di as text "HELP-56: search(poverty) limit(10) page(3)"
di as text "`sep'"

cap noi {
    qui wbopendata, search(poverty) limit(10) page(3)
    assert r(n_results) > 0
    assert r(page) == 3
    di as text "  PASS — page " r(page) " of " r(n_pages) ", " r(n_results) " total"
}
if _rc == 0 {
    local pass = `pass' + 1
}
else {
    local fail = `fail' + 1
    local failed_list "`failed_list', HELP-56"
    di as error "  FAIL — rc=`=_rc'"
}

*-------------------------------------------------------------------------------
* HELP-57: cachedays(30) override (v18.2)
*-------------------------------------------------------------------------------
di as text _n "`sep'"
di as text "HELP-57: indicator() clear cachedays(30)"
di as text "`sep'"

cap noi {
    wbopendata, indicator(SP.POP.TOTL) clear cachedays(30)
    assert _N > 0
    di as text "  PASS — " _N " obs"
}
if _rc == 0 {
    local pass = `pass' + 1
}
else {
    local fail = `fail' + 1
    local failed_list "`failed_list', HELP-57"
    di as error "  FAIL — rc=`=_rc'"
}

*-------------------------------------------------------------------------------
* HELP-58: verbose passthrough (v18.2)
*-------------------------------------------------------------------------------
di as text _n "`sep'"
di as text "HELP-58: indicator() clear verbose"
di as text "`sep'"

cap noi {
    wbopendata, indicator(SP.POP.TOTL) clear verbose
    assert _N > 0
    di as text "  PASS — " _N " obs"
}
if _rc == 0 {
    local pass = `pass' + 1
}
else {
    local fail = `fail' + 1
    local failed_list "`failed_list', HELP-58"
    di as error "  FAIL — rc=`=_rc'"
}

*-------------------------------------------------------------------------------
* HELP-59: allsources discovery
*-------------------------------------------------------------------------------
di as text _n "`sep'"
di as text "HELP-59: allsources"
di as text "`sep'"

cap noi {
    qui wbopendata, allsources
    assert r(n_sources) > 0
    di as text "  PASS — " r(n_sources) " sources"
}
if _rc == 0 {
    local pass = `pass' + 1
}
else {
    local fail = `fail' + 1
    local failed_list "`failed_list', HELP-59"
    di as error "  FAIL — rc=`=_rc'"
}

*-------------------------------------------------------------------------------
* Summary
*-------------------------------------------------------------------------------
di _n "`sep'"
di as text "Tests passed: " as result `pass'
di as text "Tests failed: " as error `fail'
if (`fail' == 0) {
    di as result _n "ALL HELP-55..HELP-59 PASSED"
}
else {
    di as error _n "FAILED: `failed_list'"
    log close helptest5559
    exit `fail'
}
di "`sep'"

log close helptest5559
