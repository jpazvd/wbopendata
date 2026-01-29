*******************************************************************************
*! _wbopendata_get_yaml_path v1.0.0  20Jan2026
*! Resolve YAML path (cache first, then installed package)
*******************************************************************************

program define _wbopendata_get_yaml_path, rclass
    version 14.0
    syntax [, TYPE(string)]

    local t = lower("`type'")
    if ("`t'" == "") local t "indicators"

    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local fname "_wbopendata_`t'.yaml"
    local candidate = "`cache_dir'`fname'"

    if (fileexists("`candidate'")) {
        return local path = "`candidate'"
        exit 0
    }

    local plus = c(sysdir_plus) + "_/`fname'"
    return local path = "`plus'"
end
