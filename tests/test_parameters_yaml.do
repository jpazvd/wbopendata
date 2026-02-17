*******************************************************************************
* Test: _parameters.ado YAML reader
*   Verifies _parameters reads _wbopendata_parameters.yaml correctly
*   and returns identical r() interface
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
di as result "Testing _parameters YAML reader"
di as text "{hline 70}"
di as text ""

local pass = 0
local fail = 0

*===========================================================================
* PART 1: Basic read and return values
*===========================================================================
di as result "=== PART 1: BASIC READ ==="

capture noisily _parameters
local rc = _rc

* Test 1a: Program runs without error
di as text ""
di as text "Test 1a: _parameters runs without error"
if (`rc' == 0) {
	di as result "  PASS"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: rc = `rc'"
	local fail = `fail' + 1
}

* Test 1b: r(total) is numeric and non-empty
di as text "Test 1b: r(total) is numeric and non-empty"
if ("`r(total)'" != "" & "`r(total)'" != ".") {
	di as result "  PASS: " as text "total = `r(total)'"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "total = '`r(total)''"
	local fail = `fail' + 1
}

* Test 1c: r(number_indicators) is numeric
di as text "Test 1c: r(number_indicators) is numeric"
if ("`r(number_indicators)'" != "" & "`r(number_indicators)'" != ".") {
	di as result "  PASS: " as text "number_indicators = `r(number_indicators)'"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "number_indicators = '`r(number_indicators)''"
	local fail = `fail' + 1
}

* Test 1d: r(ctrymetadata) is numeric
di as text "Test 1d: r(ctrymetadata) is numeric"
if ("`r(ctrymetadata)'" != "" & "`r(ctrymetadata)'" != ".") {
	di as result "  PASS: " as text "ctrymetadata = `r(ctrymetadata)'"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "ctrymetadata = '`r(ctrymetadata)''"
	local fail = `fail' + 1
}

*===========================================================================
* PART 2: Timestamp fields
*===========================================================================
di as text ""
di as result "=== PART 2: TIMESTAMPS ==="

_parameters

* Test 2a: dt_update
di as text "Test 2a: r(dt_update) is non-empty"
if ("`r(dt_update)'" != "") {
	di as result "  PASS: " as text "dt_update = '`r(dt_update)''"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "dt_update is empty"
	local fail = `fail' + 1
}

* Test 2b: dt_lastcheck
di as text "Test 2b: r(dt_lastcheck) is non-empty"
if ("`r(dt_lastcheck)'" != "") {
	di as result "  PASS: " as text "dt_lastcheck = '`r(dt_lastcheck)''"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "dt_lastcheck is empty"
	local fail = `fail' + 1
}

* Test 2c: dt_ctryupdate
di as text "Test 2c: r(dt_ctryupdate) is non-empty"
if ("`r(dt_ctryupdate)'" != "") {
	di as result "  PASS: " as text "dt_ctryupdate = '`r(dt_ctryupdate)''"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "dt_ctryupdate is empty"
	local fail = `fail' + 1
}

*===========================================================================
* PART 3: Source return values
*===========================================================================
di as text ""
di as result "=== PART 3: SOURCES ==="

_parameters

* Test 3a: sourcereturn is non-empty
di as text "Test 3a: r(sourcereturn) is non-empty"
if ("`r(sourcereturn)'" != "") {
	di as result "  PASS: " as text "sourcereturn has " as result wordcount("`r(sourcereturn)'") as text " entries"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "sourcereturn is empty"
	local fail = `fail' + 1
}

* Test 3b: sourceid compound-quoted list is non-empty
di as text "Test 3b: r(sourceid) is non-empty"
if (`"`r(sourceid)'"' != "") {
	di as result "  PASS: " as text "sourceid is populated"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "sourceid is empty"
	local fail = `fail' + 1
}

* Test 3c: WDI source (sourceid02) has indicators
di as text "Test 3c: r(sourceid02) for WDI has indicators"
if ("`r(sourceid02)'" != "" & "`r(sourceid02)'" != "0" & "`r(sourceid02)'" != ".") {
	di as result "  PASS: " as text "sourceid02 (WDI) = `r(sourceid02)'"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "sourceid02 = '`r(sourceid02)''"
	local fail = `fail' + 1
}

* Test 3d: sourceid02 is in sourcereturn list
di as text "Test 3d: sourceid02 appears in sourcereturn"
if (strmatch("`r(sourcereturn)'", "*sourceid02*")) {
	di as result "  PASS"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "sourceid02 not found in sourcereturn"
	local fail = `fail' + 1
}

* Test 3e: Iterate sourcereturn — all have non-empty counts
di as text "Test 3e: All sources in sourcereturn have counts"
local src_ok = 1
foreach sname in `r(sourcereturn)' {
	if ("`r(`sname')'" == "") {
		di as error "  Missing count for `sname'"
		local src_ok = 0
	}
}
if (`src_ok') {
	di as result "  PASS: " as text "All source counts present"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "Some source counts missing"
	local fail = `fail' + 1
}

