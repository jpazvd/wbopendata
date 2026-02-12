* Generate remaining v18.0 sjlogs (cacheinfo, checkupdate, update)
* Wraps each in cap noi to prevent one failure from stopping the rest

clear all
set more off
set linesize 80

local logs "C:/GitHub/myados/wbopendata-dev/paper/sjlogs"

which wbopendata

* === Cache: cacheinfo (may not exist in all versions) ===
di _n ">>> ex_cacheinfo"
cap noi {
    sjlog using "`logs'/ex_cacheinfo", replace
    wbopendata, cacheinfo
    sjlog close, replace
}
if _rc != 0 {
    di as text "  cacheinfo not available (rc=`=_rc')"
    cap sjlog close
}

* === Cache: checkupdate ===
di ">>> ex_checkupdate"
cap noi {
    sjlog using "`logs'/ex_checkupdate", replace
    wbopendata, checkupdate
    sjlog close, replace
}
if _rc != 0 {
    di as text "  checkupdate not available (rc=`=_rc')"
    cap sjlog close
}

* === Sync preview: replaces deprecated update query (v18.1) ===
di ">>> ex_sync"
sjlog using "`logs'/ex_sync", replace
wbopendata, sync
sjlog close, replace

di _n "=== Remaining sjlogs generated ==="
exit
