*******************************************************************************
*! __wbod_parse_yaml_ind v1.0.0  04Feb2026
*! Parse YAML indicators file into collapsed dataset (one row per indicator)
*! Called by __wbopendata_search_cache - not intended for direct use
*******************************************************************************

program define __wbod_parse_yaml_ind
    version 14.0
    args yaml_path

    quietly {
        * Use infix to read each line as a single fixed-width string
        infix str244 rawline 1-244 using "`yaml_path'", clear
        gen long linenum = _n

        * Detect indicator lines (format: INDICATOR_CODE:)
        gen byte is_indicator = 0
        replace is_indicator = 1 if substr(rawline,-1,1) == ":" & ///
            substr(rawline,1,5) != "code:" & ///
            substr(rawline,1,5) != "name:" & ///
            substr(rawline,1,10) != "source_id:" & ///
            substr(rawline,1,12) != "source_name:" & ///
            substr(rawline,1,11) != "source_org:" & ///
            substr(rawline,1,10) != "topic_ids:" & ///
            substr(rawline,1,12) != "topic_names:" & ///
            substr(rawline,1,12) != "description:" & ///
            substr(rawline,1,5) != "unit:" & ///
            substr(rawline,1,5) != "note:" & ///
            substr(rawline,1,13) != "limited_data:" & ///
            substr(rawline,1,9) != "_metadata" & ///
            substr(rawline,1,11) != "indicators:" & ///
            substr(rawline,1,1) != "-"

        * Detect field lines
        gen byte is_field = 0
        replace is_field = 1 if strpos(rawline, ":") > 0 & is_indicator == 0 & linenum > 9

        * Extract indicator code (everything before the colon)
        gen str100 ind_code = ""
        replace ind_code = strtrim(substr(rawline, 1, length(rawline) - 1)) if is_indicator

        * Propagate indicator code down to its fields
        gen long ind_group = sum(is_indicator)
        bysort ind_group: replace ind_code = ind_code[1]

        * Extract field type and value
        gen str20 field_type = ""
        gen int colon_pos = strpos(rawline, ":")
        replace field_type = strtrim(substr(rawline, 1, colon_pos - 1)) if is_field & colon_pos > 0

        * Extract field value after the colon
        gen str244 field_val = ""
        replace field_val = strtrim(substr(rawline, colon_pos + 1, .)) if is_field & colon_pos > 0
        * Remove surrounding quotes
        replace field_val = substr(field_val, 2, length(field_val)-2) if is_field & ///
            (substr(field_val,1,1) == `"""' | substr(field_val,1,1) == "'")

        * Assign to specific field columns
        gen str244 field_name = ""
        gen str244 field_desc = ""
        gen str244 field_source = ""
        gen str244 field_topic = ""
        gen str244 field_note = ""
        gen str20 field_source_id = ""
        gen str50 field_topic_ids = ""
        replace field_name = field_val if field_type == "name"
        replace field_desc = field_val if field_type == "description"
        replace field_source = field_val if field_type == "source_org"
        replace field_topic = field_val if field_type == "topic_names"
        replace field_note = field_val if field_type == "note"
        replace field_source_id = field_val if field_type == "source_id"
        replace field_topic_ids = field_val if field_type == "topic_ids"

        *-------------------------------------------------------------------
        * Handle YAML list format: topic_ids and topic_names are lists
        *-------------------------------------------------------------------
        gen byte is_list_item = substr(strtrim(rawline), 1, 2) == "- "
        gen str100 list_item_val = ""
        replace list_item_val = strtrim(substr(rawline, strpos(rawline, "- ") + 2, .)) if is_list_item
        * Remove surrounding quotes from list values
        replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
            (substr(list_item_val,1,1) == "'" | substr(list_item_val,1,1) == `"""')

        * Track which field header introduces the current list context
        gen str20 last_field_header = ""
        replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
        * Forward-fill the context
        replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

        * Assign list item values to the appropriate fields
        replace field_topic_ids = list_item_val if is_list_item & last_field_header == "topic_ids"
        replace field_topic = list_item_val if is_list_item & last_field_header == "topic_names"

        drop is_list_item list_item_val last_field_header

        * Collapse to one row per indicator
        collapse (firstnm) ind_code (firstnm) field_name (firstnm) field_desc ///
                 (firstnm) field_source (firstnm) field_topic (firstnm) field_note ///
                 (firstnm) field_source_id (firstnm) field_topic_ids, by(ind_group)
        drop if ind_code == ""

        * Keep only necessary columns for smaller cache footprint
        keep ind_code field_name field_desc field_source field_topic field_note ///
             field_source_id field_topic_ids
    }
end
