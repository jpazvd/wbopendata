*! version 1.0.0  09Feb2026
*! Get source name by ID from sources YAML
*! Part of wbopendata sync preview feature

program define _wbopendata_get_source_name, rclass
    version 14.0
    args source_id
    
    local source_name ""
    
    _wbopendata_get_yaml_path, type(sources)
    local src_yaml = r(path)
    
    if (fileexists("`src_yaml'")) {
        preserve
        quietly {
            infix str500 rawline 1-500 using "`src_yaml'", clear
            gen long linenum = _n
            
            * Find the line with the source ID as key
            * Format is "'XX':" (quotes around ID, then colon)
            * Match lines where trimmed content starts with 'ID':
            local pattern = "'" + "`source_id'" + "':"
            gen byte is_key = (strtrim(rawline) == "`pattern'")
            sum linenum if is_key, meanonly
            
            if (r(N) > 0) {
                local key_line = r(min)
                * The name line is within next 5 lines after the key
                keep if linenum > `key_line' & linenum <= `key_line' + 5
                keep if strpos(rawline, "name:") > 0
                if (_N > 0) {
                    local line = rawline[1]
                    * Extract value after "name:"
                    local colon = strpos("`line'", "name:")
                    local source_name = strtrim(substr("`line'", `colon' + 5, .))
                    * Remove quotes if present
                    local source_name = subinstr("`source_name'", "'", "", .)
                    local source_name : subinstr local source_name `"""' "", all
                }
            }
        }
        restore
    }
    
    return local source_name "`source_name'"
end
