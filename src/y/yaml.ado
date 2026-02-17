*******************************************************************************
* yaml
*! v 1.3.1   17Dec2025               by Joao Pedro Azevedo (UNICEF)
* Read and write YAML files in Stata
* v1.3.1: Fixed return value propagation from frame context in yaml_get and yaml_list
*         Fixed hyphen-to-underscore normalization in yaml_get search prefix
*******************************************************************************

/*
DESCRIPTION:
    Main command for YAML file operations in Stata.
    Supports reading, writing, and displaying YAML data.
    
    DEFAULT BEHAVIOR: Uses current dataset.
    FRAME OPTION: Use frame(name) to work with Stata frames (16+).
    
SYNTAX:
    yaml read using "filename.yaml" [, frame(name) options]
    yaml write using "filename.yaml" [, frame(name) options]
    yaml describe [, frame(name)]
    yaml list [keys] [, frame(name) options]
    yaml dir [, detail]
    yaml frames [, detail]
    yaml clear [framename] [, all]
    
SUBCOMMANDS:
    read     - Read YAML file into Stata (dataset by default, or frame)
    write    - Write Stata data to YAML file
    describe - Display structure of loaded YAML data
    list     - List specific keys or all keys
    dir      - List all YAML data in memory (dataset and frames)
    frames   - List only YAML frames in memory (Stata 16+)
    clear    - Clear YAML data from memory
    
OPTIONS:
    frame(name) - Use specified frame instead of current dataset
    
EXAMPLES:
    yaml read using "config.yaml", replace    // loads to current dataset
    yaml read using "config.yaml", frame(cfg) // loads to yaml_cfg frame
    yaml describe                             // describes current dataset
    yaml describe, frame(cfg)                 // describes yaml_cfg frame
    yaml list indicators, values              // list values under indicators
    yaml dir, detail                          // list all yaml data in memory
    yaml frames, detail                       // list only yaml frames
    yaml clear                                // clears current dataset
    yaml clear cfg                            // clears yaml_cfg frame
    yaml clear, all                           // clears all yaml frames
    
SEE ALSO:
    help yaml
    
REQUIRES:
    Stata 14.0 (basic functionality)
    Stata 16.0 (for frames support with frame() option)
*/

program define yaml
    version 14.0
    
    gettoken subcmd 0 : 0, parse(" ,")
    
    local subcmd = lower("`subcmd'")
    
    if ("`subcmd'" == "read") {
        yaml_read `0'
    }
    else if ("`subcmd'" == "write") {
        yaml_write `0'
    }
    else if ("`subcmd'" == "describe" | "`subcmd'" == "desc") {
        yaml_describe `0'
    }
    else if ("`subcmd'" == "list") {
        yaml_list `0'
    }
    else if ("`subcmd'" == "get") {
        yaml_get `0'
    }
    else if ("`subcmd'" == "dir") {
        yaml_dir `0'
    }
    else if ("`subcmd'" == "frames" | "`subcmd'" == "frame") {
        yaml_frames `0'
    }
    else if ("`subcmd'" == "clear") {
        yaml_clear `0'
    }
    else if ("`subcmd'" == "validate" | "`subcmd'" == "check") {
        yaml_validate `0'
    }
    else if ("`subcmd'" == "") {
        di as err "subcommand required"
        di as err "syntax: yaml {read|write|describe|list|get|validate|dir|frames|clear} ..."
        exit 198
    }
    else {
        di as err "unknown subcommand: `subcmd'"
        di as err "valid subcommands: read, write, describe, list, get, validate, dir, frames, clear"
        exit 198
    }
end


*******************************************************************************
* yaml read - Read YAML file into Stata
*******************************************************************************

