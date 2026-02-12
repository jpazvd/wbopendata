* Quick test for source name lookup

clear all
adopath ++ "C:/GitHub/myados/wbopendata-dev/src"
program drop _all
discard

* Test direct lookup
di "Testing _wbopendata_get_source_name with source 2..."

_wbopendata_get_yaml_path, type(sources)
local src_yaml = r(path)
di "Sources YAML path: `src_yaml'"

* Let's manually inspect the YAML structure
preserve
infix str500 rawline 1-500 using "`src_yaml'", clear
gen long linenum = _n

* Look for lines containing '2':
di "Lines containing '2':"
list linenum rawline if strpos(rawline, "'2':") > 0 & linenum < 50

* Check the exact content of line 14
local line14 = rawline[14]
di "Line 14 exact content: [" `"`line14'"' "]"
di "First 10 chars of line 14: [" substr(rawline[14], 1, 10) "]"
di "strpos for '  '2':' at position 1: " strpos(rawline[14], "  '2':")

* Try matching without leading spaces
di ""
di "Trying to match just '2': at any position:"
gen byte has_id = strpos(rawline, "'2':") > 0
count if has_id & linenum < 50

* Try matching at various positions
di "Position of '''2':' in line 14: " strpos(rawline[14], "'2':")

restore

* Now test the actual helper
di ""
di "Now testing _wbopendata_get_source_name 2:"
_wbopendata_get_source_name 2
return list
