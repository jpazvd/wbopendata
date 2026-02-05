*******************************************************************************
*! _wbopendata_get_yaml_path v1.2.0  04Feb2026
*! Resolve YAML path (cache, installed package, or local dev directory)
*******************************************************************************

program define _wbopendata_get_yaml_path, rclass
    version 14.0
    syntax [, TYPE(string)]

    local t = lower("`type'")
    if ("`t'" == "") local t "indicators"

    local fname "_wbopendata_`t'.yaml"

    * 1. Check user's personal cache directory first
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local candidate = "`cache_dir'`fname'"
    if (fileexists("`candidate'")) {
        return local path = "`candidate'"
        exit 0
    }

    * 2. Check installed package directory (ado/plus/_/)
    local plus = c(sysdir_plus) + "_/`fname'"
    if (fileexists("`plus'")) {
        return local path = "`plus'"
        exit 0
    }

    * 3. Search adopath directories (finds dev src/_/ or any adopath location)
    capture findfile `fname'
    if (_rc == 0) {
        return local path = "`r(fn)'"
        exit 0
    }

    * 4. Check current working directory _/ subfolder (for development)
    local cwd_path = c(pwd) + "/_/`fname'"
    if (fileexists("`cwd_path'")) {
        return local path = "`cwd_path'"
        exit 0
    }

    * 5. Check current working directory directly (if cd'd into _/)
    local cwd_direct = c(pwd) + "/`fname'"
    if (fileexists("`cwd_direct'")) {
        return local path = "`cwd_direct'"
        exit 0
    }

    * Return the plus path as default (will trigger "file not found" error if missing)
    return local path = "`plus'"
end