program define yaml_read, rclass
    version 14.0
    
    syntax using/ [, Locals Scalars FRAME(string) Prefix(string) Replace Verbose]
    
    * Set default prefix
    if ("`prefix'" == "") {
        local prefix "yaml_"
    }
    
    * Check file exists
    confirm file "`using'"
    
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
    
    * Prepare storage location
    if ("`frame'" != "") {
        * Load into frame (explicit request)
        capture frame drop `frame'
        frame create `frame'
        frame `frame' {
            quietly {
                gen str244 key = ""
                gen str2000 value = ""
                gen int level = .
                gen str244 parent = ""
                gen str32 type = ""
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
            gen str244 key = ""
            gen str2000 value = ""
            gen int level = .
            gen str244 parent = ""
            gen str32 type = ""
        }
        * Set characteristic to track YAML source
        char _dta[yaml_source] "`using'"
        local use_frame = 0
    }
    
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
        file read `fh' line
    
    while r(eof) == 0 {
        local linenum = `linenum' + 1
        
        * Skip empty lines and comments
        local trimmed = strtrim("`line'")
        if ("`trimmed'" == "" | substr("`trimmed'", 1, 1) == "#") {
            file read `fh' line
            continue
        }
        
        * Calculate indentation (count leading spaces)
        local indent = 0
        local templine "`line'"
        while (substr("`templine'", 1, 1) == " ") {
            local indent = `indent' + 1
            local templine = substr("`templine'", 2, .)
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
        local is_list = (substr("`trimmed'", 1, 2) == "- ")
        
        if (`is_list') {
            * List item - store as separate row with type "list_item"
            local item_value = strtrim(substr("`trimmed'", 3, .))
            
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
            local value "`item_value'"
            
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
                    qui replace value = `"`value'"' in `newobs'
                    qui replace level = `level' in `newobs'
                    qui replace parent = "`this_parent'" in `newobs'
                    qui replace type = "`vtype'" in `newobs'
                }
            }
            else {
                local newobs = _N + 1
                qui set obs `newobs'
                qui replace key = "`full_key'" in `newobs'
                qui replace value = `"`value'"' in `newobs'
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
        }
        else {
            * Reset list index when we encounter a non-list item
            local list_index = 0
            
            * Key-value pair or nested key
            local colon_pos = strpos("`trimmed'", ":")
            
            if (`colon_pos' > 0) {
                local key = strtrim(substr("`trimmed'", 1, `colon_pos' - 1))
                local value = strtrim(substr("`trimmed'", `colon_pos' + 1, .))
                
                * Reset vtype for this new key-value pair
                local vtype ""
                
                * Remove quotes from value if present (and remember it was quoted)
                local was_quoted = 0
                if (substr("`value'", 1, 1) == `"""' | substr("`value'", 1, 1) == "'") {
                    local value = substr("`value'", 2, length("`value'") - 2)
                    local was_quoted = 1
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
                
                if ("`value'" == "") {
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
                    if ("`vtype'" == "" & inlist("`value'", "true", "True", "TRUE", "yes", "Yes", "YES")) {
                        local vtype "boolean"
                        local value "1"
                    }
                    else if ("`vtype'" == "" & inlist("`value'", "false", "False", "FALSE", "no", "No", "NO")) {
                        local vtype "boolean"
                        local value "0"
                    }
                    else if ("`vtype'" == "" & ("`value'" == "null" | "`value'" == "~")) {
                        local vtype "null"
                        local value ""
                    }
                    else if ("`vtype'" == "") {
                        local vtype "string"
                    }
                    local last_key "`full_key'"
                }
                
                local n_keys = `n_keys' + 1
                
                * Store the value in frame or dataset
                if (`use_frame' == 1) {
                    * Add row to frame
                    frame `frame' {
                        local newobs = _N + 1
                        qui set obs `newobs'
                        qui replace key = "`full_key'" in `newobs'
                        qui replace value = `"`value'"' in `newobs'
                        qui replace level = `level' in `newobs'
                        qui replace parent = "`this_parent'" in `newobs'
                        qui replace type = "`vtype'" in `newobs'
                    }
                }
                else {
                    * Add row to current dataset (default)
                    local newobs = _N + 1
                    qui set obs `newobs'
                    qui replace key = "`full_key'" in `newobs'
                    qui replace value = `"`value'"' in `newobs'
                    qui replace level = `level' in `newobs'
                    qui replace parent = "`this_parent'" in `newobs'
                    qui replace type = "`vtype'" in `newobs'
                }
                
                * Now update parent_stack AFTER storing (for parent types)
                if ("`vtype'" == "parent") {
                    local parent_stack "`full_key'"
                }
                
                if ("`locals'" != "") {
                    * Store as return local (using truncated key)
                    if ("`value'" != "") {
                        return local `prefix'`short_key' `"`value'"'
                        
                        if ("`verbose'" != "") {
                            di as text "  `prefix'`short_key' = " as result `"`value'"'
                        }
                    }
                }
                
                if ("`scalars'" != "" & "`vtype'" == "numeric") {
                    * Store as scalar (using truncated key)
                    scalar `prefix'`short_key' = real("`value'")
                    
                    if ("`verbose'" != "") {
                        di as text "  scalar `prefix'`short_key' = " as result `value'
                    }
                }
            }
        }
        
        file read `fh' line
    }
    
    file close `fh'
    
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
        
        if ("`verbose'" != "") {
            di as text ""
            di as text "Loaded " as result _N as text " key-value pairs into dataset."
        }
    }
    
    * Return values
    return local filename "`using'"
    return scalar n_keys = `n_keys'
    return scalar max_level = `max_level'
    
    if ("`verbose'" != "") {
        di as text ""
        di as text "Successfully parsed " as result `n_keys' as text " keys from YAML file."
        di as text "Maximum nesting level: " as result `max_level'
    }

end


*******************************************************************************
* yaml write - Write Stata data to YAML file
*******************************************************************************

