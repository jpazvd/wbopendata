# wbopendata Architecture

This diagram summarizes the main execution flow, helper modules, and metadata pathways for the `wbopendata` Stata package.

## High-level flow

```mermaid
flowchart LR
    user[User] --> cmd[wbopendata.ado]

    cmd -->|Discovery| sources[_wbopendata_sources.ado]
    cmd -->|Discovery| topics[_wbopendata_topics.ado]
    cmd -->|Discovery| search[_wbopendata_search.ado]
    cmd -->|Discovery| info[_wbopendata_info.ado]

    cmd -->|Sync/Cache| cache[_wbopendata_cache.ado]
    cmd -->|Sync/Cache| cacheinfo[_wbopendata_cache_info.ado]
    cmd -->|Sync/Cache| cacheclear[_wbopendata_cache_clear.ado]
    cmd -->|Sync/Cache| checkver[_wbopendata_check_version.ado]
    cmd -->|Sync/Cache| download[_wbopendata_download_yaml.ado]
    cmd -->|Sync/Cache| getpath[_wbopendata_get_yaml_path.ado]

    cmd -->|Data Download| query[_query.ado]
    cmd -->|Metadata| qmeta[_query_metadata.ado]

    query --> api[_api_read.ado]
    qmeta --> api

    cmd -->|Country Metadata| cmeta[_countrymetadata.ado]

    search -->|Stata 16+| searchcache[__wbopendata_search_cache.ado]
    search -->|Stata 14-15| searchplain[__wbopendata_search.ado]
    searchcache --> parseyaml[__wbod_parse_yaml_ind.ado]

    cmd -->|Formatting| linewrap[_linewrap.ado]
    cmd -->|Formatting| metalinewrap[_metadata_linewrap.ado]

    cache --> params[_parameters.ado]

    subgraph Metadata YAML
        yamlind[_wbopendata_indicators.yaml]
        yamlsrc[_wbopendata_sources.yaml]
        yamltop[_wbopendata_topics.yaml]
    end

    download --> yamlind
    download --> yamlsrc
    download --> yamltop

    params --> yamlind
    sources --> yamlsrc
    topics --> yamltop
    info --> yamlind
    searchplain --> yamlind
    searchcache --> yamlind
```

## Notes

- The main entry point is `wbopendata.ado`.
- Discovery commands (sources, topics, search, info) rely on cached YAML metadata.
- Metadata synchronization and cache management live in `_wbopendata_cache*.ado` helpers.
- Stata 16+ uses a frame-based cached search path for performance; earlier versions parse on each call.
- Data download flows through `_query.ado` and `_api_read.ado`, with metadata fetched by `_query_metadata.ado`.
