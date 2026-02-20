*******************************************************************************
*! _yaml_mataread
*! v 1.7.0   19Feb2026               by Joao Pedro Azevedo (UNICEF)
*! Mata-accelerated YAML parser (bulk mode)
*! Translates the canonical parser logic from yaml_read.ado into Mata
*! for 5-15x speedup on large files.
*******************************************************************************

* Define the Mata function (compiled once, persists in memory)
mata:
mata set matastrict off

void _yaml_mata_parse(string scalar filepath,
                      real scalar do_blockscalars)
{
    real scalar fh, n, capacity
    real scalar indent, current_indent, n_levels, level, max_depth
    real scalar list_index, has_pending, colon_pos, was_quoted
    real scalar i, ki, vi, li, pi, ti
    string scalar line, trimmed, pending_line
    string scalar key, value, full_key, vtype, this_parent
    string scalar parent_stack, last_key, item_value
    string scalar block_style, block_val, next_line, next_trim
    real scalar next_indent, block_indent
    real scalar found_level, lv
    string scalar fc, lc

    /* Result vectors (pre-allocated, doubled on overflow) */
    string colvector r_keys, r_values, r_parents, r_types
    real colvector r_levels
    real colvector indent_stack
    string colvector parent_names

    capacity = 50000
    n = 0
    r_keys    = J(capacity, 1, "")
    r_values  = J(capacity, 1, "")
    r_parents = J(capacity, 1, "")
    r_types   = J(capacity, 1, "")
    r_levels  = J(capacity, 1, .)

    /* Parent/indent stack (indexed by level) */
    max_depth = 100
    indent_stack = J(max_depth, 1, 0)
    parent_names = J(max_depth, 1, "")

    /* Parse state */
    current_indent = 0
    n_levels       = 1
    parent_stack   = ""
    last_key       = ""
    list_index     = 0
    has_pending    = 0
    pending_line   = ""
    indent_stack[1] = 0
    parent_names[1] = ""

    fh = fopen(filepath, "r")

    line = fget(fh)
    while (line != J(0, 0, "") | has_pending) {

        /* Handle pending line from look-ahead */
        if (has_pending) {
            line = pending_line
            has_pending = 0
        }

        /* Trim and skip empty/comment lines */
        trimmed = strtrim(line)
        if (trimmed == "" | substr(trimmed, 1, 1) == "#") {
            line = fget(fh)
            continue
        }

        /* Calculate indentation */
        indent = strlen(line) - strlen(strtrim(line))
        /* Handle lines with only leading spaces but strtrim caught content */
        /* Actually strtrim removes both sides; ltrim equivalent: */
        indent = 0
        while (substr(line, indent + 1, 1) == " ") {
            indent++
        }

        /* --- Indent tracking (mirrors yaml_read.ado lines 353-384) --- */
        if (indent > current_indent) {
            n_levels++
            if (n_levels > max_depth) {
                _error("YAML nesting exceeds maximum depth (100)")
            }
            indent_stack[n_levels] = indent
            parent_stack = last_key   /* Update to new parent when going deeper */
            parent_names[n_levels] = parent_stack  /* Store for backtracking */
        }
        else if (indent < current_indent) {
            found_level = 1
            for (lv = n_levels; lv >= 1; lv--) {
                if (indent_stack[lv] == indent) {
                    found_level = lv
                    break
                }
                else if (indent_stack[lv] < indent) {
                    found_level = lv
                    break
                }
            }
            parent_stack = parent_names[found_level]
            n_levels = found_level
        }
        current_indent = indent
        level = n_levels

        /* --- List item handling (mirrors lines 395-472) --- */
        if (substr(trimmed, 1, 2) == "- ") {
            item_value = strtrim(substr(trimmed, 3, .))
            list_index++

            /* Build full key */
            full_key = last_key + "_" + strofreal(list_index)
            if (parent_stack != "" & parent_stack != last_key) {
                if (strpos(last_key, parent_stack) != 1) {
                    full_key = parent_stack + "_" + last_key + "_" + strofreal(list_index)
                }
            }

            vtype = "list_item"
            value = item_value

            /* Parent for list items */
            this_parent = last_key
            if (parent_stack != "" & strpos(last_key, parent_stack) != 1) {
                this_parent = parent_stack + "_" + last_key
            }

            /* Remove quotes from list item value */
            if (strlen(value) >= 2) {
                fc = substr(value, 1, 1)
                lc = substr(value, strlen(value), 1)
                if ((fc == `"""' & lc == `"""') | (fc == "'" & lc == "'")) {
                    value = substr(value, 2, strlen(value) - 2)
                }
            }

            /* Store result */
            n++
            if (n > capacity) {
                capacity = capacity * 2
                r_keys    = r_keys    \ J(capacity - rows(r_keys), 1, "")
                r_values  = r_values  \ J(capacity - rows(r_values), 1, "")
                r_parents = r_parents \ J(capacity - rows(r_parents), 1, "")
                r_types   = r_types   \ J(capacity - rows(r_types), 1, "")
                r_levels  = r_levels  \ J(capacity - rows(r_levels), 1, .)
            }
            r_keys[n]    = full_key
            r_values[n]  = value
            r_levels[n]  = level
            r_parents[n] = this_parent
            r_types[n]   = vtype
        }
        else {
            /* --- Key-value pair handling (mirrors lines 473-678) --- */
            list_index = 0
            colon_pos = strpos(trimmed, ":")

            if (colon_pos > 0) {
                key   = strtrim(substr(trimmed, 1, colon_pos - 1))
                value = strtrim(substr(trimmed, colon_pos + 1, .))
                vtype = ""

                /* Remove quotes */
                was_quoted = 0
                if (strlen(value) >= 2) {
                    fc = substr(value, 1, 1)
                    lc = substr(value, strlen(value), 1)
                    if ((fc == `"""' & lc == `"""') | (fc == "'" & lc == "'")) {
                        value = substr(value, 2, strlen(value) - 2)
                        was_quoted = 1
                    }
                }

                /* --- Block scalar handling (mirrors lines 494-527) --- */
                if (do_blockscalars & (value == "|" | value == "|-" |
                                       value == ">" | value == ">-")) {
                    block_style  = value
                    block_indent = indent
                    block_val    = ""

                    next_line = fget(fh)
                    while (next_line != J(0, 0, "")) {
                        next_trim = strtrim(next_line)
                        next_indent = 0
                        while (substr(next_line, next_indent + 1, 1) == " ") {
                            next_indent++
                        }
                        if (next_trim != "" & next_indent <= block_indent) {
                            pending_line = next_line
                            has_pending  = 1
                            break
                        }
                        if (next_trim != "") {
                            if (block_val == "") {
                                block_val = next_trim
                            }
                            else if (block_style == "|" | block_style == "|-") {
                                block_val = block_val + char(10) + next_trim
                            }
                            else {
                                block_val = block_val + " " + next_trim
                            }
                        }
                        next_line = fget(fh)
                    }
                    value = block_val
                }

                /* --- Continuation lines (mirrors lines 529-553) --- */
                if (value != "" & has_pending == 0 &
                    value != "|" & value != "|-" &
                    value != ">" & value != ">-") {

                    next_line = fget(fh)
                    while (next_line != J(0, 0, "")) {
                        next_trim = strtrim(next_line)
                        next_indent = 0
                        while (substr(next_line, next_indent + 1, 1) == " ") {
                            next_indent++
                        }
                        /* Stop if: shallower/same indent, empty, comment,
                           list item, or key:value */
                        if (next_indent <= indent | next_trim == "" |
                            substr(next_trim, 1, 1) == "#" |
                            substr(next_trim, 1, 2) == "- " |
                            (strpos(next_trim, ":") > 0 &
                             strpos(next_trim, ": ") > 0)) {
                            pending_line = next_line
                            has_pending  = 1
                            break
                        }
                        value = value + " " + next_trim
                        next_line = fget(fh)
                    }
                }

                /* Build full key with parent hierarchy */
                full_key = key
                if (parent_stack != "") {
                    full_key = parent_stack + "_" + key
                }

                /* Clean key name (spaces only - dots/hyphens preserved for entity codes) */
                full_key = subinstr(full_key, " ", "_")
                /* Note: dots and hyphens NOT transformed here - ind_code preserves original format.
                   Field names are sanitized in _yaml_collapse via _yaml_safe_varname(). */

                /* Determine type */
                this_parent = parent_stack

                if (value == "") {
                    vtype    = "parent"
                    last_key = full_key
                }
                else {
                    if (was_quoted) {
                        vtype = "string"
                    }
                    else {
                        /* Numeric test */
                        if (strtoreal(value) != .) {
                            vtype = "numeric"
                        }
                    }
                    /* Boolean */
                    if (vtype == "" &
                        (value == "true"  | value == "True"  | value == "TRUE" |
                         value == "yes"   | value == "Yes"   | value == "YES")) {
                        vtype = "boolean"
                        value = "1"
                    }
                    else if (vtype == "" &
                        (value == "false" | value == "False" | value == "FALSE" |
                         value == "no"    | value == "No"    | value == "NO")) {
                        vtype = "boolean"
                        value = "0"
                    }
                    else if (vtype == "" &
                        (value == "null" | value == "~")) {
                        vtype = "null"
                        value = ""
                    }
                    else if (vtype == "") {
                        vtype = "string"
                    }
                    last_key = full_key
                }

                /* Store result */
                n++
                if (n > capacity) {
                    capacity = capacity * 2
                    r_keys    = r_keys    \ J(capacity - rows(r_keys), 1, "")
                    r_values  = r_values  \ J(capacity - rows(r_values), 1, "")
                    r_parents = r_parents \ J(capacity - rows(r_parents), 1, "")
                    r_types   = r_types   \ J(capacity - rows(r_types), 1, "")
                    r_levels  = r_levels  \ J(capacity - rows(r_levels), 1, .)
                }
                r_keys[n]    = full_key
                r_values[n]  = value
                r_levels[n]  = level
                r_parents[n] = this_parent
                r_types[n]   = vtype

                /* Update parent_stack AFTER storing */
                if (vtype == "parent") {
                    parent_stack = full_key
                }
            }
        }

        /* Read next line if no pending */
        if (has_pending == 0) {
            line = fget(fh)
        }
    }

    fclose(fh)

    /* --- Bulk write results to Stata dataset --- */
    if (n > 0) {
        ki = st_varindex("key")
        vi = st_varindex("value")
        li = st_varindex("level")
        pi = st_varindex("parent")
        ti = st_varindex("type")

        st_addobs(n)

        for (i = 1; i <= n; i++) {
            st_sstore(i, ki, r_keys[i])
            st_sstore(i, vi, r_values[i])
            st_store(i, li, r_levels[i])
            st_sstore(i, pi, r_parents[i])
            st_sstore(i, ti, r_types[i])
        }
    }

    /* Report row count back to ado caller */
    st_local("mata_nrows", strofreal(n))
}

end

program define _yaml_mataread
    version 14.0
    syntax using/ [, BLOCKSCALARS]

    local do_blockscalars = ("`blockscalars'" != "")

    * Call Mata parser (dataset columns already created by yaml_read.ado)
    mata: _yaml_mata_parse("`using'", `do_blockscalars')
end
