*******************************************************************************
*! __wbod_parse_yaml_ind v1.0.10  09Feb2026
*! Parse YAML indicators file into collapsed dataset (one row per indicator)
*! Called by __wbopendata_search_cache - not intended for direct use
*! v1.0.10: Accumulate all topic_names (semicolon-separated like topic_ids)
*******************************************************************************

program define __wbod_parse_yaml_ind
    version 14.0
    args yaml_path

    quietly {
        * Read each line preserving leading whitespace (indentation).
        * Use Mata st_sstore() to bypass macro expansion, which breaks
        * when lines contain embedded double-quotes (r(132)).
        tempname fh
        clear
        gen strL rawline = ""
        local i = 0
        file open `fh' using "`yaml_path'", read
        file read `fh' line
        while (r(eof) == 0) {
            local i = `i' + 1
            set obs `i'
            mata: st_sstore(`i', "rawline", st_local("line"))
            file read `fh' line
        }
        file close `fh'

        gen long linenum = _n
        gen strL raw_trim = strtrim(subinstr(rawline, char(13), "", .))
        gen int indent = length(rawline) - length(strtrim(rawline))

        * Detect indicator lines (format: INDICATOR_CODE:)
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
        gen strL field_val = ""
        replace field_val = strtrim(substr(rawline, colon_pos + 1, .)) if is_field & colon_pos > 0
        * Remove surrounding quotes
        replace field_val = substr(field_val, 2, length(field_val)-2) if is_field & ///
            length(field_val) >= 2 & ///
            ((substr(field_val,1,1) == `"""' & substr(field_val,length(field_val),1) == `"""') | ///
             (substr(field_val,1,1) == "'" & substr(field_val,length(field_val),1) == "'"))

        * Handle YAML block scalars (folded/literal)
        gen byte block_start = is_field & inlist(field_val, ">", ">-", "|", "|-")
        replace field_val = "" if block_start

        * Identify blank/whitespace-only lines (should not break block scalar)
        gen byte is_blank = raw_trim == ""
        
        * Forward-fill block_active for continuation lines
        * CRITICAL: Blank lines in YAML block scalars have indent 0 but should NOT break the block.
        * Only reset when we hit a real new field/indicator (indent <= 4 AND has content).
        gen byte block_active = 0
        replace block_active = 1 if block_start
        
        * Iterate to propagate block_active through multiple lines including blank ones
        * Continue if: previous row was active AND (we have content indent >= 6 OR line is blank)
        forvalues iter = 1/20 {
            replace block_active = 1 if _n > 1 & block_active[_n-1] == 1 & !block_start & ///
                (indent >= 6 | is_blank)
        }
        * Reset ONLY on actual new field or indicator (has content at indent <= 4)
        replace block_active = 0 if (is_field | is_indicator) & !block_start

        gen str20 block_field = ""
        replace block_field = field_type if block_start
        * Forward-fill block_field with same iteration pattern
        forvalues iter = 1/20 {
            replace block_field = block_field[_n-1] if block_field == "" & block_active == 1 & _n > 1
        }

        * Mark content lines within block (exclude blank lines from content but keep in block)
        gen byte block_line = block_active == 1 & !block_start & indent >= 6 & !is_blank
        replace field_type = block_field if block_line
        replace field_val = strtrim(regexr(rawline, "^[ ]+", "")) if block_line

        * Assign to specific field columns
        gen strL field_name = ""
        gen strL field_desc = ""
        gen strL field_source = ""
        gen strL field_source_name = ""
        gen strL field_topic = ""
        gen strL field_note = ""
        gen str20 field_source_id = ""
        gen str50 field_topic_ids = ""
        gen str100 field_unit = ""
        gen byte field_limited_data = 0
        replace field_name = field_val if field_type == "name"
        replace field_desc = field_val if field_type == "description"
        replace field_source = field_val if field_type == "source_org"
        replace field_source_name = field_val if field_type == "source_name"
        replace field_topic = field_val if field_type == "topic_names"
        replace field_note = field_val if field_type == "note"
        replace field_source_id = field_val if field_type == "source_id"
        replace field_topic_ids = field_val if field_type == "topic_ids"
        replace field_unit = field_val if field_type == "unit"
        replace field_limited_data = (strlower(field_val) == "true") if field_type == "limited_data"

        * Normalize empty list markers for topic fields
        replace field_topic_ids = "" if field_topic_ids == "[]"
        replace field_topic = "" if field_topic == "[]"

        *-------------------------------------------------------------------
        * Handle YAML list format: topic_ids and topic_names are lists
        * Use raw_trim so indentation differences don't affect detection
        *-------------------------------------------------------------------
        gen byte is_list_item = regexm(raw_trim, "^- ")
        gen str100 list_item_val = ""
        replace list_item_val = strtrim(substr(raw_trim, 3, .)) if is_list_item
        * Remove surrounding quotes from list values
        replace list_item_val = substr(list_item_val, 2, length(list_item_val)-2) if is_list_item & ///
            length(list_item_val) >= 2 & ///
            ((substr(list_item_val,1,1) == "'" & substr(list_item_val,length(list_item_val),1) == "'") | ///
             (substr(list_item_val,1,1) == `"""' & substr(list_item_val,length(list_item_val),1) == `"""'))

        * Track which field header introduces the current list context
        gen str20 last_field_header = ""
        replace last_field_header = field_type if field_type == "topic_ids" | field_type == "topic_names"
        * Forward-fill the context
        replace last_field_header = last_field_header[_n-1] if last_field_header == "" & _n > 1

        * Assign list item values to the appropriate fields
        replace field_topic_ids = list_item_val if is_list_item & last_field_header == "topic_ids"
        replace field_topic = list_item_val if is_list_item & last_field_header == "topic_names"

        drop is_list_item list_item_val last_field_header

        * Concatenate topic_ids before collapsing (preserve all IDs as semicolon-delimited list)
        * Note: egen concat() cannot be combined with by/bysort in Stata,
        *       so we manually accumulate topic_ids within each ind_group.
        sort ind_group linenum

        * Accumulate block scalar lines for text fields using single-pass cond() logic
        * Same fix as topic_ids: Stata runs each by-replace as a complete pass,
        * so we use cond() to evaluate all conditions in one statement per row
        foreach v in field_desc field_note field_source {
            gen strL `v'_acc = ""
            * Initialize from first row
            by ind_group: replace `v'_acc = `v' if _n == 1
            * Single-pass: for each subsequent row, either:
            * - Append with space if both accumulator and current non-empty
            * - Take current if accumulator empty
            * - Carry forward accumulator if current empty
            by ind_group: replace `v'_acc = cond(`v' != "", ///
                cond(`v'_acc[_n-1] != "", `v'_acc[_n-1] + " " + `v', `v'), ///
                `v'_acc[_n-1]) if _n > 1
            * Propagate final accumulated value to all rows in group
            by ind_group: replace `v' = `v'_acc[_N]
            drop `v'_acc
        }

        * Accumulate topic_ids using single-pass forward-fill + accumulate logic
        * Use cond() to handle all cases in one pass - Stata processes rows sequentially
        * within by-groups so each row sees the updated value from the previous row
        gen str500 all_topic_ids = ""
        
        * Initialize first row
        by ind_group: replace all_topic_ids = field_topic_ids if _n == 1
        
        * Single-pass: for each subsequent row, either:
        * - Accumulate (append current to previous with ;) if both non-empty
        * - Take current if previous empty
        * - Carry forward previous if current empty
        by ind_group: replace all_topic_ids = cond(field_topic_ids != "", ///
            cond(all_topic_ids[_n-1] != "", all_topic_ids[_n-1] + ";" + field_topic_ids, field_topic_ids), ///
            all_topic_ids[_n-1]) if _n > 1
        
        * Propagate final accumulated value to all rows in group
        by ind_group: replace all_topic_ids = all_topic_ids[_N]
        replace field_topic_ids = all_topic_ids
        drop all_topic_ids

        * Accumulate topic_names using same logic (semicolon-separated)
        gen strL all_topic_names = ""
        
        * Initialize first row
        by ind_group: replace all_topic_names = field_topic if _n == 1
        
        * Single-pass: accumulate with semicolon separator
        by ind_group: replace all_topic_names = cond(field_topic != "", ///
            cond(all_topic_names[_n-1] != "", all_topic_names[_n-1] + "; " + field_topic, field_topic), ///
            all_topic_names[_n-1]) if _n > 1
        
        * Propagate final accumulated value to all rows in group
        by ind_group: replace all_topic_names = all_topic_names[_N]
        replace field_topic = all_topic_names
        drop all_topic_names

        * Collapse to one row per indicator
        collapse (firstnm) ind_code (firstnm) field_name (firstnm) field_desc ///
                 (firstnm) field_source (firstnm) field_source_name ///
                 (firstnm) field_topic (firstnm) field_note ///
                 (firstnm) field_source_id (firstnm) field_topic_ids ///
                 (firstnm) field_unit (max) field_limited_data, by(ind_group)
        drop if ind_code == ""

        * Keep only necessary columns for smaller cache footprint
        keep ind_code field_name field_desc field_source field_source_name ///
             field_topic field_note field_source_id field_topic_ids ///
             field_unit field_limited_data
    }
end
