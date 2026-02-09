*******************************************************************************
* Test: Topic YAML List Parsing Fixes
* Run from: C:\GitHub\myados\wbopendata-dev\src
* Date: 04Feb2026
*******************************************************************************

clear all
set more off

di as result _n "=" * 78
di as result "TESTING TOPIC YAML LIST PARSING FIXES"
di as result "=" * 78
di as text "Date: " c(current_date) " " c(current_time)
di as text "Working directory: " c(pwd)
di _n

* Verify we're using the dev version
which wbopendata
di _n

*******************************************************************************
* TEST 1: TOPICS COMMAND - Indicator Counts
*******************************************************************************
di as result _n "=" * 78
di as result "TEST 1: wbopendata, alltopics - Check indicator counts"
di as result "=" * 78

wbopendata, alltopics

* Check that topics have non-zero indicator counts
return list
di as text _n "Result: n_topics = " r(n_topics)

* If topic counts are all 0, the fix didn't work
di as text _n "Visual inspection: Do topics show indicator counts > 0?"
di as text "If all show 0, the YAML list parsing is still broken."

*******************************************************************************
* TEST 2: SEARCH BY TOPIC - Filter
*******************************************************************************
di as result _n "=" * 78
di as result "TEST 2: wbopendata, search() topic() - Topic filter"
di as result "=" * 78

* Topic 11 is Poverty - should have many indicators
di as text _n "2.1 Browse all from topic 11 (Poverty):"
wbopendata, search() searchtopic(11) limit(10)
return list
local n_topic11 = r(n_results)
di as result "Found " `n_topic11' " indicators in topic 11"

if (`n_topic11' == 0) {
    di as error "FAIL: searchtopic(11) returned 0 results - YAML list parsing broken"
}
else {
    di as result "PASS: searchtopic() is working"
}

* Topic 3 is Economy & Growth
di as text _n "2.2 Browse all from topic 3 (Economy & Growth):"
wbopendata, search() searchtopic(3) limit(10)
return list
di as result "Found " r(n_results) " indicators in topic 3"

* Topic 4 is Education
di as text _n "2.3 Search 'education' in topic 4 (Education):"
wbopendata, search(education) searchtopic(4) limit(10)
return list
di as result "Found " r(n_results) " results for 'education' in topic 4"

*******************************************************************************
* TEST 3: INFO COMMAND - Topic Display
*******************************************************************************
di as result _n "=" * 78
di as result "TEST 3: wbopendata, info() - Topic display"
di as result "=" * 78

di as text _n "3.1 Info for NY.GDP.MKTP.CD:"
wbopendata, info(NY.GDP.MKTP.CD)
return list

di as text _n "3.2 Info for SP.POP.TOTL (Population):"
wbopendata, info(SP.POP.TOTL)
return list

*******************************************************************************
* TEST 4: CROSS-CHECK - Topic counts vs browse results
*******************************************************************************
di as result _n "=" * 78
di as result "TEST 4: Cross-check topic counts"
di as result "=" * 78

* Get topic 11 count from alltopics
wbopendata, alltopics
* Manual visual check needed

di as text _n "Browse topic 11 to compare:"
wbopendata, search() searchtopic(11) limit(1)
di as text "Total in topic 11: " r(n_results)

*******************************************************************************
* SUMMARY
*******************************************************************************
di as result _n "=" * 78
di as result "TEST SUMMARY"
di as result "=" * 78
di as text "Key indicators of success:"
di as text "  1. alltopics shows indicator counts > 0 for most topics"
di as text "  2. searchtopic() returns results (not 0)"
di as text "  3. info() displays topic names correctly"
di as text ""
di as text "If topic counts are still 0, check:"
di as text "  - _wbopendata_topics.ado list parsing logic"
di as text "  - _wbopendata_search.ado topic filter logic"