program define yaml_write
    version 14.0
    
    syntax using/ [, Scalars(string) FRAME(string) Replace Verbose ///
                     INDENT(integer 2) HEADER(string)]
    
    * If frame specified, add yaml_ prefix if not present
    if ("`frame'" != "") {
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
    }
    
    * Check if file exists and handle replace
    capture confirm file "`using'"
    if (_rc == 0 & "`replace'" == "") {
        di as err "file `using' already exists. Use 'replace' option."
        exit 602
    }
    
    * Open file for writing
    tempname fh
    file open `fh' using "`using'", write text replace
    
    * Write header comment if specified
    if ("`header'" != "") {
        file write `fh' "# `header'" _n
    }
    else {
        file write `fh' "# Generated by Stata yaml write" _n
        file write `fh' "# Date: `c(current_date)' `c(current_time)'" _n
    }
    file write `fh' _n
    
    local n_written = 0
    
    * Write from scalars
    if ("`scalars'" != "") {
        foreach sc of local scalars {
            capture confirm scalar `sc'
            if (_rc == 0) {
                local val = `sc'
                file write `fh' "`sc': `val'" _n
                local n_written = `n_written' + 1
                
                if ("`verbose'" != "") {
                    di as text "  `sc': " as result "`val'"
                }
            }
        }
    }
    
    * Write from frame or dataset
    if ("`frame'" != "") {
        * Write from specified frame
        capture frame `frame': describe, short
        if (_rc != 0) {
            di as err "frame `frame' not found"
            file close `fh'
            exit 198
        }
        frame `frame' {
            _yaml_write_data `fh', indent(`indent') verbose(`verbose')
        }
        local n_written = r(n_written)
    }
    else if ("`scalars'" == "") {
        * Write from current dataset (default when no scalars)
        * Check required variables exist
        capture confirm variable key value
        if (_rc != 0) {
            di as err "dataset must have 'key' and 'value' variables"
            file close `fh'
            exit 198
        }
        
        * Check for level variable for indentation
        capture confirm variable level
        local has_level = (_rc == 0)
        
        local n = _N
        local prev_level = 1
        
        forvalues i = 1/`n' {
            local k = key[`i']
            local v = value[`i']
            
            if (`has_level') {
                local lev = level[`i']
            }
            else {
                local lev = 1
            }
            
            * Create indentation
            local spaces ""
            forvalues j = 1/`=(`lev'-1)*`indent'' {
                local spaces "`spaces' "
            }
            
            * Get type if available
            capture confirm variable type
            if (_rc == 0) {
                local t = type[`i']
            }
            else {
                local t "string"
            }
            
            * Write based on type
            if ("`t'" == "parent") {
                file write `fh' "`spaces'`k':" _n
            }
            else if ("`t'" == "list_item") {
                * Write as YAML list item with dash prefix
                file write `fh' "`spaces'- `v'" _n
            }
            else if ("`v'" != "") {
                file write `fh' "`spaces'`k': `v'" _n
            }
            
            local n_written = `n_written' + 1
        }
    }
    
    file close `fh'
    
    if ("`verbose'" != "") {
        di as text ""
        di as text "Wrote " as result `n_written' as text " entries to " as result "`using'"
    }
    
    di as text "YAML file saved: " as result "`using'"
    
end


*******************************************************************************
* yaml describe - Display structure of loaded YAML data
*******************************************************************************

program define yaml_describe
    version 14.0
    syntax [, LEVEL(integer 99) FRAME(string)]
    
    * Determine source - frame or current data
    if ("`frame'" != "") {
        * Check Stata version for frames
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        * Add yaml_ prefix if not present
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
        * Check frame exists
        capture frame `frame': describe, short
        if (_rc != 0) {
            di as err "frame `frame' not found"
            exit 198
        }
        frame `frame' {
            _yaml_describe_impl, level(`level')
        }
    }
    else {
        * Use current dataset (default)
        capture confirm variable key value level
        if (_rc != 0) {
            di as err "No YAML data in current dataset. Load with 'yaml read using file.yaml, replace'"
            exit 198
        }
        _yaml_describe_impl, level(`level')
    }
end

program define _yaml_describe_impl
    syntax [, LEVEL(integer 99)]
    
    capture confirm variable key value level
    if (_rc != 0) {
        di as err "No YAML data found."
        exit 198
    }
    
    di as text ""
    di as text "{hline 70}"
    di as text "{bf:YAML Structure}"
    di as text "{hline 70}"
    
    local n = _N
    forvalues i = 1/`n' {
        local k = key[`i']
        local v = value[`i']
        local l = level[`i']
        local t = type[`i']
        
        * Skip if beyond requested level
        if (`l' > `level') continue
        
        * Create indentation
        local spaces ""
        forvalues j = 1/`=`l'-1' {
            local spaces "`spaces'  "
        }
        
        if ("`t'" == "parent") {
            di as text "`spaces'" as result "`k'" as text ":"
        }
        else {
            local display_val = substr("`v'", 1, 40)
            if (length("`v'") > 40) local display_val "`display_val'..."
            di as text "`spaces'" as result "`k'" as text ": " as text `"`display_val'"'
        }
    }
    
    di as text "{hline 70}"
    di as text "Total keys: " as result `n'
    di as text "{hline 70}"
end


*******************************************************************************
* yaml get - Get metadata attributes for a specific key (e.g., indicator code)
*******************************************************************************

program define yaml_get, rclass
    version 14.0
    syntax anything(name=keyname) [, FRAME(string) ATTRibutes(string) Quiet]
    
    * Determine source - frame or current data
    local use_frame = 0
    if ("`frame'" != "") {
        * Check Stata version for frames
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        * Add yaml_ prefix if not present
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
        * Check frame exists
        capture frame `frame': describe, short
        if (_rc != 0) {
            di as err "frame `frame' not found"
            exit 198
        }
        local use_frame = 1
    }
    else {
        * Use current dataset (default)
        capture confirm variable key value
        if (_rc != 0) {
            di as err "No YAML data in current dataset. Load with 'yaml read using file.yaml, replace'"
            exit 198
        }
    }
    
    * Clean up keyname (remove quotes if present)
    local keyname = subinstr("`keyname'", `"""', "", .)
    local keyname = strtrim("`keyname'")
    
    * Check for colon syntax (parent:key) - e.g., indicators:CME_MRY0T4
    local colon_pos = strpos("`keyname'", ":")
    if (`colon_pos' > 0) {
        local parent = substr("`keyname'", 1, `colon_pos' - 1)
        local keyname = substr("`keyname'", `colon_pos' + 1, .)
        local search_prefix "`parent'_`keyname'"
    }
    else {
        local parent ""
        local search_prefix "`keyname'"
    }
    
    * Clean search_prefix - convert special chars to underscores (to match how keys are stored)
    local search_prefix = subinstr("`search_prefix'", "-", "_", .)
    local search_prefix = subinstr("`search_prefix'", " ", "_", .)
    local search_prefix = subinstr("`search_prefix'", ".", "_", .)
    
    * Search for attributes
    if (`use_frame' == 1) {
        frame `frame' {
            _yaml_get_impl "`search_prefix'", attributes(`attributes') `quiet'
        }
        * Return values are set by _yaml_get_impl via return add
        return add
    }
    else {
        _yaml_get_impl "`search_prefix'", attributes(`attributes') `quiet'
        return add
    }
    
    * Return the key searched for
    return local key "`keyname'"
    if ("`parent'" != "") {
        return local parent "`parent'"
    }
end

program define _yaml_get_impl, rclass
    syntax anything(name=search_prefix) [, ATTRibutes(string) Quiet]
    
    * Clean up search prefix - remove any quotes
    local search_prefix = subinstr(`"`search_prefix'"', `"""', "", .)
    local search_prefix = strtrim("`search_prefix'")
    
    * Find all keys that are children of this key (using parent variable)
    * Pattern: parent == search_prefix (e.g., parent == "indicators_CME_MRY0T4")
    
    local found = 0
    local n = _N
    local n_attrs = 0
    
    * Check if parent variable exists
    capture confirm variable parent
    local has_parent = (_rc == 0)
    
    * If no specific attributes requested, get all
    if ("`attributes'" == "") {
        * Find all children of this key using parent variable
        forvalues i = 1/`n' {
            local k = key[`i']
            local v = value[`i']
            local t = type[`i']
            
            if (`has_parent') {
                local p = parent[`i']
                
                * Check if this key's parent matches our search prefix
                if ("`p'" == "`search_prefix'" & "`t'" != "parent") {
                    * Extract attribute name (remove parent prefix from key)
                    local plen = length("`search_prefix'")
                    if (substr("`k'", 1, `plen') == "`search_prefix'" & substr("`k'", `plen'+1, 1) == "_") {
                        local attr_name = substr("`k'", `plen' + 2, .)
                    }
                    else {
                        local attr_name "`k'"
                    }
                    
                    local found = 1
                    local n_attrs = `n_attrs' + 1
                    return local `attr_name' `"`v'"'
                    
                    if ("`quiet'" == "") {
                        di as text "  `attr_name': " as result `"`v'"'
                    }
                }
            }
            else {
                * Fallback: use key prefix matching
                local prefix_len = length("`search_prefix'")
                if (substr("`k'", 1, `prefix_len') == "`search_prefix'") {
                    local remainder = substr("`k'", `prefix_len' + 1, .)
                    
                    * If remainder starts with underscore, it's a child attribute
                    if (substr("`remainder'", 1, 1) == "_") {
                        local attr_name = substr("`remainder'", 2, .)
                        
                        * Only get immediate children (no more underscores)
                        if (strpos("`attr_name'", "_") == 0 & "`t'" != "parent") {
                            local found = 1
                            local n_attrs = `n_attrs' + 1
                            return local `attr_name' `"`v'"'
                            
                            if ("`quiet'" == "") {
                                di as text "  `attr_name': " as result `"`v'"'
                            }
                        }
                    }
                    * Exact match - return the value itself
                    else if ("`remainder'" == "" & "`t'" != "parent") {
                        local found = 1
                        local n_attrs = `n_attrs' + 1
                        return local value `"`v'"'
                        
                        if ("`quiet'" == "") {
                            di as text "  value: " as result `"`v'"'
                        }
                    }
                }
            }
        }
    }
    else {
        * Get specific attributes
        foreach attr of local attributes {
            local target_key "`search_prefix'_`attr'"
            
            forvalues i = 1/`n' {
                local k = key[`i']
                local v = value[`i']
                
                if ("`k'" == "`target_key'") {
                    local found = 1
                    local n_attrs = `n_attrs' + 1
                    return local `attr' `"`v'"'
                    
                    if ("`quiet'" == "") {
                        di as text "  `attr': " as result `"`v'"'
                    }
                }
            }
        }
    }
    
    if (`found' == 0) {
        if ("`quiet'" == "") {
            di as text "(no attributes found for `search_prefix')"
        }
    }
    
    return scalar found = `found'
    return scalar n_attrs = `n_attrs'
end


*******************************************************************************
* yaml list - List specific keys or all keys
*******************************************************************************

program define yaml_list, rclass
    version 14.0
    syntax [anything] [, NOHeader Keys Values SEParator(string) CHILDren STATA FRAME(string)]
    
    * Determine source - frame or current data
    if ("`frame'" != "") {
        * Check Stata version for frames
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        * Add yaml_ prefix if not present
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
        * Check frame exists
        capture frame `frame': describe, short
        if (_rc != 0) {
            di as err "frame `frame' not found"
            exit 198
        }
        frame `frame' {
            _yaml_list_impl `anything', `noheader' `keys' `values' separator(`separator') `children' `stata'
        }
        * Copy return values from frame execution
        return add
    }
    else {
        * Use current dataset (default)
        capture confirm variable key value
        if (_rc != 0) {
            di as err "No YAML data in current dataset. Load with 'yaml read using file.yaml, replace'"
            exit 198
        }
        _yaml_list_impl `anything', `noheader' `keys' `values' separator(`separator') `children' `stata'
        return add
    }
end

program define _yaml_list_impl, rclass
    syntax [anything] [, NOHeader Keys Values SEParator(string) CHILDren STATA]
    
    capture confirm variable key value
    if (_rc != 0) {
        di as err "No YAML data found."
        exit 198
    }
    
    * Default separator - if stata format requested, use compound quotes
    if ("`stata'" != "") {
        local sep_start `" `""'
        local sep_end `"""'
    }
    else if ("`separator'" == "") {
        local sep_start " "
        local sep_end ""
    }
    else {
        local sep_start "`separator'"
        local sep_end ""
    }
    
    if ("`anything'" == "") {
        * List all
        if ("`keys'" != "" | "`values'" != "") {
            * Return all keys or values as delimited list
            local result_keys ""
            local result_values ""
            local n = _N
            forvalues i = 1/`n' {
                local k = key[`i']
                local v = value[`i']
                if ("`result_keys'" == "") {
                    if ("`stata'" != "") {
                        local result_keys `"`"`k'"'"'
                        local result_values `"`"`v'"'"'
                    }
                    else {
                        local result_keys "`k'"
                        local result_values `"`v'"'
                    }
                }
                else {
                    if ("`stata'" != "") {
                        local result_keys `"`result_keys' `"`k'"'"'
                        local result_values `"`result_values' `"`v'"'"'
                    }
                    else {
                        local result_keys "`result_keys'`sep_start'`k'`sep_end'"
                        local result_values `"`result_values'`sep_start'`v'`sep_end'"'
                    }
                }
            }
            if ("`keys'" != "") {
                return local keys `"`result_keys'"'
                di as text "Keys: " as result `"`result_keys'"'
            }
            if ("`values'" != "") {
                return local values `"`result_values'"'
                di as text "Values: " as result `"`result_values'"'
            }
        }
        else {
            list key value type, `noheader'
        }
    }
    else {
        * Filter by parent/pattern
        local pattern "`anything'"
        
        * Create match variable
        tempvar match is_child
        qui gen `match' = 0
        qui gen `is_child' = 0
        
        * Match keys that start with the pattern (children of that parent)
        if ("`children'" != "") {
            * Use parent variable to find immediate children
            * A key is an immediate child if its parent equals the pattern
            capture confirm variable parent
            if (_rc == 0) {
                qui replace `is_child' = 1 if parent == "`pattern'"
            }
            else {
                * Fallback: use key prefix matching
                qui replace `is_child' = 1 if strpos(key, "`pattern'_") == 1
                * Exclude grandchildren (keys with more than one underscore after pattern)
                qui replace `is_child' = 0 if regexm(substr(key, length("`pattern'_") + 1, .), "_")
            }
            qui replace `match' = `is_child'
        }
        else {
            * Match any key containing the pattern
            qui replace `match' = 1 if strpos(key, "`pattern'") > 0
        }
        
        if ("`keys'" != "" | "`values'" != "") {
            * Return matching keys/values as delimited list
            local result_keys ""
            local result_values ""
            local n = _N
            forvalues i = 1/`n' {
                if (`match'[`i'] == 1) {
                    local k = key[`i']
                    local v = value[`i']
                    
                    * For children option, extract just the child name (remove parent prefix)
                    if ("`children'" != "") {
                        local plen = length("`pattern'")
                        if (substr("`k'", 1, `plen') == "`pattern'" & substr("`k'", `plen'+1, 1) == "_") {
                            local k = substr("`k'", `plen' + 2, .)
                        }
                    }
                    
                    if ("`result_keys'" == "") {
                        if ("`stata'" != "") {
                            local result_keys `"`"`k'"'"'
                            local result_values `"`"`v'"'"'
                        }
                        else {
                            local result_keys "`k'"
                            local result_values `"`v'"'
                        }
                    }
                    else {
                        if ("`stata'" != "") {
                            local result_keys `"`result_keys' `"`k'"'"'
                            local result_values `"`result_values' `"`v'"'"'
                        }
                        else {
                            local result_keys "`result_keys'`sep_start'`k'`sep_end'"
                            local result_values `"`result_values'`sep_start'`v'`sep_end'"'
                        }
                    }
                }
            }
            if ("`keys'" != "") {
                return local keys `"`result_keys'"'
                di as text "Keys under `pattern': " as result `"`result_keys'"'
            }
            if ("`values'" != "") {
                return local values `"`result_values'"'
                di as text "Values under `pattern': " as result `"`result_values'"'
            }
            return local parent "`pattern'"
        }
        else {
            list key value type if `match' == 1, `noheader'
        }
        drop `match' `is_child'
    }
end


*******************************************************************************
* yaml clear - Clear YAML data from memory (dataset or frames)
*******************************************************************************

program define yaml_clear
    version 14.0
    syntax [anything] [, ALL]
    
    local frame_to_clear = trim("`anything'")
    
    if ("`all'" != "") {
        * Clear all yaml_* frames (requires Stata 16)
        if (`c(stata_version)' < 16) {
            di as err "The 'all' option requires Stata 16 or later for frames"
            exit 198
        }
        local cleared = 0
        quietly frames dir
        local all_frames `r(frames)'
        foreach fr of local all_frames {
            if (substr("`fr'", 1, 5) == "yaml_") {
                frame drop `fr'
                local cleared = `cleared' + 1
            }
        }
        if (`cleared' > 0) {
            di as text "`cleared' YAML frame(s) cleared from memory."
        }
        else {
            di as text "No YAML frames in memory."
        }
    }
    else if ("`frame_to_clear'" != "") {
        * Clear specific frame (requires Stata 16)
        if (`c(stata_version)' < 16) {
            di as err "Clearing frames requires Stata 16 or later"
            exit 198
        }
        local target_frame = "`frame_to_clear'"
        if (substr("`target_frame'", 1, 5) != "yaml_") {
            local target_frame "yaml_`target_frame'"
        }
        capture frame drop `target_frame'
        if (_rc == 0) {
            di as text "Frame `target_frame' cleared from memory."
        }
        else {
            di as error "Frame `target_frame' not found."
            exit 198
        }
    }
    else {
        * Clear current dataset (default)
        capture confirm variable key value level parent type
        if (_rc == 0) {
            clear
            di as text "YAML data cleared from current dataset."
        }
        else {
            di as text "No YAML data in current dataset."
        }
    }
end


*******************************************************************************
* yaml validate - Validate YAML data against requirements
*******************************************************************************

program define yaml_validate, rclass
    version 14.0
    syntax [, FRAME(string) REQuired(string) TYpes(string) Quiet]
    
    * Determine source - frame or current data
    local use_frame = 0
    if ("`frame'" != "") {
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
        capture frame `frame': describe, short
        if (_rc != 0) {
            di as err "frame `frame' not found"
            exit 198
        }
        local use_frame = 1
    }
    else {
        capture confirm variable key value level parent type
        if (_rc != 0) {
            di as err "No YAML data in current dataset. Load with 'yaml read using file.yaml, replace'"
            exit 198
        }
    }
    
    local n_errors = 0
    local n_warnings = 0
    local n_checked = 0
    local missing_keys ""
    local type_errors ""
    
    if ("`quiet'" == "") {
        di as text "{hline 60}"
        di as text "YAML Validation Report"
        di as text "{hline 60}"
    }
    
    * Check required keys
    if ("`required'" != "") {
        if ("`quiet'" == "") {
            di as text ""
            di as text "{bf:Required Keys Check:}"
        }
        
        foreach req of local required {
            local n_checked = `n_checked' + 1
            local found = 0
            
            if (`use_frame' == 1) {
                frame `frame' {
                    qui count if key == "`req'" | strpos(key, "`req'_") == 1
                    local found = (r(N) > 0)
                }
            }
            else {
                qui count if key == "`req'" | strpos(key, "`req'_") == 1
                local found = (r(N) > 0)
            }
            
            if (`found') {
                if ("`quiet'" == "") {
                    di as text "  ✓ " as result "`req'" as text " - found"
                }
            }
            else {
                local n_errors = `n_errors' + 1
                local missing_keys "`missing_keys' `req'"
                if ("`quiet'" == "") {
                    di as error "  ✗ `req' - MISSING"
                }
            }
        }
    }
    
    * Check types if specified (format: "key:type key:type")
    if ("`types'" != "") {
        if ("`quiet'" == "") {
            di as text ""
            di as text "{bf:Type Validation:}"
        }
        
        foreach typespec of local types {
            local n_checked = `n_checked' + 1
            
            * Parse key:expected_type
            local colon_pos = strpos("`typespec'", ":")
            if (`colon_pos' > 0) {
                local check_key = substr("`typespec'", 1, `colon_pos' - 1)
                local expected_type = substr("`typespec'", `colon_pos' + 1, .)
                
                local actual_type ""
                local actual_value ""
                
                if (`use_frame' == 1) {
                    frame `frame' {
                        qui count if key == "`check_key'"
                        if (r(N) > 0) {
                            qui levelsof type if key == "`check_key'", local(actual_type) clean
                            qui levelsof value if key == "`check_key'", local(actual_value) clean
                        }
                    }
                }
                else {
                    qui count if key == "`check_key'"
                    if (r(N) > 0) {
                        qui levelsof type if key == "`check_key'", local(actual_type) clean
                        qui levelsof value if key == "`check_key'", local(actual_value) clean
                    }
                }
                
                if ("`actual_type'" == "") {
                    local n_warnings = `n_warnings' + 1
                    if ("`quiet'" == "") {
                        di as text "  ? " as result "`check_key'" as text " - key not found, cannot check type"
                    }
                }
                else if ("`actual_type'" == "`expected_type'") {
                    if ("`quiet'" == "") {
                        di as text "  ✓ " as result "`check_key'" as text " - type `expected_type' ✓"
                    }
                }
                else {
                    * Special handling: numeric can match boolean (0/1)
                    if ("`expected_type'" == "numeric" & "`actual_type'" == "boolean") {
                        if ("`quiet'" == "") {
                            di as text "  ✓ " as result "`check_key'" as text " - type boolean (numeric compatible)"
                        }
                    }
                    else {
                        local n_errors = `n_errors' + 1
                        local type_errors "`type_errors' `check_key'"
                        if ("`quiet'" == "") {
                            di as error "  ✗ `check_key' - expected `expected_type', got `actual_type'"
                        }
                    }
                }
            }
        }
    }
    
    * Validate structure (check for orphaned children)
    if ("`quiet'" == "") {
        di as text ""
        di as text "{bf:Structure Validation:}"
    }
    
    local orphans = 0
    if (`use_frame' == 1) {
        frame `frame' {
            * Check if any parent references don't exist as keys
            qui count if parent != "" & type != "parent"
            local n_children = r(N)
            
            * Simple structure check - count levels
            qui sum level
            local max_level = r(max)
            local n_keys = _N
        }
    }
    else {
        qui count if parent != "" & type != "parent"
        local n_children = r(N)
        qui sum level
        local max_level = r(max)
        local n_keys = _N
    }
    
    if ("`quiet'" == "") {
        di as text "  Total keys: " as result `n_keys'
        di as text "  Max nesting depth: " as result `max_level'
        di as text "  Child elements: " as result `n_children'
    }
    
    * Summary
    if ("`quiet'" == "") {
        di as text ""
        di as text "{hline 60}"
    }
    
    if (`n_errors' == 0) {
        if ("`quiet'" == "") {
            di as result "Validation PASSED" as text " - `n_checked' checks, 0 errors"
        }
        return scalar valid = 1
    }
    else {
        if ("`quiet'" == "") {
            di as error "Validation FAILED" as text " - `n_checked' checks, `n_errors' error(s)"
            if ("`missing_keys'" != "") {
                di as text "  Missing keys:" as error "`missing_keys'"
            }
            if ("`type_errors'" != "") {
                di as text "  Type errors:" as error "`type_errors'"
            }
        }
        return scalar valid = 0
        return scalar n_errors = `n_errors'
        return scalar n_warnings = `n_warnings'
        return scalar n_checked = `n_checked'
        return local missing_keys "`missing_keys'"
        return local type_errors "`type_errors'"
        
        if ("`quiet'" == "") {
            di as text "{hline 60}"
        }
        
        * Exit with error code so callers can detect validation failure
        exit 9
    }
    
    if ("`quiet'" == "") {
        di as text "{hline 60}"
    }
    
    return scalar n_errors = `n_errors'
    return scalar n_warnings = `n_warnings'
    return scalar n_checked = `n_checked'
    return local missing_keys "`missing_keys'"
    return local type_errors "`type_errors'"
