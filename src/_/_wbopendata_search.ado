*******************************************************************************
*! _wbopendata_search v3.0.0  04Feb2026
*! Search indicators - version router
*! Temporary: route all versions to __wbopendata_search (per-call parsing)
*! until frame caching is stabilized.
*******************************************************************************

program define _wbopendata_search, rclass
    version 14.0

    * Route to appropriate implementation based on Stata version
    __wbopendata_search `0'

    * Pass through return values from implementation
    return scalar n_results = r(n_results)
    return scalar n_displayed = r(n_displayed)
    return local first_code = "`r(first_code)'"
    return local codes = "`r(codes)'"
    return local names = `"`r(names)'"'
    return local sources = "`r(sources)'"
    return local topics = `"`r(topics)'"'
    return local keyword = "`r(keyword)'"
    return local source_filter = "`r(source_filter)'"
    return local topic_filter = "`r(topic_filter)'"
    return local field_filter = "`r(field_filter)'"
    return local yaml_path = "`r(yaml_path)'"
    return local cmd = "`r(cmd)'"
    return local cache_method = "`r(cache_method)'"
end
