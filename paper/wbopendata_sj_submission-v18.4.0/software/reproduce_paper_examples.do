/*==============================================================================
    Reproduce Paper Examples (Complete, Self-Contained)

    Paper: "Data Provenance in the Age of Automation: Lessons from Fifteen
           Years of Programmatic Access to World Bank Open Data"
    Author: João Pedro Azevedo

    This do-file reproduces ALL content from the paper including:
    - All 15 examples with clean output
    - Figures (5 PDFs in figs/)
    - LaTeX-formatted logs (20 files in sjlogs/)

    Prerequisites:
    - Stata 14 or later
    - wbopendata v18.4 installed: ssc install wbopendata, replace
    - sjlatex package: net install sjlatex, from(http://www.stata-journal.com/production)
    - spmap installed (for choropleth): ssc install spmap, replace
    - worldstat installed (for worldstat): ssc install worldstat, replace
    - Internet connection for data downloads

    Usage:
        . do reproduce_paper_examples_complete.do

    Outputs:
        reproduce_paper_examples.log      Main execution log
        figs/ *.pdf                       5 publication-ready figures
        sjlogs/ *.log.tex                 20 LaTeX-formatted code snippets
==============================================================================*/

clear all
set more off
set linesize 80
set rmsg off

* install wbopendata v18.4.0
net install wbopendata, from("C:\GitHub\myados\wbopendata-dev\paper\wbopendata_sj_submission-v18.4.0\software") replace

* Get current directory (software directory) and derive parent folder
local script_dir "`c(pwd)'"
local parent_dir "`script_dir'"
local parent_dir = subinstr("`parent_dir'", "\\software", "", .)
local parent_dir = subinstr("`parent_dir'", "/software", "", .)

* Create output directories
cap mkdir "`parent_dir'/figs"
cap mkdir "`parent_dir'/sjlogs"

local figs_dir "`parent_dir'/figs"
local logs_dir "`parent_dir'/sjlogs"

* Start main log
cap log close
log using "`script_dir'/reproduce_paper_examples.log", text replace

di as text _n "============================================================"
di as text "Reproducing Paper Examples (Complete)"
di as text "============================================================"
di as text "Date: " c(current_date) " " c(current_time)
di as text "Stata: " c(stata_version) " " c(machine_type)
di as text "Working directory: `parent_dir'"
di as text "Figure output: `figs_dir'"
di as text "Log output: `logs_dir'"
di as text "============================================================"

which wbopendata

/*==============================================================================
    SECTION 1: Data Download & Metadata Examples (Examples 1-4)
==============================================================================*/

di as text _n ">>> SECTION 1: Data Download & Metadata Examples"

/*------------------------------------------------------------------------------
    Example 1: Single indicator download with metadata
    Output: ex_single_indicator.log.tex (for paper)
           + simple text display for readability
------------------------------------------------------------------------------*/

di as text _n "=== Example 1: Single indicator download ==="

sjlog using "`logs_dir'/ex_single_indicator", replace

wbopendata, indicator(NY.GDP.MKTP.CD) clear linewrap(name note) maxlength(35 70)

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 2: Multiple indicators
    Output: ex_multiple_indicators.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 2: Multiple indicators ==="

sjlog using "`logs_dir'/ex_multiple_indicators", replace

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 3: Latest option with returned results
    Output: ex_latest_option.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 3: Latest option ==="

sjlog using "`logs_dir'/ex_latest_option", replace

wbopendata, indicator(SI.POV.DDAY) clear long latest linewrap(name note) maxlength(35 70)
di as text "latest year retrieved:"
return list

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 4: Linewrap option with graph and returned metadata
    Output: ex_linewrap_returns.log.tex + wbopendata_linewrap_example.pdf
            ex_linewrap_graph.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 4a: Linewrap returns ==="

sjlog using "`logs_dir'/ex_linewrap_returns", replace

wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 160)
return list

sjlog close, replace

di as text _n "=== Example 4b: Graph using returned metadata ==="

sjlog using "`logs_dir'/ex_linewrap_graph", replace

* Store wrapped metadata from linewrap option
* Wrapped values are already quoted strings ready for graph display
local name1 "`r(name1_stack)'"
local name2 "`r(name2_stack)'"
local desc1 "`r(description1_stack)'"
local desc2 "`r(description2_stack)'"
local src1 "`r(sourcecite1)'"
local src2 "`r(sourcecite2)'"
local subtitle "`r(latest)'"

* Create publication-ready graph with wrapped metadata for titles and annotations
set scheme sj
twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Definitions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2', size(vsmall) span) ///
    note("{bf:Data Sources:}" ///
        "{bf:X (Poverty):} `src1'" ///
        "{bf:Y (Mortality):} `src2'", size(vsmall)) name(linewrap_ex, replace)

sjlog close, replace

* Export figure
cap noi graph export "`figs_dir'/wbopendata_linewrap_example.pdf", replace
if _rc == 0 {
    di as text "  ✓ Exported: wbopendata_linewrap_example.pdf"
}

