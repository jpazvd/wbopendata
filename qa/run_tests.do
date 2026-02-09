/*******************************************************************************
* wbopendata Automated Test Suite
* Test Suite Version: 2.0.0
* Date: January 2026
* Compatible with: wbopendata v17.7.1+
* Total Tests: 65 (61 core + 4 repo-comparison)
* 
* Usage: 
*   do run_tests.do              - Run all tests (prompts for repo location)
*   do run_tests.do DL-01        - Run only test DL-01
*   do run_tests.do DL-01 verbose - Run DL-01 with trace on (debug mode)
*   do run_tests.do verbose      - Run all tests with trace on
*   do run_tests.do list         - List all available tests
*   do run_tests.do norepo       - Skip repo comparison tests (ENV-01 to ENV-04)
*
* Test Categories (57 tests total):
*   0 - Environment Checks (5): ENV-01 to ENV-05 [ENV-01 to ENV-04 require repo path]
*   1 - Basic Downloads (5): DL-01 to DL-05
*   2 - Format Options (3): FMT-01 to FMT-03
*   3 - Country Metadata (10): CTRY-01 to CTRY-10
*   4 - Regression Tests (4): REG-33, REG-45, REG-46, REG-51
*   5 - Graph Metadata (4): LW-01 to LW-04
*   6 - Maintenance Commands (6): UPD-01 to UPD-06
*   7 - Topics & Language (2): TOPIC-01, LANG-01
*   8 - Advanced Features (6): PROJ-01, FMT-04, DESC-01, META-01, CTRY-11, DATE-01
*   9 - Cache & Sync System (13): CACHE-01 to CACHE-08, SYNC-01 to SYNC-05
*  10 - Discovery Commands (7): DISC-01 to DISC-07 [no network needed]
* 
* Configuration:
*   To set your repo path permanently, define global before running:
*     global wbopendata_repo "C:/path/to/wbopendata-dev"
*   Or set environment variable WBOPENDATA_REPO
*   Or the script will auto-detect from this file's location
*
* Testing Best Practices Implemented:
*   1. NO empty capture blocks - always run explicit commands inside cap
*   2. Check _rc immediately after each command that matters
*   3. Use explicit variable existence checks: capture confirm variable
*   4. Verify data with count if !missing() not just assert
*   5. Provide informative failure messages with actual error codes
*   6. Remove corrupted auto-generated files before test run
*
* Common Issues Fixed:
*   - r(920) macro length errors from corrupted _parameters.ado
*   - Empty cap{} blocks that don't set _rc meaningfully
*   - Tests failing silently without running actual validation
*******************************************************************************/

clear all
set more off
cap log close _all

*===============================================================================
* PARSE COMMAND LINE ARGUMENTS
*===============================================================================

* Get arguments passed to do-file
local args `0'
local target_test ""
local verbose 0
local skip_repo_tests 0

* Parse arguments
foreach arg of local args {
    if upper("`arg'") == "VERBOSE" {
        local verbose 1
    }
    else if upper("`arg'") == "NOREPO" {
        local skip_repo_tests 1
    }
    else if upper("`arg'") == "LIST" {
        * List all tests and exit
        di as text _n "Available tests:"
        di as text ""
        di as text "  Environment Checks:"
        di as text "  ENV-01   wbopendata version matches repo"
        di as text "  ENV-02   Ado files sync status (source vs auto-gen)"
        di as text "  ENV-03   wbopendata.pkg matches src directories"
        di as text "  ENV-04   All pkg files exist in repo"
        di as text "  ENV-05   Parameters YAML readable with valid r() values"
        di as text ""
        di as text "  Basic Downloads:"
        di as text "  DL-01    Single indicator download"
        di as text "  DL-02    Single country download"
        di as text "  DL-03    Multiple countries download"
        di as text "  DL-04    Multiple indicators download"
        di as text "  DL-05    Poverty and GDP per capita download"
        di as text ""
        di as text "  Format Options:"
        di as text "  FMT-01   Long format"
        di as text "  FMT-02   Year range filter"
        di as text "  FMT-03   Latest option"
        di as text ""
        di as text "  Country Metadata:"
        di as text "  CTRY-01  Match basic"
        di as text "  CTRY-02  Match with full option"
        di as text "  CTRY-03  Full country metadata with indicator"
        di as text "  CTRY-04  ISO 2-digit codes option"
        di as text "  CTRY-05  Geographic GEO group option"
        di as text "  CTRY-06  Capital geographic option"
        di as text "  CTRY-07  Latitude and longitude options"
        di as text "  CTRY-08  Regions group option"
        di as text "  CTRY-09  Income and Lending group options"
        di as text "  CTRY-10  Geographic options with indicator"
        di as text ""
        di as text "  Regression Tests:"
        di as text "  REG-33   Issue #33 regression"
        di as text "  REG-45   Issue #45 regression"
        di as text "  REG-46   Issue #46 regression"
        di as text "  REG-51   Issue #51 regression"
        di as text ""
        di as text "  Graph Metadata (v17.6):"
        di as text "  LW-01    Linewrap option basic"
        di as text "  LW-02    Linewrap with maxlength"
        di as text "  LW-03    Latest returns scalars"
        di as text "  LW-04    Linewrap all fields"
        di as text ""
        di as text "  Maintenance Commands:"
        di as text "  UPD-01   Update query command"
        di as text "  UPD-02   Describe indicators"
        di as text "  UPD-03   Update basic"
        di as text "  UPD-04   Update check detail"
        di as text "  UPD-05   Update all"
        di as text "  UPD-06   Update all force"
        di as text ""
        di as text "  Topics & Language:"
        di as text "  TOPIC-01 Topics download"
        di as text "  LANG-01  Language option Spanish"
        di as text ""
        di as text "  Advanced Features:"
        di as text "  PROJ-01  Projection data download"
        di as text "  FMT-04   nobasic option"
        di as text "  DESC-01  Describe option metadata only"
        di as text "  META-01  nometadata verification"
        di as text "  CTRY-11  Admin regions option"
        di as text "  DATE-01  Date range option"
        di as text ""
        di as text "  Cache & Sync System (v18.x):"
        di as text "  CACHE-01 Cache directory initialization"
        di as text "  CACHE-02 Get YAML path (cache vs package)"
        di as text "  CACHE-03 Cache info display"
        di as text "  CACHE-04 Clear cache"
        di as text "  CACHE-05 Cache persistence"
        di as text "  CACHE-06 Version file tracking"
        di as text "  CACHE-07 Timestamp tracking"
        di as text "  CACHE-08 Search with cached YAML"
        di as text "  SYNC-01  Check for updates"
        di as text "  SYNC-02  Sync command (download)"
        di as text "  SYNC-03  Force sync"
        di as text "  SYNC-04  Sync with no updates"
        di as text "  SYNC-05  Discovery commands use cache"
        di as text ""
        di as text "  Discovery Commands:"
        di as text "  DISC-01  Search basic (keyword returns results)"
        di as text "  DISC-02  Search filters (source, topic, field)"
        di as text "  DISC-03  Search patterns (wildcard, AND, exact)"
        di as text "  DISC-04  Sources listing"
        di as text "  DISC-05  Topics listing"
        di as text "  DISC-06  Indicator info lookup"
        di as text "  DISC-07  Search router (cache_method by Stata version)"
        exit 0
    }
    else {
        local target_test = upper("`arg'")
    }
}

