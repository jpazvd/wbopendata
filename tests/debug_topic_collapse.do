* Extended debug script for topic_ids parsing - full collapse trace
* Run in Stata to trace the complete YAML parse and collapse

clear all
set more off

* Get YAML path
_wbopendata_get_yaml_path, type(indicators)
local yaml_path = r(path)
di "YAML path: `yaml_path'"

* Run EXACTLY the same logic as __wbod_parse_yaml_ind but with debug output
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
        if (`i' > 200) continue, break  // Only first 200 lines for debug
        set obs `i'
        mata: st_sstore(`i', "rawline", st_local("line"))
        file read `fh' line
    }
    file close `fh'

    gen long linenum = _n
    gen strL raw_trim = strtrim(subinstr(rawline, char(13), "", .))
    gen int indent = length(rawline) - length(strtrim(rawline))

    * Detect indicator lines
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

    * Detect field lines
    gen byte is_field = 0
    replace is_field = 1 if indent == 4 & strpos(raw_trim, ":") > 0 & is_indicator == 0 & linenum > 9

    * Extract indicator code
    gen str100 ind_code = ""
    replace ind_code = strtrim(substr(rawline, 1, length(rawline) - 1)) if is_indicator

    * Propagate indicator code down
    gen long ind_group = sum(is_indicator)
    bysort ind_group: replace ind_code = ind_code[1]

    * Extract field type and value
    gen str20 field_type = ""
    gen int colon_pos = strpos(rawline, ":")
    replace field_type = strtrim(substr(rawline, 1, colon_pos - 1)) if is_field & colon_pos > 0

    gen strL field_val = ""
    replace field_val = strtrim(substr(rawline, colon_pos + 1, .)) if is_field & colon_pos > 0
    replace field_val = substr(field_val, 2, length(field_val)-2) if is_field & ///
        length(field_val) >= 2 & ///
        ((substr(field_val,1,1) == `"""' & substr(field_val,length(field_val),1) == `"""') | ///
         (substr(field_val,1,1) == "'" & substr(field_val,length(field_val),1) == "'"))

    * Assign field values
    gen str50 field_topic_ids = ""
    replace field_topic_ids = field_val if field_type == "topic_ids"
    replace field_topic_ids = "" if field_topic_ids == "[]"

    * Handle YAML list format
    gen byte is_list_item = regexm(raw_trim, "^- ")
    gen str100 list_item_val = ""
    replace list_item_val = strtrim(substr(raw_trim, 3, .)) if is_list_item
    replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
        length(list_item_val) >= 2 & ///
        ((substr(list_item_val,1,1) == "'" & substr(list_item_val,length(list_item_val),1) == "'") | ///
         (substr(list_item_val,1,1) == `"""' & substr(list_item_val,length(list_item_val),1) == `"""'))

    * Track which field header introduces the current list context
    gen str20 last_field_header = ""
    replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
    replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

    * Assign list item values
    replace field_topic_ids = list_item_val if is_list_item & last_field_header == "topic_ids"
}

di _n "=== BEFORE ACCUMULATOR: lines with field_topic_ids ==="
list linenum ind_group field_topic_ids raw_trim if field_topic_ids != "", string(40)

di _n "=== RUNNING ACCUMULATOR LOGIC ==="
quietly {
    sort ind_group linenum
    
    gen str500 all_topic_ids = ""
    
    * Step 1: Initialize from first row
    by ind_group: replace all_topic_ids = field_topic_ids if _n == 1
    
    * Step 2: Carry forward when current is empty
    by ind_group: replace all_topic_ids = all_topic_ids[_n-1] if _n > 1 & field_topic_ids == ""
    
    * Step 3: Concatenate when both have values
    by ind_group: replace all_topic_ids = all_topic_ids[_n-1] + ";" + field_topic_ids if _n > 1 & all_topic_ids[_n-1] != "" & field_topic_ids != ""
    
    * Step 4: Start fresh when accumulator empty but current has value
    by ind_group: replace all_topic_ids = field_topic_ids if _n > 1 & all_topic_ids[_n-1] == "" & field_topic_ids != ""
    
    * Step 5: Propagate final value to all rows
    by ind_group: replace all_topic_ids = all_topic_ids[_N]
    
    replace field_topic_ids = all_topic_ids
}

di _n "=== AFTER ACCUMULATOR: sample rows for ind_group 1 ==="
list linenum ind_group all_topic_ids field_topic_ids if ind_group == 1, string(20)

di _n "=== CHECKING UNIQUE VALUES PER INDICATOR ==="
preserve
collapse (firstnm) field_topic_ids, by(ind_group)
list ind_group field_topic_ids, string(20)
count if field_topic_ids != ""
di "Indicators with topic_ids after collapse: `r(N)'"
restore

