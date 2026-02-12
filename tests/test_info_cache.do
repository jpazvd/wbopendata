* test_info_cache.do - Test info() performance and block scalar parsing
* Tests parser v1.0.8 fixes: shared frame cache + block scalar accumulation
* Expected: info() uses cache (~0.1s after first), description shows full text
* Full description should contain: "...irrespective of the time required..."
* Collection should show source_name (e.g., "Millennium Development Goals")
* Note should show source_org when YAML note is empty

clear all
set more off

di _n "{hline 80}"
di as result "TEST: info() cache and block scalar parsing"
di "{hline 80}"

*------------------------------------------------------------------------------
* Test 1: Fresh cache - first call should parse YAML (~26s)
*------------------------------------------------------------------------------
di _n as result "=== Test 1: Fresh cache (drop frame, first call) ==="
capture frame drop _wbod_indicators
timer clear
timer on 1
wbopendata, info(DC.ODA.COMM.CD)
timer off 1
timer list
di as text "Expected: (Caching metadata in memory...) message, ~20-30s"

* Store return values for verification
local desc1 = r(description)
local note1 = r(note)
local src1 = r(source_org)
local time1 = r(t1)

*------------------------------------------------------------------------------
* Test 2: Cached call - should be fast (~0.1s)
*------------------------------------------------------------------------------
di _n as result "=== Test 2: Cached call (same indicator) ==="
timer clear
timer on 2
wbopendata, info(DC.ODA.COMM.CD)
timer off 2
timer list
di as text "Expected: (Using cached metadata from memory) message, <1s"

*------------------------------------------------------------------------------
* Test 3: Cached call - different indicator
*------------------------------------------------------------------------------
di _n as result "=== Test 3: Different indicator (still cached) ==="
timer clear
timer on 3
wbopendata, info(NY.GDP.MKTP.CD)
timer off 3
timer list
di as text "Expected: (Using cached metadata from memory) message, <1s"

*------------------------------------------------------------------------------
* Test 4: Verify block scalar content (NOT showing ">-")
*------------------------------------------------------------------------------
di _n as result "=== Test 4: Block scalar content verification ==="

* Check description is not a YAML marker
local desc_ok = 0
if ("`desc1'" != ">-" & "`desc1'" != ">" & "`desc1'" != "|-" & "`desc1'" != "|") {
    if (strlen("`desc1'") > 10) {
        local desc_ok = 1
    }
}

* Check source_org is not a YAML marker
local src_ok = 0
if ("`src1'" != ">-" & "`src1'" != ">" & "`src1'" != "|-" & "`src1'" != "|") {
    if (strlen("`src1'") > 10) {
        local src_ok = 1
    }
}

di as text "Description (first 80 chars): " as result substr("`desc1'", 1, 80)
if (`desc_ok') {
    di as text "  [PASS] Description contains actual text"
}
else {
    di as error "  [FAIL] Description shows YAML marker or is too short"
}

di as text "Source org (first 80 chars): " as result substr("`src1'", 1, 80)
if (`src_ok') {
    di as text "  [PASS] Source org contains actual text"
}
else {
    di as error "  [FAIL] Source org shows YAML marker or is too short"
}

*------------------------------------------------------------------------------
* Test 5: Search shares the same cache
*------------------------------------------------------------------------------
di _n as result "=== Test 5: Search uses shared cache ==="
timer clear
timer on 5
wbopendata, search(ODA) limit(5)
timer off 5
timer list
di as text "Expected: (Using cached metadata from memory) message, <1s"

*------------------------------------------------------------------------------
* Test 6: Compare with describe (API-based)
*------------------------------------------------------------------------------
di _n as result "=== Test 6: Compare info() vs describe ==="
di as text "Running describe for comparison..."
timer clear
timer on 6
wbopendata, indicator(DC.ODA.COMM.CD) describe
timer off 6
timer list

local desc_api = r(description)
di as text "API description (first 80 chars): " as result substr("`desc_api'", 1, 80)

* Both should have substantial content
if (strlen("`desc1'") > 50 & strlen("`desc_api'") > 50) {
    di as text "  [PASS] Both info() and describe return substantial descriptions"
}
else {
    di as error "  [FAIL] Content length mismatch"
}

*------------------------------------------------------------------------------
* Summary
*------------------------------------------------------------------------------
di _n "{hline 80}"
di as result "TEST SUMMARY"
di "{hline 80}"
di as text "info() first call:  " as result "`time1's"
di as text "info() cached call: " as result "should be <1s"
di as text "Block scalars:      " as result cond(`desc_ok' & `src_ok', "PASS", "FAIL")
di as text "Cache shared:       " as result "search() should show 'Using cached'"
di "{hline 80}"

di _n as text "To verify manually, check that:"
di as text "  1. (Caching metadata...) appears on first call only"
di as text "  2. (Using cached...) appears on subsequent calls"
di as text "  3. Description shows full text, not '>-' or '|-'"
di as text "  4. Source shows organization name, not YAML marker"