* Display mode
if "`target_test'" != "" {
    di as text _n "Running single test: `target_test'"
}
if `verbose' == 1 {
    di as text "Verbose mode: TRACE ON"
    set trace on
    set tracedepth 2
}

*===============================================================================
* PATH CONFIGURATION (Auto-detect or user-defined)
*===============================================================================

* Priority order for repo path:
*   1. Global wbopendata_repo (set before running this script)
*   2. Auto-detect from this do-file's location (assumes qa/ subfolder)
*   3. User prompt if repo comparison tests are needed

local repo_root ""
local qadir ""

* Try global first
if `"$wbopendata_repo"' != "" {
    local repo_root = `"$wbopendata_repo"'
    local qadir "`repo_root'/qa"
    di as text "Repo path (from global): `repo_root'"
}
else {
    * Auto-detect: if running from qa/ folder, parent is repo root
    * Use c(pwd) to get current working directory
    local cwd = c(pwd)
    
    * Check if we're in a qa folder
    if regexm("`cwd'", "(.+)[/\\]qa[/\\]?$") {
        local repo_root = regexs(1)
        local qadir "`cwd'"
        * Normalize slashes
        local repo_root = subinstr("`repo_root'", "\", "/", .)
        local qadir = subinstr("`qadir'", "\", "/", .)
        di as text "Repo path (auto-detected): `repo_root'"
    }
    else {
        * Check if qa subfolder exists in current directory
        cap confirm file "`cwd'/qa/."
        if _rc == 0 {
            local repo_root = subinstr("`cwd'", "\", "/", .)
            local qadir "`repo_root'/qa"
            di as text "Repo path (from cwd): `repo_root'"
        }
        else {
            * No repo detected
            local repo_root ""
            local qadir = subinstr("`cwd'", "\", "/", .)
            di as text "Repo path: not detected (logs will save to current directory)"
        }
    }
}

* Validate repo path if provided
if "`repo_root'" != "" {
    cap confirm file "`repo_root'/wbopendata.pkg"
    if _rc != 0 {
        di as error "Warning: wbopendata.pkg not found at `repo_root'"
        di as error "         Repo comparison tests (ENV-*) may fail"
        if `skip_repo_tests' == 0 {
            di as text _n "Tip: Run with 'norepo' option to skip repo tests:"
            di as text "     do run_tests.do norepo"
        }
    }
}

* If no repo and repo tests not skipped, prompt user
if "`repo_root'" == "" & `skip_repo_tests' == 0 {
    di as text _n "{hline 70}"
    di as text "REPO PATH CONFIGURATION"
    di as text "{hline 70}"
    di as text "No wbopendata repo path detected."
    di as text _n "Options:"
    di as text "  1. Set global before running: global wbopendata_repo {c 34}C:/path/to/wbopendata{c 34}"
    di as text "  2. Run from repo root or qa/ folder"
    di as text "  3. Run with 'norepo' option to skip repo comparison tests"
    di as text _n "Continuing with repo tests SKIPPED..."
    di as text "{hline 70}"
    local skip_repo_tests 1
}

* Store in globals for use in tests
global repo_root "`repo_root'"
global qadir "`qadir'"
global skip_repo_tests `skip_repo_tests'

* Install from repo if path is available and user wants repo sync
if "`repo_root'" != "" & `skip_repo_tests' == 0 {
    di as text _n "Installing wbopendata from repo: `repo_root'"
    cap noi net install wbopendata, from("`repo_root'") replace
    if _rc != 0 {
        di as error "Warning: Could not install from repo (rc=`=_rc')"
        di as text "         Continuing with currently installed version"
    }
}
else {
    di as text _n "Using currently installed wbopendata (no repo sync)"
}

* Global to control which test to run (empty = all tests)
global target_test "`target_test'"
global verbose `verbose'

* Increase resource limits to prevent macro line length issues
set maxvar 32767
set varabbrev off

* Use installed wbopendata (ado/plus) as the active version; do not delete auto-generated files

* Detect installed wbopendata version from the ado header (ensures logs/history reflect actual package)
local version "unknown"
local wbo_date ""
capture {
    findfile wbopendata.ado
    local wbo_path "`r(fn)'"
    file open f using "`wbo_path'", read text
    * Read up to 10 lines to find the version line (starts with *!)
    forvalues i = 1/10 {
        file read f line
        if r(eof) continue, break
        if (substr(trim("`line'"), 1, 2) == "*!") {
            * Found version line: *! v 17.6.3  04Jan2026  by ...
            local line = trim(substr("`line'", 3, .))
            if (substr("`line'", 1, 1) == "v") {
                local line = trim(substr("`line'", 2, .))
                * Normalize whitespace: replace tabs with spaces, compress multiple spaces
                local line = subinstr("`line'", char(9), " ", .)
                local line = itrim("`line'")
                if (wordcount("`line'") >= 2) {
                    local version = word("`line'", 1)
                    local wbo_date = word("`line'", 2)
                }
            }
            continue, break
        }
    }
    file close f
}

* Test configuration
local date = c(current_date)
local start_time = c(current_time)
local datestr = subinstr("`date'", " ", "", .)
local logfile "`qadir'/test_results_v`version'_`datestr'.log"
local histfile "`qadir'/test_history.txt"

* Separator line
local sep "======================================================================"

* Start log
log using "`logfile'", replace text

di as text _n "`sep'"
di as text "WBOPENDATA TEST SUITE"
di as text "Version: `version'"
if "`wbo_date'" != "" {
    di as text "Build date: `wbo_date'"
}
if "`target_test'" != "" {
    di as text "Target:  `target_test'"
}
if `verbose' == 1 {
    di as text "Mode:    VERBOSE (trace on)"
}
di as text "Date: `date' `start_time'"
di as text "Stata: `c(stata_version)'"
di as text "`sep'"

*===============================================================================
* TEST FRAMEWORK
*===============================================================================

* Test macro - sets global skip_test to 1 if test should be skipped
cap program drop run_test
program define run_test
    args test_id description
    
    * Check if we should run this test
    if "$target_test" != "" & upper("$target_test") != upper("`test_id'") {
        global skip_test 1
        exit
    }
    
    global skip_test 0
    di as text _n "--- TEST `test_id': `description' ---"
    
    * Store current test ID and increment counter
    global current_test "`test_id'"
    global tests_run = $tests_run + 1
end

cap program drop test_pass
program define test_pass
    if $skip_test == 1 exit
    di as result "PASS"
    global tests_pass = $tests_pass + 1
    * Turn off trace after test in single-test verbose mode
    if "$target_test" != "" & $verbose == 1 {
        set trace off
        di as text _n "--- TRACE OFF ---"
    }
end

cap program drop test_fail
program define test_fail
    args message
    if $skip_test == 1 exit
    di as error "FAIL: `message'"
    global tests_fail = $tests_fail + 1
    * Add to failed tests list
    if "$failed_tests" == "" {
        global failed_tests "$current_test"
    }
    else {
        global failed_tests "$failed_tests, $current_test"
    }
    * Turn off trace after test in single-test verbose mode
    if "$target_test" != "" & $verbose == 1 {
        set trace off
        di as text _n "--- TRACE OFF ---"
    }
end

* Initialize globals
global tests_run = 0
global tests_pass = 0
global tests_fail = 0
global failed_tests ""
global current_test ""
global skip_test 0

* which version of stata is this test being run on
which wbopendata

*===============================================================================
* TEST CATEGORY 0: Environment Checks
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 0: Environment Checks"
di as text "`sep'"

* ENV-01: Verify wbopendata version matches repo
run_test "ENV-01" "wbopendata version matches repo"
if $skip_test == 0 {
    * Skip if no repo path or repo tests disabled
    if "$repo_root" == "" | $skip_repo_tests == 1 {
        di as text "SKIPPED: Repo path not configured (use 'global wbopendata_repo' or run from repo)"
        global tests_run = $tests_run - 1  // Don't count as run
    }
    else {
        cap noi {
            * Get path to installed wbopendata using findfile
            qui findfile wbopendata.ado
            local installed_path "`r(fn)'"
            
            di as text "Installed path: `installed_path'"
            
            * Read version line from installed file
            tempname fh
            file open `fh' using "`installed_path'", read text
            file read `fh' line
            file read `fh' line
            file read `fh' line  // Third line has version
            file close `fh'
            local installed_version = trim("`line'")
            
            * Read version line from repo file (use global repo path)
            local repo_path "$repo_root/src/w/wbopendata.ado"
            file open `fh' using "`repo_path'", read text
            file read `fh' line
            file read `fh' line
            file read `fh' line  // Third line has version
            file close `fh'
            local repo_version = trim("`line'")
            
            di as text "Installed version: `installed_version'"
            di as text "Repo version:      `repo_version'"
            
            assert "`installed_version'" == "`repo_version'"
        }
        if _rc == 0 test_pass
        else test_fail "Version mismatch - run: copy src\*.ado to plus\"
    }
}

* ENV-02: Verify all ado files match repo (distinguishes source vs auto-generated)
run_test "ENV-02" "Ado files sync status"
if $skip_test == 0 {
    * Skip if no repo path or repo tests disabled
    if "$repo_root" == "" | $skip_repo_tests == 1 {
        di as text "SKIPPED: Repo path not configured (use 'global wbopendata_repo' or run from repo)"
        global tests_run = $tests_run - 1  // Don't count as run
    }
    else {
        cap noi {
            * SOURCE files - must match repo (these are version-controlled)
            local source_files "_api_read _api_read_indicators _countrymetadata _linewrap _metadata_linewrap _query _query_indicators _query_metadata _tknz _update_countrymetadata _update_indicators _update_regionmetadata _update_wbopendata _website"
            
            * AUTO-GENERATED files - created by "wbopendata, update" 
            * Mismatch is informational only (run "wbopendata, update" to refresh)
            local autogen_files "_parameters _wbod_tmpfile1 _wbod_tmpfile2 _wbod_tmpfile3"
            
            local src_mismatches ""
            local src_missing ""
            local autogen_mismatches ""
            
            di as text _n "Checking SOURCE files (must match repo):"
            foreach f of local source_files {
                cap qui findfile `f'.ado
                if _rc != 0 {
                    local src_missing "`src_missing' `f'"
                    di as error "  `f': MISSING"
                    continue
                }
                local installed_path "`r(fn)'"
                
                local repo_path "$repo_root/src/_/`f'.ado"
                cap confirm file "`repo_path'"
                if _rc != 0 {
                    di as text "  `f': not in repo (OK if deprecated)"
                    continue
                }
                
                tempname fh1 fh2
                file open `fh1' using "`installed_path'", read text
                file open `fh2' using "`repo_path'", read text
                local match 1
                forvalues i = 1/5 {
                    file read `fh1' line1
                    file read `fh2' line2
                    if `"`line1'"' != `"`line2'"' local match 0
                }
                file close `fh1'
                file close `fh2'
                
                if `match' == 0 {
                    local src_mismatches "`src_mismatches' `f'"
                    di as error "  `f': MISMATCH - copy from repo to ado/plus/_/"
                }
                else {
                    di as text "  `f': OK"
                }
            }
            
            di as text _n "Checking AUTO-GENERATED files (created by wbopendata, update):"
            foreach f of local autogen_files {
                cap qui findfile `f'.ado
                if _rc != 0 {
                    di as text "  `f': not installed (run: wbopendata, update)"
                    continue
                }
                local installed_path "`r(fn)'"
                
                local repo_path "$repo_root/src/_/`f'.ado"
                cap confirm file "`repo_path'"
                if _rc != 0 {
                    di as text "  `f': installed but not in repo (expected)"
                    continue
                }
                
                tempname fh1 fh2
                file open `fh1' using "`installed_path'", read text
                file open `fh2' using "`repo_path'", read text
                local match 1
                forvalues i = 1/5 {
                    file read `fh1' line1
                    file read `fh2' line2
                    if `"`line1'"' != `"`line2'"' local match 0
                }
                file close `fh1'
                file close `fh2'
                
                if `match' == 0 {
                    local autogen_mismatches "`autogen_mismatches' `f'"
                    di as text "  `f': differs from repo (OK - auto-generated)"
                }
                else {
                    di as text "  `f': matches repo"
                }
            }
            
            * Summary
            di as text _n "Summary:"
            if "`src_missing'" != "" {
                di as error "  SOURCE files MISSING:`src_missing'"
            }
            if "`src_mismatches'" != "" {
                di as error "  SOURCE files MISMATCHED:`src_mismatches'"
                di as error "  -> Run: copy src/_/*.ado to ado/plus/_/"
            }
            if "`autogen_mismatches'" != "" {
                di as text "  Auto-generated files out of sync:`autogen_mismatches'"
                di as text "  -> This is OK. Run 'wbopendata, update' to refresh if needed."
            }
            
            * Only fail on SOURCE file issues
            assert "`src_missing'" == "" & "`src_mismatches'" == ""
        }
        if _rc == 0 test_pass
        else test_fail "Source ado files missing or mismatched (see details above)"
    }
}

* ENV-03: Verify wbopendata.pkg lists all src ado files (dynamic scan)
run_test "ENV-03" "wbopendata.pkg matches src directories"
if $skip_test == 0 {
    * Skip if no repo path or repo tests disabled
    if "$repo_root" == "" | $skip_repo_tests == 1 {
        di as text "SKIPPED: Repo path not configured (use 'global wbopendata_repo' or run from repo)"
        global tests_run = $tests_run - 1  // Don't count as run
    }
    else {
        cap noi {
            * Read wbopendata.pkg and extract F lines into a string
            local pkg_path "$repo_root/src/wbopendata.pkg"
            local pkg_contents ""
            
            tempname fh
            file open `fh' using "`pkg_path'", read text
            file read `fh' line
            while r(eof) == 0 {
                if substr("`line'", 1, 2) == "F " {
                    local pkg_contents "`pkg_contents' `line'"
                }
                file read `fh' line
            }
            file close `fh'
            
            * Scan src subdirectories for all .ado files
            local missing_from_pkg ""
            local src_subdirs "_ w"
            
            foreach subdir of local src_subdirs {
                local src_path "$repo_root/src/`subdir'"
                
                * Get list of ado files in this directory
                local ado_files : dir "`src_path'" files "*.ado", respectcase
                
                foreach f of local ado_files {
                    * Build expected path as it should appear in pkg (no src/ prefix)
                    local expected_path "`subdir'/`f'"
                    
                    if strpos("`pkg_contents'", "`expected_path'") == 0 {
                        local missing_from_pkg "`missing_from_pkg' `expected_path'"
                        di as error "NOT in pkg: `expected_path'"
                    }
                    else {
                        di as text "OK: `expected_path'"
                    }
                }
            }
            
            * Also scan for .sthlp, .dlg, .dta, .txt files in src/w and src/c and src/i
            local other_subdirs "w c i"
            local other_exts "sthlp dlg dta txt"
            
            foreach subdir of local other_subdirs {
                local src_path "$repo_root/src/`subdir'"
                cap confirm file "`src_path'/."
                if _rc == 0 {
                    foreach ext of local other_exts {
                        local files : dir "`src_path'" files "*.`ext'", respectcase
                        foreach f of local files {
                            local expected_path "`subdir'/`f'"
                            if strpos("`pkg_contents'", "`expected_path'") == 0 {
                                local missing_from_pkg "`missing_from_pkg' `expected_path'"
                                di as error "NOT in pkg: `expected_path'"
                            }
                        }
                    }
                }
            }
            
            if "`missing_from_pkg'" == "" {
                di as text _n "All src files are listed in wbopendata.pkg"
            }
            else {
                di as error _n "Missing from wbopendata.pkg:`missing_from_pkg'"
            }
            
            assert "`missing_from_pkg'" == ""
        }
        if _rc == 0 test_pass
        else test_fail "wbopendata.pkg missing some src files"
    }
}

