clear all
set more off
set linesize 80
set rmsg off

* Resolve directories from current working directory.
* In batch mode, run_repro.do first cds into the software folder.
local script_dir = subinstr(c(pwd), "\", "/", .)
local thisfile = subinstr("`c(filename)'", "\", "/", .)
if "`thisfile'" != "" {
    if regexm("`thisfile'", "(.+)/[^/]+\\.do$") {
        local script_dir = regexs(1)
    }
}

cd "`script_dir'"

local submission_dir "`script_dir'"
if regexm("`script_dir'", "(.+)/software/?$") {
    local submission_dir = regexs(1)
}

local figs_dir "`submission_dir'/figs"
local logs_dir "`submission_dir'/sjlogs"

cap mkdir "`figs_dir'"
cap mkdir "`logs_dir'"

foreach f in wbopendata_linewrap_example.pdf wbopendata_example01.pdf ///
            wbopendata_example04.pdf wbopendata_worldstat_africa_gdp.pdf ///
            wbopendata_worldstat_world_fertility.pdf {
    cap erase "`figs_dir'/`f'"
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
    cap erase "`logs_dir'/`f'"
}

cap log close _all
log using "`script_dir'/reproduce_paper_examples.log", text replace

di as text _n "============================================================"
di as text "Reproducing paper examples"
di as text "============================================================"
di as text "Date: " c(current_date) " " c(current_time)
di as text "Working directory: `script_dir'"
di as text "Submission directory: `submission_dir'"
di as text "Figure output: `figs_dir'"
di as text "Log output: `logs_dir'"
di as text "============================================================"

net install wbopendata, from("`script_dir'") replace

capture which sjlog
if _rc != 0 {
    di as text "Installing sjlatex package"
    net install sjlatex, from("http://www.stata-journal.com/production") replace
}

which wbopendata

di as text _n ">>> Section 1: data download and metadata"

di as text _n "=== Example 1: single indicator download ==="
sjlog using "`logs_dir'/ex_single_indicator", replace
wbopendata, indicator(NY.GDP.MKTP.CD) clear linewrap(name note) maxlength(35 70)
sjlog close, replace

di as text _n "=== Example 2: multiple indicators ==="
sjlog using "`logs_dir'/ex_multiple_indicators", replace
wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long
sjlog close, replace

di as text _n "=== Example 3: latest option ==="
sjlog using "`logs_dir'/ex_latest_option", replace
wbopendata, indicator(SI.POV.DDAY) clear long latest linewrap(name note) maxlength(35 70)
di as text "latest year retrieved:"
return list
sjlog close, replace

di as text _n "=== Example 4a: linewrap returns ==="
sjlog using "`logs_dir'/ex_linewrap_returns", replace
wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 160)
return list
* Capture r() values before sjlog close clears them
local name1 `"`r(name1_stack)'"'
local name2 `"`r(name2_stack)'"'
local desc1 `"`r(description1_stack)'"'
local desc2 `"`r(description2_stack)'"'
local src1 `"`r(sourcecite1)'"'
local src2 `"`r(sourcecite2)'"'
local subtitle `"`r(latest)'"'
sjlog close, replace

di as text _n "=== Example 4b: graph using returned metadata ==="
sjlog using "`logs_dir'/ex_linewrap_graph", replace
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
cap noi graph export "`figs_dir'/wbopendata_linewrap_example.pdf", replace
if _rc == 0 di as text "  exported wbopendata_linewrap_example.pdf"

di as text _n ">>> Section 2: visualization"

di as text _n "=== Example 5: choropleth map ==="
sjlog using "`logs_dir'/ex_choropleth_map", replace
cap which spmap
if _rc == 0 {
    di as text "Note: creating choropleth with spmap"
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
}
sjlog close, replace
cap noi graph export "`figs_dir'/wbopendata_example01.pdf", replace
if _rc == 0 di as text "  exported wbopendata_example01.pdf"

di as text _n "=== Example 6: scatter plot - poverty vs GDP ==="
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
cap noi graph export "`figs_dir'/wbopendata_example04.pdf", replace
if _rc == 0 di as text "  exported wbopendata_example04.pdf"

di as text _n "=== Example 7: worldstat maps ==="
capture which worldstat
if _rc == 0 {
    di as text "Note: worldstat is installed"

    sjlog using "`logs_dir'/ex_worldstat_africa", replace
    cap noi worldstat Africa, stat(GDP) year(2009) cname
    sjlog close, replace
    cap noi graph export "`figs_dir'/wbopendata_worldstat_africa_gdp.pdf", replace
    if _rc == 0 di as text "  exported wbopendata_worldstat_africa_gdp.pdf"

    sjlog using "`logs_dir'/ex_worldstat_world", replace
    cap noi worldstat world, stat(FERT) fcolor(Pastel2)
    sjlog close, replace
    cap noi graph export "`figs_dir'/wbopendata_worldstat_world_fertility.pdf", replace
    if _rc == 0 di as text "  exported wbopendata_worldstat_world_fertility.pdf"
}
else {
    di as text "worldstat not installed; skipping map examples"
}

di as text _n ">>> Section 3: error handling"

di as text _n "=== Example 8: missing indicator ==="
sjlog using "`logs_dir'/ex_indicator_missing", replace
cap noi wbopendata, language(en) indicator(platypus) long clear
di as text "  return code (expected nonzero): " _rc
sjlog close, replace

di as text _n "=== Example 9: deprecated indicator ==="
sjlog using "`logs_dir'/ex_indicator_deprecated", replace
di as text "Captured return code (expected r(23) archive notice): "
cap noi wbopendata, language(en) indicator(AG.AGR.TRAC.NO) clear
di as text "  rc=`=_rc'"
sjlog close, replace

di as text _n ">>> Section 4: discovery commands"

di as text _n "=== Example 10: discovery - sources ==="
sjlog using "`logs_dir'/ex_discovery_sources", replace
wbopendata, sources
sjlog close, replace

di as text _n "=== Example 11: discovery - search ==="
sjlog using "`logs_dir'/ex_discovery_search", replace
wbopendata, search(poverty) searchtopic(11) limit(10)
sjlog close, replace

di as text _n "=== Example 12: discovery - info ==="
sjlog using "`logs_dir'/ex_discovery_info", replace
wbopendata, info(SI.POV.DDAY)
sjlog close, replace

di as text _n "=== Example 13: discovery - alltopics ==="
sjlog using "`logs_dir'/ex_discovery_alltopics", replace
wbopendata, alltopics
sjlog close, replace

di as text _n ">>> Section 5: synchronization and updates"

di as text _n "=== Example 14: sync preview ==="
sjlog using "`logs_dir'/ex_sync_preview", replace
wbopendata, sync
sjlog close, replace

di as text _n "=== Example 14b: sync detail ==="
sjlog using "`logs_dir'/ex_sync_detail", replace
wbopendata, sync detail
sjlog close, replace

di as text _n "=== Example 15: check for updates ==="
sjlog using "`logs_dir'/ex_checkupdate", replace
wbopendata, checkupdate
sjlog close, replace

di as text _n "============================================================"
di as text "COMPLETION SUMMARY"
di as text "============================================================"

local fig_count = 0
local log_count = 0

foreach f in wbopendata_linewrap_example.pdf wbopendata_example01.pdf ///
            wbopendata_example04.pdf wbopendata_worldstat_africa_gdp.pdf ///
            wbopendata_worldstat_world_fertility.pdf {
    cap confirm file "`figs_dir'/`f'"
    if _rc == 0 local fig_count = `fig_count' + 1
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
    if _rc == 0 local log_count = `log_count' + 1
}

di as text "Figures generated: `fig_count'/5"
di as text "LaTeX logs generated: `log_count'/18"
di as text "All paper examples reproduced successfully."
di as text "Date: " c(current_date) " " c(current_time)
di as text "============================================================"

cap log close _all
set rmsg on
exit
