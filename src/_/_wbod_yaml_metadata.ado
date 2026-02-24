*! _wbod_yaml_metadata - Look up indicator metadata from cached YAML frame
*! Returns the same r() values as _query_metadata for char attribute compat
*! v1.0.0  23Feb2026  by Joao Pedro Azevedo
*! Extracted from _query_metadata.ado for Stata auto-discovery

program define _wbod_yaml_metadata, rclass
    version 14.0
    syntax , INDICATOR(string) FRAME(string)

    local indicator1 = word("`indicator'", 1)

    * Save current data
    tempfile _orig_data
    quietly save `_orig_data', replace

    * Load from frame
    tempfile _frame_tmp
    frame `frame' {
        quietly save `_frame_tmp', replace
    }
    quietly use `_frame_tmp', clear

    * Find the indicator (case-insensitive)
    quietly gen _match = (upper(ind_code) == upper("`indicator1'"))
    quietly count if _match == 1
    if (r(N) == 0) {
        * Not found in YAML — caller should fall back to API
        quietly use `_orig_data', clear
        return local _yaml_found "0"
        exit 0
    }
    quietly keep if _match == 1
    quietly keep in 1

    * Extract fields
    local _name = field_name[1]
    local _source_id = field_source_id[1]
    local _desc = field_desc[1]
    local _note = field_source[1]
    local _topic = field_topic[1]

    * Derive sourcecite from note (text before first comma/semicolon, max 80)
    local _sourcecite ""
    if (`"`_note'"' != "" & `"`_note'"' != ".") {
        local _sourcecite `"`_note'"'
        local _pos_comma = strpos(`"`_sourcecite'"', ",")
        local _pos_semi = strpos(`"`_sourcecite'"', ";")
        local _pos_uri = strpos(`"`_sourcecite'"', " uri:")
        local _cutpos = 0
        foreach p in _pos_comma _pos_semi _pos_uri {
            if (``p'' > 0) {
                if (`_cutpos' == 0 | ``p'' < `_cutpos') {
                    local _cutpos = ``p''
                }
            }
        }
        if (`_cutpos' > 1) {
            local _sourcecite = substr(`"`_sourcecite'"', 1, `_cutpos' - 1)
        }
        else if (strlen(`"`_sourcecite'"') > 80) {
            local _sourcecite = substr(`"`_sourcecite'"', 1, 80)
        }
        local _sourcecite = trim(`"`_sourcecite'"')
    }

    * Parse topics (semicolon-separated in YAML → topic1, topic2, topic3)
    local _topic1 ""
    local _topic2 ""
    local _topic3 ""
    if (`"`_topic'"' != "" & `"`_topic'"' != ".") {
        * Split on semicolons
        local _rest `"`_topic'"'
        local _tidx = 1
        while (`"`_rest'"' != "" & `_tidx' <= 3) {
            local _spos = strpos(`"`_rest'"', ";")
            if (`_spos' > 0) {
                local _topic`_tidx' = trim(substr(`"`_rest'"', 1, `_spos' - 1))
                local _rest = trim(substr(`"`_rest'"', `_spos' + 1, .))
            }
            else {
                local _topic`_tidx' = trim(`"`_rest'"')
                local _rest ""
            }
            local _tidx = `_tidx' + 1
        }
    }

    * Restore original data
    quietly use `_orig_data', clear

    * Return values matching _query_metadata interface
    return local _yaml_found "1"
    return local source         "`_source_id'"
    return local varlabel       `"`_name'"'
    return local indicator      "`indicator1'"
    return local description    `"`_desc'"'
    return local note           `"`_note'"'
    return local sourcecite     `"`_sourcecite'"'
    return local topic1         "`_topic1'"
    return local topic2         "`_topic2'"
    return local topic3         "`_topic3'"
    return local name           `"`_name'"'
    return local collection     "`_source_id'"
    return scalar nurls = 0
end
