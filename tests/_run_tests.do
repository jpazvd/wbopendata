* Wrapper to run tests with logging
* Use relative paths from the tests directory
local test_dir "`c(pwd)'"
capture log close _test
log using "`test_dir'/_test_results.log", replace text name(_test)

di "=== PARAMETERS YAML TEST ==="
di "Started: `c(current_date)' `c(current_time)'"
di ""

capture noisily do "`test_dir'/test_parameters_yaml.do"
if _rc != 0 {
    di as error "test_parameters_yaml.do FAILED with rc = `=_rc'"
}

di ""
di "=== QA: ENV-05 ==="
di ""

* Set repo path for QA - go up one level from tests directory
local repo_root = subinstr("`test_dir'", "/tests", "", .)
if "`repo_root'" == "`test_dir'" {
    * Windows path
    local repo_root = subinstr("`test_dir'", "\tests", "", .)
}
global wbopendata_repo "`repo_root'"

* Run individual QA tests
local src_path "`repo_root'/src"
adopath ++ "`src_path'/_"
adopath ++ "`src_path'/w"
adopath ++ "`src_path'/y"

* Source the test helpers from run_tests.do
cap program drop run_test
program define run_test
    args test_id description
    global skip_test 0
    di as text _n "--- TEST `test_id': `description' ---"
    global current_test "`test_id'"
    global tests_run = $tests_run + 1
end

cap program drop test_pass
program define test_pass
    if $skip_test == 1 exit
    di as result "PASS"
    global tests_pass = $tests_pass + 1
end

cap program drop test_fail
program define test_fail
    args message
    if $skip_test == 1 exit
    di as error "FAIL: `message'"
    global tests_fail = $tests_fail + 1
    if "$failed_tests" == "" {
        global failed_tests "$current_test"
    }
    else {
        global failed_tests "$failed_tests, $current_test"
    }
end

global tests_run = 0
global tests_pass = 0
global tests_fail = 0
global failed_tests ""
global current_test ""
global skip_test 0
global target_test ""
global verbose 0

* ENV-05: Parameters YAML readable with valid r() values
run_test "ENV-05" "Parameters YAML readable with valid r() values"
if $skip_test == 0 {
    cap noi {
        qui _parameters

        assert "`r(total)'" != ""
        assert "`r(number_indicators)'" != ""
        assert "`r(ctrymetadata)'" != ""

        assert "`r(dt_update)'" != ""
        assert "`r(dt_lastcheck)'" != ""
        assert "`r(dt_ctryupdate)'" != ""

        assert "`r(sourcereturn)'" != ""
        assert `"`r(sourceid)'"' != ""
        assert "`r(sourceid02)'" != ""
        di as text "Sources: " wordcount("`r(sourcereturn)'") " entries, WDI=" r(sourceid02)

        assert "`r(topicreturn)'" != ""
        assert `"`r(topicid)'"' != ""
        assert "`r(topicid01)'" != ""
        di as text "Topics:  " wordcount("`r(topicreturn)'") " entries"

        foreach sname in `r(sourcereturn)' {
            assert "`r(`sname')'" != ""
        }

        foreach tname in `r(topicreturn)' {
            assert "`r(`tname')'" != ""
        }

        di as text "All r() values present and valid"
    }
    if _rc == 0 test_pass
    else test_fail "Parameters YAML read failed or returned incomplete values"
}

* DISC-01: Basic keyword search
run_test "DISC-01" "Search basic keyword"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_search GDP, limit(5)

        assert `r(n_results)' > 0
        assert `r(n_displayed)' > 0
        assert `r(n_displayed)' <= 5
        assert "`r(first_code)'" != ""
        assert "`r(keyword)'" == "GDP"

        di as text "Found `r(n_results)' results, displayed `r(n_displayed)', first=`r(first_code)'"
    }
    if _rc == 0 test_pass
    else test_fail "Basic keyword search failed"
}

