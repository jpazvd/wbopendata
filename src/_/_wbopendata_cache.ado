*******************************************************************************
*! _wbopendata_cache v1.0.0  20Jan2026
*! Cache manager for wbopendata YAML metadata (Pathway C)
*******************************************************************************

program define _wbopendata_cache, rclass
    version 14.0

    syntax [, CHECKversion UPDAte FORCe CLEAR INFO]

    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"

    * Only initialize cache (write test) for update operations
    * Read operations (checkversion, info) work without write access
    * Clear uses capture erase, so it handles missing files gracefully
    if ("`update'" != "") {
        _wbopendata_init_cache
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
        _wbopendata_check_version
        if (r(needs_update) == 0 & "`force'" == "") {
            di as text "Metadata is up-to-date (v" r(local_version) ")"
        }
        else {
            _wbopendata_download_yaml, `force'
        }
        return add
        exit 0
    }

    if ("`info'" != "") {
        _wbopendata_cache_info
        return add
        exit 0
    }

    return local cache_dir = "`cache_dir'"
    return scalar cache_exists = fileexists("`cache_dir'metadata_version.txt")
end


program define _wbopendata_init_cache
    version 14.0
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    capture mkdir "`cache_dir'"

    tempname fh
    local test_file = "`cache_dir'_test.tmp"
    capture file open `fh' using "`test_file'", write replace
    if (_rc != 0) {
        di as error "Cannot write to cache directory: `cache_dir'"
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
