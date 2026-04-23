*******************************************************************************
*! __wbod_search v3.0.0  04Feb2026
*! Search indicators - version router
*! Stata 16+: routes to __wbopendata_search_cache (frame-based caching)
*! Stata 14-15: routes to __wbopendata_search (per-call parsing)
*******************************************************************************

program define __wbod_search, rclass
    version 14.0

    syntax [anything(name=keyword)] [, LIMIT(integer 20) PAGE(integer 1) ///
        SOURCE(string) TOPIC(string) FIELD(string) EXACT DETAIL NOcache DEBUG]

    local topic_input "`topic'"
    local topic_dispatch "`topic'"

    * Route to appropriate implementation based on Stata version
    if (`c(stata_version)' >= 16) {
        if (`"`keyword'"' != "") {
            __wbopendata_search_cache `"`keyword'"', limit(`limit') page(`page') source("`source'") ///
                topic("`topic_dispatch'") field("`field'") `exact' `detail' `nocache' `debug'
        }
        else {
            __wbopendata_search_cache, limit(`limit') page(`page') source("`source'") ///
                topic("`topic_dispatch'") field("`field'") `exact' `detail' `nocache' `debug'
        }
    }
    else {
        if (`"`keyword'"' != "") {
            __wbopendata_search `"`keyword'"', limit(`limit') page(`page') source("`source'") ///
                topic("`topic_dispatch'") field("`field'") `exact' `detail' `nocache' `debug'
        }
        else {
            __wbopendata_search, limit(`limit') page(`page') source("`source'") ///
                topic("`topic_dispatch'") field("`field'") `exact' `detail' `nocache' `debug'
        }
    }

    * Pass through return values from implementation
    return scalar n_results = r(n_results)
    return scalar n_displayed = r(n_displayed)
    capture return scalar page = r(page)
    capture return scalar n_pages = r(n_pages)
    return local first_code = "`r(first_code)'"
    return local codes = "`r(codes)'"
    return local names = `"`r(names)'"'
    return local sources = "`r(sources)'"
    return local topics = `"`r(topics)'"'
    return local keyword = "`r(keyword)'"
    return local source_filter = "`r(source_filter)'"
    if ("`topic_input'" != "") return local topic_filter = "`topic_input'"
    else return local topic_filter = "`r(topic_filter)'"
    return local field_filter = "`r(field_filter)'"
    return local yaml_path = "`r(yaml_path)'"
    return local cmd = "`r(cmd)'"
    return local cache_method = "`r(cache_method)'"
end