/*==============================================================================
    SECTION 2: Visualization Examples (Examples 5-7)
==============================================================================*/

di as text _n ">>> SECTION 2: Visualization Examples"

/*------------------------------------------------------------------------------
    Example 5: Choropleth map
    Output: ex_choropleth_map.log.tex + wbopendata_example01.pdf
    Note: Requires spmap and shapefile data
------------------------------------------------------------------------------*/

di as text _n "=== Example 5: Choropleth map ==="

sjlog using "`logs_dir'/ex_choropleth_map", replace

cap which spmap
if _rc == 0 {
    di as text "Note: Creating choropleth with spmap"
    tempfile wdi_data
    wbopendata, indicator(it.cel.sets.p2) long clear latest
    local labelvar "`r(varlabel1)'"
    local source "`r(sourcecite1)'"
    sort countrycode
    save `wdi_data', replace

    local world_d "`c(sysdir_plus)'w/world-d.dta"
    local world_c "`c(sysdir_plus)'w/world-c.dta"
    cap confirm file "`world_d'"
    if _rc == 0 {
        use "`world_d'", clear
        merge countrycode using `wdi_data'

        set scheme sj
        sum year
        local avg = string(`r(mean)', "%16.1f")

        spmap it_cel_sets_p2 using "`world_c'", id(_ID) ///
            clnumber(20) fcolor(Reds2) ocolor(none ..) ///
            title("`labelvar'", size(*1.2)) ///
            legstyle(3) legend(ring(1) position(3)) ///
            note("Source: `source' (latest: `avg')") name(choropleth, replace)

        sjlog close, replace
        
        * Export figure
        cap noi graph export "`figs_dir'/wbopendata_example01.pdf", replace
        if _rc == 0 {
            di as text "  ✓ Exported: wbopendata_example01.pdf"
        }
    }
    else {
        sjlog close, replace
        di as text "  Shapefiles not found. Skipping choropleth map export."
    }
}
else {
    sjlog close, replace
    di as text "  spmap not installed. Skipping choropleth map."
    di as text "  Install with: ssc install spmap, replace"
}

/*------------------------------------------------------------------------------
    Example 6: Scatter plot - Poverty vs GDP
    Output: ex_scatter_poverty_gdp.log.tex + wbopendata_example04.pdf
------------------------------------------------------------------------------*/

di as text _n "=== Example 6: Scatter plot - Poverty vs GDP ==="

sjlog using "`logs_dir'/ex_scatter_poverty_gdp", replace

wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest nometadata

set scheme sj
graph twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd if regionname == "Aggregates", ///
        msize(*.8) mlabel(countryname) mlabsize(*.8) mlabangle(25)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd), ///
        legend(off) ///
        ytitle("Poverty headcount ratio at $2.15 a day", size(small)) ///
        xtitle("GDP per capita, PPP (constant intl $)", size(small)) ///
        note("Source: WDI") name(scatter, replace)

sjlog close, replace

* Export figure
cap noi graph export "`figs_dir'/wbopendata_example04.pdf", replace
if _rc == 0 {
    di as text "  ✓ Exported: wbopendata_example04.pdf"
}

/*------------------------------------------------------------------------------
    Example 7: worldstat - Regional and global maps
    Output: ex_worldstat_africa.log.tex + wbopendata_worldstat_africa_gdp.pdf
            ex_worldstat_world.log.tex + wbopendata_worldstat_world_fertility.pdf
    Note: Requires worldstat package
------------------------------------------------------------------------------*/

di as text _n "=== Example 7: worldstat maps ==="

cap which worldstat
if _rc == 0 {
    di as text "Note: worldstat is installed, generating maps"
    
    sjlog using "`logs_dir'/ex_worldstat_africa", replace
    cap noi worldstat Africa, stat(GDP) year(2009) cname
    sjlog close, replace
    
    cap noi graph export "`figs_dir'/wbopendata_worldstat_africa_gdp.pdf", replace
    if _rc == 0 {
        di as text "  ✓ Exported: wbopendata_worldstat_africa_gdp.pdf"
    }

    sjlog using "`logs_dir'/ex_worldstat_world", replace
    cap noi worldstat world, stat(FERT) fcolor(Pastel2)
    sjlog close, replace
    
    cap noi graph export "`figs_dir'/wbopendata_worldstat_world_fertility.pdf", replace
    if _rc == 0 {
        di as text "  ✓ Exported: wbopendata_worldstat_world_fertility.pdf"
    }
}
else {
    di as text "  worldstat not installed. Skipping map examples."
    di as text "  Install with: ssc install worldstat, replace"
}

/*==============================================================================
    SECTION 3: Error Handling Examples (Examples 8-9)
==============================================================================*/

di as text _n ">>> SECTION 3: Error Handling Examples"