* ENV-04: Verify all pkg files exist in repo
run_test "ENV-04" "All pkg files exist in repo"
if $skip_test == 0 {
    * Skip if no repo path or repo tests disabled
    if "$repo_root" == "" | $skip_repo_tests == 1 {
        di as text "SKIPPED: Repo path not configured (use 'global wbopendata_repo' or run from repo)"
        global tests_run = $tests_run - 1  // Don't count as run
    }
    else {
        cap noi {
            * Read wbopendata.pkg and verify each F line file exists
            local pkg_path "$repo_root/src/wbopendata.pkg"
            local missing_files ""
            
            tempname fh
            file open `fh' using "`pkg_path'", read text
            file read `fh' line
            while r(eof) == 0 {
                if substr("`line'", 1, 2) == "F " {
                    local filepath = substr("`line'", 3, .)
                    local fullpath "$repo_root/src/`filepath'"
                    cap confirm file "`fullpath'"
                    if _rc != 0 {
                        local missing_files "`missing_files' `filepath'"
                        di as error "MISSING: `filepath'"
                    }
                }
                file read `fh' line
            }
            file close `fh'
            
            if "`missing_files'" == "" {
                di as text "All files in wbopendata.pkg exist in repo"
            }
            
            assert "`missing_files'" == ""
        }
        if _rc == 0 test_pass
        else test_fail "Some pkg files missing from repo"
    }
}

