*******************************************************************************
* Test: Modular search architecture
*   _wbopendata_search     (wrapper/router)
*   __wbopendata_search    (standard, no caching)
*   __wbopendata_search_cache (frame-based caching, Stata 16+)
* Run in Stata 16+ to test caching; works in Stata 14+ without cache
*******************************************************************************

clear all
set more off

* Set paths - adjust if needed
local src_path "C:/GitHub/myados/wbopendata-dev/src"
adopath ++ "`src_path'/_"
adopath ++ "`src_path'/w"
adopath ++ "`src_path'/y"

di as text ""
di as text "{hline 70}"
di as result "Testing wbopendata modular search architecture"
di as text "{hline 70}"
di as text "Stata version: " as result "`c(stata_version)'"
di as text "Expected route: " as result cond(`c(stata_version)' >= 16, "__wbopendata_search_cache", "__wbopendata_search")
di as text "{hline 70}"

*===========================================================================
* PART 1: Timing comparison - standard vs cached
*===========================================================================
di as text ""
di as result "=== PART 1: TIMING COMPARISON ==="

* Clear any existing cache
capture _wbopendata_cache_clear, all

*---------------------------------------------------------------------------
* Test 1a: __wbopendata_search (standard, no cache)
*---------------------------------------------------------------------------
di as text ""
di as result "Test 1a: __wbopendata_search (standard, no cache)"
timer clear 1
timer on 1
quietly __wbopendata_search GDP, limit(5)
timer off 1
local std_n1 = r(n_results)
local std_method = r(cache_method)
quietly timer list 1
local std_time1 = r(t1)
di as text "  Results: `std_n1' matches, Time: " %6.3f `std_time1' " sec, Method: `std_method'"

*---------------------------------------------------------------------------
* Test 1b: __wbopendata_search_cache first call (builds cache)
*---------------------------------------------------------------------------
if (`c(stata_version)' >= 16) {
    di as text ""
    di as result "Test 1b: __wbopendata_search_cache first call (builds cache)"
    capture _wbopendata_cache_clear, all
    timer clear 2
    timer on 2
    quietly __wbopendata_search_cache GDP, limit(5)
    timer off 2
    local cache_n1 = r(n_results)
    local cache_method1 = r(cache_method)
    quietly timer list 2
    local cache_time1 = r(t2)
    di as text "  Results: `cache_n1' matches, Time: " %6.3f `cache_time1' " sec, Method: `cache_method1'"

    *---------------------------------------------------------------------------
    * Test 1c: __wbopendata_search_cache second call (uses cache)
    *---------------------------------------------------------------------------
    di as text ""
    di as result "Test 1c: __wbopendata_search_cache second call (uses cache)"
    timer clear 3
    timer on 3
    quietly __wbopendata_search_cache GDP, limit(5)
    timer off 3
    local cache_n2 = r(n_results)
    quietly timer list 3
    local cache_time2 = r(t3)
    di as text "  Results: `cache_n2' matches, Time: " %6.3f `cache_time2' " sec (from cache)"

    *---------------------------------------------------------------------------
    * Test 1d: __wbopendata_search_cache different keyword (uses cache)
    *---------------------------------------------------------------------------
    di as text ""
    di as result "Test 1d: __wbopendata_search_cache different keyword (uses cache)"
    timer clear 4
    timer on 4
    quietly __wbopendata_search_cache poverty, limit(5)
    timer off 4
    local cache_n3 = r(n_results)
    quietly timer list 4
    local cache_time3 = r(t4)
    di as text "  Results: `cache_n3' matches, Time: " %6.3f `cache_time3' " sec (from cache)"

    *---------------------------------------------------------------------------
    * Timing Summary
    *---------------------------------------------------------------------------
    di as text ""
    di as text "{hline 70}"
    di as result "Timing Summary:"
    di as text "{hline 70}"
    di as text "Standard (no cache): " %6.3f `std_time1' " sec"
    di as text "Cached (first call): " %6.3f `cache_time1' " sec (builds cache)"
    di as text "Cached (2nd call):   " %6.3f `cache_time2' " sec (from cache)"
    di as text "Cached (diff kw):    " %6.3f `cache_time3' " sec (from cache)"
    if (`cache_time2' > 0) {
        local speedup = `std_time1' / `cache_time2'
        di as result "Speedup (cached):    " %6.1f `speedup' "x faster"
    }
    di as text "{hline 70}"
}
else {
    di as text ""
    di as text "(Skipping cache tests - Stata < 16)"
}

*===========================================================================
* PART 2: Feature parity tests (standard vs wrapper)
*===========================================================================
di as text ""
di as result "=== PART 2: FEATURE PARITY TESTS ==="
di as text "(Comparing __wbopendata_search vs _wbopendata_search wrapper)"

local pass = 0
local fail = 0

*---------------------------------------------------------------------------
* Test 2a: Result count match
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2a: Result count match (GDP search)"
quietly __wbopendata_search GDP
local std_gdp = r(n_results)
quietly _wbopendata_search GDP
local wrap_gdp = r(n_results)

if (`std_gdp' == `wrap_gdp') {
    di as result "  PASS: " as text "Both found `std_gdp' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_gdp', wrapper=`wrap_gdp'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2b: Source filter
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2b: Source filter (source=2, WDI)"
quietly __wbopendata_search GDP, source(2)
local std_src = r(n_results)
quietly _wbopendata_search GDP, source(2)
local wrap_src = r(n_results)

if (`std_src' == `wrap_src') {
    di as result "  PASS: " as text "Both found `std_src' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_src', wrapper=`wrap_src'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2c: Topic filter
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2c: Topic filter (topic=11, Poverty)"
quietly __wbopendata_search poverty, topic(11)
local std_top = r(n_results)
quietly _wbopendata_search poverty, topic(11)
local wrap_top = r(n_results)

if (`std_top' == `wrap_top') {
    di as result "  PASS: " as text "Both found `std_top' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_top', wrapper=`wrap_top'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2d: AND search (multi-keyword)
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2d: AND search (learning+poverty)"
quietly __wbopendata_search learning+poverty
local std_and = r(n_results)
quietly _wbopendata_search learning+poverty
local wrap_and = r(n_results)

if (`std_and' == `wrap_and') {
    di as result "  PASS: " as text "Both found `std_and' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_and', wrapper=`wrap_and'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2e: Wildcard search
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2e: Wildcard search (NY.GDP.*)"
quietly __wbopendata_search NY.GDP.*
local std_wild = r(n_results)
quietly _wbopendata_search NY.GDP.*
local wrap_wild = r(n_results)

if (`std_wild' == `wrap_wild') {
    di as result "  PASS: " as text "Both found `std_wild' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_wild', wrapper=`wrap_wild'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2f: Exact match
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2f: Exact match (NY.GDP.MKTP.CD)"
quietly __wbopendata_search NY.GDP.MKTP.CD, exact
local std_exact = r(n_results)
quietly _wbopendata_search NY.GDP.MKTP.CD, exact
local wrap_exact = r(n_results)

if (`std_exact' == `wrap_exact') {
    di as result "  PASS: " as text "Both found `std_exact' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_exact', wrapper=`wrap_exact'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2g: Field filter (code only)
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2g: Field filter (field=code)"
quietly __wbopendata_search GDP, field(code)
local std_field = r(n_results)
quietly _wbopendata_search GDP, field(code)
local wrap_field = r(n_results)

if (`std_field' == `wrap_field') {
    di as result "  PASS: " as text "Both found `std_field' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_field', wrapper=`wrap_field'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2h: First code match
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2h: First code match"
quietly __wbopendata_search GDP, limit(1)
local std_first = r(first_code)
quietly _wbopendata_search GDP, limit(1)
local wrap_first = r(first_code)

if ("`std_first'" == "`wrap_first'") {
    di as result "  PASS: " as text "Both returned `std_first'"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_first', wrapper=`wrap_first'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2i: Browse by source only (no keyword)
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2i: Browse by source only (source=37)"
quietly __wbopendata_search, source(37)
local std_browse = r(n_results)
quietly _wbopendata_search, source(37)
local wrap_browse = r(n_results)

if (`std_browse' == `wrap_browse') {
    di as result "  PASS: " as text "Both found `std_browse' results"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "standard=`std_browse', wrapper=`wrap_browse'"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Test 2j: Wrapper returns cache_method
*---------------------------------------------------------------------------
di as text ""
di as text "Test 2j: Wrapper returns cache_method"
quietly _wbopendata_search GDP
local wrap_method = r(cache_method)
local expected_method = cond(`c(stata_version)' >= 16, "frames", "none")

if ("`wrap_method'" == "`expected_method'") {
    di as result "  PASS: " as text "cache_method = `wrap_method' (expected for Stata `c(stata_version)')"
    local pass = `pass' + 1
}
else {
    di as error "  FAIL: " as text "Expected '`expected_method'', got '`wrap_method''"
    local fail = `fail' + 1
}

*---------------------------------------------------------------------------
* Feature Parity Summary
*---------------------------------------------------------------------------
di as text ""
di as text "{hline 70}"
di as result "Feature Parity Summary:"
di as text "{hline 70}"
local total = `pass' + `fail'
di as text "Passed: " as result "`pass'" as text " / `total'"
if (`fail' > 0) {
    di as error "Failed: `fail'"
}
else {
    di as result "All tests passed!"
}
di as text "{hline 70}"

*===========================================================================
* PART 3: Cache status
*===========================================================================
di as text ""
di as result "=== PART 3: CACHE STATUS ==="
_wbopendata_cache_info

*===========================================================================
* PART 4: Visual output test (via wrapper)
*===========================================================================
di as text ""
di as result "=== PART 4: VISUAL OUTPUT TEST ==="
di as text ""
di as text "Wrapper search with detail option:"
_wbopendata_search GDP, limit(3) detail

di as text ""
di as text "Wrapper search table format:"
_wbopendata_search GDP, limit(5)

*===========================================================================
* Cleanup
*===========================================================================
di as text ""
di as result "=== CLEANUP ==="
_wbopendata_cache_clear, all

di as text ""
di as text "{hline 70}"
di as result "TESTING COMPLETE"
di as text "{hline 70}"
