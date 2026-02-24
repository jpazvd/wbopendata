*! version 1.0.0  09Feb2026
*! Get topic name by ID from topics YAML
*! Part of wbopendata sync preview feature

program define __wbod_get_topic_name, rclass
    version 14.0
    args topic_id
    
    local topic_name ""
    
    __wbod_get_yaml_path, type(topics)
    local top_yaml = r(path)
    
    if (fileexists("`top_yaml'")) {
        preserve
        quietly {
            infix str500 rawline 1-500 using "`top_yaml'", clear
            gen long linenum = _n
            
            * Find the line with the topic ID as key
            * Format is "'XX':" (quotes around ID, then colon)
            * Match lines where trimmed content starts with 'ID':
            local pattern = "'" + "`topic_id'" + "':"
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
                    local topic_name = strtrim(substr("`line'", `colon' + 5, .))
                    * Remove quotes if present
                    local topic_name = subinstr("`topic_name'", "'", "", .)
                    local topic_name : subinstr local topic_name `"""' "", all
                }
            }
        }
        restore
    }
    
    return local topic_name "`topic_name'"
end