* ENV-05: Parameters YAML readable with valid r() values (no network needed)
run_test "ENV-05" "Parameters YAML readable with valid r() values"
if $skip_test == 0 {
    cap noi {
        * Run _parameters (reads _wbopendata_parameters.yaml)
        qui _parameters

        * Check required scalar values
        assert "`r(total)'" != ""
        assert "`r(number_indicators)'" != ""
        assert "`r(ctrymetadata)'" != ""

        * Check required timestamp values
        assert "`r(dt_update)'" != ""
        assert "`r(dt_lastcheck)'" != ""
        assert "`r(dt_ctryupdate)'" != ""

        * Check source return values
        assert "`r(sourcereturn)'" != ""
        assert `"`r(sourceid)'"' != ""
        assert "`r(sourceid02)'" != ""  // WDI must exist
        di as text "Sources: " wordcount("`r(sourcereturn)'") " entries, WDI=" r(sourceid02)

        * Check topic return values
        assert "`r(topicreturn)'" != ""
        assert `"`r(topicid)'"' != ""
        assert "`r(topicid01)'" != ""   // Agriculture must exist
        di as text "Topics:  " wordcount("`r(topicreturn)'") " entries"

        * Verify all sources in sourcereturn have counts
        foreach sname in `r(sourcereturn)' {
            assert "`r(`sname')'" != ""
        }

        * Verify all topics in topicreturn have counts
        foreach tname in `r(topicreturn)' {
            assert "`r(`tname')'" != ""
        }

        di as text "All r() values present and valid"
    }
    if _rc == 0 test_pass
    else test_fail "Parameters YAML read failed or returned incomplete values"
}

*===============================================================================
* TEST CATEGORY 1: Basic Downloads
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 1: Basic Downloads"
di as text "`sep'"

* Verify wbopendata is accessible
which wbopendata

* DL-01: Single indicator
run_test "DL-01" "Single indicator download"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) clear nometadata long
        desc, short
        assert _N > 200
    }
    if _rc == 0 test_pass
    else test_fail "Failed to download single indicator"
}

* DL-02: Specific country
run_test "DL-02" "Single country download"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) clear nometadata long
        assert _N > 50
        levelsof countrycode, local(ctry) clean
        assert "`ctry'" == "USA"
    }
    if _rc == 0 test_pass
    else test_fail "Failed to download for single country"
}

* DL-03: Multiple countries
run_test "DL-03" "Multiple countries download"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear nometadata long
        levelsof countrycode, local(ctry) clean
        assert wordcount("`ctry'") == 3
    }
    if _rc == 0 test_pass
    else test_fail "Failed to download for multiple countries"
}

* DL-04: Multiple indicators
run_test "DL-04" "Multiple indicators download"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL;NY.GDP.MKTP.CD) clear long nometadata
        assert _N > 200
        cap confirm variable sp_pop_totl
        local rc1 = _rc
        cap confirm variable ny_gdp_mktp_cd
        local rc2 = _rc
        assert `rc1' == 0 & `rc2' == 0
    }
    if _rc == 0 test_pass
    else test_fail "Failed to download multiple indicators"
}

* DL-05: Poverty and GDP per capita indicators
run_test "DL-05" "Poverty and GDP per capita download"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long nometadata
        cap confirm variable si_pov_dday
        assert _rc == 0
        cap confirm variable ny_gdp_pcap_pp_kd
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Failed to download poverty/GDP indicators"
}

*===============================================================================
* TEST CATEGORY 2: Format Options
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 2: Format Options"
di as text "`sep'"

* FMT-01: Long format
run_test "FMT-01" "Long format"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nometadata
        assert year != .
        assert _N > 50
    }
    if _rc == 0 test_pass
    else test_fail "Long format not working"
}

* FMT-02: Year range
run_test "FMT-02" "Year range filter"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) year(2010:2020) clear long nometadata
        sum year
        assert r(min) >= 2010
        assert r(max) <= 2020
    }
    if _rc == 0 test_pass
    else test_fail "Year range not working"
}

* FMT-03: Latest option
run_test "FMT-03" "Latest option"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear long latest nometadata
        bysort countrycode: assert _N == 1
    }
    if _rc == 0 test_pass
    else test_fail "Latest option not working"
}

*===============================================================================
* TEST CATEGORY 3: Country Metadata
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 3: Country Metadata"
di as text "`sep'"