*===========================================================================
* PART 4: Topic return values
*===========================================================================
di as text ""
di as result "=== PART 4: TOPICS ==="

_parameters

* Test 4a: topicreturn is non-empty
di as text "Test 4a: r(topicreturn) is non-empty"
if ("`r(topicreturn)'" != "") {
	di as result "  PASS: " as text "topicreturn has " as result wordcount("`r(topicreturn)'") as text " entries"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "topicreturn is empty"
	local fail = `fail' + 1
}

* Test 4b: topicid compound-quoted list is non-empty
di as text "Test 4b: r(topicid) is non-empty"
if (`"`r(topicid)'"' != "") {
	di as result "  PASS: " as text "topicid is populated"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "topicid is empty"
	local fail = `fail' + 1
}

* Test 4c: Topic 01 (Agriculture) has indicators
di as text "Test 4c: r(topicid01) for Agriculture has indicators"
if ("`r(topicid01)'" != "" & "`r(topicid01)'" != "0" & "`r(topicid01)'" != ".") {
	di as result "  PASS: " as text "topicid01 = `r(topicid01)'"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "topicid01 = '`r(topicid01)''"
	local fail = `fail' + 1
}

* Test 4d: topicidtopicID exists (all topics summary)
di as text "Test 4d: r(topicidtopicID) exists"
if ("`r(topicidtopicID)'" != "" & "`r(topicidtopicID)'" != ".") {
	di as result "  PASS: " as text "topicidtopicID = `r(topicidtopicID)'"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "topicidtopicID = '`r(topicidtopicID)''"
	local fail = `fail' + 1
}

* Test 4e: Iterate topicreturn — all have counts
di as text "Test 4e: All topics in topicreturn have counts"
local top_ok = 1
foreach tname in `r(topicreturn)' {
	if ("`r(`tname')'" == "") {
		di as error "  Missing count for `tname'"
		local top_ok = 0
	}
}
if (`top_ok') {
	di as result "  PASS: " as text "All topic counts present"
	local pass = `pass' + 1
}
else {
	di as error "  FAIL: " as text "Some topic counts missing"
	local fail = `fail' + 1
}

*===========================================================================
* PART 5: Compound-quoted list structure
*===========================================================================
di as text ""
di as result "=== PART 5: COMPOUND-QUOTED LIST STRUCTURE ==="

_parameters

* Test 5a: Source labels extractable (first 2 chars = code)
di as text "Test 5a: Source labels have correct format (NN Name)"
local src_fmt_ok = 1
local src_count = 0
local src_list `"`r(sourceid)'"'
while `"`src_list'"' != "" {
	gettoken item src_list : src_list
	local src_count = `src_count' + 1
	local scode = substr(`"`item'"', 1, 2)
	local sname = strtrim(substr(`"`item'"', 3, .))
	if (`"`sname'"' == "") {
		di as error "  Empty name for code '`scode''"
		local src_fmt_ok = 0
	}
}
if (`src_fmt_ok' & `src_count' > 0) {
	di as result "  PASS: " as text "`src_count' sources with valid format"
	local pass = `pass' + 1
}
else if (`src_count' == 0) {
	di as error "  FAIL: " as text "No source entries found"
	local fail = `fail' + 1
}
else {
	di as error "  FAIL: " as text "Some sources have invalid format"
	local fail = `fail' + 1
}

* Test 5b: Topic labels extractable
di as text "Test 5b: Topic labels have correct format (CODE Name)"
local top_fmt_ok = 1
local top_count = 0
local top_list `"`r(topicid)'"'
while `"`top_list'"' != "" {
	gettoken item top_list : top_list
	local top_count = `top_count' + 1
	local tcode = word(`"`item'"', 1)
	local tname = strtrim(substr(`"`item'"', strlen(`"`tcode'"') + 1, .))
	if (`"`tname'"' == "") {
		di as error "  Empty name for code '`tcode''"
		local top_fmt_ok = 0
	}
}
if (`top_fmt_ok' & `top_count' > 0) {
	di as result "  PASS: " as text "`top_count' topics with valid format"
	local pass = `pass' + 1
}
else if (`top_count' == 0) {
	di as error "  FAIL: " as text "No topic entries found"
	local fail = `fail' + 1
}
else {
	di as error "  FAIL: " as text "Some topics have invalid format"
	local fail = `fail' + 1
}

*===========================================================================
* PART 6: Full return list display
*===========================================================================
di as text ""
di as result "=== PART 6: FULL RETURN LIST ==="

_parameters
return list

*===========================================================================
* Summary
*===========================================================================
di as text ""
di as text "{hline 70}"
di as result "Test Summary"
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
