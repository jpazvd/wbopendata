*******************************************************************************
*! _wbopendata_sync_preview v1.0.0  09Feb2026
*! Display metadata status diagnostic before sync
*! Author: João Pedro Azevedo (World Bank | UNICEF)
*! Contact: https://jpazvd.github.io
*! License: MIT
*******************************************************************************

program define _wbopendata_sync_preview, rclass
    version 14.0
    syntax [, DETAIL]

    *---------------------------------------------------------------------------
    * 1. Resolve cache directory and paths
    *---------------------------------------------------------------------------
    local cache_base "`c(sysdir_personal)'wbopendata/"
    local cache_base : subinstr local cache_base "\" "/" , all
    local cache_dir "`cache_base'cache/"

    local vf "`cache_dir'metadata_version.txt"
    local tf "`cache_dir'cache_timestamp.txt"
    local mf "`cache_dir'cache_metadata.yaml"

    *---------------------------------------------------------------------------
    * 2. Read cache metadata
    *---------------------------------------------------------------------------
    local has_cache = 0
    local cache_ver = ""
    local cache_ts = ""
    local cache_method = ""

    if (fileexists("`vf'")) {
        local has_cache = 1
        tempname fh
        file open `fh' using "`vf'", read
        file read `fh' cache_ver
        file close `fh'
        local cache_ver = strtrim("`cache_ver'")
    }

    if (fileexists("`tf'")) {
        tempname fh
        file open `fh' using "`tf'", read
        file read `fh' cache_ts
        file close `fh'
        local cache_ts = strtrim("`cache_ts'")
    }

    * Parse method from cache_metadata.yaml if available
    if (fileexists("`mf'")) {
        tempname fh
        file open `fh' using "`mf'", read
        file read `fh' line
        while r(eof) == 0 {
            if (strpos("`line'", "method:") > 0) {
                local cache_method = strtrim(subinstr("`line'", "method:", "", 1))
                continue, break
            }
            file read `fh' line
        }
        file close `fh'
    }

    *---------------------------------------------------------------------------
    * 3. Count indicators/sources/topics from cached YAML metadata
    *---------------------------------------------------------------------------
    local ind_count = 0
    local src_count = 0
    local top_count = 0

    _wbopendata_get_yaml_path, type(indicators)
    local ind_yaml = r(path)
    if (fileexists("`ind_yaml'")) {
        * Read total_indicators from _metadata section
        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            gen byte has_total = strpos(rawline, "total_indicators:") > 0
            sum has_total, meanonly
            if (r(max) == 1) {
                keep if has_total
                keep in 1
                local line = rawline[1]
                local colon = strpos("`line'", ":")
                local val = strtrim(substr("`line'", `colon' + 1, .))
                local ind_count = real("`val'")
                if missing(`ind_count') local ind_count = 0
            }
        }
        restore
    }

    _wbopendata_get_yaml_path, type(sources)
    local src_yaml = r(path)
    if (fileexists("`src_yaml'")) {
        * Read total_sources from _metadata section
        preserve
        quietly {
            infix str500 rawline 1-500 using "`src_yaml'", clear
            gen byte has_total = strpos(rawline, "total_sources:") > 0
            sum has_total, meanonly
            if (r(max) == 1) {
                keep if has_total
                keep in 1
                local line = rawline[1]
                local colon = strpos("`line'", ":")
                local val = strtrim(substr("`line'", `colon' + 1, .))
                local src_count = real("`val'")
                if missing(`src_count') local src_count = 0
            }
        }
        restore
    }

    _wbopendata_get_yaml_path, type(topics)
    local top_yaml = r(path)
    if (fileexists("`top_yaml'")) {
        * Read total_topics from _metadata section
        preserve
        quietly {
            infix str500 rawline 1-500 using "`top_yaml'", clear
            gen byte has_total = strpos(rawline, "total_topics:") > 0
            sum has_total, meanonly
            if (r(max) == 1) {
                keep if has_total
                keep in 1
                local line = rawline[1]
                local colon = strpos("`line'", ":")
                local val = strtrim(substr("`line'", `colon' + 1, .))
                local top_count = real("`val'")
                if missing(`top_count') local top_count = 0
            }
        }
        restore
    }

    *---------------------------------------------------------------------------
    * 4. Check Python availability
    *---------------------------------------------------------------------------
    local python_ok = 0
    local python_ver = ""
    capture shell python -V 2>&1
    if (_rc == 0) {
        local python_ok = 1
        * Try to capture version (best effort)
        tempfile pyver
        capture shell python -V > "`pyver'" 2>&1
        if (_rc == 0 & fileexists("`pyver'")) {
            tempname fh
            capture file open `fh' using "`pyver'", read
            if (_rc == 0) {
                file read `fh' python_ver
                file close `fh'
                local python_ver = strtrim("`python_ver'")
            }
        }
    }

    *---------------------------------------------------------------------------
    * 5. Check remote version (optional, may fail if offline)
    *---------------------------------------------------------------------------
    local remote_ver = ""
    local needs_update = 0
    local check_success = 0
    capture noisily _wbopendata_check_version
    if (_rc == 0) {
        local remote_ver = r(remote_version)
        local needs_update = r(needs_update)
        local check_success = r(check_success)
    }

    *---------------------------------------------------------------------------
    * 6. Quick API check for current indicator count
    *---------------------------------------------------------------------------
    local api_ind_count = .
    capture {
        _api_read, parameter(total)
        local api_ind_count = r(total1)
    }

    *---------------------------------------------------------------------------
    * 7. Display diagnostic
    *---------------------------------------------------------------------------
    di as text ""
    di as text "{hline 70}"
    di as result "wbopendata Metadata Status"
    di as text "{hline 70}"
    di ""

    if (`has_cache') {
        di as text "  Cache Status"
        di as text "  {hline 40}"
        di as text "  Version:          " as result "v`cache_ver'"
        di as text "  Last sync:        " as result "`cache_ts'"
        if ("`cache_method'" != "") {
            di as text "  Sync method:      " as result "`cache_method'"
        }
        di ""
        di as text "  Cached Records"
        di as text "  {hline 40}"
        local ind_fmt : di %9.0fc `ind_count'
        local src_fmt : di %9.0fc `src_count'
        local top_fmt : di %9.0fc `top_count'
        di as text "  Indicators:       " as result "`ind_fmt'"
        di as text "  Sources:          " as result "`src_fmt'"
        di as text "  Topics:           " as result "`top_fmt'"
    }
    else {
        di as text "  Cache Status:     " as error "Not found"
        di as text "  Location:         " as text "`cache_dir'"
    }

    * Show API comparison if available
    if (`api_ind_count' != .) {
        di ""
        di as text "  Remote Status (WB API)"
        di as text "  {hline 40}"
        local api_fmt : di %9.0fc `api_ind_count'
        di as text "  API indicators:   " as result "`api_fmt'"
        if (`has_cache' & `ind_count' > 0) {
            local diff = `api_ind_count' - `ind_count'
            if (`diff' > 0) {
                di as text "  Change:           " as result "+`diff' new"
            }
            else if (`diff' < 0) {
                local diff_abs = abs(`diff')
                di as text "  Change:           " as result "`diff_abs' removed"
            }
            else {
                di as text "  Change:           " as result "none (up to date)"
            }
        }
    }

    * Show remote version check
    if (`check_success') {
        di ""
        di as text "  GitHub Release"
        di as text "  {hline 40}"
        di as text "  Latest version:   " as result "v`remote_ver'"
        if (`needs_update') {
            di as text "  Status:           " as result "Update available"
        }
        else {
            di as text "  Status:           " as result "Up to date"
        }
    }

    * Show sync pathway
    di ""
    di as text "  Sync Pathway"
    di as text "  {hline 40}"
    if (`python_ok') {
        if ("`python_ver'" != "") {
            di as text "  Python:           " as result "available (`python_ver')"
        }
        else {
            di as text "  Python:           " as result "available"
        }
        di as text "  Will use:         " as result "Python canonical"
    }
    else {
        di as text "  Python:           " as text "not detected"
        di as text "  Will use:         " as result "Stata fallback"
    }

    di ""
    di as text "{hline 70}"
    di ""
    di as text "Actions:"
    di ""
    di `"  {stata wbopendata, sync:  Sync metadata now}"'
    di `"  {stata wbopendata, sync force:  Force sync (even if fresh)}"'
    if (`python_ok') {
        di `"  {stata wbopendata, sync forcestata:  Force Stata pathway}"'
    }
    else {
        di `"  {stata wbopendata, sync forcepython:  Force Python pathway}"'
    }
    di ""
    di `"  {stata wbopendata, sources:  View sources}"'
    di `"  {stata wbopendata, alltopics:  View topics}"'
    di `"  {stata wbopendata, search(GDP):  Search indicators}"'
    di ""
    di as text "{hline 70}"

    *---------------------------------------------------------------------------
    * 8. Return values
    *---------------------------------------------------------------------------
    return scalar has_cache = `has_cache'
    return scalar ind_count = `ind_count'
    return scalar src_count = `src_count'
    return scalar top_count = `top_count'
    return scalar python_available = `python_ok'
    return scalar needs_update = `needs_update'
    if (`api_ind_count' != .) return scalar api_ind_count = `api_ind_count'
    if ("`cache_ver'" != "") return local cache_version = "`cache_ver'"
    if ("`cache_ts'" != "") return local cache_timestamp = "`cache_ts'"
    if ("`cache_method'" != "") return local cache_method = "`cache_method'"
    if ("`remote_ver'" != "") return local remote_version = "`remote_ver'"
end