* DISC-02: Search filters
run_test "DISC-02" "Search filters"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_search GDP
        local n_all = r(n_results)

        qui _wbopendata_search GDP, source(2)
        local n_src = r(n_results)
        assert `n_src' > 0
        assert `n_src' <= `n_all'
        assert "`r(source_filter)'" == "2"

        qui _wbopendata_search poverty, topic(11)
        local n_top = r(n_results)
        assert `n_top' > 0
        assert "`r(topic_filter)'" == "11"

        qui _wbopendata_search GDP, field(code)
        local n_fld = r(n_results)
        assert `n_fld' > 0
        assert `n_fld' <= `n_all'
        assert "`r(field_filter)'" == "code"

        di as text "All=`n_all', source(2)=`n_src', topic(11)=`n_top', field(code)=`n_fld'"
    }
    if _rc == 0 test_pass
    else test_fail "Search filters not working correctly"
}

* DISC-03: Search patterns
run_test "DISC-03" "Search patterns"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_search NY.GDP.*
        local n_wild = r(n_results)
        assert `n_wild' > 0

        qui _wbopendata_search learning+poverty
        local n_and = r(n_results)
        assert `n_and' >= 0

        qui _wbopendata_search NY.GDP.MKTP.CD, exact
        local n_exact = r(n_results)
        assert `n_exact' == 1
        assert "`r(first_code)'" == "NY.GDP.MKTP.CD"

        di as text "Wildcard=`n_wild', AND=`n_and', Exact=`n_exact' (`r(first_code)')"
    }
    if _rc == 0 test_pass
    else test_fail "Search patterns not working correctly"
}

* DISC-04: Sources listing
run_test "DISC-04" "Sources listing"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_sources

        assert `r(n_sources)' > 0
        assert `r(n_indicators)' > 0
        assert "`r(source_codes)'" != ""

        di as text "Found `r(n_sources)' sources, `r(n_indicators)' total indicators"
    }
    if _rc == 0 test_pass
    else test_fail "Sources listing failed"
}

* DISC-05: Topics listing
run_test "DISC-05" "Topics listing"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_topics

        assert `r(n_topics)' > 0
        assert "`r(topic_ids)'" != ""
        assert `"`r(topic_names)'"' != ""

        di as text "Found `r(n_topics)' topics"
    }
    if _rc == 0 test_pass
    else test_fail "Topics listing failed"
}

* DISC-06: Indicator info lookup
run_test "DISC-06" "Indicator info lookup"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_info, indicator(SP.POP.TOTL)

        assert "`r(indicator)'" == "SP.POP.TOTL"
        assert "`r(name)'" != ""
        assert "`r(source_id)'" != ""

        di as text "Indicator: `r(indicator)'"
        di as text "Name: `r(name)'"
        di as text "Source ID: `r(source_id)'"
    }
    if _rc == 0 test_pass
    else test_fail "Indicator info lookup failed"
}

* DISC-07: Search router cache_method
run_test "DISC-07" "Search router cache_method"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_search GDP, limit(1)
        local method = "`r(cache_method)'"

        if (`c(stata_version)' >= 16) {
            assert "`method'" == "frames"
            di as text "Stata `c(stata_version)' >= 16: cache_method='`method'' (frames) - correct"
        }
        else {
            assert "`method'" == "none"
            di as text "Stata `c(stata_version)' < 16: cache_method='`method'' (none) - correct"
        }
    }
    if _rc == 0 test_pass
    else test_fail "Search router cache_method incorrect"
}

* Summary
di as text _n "{hline 70}"
di as result "QA SUMMARY"
di as text "{hline 70}"
di as text "Tests Run:    " as result $tests_run
di as text "Tests Passed: " as result $tests_pass
di as text "Tests Failed: " as error $tests_fail
if $tests_fail == 0 {
    di as result _n "ALL QA TESTS PASSED!"
}
else {
    di as error _n "FAILED: $failed_tests"
}
di as text "{hline 70}"

di ""
di "Finished: `c(current_date)' `c(current_time)'"

log close _test
exit
