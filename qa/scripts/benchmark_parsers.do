*! benchmark_parsers.do - Compare v1 (vectorized) vs v2 (yaml.ado) parser performance
*! Run from wbopendata-dev directory

clear all
set more off

local root = c(pwd)
adopath ++ "`root'/src/y"
adopath ++ "`root'/src/_"
adopath ++ "`root'/src/w"

* Find indicators YAML - use direct path
local yaml_path "`root'/src/_/_wbopendata_indicators.yaml"
capture confirm file "`yaml_path'"
if (_rc != 0) {
    di as error "YAML file not found: `yaml_path'"
    exit 601
}
di "Using: `yaml_path'"

*===============================================================================
* BENCHMARK 1: Original vectorized parser (__wbod_parse_yaml_ind)
*===============================================================================
di _n "=== Benchmark 1: Vectorized parser (v1) ==="
timer clear 1
timer on 1
__wbod_parse_yaml_ind "`yaml_path'"
timer off 1
local v1_N = _N
qui timer list 1
local v1_sec = r(t1)
di "Rows: `v1_N'"
di "Time: `v1_sec' seconds"
di "Variables:"
ds

preserve
    tempfile v1_data
    save `v1_data'
restore

*===============================================================================
* BENCHMARK 2: yaml.ado-based parser (__wbod_parse_yaml_ind_v2)
*===============================================================================
di _n "=== Benchmark 2: yaml.ado parser (v2) ==="
timer clear 2
timer on 2
__wbod_parse_yaml_ind_v2 "`yaml_path'"
timer off 2
local v2_N = _N
qui timer list 2
local v2_sec = r(t2)
di "Rows: `v2_N'"
di "Time: `v2_sec' seconds"
di "Variables:"
ds

preserve
    tempfile v2_data
    save `v2_data'
restore

*===============================================================================
* SUMMARY
*===============================================================================
di _n "=== Performance Summary ==="
di "v1 (vectorized): `v1_sec's (`v1_N' rows)"
di "v2 (yaml.ado):   `v2_sec's (`v2_N' rows)"

local speedup = (`v1_sec' - `v2_sec') / `v1_sec' * 100
if (`v2_sec' < `v1_sec') {
    di "yaml.ado is `=round(`speedup', 0.1)'% FASTER"
}
else {
    di "yaml.ado is `=round(-`speedup', 0.1)'% SLOWER"
}

*===============================================================================
* VERIFY OUTPUT COMPATIBILITY
*===============================================================================
di _n "=== Verifying output compatibility ==="

* Load v1 data and check key rows
use `v1_data', clear
local v1_vars : char _dta[vars]
sort ind_code
gen str50 v1_first_code = ind_code[1]
gen str200 v1_first_name = field_name[1]
local v1_first_code = v1_first_code[1]
local v1_first_name = field_name[1]
drop v1_*

* Load v2 data and compare
use `v2_data', clear
sort ind_code
local v2_first_code = ind_code[1]
local v2_first_name = field_name[1]

di "First indicator (v1): `v1_first_code'"
di "First indicator (v2): `v2_first_code'"
if ("`v1_first_code'" == "`v2_first_code'") {
    di as result "MATCH: First indicator codes match"
}
else {
    di as error "MISMATCH: First indicator codes differ"
}

if ("`v1_first_name'" == "`v2_first_name'") {
    di as result "MATCH: First indicator names match"
}
else {
    di as error "MISMATCH: First indicator names differ"
    di "  v1: `v1_first_name'"
    di "  v2: `v2_first_name'"
}

if (`v1_N' == `v2_N') {
    di as result "MATCH: Row counts match (`v1_N')"
}
else {
    di as error "MISMATCH: Row counts differ (v1=`v1_N', v2=`v2_N')"
}

exit 0
