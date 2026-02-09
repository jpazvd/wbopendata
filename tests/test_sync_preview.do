*******************************************************************************
* test_sync_preview.do
* Test the sync preview functionality
*******************************************************************************

clear all
set more off

* Ensure we're using dev source
adopath ++ "C:/GitHub/myados/wbopendata-dev/src"

* Force reload
program drop _all
discard

di as text "{hline 70}"
di as result "TEST 1: wbopendata, syncdryrun (preview only, no sync)"
di as text "{hline 70}"
di ""

wbopendata, syncdryrun

di ""
di as text "{hline 70}"
di as result "TEST 1 COMPLETE: syncdryrun showed preview without syncing"
di as text "{hline 70}"
