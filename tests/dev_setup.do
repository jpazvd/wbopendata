*! version 1.0.0 07Feb2026
* dev_setup.do - Standardized Stata dev environment for batch runs

version 14.0

* Fail fast in batch
capture noisily {
    set more off
    set varabbrev off
    set linesize 255
    set maxvar 32767
    set matsize 11000
    set rmsg off
}

* Resolve repo root
local repo_root "C:/GitHub/myados"
cap cd "`repo_root'"

* Ensure wbopendata-dev is on adopath (highest priority)
local srcpath "C:/GitHub/myados/wbopendata-dev/src"
cap adopath - "`c(sysdir_plus)'"
cap adopath - "`c(sysdir_plus)'_"
cap adopath - "`c(sysdir_plus)'/"
cap adopath - "`c(sysdir_plus)'_/"
cap adopath ++ "`srcpath'/_"
cap adopath ++ "`srcpath'/w"
cap adopath ++ "`srcpath'/y"

* Default personal dir (optional override)
* sysdir set PERSONAL "C:/ado/personal/"

* Log environment details (caller can override log destination)
noi di as text "Stata version: `c(stata_version)'"
noi di as text "adopath:"
noi adopath
