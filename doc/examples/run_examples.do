/*******************************************************************************
* run_examples.do
* 
* Purpose: Run all example do-files and save outputs (logs) to the repository
*
* Usage:   Run this script from Stata after installing wbopendata:
*          do "C:/GitHub/myados/wbopendata/doc/examples/run_examples.do"
*
* Output:  Creates log files in doc/examples/output/
*
* Author:  João Pedro Azevedo
* Date:    21Dec2025
*******************************************************************************/

clear all
set more off
capture log close _all

* Define paths
local basepath "C:/GitHub/myados/wbopendata/doc/examples"
local outpath "`basepath'/output"

* Create output directory if it doesn't exist
capture mkdir "`outpath'"

* Display header
display as text _n "{hline 70}"
display as result "Running wbopendata example do-files"
display as text "{hline 70}"
display as text "Base path: `basepath'"
display as text "Output path: `outpath'"
display as text "Date: " c(current_date) " " c(current_time)
display as text "{hline 70}" _n

*===============================================================================
* Run basic_usage.do
*===============================================================================

display as result _n ">>> Running basic_usage.do..." _n

log using "`outpath'/basic_usage_log.txt", text replace name(basic)

capture noisily do "`basepath'/basic_usage.do"

log close basic

display as result ">>> basic_usage.do completed. Log saved to output/basic_usage_log.txt" _n

*===============================================================================
* Run advanced_usage.do
*===============================================================================

display as result _n ">>> Running advanced_usage.do..." _n

log using "`outpath'/advanced_usage_log.txt", text replace name(advanced)

capture noisily do "`basepath'/advanced_usage.do"

log close advanced

display as result ">>> advanced_usage.do completed. Log saved to output/advanced_usage_log.txt" _n

*===============================================================================
* Summary
*===============================================================================

display as text _n "{hline 70}"
display as result "Example do-files completed!"
display as text "{hline 70}"
display as text "Output files saved to: `outpath'/"
display as text ""
display as text "  - basic_usage_log.txt"
display as text "  - advanced_usage_log.txt"
display as text ""
display as text "To view logs:"
display as text "  type `outpath'/basic_usage_log.txt"
display as text ""
display as text "{hline 70}" _n

/*******************************************************************************
* END OF SCRIPT
*******************************************************************************/
