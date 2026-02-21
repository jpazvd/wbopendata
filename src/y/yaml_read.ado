*******************************************************************************
* yaml_read
*! v 1.9.0   20Feb2026               by Joao Pedro Azevedo (UNICEF)
* Read YAML file into Stata (dataset by default, or frame)
* v1.9.0: INDICATORS preset for wbopendata/unicefdata indicator metadata
* v1.8.0: collapse fields() and maxlevel() options for selective columns
* v1.7.0: Mata bulk-load (BULK), collapsed wide-format output (COLLAPSE)
* v1.6.0: Mata st_sstore for embedded quote safety, strL option,
*         block scalar support in canonical parser, continuation lines
*******************************************************************************

program define yaml_read, rclass
    version 14.0
    
    syntax using/ [, Locals Scalars FRAME(string) Prefix(string) Replace Verbose ///
        FASTREAD FIELDS(string) LISTKEYS(string) CACHE(string) ///
        TARGETS(string) EARLYEXIT STREAM BLOCKSCALARS INDEX(string) STRL ///
        BULK COLLAPSE COLFIELDS(string) MAXLEVEL(integer 0) INDICATORS]
    
    * INDICATORS preset: auto-set bulk, collapse, and default colfields
    if ("`indicators'" != "") {
        local bulk "bulk"
        local collapse "collapse"
        * Use standard indicator metadata fields if colfields not specified
        if ("`colfields'" == "") {
            local colfields "code;name;source_id;source_name;description;unit;topic_ids;topic_names;note;limited_data"
        }
    }
    
    * Validate option combinations
    if ("`fastread'" != "" & ("`locals'" != "" | "`scalars'" != "")) {
        di as err "fastread is not compatible with locals/scalars"
        exit 198
    }
    if ("`listkeys'" != "" & "`fastread'" == "") {
        di as err "listkeys() requires fastread"
        exit 198
    }
    if ("`targets'" != "" & "`fastread'" != "") {
        di as err "targets() is not supported with fastread"
        exit 198
    }
    if ("`stream'" != "" & "`fastread'" != "") {
        di as err "stream is not supported with fastread"
        exit 198
    }
    if ("`index'" != "" & "`fastread'" != "") {
        di as err "index() is not supported with fastread"
        exit 198
    }
    if ("`earlyexit'" != "" & "`targets'" == "") {
        di as err "earlyexit requires targets()"
        exit 198
    }
    if ("`bulk'" != "" & "`fastread'" != "") {
        di as err "bulk is not compatible with fastread"
        exit 198
    }
    if ("`bulk'" != "" & ("`locals'" != "" | "`scalars'" != "")) {
        di as err "bulk is not compatible with locals/scalars"
        exit 198
    }
    if ("`collapse'" != "" & "`fastread'" != "") {
        di as err "collapse is not compatible with fastread"
        exit 198
    }
    if ("`collapse'" != "" & ("`locals'" != "" | "`scalars'" != "")) {
        di as err "collapse is not compatible with locals/scalars"
        exit 198
    }
    if ("`colfields'" != "" & "`collapse'" == "") {
        di as err "colfields() requires collapse"
        exit 198
    }
    if (`maxlevel' > 0 & "`collapse'" == "") {
        di as err "maxlevel() requires collapse"
        exit 198
    }
    if ("`colfields'" != "") {
        local colfields_trim = strtrim(subinstr("`colfields'", ";", " ", .))
        if ("`colfields_trim'" == "") {
            di as err "colfields() must include at least one field name"
            exit 198
        }
    }
    if (`maxlevel' < 0) {
        di as err "maxlevel() must be >= 0 (0 = no limit)"
        exit 198
    }
    if ("`fields'" != "") {
        local fields_trim = strtrim(subinstr("`fields'", ";", " ", .))
        if ("`fields_trim'" == "") {
            di as err "fields() must include at least one key"
            exit 198
        }
    }
    if ("`listkeys'" != "") {
        local list_trim = strtrim(subinstr("`listkeys'", ";", " ", .))
        if ("`list_trim'" == "") {
            di as err "listkeys() must include at least one key"
            exit 198
        }
    }
    if ("`index'" != "") {
        if (`c(stata_version)' < 16) {
            di as err "index() option requires Stata 16 or later"
            exit 198
        }
    }

    * Set default prefix
    if ("`prefix'" == "") {
        local prefix "yaml_"
    }
    
    * Check file exists
    confirm file "`using'"

    * Readability + empty-file check
    tempname fh_check
    capture file open `fh_check' using "`using'", read text
    if (_rc != 0) {
        di as err "YAML file not readable: `using'"
        exit 603
    }
    file read `fh_check' line
    if (r(eof) == 1) {
        file close `fh_check'
        di as err "YAML file is empty: `using'"
        exit 198
    }
    file close `fh_check'

    * Parse cache() option (Stata 16+)
    local cache_frame ""
    if ("`cache'" != "") {
        if (`c(stata_version)' < 16) {
            di as err "cache() option requires Stata 16 or later"
            exit 198
        }
        if (strpos("`cache'", "frame=") == 1) {
            local cache_frame = substr("`cache'", 7, .)
        }
        else {
            local cache_frame "`cache'"
        }
        if (substr("`cache_frame'", 1, 5) != "yaml_") {
            local cache_frame "yaml_`cache_frame'"
        }
    }

    * Parse index() option (Stata 16+)
    local index_frame ""
    if ("`index'" != "") {
        if (strpos("`index'", "frame=") == 1) {
            local index_frame = substr("`index'", 7, .)
        }
        else {
            local index_frame "`index'"
        }
        if (substr("`index_frame'", 1, 5) != "yaml_") {
            local index_frame "yaml_`index_frame'"
        }
    }

    * If frame specified, add yaml_ prefix if not present
    if ("`frame'" != "") {
        * Check Stata version for frames support
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
    }
    
    * Compute file checksum if caching
    local file_hash ""
    if ("`cache_frame'" != "") {
        capture checksum "`using'"
        if (_rc != 0) {
            di as err "checksum failed for: `using'"
            exit 198
        }
        local file_hash = r(checksum)
    }

    * Cache hit? (Stata 16+)
    local cache_hit = 0
    local skip_parse = 0
    local yaml_mode = cond("`fastread'" != "", "fastread", "canonical")
    if ("`cache_frame'" != "") {
        capture frame `cache_frame': count
        if (_rc == 0 & r(N) > 0) {
            capture frame `cache_frame': local cache_hash : char _dta[yaml_checksum]
            capture frame `cache_frame': local cache_mode : char _dta[yaml_mode]
            if ("`cache_hash'" == "`file_hash'" & "`cache_mode'" == "`yaml_mode'") {
                if ("`frame'" != "") {
                    if ("`frame'" != "`cache_frame'") {
                        capture frame drop `frame'
                        frame copy `cache_frame' `frame', replace
                    }
                    return local frame "`frame'"
                }
                else {
                    tempfile cache_tmp
                    frame `cache_frame' { quietly save `cache_tmp', replace }
                    quietly use `cache_tmp', clear
                }
                local cache_hit = 1
                local skip_parse = 1
            }
        }
    }

    * Initialize
    local n_keys = 0
    local max_level = 0
    
    if ("`verbose'" != "") {
        di as text "Reading YAML file: " as result "`using'"
        if ("`frame'" != "") {
            di as text "Loading into frame: " as result "`frame'"
        }
        else {
            di as text "Loading into current dataset"
        }
    }
    
    * Determine value storage type
    local val_type = cond("`strl'" != "", "strL", "str2000")

    * Prepare storage location
    if ("`frame'" != "") {
        * Load into frame (explicit request)
        capture frame drop `frame'
        frame create `frame'
        frame `frame' {
            quietly {
                if ("`fastread'" != "") {
                    gen str244 key = ""
                    gen str244 field = ""
                    gen `val_type' value = ""
                    gen byte list = .
                    gen long line = .
                }
                else {
                    gen str244 key = ""
                    gen `val_type' value = ""
                    gen int level = .
                    gen str244 parent = ""
                    gen str32 type = ""
                }
            }
            * Set characteristic to track YAML source
            char _dta[yaml_source] "`using'"
        }
        local use_frame = 1
    }
    else {
        * Load into current dataset (default)
        if ("`replace'" == "") {
            if (_N > 0) {
                di as err "Data in memory would be lost. Use 'replace' option."
                exit 4
            }
        }
        clear
        quietly {
            if ("`fastread'" != "") {
                gen str244 key = ""
                gen str244 field = ""
                gen `val_type' value = ""
                gen byte list = .
                gen long line = .
            }
            else {
                gen str244 key = ""
                gen `val_type' value = ""
                gen int level = .
                gen str244 parent = ""
                gen str32 type = ""
            }
        }
        * Set characteristic to track YAML source
        char _dta[yaml_source] "`using'"
        local use_frame = 0
    }

    * Bulk (Mata) path (opt-in)
    if ("`bulk'" != "" & `skip_parse' == 0) {
        if (`use_frame' == 1) {
            frame `frame' {
                _yaml_mataread using "`using'", `blockscalars'
            }
        }
        else {
            _yaml_mataread using "`using'", `blockscalars'
        }

        * Post-process: clean up and label
        if (`use_frame' == 1) {
            frame `frame' {
                qui drop if key == ""
                qui compress
                label variable key "YAML key name"
                label variable value "YAML value"
                label variable level "Nesting level (1=root)"
                label variable parent "Parent key"
                label variable type "Value type"
                if ("`collapse'" != "") {
                    _yaml_collapse, fields(`colfields') maxlevel(`maxlevel')
                }
            }
        }
        else {
            qui drop if key == ""
            qui compress
            label variable key "YAML key name"
            label variable value "YAML value"
            label variable level "Nesting level (1=root)"
            label variable parent "Parent key"
            label variable type "Value type"
            if ("`collapse'" != "") {
                _yaml_collapse, fields(`colfields') maxlevel(`maxlevel')
            }
        }

        * Cache bulk results if requested
        if ("`cache_frame'" != "") {
            if (`use_frame' == 1) {
                if ("`frame'" != "`cache_frame'") {
                    capture frame drop `cache_frame'
                    frame copy `frame' `cache_frame', replace
                }
            }
            else {
                capture frame drop `cache_frame'
                frame put *, into(`cache_frame')
            }
            frame `cache_frame' {
                char _dta[yaml_source] "`using'"
                char _dta[yaml_checksum] "`file_hash'"
                char _dta[yaml_mode] "bulk"
            }
        }

        return local filename "`using'"
        return local yaml_mode "bulk"
        return scalar cache_hit = 0
        exit 0
    }

    * Fast-read path (opt-in)
    if ("`fastread'" != "" & `skip_parse' == 0) {
        if (`use_frame' == 1) {
            frame `frame' {
                _yaml_fastread using "`using'", fields("`fields'") listkeys("`listkeys'") `blockscalars'
            }
        }
        else {
            _yaml_fastread using "`using'", fields("`fields'") listkeys("`listkeys'") `blockscalars'
        }

        * Cache fastread results if requested
        if ("`cache_frame'" != "") {
            if (`use_frame' == 1) {
                if ("`frame'" != "`cache_frame'") {
                    capture frame drop `cache_frame'
                    frame copy `frame' `cache_frame', replace
                }
            }
            else {
                capture frame drop `cache_frame'
                frame put *, into(`cache_frame')
            }
            frame `cache_frame' {
                char _dta[yaml_source] "`using'"
                char _dta[yaml_checksum] "`file_hash'"
                char _dta[yaml_mode] "fastread"
            }
        }

        return local filename "`using'"
        return local yaml_mode "fastread"
        return scalar cache_hit = 0
        exit 0
    }

    * Fast-read cache hit (skip parse)
    if ("`fastread'" != "" & `skip_parse' == 1) {
        return local filename "`using'"
        return local yaml_mode "fastread"
        return scalar cache_hit = 1
        exit 0
    }

    * Early-exit targets (canonical)
    local earlyexit_on = ("`earlyexit'" != "" | "`targets'" != "")
    local n_targets = 0
    if ("`targets'" != "") {
        local targets_list = lower("`targets'")
        local targets_list = subinstr("`targets_list'", ";", " ", .)
        foreach t of local targets_list {
            local n_targets = `n_targets' + 1
            local target`n_targets' = subinstr("`t'", "-", "_", .)
            local target`n_targets' = subinstr("`target`n_targets''", " ", "_", .)
            local target`n_targets' = subinstr("`target`n_targets''", ".", "_", .)
            local found`n_targets' = 0
        }
    }
    local found_count = 0

    if (`skip_parse' == 0) {
        * Read file line by line
        tempname fh
        file open `fh' using "`using'", read text
        
        local linenum = 0
        local current_indent = 0
        local parent_stack ""
        local n_levels = 1
        local indent_1 = 0
        local parent_1 ""
        local list_index = 0
        local has_pending = 0
        local pending_line ""
        file read `fh' line

        while r(eof) == 0 | `has_pending' == 1 {
        if (`has_pending' == 1) {
            local line `"`pending_line'"'
            local has_pending = 0
        }
        local linenum = `linenum' + 1
        
        * Skip empty lines and comments
        local trimmed = ""
        local indent = 0
        local is_list = 0
        if ("`stream'" != "") {
            _yaml_tokenize_line, line(`"`line'"')
            local trimmed `"`s(trimmed)'"'
            local indent = `s(indent)'
            local is_list = `s(is_list)'
        }
        else {
            local trimmed = strtrim(`"`line'"')
            if (`"`trimmed'"' == "" | substr(`"`trimmed'"', 1, 1) == "#") {
                file read `fh' line
                continue
            }
            * Calculate indentation (count leading spaces)
            local templine `"`line'"'
            while (substr(`"`templine'"', 1, 1) == " ") {
                local indent = `indent' + 1
                local templine = substr(`"`templine'"', 2, .)
            }
        }
        if (`"`trimmed'"' == "" | substr(`"`trimmed'"', 1, 1) == "#") {
            file read `fh' line
            continue
        }
        
        * Handle indent changes to track parent hierarchy
        * We track: indent_N = indent value at level N, parent_N = parent full_key for items at level N
        if (`indent' > `current_indent') {
            * Going deeper - add new indent level
            local n_levels = `n_levels' + 1
            local indent_`n_levels' = `indent'
            * The parent for this new level is the current parent_stack (set by previous parent key)
            local parent_`n_levels' "`parent_stack'"
        }
        else if (`indent' < `current_indent') {
            * Going back up - find the level that matches this indent
            * We want the level where indent_N == indent (sibling level)
            * or the highest level where indent_N < indent (new intermediate level)
            local found_level = 1
            forvalues lv = `n_levels'(-1)1 {
                if (`indent_`lv'' == `indent') {
                    * Exact match - this is a sibling level
                    local found_level = `lv'
                    continue, break
                }
                else if (`indent_`lv'' < `indent') {
                    * This indent is between levels - would be a new level
                    local found_level = `lv'
                    continue, break
                }
            }
            * Restore parent_stack to the parent at that level
            local parent_stack "`parent_`found_level''"
            local n_levels = `found_level'
        }
        * If indent == current_indent, we're at sibling - parent_stack stays same
        local current_indent = `indent'
        
        * Calculate level for display
        local level = `n_levels'
        if (`level' > `max_level') local max_level = `level'
        
        * Check if it's a list item (starts with -)
        if ("`stream'" == "") {
            local is_list = (substr(`"`trimmed'"', 1, 2) == "- ")
        }

        if (`is_list') {
            * List item - store as separate row with type "list_item"
            local item_value = strtrim(substr(`"`trimmed'"', 3, .))
            
            * Increment list index for this parent
            local list_index = `list_index' + 1
            
            * Build the full key: parent_N where N is the index
            local full_key "`last_key'_`list_index'"
            if ("`parent_stack'" != "" & "`parent_stack'" != "`last_key'") {
                * Only prepend parent if last_key doesn't already include it
                if (strpos("`last_key'", "`parent_stack'") != 1) {
                    local full_key "`parent_stack'_`last_key'_`list_index'"
                }
            }
            
            local vtype "list_item"
            local value `"`item_value'"'
            
            * The parent for list items is the list key itself
            local this_parent "`last_key'"
            if ("`parent_stack'" != "" & strpos("`last_key'", "`parent_stack'") != 1) {
                local this_parent "`parent_stack'_`last_key'"
            }
            
            local n_keys = `n_keys' + 1
            
            * Store the list item in frame or dataset
            if (`use_frame' == 1) {
                frame `frame' {
                    local newobs = _N + 1
                    qui set obs `newobs'
                    qui replace key = "`full_key'" in `newobs'
                    mata: st_sstore(`newobs', "value", st_local("value"))
                    qui replace level = `level' in `newobs'
                    qui replace parent = "`this_parent'" in `newobs'
                    qui replace type = "`vtype'" in `newobs'
                }
            }
            else {
                local newobs = _N + 1
                qui set obs `newobs'
                qui replace key = "`full_key'" in `newobs'
                mata: st_sstore(`newobs', "value", st_local("value"))
                qui replace level = `level' in `newobs'
                qui replace parent = "`this_parent'" in `newobs'
                qui replace type = "`vtype'" in `newobs'
            }
            
            * Also accumulate list items in the parent's value for backward compatibility
            if ("`dataset'" != "") {
                * Find and update the parent key's value
                local parent_key "`this_parent'"
                qui count if key == "`parent_key'"
                if (r(N) > 0) {
                    qui replace value = value + " " + "`item_value'" if key == "`parent_key'"
                }
            }
            
            * For locals, append to existing
            if ("`locals'" != "") {
                local `prefix'`last_key' "``prefix'`last_key'' `item_value'"
            }

            * Early-exit check for targets
            if (`earlyexit_on' & `n_targets' > 0) {
                local key_check = lower("`full_key'")
                forvalues ti = 1/`n_targets' {
                    if (`found`ti'' == 0 & "`key_check'" == "`target`ti''") {
                        local found`ti' = 1
                        local found_count = `found_count' + 1
                    }
                }
                if (`found_count' == `n_targets') {
                    continue, break
                }
            }
        }
        else {
            * Reset list index when we encounter a non-list item
            local list_index = 0
            
            * Key-value pair or nested key
            local colon_pos = strpos(`"`trimmed'"', ":")

            if (`colon_pos' > 0) {
                local key = strtrim(substr(`"`trimmed'"', 1, `colon_pos' - 1))
                local value = strtrim(substr(`"`trimmed'"', `colon_pos' + 1, .))
                
                * Reset vtype for this new key-value pair
                local vtype ""
                
                * Remove quotes from value if present (and remember it was quoted)
                local was_quoted = 0
                if (substr(`"`value'"', 1, 1) == `"""' | substr(`"`value'"', 1, 1) == "'") {
                    local value = substr(`"`value'"', 2, length(`"`value'"') - 2)
                    local was_quoted = 1
                }

                * Block scalar handling (|, >, |-, >-)
                if ("`blockscalars'" != "" & inlist(`"`value'"', "|", "|-", ">", ">-")) {
                    local block_style `"`value'"'
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
                        if (`"`next_trim'"' != "" & `next_indent' <= `block_indent') {
                            local pending_line `"`line'"'
                            local has_pending = 1
                            continue, break
                        }
                        if (`"`next_trim'"' != "") {
                            if (`"`block_val'"' == "") {
                                local block_val `"`next_trim'"'
                            }
                            else if ("`block_style'" == "|" | "`block_style'" == "|-") {
                                local block_val = `"`block_val'"' + char(10) + `"`next_trim'"'
                            }
                            else {
                                local block_val = `"`block_val'"' + " " + `"`next_trim'"'
                            }
                        }
                        file read `fh' line
                    }
                    local value `"`block_val'"'
                }

                * Continuation lines: plain scalar spanning multiple lines
                if (`"`value'"' != "" & `has_pending' == 0 & ///
                    !inlist(`"`value'"', "|", "|-", ">", ">-")) {
                    file read `fh' line
                    while (r(eof) == 0) {
                        local next_trim = strtrim(`"`line'"')
                        local next_indent = 0
                        local tmp `"`line'"'
                        while (substr(`"`tmp'"', 1, 1) == " ") {
                            local next_indent = `next_indent' + 1
                            local tmp = substr(`"`tmp'"', 2, .)
                        }
                        * Continuation if: deeper indent, not empty/comment, not list, not key:value
                        if (`next_indent' <= `indent' | `"`next_trim'"' == "" | ///
                            substr(`"`next_trim'"', 1, 1) == "#" | ///
                            substr(`"`next_trim'"', 1, 2) == "- " | ///
                            (strpos(`"`next_trim'"', ":") > 0 & strpos(`"`next_trim'"', ": ") > 0)) {
                            local pending_line `"`line'"'
                            local has_pending = 1
                            continue, break
                        }
                        local value = `"`value'"' + " " + `"`next_trim'"'
                        file read `fh' line
                    }
                }

                * Build full key name with parent hierarchy
                local full_key "`key'"
                if ("`parent_stack'" != "") {
                    local full_key "`parent_stack'_`key'"
                }
                
                * Clean key name (replace spaces and special chars with underscore)
                local full_key = subinstr("`full_key'", " ", "_", .)
                local full_key = subinstr("`full_key'", "-", "_", .)
                local full_key = subinstr("`full_key'", ".", "_", .)
                
                * Create truncated key for locals/scalars (prefix + key <= 32 chars)
                local prefixlen = length("`prefix'")
                local maxkeylen = 32 - `prefixlen'
                if (length("`full_key'") > `maxkeylen') {
                    local short_key = substr("`full_key'", 1, `maxkeylen')
                    if ("`verbose'" != "") {
                        di as text "  (key truncated to `maxkeylen' chars for locals)"
                    }
                }
                else {
                    local short_key "`full_key'"
                }
                
                * Determine type and save current parent for storage
                local this_parent "`parent_stack'"
                
                if (`"`value'"' == "") {
                    local vtype "parent"
                    * This key becomes a parent for nested items AFTER storing
                    local last_key "`full_key'"
                }
                else {
                    * Check if numeric (but quoted values are always strings)
                    if (`was_quoted') {
                        local vtype "string"
                    }
                    else {
                        capture confirm number `value'
                        if (_rc == 0) {
                            local vtype "numeric"
                        }
                    }
                    if ("`vtype'" == "" & inlist(`"`value'"', "true", "True", "TRUE", "yes", "Yes", "YES")) {
                        local vtype "boolean"
                        local value "1"
                    }
                    else if ("`vtype'" == "" & inlist(`"`value'"', "false", "False", "FALSE", "no", "No", "NO")) {
                        local vtype "boolean"
                        local value "0"
                    }
                    else if ("`vtype'" == "" & (`"`value'"' == "null" | `"`value'"' == "~")) {
                        local vtype "null"
                        local value ""
                    }
                    else if ("`vtype'" == "") {
                        local vtype "string"
                    }
                    local last_key "`full_key'"
                }
                
                * Store the key-value pair
                local n_keys = `n_keys' + 1
                
                if (`use_frame' == 1) {
                    frame `frame' {
                        local newobs = _N + 1
                        qui set obs `newobs'
                        qui replace key = "`full_key'" in `newobs'
                        mata: st_sstore(`newobs', "value", st_local("value"))
                        qui replace level = `level' in `newobs'
                        qui replace parent = "`this_parent'" in `newobs'
                        qui replace type = "`vtype'" in `newobs'
                    }
                }
                else {
                    local newobs = _N + 1
                    qui set obs `newobs'
                    qui replace key = "`full_key'" in `newobs'
                    mata: st_sstore(`newobs', "value", st_local("value"))
                    qui replace level = `level' in `newobs'
                    qui replace parent = "`this_parent'" in `newobs'
                    qui replace type = "`vtype'" in `newobs'
                }

                * Update parent_stack AFTER storing (for parent types)
                if ("`vtype'" == "parent") {
                    local parent_stack "`full_key'"
                }

                if ("`locals'" != "") {
                    * Store as return local (using truncated key)
                    if (`"`value'"' != "") {
                        return local `prefix'`short_key' `"`value'"'
                        
                        if ("`verbose'" != "") {
                            di as text "  `prefix'`short_key' = " as result `"`value'"'
                        }
                    }
                }
                
                if ("`scalars'" != "" & "`vtype'" == "numeric") {
                    * Store as scalar (using truncated key)
                    scalar `prefix'`short_key' = real(`"`value'"')
                    
                    if ("`verbose'" != "") {
                        di as text "  scalar `prefix'`short_key' = " as result `value'
                    }
                }

                * Early-exit check for targets
                if (`earlyexit_on' & `n_targets' > 0) {
                    local key_check = lower("`full_key'")
                    forvalues ti = 1/`n_targets' {
                        if (`found`ti'' == 0 & "`key_check'" == "`target`ti''") {
                            local found`ti' = 1
                            local found_count = `found_count' + 1
                        }
                    }
                    if (`found_count' == `n_targets') {
                        continue, break
                    }
                }
            }
        }

        if (`has_pending' == 0) file read `fh' line
    }

        file close `fh'
    }

    * If cache hit, derive counts from loaded data
    if (`skip_parse' == 1) {
        if (`use_frame' == 1) {
            frame `frame' {
                count
                local n_keys = r(N)
                capture confirm variable level
                if (_rc == 0) {
                    qui summarize level, meanonly
                    local max_level = r(max)
                }
            }
        }
        else {
            count
            local n_keys = r(N)
            capture confirm variable level
            if (_rc == 0) {
                qui summarize level, meanonly
                local max_level = r(max)
            }
        }
    }

    * Apply fields() filter (canonical parse)
    if ("`fields'" != "") {
        local fields_list = lower("`fields'")
        local fields_list = subinstr("`fields_list'", ";", " ", .)
        if (`use_frame' == 1) {
            frame `frame' {
                gen byte _keep = 0
                foreach f of local fields_list {
                    replace _keep = 1 if regexm(lower(key), "_`f'$") | lower(key) == "`f'"
                }
                keep if _keep
                drop _keep
            }
        }
        else {
            gen byte _keep = 0
            foreach f of local fields_list {
                replace _keep = 1 if regexm(lower(key), "_`f'$") | lower(key) == "`f'"
            }
            keep if _keep
            drop _keep
        }
    }
    
    * Clean up frame or dataset
    if (`use_frame' == 1) {
        frame `frame' {
            qui drop if key == ""
            qui compress

            * Add variable labels
            label variable key "YAML key name"
            label variable value "YAML value"
            label variable level "Nesting level (1=root)"
            label variable parent "Parent key"
            label variable type "Value type"

            if ("`collapse'" != "") {
                _yaml_collapse, fields(`colfields') maxlevel(`maxlevel')
            }
        }

        if ("`verbose'" != "") {
            frame `frame' {
                di as text ""
                di as text "Loaded " as result _N as text " key-value pairs into frame " as result "`frame'" as text "."
            }
        }

        return local frame "`frame'"
    }
    else {
        * Clean up current dataset (default)
        qui drop if key == ""
        qui compress

        * Add variable labels
        label variable key "YAML key name"
        label variable value "YAML value"
        label variable level "Nesting level (1=root)"
        label variable parent "Parent key"
        label variable type "Value type"

        if ("`collapse'" != "") {
            _yaml_collapse, fields(`colfields') maxlevel(`maxlevel')
        }

        if ("`verbose'" != "") {
            di as text ""
            di as text "Loaded " as result _N as text " key-value pairs into dataset."
        }
    }
    
    * Materialize index frame if requested (canonical)
    if ("`index_frame'" != "") {
        tempfile idx_tmp
        if (`use_frame' == 1) {
            frame `frame' {
                preserve
                keep key value parent type
                sort key
                quietly save `idx_tmp', replace
                restore
            }
        }
        else {
            preserve
            keep key value parent type
            sort key
            quietly save `idx_tmp', replace
            restore
        }
        capture frame drop `index_frame'
        frame create `index_frame'
        frame `index_frame' {
            quietly use `idx_tmp', clear
            char _dta[yaml_source] "`using'"
            char _dta[yaml_checksum] "`file_hash'"
            char _dta[yaml_mode] "canonical"
        }
        if (`use_frame' == 1) {
            frame `frame' {
                char _dta[yaml_index_frame] "`index_frame'"
            }
        }
        else {
            char _dta[yaml_index_frame] "`index_frame'"
        }
    }

    * Cache canonical results if requested
    if ("`cache_frame'" != "" & `cache_hit' == 0) {
        if (`use_frame' == 1) {
            if ("`frame'" != "`cache_frame'") {
                capture frame drop `cache_frame'
                frame copy `frame' `cache_frame', replace
            }
        }
        else {
            capture frame drop `cache_frame'
            frame put *, into(`cache_frame')
        }
        frame `cache_frame' {
            char _dta[yaml_source] "`using'"
            char _dta[yaml_checksum] "`file_hash'"
            char _dta[yaml_mode] "canonical"
        }
    }

    * Return values
    return local filename "`using'"
    return scalar n_keys = `n_keys'
    return scalar max_level = `max_level'
    return local yaml_mode "canonical"
    return scalar cache_hit = `cache_hit'
    
    if ("`verbose'" != "") {
        di as text ""
        di as text "Successfully parsed " as result `n_keys' as text " keys from YAML file."
        di as text "Maximum nesting level: " as result `max_level'
    }

end
