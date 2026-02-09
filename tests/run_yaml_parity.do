/*******************************************************************************
* run_yaml_parity.do
*
* Purpose: Generate YAML via Stata fallback and compare with Python output.
* Usage: do run_yaml_parity.do [stata_outdir] [python_outdir] [python_cmd]
*
* Example:
*   do run_yaml_parity.do "C:/GitHub/myados/wbopendata-dev/tests/parity_out/stata" \
*       "C:/GitHub/myados/wbopendata-dev/tests/parity_out/python" \
*       "C:/GitHub/myados/.venv/Scripts/python.exe"
*******************************************************************************/

clear all
set more off

* Standardized dev environment
quietly do "C:/GitHub/myados/wbopendata-dev/tests/dev_setup.do"

log using "C:/GitHub/myados/wbopendata-dev/tests/parity_out/parity_run.log", replace text

args outdir_stata outdir_python python_cmd

* Default output dirs
if ("`outdir_stata'" == "") {
    local outdir_stata "C:/GitHub/myados/wbopendata-dev/tests/parity_out/stata"
}
if ("`outdir_python'" == "") {
    local outdir_python "C:/GitHub/myados/wbopendata-dev/tests/parity_out/python"
}
if ("`python_cmd'" == "") {
    local python_cmd "C:/GitHub/myados/.venv/Scripts/python.exe"
}

* Force-load dev ado files to avoid PLUS shadowing
local srcpath "C:/GitHub/myados/wbopendata-dev/src"
cap program drop _api_read_indicators
cap program drop _wbopendata_refresh_yaml
do "`srcpath'/_/_api_read_indicators.ado"
do "`srcpath'/_/_wbopendata_refresh_yaml.ado"
noi which _wbopendata_refresh_yaml
noi which _api_read_indicators

* Generate YAML using Stata fallback
noi di as text "Generating YAML via Stata fallback..."
cap erase "`outdir_stata'/_wbopendata_indicators.yaml"
cap erase "`outdir_stata'/_wbopendata_sources.yaml"
cap erase "`outdir_stata'/_wbopendata_topics.yaml"
cap noi _wbopendata_refresh_yaml, outdir("`outdir_stata'") replace
local rc = _rc
noi di as text "Stata YAML refresh exit code: `rc'"
cap confirm file "`outdir_stata'/_wbopendata_indicators.yaml"
if (_rc != 0) {
    noi di as error "Indicators YAML not found after refresh."
}

* Fix mojibake in Stata topics YAML (ensures UTF-8 parity)
local fix_script "C:/GitHub/myados/wbopendata-dev/tests/fix_stata_yaml_mojibake.py"
cap confirm file "`outdir_stata'/_wbopendata_topics.yaml"
if (_rc == 0) {
    shell "`python_cmd'" "`fix_script'" "`outdir_stata'/_wbopendata_topics.yaml"
}

* Compare with Python output (assumes Python YAML already generated)
local compare_script "C:/GitHub/myados/wbopendata-dev/tests/compare_yaml_parity.py"
noi di as text "Running parity check..."
shell "`python_cmd'" "`compare_script'" --stata-dir "`outdir_stata'" --python-dir "`outdir_python'"

noi di as text "Parity check complete."

log close
