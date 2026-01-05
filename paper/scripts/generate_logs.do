* ==============================================================================
* Generate Stata Log Snippets for LaTeX Paper
* 
* This do-file runs ACTUAL Stata commands and captures output to .tex files
* for inclusion in the wbopendata Stata Journal paper.
* 
* OUTPUT FORMAT:
* - Log files contain RAW Stata output (no LaTeX wrappers)
* - Main paper uses fancyvrb's \VerbatimInput to include them:
*     \VerbatimInput{sjlogs/filename.tex}
* - fvset configuration in paper preamble matches stlog formatting:
*     \usepackage{fancyvrb}
*     \fvset{fontsize=\fontsize{8}{9}\selectfont, xleftmargin=12pt}
* 
* FIGURE GENERATION & LATEX EMBEDDING:
* - Examples that generate figures use graph export (PDF preferred, see stata.tex)
* - Graph files saved to ../doc/images/ for inclusion in paper
* - LaTeX figure environment pattern (from stata.tex lines 457-515):
*     \begin{figure}[htbp]
*       \centering
*       \includegraphics[width=0.8\textwidth]{../doc/images/filename.pdf}
*       \caption{Caption text}
*       \label{fig:label}
*     \end{figure}
* - Requirements: PDF format, 300 dpi minimum, grayscale, use sj scheme
* - See Example 5 (ex_scatter_figure) for concrete figure generation pattern
* 
* Output Location: paper/sjlogs/ (.tex files) and paper/figs/ (.pdf files)
* 
* Usage: From the paper/ directory, run:
*     do generate_logs.do
* Each example prints a short paragraph before the commands so the LaTeX
* snippets have self-contained context. Examples that generate figures show
* both the Stata commands (graph creation) and LaTeX code (embedding) needed
* for reproducibility.
* 
* Author: João Pedro Azevedo
* Date: January 2026
* ==============================================================================

clear all
set more off
set linesize 80

* Always start by making sure wbopendata in REPO and in Stata are aligned
* For development: use net install from local repo
* For SSC version: use "ssc install wbopendata, replace"
net install wbopendata, from("C:/GitHub/myados/wbopendata") replace

* Set the paper directory - use absolute path for reliability
local paper_dir "C:/GitHub/myados/wbopendata/paper"
cd "`paper_dir'"

* Note: When running with Stata's /e flag, a log is auto-created in cwd.
* We don't create a second explicit log to avoid duplicate files.

* Display the start time
di as text "Script started: " c(current_date) " " c(current_time)

* Set paths
local logs_dir "`paper_dir'/sjlogs"
local fig_dir "`paper_dir'/figs"

* Ensure output directories exist
cap mkdir "`logs_dir'"
cap mkdir "`fig_dir'"

di as text _n "=============================================="
di as text "Generating Stata log snippets for LaTeX paper"
di as text "=============================================="

* ==============================================================================
* Example 1: Single indicator download with metadata display
* ==============================================================================

di as text _n "Generating: ex_single_indicator.tex"

cap log close _snippet
log using "`logs_dir'/ex_single_indicator.tex", text replace name(_snippet)

wbopendata, indicator(NY.GDP.MKTP.CD) clear linewrap(name note) maxlength(35 70)

log close _snippet

* ==============================================================================
* Example 2: Multiple indicators with metadata
* ==============================================================================

di as text "Generating: ex_multiple_indicators.tex"

cap log close _snippet
log using "`logs_dir'/ex_multiple_indicators.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long ///
    linewrap(name note) maxlength(35 70)

describe

log close _snippet

* ==============================================================================
* Example 3: Latest option with returned results
* ==============================================================================

di as text "Generating: ex_latest_option.tex"

cap log close _snippet
log using "`logs_dir'/ex_latest_option.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY) clear long latest ///
    linewrap(name note) maxlength(35 70)
di as text "latest year: `r(latest_year)'"
di as text "countries: `r(latest_ncountries)'"
di as text "avg year: `r(latest_avgyear)'"