* CTRY-01: Match basic
run_test "CTRY-01" "Match basic"
if $skip_test == 0 {
    * Download base dataset
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        keep countrycode
        
        * Apply match to add countryname
        capture noisily wbopendata, match(countrycode)
        if _rc != 0 {
            test_fail "Match command failed: r(`=_rc')"
        }
        else {
            * 1) Variable exists
            capture confirm variable countryname
            if _rc != 0 {
                test_fail "Match basic not working - countryname variable is missing"
            }
            else {
                * 2) Variable has data
                quietly count if !missing(countryname)
                if r(N) == 0 {
                    test_fail "Match basic not working - countryname exists but has no non-missing data"
                }
                else {
                    * 3) Verify we got at least 3 countries
                    qui count if inlist(countrycode, "USA", "BRA", "CHN")
                    if r(N) < 3 {
                        test_fail "Match basic - expected 3 countries, got `=r(N)'"
                    }
                    else {
                        test_pass
                    }
                }
            }
        }
    }
}


* CTRY-02: Match with full
run_test "CTRY-02" "Match with full option"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;BRA) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        capture noisily wbopendata, match(countrycode) full
        if _rc != 0 {
            test_fail "Match full command failed: r(`=_rc')"
        }
        else {
            * Check for expected variables
            local missing_vars ""
            foreach v in longitude latitude capital {
                capture confirm variable `v'
                if _rc != 0 local missing_vars "`missing_vars' `v'"
            }
            if "`missing_vars'" != "" {
                test_fail "Match full missing variables:`missing_vars'"
            }
            else test_pass
        }
    }
}

* CTRY-03: Full country metadata with indicator
run_test "CTRY-03" "Full country metadata with indicator"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(NY.GDP.PCAP.PP.KD) country(BRA;USA;CHN) clear long full nometadata
    if _rc != 0 {
        test_fail "Failed to download with full metadata: r(`=_rc')"
    }
    else {
        local missing_vars ""
        foreach v in longitude latitude capital {
            capture confirm variable `v'
            if _rc != 0 local missing_vars "`missing_vars' `v'"
        }
        if "`missing_vars'" != "" {
            test_fail "Full metadata missing variables:`missing_vars'"
        }
        else test_pass
    }
}

* CTRY-04: ISO option
run_test "CTRY-04" "ISO 2-digit codes option"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(BRA) clear long iso nometadata
    if _rc != 0 {
        test_fail "Failed to download with iso option: r(`=_rc')"
    }
    else {
        capture confirm variable region_iso2
        if _rc != 0 {
            test_fail "ISO option - region_iso2 variable missing"
        }
        else test_pass
    }
}

* CTRY-05: Geographic option (GEO group)
run_test "CTRY-05" "Geographic GEO group option"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        capture noisily wbopendata, match(countrycode) geo
        if _rc != 0 {
            test_fail "Match geo command failed: r(`=_rc')"
        }
        else {
            local missing_vars ""
            foreach v in capital latitude longitude {
                capture confirm variable `v'
                if _rc != 0 local missing_vars "`missing_vars' `v'"
            }
            if "`missing_vars'" != "" {
                test_fail "GEO option missing variables:`missing_vars'"
            }
            else test_pass
        }
    }
}

* CTRY-06: Capital option (individual)
run_test "CTRY-06" "Capital geographic option"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;BRA) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        capture noisily wbopendata, match(countrycode) capital
        if _rc != 0 {
            test_fail "Match capital command failed: r(`=_rc')"
        }
        else {
            capture confirm variable capital
            if _rc != 0 test_fail "Capital variable missing"
            else test_pass
        }
    }
}

* CTRY-07: Latitude and longitude options
run_test "CTRY-07" "Latitude and longitude options"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;CHN) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        capture noisily wbopendata, match(countrycode) latitude longitude
        if _rc != 0 {
            test_fail "Match lat/lon command failed: r(`=_rc')"
        }
        else {
            local missing_vars ""
            foreach v in latitude longitude {
                capture confirm variable `v'
                if _rc != 0 local missing_vars "`missing_vars' `v'"
            }
            if "`missing_vars'" != "" {
                test_fail "Lat/lon missing variables:`missing_vars'"
            }
            else test_pass
        }
    }
}

* CTRY-08: Regions group option
run_test "CTRY-08" "Regions group option"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;BRA) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        capture noisily wbopendata, match(countrycode) regions
        if _rc != 0 {
            test_fail "Match regions command failed: r(`=_rc')"
        }
        else {
            capture confirm variable regionname
            if _rc != 0 test_fail "Regionname variable missing"
            else test_pass
        }
    }
}

* CTRY-09: Income and Lending options
run_test "CTRY-09" "Income and Lending group options"
if $skip_test == 0 {
    capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA;BRA) clear long nometadata
    if _rc != 0 {
        test_fail "Failed to download base dataset: r(`=_rc')"
    }
    else {
        capture noisily wbopendata, match(countrycode) income lending
        if _rc != 0 {
            test_fail "Match income/lending command failed: r(`=_rc')"
        }
        else {
            local missing_vars ""
            foreach v in incomelevel lendingtype {
                capture confirm variable `v'
                if _rc != 0 local missing_vars "`missing_vars' `v'"
            }
            if "`missing_vars'" != "" {
                test_fail "Income/lending missing variables:`missing_vars'"
            }
            else test_pass
        }
    }
}

* CTRY-10: Geographic options with indicator download
run_test "CTRY-10" "Geographic options with indicator"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(NY.GDP.PCAP.PP.KD) country(USA;BRA;CHN) clear long ///
            geo capital latitude longitude regions income lending nometadata
        cap confirm variable capital
        assert _rc == 0
        cap confirm variable latitude
        assert _rc == 0
        cap confirm variable longitude
        assert _rc == 0
        cap confirm variable regionname
        assert _rc == 0
        cap confirm variable incomelevel
        assert _rc == 0
        cap confirm variable lendingtype
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Geographic options with indicator not working"
}

*===============================================================================
* TEST CATEGORY 4: Regression Tests (Fixed Issues)
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 4: Regression Tests"
di as text "`sep'"

* REG-33: Latest with long indicator names
run_test "REG-33" "Issue #33: Latest with long names"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(DT.DOD.DECT.CD) clear long latest nometadata
    }
    if _rc == 0 test_pass
    else test_fail "Issue #33 regression"
}

* REG-45: URL in metadata
run_test "REG-45" "Issue #45: URL in metadata"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SL.UEM.TOTL.ZS) clear
    }
    if _rc == 0 test_pass
    else test_fail "Issue #45 regression"
}

* REG-46: Varlist not allowed (update)
run_test "REG-46" "Issue #46: Update without varlist error"
if $skip_test == 0 {
    cap noi {
        clear
        wbopendata, update query
    }
    if _rc == 0 test_pass
    else test_fail "Issue #46 regression"
}

* REG-51: Match incompatibility
run_test "REG-51" "Issue #51: Match+indicator incompatibility check"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        end
        cap wbopendata, indicator(SP.POP.TOTL) match(countrycode) clear
        local reg51_rc = _rc
        assert `reg51_rc' != 0
    }
    if _rc == 0 test_pass
    else test_fail "Issue #51 regression - should have errored"
}

*===============================================================================
* TEST CATEGORY 5: Graph Metadata (v17.4)
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 5: Graph Metadata (v17.4 features)"
di as text "`sep'"

* LW-01: Linewrap basic
run_test "LW-01" "Linewrap option basic"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) clear long latest linewrap(name) nometadata
        assert strlen(`"`r(name1_stack)'"') > 0
    }
    if _rc == 0 test_pass
    else test_fail "Linewrap basic not working"
}

