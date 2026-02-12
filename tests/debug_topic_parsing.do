* Debug script for topic_ids parsing
* Run in Stata to trace the YAML parser

clear all
set more off

* Get YAML path
_wbopendata_get_yaml_path, type(indicators)
local yaml_path = r(path)
di "YAML path: `yaml_path'"

* Run the parser directly
quietly {
    * Read each line preserving leading whitespace
    tempname fh
    clear
    gen strL rawline = ""
    local i = 0
    file open `fh' using "`yaml_path'", read
    file read `fh' line
    while (r(eof) == 0) {
        local i = `i' + 1
        if (`i' > 100) continue, break  // Only first 100 lines for debug
        set obs `i'
        mata: st_sstore(`i', "rawline", st_local("line"))
        file read `fh' line
    }
    file close `fh'

    gen long linenum = _n
    gen strL raw_trim = strtrim(subinstr(rawline, char(13), "", .))
    gen int indent = length(rawline) - length(strtrim(rawline))
}

di _n "=== First 60 lines of YAML ==="
list linenum indent rawline in 1/60, string(60)

* Check list item detection
gen byte is_list_item = regexm(raw_trim, "^- ")
di _n "=== List items detected ==="
list linenum indent raw_trim if is_list_item, string(60)

* Check field detection
gen byte is_indicator = 0
replace is_indicator = 1 if indent == 2 & regexm(raw_trim, ":$") & ///
    substr(raw_trim,1,5) != "code:" & ///
    substr(raw_trim,1,5) != "name:" & ///
    substr(raw_trim,1,10) != "source_id:" & ///
    substr(raw_trim,1,12) != "source_name:" & ///
    substr(raw_trim,1,11) != "source_org:" & ///
    substr(raw_trim,1,10) != "topic_ids:" & ///
    substr(raw_trim,1,12) != "topic_names:" & ///
    substr(raw_trim,1,12) != "description:" & ///
    substr(raw_trim,1,5) != "unit:" & ///
    substr(raw_trim,1,5) != "note:" & ///
    substr(raw_trim,1,13) != "limited_data:" & ///
    substr(raw_trim,1,9) != "_metadata" & ///
    substr(raw_trim,1,11) != "indicators:" & ///
    substr(raw_trim,1,1) != "-"

gen byte is_field = 0
replace is_field = 1 if indent == 4 & strpos(raw_trim, ":") > 0 & is_indicator == 0 & linenum > 9

di _n "=== Indicators detected ==="
list linenum indent raw_trim if is_indicator

di _n "=== Field lines detected ==="
list linenum indent raw_trim if is_field, string(60)

* Extract field type
gen str20 field_type = ""
gen int colon_pos = strpos(rawline, ":")
replace field_type = strtrim(substr(rawline, 1, colon_pos - 1)) if is_field & colon_pos > 0

di _n "=== topic_ids / topic_names field lines ==="
list linenum field_type if field_type == "topic_ids" | field_type == "topic_names"

* Check last_field_header forward-fill
gen str20 last_field_header = ""
replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

di _n "=== Lines around topic_ids (context tracking) ==="
list linenum indent is_list_item field_type last_field_header raw_trim in 15/35, string(40)

* Extract list values
gen str100 list_item_val = ""
replace list_item_val = strtrim(substr(raw_trim, 3, .)) if is_list_item
* Remove surrounding quotes
replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
    length(list_item_val) >= 2 & ///
    ((substr(list_item_val,1,1) == "'" & substr(list_item_val,length(list_item_val),1) == "'") | ///
     (substr(list_item_val,1,1) == `"""' & substr(list_item_val,length(list_item_val),1) == `"""'))

gen str50 field_topic_ids = ""
replace field_topic_ids = list_item_val if is_list_item & last_field_header == "topic_ids"

di _n "=== Final: Lines with field_topic_ids populated ==="
list linenum indent field_topic_ids raw_trim if field_topic_ids != "", string(40)

di _n "=== Summary ==="
count if field_topic_ids != ""
di "Lines with topic_ids populated: `r(N)'"

