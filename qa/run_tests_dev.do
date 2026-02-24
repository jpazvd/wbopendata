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

* Add dev source to FRONT of adopath (++ = prepend)
* This ensures dev .ado files are found before installed ones
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/w"
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/_"
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/y"

* Change to qa/ directory so run_tests.do auto-detects repo root
* and writes logs + test_history.txt to qa/
cd "C:/GitHub/myados/wbopendata-dev/qa"

* Run the main test suite (pass through any arguments)
do run_tests.do `0'
