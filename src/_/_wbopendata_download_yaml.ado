*******************************************************************************
*! _wbopendata_download_yaml v1.0.0  20Jan2026
*! Download metadata YAML files from GitHub (Pathway C)
*******************************************************************************

program define _wbopendata_download_yaml, rclass
    version 14.0
    syntax [, FORCe]

    _wbopendata_init_cache
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"

    if ("`force'" == "") {
        _wbopendata_check_version
        if (r(needs_update) == 0) {
            di as text "Metadata is up-to-date (v" r(local_version) ")"
            return scalar sync_success = 0
            exit 0
        }
        local tag = "metadata-v" + r(remote_version)
    }
    else {
        local tag = "main"
    }

    local base "https://raw.githubusercontent.com/jpazvd/wbopendata/`tag'/src/_"
    local files "indicators sources topics"

    foreach f of local files {
        local remote "`base'/_wbopendata_`f'.yaml"
        local local "`cache_dir'_wbopendata_`f'.yaml"
        di as text "Downloading `f'.yaml..."
        capture copy "`remote'" "`local'", replace
        if (_rc != 0) {
            di as error "Failed to download `f'.yaml"
            error 603
        }
    }

    if ("`force'" == "") local ver = r(remote_version)
    else local ver = "forced"

    file open vf using "`cache_dir'metadata_version.txt", write replace
    file write vf "`ver'"
    file close vf

    file open tf using "`cache_dir'cache_timestamp.txt", write replace
    file write tf "`c(current_date)' `c(current_time)'"
    file close tf

    di as result "Metadata updated to v`ver'"
    return scalar sync_success = 1
end
