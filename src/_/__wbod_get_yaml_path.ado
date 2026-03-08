*******************************************************************************
*! __wbod_get_yaml_path v2.0.0  22Feb2026
*! Resolve YAML path via adopath (findfile) with sysdir_plus fallback
*******************************************************************************

program define __wbod_get_yaml_path, rclass
    version 14.0
    syntax [, TYPE(string)]

    local t = lower("`type'")
    if ("`t'" == "") local t "indicators"

    local fname "_wbopendata_`t'.yaml"

    * Primary: search adopath (covers sysdir_plus/_/, dev src/_/, adopath ++ dirs)
    capture findfile `fname'
    if (_rc == 0) {
        local resolved = subinstr(`"`r(fn)'"', "\", "/", .)
        return local path = "`resolved'"
        exit 0
    }

    * Development fallbacks when running from the repo (for QA and local work)
    local cwd = subinstr(c(pwd), "\", "/", .)

    local cwd_src = "`cwd'/src/_/`fname'"
    if (fileexists("`cwd_src'")) {
        return local path = "`cwd_src'"
        exit 0
    }

    local cwd_underscore = "`cwd'/_/`fname'"
    if (fileexists("`cwd_underscore'")) {
        return local path = "`cwd_underscore'"
        exit 0
    }

    if regexm("`cwd'", "(.+)/[^/]+/?$") {
        local parent = regexs(1)
        local parent_src = "`parent'/src/_/`fname'"
        if (fileexists("`parent_src'")) {
            return local path = "`parent_src'"
            exit 0
        }
    }

    * Fallback: explicit sysdir_plus path (returned even if missing â€” caller checks)
    local plus = subinstr(c(sysdir_plus), "\", "/", .) + "_/`fname'"
    return local path = "`plus'"
end


