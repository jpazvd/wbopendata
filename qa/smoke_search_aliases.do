*******************************************************************************
* Smoke test for v18.7.0 alias-helper refactor
* Verifies __wbod_search_aliases populates expected locals in caller scope.
*******************************************************************************

clear all
set more off

* Make sure the dev copy is the one loaded
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/_"
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/w"

local pass 0
local fail 0
local checks ""

*-------------------------------------------------------------------------------
* TEST 1: Helper loads and populates known locals
*-------------------------------------------------------------------------------
program drop _all
__wbod_search_aliases

if ("`src_alias_2'" == "WDI") {
    local pass = `pass' + 1
    di as result "PASS: src_alias_2 == WDI"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: src_alias_2 expected 'WDI', got '`src_alias_2''"
}

if ("`src_alias_46'" == "SDGs") {
    local pass = `pass' + 1
    di as result "PASS: src_alias_46 == SDGs"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: src_alias_46 expected 'SDGs', got '`src_alias_46''"
}

if ("`src_alias_93'" == "FPNA") {
    local pass = `pass' + 1
    di as result "PASS: src_alias_93 == FPNA (last entry)"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: src_alias_93 expected 'FPNA', got '`src_alias_93''"
}

if ("`src_name_2'" == "World Development Indicators") {
    local pass = `pass' + 1
    di as result "PASS: src_name_2 == World Development Indicators"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: src_name_2 expected 'World Development Indicators', got '`src_name_2''"
}

if ("`topic_name_3'" == "Economy & Growth") {
    local pass = `pass' + 1
    di as result "PASS: topic_name_3 == Economy & Growth"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: topic_name_3 expected 'Economy & Growth', got '`topic_name_3''"
}

if ("`topic_name_21'" == "Trade") {
    local pass = `pass' + 1
    di as result "PASS: topic_name_21 == Trade (last topic)"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: topic_name_21 expected 'Trade', got '`topic_name_21''"
}

*-------------------------------------------------------------------------------
* TEST 2: Calling helper twice returns the same values (idempotent)
*-------------------------------------------------------------------------------
local first_check "`src_alias_28'"
__wbod_search_aliases
if ("`src_alias_28'" == "Findex" & "`first_check'" == "Findex") {
    local pass = `pass' + 1
    di as result "PASS: helper is idempotent (src_alias_28 == Findex on both calls)"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: helper not idempotent — first='`first_check'' second='`src_alias_28''"
}

*-------------------------------------------------------------------------------
* TEST 3: Search command end-to-end (uses the helper internally)
*-------------------------------------------------------------------------------
cap noi {
    qui wbopendata, search(GDP) limit(5)
}
if (_rc == 0) {
    local pass = `pass' + 1
    di as result "PASS: wbopendata, search(GDP) limit(5) ran without error"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: search(GDP) returned r(`=_rc')"
}

cap noi {
    qui wbopendata, search() searchsource(46) limit(5)
}
if (_rc == 0) {
    local pass = `pass' + 1
    di as result "PASS: searchsource(46) [SDGs] ran without error"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: searchsource(46) returned r(`=_rc')"
}

cap noi {
    qui wbopendata, search() searchtopic(3) limit(5)
}
if (_rc == 0) {
    local pass = `pass' + 1
    di as result "PASS: searchtopic(3) [Economy & Growth] ran without error"
}
else {
    local fail = `fail' + 1
    di as error "FAIL: searchtopic(3) returned r(`=_rc')"
}

*-------------------------------------------------------------------------------
* SUMMARY
*-------------------------------------------------------------------------------
di _n "================================================================"
di as text "Smoke tests passed: " as result `pass'
di as text "Smoke tests failed: " as error `fail'
if (`fail' == 0) {
    di as result _n "ALL SMOKE TESTS PASSED"
}
else {
    di as error _n "SOME SMOKE TESTS FAILED"
    exit `fail'
}
di "================================================================"
