*******************************************************************************
*! _wbopendata_cache v3.0.0  22Feb2026
*! Cache manager for wbopendata metadata
*! v3.0.0: Consolidated disk+frame cache ops; moved cache to sysdir_plus
*******************************************************************************

program define _wbopendata_cache, rclass
    version 14.0

    syntax [, CHECKversion UPDAte FORCe CLEAR INFO CLEARDATACACHE RESETDATACACHE]

    if ("`resetdatacache'" != "") {
        _wbopendata_reset_datacache
        return local datacache_reset = "1"
        exit 0
    }

    if ("`cleardatacache'" != "") {
        _wbopendata_clear_datacache
        return local datacache_cleared = "1"
        exit 0
    }

    if ("`clear'" != "") {
        _wbopendata_clear_cache
        return local cache_cleared = "1"
        exit 0
    }

    if ("`checkversion'" != "") {
        capture noisily _wbopendata_check_version
        if (_rc == 0) return add
        exit 0
    }

    if ("`update'" != "") {
        * 1. Check whether metadata files exist in the adopath
        local missing 0
        foreach f in indicators sources topics {
            _wbopendata_get_yaml_path, type(`f')
            local p = r(path)
            capture confirm file "`p'"
            if (_rc != 0) local missing = `missing' + 1
        }

        if (`missing' > 0) {
            di as text ""
            di as error "Metadata files not found in adopath."
            di as text  "Please reinstall the package:"
            di as text  `"  {stata net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace force}"'
            di as text  ""
            di as text  "Or from SSC:"
            di as text  `"  {stata ssc install wbopendata, replace}"'
            error 601
        }
        else {
            di as text "Metadata files found in adopath."
        }

        * 2. Optionally check for newer version on GitHub
        capture noisily _wbopendata_check_version
        if (_rc == 0) {
            local _remote_ver = r(remote_version)
            local _needs_upd  = r(needs_update)
            local _local_ver  = r(local_version)
            if (`_needs_upd' == 1 & "`force'" == "") {
                di as text ""
                di as result "A newer version (v`_remote_ver') is available."
                di as text   "Current installed: v`_local_ver'"
                di as text   "To update, run:"
                di as text   `"  {stata ado update wbopendata}"'
                di as text   "Or reinstall from source."
            }
            else if (`_needs_upd' == 0) {
                di as text "Package is up-to-date (v`_local_ver')."
            }
        }
        else {
            di as text "(Could not check GitHub for updates — offline or API unavailable.)"
        }

        return add
        exit 0
    }

    if ("`info'" != "") {
        _wbopendata_cache_info
        return add
        exit 0
    }

    * Default: return basic status
    local plus_path = c(sysdir_plus) + "_/_wbopendata_indicators.yaml"
    return scalar cache_exists = fileexists("`plus_path'")
end


program define _wbopendata_clear_cache
    version 14.0
    local cache_dir = c(sysdir_plus) + "_/"

    * Clear disk metadata files
    local files "metadata_version.txt cache_timestamp.txt"
    local files "`files' _wbopendata_indicators.yaml"
    local files "`files' _wbopendata_sources.yaml"
    local files "`files' _wbopendata_topics.yaml"

    foreach f of local files {
        capture erase "`cache_dir'`f'"
    }

    * Clear in-memory frame cache (Stata 16+)
    if (`c(stata_version)' >= 16) {
        capture frame drop _wbod_indicators
        capture frame drop _wbod_sources
        capture frame drop _wbod_topics
    }
end


program define _wbopendata_cache_info, rclass
    version 14.0
    local cache_dir = c(sysdir_plus) + "_/"
    local vf = "`cache_dir'metadata_version.txt"
    local tf = "`cache_dir'cache_timestamp.txt"

    di as text "{hline 60}"
    di as result "wbopendata Cache Status"
    di as text "{hline 60}"

    * Disk cache status
    if (fileexists("`vf'")) {
        tempname fh
        file open `fh' using "`vf'", read
        file read `fh' ver
        file close `fh'
        local ver = trim("`ver'")

        if (fileexists("`tf'")) {
            file open `fh' using "`tf'", read
            file read `fh' ts
            file close `fh'
        }
        else local ts "Unknown"

        di as text `"  Cache location: `cache_dir'"'
        di as text "  Current version: v`ver'"
        di as text `"  Last updated: `ts'"'

        return local cache_version = "`ver'"
        return local cache_timestamp = "`ts'"
        return scalar cache_exists = 1
    }
    else {
        di as text "  Status: No cache found"
        di as text `"  Location: `cache_dir'"'
        di as text "  Run: wbopendata, sync"
        return scalar cache_exists = 0
    }

    * Frame cache status (Stata 16+)
    di as text ""
    if (`c(stata_version)' >= 16) {
        capture frame _wbod_indicators: count
        if (_rc == 0) {
            di as text "  Frame cache:   " as result "_wbod_indicators (`r(N)' records, LOADED)"
        }
        else {
            di as text "  Frame cache:   " as text "(not loaded — will load on first search)"
        }
    }
    else {
        di as text "  Frame cache:   " as text "N/A (requires Stata 16+)"
    }

    * Data cache status
    di as text ""
    local dc_dir = c(sysdir_plus) + "_/_wbopendata_datacache/"
    local dc_dir : subinstr local dc_dir "\" "/" , all
    if (fileexists("`dc_dir'_manifest.txt")) {
        local dc_count = 0
        tempname dfh
        file open `dfh' using "`dc_dir'_manifest.txt", read
        file read `dfh' _dline
        while (r(eof) == 0) {
            local dc_count = `dc_count' + 1
            file read `dfh' _dline
        }
        file close `dfh'
        di as text "  Data cache:    " as result "`dc_count' cached queries"
        di as text `"  Data location: `dc_dir'"'
    }
    else {
        di as text "  Data cache:    " as text "(empty — queries will be cached on first download)"
    }

    di as text "{hline 60}"
end


program define _wbopendata_clear_datacache
    version 14.0
    local dc_dir = c(sysdir_plus) + "_/_wbopendata_datacache/"
    local dc_dir : subinstr local dc_dir "\" "/" , all

    if (!fileexists("`dc_dir'_manifest.txt")) {
        di as text "Data cache is already empty."
        exit 0
    }

    * Count and erase cached CSV files listed in manifest
    local cleared = 0
    capture {
        tempname rfh
        file open `rfh' using "`dc_dir'_manifest.txt", read
        file read `rfh' _line
        while (r(eof) == 0) {
            local _ppos = strpos(`"`_line'"', "|")
            if (`_ppos' > 1) {
                local _ef = trim(substr(`"`_line'"', 1, `_ppos' - 1))
                capture erase "`dc_dir'`_ef'"
                if (_rc == 0) local cleared = `cleared' + 1
            }
            file read `rfh' _line
        }
        file close `rfh'
    }
    if (_rc != 0) {
        capture file close `rfh'
    }

    * Always erase manifest (even if corrupted and unreadable)
    capture erase "`dc_dir'_manifest.txt"

    di as result "Cleared `cleared' cached data file(s)."
