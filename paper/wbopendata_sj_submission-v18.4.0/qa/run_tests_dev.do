* run_tests_dev.do — Wrapper to run tests against development source files
* Usage: do "C:/GitHub/myados/wbopendata-dev/qa/run_tests_dev.do"
*
* This wrapper:
*   1. Adds dev source directories to the FRONT of adopath
*      so dev versions override installed versions
*   2. Changes to the qa/ directory (run_tests.do auto-detects repo from cwd)
*   3. Runs the main test suite
*
* Note: adopath and cd survive clear all in run_tests.do.
*       Do NOT set globals here — clear all wipes them before they are read.

* Resolve repo root from current working directory (expects qa/)
local cwd = subinstr(c(pwd), "\", "/", .)
local repo_root "`cwd'"
if regexm("`cwd'", "(.+)[/\\]qa[/\\]?$") {
	local repo_root = regexs(1)
}

* Add dev source to FRONT of adopath (++ = prepend)
* This ensures dev .ado files are found before installed ones
adopath ++ "`repo_root'/src/w"
adopath ++ "`repo_root'/src/_"
adopath ++ "`repo_root'/src/y"

* Change to qa/ directory so run_tests.do auto-detects repo root
* and writes logs + test_history.txt to qa/
cd "`repo_root'/qa"

* Run the main test suite (pass through any arguments)
do run_tests.do `0'
