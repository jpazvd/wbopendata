/*******************************************************************************
* run_examples.do
* 
* Purpose: Run all example do-files and save outputs to the repository
*
* Usage:   Run this script from Stata:
*          cd "C:/GitHub/myados/wbopendata/doc/examples"
*          do "run_examples.do"
*
* Output:  
*   - Logs saved to output/logs/
*   - Graphs saved to output/figures/
*   - Data exports saved to output/data/
*
* Author:  João Pedro Azevedo
* Date:    21Dec2025
*******************************************************************************/

clear all
set more off
capture log close _all

* Define paths
local basepath "C:/GitHub/myados/wbopendata/doc/examples"

* Change to examples directory
cd "`basepath'"

* Create output directories if they don't exist
capture mkdir "output"
capture mkdir "output/logs"
capture mkdir "output/figures"
capture mkdir "output/data"

* Display header
display as text _n "{hline 70}"
display as result "Running wbopendata example do-files"
display as text "{hline 70}"
display as text "Base path: `basepath'"
display as text "Date: " c(current_date) " " c(current_time)
display as text "{hline 70}" _n

*===============================================================================
* Run basic_usage.do
*===============================================================================

display as result _n ">>> Running basic_usage.do..." _n

log using "output/logs/basic_usage_log.txt", text replace name(basic)

capture noisily do "basic_usage.do"

log close basic

display as result ">>> basic_usage.do completed." _n
display as text "    Log: output/logs/basic_usage_log.txt" _n

*===============================================================================
* Run advanced_usage.do
*===============================================================================

display as result _n ">>> Running advanced_usage.do..." _n

log using "output/logs/advanced_usage_log.txt", text replace name(advanced)

capture noisily do "advanced_usage.do"

log close advanced

display as result ">>> advanced_usage.do completed." _n
display as text "    Log: output/logs/advanced_usage_log.txt" _n

*===============================================================================
* Summary
*===============================================================================

display as text _n "{hline 70}"
display as result "All example do-files completed!"
display as text "{hline 70}"
display as text ""
display as text "Output files saved to:"
display as text ""
display as text "  Logs:    output/logs/"
display as text "           - basic_usage_log.txt"
display as text "           - advanced_usage_log.txt"
display as text ""
display as text "  Figures: output/figures/"
display as text "           - gdp_per_capita_brics.png"
display as text "           - life_exp_vs_gni.png"
display as text "           - population_by_region.png"
display as text "           - inflation_rates.png"
display as text "           - mortality_by_income.png"
display as text ""
display as text "  Data:    output/data/"
display as text "           - gdp_data.csv, .xlsx, .dta"
display as text "           - poverty_table.xlsx"
display as text ""
display as text "{hline 70}" _n

*===============================================================================
* Optional: Generate dyndoc output
*===============================================================================

/* Uncomment to regenerate the Markdown documentation:

display as result _n ">>> Generating dyndoc output..." _n
dyndoc "examples_dyndoc.do", saving("examples_output_generated.md") replace
display as result ">>> dyndoc completed. See examples_output_generated.md" _n

*/

/*******************************************************************************
* END OF SCRIPT
*******************************************************************************/
