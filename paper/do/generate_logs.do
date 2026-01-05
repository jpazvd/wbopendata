/*==============================================================================
    Generate Stata Log Snippets for LaTeX Paper
    
    This do-file runs ACTUAL Stata commands and captures output to .tex files
    for inclusion in the wbopendata Stata Journal paper.
    
    OUTPUT FORMAT:
    - Log files contain RAW Stata output (no LaTeX wrappers)
    - Main paper uses fancyvrb's \VerbatimInput to include them:
        \VerbatimInput{sjlogs/filename.tex}
    - fvset configuration in paper preamble matches stlog formatting:
        \usepackage{fancyvrb}
        \fvset{fontsize=\fontsize{8}{9}\selectfont, xleftmargin=12pt}
    
    FIGURE GENERATION & LATEX EMBEDDING:
    - Examples that generate figures use graph export (PDF preferred, see stata.tex)
    - Graph files saved to ../doc/images/ for inclusion in paper
    - LaTeX figure environment pattern (from stata.tex lines 457-515):
        \begin{figure}[htbp]
          \centering
          \includegraphics[width=0.8\textwidth]{../doc/images/filename.pdf}
          \caption{Caption text}
          \label{fig:label}
        \end{figure}
    - Requirements: PDF format, 300 dpi minimum, grayscale, use sj scheme
    - See Example 5 (ex_scatter_figure) for concrete figure generation pattern
    
    Output Location: paper/sjlogs/.tex files and paper/docs/images/*.pdf
    
    Usage: From the paper/ directory, run:
        do generate_logs.do
    Each example prints a short paragraph before the commands so the LaTeX
    snippets have self-contained context. Examples that generate figures show
    both the Stata commands (graph creation) and LaTeX code (embedding) needed
    for reproducibility.
    
    Author: João Pedro Azevedo
    Date: January 2026
==============================================================================*/

clear all
set more off
set linesize 80

// Set paths - adjust if running from different directory
local paper_dir "."
local logs_dir "`paper_dir'/sjlogs"

// Ensure output directory exists
cap mkdir "`logs_dir'"
local fig_dir "../doc/images"
cap mkdir "`fig_dir'"

di as text _n "=============================================="
di as text "Generating Stata log snippets for LaTeX paper"
di as text "=============================================="

/*------------------------------------------------------------------------------
    Example 1: Single indicator download with metadata display
------------------------------------------------------------------------------*/

di as text _n "Generating: ex_single_indicator.tex"

cap log close _snippet
log using "`logs_dir'/ex_single_indicator.tex", text replace name(_snippet)

wbopendata, indicator(NY.GDP.MKTP.CD) clear linewrap(name note) maxlength(35 70)

log close _snippet

/*------------------------------------------------------------------------------
    Example 2: Multiple indicators with metadata
------------------------------------------------------------------------------*/

di as text "Generating: ex_multiple_indicators.tex"

cap log close _snippet
log using "`logs_dir'/ex_multiple_indicators.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long ///
    linewrap(name note) maxlength(35 70)

log close _snippet

/*------------------------------------------------------------------------------
    Example 3: Latest option with returned results
------------------------------------------------------------------------------*/

di as text "Generating: ex_latest_option.tex"

cap log close _snippet
log using "`logs_dir'/ex_latest_option.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY) clear long latest ///
    linewrap(name note) maxlength(35 70)
di as text "latest year: `r(latest_year)'"
di as text "countries: `r(latest_ncountries)'"
di as text "avg year: `r(latest_avgyear)'"

log close _snippet

/*------------------------------------------------------------------------------
    Example 4: Linewrap option with graph metadata
------------------------------------------------------------------------------*/

di as text "Generating: ex_linewrap_option.tex"

cap log close _snippet
log using "`logs_dir'/ex_linewrap_option.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long latest ///
    linewrap(name note) maxlength(35 70)
di as text "latest year: `r(latest_year)'"
di as text "countries: `r(latest_ncountries)'"
di as text "avg year: `r(latest_avgyear)'"

// Generate a simple scatter plot using the wrapped title for the first indicator
local ttl `"Poverty headcount ($3/day, 2021 PPP)"'
keep if !missing(si_pov_dday, ny_gdp_pcap_pp_kd)
twoway (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(small)) ///
    , title(`ttl') ///
      note("Source: World Bank Open Data")
graph export "`fig_dir'/wbopendata_linewrap_example.pdf", replace

log close _snippet

/*------------------------------------------------------------------------------
    Example 5: Scatter plot figure with LaTeX embedding
    
    This example demonstrates how to generate and document a publication-ready
    figure. It shows both the Stata commands to create the graph AND the LaTeX
    code needed to embed it in the paper.
    
    The figure is embedded in the paper using \begin{figure}...\includegraphics{}
    ... \end{figure} LaTeX environment (see stata.tex lines 457-515 for details).
    Requirements: PDF preferred (not EPS), 300 dpi minimum, grayscale, sj scheme.
------------------------------------------------------------------------------*/

di as text "Generating: ex_scatter_figure.tex"

cap log close _snippet
log using "`logs_dir'/ex_scatter_figure.tex", text replace name(_snippet)

// Retrieve poverty and income data with wrapped metadata
wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) ///
    clear long latest linewrap(name) maxlength(40)

