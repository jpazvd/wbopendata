*******************************************************************************
* Test Protocol: Discovery Commands (v17.8.0)
* Run from: C:\GitHub\myados\wbopendata-dev\src
* Date: 04Feb2026
*******************************************************************************

clear all
set more off
capture log close
log using "test_discovery_results.log", replace text

di as result _n "{hline 78}"
di as result "WBOPENDATA DISCOVERY COMMANDS TEST PROTOCOL"
di as result "{hline 78}"
di as text "Date: " c(current_date) " " c(current_time)
di as text "Stata version: " c(stata_version)
di as text "Working directory: " c(pwd)

* Verify we're using the dev version
which wbopendata
di _n

*******************************************************************************
* TEST 1: SOURCES COMMAND
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 1: wbopendata, sources"
di as result "{hline 78}"

* 1.1 Basic sources command
di as text _n "1.1 Basic sources list:"
wbopendata, sources

* 1.2 Check return values
di as text _n "1.2 Return values:"
return list
assert r(n_sources) > 0
di as result "PASS: r(n_sources) = " r(n_sources)

* 1.3 Limit option
di as text _n "1.3 With limit(5):"
wbopendata, sources limit(5)

*******************************************************************************
* TEST 2: TOPICS COMMAND
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 2: wbopendata, alltopics"
di as result "{hline 78}"

* 2.1 Basic topics command
di as text _n "2.1 Basic topics list:"
wbopendata, alltopics

* 2.2 Check return values
di as text _n "2.2 Return values:"
return list
assert r(n_topics) == 21
di as result "PASS: r(n_topics) = " r(n_topics)

*******************************************************************************
* TEST 3: SEARCH COMMAND - BASIC
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 3: wbopendata, search() - Basic"
di as result "{hline 78}"

* 3.1 Simple keyword search
di as text _n "3.1 Search for 'GDP':"
wbopendata, search(GDP)
return list
assert r(n_results) > 0
di as result "PASS: Found " r(n_results) " results for 'GDP'"

* 3.2 Search with limit
di as text _n "3.2 Search with limit(5):"
wbopendata, search(GDP) limit(5)
assert r(n_displayed) == 5
di as result "PASS: Displayed exactly 5 results"

* 3.3 Search for less common term
di as text _n "3.3 Search for 'malnutrition':"
wbopendata, search(malnutrition) limit(10)
return list

*******************************************************************************
* TEST 4: SEARCH COMMAND - FILTERS
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 4: wbopendata, search() - Filters"
di as result "{hline 78}"

* 4.1 Filter by source
di as text _n "4.1 Search 'health' in source 2 (WDI):"
wbopendata, search(health) searchsource(2) limit(10)
return list
di as result "Found " r(n_results) " results in source 2"

* 4.2 Filter by topic
di as text _n "4.2 Search 'education' in topic 4 (Education):"
wbopendata, search(education) searchtopic(4) limit(10)
return list
di as result "Found " r(n_results) " results in topic 4"

* 4.3 Browse all indicators from a source (empty search)
di as text _n "4.3 Browse all from source 2 (WDI):"
wbopendata, search() searchsource(2) limit(10)
return list
di as result "Source 2 has " r(n_results) " indicators"

* 4.4 Browse all indicators from a topic (empty search)
di as text _n "4.4 Browse all from topic 11 (Poverty):"
wbopendata, search() searchtopic(11) limit(10)
return list
di as result "Topic 11 has " r(n_results) " indicators"

*******************************************************************************
* TEST 5: SEARCH COMMAND - FIELD OPTION
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 5: wbopendata, search() - Field Option"
di as result "{hline 78}"

* 5.1 Search in code only
di as text _n "5.1 Search 'NY.GDP' in code field only:"
wbopendata, search(NY.GDP) searchfield(code) limit(10)
return list
di as result "Found " r(n_results) " indicators with 'NY.GDP' in code"

* 5.2 Search in name only
di as text _n "5.2 Search 'per capita' in name field only:"
wbopendata, search(per capita) searchfield(name) limit(10)
return list

* 5.3 Search in multiple fields
di as text _n "5.3 Search 'poverty' in code and name:"
wbopendata, search(poverty) searchfield(code;name) limit(10)
return list

*******************************************************************************
* TEST 6: SEARCH COMMAND - WILDCARDS
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 6: wbopendata, search() - Wildcards"
di as result "{hline 78}"

* 6.1 Asterisk wildcard
di as text _n "6.1 Wildcard search 'NY.GDP.*':"
wbopendata, search(NY.GDP.*) searchfield(code) limit(20)
return list
di as result "Found " r(n_results) " indicators matching NY.GDP.*"

