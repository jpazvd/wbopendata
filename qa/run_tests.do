/*******************************************************************************
* wbopendata Automated Test Suite
* Version: 17.1
* Date: December 2025
* 
* Usage: do run_tests.do
* 
* This script runs through core functionality tests and reports results.
*******************************************************************************/

clear all
set more off
cap log close _all

* Test configuration
local version "17.1"
local date = c(current_date)
local time = c(current_time)

* Start log
log using "test_results_`=subinstr("`date'"," ","",.)'.log", replace text

di as text _n "=" * 70
di as text "WBOPENDATA TEST SUITE"
di as text "Version: `version'"
di as text "Date: `date' `time'"
di as text "Stata: `c(stata_version)'"
di as text "=" * 70

* Initialize counters
local tests_run = 0
local tests_pass = 0
local tests_fail = 0

* Test macro
cap program drop run_test
program define run_test
    args test_id description
    
    di as text _n "--- TEST `test_id': `description' ---"
    
    * Increment counter (via global since locals don't persist)
    global tests_run = $tests_run + 1
end

cap program drop test_pass
program define test_pass
    di as result "PASS"
    global tests_pass = $tests_pass + 1
end

cap program drop test_fail
program define test_fail
    args message
    di as error "FAIL: `message'"
    global tests_fail = $tests_fail + 1
end

* Initialize globals
global tests_run = 0
global tests_pass = 0
global tests_fail = 0

*===============================================================================
* TEST CATEGORY 1: Basic Downloads
*===============================================================================

di as text _n "=" * 70
di as text "CATEGORY 1: Basic Downloads"
di as text "=" * 70

* DL-01: Single indicator
run_test "DL-01" "Single indicator download"
cap {
    wbopendata, indicator(SP.POP.TOTL) clear nometadata
    assert _N > 200
    assert countrycode != ""
}
if _rc == 0 test_pass
else test_fail "Failed to download single indicator"

* DL-02: Specific country
run_test "DL-02" "Single country download"
cap {
    wbopendata, indicator(SP.POP.TOTL) country(USA) clear nometadata
    assert _N == 1
    assert countrycode == "USA"
}
if _rc == 0 test_pass
else test_fail "Failed to download for single country"

* DL-03: Multiple countries
run_test "DL-03" "Multiple countries download"
cap {
    wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear nometadata
    assert _N == 3
}
if _rc == 0 test_pass
else test_fail "Failed to download for multiple countries"

* DL-04: Multiple indicators
run_test "DL-04" "Multiple indicators download"
cap {
    wbopendata, indicator(SP.POP.TOTL;NY.GDP.MKTP.CD) clear long nometadata
    levelsof indicatorcode, local(inds)
    assert wordcount(`"`inds'"') >= 2
}
if _rc == 0 test_pass
else test_fail "Failed to download multiple indicators"

*===============================================================================
* TEST CATEGORY 2: Format Options
*===============================================================================

di as text _n "=" * 70
di as text "CATEGORY 2: Format Options"
di as text "=" * 70

* FMT-01: Long format
run_test "FMT-01" "Long format"
cap {
    wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nometadata
    assert year != .
    assert _N > 50
}
if _rc == 0 test_pass
else test_fail "Long format not working"

* FMT-02: Year range
run_test "FMT-02" "Year range filter"
cap {
    wbopendata, indicator(SP.POP.TOTL) country(USA) year(2010:2020) clear long nometadata
    sum year
    assert r(min) >= 2010
    assert r(max) <= 2020
}
if _rc == 0 test_pass
else test_fail "Year range not working"

* FMT-03: Latest option
run_test "FMT-03" "Latest option"
cap {
    wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear long latest nometadata
    bysort countrycode: assert _N == 1
}
if _rc == 0 test_pass
else test_fail "Latest option not working"

*===============================================================================
* TEST CATEGORY 3: Country Metadata
*===============================================================================

di as text _n "=" * 70
di as text "CATEGORY 3: Country Metadata"
di as text "=" * 70

* CTRY-01: Match basic
run_test "CTRY-01" "Match basic"
cap {
    clear
    input str3 countrycode
    "USA"
    "BRA"
    "CHN"
    end
    wbopendata, match(countrycode)
    assert regionname != ""
}
if _rc == 0 test_pass
else test_fail "Match basic not working"

* CTRY-02: Match with full
run_test "CTRY-02" "Match with full option"
cap {
    clear
    input str3 countrycode
    "USA"
    "BRA"
    end
    wbopendata, match(countrycode) full
    cap confirm variable longitude
    assert _rc == 0
}
if _rc == 0 test_pass
else test_fail "Match full not working"

*===============================================================================
* TEST CATEGORY 4: Regression Tests (Fixed Issues)
*===============================================================================

di as text _n "=" * 70
di as text "CATEGORY 4: Regression Tests"
di as text "=" * 70

* REG-33: Latest with long indicator names
run_test "REG-33" "Issue #33: Latest with long names"
cap {
    wbopendata, indicator(DT.DOD.DECT.CD) clear long latest nometadata
}
if _rc == 0 test_pass
else test_fail "Issue #33 regression"

* REG-45: URL in metadata
run_test "REG-45" "Issue #45: URL in metadata"
cap {
    wbopendata, indicator(SL.UEM.TOTL.ZS) clear
}
if _rc == 0 test_pass
else test_fail "Issue #45 regression"

* REG-46: Varlist not allowed (update)
run_test "REG-46" "Issue #46: Update without varlist error"
cap {
    clear
    wbopendata, update query
}
if _rc == 0 test_pass
else test_fail "Issue #46 regression"

* REG-51: Match incompatibility
run_test "REG-51" "Issue #51: Match+indicator incompatibility check"
cap {
    clear
    input str3 countrycode
    "USA"
    end
    cap wbopendata, indicator(SP.POP.TOTL) match(countrycode) clear
    * Should error - we expect _rc != 0
    if _rc != 0 exit 0
    else exit 1
}
if _rc == 0 test_pass
else test_fail "Issue #51 regression - should have errored"

*===============================================================================
* TEST SUMMARY
*===============================================================================

di as text _n "=" * 70
di as text "TEST SUMMARY"
di as text "=" * 70

di as text "Tests Run:    " as result $tests_run
di as text "Tests Passed: " as result $tests_pass
di as text "Tests Failed: " as error $tests_fail

if $tests_fail == 0 {
    di as result _n "ALL TESTS PASSED!"
}
else {
    di as error _n "SOME TESTS FAILED - Review log for details"
}

di as text "=" * 70

log close
di as text "Log saved to: test_results_`=subinstr("`date'"," ","",.)'.log"