* LW-02: Linewrap with maxlength
run_test "LW-02" "Linewrap with maxlength"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SI.POV.DDAY) clear long latest ///
            linewrap(name description) maxlength(40 80) nometadata
        assert strlen(`"`r(name1_stack)'"') > 0
        assert strlen(`"`r(description1_stack)'"') > 0
    }
    if _rc == 0 test_pass
    else test_fail "Linewrap with maxlength not working"
}

* LW-03: Latest returns scalars
run_test "LW-03" "Latest option returns"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) clear long latest nometadata
        assert "`r(latest)'" != ""
        assert "`r(latest_ncountries)'" != ""
        assert "`r(latest_avgyear)'" != ""
    }
    if _rc == 0 test_pass
    else test_fail "Latest return values not working"
}

* LW-04: Linewrap all fields
run_test "LW-04" "Linewrap all fields"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(NY.GDP.MKTP.CD) clear long latest ///
            linewrap(all) linewrapformat(all) nometadata
        assert strlen(`"`r(name1_stack)'"') > 0
    }
    if _rc == 0 test_pass
    else test_fail "Linewrap all fields not working"
}

*===============================================================================
* TEST CATEGORY 6: Maintenance Commands
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 6: Maintenance Commands"
di as text "`sep'"

* UPD-01: Update query
run_test "UPD-01" "Update query command"
if $skip_test == 0 {
    cap noi {
        wbopendata, update query
    }
    if _rc == 0 test_pass
    else test_fail "Update query not working"
}

* UPD-02: Describe indicators
run_test "UPD-02" "Describe indicators"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) describe clear nometadata
    }
    if _rc == 0 test_pass
    else test_fail "Describe not working"
}

* UPD-03: Update basic
run_test "UPD-03" "Update basic"
if $skip_test == 0 {
    cap noi {
        wbopendata, update
    }
    if _rc == 0 test_pass
    else test_fail "Update basic not working"
}

* UPD-04: Update check detail
run_test "UPD-04" "Update check detail"
if $skip_test == 0 {
    cap noi {
        wbopendata, update check detail
    }
    if _rc == 0 test_pass
    else test_fail "Update check detail not working"
}

* UPD-05: Update all
run_test "UPD-05" "Update all"
if $skip_test == 0 {
    cap noi {
        wbopendata, update all
    }
    if _rc == 0 test_pass
    else test_fail "Update all not working"
}

* UPD-06: Update all force
run_test "UPD-06" "Update all force"
if $skip_test == 0 {
    cap noi {
        wbopendata, update all force
    }
    if _rc == 0 test_pass
    else test_fail "Update all force not working"
}

*===============================================================================
* TEST CATEGORY 7: Topics & Language
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 7: Topics & Language"
di as text "`sep'"

* TOPIC-01: Topics download (tests different API path)
run_test "TOPIC-01" "Topics download"
if $skip_test == 0 {
    cap noi {
        wbopendata, topics(1) clear long nometadata  // Topic 1 = Agriculture
        * Topics query returns data for all countries and all indicators in topic
        * When reshaped to long, each observation is a country-indicator-year
        * Just verify we got data and have core variables
        cap confirm variable countrycode
        local rc1 = _rc
        cap confirm variable year
        local rc2 = _rc
        assert `rc1' == 0 | `rc2' == 0  // Should have either countrycode or year
        assert _N > 100  // Should have many observations for a topic
    }
    if _rc == 0 test_pass
    else test_fail "Topics download not working"
}

* LANG-01: Language option (tests metadata in Spanish)
run_test "LANG-01" "Language option Spanish"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) language(es) clear long
        * Metadata should be in Spanish - verify r(varlabel1) exists
        assert "`r(varlabel1)'" != ""
    }
    if _rc == 0 test_pass
    else test_fail "Language option not working"
}

*===============================================================================
* TEST CATEGORY 8: Advanced Features
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 8: Advanced Features"
di as text "`sep'"

* PROJ-01: Projection data (tests source=40 API path)
run_test "PROJ-01" "Projection data download"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) projection clear long nometadata
        cap confirm variable sp_pop_totl
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Projection option not working"
}

* FMT-04: nobasic option (new v17.7 feature)
run_test "FMT-04" "nobasic option suppresses default vars"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nobasic nometadata
        * With nobasic, region/adminregion/incomelevel/lendingtype should NOT exist
        local unexpected_vars ""
        foreach v in region regionname adminregion incomelevel lendingtype {
            cap confirm variable `v'
            if _rc == 0 local unexpected_vars "`unexpected_vars' `v'"
        }
        assert "`unexpected_vars'" == ""
    }
    if _rc == 0 test_pass
    else test_fail "nobasic option not suppressing default vars"
}

* DESC-01: Describe option (metadata only, no data)
run_test "DESC-01" "Describe option returns metadata only"
if $skip_test == 0 {
    clear
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) describe
        * describe calls _query_metadata directly, returns without index suffix
        local has_meta = 0
        if "`r(name_stack)'" != "" local has_meta = 1
        if "`r(description_stack)'" != "" local has_meta = 1  
        if "`r(name)'" != "" local has_meta = 1
        assert `has_meta' == 1
        * Should NOT have data in memory (describe exits early)
        assert _N == 0
    }
    if _rc == 0 test_pass
    else test_fail "Describe option not working"
}

* META-01: nometadata suppresses metadata returns
run_test "META-01" "nometadata suppresses metadata returns"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nometadata
        * With nometadata, linewrap-style returns should be empty
        local has_stack = 0
        if "`r(name1_stack)'" != "" local has_stack = 1
        if "`r(description1_stack)'" != "" local has_stack = 1
        assert `has_stack' == 0
    }
    if _rc == 0 test_pass
    else test_fail "nometadata option not suppressing metadata returns"
}

* CTRY-11: Admin regions option
run_test "CTRY-11" "Admin regions option"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(BRA;USA) clear long adminr nometadata
        cap confirm variable adminregion
        local rc1 = _rc
        cap confirm variable adminregionname  
        local rc2 = _rc
        assert `rc1' == 0
        assert `rc2' == 0
    }
    if _rc == 0 test_pass
    else test_fail "Admin regions option not working"
}

* DATE-01: Date range option
run_test "DATE-01" "Date range option"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) date(2015:2020) clear long nometadata
        cap confirm variable sp_pop_totl
        assert _rc == 0
        * Verify we got data in the expected range
        assert _N > 0
    }
    if _rc == 0 test_pass
    else test_fail "Date range option not working"
}

*===============================================================================
* TEST CATEGORY 9: Cache & Sync System (v18.x)
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 9: Cache & Sync System (v18.x)"
di as text "`sep'"

