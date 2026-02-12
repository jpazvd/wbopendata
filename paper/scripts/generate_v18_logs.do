/*==============================================================================
    Generate v18.0 Stata Log Snippets for LaTeX Paper

    This do-file generates sjlog snippets for NEW v18.0 features:
    - Discovery commands (sources, search, info)
    - Sync system (sync, sync detail)
    - Cache management (cacheinfo)
    - Updated test excerpts (71 tests / 16 categories)

    Prerequisites:
    - wbopendata v18.0.0 installed (from dev repo)
    - sjlatex package: net install sjlatex, from(http://www.stata-journal.com/production)

    Output: paper/sjlogs/*.log.tex files

    Usage: From the paper/ directory, run:
        do scripts/generate_v18_logs.do

    Author: Joao Pedro Azevedo
    Date: February 2026
==============================================================================*/

clear all
set more off
set linesize 80

* Set paths
local paper_dir "C:/GitHub/myados/wbopendata-dev/paper"
local logs_dir "`paper_dir'/sjlogs"
local qa_dir "C:/GitHub/myados/wbopendata-dev/qa"

* Ensure output directory exists
cap mkdir "`logs_dir'"

* Install from dev repo to ensure v18.0.0
cap noi net install wbopendata, from("C:/GitHub/myados/wbopendata-dev/src") replace

di as text _n "============================================================"
di as text "Generating v18.0 log snippets for LaTeX paper"
di as text "============================================================"

* Verify version
which wbopendata
di as text "Started: " c(current_date) " " c(current_time)

/*------------------------------------------------------------------------------
    Discovery: sources
------------------------------------------------------------------------------*/

di as text _n ">>> Generating: ex_discovery_sources.log.tex"

sjlog using "`logs_dir'/ex_discovery_sources", replace

wbopendata, sources

sjlog close, replace

/*------------------------------------------------------------------------------
    Discovery: search with keyword
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_discovery_search.log.tex"

sjlog using "`logs_dir'/ex_discovery_search", replace

wbopendata, search(poverty) searchtopic(11) limit(10)

sjlog close, replace

/*------------------------------------------------------------------------------
    Discovery: info for a specific indicator
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_discovery_info.log.tex"

sjlog using "`logs_dir'/ex_discovery_info", replace

wbopendata, info(SI.POV.DDAY)

sjlog close, replace

/*------------------------------------------------------------------------------
    Discovery: alltopics
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_discovery_alltopics.log.tex"

sjlog using "`logs_dir'/ex_discovery_alltopics", replace

wbopendata, alltopics

sjlog close, replace

/*------------------------------------------------------------------------------
    Sync: preview (dry run)
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_sync_preview.log.tex"

sjlog using "`logs_dir'/ex_sync_preview", replace

wbopendata, sync

sjlog close, replace

/*------------------------------------------------------------------------------
    Sync: detail
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_sync_detail.log.tex"

sjlog using "`logs_dir'/ex_sync_detail", replace

wbopendata, sync detail

sjlog close, replace

/*------------------------------------------------------------------------------
    Cache: cacheinfo
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_cacheinfo.log.tex"

sjlog using "`logs_dir'/ex_cacheinfo", replace

wbopendata, cacheinfo

sjlog close, replace

/*------------------------------------------------------------------------------
    Cache: checkupdate
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_checkupdate.log.tex"

sjlog using "`logs_dir'/ex_checkupdate", replace

wbopendata, checkupdate

sjlog close, replace

/*------------------------------------------------------------------------------
    Sync preview: replaces deprecated update query (v18.1)
------------------------------------------------------------------------------*/

di as text ">>> Generating: ex_sync.log.tex"

sjlog using "`logs_dir'/ex_sync", replace

wbopendata, sync

sjlog close, replace

/*------------------------------------------------------------------------------
    Summary
------------------------------------------------------------------------------*/

di as text _n "============================================================"
di as text "v18.0 log snippets generated in: `logs_dir'/"
di as text "============================================================"
di as text "Files created/updated:"
di as text "  - ex_discovery_sources.log.tex"
di as text "  - ex_discovery_search.log.tex"
di as text "  - ex_discovery_info.log.tex"
di as text "  - ex_discovery_alltopics.log.tex"
di as text "  - ex_sync_preview.log.tex"
di as text "  - ex_sync_detail.log.tex"
di as text "  - ex_cacheinfo.log.tex"
di as text "  - ex_checkupdate.log.tex"
di as text "  - ex_sync.log.tex"
di as text ""
di as text "Usage in LaTeX paper:"
di as text "  \begin{stlog}"
di as text "  \input{sjlogs/ex_discovery_sources.log.tex}\nullskip"
di as text "  \end{stlog}"
di as text ""
di as text "Finished: " c(current_date) " " c(current_time)

exit