// Store wrapped title from returned metadata for graph title
local ttl1 `r(name1_stack)'

// Create the scatter plot visualization
keep if !missing(si_pov_dday, ny_gdp_pcap_pp_kd)
twoway (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(small)) ///
    , title(`ttl1') ///
      xtitle("GDP per capita (PPP)") ///
      ytitle("Poverty headcount (%)") ///
      note("Source: World Bank Open Data. Latest available year: `r(latest_year)'")

// Export to PDF for publication
graph export "`fig_dir'/scatter_poverty_income.pdf", replace

di as text _n "Figure generated and exported to PDF."
di as text "To embed in LaTeX, use:"
di as text ""
di as text "\begin{figure}[htbp]"
di as text "\centering"
di as text "\includegraphics[width=0.8\textwidth]{scatter_poverty_income.pdf}"
di as text "\caption{Relationship between poverty headcount and GDP per capita}"
di as text "\label{fig:scatter}"
di as text "\end{figure}"
di as text ""

log close _snippet

/*------------------------------------------------------------------------------
    Example 6: Country attributes with full option
------------------------------------------------------------------------------*/

di as text "Generating: ex_full_option.tex"

cap log close _snippet
log using "`logs_dir'/ex_full_option.tex", text replace name(_snippet)

wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA) clear full ///
    linewrap(name note) maxlength(35 70)

list countrycode countryname region* in 1, clean noobs abbreviate(16)
list countrycode countryname incomelevel* in 1, clean noobs abbreviate(16)
list countrycode countryname admn* in 1, clean noobs abbreviate(16)
list lendingtype* capital latitude longitude in 1, clean noobs abbreviate(16)

log close _snippet

/*------------------------------------------------------------------------------
    Example 6: Describe output showing variable structure
------------------------------------------------------------------------------*/

di as text "Generating: ex_describe.tex"

cap log close _snippet
log using "`logs_dir'/ex_describe.tex", text replace name(_snippet)

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) ///
    country(BRA;CHN;USA) clear long nometadata
describe, short
describe countrycode countryname region regionname year ///
    si_pov_dday ny_gdp_pcap_pp_kd

log close _snippet

/*------------------------------------------------------------------------------
    Example 7: Update metadata query
------------------------------------------------------------------------------*/

di as text "Generating: ex_update.tex"

cap log close _snippet
log using "`logs_dir'/ex_update.tex", text replace name(_snippet)

wbopendata, update query

log close _snippet

/*------------------------------------------------------------------------------
    Example 8: Missing/invalid indicator or offline session
------------------------------------------------------------------------------*/

di as text "Generating: ex_indicator_missing.tex"

cap log close _snippet
log using "`logs_dir'/ex_indicator_missing.tex", text replace name(_snippet)

cap noi wbopendata, language(en) indicator(platypus) long clear
di as text "Captured return code (expected nonzero): `_rc'"

log close _snippet

/*------------------------------------------------------------------------------
    Example 9: Deprecated/archived indicator
------------------------------------------------------------------------------*/

di as text "Generating: ex_indicator_deprecated.tex"

cap log close _snippet
log using "`logs_dir'/ex_indicator_deprecated.tex", text replace name(_snippet)

cap noi wbopendata, language(en) indicator(AG.AGR.TRAC.NO) clear
di as text "Captured return code (expected r(23) archive notice): `_rc'"

log close _snippet

/*------------------------------------------------------------------------------
    Post-processing: Clean log headers from all files
------------------------------------------------------------------------------*/

di as text _n "Cleaning log headers..."

// Clean each log file to remove Stata log header/footer
foreach f in ex_single_indicator ex_multiple_indicators ex_latest_option ///
             ex_linewrap_option ex_scatter_figure ex_full_option ex_describe ex_update ///
             ex_indicator_missing ex_indicator_deprecated {
    
    local infile "`logs_dir'/`f'.tex"
    tempfile tmpfile
    
    // Read file, skip header lines, write to temp
    tempname fh_in fh_out
    file open `fh_in' using "`infile'", read text
    file open `fh_out' using "`tmpfile'", write text replace
    
    local linenum = 0
    local in_content = 0
    
    file read `fh_in' line
    while r(eof) == 0 {
        local linenum = `linenum' + 1
        
        // Skip header lines (log metadata)
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
        
        // Start capturing after header
        if `skip' == 0 {
            local in_content = 1
        }
        
        // Write content lines, normalizing backslashes to forward slashes for LaTeX safety
        if `in_content' == 1 & `skip' == 0 {
            local line_clean = subinstr(`"`line'"', char(92), "/", .)
            file write `fh_out' `"`line_clean'"' _n
        }
        
        file read `fh_in' line
    }
    
    file close `fh_in'
    file close `fh_out'
    
    // Replace original with cleaned version
    copy "`tmpfile'" "`infile'", replace
    copy "`infile'" "`logs_dir'/`f'.log.tex", replace
    
    di as text "  Cleaned: `f'.tex (mirrored to .log.tex)"
}

/*------------------------------------------------------------------------------
    Summary
------------------------------------------------------------------------------*/

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
di as text "    \includegraphics[width=0.8\textwidth]{../doc/images/scatter_poverty_income.pdf}"
di as text "    \caption{Figure caption text}"
di as text "    \label{fig:label}"
di as text "  \end{figure}"
di as text ""
di as text "Reference: stata.tex lines 457-515 for detailed LaTeX figure documentation"

di as text _n "Done!"
exit