log close _snippet

* ==============================================================================
* Example 4a: Linewrap option - returned values
* ==============================================================================

    di as text "Generating: ex_linewrap_returns.tex"

    cap log close _snippet
    log using "`logs_dir'/ex_linewrap_returns.tex", text replace name(_snippet)

    * Download indicators with linewrap option for graph-ready metadata
    * Returns r(name#_stack), r(description#_stack), r(sourcecite#), r(latest)
    wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
        linewrap(name description note) maxlength(40 160)

    * Display wrapped metadata available for graph annotations
    return list

    * Store returned values in locals (must be done before opening new log)
    local name1 `"`r(name1_stack)'"'
    local name2 `"`r(name2_stack)'"'
    local desc1 `"`r(description1_stack)'"'
    local desc2 `"`r(description2_stack)'"'
    local src1 "`r(sourcecite1)'"
    local src2 "`r(sourcecite2)'"
    local subtitle "`r(latest)'"

    log close _snippet

* ==============================================================================
* Example 4b: Linewrap option - graph using returned metadata
* ==============================================================================

    di as text "Generating: ex_linewrap_graph.tex"

    cap log close _snippet
    log using "`logs_dir'/ex_linewrap_graph.tex", text replace name(_snippet)

    * Graph with wrapped axis titles, subtitle, definitions, and sources
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
            "{bf:Y (Mortality):} `src2'", size(vsmall)) name(tmp1, replace)
    graph export "`fig_dir'/wbopendata_linewrap_example.pdf", replace

    log close _snippet

* ==============================================================================
* Example 5: Scatter plot figure with LaTeX embedding
* 
* This example demonstrates how to generate and document a publication-ready
* figure. It shows both the Stata commands to create the graph AND the LaTeX
* code needed to embed it in the paper.
* 
* The figure is embedded in the paper using \begin{figure}...\includegraphics{}
* ... \end{figure} LaTeX environment (see stata.tex lines 457-515 for details).
* Requirements: PDF preferred (not EPS), 300 dpi minimum, grayscale, sj scheme.
* ==============================================================================

di as text "Generating: ex_scatter_figure.tex"

* Load data first (outside the log to keep log clean)
wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long latest ///
    linewrap(name) maxlength(40)
local title1 = r(name1_stack)

cap log close _snippet
log using "`logs_dir'/ex_scatter_figure.tex", text replace name(_snippet)

* Show the scatter plot creation
keep if !missing(si_pov_dday, ny_gdp_pcap_pp_kd)
set scheme sj
twoway (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(small)) ///
    , title("`title1'") ///
      xtitle("GDP per capita (PPP)") ///
      ytitle("Poverty headcount (%)") ///
      note("Source: World Bank Open Data")
graph export "`fig_dir'/scatter_poverty_income.pdf", replace

log close _snippet

* ==============================================================================
* Example 6: Country attributes with full option
* ==============================================================================

    di as text "Generating: ex_full_option.tex"

    cap log close _snippet
    log using "`logs_dir'/ex_full_option.tex", text replace name(_snippet)

    wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA) clear full ///
        linewrap(name note) maxlength(35 70)

    log close _snippet

* Generate LaTeX table for country attributes using listtab (Roger Newson)
    di as text "Generating: ex_full_option_table.tex (listtab output)"
    
    * Ensure listtab is installed
    cap which listtab
    if _rc != 0 {
        ssc install listtab, replace
    }
    
    * Create attribute-value pairs for vertical table layout
    preserve
        clear
        input str20 attribute str50 value
        "Region" "LCN (Latin America \& Caribbean)"
        "Income Level" "UMC (Upper middle income)"
        "Admin Region" "LAC (excl.\ high income)"
        "Lending Type" "IBD (IBRD)"
        "Capital" "Brasilia"
        "Coordinates" "$-$15.78, $-$47.93"
        end
        
        * Output LaTeX table to file
        listtab attribute value using "`logs_dir'/ex_full_option_table.tex", ///
            rstyle(tabular) replace ///
            head("\begin{tabular}{ll}" "\hline" ///
                 "\textbf{Attribute} & \textbf{Value (Brazil)} \\ \hline") ///
            foot("\hline" "\end{tabular}")
    restore
    
    di as text "  Generated: ex_full_option_table.tex"

