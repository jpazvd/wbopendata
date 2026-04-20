*******************************************************************************
* yaml_validate
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* Validate YAML data
*******************************************************************************

program define yaml_validate, rclass
    version 14.0
    
    syntax [, Required(string) Types(string) Frame(string) Quiet]
    
    * If frame specified, add yaml_ prefix if not present
    if ("`frame'" != "") {
        if (`c(stata_version)' < 16) {
            di as err "frame() option requires Stata 16 or later"
            exit 198
        }
        if (substr("`frame'", 1, 5) != "yaml_") {
            local frame "yaml_`frame'"
        }
        
        * Check frame exists
        capture frame `frame': describe, short
        if (_rc != 0) {
            di as err "frame `frame' not found"
            exit 198
        }
        
        * Run validate in frame context
        frame `frame' {
            _yaml_validate_impl, required("`required'") types("`types'") `quiet'
        }
        return add
    }
    else {
        * Use current dataset
        _yaml_validate_impl, required("`required'") types("`types'") `quiet'
        return add
    }
end

program define _yaml_validate_impl, rclass
    syntax [, Required(string) Types(string) Quiet]
    
    * Ensure required variables exist
    capture confirm variable key value type
    if (_rc != 0) {
        di as err "No YAML data in memory. Use 'yaml read using file.yaml' first."
        exit 198
    }
    
    local valid = 1
    local n_errors = 0
    local n_warnings = 0
    local missing_keys ""
    local type_errors ""
    
    * Check required keys
    if ("`required'" != "") {
        foreach req of local required {
            local req_key = subinstr("`req'", "-", "_", .)
            local req_key = subinstr("`req_key'", " ", "_", .)
            local req_key = subinstr("`req_key'", ".", "_", .)
            
            qui count if key == "`req_key'"
            if (r(N) == 0) {
                local valid = 0
                local n_errors = `n_errors' + 1
                local missing_keys "`missing_keys' `req'"
                
                if ("`quiet'" == "") {
                    di as err "Missing required key: `req'"
                }
            }
        }
    }
    
    * Check types
    if ("`types'" != "") {
        foreach t of local types {
            * Split into key:type
            local pos = strpos("`t'", ":")
            if (`pos' > 0) {
                local tkey = substr("`t'", 1, `pos' - 1)
                local ttype = substr("`t'", `pos' + 1, .)
                
                local tkey = subinstr("`tkey'", "-", "_", .)
                local tkey = subinstr("`tkey'", " ", "_", .)
                local tkey = subinstr("`tkey'", ".", "_", .)
                
                qui count if key == "`tkey'"
                if (r(N) > 0) {
                    * Find the matching row (not necessarily row 1)
                    local actual_type ""
                    forvalues _vi = 1/`=_N' {
                        if (key[`_vi'] == "`tkey'") {
                            local actual_type = type[`_vi']
                            continue, break
                        }
                    }
                    if ("`actual_type'" != "`ttype'") {
                        local valid = 0
                        local n_warnings = `n_warnings' + 1
                        local type_errors "`type_errors' `tkey'"
                        
                        if ("`quiet'" == "") {
                            di as err "Type mismatch for `tkey': expected `ttype', got `actual_type'"
                        }
                    }
                }
            }
        }
    }
    
    * Return results
    return scalar valid = `valid'
    return scalar n_errors = `n_errors'
    return scalar n_warnings = `n_warnings'
    return local missing_keys "`missing_keys'"
    return local type_errors "`type_errors'"
end
