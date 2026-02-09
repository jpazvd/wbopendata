*******************************************************************************
*! _wbopendata_cache v2.0.0  07Feb2026
*! Cache manager for wbopendata metadata
*! Metadata files (.txt) are installed by `net install` alongside .ado files.
*! sync/update verifies they exist and checks for newer releases on GitHub.
*******************************************************************************

program define _wbopendata_cache, rclass
    version 14.0

    syntax [, CHECKversion UPDAte FORCe CLEAR INFO]

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
            di as text  `"  {stata net install wbopendata, from("C:\GitHub\myados\wbopendata-dev\src") replace force}"'
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


program define _wbopendata_init_cache
    version 14.0
    local personal_dir = c(sysdir_personal)
    local cache_root = c(sysdir_personal) + "wbopendata/"
    local cache_dir = "`cache_root'" + "cache/"
    capture mkdir "`cache_root'"
    capture mkdir "`cache_dir'"

    tempname fh
    local test_file = "`cache_dir'_test.tmp"
    capture file open `fh' using "`test_file'", write replace
    if (_rc != 0) {
        di as error "Cannot write to cache directory: `cache_dir'"
        di as text "Current PERSONAL setting: `personal_dir'"
        di as text "Set a writable PERSONAL directory, then rerun:"
        di as text `"  . sysdir set PERSONAL ""C:/Users/<username>/ado/personal/"""'
        di as text "If the path is correct, create it and retry:"
        di as text `"  . mkdir ""`personal_dir'"""'
        di as text "  . wbopendata, sync"
        error 603
    }
    file close `fh'
    capture erase "`test_file'"
end


program define _wbopendata_clear_cache
    version 14.0
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local files "metadata_version.txt cache_timestamp.txt"
    local files "`files' _wbopendata_indicators.yaml"
    local files "`files' _wbopendata_sources.yaml"
    local files "`files' _wbopendata_topics.yaml"

    foreach f of local files {
        capture erase "`cache_dir'`f'"
    }
end


program define _wbopendata_cache_info, rclass
    version 14.0
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local vf = "`cache_dir'metadata_version.txt"
    local tf = "`cache_dir'cache_timestamp.txt"

    di as text "{hline 60}"
    di as result "wbopendata Cache Status"
    di as text "{hline 60}"

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

    di as text "{hline 60}"
end