* ==============================================================================
* Example 7a: worldstat - Regional map (Africa GDP)
* 
* The worldstat module (Clarke 2012) visualizes World Bank indicators
* geographically and temporally. It calls wbopendata internally to fetch data.
* Reference: ssc install worldstat
* ==============================================================================

di as text "Generating: ex_worldstat_africa.tex"

cap log close _snippet
log using "`logs_dir'/ex_worldstat_africa.tex", text replace name(_snippet)

* Regional map: GDP per capita in Africa (2009)
* Options: stat(GDP), year(2009), cname displays country names
cap noi worldstat Africa, stat(GDP) year(2009) cname
if _rc != 0 {
    di as text "Note: worldstat not installed. Install with: ssc install worldstat"
}

log close _snippet

cap noi graph export "`fig_dir'/wbopendata_worldstat_africa_gdp.pdf", replace
di as text "  Completed: ex_worldstat_africa.tex (optional)"

* ==============================================================================
* Example 7b: worldstat - Global map (Fertility rate)
* 
* Demonstrates worldstat with global coverage and custom color scheme.
* ==============================================================================

di as text "Generating: ex_worldstat_world.tex"

cap log close _snippet
log using "`logs_dir'/ex_worldstat_world.tex", text replace name(_snippet)

* Global map: Fertility rate with Pastel2 color scheme
cap noi worldstat world, stat(FERT) fcolor(Pastel2)
if _rc != 0 {
    di as text "Note: worldstat not installed. Install with: ssc install worldstat"
}

log close _snippet

cap noi graph export "`fig_dir'/wbopendata_worldstat_world_fertility.pdf", replace
di as text "  Completed: ex_worldstat_world.tex (optional)"

* ==============================================================================
* Example 8: Describe output showing variable structure
* ==============================================================================

di as text "Generating: ex_describe.tex"

cap log close _snippet
log using "`logs_dir'/ex_describe.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) ///
    country(BRA;CHN;USA) clear long nometadata
describe, short
describe countrycode countryname region regionname year ///
    si_pov_dday ny_gdp_pcap_pp_kd

log close _snippet

di as text "  Completed: ex_describe.tex"

* ==============================================================================
* Example 9: Update metadata query
* ==============================================================================

di as text "Generating: ex_update.tex"

cap log close _snippet
log using "`logs_dir'/ex_update.tex", text replace name(_snippet)

cap noi wbopendata, update query

log close _snippet

di as text "  Completed: ex_update.tex"

* ==============================================================================
* Example 10: Missing/invalid indicator or offline session
* ==============================================================================

di as text "Generating: ex_indicator_missing.tex"

cap log close _snippet
log using "`logs_dir'/ex_indicator_missing.tex", text replace name(_snippet)

cap noi wbopendata, language(en) indicator(platypus) long clear
di as text "Captured return code (expected nonzero): `_rc'"

log close _snippet

di as text "  Completed: ex_indicator_missing.tex"

* ==============================================================================
* Example 11: Deprecated/archived indicator
* ==============================================================================

di as text "Generating: ex_indicator_deprecated.tex"

cap log close _snippet
log using "`logs_dir'/ex_indicator_deprecated.tex", text replace name(_snippet)

cap noi wbopendata, language(en) indicator(AG.AGR.TRAC.NO) clear
di as text "Captured return code (expected r(23) archive notice): `_rc'"

log close _snippet

di as text "  Completed: ex_indicator_deprecated.tex"