end


*******************************************************************************
* yaml dir - List all YAML data in memory (dataset and frames)
*******************************************************************************

program define yaml_dir, rclass
    version 14.0
    syntax [, DETail]
    
    local total_count = 0
    local frame_count = 0
    local dataset_loaded = 0
    
    di as text ""
    di as text "{hline 60}"
    di as text "YAML Data in Memory"
    di as text "{hline 60}"
    
    * -------------------------------------------------------------------------
    * Check current dataset for YAML data
    * -------------------------------------------------------------------------
    * YAML data is identified by having the standard variables: key, value, level, parent, type
    * and the characteristic _dta[yaml_source] set by yaml read
    
    local has_yaml_vars = 0
    capture confirm variable key value level parent type
    if (_rc == 0) {
        local has_yaml_vars = 1
    }
    
    local yaml_source : char _dta[yaml_source]
    
    if (`has_yaml_vars' == 1) {
        local dataset_loaded = 1
        local total_count = `total_count' + 1
        
        if ("`yaml_source'" != "") {
            * YAML was loaded via yaml read
            if ("`detail'" != "") {
                quietly count
                local nobs = r(N)
                di as text "  Current dataset: {result:YAML loaded} ({result:`nobs'} entries)"
                di as text "                   Source: `yaml_source'"
            }
            else {
                di as text "  Current dataset: {result:YAML loaded} - `yaml_source'"
            }
        }
        else {
            * Has YAML structure but no source characteristic
            if ("`detail'" != "") {
                quietly count
                local nobs = r(N)
                di as text "  Current dataset: {result:YAML structure detected} ({result:`nobs'} entries)"
                di as text "                   (source unknown - not loaded via yaml read)"
            }
            else {
                di as text "  Current dataset: {result:YAML structure detected}"
            }
        }
    }
    else {
        di as text "  Current dataset: (no YAML data)"
    }
    
    * -------------------------------------------------------------------------
    * Check frames for YAML data (Stata 16+)
    * -------------------------------------------------------------------------
    
    if (`c(stata_version)' >= 16) {
        di as text ""
        di as text "  YAML Frames (yaml_* prefix):"
        
        quietly frames dir
        local all_frames `r(frames)'
        
        foreach fr of local all_frames {
            if (substr("`fr'", 1, 5) == "yaml_") {
                local frame_count = `frame_count' + 1
                local total_count = `total_count' + 1
                local yaml_name = substr("`fr'", 6, .)
                
                if ("`detail'" != "") {
                    * Get observation count and source
                    frame `fr' {
                        quietly count
                        local nobs = r(N)
                        local fr_source : char _dta[yaml_source]
                    }
                    if ("`fr_source'" != "") {
                        di as text "    `frame_count'. {cmd:`yaml_name'} ({result:`nobs'} entries)"
                        di as text "       Source: `fr_source'"
                    }
                    else {
                        di as text "    `frame_count'. {cmd:`yaml_name'} ({result:`nobs'} entries)"
                    }
                }
                else {
                    di as text "    `frame_count'. {cmd:`yaml_name'}"
                }
            }
        }
        
        if (`frame_count' == 0) {
            di as text "    (no YAML frames loaded)"
        }
    }
    else {
        di as text ""
        di as text "  YAML Frames: (requires Stata 16+)"
    }
    
    di as text "{hline 60}"
    if (`c(stata_version)' >= 16) {
        di as text "Total: `total_count' YAML source(s) in memory"
        di as text "       (`dataset_loaded' in dataset, `frame_count' in frames)"
    }
    else {
        di as text "Total: `dataset_loaded' YAML source(s) in current dataset"
    }
    di as text ""
    
    * Return results
    return scalar n_total = `total_count'
    return scalar n_frames = `frame_count'
    return scalar n_dataset = `dataset_loaded'
end


*******************************************************************************
* yaml frames - List only YAML frames in memory (requires Stata 16+)
*******************************************************************************

program define yaml_frames, rclass
    version 14.0
    syntax [, DETail]
    
    * Check Stata version - frames require Stata 16+
    if (`c(stata_version)' < 16) {
        di as err "yaml frames requires Stata 16 or later"
        di as err "Use {cmd:yaml dir} to check YAML data in current dataset"
        exit 198
    }
    
    local frame_count = 0
    
    di as text ""
    di as text "{hline 60}"
    di as text "YAML Frames in Memory"
    di as text "{hline 60}"
    
    quietly frames dir
    local all_frames `r(frames)'
    
    foreach fr of local all_frames {
        if (substr("`fr'", 1, 5) == "yaml_") {
            local frame_count = `frame_count' + 1
            local yaml_name = substr("`fr'", 6, .)
            
            if ("`detail'" != "") {
                * Get observation count and source
                frame `fr' {
                    quietly count
                    local nobs = r(N)
                    local fr_source : char _dta[yaml_source]
                }
                if ("`fr_source'" != "") {
                    di as text "  `frame_count'. {cmd:`yaml_name'} ({result:`nobs'} entries)"
                    di as text "     Source: `fr_source'"
                }
                else {
                    di as text "  `frame_count'. {cmd:`yaml_name'} ({result:`nobs'} entries)"
                }
            }
            else {
                di as text "  `frame_count'. {cmd:`yaml_name'}"
            }
        }
    }
    
    if (`frame_count' == 0) {
        di as text "  (no YAML frames loaded)"
    }
    
    di as text "{hline 60}"
    di as text "Total: `frame_count' YAML frame(s)"
    di as text ""
    
    * Return results
    return scalar n_frames = `frame_count'
end


*******************************************************************************
* Helper program to manage parent stack based on indentation
*******************************************************************************

program define _yaml_pop_parents, sclass
    syntax, indent(integer) parent_stack(string) indent_stack(string)
    
    * Pop indent levels that are >= current indent
    local new_indent_stack ""
    local new_parent_stack ""
    local count = 0
    
    foreach i of local indent_stack {
        if (`i' < `indent') {
            local new_indent_stack "`new_indent_stack' `i'"
            local count = `count' + 1
        }
    }
    
    * Rebuild parent stack (simplified - just keep last parent at lower indent)
    if (`count' <= 1) {
        local new_parent_stack ""
    }
    else {
        * Keep parent stack but trim to match indent level
        local nwords : word count `parent_stack'
        if (`nwords' > 0) {
            local pos = 0
            forvalues j = 1/`=length("`parent_stack'")' {
                if (substr("`parent_stack'", `j', 1) == "_") {
                    local pos = `j'
                }
            }
            if (`pos' > 0 & `count' <= 2) {
                local new_parent_stack = substr("`parent_stack'", 1, `pos' - 1)
            }
            else {
                local new_parent_stack "`parent_stack'"
            }
        }
    }
    
    sreturn local indent_stack "`new_indent_stack'"
    sreturn local parent_stack "`new_parent_stack'"
end
