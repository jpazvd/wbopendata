* Generate v18.0 sjlogs for paper
* Run from: any directory
* Author: Joao Pedro Azevedo, February 2026

clear all
set more off
set linesize 80

local logs "C:/GitHub/myados/wbopendata-dev/paper/sjlogs"

cap noi net install wbopendata, from("C:/GitHub/myados/wbopendata-dev/src") replace
which wbopendata

* === Discovery: sources ===
di _n ">>> ex_discovery_sources"
sjlog using "`logs'/ex_discovery_sources", replace
wbopendata, sources
sjlog close, replace

* === Discovery: search ===
di ">>> ex_discovery_search"
sjlog using "`logs'/ex_discovery_search", replace
wbopendata, search(poverty) searchtopic(11) limit(10)
sjlog close, replace

* === Discovery: info ===
di ">>> ex_discovery_info"
sjlog using "`logs'/ex_discovery_info", replace
wbopendata, info(SI.POV.DDAY)
sjlog close, replace

* === Discovery: alltopics ===
di ">>> ex_discovery_alltopics"
sjlog using "`logs'/ex_discovery_alltopics", replace
wbopendata, alltopics
sjlog close, replace

* === Sync: preview ===
di ">>> ex_sync_preview"
sjlog using "`logs'/ex_sync_preview", replace
wbopendata, sync
sjlog close, replace

* === Sync: detail ===
di ">>> ex_sync_detail"
sjlog using "`logs'/ex_sync_detail", replace
wbopendata, sync detail
sjlog close, replace

* === Cache: cacheinfo ===
di ">>> ex_cacheinfo"
sjlog using "`logs'/ex_cacheinfo", replace
wbopendata, cacheinfo
sjlog close, replace

* === Cache: checkupdate ===
di ">>> ex_checkupdate"
sjlog using "`logs'/ex_checkupdate", replace
wbopendata, checkupdate
sjlog close, replace

* === Sync preview: replaces deprecated update query (v18.1) ===
di ">>> ex_sync"
sjlog using "`logs'/ex_sync", replace
wbopendata, sync
sjlog close, replace

di _n "=== All v18.0 sjlogs generated ==="
exit