* ==============================================================================
* Example 12: Choropleth map - Mobile subscriptions (wbopendata + spmap)
* 
* Demonstrates combining wbopendata with spmap for geographic visualization.
* Requires: spmap, world-c.dta/world-d.dta shapefiles
* Reference: wbopendata_examples.ado example01
* ==============================================================================

di as text "Generating: ex_choropleth_map.tex"

* Check dependencies first
cap which spmap
local has_spmap = (_rc == 0)

local world_d_path "`c(sysdir_plus)'w/world-d.dta"
local world_c_path "`c(sysdir_plus)'w/world-c.dta"
cap confirm file "`world_d_path'"
local found_d = (_rc == 0)
cap confirm file "`world_c_path'"
local found_c = (_rc == 0)

if `has_spmap' & `found_d' & `found_c' {
    
    cap log close _snippet
    log using "`logs_dir'/ex_choropleth_map.tex", text replace name(_snippet)

    * Download indicator data
    tempfile wdi_data
    wbopendata, indicator(it.cel.sets.p2) long clear latest
    local labelvar "`r(varlabel1)'"
    local source "`r(sourcecite1)'"
    sort countrycode
    save `wdi_data', replace

    * Merge with shapefile coordinates
    use "`world_d_path'", clear
    merge countrycode using `wdi_data'

    * Create choropleth map
    set scheme sj
    sum year
    local avg = string(`r(mean)', "%16.1f")

    spmap it_cel_sets_p2 using "`world_c_path'", id(_ID) ///
        clnumber(20) fcolor(Reds2) ocolor(none ..) ///
        title("`labelvar'", size(*1.2)) ///
        legstyle(3) legend(ring(1) position(3)) ///
        note("Source: `source' (latest: `avg')")

    log close _snippet

    graph export "`fig_dir'/wbopendata_example01.pdf", replace
    di as text "  Completed: ex_choropleth_map.tex + wbopendata_example01.pdf"
}
else {
    * Generate placeholder log noting dependencies
    cap log close _snippet
    log using "`logs_dir'/ex_choropleth_map.tex", text replace name(_snippet)
    
    di as text "* Choropleth map example requires:"
    di as text "*   ssc install spmap"
    di as text "*   world-c.dta and world-d.dta shapefiles"
    di as text ""
    di as text "* Syntax pattern:"
    di as text "  wbopendata, indicator(it.cel.sets.p2) long clear latest"
    di as text "  merge countrycode using wdi_data"
    di as text `"  spmap varname using "world-c.dta", id(_ID) fcolor(Reds2)"'
    
    log close _snippet
    
    if !`has_spmap' di as error "  spmap not installed"
    if !`found_d' | !`found_c' di as error "  Shapefiles not found in `c(sysdir_plus)'w/"
    di as text "  Completed: ex_choropleth_map.tex (placeholder)"
}

* ==============================================================================
* Example 13: Scatter plot - Poverty vs GDP (wbopendata + lowess)
* 
* Demonstrates scatter plot with lowess smoother and labeled aggregates.
* Reference: wbopendata_examples.ado example04
* ==============================================================================

di as text "Generating: ex_scatter_poverty_gdp.tex"

* Fetch data and store labels before opening log
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest nometadata
local ylabel "Poverty headcount ratio at $2.15 a day"
local xlabel "GDP per capita, PPP (constant intl $)"
local time "$S_FNDATE"

cap log close _snippet
log using "`logs_dir'/ex_scatter_poverty_gdp.tex", text replace name(_snippet)

* Scatter plot: Poverty vs GDP per capita with lowess smoother
set scheme sj
graph twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd if regionname == "Aggregates", ///
        msize(*.8) mlabel(countryname) mlabsize(*.8) mlabangle(25)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd), ///
        legend(off) ///
        ytitle("`ylabel'", size(small)) ///
        xtitle("`xlabel'", size(small)) ///
        note("Source: WDI (latest as of `time')")

log close _snippet

graph export "`fig_dir'/wbopendata_example04.pdf", replace
di as text "  Completed: ex_scatter_poverty_gdp.tex + wbopendata_example04.pdf"

