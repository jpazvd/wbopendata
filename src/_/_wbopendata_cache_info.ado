*******************************************************************************
*! _wbopendata_cache_info v1.0.0  04Feb2026
*! Display wbopendata session cache status
*******************************************************************************

program define _wbopendata_cache_info
    version 14.0

    di as text ""
    di as text "{hline 60}"
    di as result "wbopendata Session Cache Status"
    di as text "{hline 60}"

    if (`c(stata_version)' < 16) {
        di as text "Stata version:  " as result "`c(stata_version)'"
        di as text "Cache support:  " as result "No (frames require Stata 16+)"
        di as text "{hline 60}"
        exit 0
    }

    di as text "Stata version:  " as result "`c(stata_version)'"
    di as text "Cache support:  " as result "Yes (frames)"
    di as text ""

    * Check for cached frame
    local frame_name "_wbod_indicators"
    capture frame `frame_name': count

    if (_rc == 0) {
        local n_obs = r(N)
        di as text "Indicators cache:"
        di as text "  Frame:       " as result "`frame_name'"
        di as text "  Records:     " as result "`n_obs'"
        di as text "  Status:      " as result "LOADED"
    }
    else {
        di as text "Indicators cache:"
        di as text "  Status:      " as text "(not loaded - will load on first search)"
    }

    di as text "{hline 60}"
end
