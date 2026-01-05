* ==============================================================================
* Test all wbopendata_examples
* This script tests each example in wbopendata_examples.ado
* ==============================================================================

clear all
set more off

* Install wbopendata from local repo
net install wbopendata, from("C:/GitHub/myados/wbopendata") replace

di as text _n "=============================================="
di as text "Testing wbopendata_examples"
di as text "=============================================="

* Track results
local passed = 0
local failed = 0
local skipped = 0

* ==============================================================================
* Example 01: Choropleth map (requires spmap and shapefiles)
* ==============================================================================
di as text _n ">>> Testing example01 (Choropleth map)..."

cap which spmap
if _rc != 0 {
    di as result "SKIPPED: spmap not installed"
    local skipped = `skipped' + 1
}
else {
    cap noi wbopendata_examples example01
    if _rc == 0 {
        di as result "PASSED: example01"
        local passed = `passed' + 1
    }
    else {
        di as error "FAILED: example01 (rc=`_rc')"
        local failed = `failed' + 1
    }
}

* ==============================================================================
* Example 02: alorenz (requires alorenz)
* ==============================================================================
di as text _n ">>> Testing example02 (alorenz)..."

cap which alorenz
if _rc != 0 {
    di as result "SKIPPED: alorenz not installed"
    local skipped = `skipped' + 1
}
else {
    cap noi wbopendata_examples example02
    if _rc == 0 {
        di as result "PASSED: example02"
        local passed = `passed' + 1
    }
    else {
        di as error "FAILED: example02 (rc=`_rc')"
        local failed = `failed' + 1
    }
}

* ==============================================================================
* Example 03: MDG analysis
* ==============================================================================
di as text _n ">>> Testing example03 (MDG analysis)..."

cap noi wbopendata_examples example03
if _rc == 0 {
    di as result "PASSED: example03"
    local passed = `passed' + 1
}
else {
    di as error "FAILED: example03 (rc=`_rc')"
    local failed = `failed' + 1
}

* ==============================================================================
* Example 04: Poverty vs GDP scatter (requires linewrap)
* ==============================================================================
di as text _n ">>> Testing example04 (Poverty vs GDP scatter)..."

cap which linewrap
if _rc != 0 {
    di as result "SKIPPED: linewrap not installed"
    local skipped = `skipped' + 1
}
else {
    cap noi wbopendata_examples example04
    if _rc == 0 {
        di as result "PASSED: example04"
        local passed = `passed' + 1
    }
    else {
        di as error "FAILED: example04 (rc=`_rc')"
        local failed = `failed' + 1
    }
}

* ==============================================================================
* Example 05: match option
* ==============================================================================
di as text _n ">>> Testing example05 (match option)..."

cap noi wbopendata_examples example05
if _rc == 0 {
    di as result "PASSED: example05"
    local passed = `passed' + 1
}
else {
    di as error "FAILED: example05 (rc=`_rc')"
    local failed = `failed' + 1
}

* ==============================================================================
* Example geo: Geographic metadata
* ==============================================================================
di as text _n ">>> Testing example_geo (Geographic metadata)..."

cap noi wbopendata_examples example_geo
if _rc == 0 {
    di as result "PASSED: example_geo"
    local passed = `passed' + 1
}
else {
    di as error "FAILED: example_geo (rc=`_rc')"
    local failed = `failed' + 1
}

* ==============================================================================
* Example linewrap: Linewrap for graph titles
* ==============================================================================
di as text _n ">>> Testing example_linewrap..."

cap which linewrap
if _rc != 0 {
    di as result "SKIPPED: linewrap not installed"
    local skipped = `skipped' + 1
}
else {
    cap noi wbopendata_examples example_linewrap
    if _rc == 0 {
        di as result "PASSED: example_linewrap"
        local passed = `passed' + 1
    }
    else {
        di as error "FAILED: example_linewrap (rc=`_rc')"
        local failed = `failed' + 1
    }
}

* ==============================================================================
* Example basic: basic/nobasic options
* ==============================================================================
di as text _n ">>> Testing example_basic..."

cap noi wbopendata_examples example_basic
if _rc == 0 {
    di as result "PASSED: example_basic"
    local passed = `passed' + 1
}
else {
    di as error "FAILED: example_basic (rc=`_rc')"
    local failed = `failed' + 1
}

* ==============================================================================
* Summary
* ==============================================================================
di as text _n "=============================================="
di as text "TEST SUMMARY"
di as text "=============================================="
di as result "PASSED:  `passed'"
di as result "FAILED:  `failed'"
di as result "SKIPPED: `skipped'"
di as text "=============================================="

if `failed' > 0 {
    di as error "Some tests failed!"
    exit 1
}
else {
    di as text "All tests passed (or skipped due to missing dependencies)"
}

exit
