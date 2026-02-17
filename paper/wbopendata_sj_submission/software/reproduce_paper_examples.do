/*==============================================================================
    Reproduce Paper Examples

    Paper: "Data Provenance in the Age of Automation: Lessons from Fifteen
           Years of Programmatic Access to World Bank Open Data"
    Author: João Pedro Azevedo

    This do-file reproduces all Stata examples shown in the paper.

    Prerequisites:
    - Stata 14 or later
    - wbopendata v18.1 installed: ssc install wbopendata, replace
    - spmap installed (for choropleth example): ssc install spmap, replace
    - worldstat installed (for worldstat examples): ssc install worldstat, replace
    - Internet connection for data downloads

    Usage:
        . do reproduce_paper_examples.do

    Output:
        reproduce_paper_examples.log (text log of all output)
==============================================================================*/

clear all
set more off
set linesize 80

cap log close
log using "reproduce_paper_examples.log", text replace

di as text _n "============================================================"
di as text "Reproducing paper examples"
di as text "Date: " c(current_date) " " c(current_time)
di as text "Stata: " c(stata_version) " " c(machine_type)
di as text "============================================================"

which wbopendata

/*------------------------------------------------------------------------------
    Example 1: Single indicator download (Section 4 / Appendix A.1)
------------------------------------------------------------------------------*/

di as text _n "=== Example 1: Single indicator download ==="

wbopendata, indicator(NY.GDP.MKTP.CD) clear long

/*------------------------------------------------------------------------------
    Example 2: Multiple indicators (Section 4 / Appendix A.1)
------------------------------------------------------------------------------*/

di as text _n "=== Example 2: Multiple indicators ==="

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long

/*------------------------------------------------------------------------------
    Example 3: Latest option (Section 4 / Appendix A.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 3: Latest option ==="

wbopendata, indicator(SI.POV.DDAY) clear long latest
return list

/*------------------------------------------------------------------------------
    Example 4: Linewrap option (Section 4 / Appendix A.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 4a: Linewrap returns ==="

wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 160)
return list

di as text _n "=== Example 4b: Graph using returned metadata ==="

local name1 `"`r(name1_stack)'"'
local name2 `"`r(name2_stack)'"'
local desc1 `"`r(description1_stack)'"'
local desc2 `"`r(description2_stack)'"'
local src1 "`r(sourcecite1)'"
local src2 "`r(sourcecite2)'"
local subtitle "`r(latest)'"

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
        "{bf:Y (Mortality):} `src2'", size(vsmall)) name(linewrap, replace)

/*------------------------------------------------------------------------------
    Example 5: Choropleth map (Section 5 / Appendix A.3)
    Requires: spmap, world-c.dta, world-d.dta
------------------------------------------------------------------------------*/

di as text _n "=== Example 5: Choropleth map ==="

cap which spmap
if _rc == 0 {
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
    }
    else {
        di as text "Shapefiles not found. Skipping choropleth map."
    }
}
else {
    di as text "spmap not installed. Skipping choropleth map."
    di as text "Install with: ssc install spmap, replace"
}

/*------------------------------------------------------------------------------
    Example 6: Scatter plot - Poverty vs GDP (Section 5 / Appendix A.3)
------------------------------------------------------------------------------*/

di as text _n "=== Example 6: Scatter plot - Poverty vs GDP ==="

wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest nometadata
local time "$S_FNDATE"

set scheme sj
graph twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd if regionname == "Aggregates", ///
        msize(*.8) mlabel(countryname) mlabsize(*.8) mlabangle(25)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd), ///
        legend(off) ///
        ytitle("Poverty headcount ratio at $2.15 a day", size(small)) ///
        xtitle("GDP per capita, PPP (constant intl $)", size(small)) ///
        note("Source: WDI (latest as of `time')") name(scatter, replace)

/*------------------------------------------------------------------------------
    Example 7: worldstat - Regional and global maps (Appendix A.4)
    Requires: worldstat
------------------------------------------------------------------------------*/

di as text _n "=== Example 7: worldstat maps ==="

cap which worldstat
if _rc == 0 {
    cap noi worldstat Africa, stat(GDP) year(2009) cname
    cap noi worldstat world, stat(FERT) fcolor(Pastel2)
}
else {
    di as text "worldstat not installed. Skipping map examples."
    di as text "Install with: ssc install worldstat, replace"
}

/*------------------------------------------------------------------------------
    Example 8: Missing/invalid indicator (Section 6 / Appendix B.1)
------------------------------------------------------------------------------*/

di as text _n "=== Example 8: Missing indicator ==="

cap noi wbopendata, language(en) indicator(platypus) long clear
di as text "Return code (expected nonzero): " _rc

/*------------------------------------------------------------------------------
    Example 9: Deprecated indicator (Section 6 / Appendix B.1)
------------------------------------------------------------------------------*/

di as text _n "=== Example 9: Deprecated indicator ==="

cap noi wbopendata, language(en) indicator(AG.AGR.TRAC.NO) clear
di as text "Return code (expected r(23) archive notice): " _rc

/*------------------------------------------------------------------------------
    Example 10: Discovery - sources (Section 4 / Appendix B.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 10: Discovery - sources ==="

wbopendata, sources

/*------------------------------------------------------------------------------
    Example 11: Discovery - search (Section 4 / Appendix B.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 11: Discovery - search ==="

wbopendata, search(poverty) searchtopic(11) limit(10)

/*------------------------------------------------------------------------------
    Example 12: Discovery - info (Section 4 / Appendix B.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 12: Discovery - info ==="

wbopendata, info(SI.POV.DDAY)

/*------------------------------------------------------------------------------
    Example 13: Discovery - alltopics (Section 4 / Appendix B.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 13: Discovery - alltopics ==="

wbopendata, alltopics

/*------------------------------------------------------------------------------
    Example 14: Sync preview and detail (Section 4 / Appendix B.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 14: Sync preview ==="

wbopendata, sync

di as text _n "=== Example 14b: Sync detail ==="

wbopendata, sync detail

/*------------------------------------------------------------------------------
    Example 15: Check for updates (Section 4 / Appendix B.2)
------------------------------------------------------------------------------*/

di as text _n "=== Example 15: Check for updates ==="

wbopendata, checkupdate

/*------------------------------------------------------------------------------
    Summary
------------------------------------------------------------------------------*/

di as text _n "============================================================"
di as text "All paper examples reproduced successfully."
di as text "Date: " c(current_date) " " c(current_time)
di as text "============================================================"

log close
exit
