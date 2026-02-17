*******************************************************************************
*! _wbopendata_download_yaml v1.0.1  17Feb2026
*! Download metadata YAML files from GitHub (Pathway C)
*******************************************************************************

program define _wbopendata_download_yaml, rclass
    version 14.0
    syntax [, FORCe VERSION(string)]

    * --- Inline cache-directory initialisation (cannot call sub-program
    *     _wbopendata_init_cache because it lives inside _wbopendata_cache) ---
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    capture mkdir c(sysdir_personal) + "wbopendata/"
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

    * --- Download YAML metadata from the public repo ---
    * Use version-specific tag if provided, otherwise use main branch
    local ver "`version'"
    if ("`ver'" != "" & "`ver'" != "forced") {
        local base "https://raw.githubusercontent.com/jpazvd/wbopendata/v`ver'/src/_"
    }
    else {
        local base "https://raw.githubusercontent.com/jpazvd/wbopendata/main/src/_"
    }
    local files "indicators sources topics"

    foreach f of local files {
        local remote "`base'/_wbopendata_`f'.yaml"
        local dest   "`cache_dir'_wbopendata_`f'.yaml"
        di as text "Downloading `f'.yaml..."
        capture copy "`remote'" "`dest'", replace
        if (_rc != 0) {
            di as error "Failed to download `f'.yaml (rc = " _rc ")"
            error 603
        }
    }

    * --- Record version & timestamp ---
    if ("`ver'" == "") local ver "forced"

    tempname vfh
    file open `vfh' using "`cache_dir'metadata_version.txt", write replace
    file write `vfh' "`ver'"
    file close `vfh'

    tempname tfh
    file open `tfh' using "`cache_dir'cache_timestamp.txt", write replace
    file write `tfh' "`c(current_date)' `c(current_time)'"
    file close `tfh'

    di as result "Metadata updated to v`ver'"
    return scalar sync_success = 1
end
