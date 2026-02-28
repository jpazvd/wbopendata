*===============================================================================
* verify_qa_setup.do — Quick Environment Check
*
* Verifies all prerequisites for running the QA test suite
*
* Usage:
*   do verify_qa_setup.do
*
* Returns:
*   Display of setup status with actionable recommendations
*===============================================================================

local sep "======================================================================"

display as text _n "`sep'"
display as result "wbopendata QA Environment Verification"
display as text "`sep'" _n

local issues = 0

* ===== Check 1: wbopendata installed =====
display as text "[1/5] Checking wbopendata installation..."
cap which wbopendata
if _rc != 0 {
    display as error "  ✗ wbopendata not installed"
    display as text "  Action: Install from software/ folder or ssc"
    local issues = `issues' + 1
}
else {
    qui wbopendata, info
    local version = "`r(version)'"
    display as result "  ✓ wbopendata v`version' installed"
}

* ===== Check 2: YAML metadata files =====
display as text _n "[2/5] Checking YAML metadata files..."
local ado_dir = "`c(sysdir_plus)'_/"
local yaml_files "_wbopendata_indicators.yaml _wbopendata_sources.yaml _wbopendata_topics.yaml _wbopendata_parameters.yaml"

local found_yaml = 0
local missing_yaml = 0
foreach yaml of local yaml_files {
    cap confirm file "`ado_dir'`yaml'"
    if _rc == 0 {
        local found_yaml = `found_yaml' + 1
    }
    else {
        if `missing_yaml' == 0 {
            display as error "  ✗ Missing YAML files in: `ado_dir'"
        }
        display as error "    - `yaml'"
        local missing_yaml = `missing_yaml' + 1
    }
}

if `found_yaml' == 4 {
    display as result "  ✓ All 4 YAML files found in ado directory"
}
else if `found_yaml' > 0 {
    display as text "  ⚠ Partial: `found_yaml'/4 YAML files found"
    local issues = `issues' + 1
}
else {
    display as text "  Action: Copy from qa/cache/ to `ado_dir'"
    display as text "    PowerShell: Copy-Item qa\cache\_wbopendata_*.yaml `ado_dir' -Force"
    local issues = `issues' + 1
}

* ===== Check 3: QA directory structure =====
display as text _n "[3/5] Checking QA directory structure..."
local qa_dir = "`c(pwd)'"
if !regexm("`qa_dir'", "qa/?$") {
    * Try to find qa dir relative to current location
    cap confirm dir "`qa_dir'/qa"
    if _rc == 0 {
        local qa_dir = "`qa_dir'/qa"
    }
}

local required_files "run_tests.do submission.cfg README.md"
local missing_files = 0
foreach file of local required_files {
    cap confirm file "`qa_dir'/`file'"
    if _rc != 0 {
        if `missing_files' == 0 {
            display as error "  ✗ Missing required files:"
        }
        display as error "    - `file'"
        local missing_files = `missing_files' + 1
    }
}

if `missing_files' == 0 {
    display as result "  ✓ QA directory structure valid"
}
else {
    display as text "  Action: Ensure you're in the qa/ directory"
    local issues = `issues' + 1
}

* ===== Check 4: Fixtures (optional but recommended) =====
display as text _n "[4/5] Checking test fixtures (optional)..."
cap confirm dir "`qa_dir'/fixtures"
if _rc != 0 {
    display as text "  ⚠ fixtures/ directory not found"
    display as text "  Note: DET tests will be skipped (non-critical)"
}
else {
    local fixture_count = 0
    local needed_fixtures "SP_POP_TOTL_USA.csv SP_POP_TOTL_all.csv NY_GDP_MKTP_CD_USA.csv country_USA.csv"
    foreach fix of local needed_fixtures {
        cap confirm file "`qa_dir'/fixtures/`fix'"
        if _rc == 0 {
            local fixture_count = `fixture_count' + 1
        }
    }
    
    if `fixture_count' == 4 {
        display as result "  ✓ All 4 required fixtures present"
    }
    else if `fixture_count' > 0 {
        display as text "  ⚠ Partial: `fixture_count'/4 fixtures found"
        display as text "  Note: Some DET tests may fail"
    }
    else {
        display as text "  ⚠ No CSV fixtures found"
        display as text "  Action: Extract fixtures.tar.gz if available"
    }
}

* ===== Check 5: Cache directory =====
display as text _n "[5/5] Checking cache directory..."
cap confirm dir "`qa_dir'/cache"
if _rc != 0 {
    display as error "  ✗ cache/ directory not found"
    display as text "  Action: This directory should contain YAML files for distribution"
    local issues = `issues' + 1
}
else {
    local cache_yaml_count = 0
    foreach yaml of local yaml_files {
        cap confirm file "`qa_dir'/cache/`yaml'"
        if _rc == 0 {
            local cache_yaml_count = `cache_yaml_count' + 1
        }
    }
    
    if `cache_yaml_count' == 4 {
        display as result "  ✓ All 4 YAML files in qa/cache/"
    }
    else {
        display as text "  ⚠ Only `cache_yaml_count'/4 YAML files in cache/"
        local issues = `issues' + 1
    }
}

* ===== Summary =====
display as text _n "`sep'"
if `issues' == 0 {
    display as result "Environment Status: READY ✓"
    display as text "`sep'" _n
    display as text "You can now run:"
    display as text "  do run_tests.do"
    display as text "Or:"
    display as text "  .\run_tests.ps1    (PowerShell)"
    display as text "  RUN_TESTS.bat      (Windows batch)"
}
else {
    display as error "Environment Status: ISSUES FOUND (`issues')"
    display as text "`sep'" _n
    display as text "Please resolve the issues above before running tests."
    display as text _n "Quick fix for most common issue (YAML files):"
    display as text "  PowerShell:"
    display as text "    Copy-Item qa\cache\_wbopendata_*.yaml `ado_dir' -Force"
}

display as text _n
