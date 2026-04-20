NOTE:  readme.txt template -- do not remove empty entries, but you may
                              add entries for additional authors
------------------------------------------------------------------------------

Package name:   <leave blank>

DOI:  <leave blank>

Title:  Data Provenance in the Age of Automation: Lessons from Fifteen Years of Programmatic Access to World Bank Open Data

Author 1 name:  João Pedro Azevedo
Author 1 from:  UNICEF, Division of Data, Analytics, Planning and Monitoring
Author 1 email: jpazevedo@unicef.org

Author 2 name:
Author 2 from:
Author 2 email:

Author 3 name:
Author 3 from:
Author 3 email:

Author 4 name:
Author 4 from:
Author 4 email:

Author 5 name:
Author 5 from:
Author 5 email:

Help keywords:  wbopendata, World Bank, development indicators, WDI, API, open data, reproducible research

File list:

  wbopendata.ado                      Main command
  wbopendata_populate_list.ado        Database list population
  wbopendata_examples.ado             Built-in examples
  __wbod_api_read.ado                 API reader
  __wbod_api_read_indicators.ado      Indicator API reader
  __wbod_cache.ado                    Cache manager
  __wbod_check_version.ado            Version checker
  __wbod_check_yaml.ado               YAML checker
  __wbod_countrymetadata.ado          Country metadata handler
  __wbod_get_source_name.ado          Source name resolver
  __wbod_get_topic_name.ado           Topic name resolver
  __wbod_get_yaml_path.ado            YAML path resolver
  __wbod_info.ado                     Indicator information
  __wbod_linewrap.ado                 Line wrapping utility
  __wbod_metadata_linewrap.ado        Metadata line wrapping
  __wbod_parameters.ado               Parameter definitions
  __wbod_parse_yaml_ind.ado           YAML indicator parser (v1)
  __wbod_parse_yaml_ind_v2.ado        YAML indicator parser (v2)
  __wbod_query.ado                    Query builder
  __wbod_query_indicators.ado         Indicator query builder
  __wbod_query_metadata.ado           Metadata query builder
  __wbod_refresh_yaml.ado             YAML refresh
  __wbod_search.ado                   Indicator search engine
  __wbod_sources.ado                  Database source listing
  __wbod_sync.ado                     Metadata synchronization
  __wbod_sync_preview.ado             Sync preview
  __wbod_tknz.ado                     String tokenizer
  __wbod_topics.ado                   Topic listing
  __wbod_update_countrymetadata.ado   Country metadata updater
  __wbod_update_indicators.ado        Indicator list updater
  __wbod_update_regionmetadata.ado    Region metadata updater
  __wbod_update_wbopendata.ado        Package updater
  __wbod_website.ado                  Website URL helper
  __wbod_write_stats_history.ado      Statistics history writer
  __wbod_yaml_metadata.ado            YAML metadata handler
  __yaml_collapse.ado                 YAML collapse utility
  __yaml_fastread.ado                 YAML fast reader
  __yaml_mataread.ado                 YAML Mata reader
  __yaml_tokenize_line.ado            YAML line tokenizer
  yaml.ado                            YAML parser
  yaml.sthlp                          YAML parser help file
  wbopendata.sthlp                    Main help file
  wbopendata_whatsnew.sthlp            What's new help file
  wbopendata.dlg                      Dialog box definition
  wbopendata_indicators.sthlp         Indicator classification help
  wbopendata_adminregion.sthlp        Admin region codes help
  wbopendata_incomelevel.sthlp        Income level codes help
  wbopendata_lendingtype.sthlp        Lending type codes help
  wbopendata_region.sthlp             Region codes help
  wbopendata_sourceid.sthlp           Source ID codes help
  wbopendata_topicid.sthlp            Topic ID codes help
  world-c.dta                         Country concordance dataset
  world-d.dta                         Country data dataset
  _wbopendata_parameters.yaml         Parameters metadata (YAML)
  _wbopendata_indicators.yaml         Indicator metadata (YAML, 17 MB)
  _wbopendata_sources.yaml            Source metadata (YAML)
  _wbopendata_topics.yaml             Topic metadata (YAML)
  country.txt                         Country code list
  indicators.txt                      Indicator code list
  reproduce_paper_examples.do         Reproduces all examples in the paper
  reproduce_paper_examples.log        Log output from do-file

Notes:

  wbopendata v18.4.0 provides programmatic access to World Bank Open Data
  from within Stata. It supports five download modes (country, topics,
  indicator, indicator-country, and multiple indicators), three languages
  (English, Spanish, French), and offline indicator discovery through
  YAML-backed metadata.

  Requirements: Stata 14 or later, internet connection for data downloads.

  Installation from SSC:
    . ssc install wbopendata, replace

  The reproduce_paper_examples.do file generates all Stata output shown in
  the paper. It requires wbopendata to be installed and an active internet
  connection. Run from within the software/ directory:
    . do reproduce_paper_examples.do

  The YAML metadata files (_wbopendata_indicators.yaml is approximately
  17 MB) are required for offline indicator discovery features (search,
  info, sources, alltopics).
