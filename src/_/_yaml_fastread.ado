*******************************************************************************
* _yaml_fastread
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* Fast-read parser (opt-in): shallow mappings + list blocks
*
* Data model (differs from canonical parser):
*   key   (str)  - Top-level section header (first-level mapping key)
*   field (str)  - Field name within that section
*   value (str)  - Scalar value or list item text
*   list  (int)  - 1 = list item, 0 = scalar field
*   line  (int)  - Source file line number
*
* Canonical parser produces: key / value / level / parent / type
* Fastread produces:         key / field / value / list  / line
*
* Options:
*   fields(list)       - Keep only these field names (semicolon- or space-separated)
*   listkeys(list)     - Keep list items only under these field names
*   blockscalars       - Capture | and > block scalars (joined with char(10))
*
* Limitations:
*   - Rejects anchors (&), aliases (*), merge keys (<<:)
*   - Rejects flow collections ({ } [ ]) at line start or value position
*   - Designed for shallow YAML (1-2 levels of nesting)
*******************************************************************************

program define _yaml_fastread
    version 14.0

    syntax using/ [, FIELDS(string) LISTKEYS(string) BLOCKSCALARS]

    local fields_list = lower("`fields'")
    local fields_list = subinstr("`fields_list'", ";", " ", .)
    local list_list = lower("`listkeys'")
    local list_list = subinstr("`list_list'", ";", " ", .)

    local use_fields = ("`fields_list'" != "")
    local use_listkeys = ("`list_list'" != "")

    tempname fh
    file open `fh' using "`using'", read text

    local linenum = 0
    local current_key ""
    local current_field ""
    local current_indent = 0
    local n_levels = 0

    local has_pending = 0
    local pending_line ""

    file read `fh' line
    while r(eof) == 0 | `has_pending' == 1 {
        if (`has_pending' == 1) {
            local line `"`pending_line'"'
            local has_pending = 0
        }
        local linenum = `linenum' + 1

        local trimmed = strtrim(`"`line'"')
        if (`"`trimmed'"' == "" | substr(`"`trimmed'"', 1, 1) == "#") {
            if (`has_pending' == 0) file read `fh' line
            continue
        }

        * Unsupported YAML features in fastread: anchors, aliases, merge keys
        if (regexm(`"`trimmed'"', "^&") | regexm(`"`trimmed'"', "^[*]") | ///
            regexm(`"`trimmed'"', "^<<:")) {
            di as err "fastread unsupported YAML feature at line `linenum'. Rerun without fastread."
            exit 198
        }
        * Flow collections: only flag when line or value starts with { or [
        if (substr(`"`trimmed'"', 1, 1) == "{" | substr(`"`trimmed'"', 1, 1) == "[") {
            di as err "fastread unsupported flow collection at line `linenum'. Rerun without fastread."
            exit 198
        }

        * Count indent
        local indent = 0
        local templine `"`line'"'
        while (substr(`"`templine'"', 1, 1) == " ") {
            local indent = `indent' + 1
            local templine = substr(`"`templine'"', 2, .)
        }

        * List item
        if (substr(`"`trimmed'"', 1, 2) == "- ") {
            local item_value = strtrim(substr(`"`trimmed'"', 3, .))
            if (substr(`"`item_value'"', 1, 1) == `"""' | substr(`"`item_value'"', 1, 1) == "'") {
                local item_value = substr(`"`item_value'"', 2, length(`"`item_value'"') - 2)
            }

            local allow_list = 1
            if (`use_listkeys') {
                local allow_list = 0
                foreach lk of local list_list {
                    if (lower("`current_field'") == "`lk'") local allow_list = 1
                }
            }
            else if (`use_fields') {
                local allow_list = 0
                foreach fk of local fields_list {
                    if (lower("`current_field'") == "`fk'") local allow_list = 1
                }
            }

            if (`allow_list' & "`current_key'" != "" & "`current_field'" != "") {
                local newobs = _N + 1
                qui set obs `newobs'
                qui replace key = "`current_key'" in `newobs'
                qui replace field = "`current_field'" in `newobs'
                mata: st_sstore(`newobs', "value", st_local("item_value"))
                qui replace list = 1 in `newobs'
                qui replace line = `linenum' in `newobs'
            }

            if (`has_pending' == 0) file read `fh' line
            continue
        }

        * Key or field line
        local colon_pos = strpos(`"`trimmed'"', ":")
        if (`colon_pos' > 0) {
            local left = strtrim(substr(`"`trimmed'"', 1, `colon_pos' - 1))
            local right = strtrim(substr(`"`trimmed'"', `colon_pos' + 1, .))

            if (`"`right'"' == "") {
                * Header (key)
                if (`indent' > `current_indent') {
                    local n_levels = `n_levels' + 1
                    local indent_`n_levels' = `indent'
                }
                else if (`indent' < `current_indent') {
                    local found_level = 1
                    forvalues lv = `n_levels'(-1)1 {
                        if (`indent_`lv'' <= `indent') {
                            local found_level = `lv'
                            continue, break
                        }
                    }
                    local n_levels = `found_level'
                }

                local key_`n_levels' "`left'"
                local current_indent = `indent'
                local current_key "`key_`n_levels''"
                local current_field ""
            }
            else {
                * Field with value
                local current_field "`left'"
                local value = `"`right'"'
                * Flow collection as value
                if (substr(`"`value'"', 1, 1) == "{" | substr(`"`value'"', 1, 1) == "[") {
                    di as err "fastread unsupported flow collection at line `linenum'. Rerun without fastread."
                    exit 198
                }
                if ("`blockscalars'" == "" & inlist(`"`value'"', "|", "|-", ">", ">-")) {
                    di as err "fastread unsupported block scalar at line `linenum'. Rerun without fastread or use blockscalars."
                    exit 198
                }
                * Optional block scalar capture
                if ("`blockscalars'" != "" & inlist(`"`value'"', "|", "|-", ">", ">-")) {
                    local block_indent = `indent'
                    local block_val ""
                    file read `fh' line
                    while (r(eof) == 0) {
                        local next_trim = strtrim(`"`line'"')
                        local next_indent = 0
                        local tmp `"`line'"'
                        while (substr(`"`tmp'"', 1, 1) == " ") {
                            local next_indent = `next_indent' + 1
                            local tmp = substr(`"`tmp'"', 2, .)
                        }
                        if (`next_indent' <= `block_indent') {
                            local pending_line `"`line'"'
                            local has_pending = 1
                            continue, break
                        }
                        if (`"`block_val'"' == "") {
                            local block_val = strtrim(`"`line'"')
                        }
                        else {
                            local block_val = `"`block_val'"' + char(10) + strtrim(`"`line'"')
                        }
                        file read `fh' line
                    }
                    local value `"`block_val'"'
                }
                if (substr(`"`value'"', 1, 1) == `"""' | substr(`"`value'"', 1, 1) == "'") {
                    local value = substr(`"`value'"', 2, length(`"`value'"') - 2)
                }

                local allow_field = 1
                if (`use_fields') {
                    local allow_field = 0
                    foreach fk of local fields_list {
                        if (lower("`current_field'") == "`fk'") local allow_field = 1
                    }
                }

                if (`allow_field' & "`current_key'" != "") {
                    local newobs = _N + 1
                    qui set obs `newobs'
                    qui replace key = "`current_key'" in `newobs'
                    qui replace field = "`current_field'" in `newobs'
                    mata: st_sstore(`newobs', "value", st_local("value"))
                    qui replace list = 0 in `newobs'
                    qui replace line = `linenum' in `newobs'
                }
            }
        }

        if (`has_pending' == 0) file read `fh' line
    }

    file close `fh'

    qui drop if key == ""
    qui compress

    label variable key "Top-level key"
    label variable field "Field name"
    label variable value "Field value"
    label variable list "List item flag"
    label variable line "Line number"
end