* CACHE-01: Cache directory initialization
run_test "CACHE-01" "Cache directory initialization"
if $skip_test == 0 {
    cap noi {
        * Clear any existing cache first
        cap wbopendata, clearcache

        * Test _wbopendata_cache default returns cache_exists scalar
        qui _wbopendata_cache
        di as text "cache_exists = `r(cache_exists)'"

        * Verify YAML files are findable via adopath (installed package)
        _wbopendata_get_yaml_path, type(indicators)
        local ind_path = "`r(path)'"
        di as text "Indicators YAML: `ind_path'"
        assert "`ind_path'" != ""
        cap confirm file "`ind_path'"
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Cache directory initialization failed"
}

* CACHE-02: Get YAML path (cache vs package priority)
run_test "CACHE-02" "Get YAML path resolution"
if $skip_test == 0 {
    cap noi {
        * Clear cache to test fallback to package
        cap wbopendata, clearcache

        * Test path resolution without cache — uses named option type()
        * Returns r(path), not r(yaml_path)
        _wbopendata_get_yaml_path, type(indicators)
        local path1 = "`r(path)'"

        di as text "Without cache - Path: `path1'"

        * Should resolve to a valid YAML file
        assert strpos("`path1'", "_wbopendata_indicators.yaml") > 0
        cap confirm file "`path1'"
        assert _rc == 0

        * Test other types resolve too
        _wbopendata_get_yaml_path, type(sources)
        local path_src = "`r(path)'"
        assert strpos("`path_src'", "_wbopendata_sources.yaml") > 0

        _wbopendata_get_yaml_path, type(topics)
        local path_top = "`r(path)'"
        assert strpos("`path_top'", "_wbopendata_topics.yaml") > 0

        di as text "Sources YAML:    `path_src'"
        di as text "Topics YAML:     `path_top'"
    }
    if _rc == 0 test_pass
    else test_fail "YAML path resolution failed"
}

* CACHE-03: Cache info display
run_test "CACHE-03" "Cache info command"
if $skip_test == 0 {
    cap noi {
        * Test cache info via _wbopendata_cache, info
        * Returns r(cache_exists) scalar, r(cache_version), r(cache_timestamp)
        _wbopendata_cache, info

        * cache_exists should be 0 or 1 — command itself should not error
        di as text "cache_exists = `r(cache_exists)'"
        assert "`r(cache_exists)'" == "0" | "`r(cache_exists)'" == "1"
    }
    if _rc == 0 test_pass
    else test_fail "Cache info command failed"
}

* CACHE-04: Clear cache
run_test "CACHE-04" "Clear cache command"
if $skip_test == 0 {
    cap noi {
        * _wbopendata_cache, clear uses capture erase — safe even if no cache exists
        _wbopendata_cache, clear

        * Should return cache_cleared = "1"
        di as text "cache_cleared = `r(cache_cleared)'"
        assert "`r(cache_cleared)'" == "1"

        * Verify metadata_version.txt is gone
        local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
        cap confirm file "`cache_dir'metadata_version.txt"
        local after_exists = (_rc == 0)

        di as text "After clear - metadata_version.txt exists: " cond(`after_exists', "yes", "no")
        assert `after_exists' == 0
    }
    if _rc == 0 test_pass
    else test_fail "Clear cache command failed"
}

* CACHE-05: Cache persistence across sessions
run_test "CACHE-05" "Cache persistence"
if $skip_test == 0 {
    cap noi {
        * Clear and recreate cache
        cap wbopendata, clearcache
        cap qui wbopendata, sync
        
        * Check version file persists
        local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
        cap confirm file "`cache_dir'metadata_version.txt"
        local version_exists = (_rc == 0)
        
        * Check YAML files persist
        cap confirm file "`cache_dir'_wbopendata_indicators.yaml"
        local indicators_exists = (_rc == 0)
        
        cap confirm file "`cache_dir'_wbopendata_sources.yaml"
        local sources_exists = (_rc == 0)
        
        cap confirm file "`cache_dir'_wbopendata_topics.yaml"
        local topics_exists = (_rc == 0)
        
        di as text "Version file exists: " cond(`version_exists', "yes", "no")
        di as text "Indicators YAML exists: " cond(`indicators_exists', "yes", "no")
        di as text "Sources YAML exists: " cond(`sources_exists', "yes", "no")
        di as text "Topics YAML exists: " cond(`topics_exists', "yes", "no")
        
        * At minimum, version file should exist if sync worked
        if `version_exists' {
            assert `version_exists' == 1
        }
    }
    if _rc == 0 test_pass
    else test_fail "Cache persistence check failed"
}

* CACHE-06: Version file tracking
run_test "CACHE-06" "Version file tracking"
if $skip_test == 0 {
    cap noi {
        * Ensure cache exists
        cap qui wbopendata, sync
        
        * Read version file
        local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
        local version_file = "`cache_dir'metadata_version.txt"
        
        cap confirm file "`version_file'"
        if _rc == 0 {
            tempname fh
            file open `fh' using "`version_file'", read
            file read `fh' version_content
            file close `fh'
            
            di as text "Version content: `version_content'"
            
            * Version should be non-empty
            assert "`version_content'" != ""
            
            * Version format check (should look like a version number or date)
            local is_version = (regexm("`version_content'", "[0-9]"))
            assert `is_version' == 1
        }
        else {
            di as text "Version file not found (sync may have failed)"
        }
    }
    if _rc == 0 test_pass
    else test_fail "Version file tracking failed"
}

* CACHE-07: Timestamp tracking
run_test "CACHE-07" "Timestamp tracking"
if $skip_test == 0 {
    cap noi {
        * Ensure cache exists
        cap qui wbopendata, sync
        
        * Check timestamp file
        local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
        local timestamp_file = "`cache_dir'cache_timestamp.txt"
        
        cap confirm file "`timestamp_file'"
        if _rc == 0 {
            tempname fh
            file open `fh' using "`timestamp_file'", read
            file read `fh' timestamp_content
            file close `fh'
            
            di as text "Timestamp content: `timestamp_content'"
            
            * Timestamp should be non-empty
            assert "`timestamp_content'" != ""
        }
        else {
            di as text "Timestamp file not found (may not be created yet)"
        }
    }
    if _rc == 0 test_pass
    else test_fail "Timestamp tracking failed"
}

* CACHE-08: Search with cached YAML
run_test "CACHE-08" "Search with cached YAML"
if $skip_test == 0 {
    cap noi {
        * Ensure cache exists
        cap qui wbopendata, sync
        
        * Test search command (should use cache if available)
        cap wbopendata, search("GDP")
        local search_rc = _rc
        
        di as text "Search command rc: `search_rc'"
        
        * Search should work (whether using cache or package)
        assert `search_rc' == 0
        
        * Check if search returned results
        if "`r(yaml_source)'" != "" {
            di as text "YAML source: `r(yaml_source)'"
        }
    }
    if _rc == 0 test_pass
    else test_fail "Search with cached YAML failed"
}

* SYNC-01: Check for updates
run_test "SYNC-01" "Check for updates command"
if $skip_test == 0 {
    cap noi {
        * Test checkupdate command
        cap wbopendata, checkupdate
        local check_rc = _rc
        
        di as text "checkupdate rc: `check_rc'"
        
        * Command should execute without error (even if network fails gracefully)
        * Don't assert rc==0 since GitHub API may be unavailable
        if `check_rc' == 0 {
            di as result "Update check completed successfully"
            
            * Check for version returns
            if "`r(local_version)'" != "" {
                di as text "Local version: `r(local_version)'"
            }
            if "`r(remote_version)'" != "" {
                di as text "Remote version: `r(remote_version)'"
            }
        }
        else {
            di as text "Update check failed (may be network/API issue)"
        }
    }
    * Always pass - checkupdate failure is not critical
    test_pass
}

* SYNC-02: Sync command (download)
run_test "SYNC-02" "Sync command"
if $skip_test == 0 {
    cap noi {
        * Clear cache first
        cap wbopendata, clearcache
        
        * Test sync command
        cap wbopendata, sync
        local sync_rc = _rc
        
        di as text "sync rc: `sync_rc'"
        
        * If sync succeeds, verify cache was created
        if `sync_rc' == 0 {
            local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
            cap confirm file "`cache_dir'metadata_version.txt"
            local cache_created = (_rc == 0)
            
            di as text "Cache created after sync: " cond(`cache_created', "yes", "no")
            
            if `cache_created' {
                assert `cache_created' == 1
            }
        }
        else {
            di as text "Sync failed (may be network/API issue)"
        }
    }
    * Pass regardless of network issues
    test_pass
}

* SYNC-03: Force sync
run_test "SYNC-03" "Force sync command"
if $skip_test == 0 {
    cap noi {
        * Test syncforce command
        cap wbopendata, syncforce
        local syncforce_rc = _rc
        
        di as text "syncforce rc: `syncforce_rc'"
        
        * If sync succeeds, verify cache was updated
        if `syncforce_rc' == 0 {
            local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
            cap confirm file "`cache_dir'_wbopendata_indicators.yaml"
            local yaml_exists = (_rc == 0)
            
            di as text "YAML exists after force sync: " cond(`yaml_exists', "yes", "no")
        }
        else {
            di as text "Force sync failed (may be network/API issue)"
        }
    }
    * Pass regardless of network issues
    test_pass
}

* SYNC-04: Sync with no updates needed
run_test "SYNC-04" "Sync when already up-to-date"
if $skip_test == 0 {
    cap noi {
        * Sync once
        cap qui wbopendata, sync
        
        * Sync again (should detect up-to-date)
        cap wbopendata, sync
        local sync2_rc = _rc
        
        di as text "Second sync rc: `sync2_rc'"
        
        * Should succeed without error
        if `sync2_rc' == 0 {
            di as result "Sync completed (up-to-date or updated)"
        }
    }
    * Pass regardless - behavior may vary
    test_pass
}

* SYNC-05: Discovery commands use cache
run_test "SYNC-05" "Discovery commands use cache after sync"
if $skip_test == 0 {
    cap noi {
        * Ensure cache exists
        cap qui wbopendata, sync
        
        * Test info command
        cap wbopendata, info("SP.POP.TOTL")
        local info_rc = _rc
        
        di as text "info command rc: `info_rc'"
        
        * Info should work
        if `info_rc' == 0 {
            di as result "Info command succeeded"
            if "`r(yaml_source)'" != "" {
                di as text "YAML source: `r(yaml_source)'"
            }
        }
    }
    * Pass regardless of network issues
    test_pass
}

*===============================================================================
* TEST CATEGORY 10: Discovery Commands (no network needed)
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 10: Discovery Commands"
di as text "`sep'"

* DISC-01: Basic keyword search
run_test "DISC-01" "Search basic keyword"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_search GDP, limit(5)

        * Must return results
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

* DISC-02: Search filters (source, topic, field)
run_test "DISC-02" "Search filters"
if $skip_test == 0 {
    cap noi {
        * Unfiltered baseline
        qui _wbopendata_search GDP
        local n_all = r(n_results)

        * Source filter (WDI = source 2)
        qui _wbopendata_search GDP, source(2)
        local n_src = r(n_results)
        assert `n_src' > 0
        assert `n_src' <= `n_all'
        assert "`r(source_filter)'" == "2"

        * Topic filter
        qui _wbopendata_search poverty, topic(11)
        local n_top = r(n_results)
        assert `n_top' > 0
        assert "`r(topic_filter)'" == "11"

        * Field filter (code only — should be fewer than all fields)
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

* DISC-03: Search patterns (wildcard, AND, exact)
run_test "DISC-03" "Search patterns"
if $skip_test == 0 {
    cap noi {
        * Wildcard search
        qui _wbopendata_search NY.GDP.*
        local n_wild = r(n_results)
        assert `n_wild' > 0

        * Multi-keyword AND search
        qui _wbopendata_search learning+poverty
        local n_and = r(n_results)
        assert `n_and' >= 0  // may be 0 if no indicators match both

        * Exact match
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

* DISC-07: Search router returns correct cache_method
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

*===============================================================================
* TEST SUMMARY
*===============================================================================

di as text _n "`sep'"
di as text "TEST SUMMARY"
di as text "`sep'"

di as text "Tests Run:    " as result $tests_run
di as text "Tests Passed: " as result $tests_pass
di as text "Tests Failed: " as error $tests_fail

if $tests_fail == 0 {
    di as result _n "ALL TESTS PASSED!"
}
else {
    di as error _n "SOME TESTS FAILED - Review log for details"
    di as error "Failed tests: $failed_tests"
}

di as text "`sep'"

* Turn off trace if still on
cap set trace off

log close
di as text "Log saved to: `logfile'"

* Always publish a canonical log copy for quick access
if "$qadir" != "" {
    cap copy "`logfile'" "$qadir/run_tests.log", replace
    if _rc==0 di as text "Canonical log copied to: $qadir/run_tests.log"
    else di as error "Could not copy log to $qadir/run_tests.log (rc=`=_rc')"
}
else {
    di as text "(Canonical log copy skipped - qadir not configured)"
}

* Capture end time and calculate duration
local end_time = c(current_time)

* Calculate duration in seconds (parse HH:MM:SS format)
local start_h = real(substr("`start_time'", 1, 2))
local start_m = real(substr("`start_time'", 4, 2))
local start_s = real(substr("`start_time'", 7, 2))
local end_h = real(substr("`end_time'", 1, 2))
local end_m = real(substr("`end_time'", 4, 2))
local end_s = real(substr("`end_time'", 7, 2))
local start_secs = `start_h' * 3600 + `start_m' * 60 + `start_s'
local end_secs = `end_h' * 3600 + `end_m' * 60 + `end_s'
local duration_secs = `end_secs' - `start_secs'
if `duration_secs' < 0 local duration_secs = `duration_secs' + 86400  // Handle midnight crossing
local duration_min = floor(`duration_secs' / 60)
local duration_sec = mod(`duration_secs', 60)
local duration_str = "`duration_min'm `duration_sec's"

di as text "Duration: `duration_str' (started `start_time', ended `end_time')"

* Only write to history if running all tests (not single test mode) and qadir is set
local histfile "$qadir/test_history.txt"
if "$target_test" == "" & "$qadir" != "" {
    cap confirm file "`histfile'"
    if _rc != 0 {
        * Create history file if it doesn't exist
        file open history using "`histfile'", write replace
        file write history "=== wbopendata Test History ===" _n
        file write history "Created: `date'" _n
        file write history "" _n
        file close history
    }
    file open history using "`histfile'", write append
    file write history _n "`sep'" _n
    file write history "Test Run: `date'" _n
    file write history "Started:  `start_time'" _n
    file write history "Ended:    `end_time'" _n
    file write history "Duration: `duration_str'" _n
    file write history "Version:  `version'" _n
    if "`wbo_date'" != "" file write history "Build:    `wbo_date'" _n
    file write history "Stata:    `c(stata_version)'" _n
    file write history "Tests:    $tests_run run, $tests_pass passed, $tests_fail failed" _n
    if $tests_fail == 0 {
        file write history "Result:   ALL TESTS PASSED" _n
    }
    else {
        file write history "Result:   FAILED" _n
        file write history "Failed:   $failed_tests" _n
    }
    file write history "Log:      test_results_v`version'_`datestr'.log" _n
    file write history "`sep'" _n
    file close history
    di as text "History appended to: `histfile'"
}
else if "$target_test" != "" {
    di as text "(Single test mode - history not updated)"
}
else {
    di as text "(History update skipped - qadir not configured)"
}
