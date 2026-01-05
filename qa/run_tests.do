/*******************************************************************************
* wbopendata Automated Test Suite
* Version: 17.4.2
* Date: January 2026
* 
* Usage: 
*   do run_tests.do              - Run all tests
*   do run_tests.do DL-01        - Run only test DL-01
*   do run_tests.do DL-01 verbose - Run DL-01 with trace on (debug mode)
*   do run_tests.do verbose      - Run all tests with trace on
*   do run_tests.do list         - List all available tests
*
* Test Categories:
*   1 - Basic Downloads (DL-01 to DL-05)
*   2 - Format Options (FMT-01 to FMT-03)
*   3 - Country Metadata (CTRY-01 to CTRY-10)
*   4 - Regression Tests (REG-33, REG-45, REG-46, REG-51)
*   5 - Graph Metadata (LW-01 to LW-04)
*   6 - Maintenance Commands (UPD-01, UPD-02)
* 
* This script runs through core functionality tests and reports results.
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

* Parse arguments
foreach arg of local args {
    if upper("`arg'") == "VERBOSE" {
        local verbose 1
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
        di as text "  Graph Metadata (v17.4):"
        di as text "  LW-01    Linewrap option basic"
        di as text "  LW-02    Linewrap with maxlength"
        di as text "  LW-03    Latest returns scalars"
        di as text "  LW-04    Linewrap all fields"
        di as text ""
        di as text "  Maintenance Commands:"
        di as text "  UPD-01   Update query command"
        di as text "  UPD-02   Describe indicators"
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

* Global to control which test to run (empty = all tests)
global target_test "`target_test'"
global verbose `verbose'

* Add development path for wbopendata
adopath ++ "c:/GitHub/myados/wbopendata"

* Test configuration
local version "17.4.2"
local date = c(current_date)
local time = c(current_time)

* Ensure logs are saved in qa folder (same location as this do-file)
local qadir "c:/GitHub/myados/wbopendata/qa"
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
if "`target_test'" != "" {
    di as text "Target:  `target_test'"
}
if `verbose' == 1 {
    di as text "Mode:    VERBOSE (trace on)"
}
di as text "Date: `date' `time'"
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

*===============================================================================
* TEST CATEGORY 0: Environment Checks
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 0: Environment Checks"
di as text "`sep'"

* ENV-01: Verify wbopendata version matches repo
run_test "ENV-01" "wbopendata version matches repo"
if $skip_test == 0 {
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
        
        * Read version line from repo file
        local repo_path "c:/GitHub/myados/wbopendata/src/w/wbopendata.ado"
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

* ENV-02: Verify all ado files match repo (distinguishes source vs auto-generated)
run_test "ENV-02" "Ado files sync status"
if $skip_test == 0 {
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
            
            local repo_path "c:/GitHub/myados/wbopendata/src/_/`f'.ado"
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
            
            local repo_path "c:/GitHub/myados/wbopendata/src/_/`f'.ado"
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

* ENV-03: Verify wbopendata.pkg lists all src ado files (dynamic scan)
run_test "ENV-03" "wbopendata.pkg matches src directories"
if $skip_test == 0 {
    cap noi {
        * Read wbopendata.pkg and extract F lines into a string
        local pkg_path "c:/GitHub/myados/wbopendata/wbopendata.pkg"
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
        local repo_root "c:/GitHub/myados/wbopendata"
        local missing_from_pkg ""
        local src_subdirs "_ w"
        
        foreach subdir of local src_subdirs {
            local src_path "`repo_root'/src/`subdir'"
            
            * Get list of ado files in this directory
            local ado_files : dir "`src_path'" files "*.ado", respectcase
            
            foreach f of local ado_files {
                * Build expected path as it should appear in pkg
                local expected_path "src/`subdir'/`f'"
                
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
            local src_path "`repo_root'/src/`subdir'"
            cap confirm file "`src_path'/."
            if _rc == 0 {
                foreach ext of local other_exts {
                    local files : dir "`src_path'" files "*.`ext'", respectcase
                    foreach f of local files {
                        local expected_path "src/`subdir'/`f'"
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

* ENV-04: Verify all pkg files exist in repo
run_test "ENV-04" "All pkg files exist in repo"
if $skip_test == 0 {
    cap noi {
        * Read wbopendata.pkg and verify each F line file exists
        local pkg_path "c:/GitHub/myados/wbopendata/wbopendata.pkg"
        local repo_root "c:/GitHub/myados/wbopendata"
        local missing_files ""
        
        tempname fh
        file open `fh' using "`pkg_path'", read text
        file read `fh' line
        while r(eof) == 0 {
            if substr("`line'", 1, 2) == "F " {
                local filepath = substr("`line'", 3, .)
                local fullpath "`repo_root'/`filepath'"
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
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "BRA"
        "CHN"
        end
        wbopendata, match(countrycode)
        cap confirm variable regionname
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Match basic not working"
}

* CTRY-02: Match with full
run_test "CTRY-02" "Match with full option"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "BRA"
        end
        wbopendata, match(countrycode) full
        cap confirm variable longitude
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Match full not working"
}

* CTRY-03: Full country metadata with indicator
run_test "CTRY-03" "Full country metadata with indicator"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(NY.GDP.PCAP.PP.KD) country(BRA;USA;CHN) clear long full nometadata
        cap confirm variable longitude
        assert _rc == 0
        cap confirm variable latitude
        assert _rc == 0
        cap confirm variable capital
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Full country metadata not working"
}

* CTRY-04: ISO option
run_test "CTRY-04" "ISO 2-digit codes option"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(BRA) clear long iso nometadata
        cap confirm variable region_iso2
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "ISO option not working"
}

* CTRY-05: Geographic option (GEO group)
run_test "CTRY-05" "Geographic GEO group option"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "BRA"
        "CHN"
        end
        wbopendata, match(countrycode) geo
        cap confirm variable capital
        assert _rc == 0
        cap confirm variable latitude
        assert _rc == 0
        cap confirm variable longitude
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "GEO group option not working"
}

* CTRY-06: Capital option (individual)
run_test "CTRY-06" "Capital geographic option"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "BRA"
        end
        wbopendata, match(countrycode) capital
        cap confirm variable capital
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Capital option not working"
}

* CTRY-07: Latitude and longitude options
run_test "CTRY-07" "Latitude and longitude options"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "CHN"
        end
        wbopendata, match(countrycode) latitude longitude
        cap confirm variable latitude
        assert _rc == 0
        cap confirm variable longitude
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Latitude/longitude options not working"
}

* CTRY-08: Regions group option
run_test "CTRY-08" "Regions group option"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "BRA"
        end
        wbopendata, match(countrycode) regions
        cap confirm variable regionname
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Regions option not working"
}

* CTRY-09: Income and Lending options
run_test "CTRY-09" "Income and Lending group options"
if $skip_test == 0 {
    cap noi {
        clear
        input str3 countrycode
        "USA"
        "BRA"
        end
        wbopendata, match(countrycode) income lending
        cap confirm variable incomelevel
        assert _rc == 0
        cap confirm variable lendingtype
        assert _rc == 0
    }
    if _rc == 0 test_pass
    else test_fail "Income/Lending options not working"
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
        assert "`r(name1_stack)'" != ""
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
        assert "`r(name1_stack)'" != ""
        assert "`r(description1_stack)'" != ""
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
        assert "`r(name1_stack)'" != ""
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

* Only write to history if running all tests (not single test mode)
if "$target_test" == "" {
    file open history using "`histfile'", write append
    file write history _n "`sep'" _n
    file write history "Test Run: `date' `time'" _n
    file write history "Version:  `version'" _n
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
else {
    di as text "(Single test mode - history not updated)"
}
