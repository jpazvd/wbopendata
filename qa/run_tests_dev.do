* run_tests_dev.do — Wrapper to run tests against development source files
* Usage: do "C:/path/to/wbopendata-dev/qa/run_tests_dev.do"
*
* This wrapper:
*   1. Auto-detects the repo root by walking up from c(pwd)
*   2. Adds dev source directories to the FRONT of adopath
*      so dev versions override installed versions
*   3. Changes to the qa/ directory so run_tests.do auto-detects the repo
*      and writes logs + test_history.txt to qa/
*   4. Runs the main test suite
*
* Note: adopath and cd survive clear all in run_tests.do.
*       Do NOT set globals here — clear all wipes them before they are read.

* --- Auto-detect repo root (walk up to 3 levels from c(pwd)) ---
local cwd = subinstr(c(pwd), "\", "/", .)
local repo_root ""

local d0 "`cwd'"
local d1 = regexr("`d0'", "/[^/]+$", "")
local d2 = regexr("`d1'", "/[^/]+$", "")
local d3 = regexr("`d2'", "/[^/]+$", "")

foreach d in `"`d0'"' `"`d1'"' `"`d2'"' `"`d3'"' {
    if "`repo_root'" == "" & `"`d'"' != "" {
        cap confirm file `"`d'/src/wbopendata.pkg"'
        if _rc == 0 local repo_root `"`d'"'
    }
}

if "`repo_root'" == "" {
    di as error "ERROR: Could not locate repo root (checked up to 3 levels above c(pwd))."
    di as error "Either cd to the repo folder first, or set global wbopendata_repo before running."
    exit 1
}

di as text "Repo root: `repo_root'"

* Add dev source to FRONT of adopath (++ = prepend)
adopath ++ "`repo_root'/src/w"
adopath ++ "`repo_root'/src/_"
adopath ++ "`repo_root'/src/y"

* cd to qa/ so run_tests.do auto-detects repo root and writes logs there
cd "`repo_root'/qa"

* Run the main test suite (pass through any arguments)
do run_tests.do `0'
