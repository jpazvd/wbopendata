/*==============================================================================
    Generate Stata Log Snippets for LaTeX Paper (Official SJ Method)
    
    This do-file uses the OFFICIAL Stata Journal method:
    - Uses `sjlog` command to generate .log.tex files
    - Output contains TeX macros for proper table rendering
    - Include in paper with: \begin{stlog}\input{file.log.tex}\nullskip\end{stlog}
    
    Prerequisites:
    - Install sjlatex package: net install sjlatex, from(http://www.stata-journal.com/production)
    
    Output: paper/sjlogs/.log.tex files
    
    Usage: From the paper/ directory, run:
        do generate_logs_sjlog.do
    
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

di as text _n "=============================================="
di as text "Generating Stata log snippets (sjlog method)"
di as text "=============================================="

/*------------------------------------------------------------------------------
    Example 1: Single indicator download with metadata display
------------------------------------------------------------------------------*/

di as text _n "Generating: ex_single_indicator.log.tex"

sjlog using "`logs_dir'/ex_single_indicator", replace

wbopendata, indicator(NY.GDP.MKTP.CD) clear long

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 2: Multiple indicators with metadata
------------------------------------------------------------------------------*/

di as text "Generating: ex_multiple_indicators.log.tex"

sjlog using "`logs_dir'/ex_multiple_indicators", replace

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 3: Latest option with returned results
------------------------------------------------------------------------------*/

di as text "Generating: ex_latest_option.log.tex"

sjlog using "`logs_dir'/ex_latest_option", replace

wbopendata, indicator(SI.POV.DDAY) clear long latest
return list

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 4: Linewrap option with graph metadata
------------------------------------------------------------------------------*/

di as text "Generating: ex_linewrap_option.log.tex"

sjlog using "`logs_dir'/ex_linewrap_option", replace

wbopendata, indicator(SI.POV.DDAY) clear long latest ///
    linewrap(name description) maxlength(40 80)
return list

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 5: Country attributes 
------------------------------------------------------------------------------*/

di as text "Generating: ex_full_option.log.tex"

sjlog using "`logs_dir'/ex_full_option", replace

wbopendata, indicator(NY.GDP.PCAP.PP.KD) country(BRA) clear long nometadata

describe
list countrycode countryname region* incomelevel* if year > 2010, clean noobs
*list lendingtype* capital latitude longitude if year > 2010, clean noobs

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 6: Describe output showing variable structure
------------------------------------------------------------------------------*/

di as text "Generating: ex_describe.log.tex"

sjlog using "`logs_dir'/ex_describe", replace

wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) ///
    country(BRA;CHN;USA) clear long nometadata
describe, short
describe countrycode countryname region regionname year ///
    si_pov_dday ny_gdp_pcap_pp_kd

sjlog close, replace

/*------------------------------------------------------------------------------
    Example 7: Update metadata query
------------------------------------------------------------------------------*/

di as text "Generating: ex_update.log.tex"

sjlog using "`logs_dir'/ex_update", replace

wbopendata, update query

sjlog close, replace

/*------------------------------------------------------------------------------
    Summary
------------------------------------------------------------------------------*/

di as text _n "=============================================="
di as text "All log snippets generated in: `logs_dir'/"
di as text "=============================================="
di as text "Files created:"
dir "`logs_dir'/*.log.tex"
di as text _n "Usage in LaTeX paper (official SJ method):"
di as text "  \begin{stlog}"
di as text "  \input{sjlogs/ex_single_indicator.log.tex}\nullskip"
di as text "  \end{stlog}"

di as text _n "Done!"
exit

