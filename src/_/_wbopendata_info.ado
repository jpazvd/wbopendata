*******************************************************************************
*! _wbopendata_info v2.5.0  21Feb2026
*! Return indicator metadata using shared frame cache (fast after first call)
*! Uses same __wbod_parse_yaml_ind parser as search - fixed block scalars
*! v2.5.0: Bump parser_version to 1.1.0 (invalidate cache after YAML parser fix)
*! v2.4.0: Parse Note field with _website to convert URLs to clickable links
*! v2.3.0: New display layout with separate ID/Name rows. Add unit, limited_data.
*!         Show all topic IDs/names. Add Filters section with clickable commands.
*******************************************************************************

program define _wbopendata_info, rclass
    version 16.0
    syntax , INDICATOR(string)

    local code_raw = strtrim("`indicator'")
    if ("`code_raw'" == "") {
        di as err "indicator() required"
        exit 198
    }

    _wbopendata_get_yaml_path, type(indicators)
    local yaml_path = r(path)

    if (!fileexists("`yaml_path'")) {
        di as error "Indicators metadata not found. Run: wbopendata, sync"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Use shared frame cache (same as __wbopendata_search_cache)
    *---------------------------------------------------------------------------
    local parser_version "1.1.0"
    local frame_name "_wbod_indicators"
    local cache_loaded = 0

    preserve

    * Check if frame already exists with valid data
    capture frame `frame_name': count
    if (_rc == 0 & r(N) > 0) {
        capture frame `frame_name': confirm variable ind_code field_name field_source_id field_source_name field_unit field_limited_data _parser_version
        if (_rc == 0) {
            local cache_loaded = 1
            frame `frame_name' {
                local cache_version = _parser_version[1]
            }
            if ("`cache_version'" != "`parser_version'") {
                local cache_loaded = 0
            }
            if (`cache_loaded') {
                di as text "(Using cached metadata from memory)"
            }
        }
    }

    if (!`cache_loaded') {
        * First call or invalid cache - parse YAML and cache result
        di as text "(Caching metadata in memory...)"
        
        __wbod_parse_yaml_ind "`yaml_path'"
        gen str10 _parser_version = "`parser_version'"

        * Save processed dataset to frame for future use
        capture frame drop `frame_name'
        frame put *, into(`frame_name')
    }
    else {
        * Load cached data from frame via tempfile
        tempfile cache_tmp
        frame `frame_name' {
            quietly save `cache_tmp', replace
        }
        quietly use `cache_tmp', clear
    }

    * Find the requested indicator (case-insensitive)
    quietly {
        gen byte match = upper(ind_code) == upper("`code_raw'")
        keep if match
        drop match
    }

    quietly count
    if (r(N) == 0) {
        di as error "Indicator not found: `code_raw'"
        restore
        exit 111
    }

    *---------------------------------------------------------------------------
    * Extract values from cached frame data safely
    * Use scalar strings and levelsof to handle strL and special characters
    *---------------------------------------------------------------------------
    
    * Simple string fields - direct assignment is safe
    local ind = ind_code[1]
    local src_id = field_source_id[1]
    local topic_ids = field_topic_ids[1]
    local limited_data = field_limited_data[1]
    
    * For strL fields that may contain special characters (:, ", etc.)
    * Use scalar to preserve content without macro expansion issues
    scalar s_name = field_name[1]
    scalar s_desc = field_desc[1]
    scalar s_src = field_source[1]
    scalar s_src_name = field_source_name[1]
    scalar s_topics = field_topic[1]
    scalar s_note = field_note[1]
    scalar s_unit = field_unit[1]
    
    * Convert scalars to locals for display (compound quotes protect special chars)
    local name : di s_name
    local desc : di s_desc
    local src : di s_src
    local src_name : di s_src_name
    local topics : di s_topics
    local note : di s_note
    local unit : di s_unit
    
    * Clean up scalars
    scalar drop s_name s_desc s_src s_src_name s_topics s_note s_unit

    * Handle YAML multi-line markers (shouldn't happen with new parser, but safety check)
    if (`"`src'"' == "|-" | `"`src'"' == "|" | `"`src'"' == ">-" | `"`src'"' == ">") {
        local src ""
    }
    if (`"`desc'"' == "|-" | `"`desc'"' == "|" | `"`desc'"' == ">-" | `"`desc'"' == ">") {
        local desc ""
    }
    if (`"`note'"' == "|-" | `"`note'"' == "|" | `"`note'"' == ">-" | `"`note'"' == ">") {
        local note ""
    }

    * Fallbacks
    if (`"`name'"' == "") local name "N/A"
    if (`"`src_name'"' == "") local src_name "N/A"
    if (`"`topics'"' == "") local topics "N/A"
    if (`"`desc'"' == "") local desc "N/A"
    
    * Note fallback: if YAML note is empty, use source_org (like describe does)
    if (`"`note'"' == "") {
        if (`"`src'"' != "") {
            local note `"`src'"'
        }
        else {
            local note "N/A"
        }
    }
    * Preserve source_org for return list even when used as note
    local source_org `"`src'"'
    if (`"`source_org'"' == "") local source_org "N/A"

    * Build collection string: "ID source_name" format (for backward compatibility)
    local collection "`src_id' `src_name'"
    if ("`src_id'" == "") local collection `"`src_name'"'

    * Parse topic_ids into topic1, topic2, topic3 (matching describe)
    * topic_ids is semicolon-separated, e.g., "18;5"
    local topic1 ""
    local topic2 ""
    local topic3 ""
    if ("`topic_ids'" != "") {
        tokenize "`topic_ids'", parse(";")
        local topic1 = "`1'"
        if ("`3'" != "") local topic2 = "`3'"
        if ("`5'" != "") local topic3 = "`5'"
    }

    * Get first topic ID for browse links
    local first_topic_id "`topic1'"

    * Format topic_ids for display: "11; 5" instead of "11;5"
    local topic_ids_display = subinstr("`topic_ids'", ";", "; ", .)

    * Format topics for display: if multiple, use semicolon-separated
    * The field_topic should already have all topics accumulated
    local topics_display `"`topics'"'

    *---------------------------------------------------------------------------
    * Process Note and Description with _website to convert URLs to clickable links
    * Preserve original text for return list (without SMCL), use processed for display
    *---------------------------------------------------------------------------
    local note_plain `"`note'"'
    local desc_plain `"`desc'"'
    
    * Process note through _website (quietly to suppress its display)
    if (`"`note'"' != "N/A") {
        capture quietly _website, text(`"`note'"')
        if (_rc == 0 & `"`r(text)'"' != "") {
            local note `"`r(text)'"'
        }
    }
    
    * Process description through _website
    if (`"`desc'"' != "N/A") {
        capture quietly _website, text(`"`desc'"')
        if (_rc == 0 & `"`r(text)'"' != "") {
            local desc `"`r(text)'"'
        }
    }

    *---------------------------------------------------------------------------
    * Display with new layout (separate ID/Name rows, unit, limited_data warning)
    *---------------------------------------------------------------------------
    di as text ""
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Indicator}: `ind'{p_end}"'
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Name}: `name'{p_end}"'
    di as text "{hline}"
    
    * Show Unit if not empty
    if (`"`unit'"' != "") {
        di in smcl `"{p 4 4 4}{result:Unit}: `unit'{p_end}"'
        di as text "{hline}"
    }
    
    * Source ID and Source Name on separate lines
    di in smcl `"{p 4 4 4}{result:Source ID}: `src_id'{p_end}"'
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Source}: `src_name'{p_end}"'
    di as text "{hline}"
    
    * Topic ID(s) and Topic(s) on separate lines
    di in smcl `"{p 4 4 4}{result:Topic ID(s)}: `topic_ids_display'{p_end}"'
    di as text "{hline}"
    di in smcl `"{p 4 4 4}{result:Topic(s)}: `topics_display'{p_end}"'
    di as text "{hline}"
    
    * Description
    di in smcl `"{p 4 4 4}{result:Description}: `desc'{p_end}"'
    di as text "{hline}"
    
    * Note
    di in smcl `"{p 4 4 4}{result:Note}: `note'{p_end}"'
    di as text "{hline}"
    
    * Limited data warning
    if (`limited_data' == 1) {
        di as error "{p 4 4 4}{bf:{c 149} Limited data availability}{p_end}"
        di as text "{hline}"
    }
    
    * Filters section with clickable commands
    di as result "Filters:"
    if ("`src_id'" != "") {
        di `"  {stata `"wbopendata, search() searchsource(`src_id')"':[searchsource(`src_id')]}"' _c
    }
    if ("`first_topic_id'" != "") {
        if ("`src_id'" != "") di " | " _c
        di `"  {stata `"wbopendata, search() searchtopic(`first_topic_id')"':[searchtopic(`first_topic_id')]}"'
    }
    else {
        di ""
    }
    di as text "{hline}"
    
    * Download section
    di as result "Download:"
    di `"  {stata `"wbopendata, indicator(`ind') clear"':[Wide format]}"'
    di `"  {stata `"wbopendata, indicator(`ind') clear long"':[Long format]}"'
    di `"  {stata `"wbopendata, indicator(`ind') country(BRA;USA;CHN) clear long"':[Specific countries]}"'
    di as text "{hline}"

    *---------------------------------------------------------------------------
    * Return values - MUST use compound quotes for text with special chars
    * Match _query_metadata return list for compatibility with describe
    * Return plain text versions (without SMCL) for programmatic use
    *---------------------------------------------------------------------------
    * Ensure _rc=0 before returning (capture commands earlier may have set it)
    local _dummy = 1
    
    return local indicator    "`ind'"
    return local name         `"`name'"'
    return local varlabel     `"`name'"'
    return local source       `"`collection'"'
    return local collection   `"`collection'"'
    return local source_id    "`src_id'"
    return local source_name  `"`src_name'"'
    return local source_org   `"`source_org'"'
    return local sourcecite   `"`source_org'"'
    return local description  `"`desc_plain'"'
    return local note         `"`note_plain'"'
    return local unit         `"`unit'"'
    return local limited_data "`limited_data'"
    return local topic1       "`topic1'"
    return local topic2       "`topic2'"
    return local topic3       "`topic3'"
    return local topics       `"`topics'"'
    return local topic_ids    "`topic_ids'"
    return local yaml_path    "`yaml_path'"
    return local cmd          "wbopendata, info(`ind')"

    restore
end
