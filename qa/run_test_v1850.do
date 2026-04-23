* run_test_v1850.do — Run v18.5.0 pagination tests against dev source
*
* Usage:
*   do "C:/path/to/wbopendata-dev/qa/run_test_v1850.do"
*   do "C:/path/to/wbopendata-dev/qa/run_test_v1850.do" verbose
*   do "C:/path/to/wbopendata-dev/qa/run_test_v1850.do" PAGE-06

* Auto-detect repo root (same logic as run_tests_dev.do)
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
    di as error "ERROR: Could not locate repo root."
    exit 1
}

di as text "Repo root: `repo_root'"

adopath ++ "`repo_root'/src/w"
adopath ++ "`repo_root'/src/_"
adopath ++ "`repo_root'/src/y"

cd "`repo_root'"

do qa/test_v1850_pagination.do `0'
