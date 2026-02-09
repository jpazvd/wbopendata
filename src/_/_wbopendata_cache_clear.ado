*******************************************************************************
*! _wbopendata_cache_clear v1.0.0  04Feb2026
*! Clear wbopendata session cache frames
*******************************************************************************

program define _wbopendata_cache_clear
    version 14.0
    syntax [, ALL]

    if (`c(stata_version)' < 16) {
        di as text "No frame cache to clear (Stata < 16)"
        exit 0
    }

    local cleared = 0

    * Clear indicators frame
    capture frame drop _wbod_indicators
    if (_rc == 0) {
        di as text "Cleared: _wbod_indicators"
        local cleared = `cleared' + 1
    }

    if ("`all'" != "") {
        * Clear sources and topics frames too (for future expansion)
        capture frame drop _wbod_sources
        if (_rc == 0) {
            di as text "Cleared: _wbod_sources"
            local cleared = `cleared' + 1
        }
        capture frame drop _wbod_topics
        if (_rc == 0) {
            di as text "Cleared: _wbod_topics"
            local cleared = `cleared' + 1
        }
    }

    if (`cleared' == 0) {
        di as text "No cached frames found"
    }
    else {
        di as text ""
        di as text "Cleared `cleared' cached frame(s). Next search will reload from YAML."
    }
end
