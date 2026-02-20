*******************************************************************************
* yaml_get
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* Get metadata attributes for a specific key
*******************************************************************************

program define yaml_get, rclass
    version 14.0
    syntax anything(name=keyname) [, FRAME(string) ATTRibutes(string) Quiet]
    
    * Determine source - frame or current data
    local use_frame = 0
    local index_frame ""
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
        frame `frame' {
            capture local index_frame : char _dta[yaml_index_frame]
        }
    }
    else {
        * Use current dataset (default)
        capture confirm variable key value
        if (_rc != 0) {
            di as err "No YAML data in current dataset. Load with 'yaml read using file.yaml, replace'"
            exit 198
        }
        capture local index_frame : char _dta[yaml_index_frame]
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
            _yaml_get_impl "`search_prefix'", attributes(`attributes') `quiet' indexframe("`index_frame'")
            * Capture return values before exiting frame block
            local _found = r(found)
            local _n_attrs = r(n_attrs)
            local _return_names : r(macros)
            foreach _rn of local _return_names {
                local _rv_`_rn' `"`r(`_rn')'"'
            }
        }
        * Restore return values outside frame block
        return scalar found = `_found'
        return scalar n_attrs = `_n_attrs'
        foreach _rn of local _return_names {
            if (!inlist("`_rn'", "found", "n_attrs")) {
                return local `_rn' `"`_rv_`_rn''"'
            }
        }
    }
    else {
        _yaml_get_impl "`search_prefix'", attributes(`attributes') `quiet' indexframe("`index_frame'")
        return add
    }
    
    * Return the key searched for
    return local key "`keyname'"
    if ("`parent'" != "") {
        return local parent "`parent'"
    }
end

program define _yaml_get_impl, rclass
    syntax anything(name=search_prefix) [, ATTRibutes(string) Quiet INDEXFRAME(string)]
    
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

    * If index frame provided, use it for faster filtering
    local used_index = 0
    if ("`indexframe'" != "") {
        capture frame `indexframe': describe, short
        if (_rc == 0) {
            frame `indexframe' {
                preserve
                capture confirm variable parent
                local has_parent = (_rc == 0)

                if ("`attributes'" == "") {
                    if (`has_parent') {
                        keep if parent == "`search_prefix'" & type != "parent"
                    }
                    else {
                        keep if strpos(key, "`search_prefix'") == 1
                    }
                    sort key
                    local n = _N
                    forvalues i = 1/`n' {
                        local k = key[`i']
                        local v = value[`i']
                        local t = type[`i']
                        if (`has_parent') {
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
                        else {
                            local prefix_len = length("`search_prefix'")
                            if (substr("`k'", 1, `prefix_len') == "`search_prefix'") {
                                local remainder = substr("`k'", `prefix_len' + 1, .)
                                if (substr("`remainder'", 1, 1) == "_") {
                                    local attr_name = substr("`remainder'", 2, .)
                                    if (strpos("`attr_name'", "_") == 0 & "`t'" != "parent") {
                                        local found = 1
                                        local n_attrs = `n_attrs' + 1
                                        return local `attr_name' `"`v'"'
                                        if ("`quiet'" == "") {
                                            di as text "  `attr_name': " as result `"`v'"'
                                        }
                                    }
                                }
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
                    foreach attr of local attributes {
                        local target_key "`search_prefix'_`attr'"
                        keep if key == "`target_key'"
                        if (_N > 0) {
                            local v = value[1]
                            local found = 1
                            local n_attrs = `n_attrs' + 1
                            return local `attr' `"`v'"'
                            if ("`quiet'" == "") {
                                di as text "  `attr': " as result `"`v'"'
                            }
                        }
                        restore, preserve
                    }
                }
                restore
            }
            local used_index = 1
        }
    }
    if (`used_index') {
        return scalar found = `found'
        return scalar n_attrs = `n_attrs'
        exit
    }

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

    return scalar found = `found'
    return scalar n_attrs = `n_attrs'
end