* 6.2 Asterisk at beginning
di as text _n "6.2 Wildcard search '*.CD' (current dollars):"
wbopendata, search(*.CD) searchfield(code) limit(10)
return list

* 6.3 Question mark wildcard
di as text _n "6.3 Wildcard search 'SP.POP.????.IN':"
wbopendata, search(SP.POP.????.IN) searchfield(code) limit(10)
return list

* 6.4 Exact match
di as text _n "6.4 Exact match for 'NY.GDP.MKTP.CD':"
wbopendata, search(NY.GDP.MKTP.CD) exact limit(5)
return list
assert r(n_results) == 1
di as result "PASS: Exact match found 1 result"

*******************************************************************************
* TEST 7: INFO COMMAND
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 7: wbopendata, info()"
di as result "{hline 78}"

* 7.1 Basic info
di as text _n "7.1 Info for NY.GDP.MKTP.CD:"
wbopendata, info(NY.GDP.MKTP.CD)
return list
assert "`r(indicator)'" == "NY.GDP.MKTP.CD"
di as result "PASS: Indicator info retrieved"

* 7.2 Another indicator
di as text _n "7.2 Info for SP.POP.TOTL:"
wbopendata, info(SP.POP.TOTL)
return list

* 7.3 Case insensitive
di as text _n "7.3 Case insensitive (ny.gdp.mktp.cd):"
wbopendata, info(ny.gdp.mktp.cd)
return list

*******************************************************************************
* TEST 8: ERROR HANDLING
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 8: Error Handling"
di as result "{hline 78}"

* 8.1 Search with no results
di as text _n "8.1 Search for non-existent term:"
wbopendata, search(xyznonexistent123)
return list
assert r(n_results) == 0
di as result "PASS: No results found (expected)"

* 8.2 Invalid indicator code
di as text _n "8.2 Info for non-existent indicator:"
capture noisily wbopendata, info(INVALID.CODE.XYZ)
assert _rc == 111
di as result "PASS: Error 111 returned for invalid indicator"

* 8.3 Empty search without filters
di as text _n "8.3 Empty search without filters (should error):"
capture noisily wbopendata, search()
assert _rc == 198
di as result "PASS: Error 198 returned for empty search"

*******************************************************************************
* TEST 9: RETURN VALUES (rclass)
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 9: Return Values (rclass)"
di as result "{hline 78}"

* 9.1 Sources return values
di as text _n "9.1 Sources rclass:"
wbopendata, sources limit(5)
di "r(n_sources) = " r(n_sources)
di "r(n_available) = " r(n_available)
di "r(n_indicators) = " r(n_indicators)
di "r(source_codes) = " r(source_codes)
di "r(cmd) = " r(cmd)

* 9.2 Topics return values
di as text _n "9.2 Topics rclass:"
wbopendata, alltopics limit(5)
di "r(n_topics) = " r(n_topics)
di "r(topic_ids) = " r(topic_ids)
di "r(cmd) = " r(cmd)

* 9.3 Search return values
di as text _n "9.3 Search rclass:"
wbopendata, search(GDP) limit(5)
di "r(n_results) = " r(n_results)
di "r(n_displayed) = " r(n_displayed)
di "r(first_code) = " r(first_code)
di "r(keyword) = " r(keyword)
di "r(cmd) = " r(cmd)

* 9.4 Info return values
di as text _n "9.4 Info rclass:"
wbopendata, info(NY.GDP.MKTP.CD)
di "r(indicator) = " r(indicator)
di "r(name) = " r(name)
di "r(source_id) = " r(source_id)
di "r(topics) = " r(topics)
di "r(cmd) = " r(cmd)

*******************************************************************************
* TEST 10: INTEGRATION - CHAINED COMMANDS
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST 10: Integration - Chained Commands"
di as result "{hline 78}"

* 10.1 Search, get first result, then info
di as text _n "10.1 Search -> Info chain:"
wbopendata, search(life expectancy) limit(1)
local first_code = r(first_code)
di "First result: `first_code'"
wbopendata, info(`first_code')

* 10.2 Search -> Download
di as text _n "10.2 Search -> Download chain:"
wbopendata, search(population total) searchfield(name) limit(1)
local ind = r(first_code)
di "Downloading: `ind'"
wbopendata, indicator(`ind') country(BRA;USA) clear long
desc
list in 1/5

*******************************************************************************
* SUMMARY
*******************************************************************************
di as result _n "{hline 78}"
di as result "TEST SUMMARY"
di as result "{hline 78}"
di as text "All tests completed. Review log for any failures."
di as text "Log file: test_discovery_results.log"

log close
