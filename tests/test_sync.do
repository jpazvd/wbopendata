*******************************************************************************
* test_sync.do - Test _wbopendata_sync Python/Stata fallback
*******************************************************************************

clear all
set more off

* Force reload of all wbopendata programs
capture program drop _wbopendata_sync
capture program drop _wbopendata_run_python
capture program drop _wbopendata_check_python
capture program drop _wbopendata_check_staleness
capture program drop _wbopendata_write_cache_meta
capture program drop _wbopendata_update_sync_history

* Setup adopath
local repo = subinstr("`c(pwd)'", "\", "/", .)
adopath ++ "`repo'/src/w"
adopath ++ "`repo'/src/_"

di _n as txt "======================================================================"
di as txt "Testing _wbopendata_sync functionality"
di as txt "======================================================================"

* Test 1: Check Python availability
di _n as txt "TEST 1: Check if Python is available"
di as txt "----------------------------------------"

capture noisily _wbopendata_check_python
if (_rc == 0) {
    di as res "  Python is AVAILABLE"
}
else {
    di as res "  Python is NOT available (rc=" _rc ")"
}

* Test 2: Test sync with forcepython
di _n as txt "TEST 2: Test sync with forcepython option"
di as txt "----------------------------------------"

local testdir "`c(tmpdir)'/wbopendata_test_sync/"
cap mkdir "`testdir'"

* Debug: show cache_dir resolution
di as txt "  Debug: c(sysdir_personal) = `c(sysdir_personal)'"
di as txt "  Debug: testdir = `testdir'"

capture noisily _wbopendata_sync, forcepython outdir("`testdir'")
if (_rc == 0) {
    di as res "  forcepython: SUCCESS (method = `r(method)')"
}
else {
    di as err "  forcepython: FAILED (rc=" _rc ")"
}

* Test 3: Test sync with forcestata
di _n as txt "TEST 3: Test sync with forcestata option"
di as txt "----------------------------------------"

capture noisily _wbopendata_sync, forcestata outdir("`testdir'")
if (_rc == 0) {
    di as res "  forcestata: SUCCESS (method = `r(method)')"
}
else {
    di as err "  forcestata: FAILED (rc=" _rc ")"
}

* Test 4: Test default sync (should prefer Python)
di _n as txt "TEST 4: Test default sync (Python preferred)"
di as txt "----------------------------------------"

capture noisily _wbopendata_sync, outdir("`testdir'") force
if (_rc == 0) {
    di as res "  default sync: SUCCESS (method = `r(method)')"
}
else {
    di as err "  default sync: FAILED (rc=" _rc ")"
}

di _n as txt "======================================================================"
di as txt "Sync tests completed"
di as txt "======================================================================"