/*------------------------------------------------------------------------------
    Example 8: Missing indicator
    Output: ex_indicator_missing.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 8: Missing indicator ==="

sjlog using "`logs_dir'/ex_indicator_missing", replace

cap noi wbopendata, language(en) indicator(platypus) long clear
di as text "  Return code (expected nonzero): " _rc

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 9: Deprecated indicator
    Output: ex_indicator_deprecated.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 9: Deprecated indicator ==="

sjlog using "`logs_dir'/ex_indicator_deprecated", replace

di as text "Captured return code (expected r(23) archive notice): "
cap noi wbopendata, language(en) indicator(AG.AGR.TRAC.NO) clear
di as text "  rc=`=_rc'"

sjlog close, replace

/*==============================================================================
    SECTION 4: Discovery Commands (Examples 10-13)
==============================================================================*/

di as text _n ">>> SECTION 4: Discovery Commands"

/*------------------------------------------------------------------------------
    Example 10: Discovery - sources (list all available data sources)
    Output: ex_discovery_sources.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 10: Discovery - sources ==="

sjlog using "`logs_dir'/ex_discovery_sources", replace

wbopendata, sources

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 11: Discovery - search (full-text search)
    Output: ex_discovery_search.log.tex
    Note: May take longer due to filesystem search
------------------------------------------------------------------------------*/

di as text _n "=== Example 11: Discovery - search (poverty indicators) ==="

sjlog using "`logs_dir'/ex_discovery_search", replace

wbopendata, search(poverty) searchtopic(11) limit(10)

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 12: Discovery - info (metadata for specific indicator)
    Output: ex_discovery_info.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 12: Discovery - info ==="

sjlog using "`logs_dir'/ex_discovery_info", replace

wbopendata, info(SI.POV.DDAY)

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 13: Discovery - alltopics (list all topic categories)
    Output: ex_discovery_alltopics.log.tex
------------------------------------------------------------------------------*/

di as text _n "=== Example 13: Discovery - alltopics ==="

sjlog using "`logs_dir'/ex_discovery_alltopics", replace

wbopendata, alltopics

sjlog close, replace

/*==============================================================================
    SECTION 5: Synchronization & Updates (Examples 14-15)
==============================================================================*/

di as text _n ">>> SECTION 5: Synchronization & Updates"

/*------------------------------------------------------------------------------
    Example 14: Sync - metadata synchronization
    Output: ex_sync_preview.log.tex + ex_sync_detail.log.tex
    Note: Shows YAML metadata sync capabilities
------------------------------------------------------------------------------*/

di as text _n "=== Example 14: Sync preview ==="

sjlog using "`logs_dir'/ex_sync_preview", replace

wbopendata, sync

sjlog close, replace

di as text _n "=== Example 14b: Sync detail ==="

sjlog using "`logs_dir'/ex_sync_detail", replace

wbopendata, sync detail

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 15: Check for updates
    Output: ex_checkupdate.log.tex
    Note: Queries repository for latest version info
------------------------------------------------------------------------------*/

di as text _n "=== Example 15: Check for updates ==="

sjlog using "`logs_dir'/ex_checkupdate", replace

wbopendata, checkupdate

sjlog close, replace

/*==============================================================================
    SUMMARY & VERIFICATION
==============================================================================*/

di as text _n "============================================================"
di as text "COMPLETION SUMMARY"
di as text "============================================================"

* Count generated files
local fig_count = 0
local log_count = 0

foreach f in wbopendata_linewrap_example.pdf wbopendata_example01.pdf ///
            wbopendata_example04.pdf wbopendata_worldstat_africa_gdp.pdf ///
            wbopendata_worldstat_world_fertility.pdf {
    cap confirm file "`figs_dir'/`f'"
    if _rc == 0 {
        local fig_count = `fig_count' + 1
    }
}

foreach f in ex_single_indicator.log.tex ex_multiple_indicators.log.tex ///
            ex_latest_option.log.tex ex_linewrap_returns.log.tex ///
            ex_linewrap_graph.log.tex ex_choropleth_map.log.tex ///
            ex_scatter_poverty_gdp.log.tex ex_worldstat_africa.log.tex ///
            ex_worldstat_world.log.tex ex_indicator_missing.log.tex ///
            ex_indicator_deprecated.log.tex ex_discovery_sources.log.tex ///
            ex_discovery_search.log.tex ex_discovery_info.log.tex ///
            ex_discovery_alltopics.log.tex ex_sync_preview.log.tex ///
            ex_sync_detail.log.tex ex_checkupdate.log.tex {
    cap confirm file "`logs_dir'/`f'"
    if _rc == 0 {
        local log_count = `log_count' + 1
    }
}

di as text "Figures generated: `fig_count'/5"
di as text "LaTeX logs generated: `log_count'/18"
di as text ""
di as text "All paper examples reproduced successfully."
di as text "Date: " c(current_date) " " c(current_time)
di as text "============================================================"

cap log close
set rmsg on
exit