end


program define _wbopendata_reset_datacache
    version 14.0
    local dc_dir = c(sysdir_plus) + "_/_wbopendata_datacache/"
    local dc_dir : subinstr local dc_dir "\" "/" , all

    if (!fileexists("`dc_dir'_manifest.txt")) {
        di as text "Data cache is empty — nothing to reset."
        exit 0
    }

    * Rewrite all manifest dates to 01 Jan 2000 (forces expiry on next query)
    local reset_count = 0
    tempfile _tmp_mf
    tempname wfh rfh
    file open `wfh' using "`_tmp_mf'", write

    capture {
        file open `rfh' using "`dc_dir'_manifest.txt", read
        file read `rfh' _line
        while (r(eof) == 0) {
            local _ppos = strpos(`"`_line'"', "|")
            if (`_ppos' > 1) {
                local _ef = trim(substr(`"`_line'"', 1, `_ppos' - 1))
                file write `wfh' "`_ef'|01 Jan 2000" _n
                local reset_count = `reset_count' + 1
            }
            file read `rfh' _line
        }
        file close `rfh'
    }
    if (_rc != 0) {
        capture file close `rfh'
    }

    file close `wfh'

    if (`reset_count' > 0) {
        copy "`_tmp_mf'" "`dc_dir'_manifest.txt", replace
    }

    di as result "Reset TTL for `reset_count' cached data file(s)."
    di as text   "Cached files kept on disk; fresh data will be fetched on next query."
end
