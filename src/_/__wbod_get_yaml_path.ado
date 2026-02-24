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
        return local path = "`r(fn)'"
        exit 0
    }

    * Fallback: explicit sysdir_plus path (returned even if missing â€” caller checks)
    local plus = c(sysdir_plus) + "_/`fname'"
    return local path = "`plus'"
end


