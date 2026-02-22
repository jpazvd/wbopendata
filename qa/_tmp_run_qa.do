* Wrapper to run QA tests in batch mode
* Set repo root AFTER clear all runs inside run_tests.do
* We cd to qa/ so auto-detection works, and also set the global as backup
cd "C:/GitHub/myados/wbopendata-dev/qa"
global wbopendata_repo "C:/GitHub/myados/wbopendata-dev"
do "C:/GitHub/myados/wbopendata-dev/qa/run_tests.do"
