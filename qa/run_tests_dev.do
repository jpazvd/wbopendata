* run_tests_dev.do — Wrapper to run tests against development source files
* Usage: do "C:/GitHub/myados/wbopendata-dev/qa/run_tests_dev.do"
*
* This wrapper:
*   1. Sets the repo path global
*   2. Adds dev source directories to the FRONT of adopath
*      so dev versions override installed versions
*   3. Changes to the qa/ directory
*   4. Runs the main test suite

* Set repo root
global wbopendata_repo "C:/GitHub/myados/wbopendata-dev"

* Add dev source to FRONT of adopath (++ = prepend)
* This ensures dev .ado files are found before installed ones
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/w"
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/_"
adopath ++ "C:/GitHub/myados/wbopendata-dev/src/y"

* Change to qa/ directory so relative paths work
cd "C:/GitHub/myados/wbopendata-dev/qa"

* Run the main test suite (pass through any arguments)
do run_tests.do `0'