* ==============================================================================
* Post-processing: Clean log headers from all files
* ==============================================================================

di as text _n "Cleaning log headers..."

* Clean each log file to remove Stata log header/footer
foreach f in ex_single_indicator ex_multiple_indicators ex_latest_option ///
             ex_linewrap_returns ex_linewrap_graph ex_scatter_figure ex_full_option ///
             ex_worldstat_africa ex_worldstat_world ex_describe ex_update ///
             ex_indicator_missing ex_indicator_deprecated ex_choropleth_map ///
             ex_scatter_poverty_gdp {
    
    local infile "`logs_dir'/`f'.tex"
    tempfile tmpfile
    
    * Read file, skip header lines, write to temp
    tempname fh_in fh_out
    file open `fh_in' using "`infile'", read text
    file open `fh_out' using "`tmpfile'", write text replace
    
    local linenum = 0
    local in_content = 0
    
    file read `fh_in' line
    while r(eof) == 0 {
        local linenum = `linenum' + 1
        
        * Skip header lines (log metadata)
        local skip = 0
        if strpos(`"`line'"', "------") > 0 & `linenum' <= 6 {
            local skip = 1
        }
        if strpos(`"`line'"', "log:") > 0 {
            local skip = 1
        }
        if strpos(`"`line'"', "log type:") > 0 {
            local skip = 1
        }
        if strpos(`"`line'"', "opened on:") > 0 {
            local skip = 1
        }
        if strpos(`"`line'"', "closed on:") > 0 {
            local skip = 1
        }
        if `"`line'"' == "" & `linenum' <= 2 {
            local skip = 1
        }
        
        * Start capturing after header
        if `skip' == 0 {
            local in_content = 1
        }
        
        * Write content lines, normalizing backslashes to forward slashes for LaTeX safety
        if `in_content' == 1 & `skip' == 0 {
            local line_clean = subinstr(`"`line'"', char(92), "/", .)
            file write `fh_out' `"`line_clean'"' _n
        }
        
        file read `fh_in' line
    }
    
    file close `fh_in'
    file close `fh_out'
    
    * Replace original with cleaned version
    copy "`tmpfile'" "`infile'", replace
    copy "`infile'" "`logs_dir'/`f'.log.tex", replace
    
    di as text "  Cleaned: `f'.tex (mirrored to .log.tex)"
}

* ==============================================================================
* Summary
* ==============================================================================

di as text _n "=============================================="
di as text "All log snippets generated in: `logs_dir'/"
di as text "All figures exported to: `fig_dir'/"
di as text "=============================================="
di as text "Code examples generated:"
dir "`logs_dir'/*.tex"
di as text _n "Figures generated:"
dir "`fig_dir'/*.pdf"
di as text _n "Usage in LaTeX paper:"
di as text ""
di as text "For code examples (with fancyvrb VerbatimInput):"
di as text "  \VerbatimInput{sjlogs/ex_single_indicator.log.tex}"
di as text ""
di as text "For figures (with includegraphics):"
di as text "  \begin{figure}[htbp]"
di as text "    \centering"
di as text "    \includegraphics[width=0.8\textwidth]{figs/wbopendata_example04.pdf}"
di as text "    \caption{Figure caption text}"
di as text "    \label{fig:label}"
di as text "  \end{figure}"
di as text ""
di as text "Reference: stata.tex lines 457-515 for detailed LaTeX figure documentation"
di as text ""
di as text "Integration examples:"
di as text "  - Example 5 (ex_scatter_figure): Data retrieval + graph creation + LaTeX embedding"
di as text "  - Example 7 (ex_worldstat_integration): wbopendata with worldstat visualization tool"
di as text "  - Example 12 (wbopendata_example01.pdf): Choropleth map from help file example01"
di as text "  - Example 13 (wbopendata_example04.pdf): Scatter plot from help file example04"

di as text _n "Done!"
exit
