*===============================================================================
* setup_qa_environment.do — Prepare wbopendata QA environment
*
* RUN ONCE before running QA tests to enable full test coverage
*
* This script:
*   1. Syncs wbopendata package metadata (YAML files)
*   2. Verifies installed package version
*   3. Validates QA fixtures
*   4. Reports environment readiness
*
* Usage:
*   do setup_qa_environment.do
*
* Note: Requires internet for package sync. Can be skipped if you only want
*       to test help examples (run test_help_examples.do directly).
*===============================================================================

local start_time = c(current_time)
local start_date = c(current_date)

display as text _n(2) "=========================================="
display as text "wbopendata QA Environment Setup"
display as text "=========================================="
display as text "Date: `start_date' `start_time'" _n

* ===== Step 1: Verify wbopendata installed =====
display as text "Step 1: Verify wbopendata installation..."
cap which wbopendata
if _rc != 0 {
    display as error "  [ERROR] wbopendata not installed"
    display as text "  Install from: ssc install wbopendata"
    error 1
}
else {
    qui wbopendata, info
    local version = "`r(version)'"
    display as result "  ✓ wbopendata version `version' found"
}

* ===== Step 2: Sync metadata (YAML files) =====
display as text _n "Step 2: Syncing package metadata (YAML files)..."
display as text "  (This requires internet connection)"

cap noi wbopendata, sync
if _rc != 0 {
    display as error "  [WARNING] Metadata sync failed (offline mode)"
    display as text "  CACHE tests may fail - this is normal without internet"
    display as text "  To retry: wbopendata, sync"
}
else {
    display as result "  ✓ Metadata synced successfully"
    cap {
        local cache_dir = "`c(sysdir_personal)'_/"
        cap confirm file "`cache_dir'_wbopendata_indicators.yaml"
        if _rc == 0 {
            display as result "  ✓ Indicators YAML found: `cache_dir'_wbopendata_indicators.yaml"
        }
    }
}

* ===== Step 3: Validate QA fixtures =====
display as text _n "Step 3: Validating QA fixtures..."

local needed_fixtures "SP_POP_TOTL_USA.csv" "SP_POP_TOTL_all.csv" ///
                      "NY_GDP_MKTP_CD_USA.csv" "country_USA.csv"

local fixtures_dir = "`c(pwd)'/fixtures"
cap confirm dir "`fixtures_dir'"
if _rc != 0 {
    display as error "  [ERROR] fixtures/ directory not found"
    error 1
}

local missing = 0
foreach fix of local needed_fixtures {
    cap confirm file "`fixtures_dir'/`fix'"
    if _rc != 0 {
        display as error "  ✗ Missing: `fix'"
        local missing = `missing' + 1
    }
    else {
        display as result "  ✓ Found: `fix'"
    }
}

if `missing' > 0 {
    display as error _n "  [ERROR] Some fixtures missing"
    display as text "  All fixtures are required for DET tests"
    error 1
}
else {
    display as result _n "  ✓ All fixtures present"
}

* ===== Summary =====
display as text _n "=========================================="
display as result "QA Environment Ready!"
display as text "=========================================="

display as text _n "You can now run:"
display as text "  do run_submission_qa.do"
display as text _n "Or specific tests:"
display as text "  do run_submission_qa.do, mode(core)       // Core tests"
display as text "  do run_submission_qa.do, mode(help)       // Help examples"
display as text "  do run_submission_qa.do, mode(all)        // Everything"

local end_time = c(current_time)
display as text _n "Setup completed: `end_time'"
