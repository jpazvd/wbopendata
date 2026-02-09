*******************************************************************************
* test_sync_quick.do - Quick test of _wbopendata_sync Python/Stata detection
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
di as txt "Testing _wbopendata_sync Python/Stata detection"
di as txt "======================================================================"

* Test: Default sync with force (Python preferred if available)
di _n as txt "Test: Default sync with force option"
di as txt "      Expected: Python detected -> 'Running Python pipeline...'"
di as txt "----------------------------------------"

local testdir "`c(tmpdir)'/wbopendata_test_sync/"
cap mkdir "`testdir'"
di as txt "  Output dir: `testdir'"

capture noisily _wbopendata_sync, outdir("`testdir'") force
local rc = _rc
if (`rc' == 0) {
    di as res "  sync: SUCCESS (method = `r(method)')"
}
else {
    di as err "  sync: FAILED (rc=" `rc' ")"
    di as txt "  Note: If Python ran, the key test passed (Python detection works)"
}

di _n as txt "======================================================================"
di as txt "Sync detection test completed"
di as txt "======================================================================"
