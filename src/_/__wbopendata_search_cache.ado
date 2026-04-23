*******************************************************************************
*! __wbopendata_search_cache v3.3.0  20Apr2026
*! v3.3.0: Add page() option with clickable [Prev]/[Next] pagination
*! v3.2.0: Fix clickable links: source() -> searchsource(), topic() -> searchtopic()
*! Search indicators with frame-based session caching (Stata 16+)
*! Uses __wbod_parse_yaml_ind, caches processed dataset in frame for speed
*******************************************************************************

program define __wbopendata_search_cache, rclass
    version 16.0
    syntax [anything(name=keyword)] [, LIMIT(integer 20) PAGE(integer 1) ///
        SOURCE(string) TOPIC(string) FIELD(string) EXACT DETAIL NOcache DEBUG]

    * Strip surrounding quotes from keyword
    local kw `keyword'
    local kw = subinstr(`"`kw'"', `"""', "", .)
    local kw = strtrim("`kw'")
    local kw_lower = lower("`kw'")
    local limit = cond(`limit' <= 0, 20, `limit')
    if (`page' < 1) local page = 1

    * Check for multi-keyword AND search (keyword1+keyword2+keyword3)
    local multi_kw = 0
    local n_keywords = 1
    if (strpos("`kw'", "+") > 0 & substr("`kw'", 1, 1) != "~" & ///
        strpos("`kw'", "*") == 0 & strpos("`kw'", "?") == 0 & strpos("`kw'", "[") == 0) {
        local multi_kw = 1
        * Count and extract keywords
        local kw_remaining = "`kw'"
        local n_keywords = 0
        while ("`kw_remaining'" != "") {
            local n_keywords = `n_keywords' + 1
            local plus_pos = strpos("`kw_remaining'", "+")
            if (`plus_pos' > 0) {
                local kw`n_keywords' = lower(strtrim(substr("`kw_remaining'", 1, `plus_pos' - 1)))
                local kw_remaining = strtrim(substr("`kw_remaining'", `plus_pos' + 1, .))
            }
            else {
                local kw`n_keywords' = lower(strtrim("`kw_remaining'"))
                local kw_remaining ""
            }
        }
    }

    * Validate: either keyword or source/topic filter required
    if ("`kw'" == "" & "`source'" == "" & "`topic'" == "") {
        di as error "search() requires a keyword, or source()/topic() filter"
        di as text "Examples:"
        di as text "  wbopendata, search(GDP)"
        di as text "  wbopendata, search(learning+poverty)     // AND search: both keywords"
        di as text "  wbopendata, search() searchsource(2)"
        di as text "  wbopendata, search(poverty) searchtopic(11)"
        exit 198
    }

    __wbod_get_yaml_path, type(indicators)
    local yaml_path = r(path)

    if (!fileexists("`yaml_path'")) {
        di as error "Indicators metadata not found. Run: wbopendata, sync"
        exit 601
    }

    *---------------------------------------------------------------------------
    * Convert wildcard pattern to regex
    *---------------------------------------------------------------------------
    local use_regex = 0
    local regex_pattern = ""

    if ("`kw'" != "") {
        * Check for regex mode (prefix with ~)
        if (substr("`kw'", 1, 1) == "~") {
            local use_regex = 1
            local regex_pattern = substr("`kw'", 2, .)
        }
        * Check for wildcards (* ? [ ])
        else if (strpos("`kw'", "*") > 0 | strpos("`kw'", "?") > 0 | ///
                 strpos("`kw'", "[") > 0) {
            local use_regex = 1
            * Convert glob to regex
            local regex_pattern = "`kw'"
            * Escape regex special chars (except * ? [ ])
            local regex_pattern = subinstr("`regex_pattern'", ".", "\.", .)
            local regex_pattern = subinstr("`regex_pattern'", "^", "\^", .)
            local regex_pattern = subinstr("`regex_pattern'", "$", "\$", .)
            local regex_pattern = subinstr("`regex_pattern'", "+", "\+", .)
            local regex_pattern = subinstr("`regex_pattern'", "(", "\(", .)
            local regex_pattern = subinstr("`regex_pattern'", ")", "\)", .)
            local regex_pattern = subinstr("`regex_pattern'", "{", "\{", .)
            local regex_pattern = subinstr("`regex_pattern'", "}", "\}", .)
            * Convert wildcards: * → .*, ? → .
            local regex_pattern = subinstr("`regex_pattern'", "*", ".*", .)
            local regex_pattern = subinstr("`regex_pattern'", "?", ".", .)
        }
    }

    *---------------------------------------------------------------------------
    * Parse field() option - default is "all"
    *---------------------------------------------------------------------------
    local search_code = 1
    local search_name = 1
    local search_desc = 1
    local search_source = 1
    local search_topic = 1
    local search_note = 1

    if ("`field'" != "") {
        * Reset all to 0, then enable requested fields
        local search_code = 0
        local search_name = 0
        local search_desc = 0
        local search_source = 0
        local search_topic = 0
        local search_note = 0

        * Parse semicolon-separated field list
        local fields = lower("`field'")
        local fields = subinstr("`fields'", ";", " ", .)
        foreach f of local fields {
            if ("`f'" == "all") {
                local search_code = 1
                local search_name = 1
                local search_desc = 1
                local search_source = 1
                local search_topic = 1
                local search_note = 1
            }
            else if ("`f'" == "code")        local search_code = 1
            else if ("`f'" == "name")        local search_name = 1
            else if ("`f'" == "description") local search_desc = 1
            else if ("`f'" == "source")      local search_source = 1
            else if ("`f'" == "topic")       local search_topic = 1
            else if ("`f'" == "note")        local search_note = 1
            else {
                di as error "Unknown field: `f'"
                di as text "Valid fields: code, name, description, source, topic, note, all"
                exit 198
            }
        }
    }

    *---------------------------------------------------------------------------
    * Frame cache: parse once, reuse across calls
    *---------------------------------------------------------------------------
    local use_cache = ("`nocache'" == "")
    local cache_method = "frames"
    local parser_version "1.1.0"

    preserve

    if (`use_cache') {
        *-----------------------------------------------------------------------
        * FRAME CACHE approach
        * First call: parse YAML via __wbod_parse_yaml_ind, save to frame
        * Subsequent calls: load from cached frame
        *-----------------------------------------------------------------------
        local frame_name "_wbod_indicators"
        local cache_loaded = 0

        * Check if frame already exists with valid data
        * Cache validity: frame exists + has expected variables + parser version matches
        * No content-based guards - trust parser version for invalidation
        capture frame `frame_name': count
        if (_rc == 0 & r(N) > 0) {
            capture frame `frame_name': confirm variable ind_code field_name field_source_id field_source_name field_unit field_limited_data _parser_version
            if (_rc == 0) {
                local cache_loaded = 1
                frame `frame_name' {
                    local cache_version = _parser_version[1]
                }
                if ("`cache_version'" != "`parser_version'") {
                    local cache_loaded = 0
                }
                * Show cache message if cache is valid
                if (`cache_loaded') {
                    di as text "(Using cached metadata from memory)"
                }
            }
        }

        if (!`cache_loaded') {
            * First call or invalid cache - parse YAML and cache result
            di as text "(Caching metadata in memory...)"

            __wbod_parse_yaml_ind_v2 "`yaml_path'"
            gen str10 _parser_version = "`parser_version'"

            * Save processed dataset to frame for future use
            capture frame drop `frame_name'
            frame put *, into(`frame_name')

            if ("`debug'" != "") {
                count
                di as text "(Cached `r(N)' indicators to frame)"
            }
        }
        else {
            * Load cached data from frame via tempfile
            tempfile cache_tmp
            frame `frame_name' {
                quietly save `cache_tmp', replace
            }
            quietly use `cache_tmp', clear
        }
    }
    else {
        *-----------------------------------------------------------------------
        * NO CACHE: parse YAML each call (nocache option)
        *-----------------------------------------------------------------------
        local cache_method = "nocache"
        if ("`debug'" != "") {
            di as text "(Parsing YAML - no cache)"
        }
        __wbod_parse_yaml_ind_v2 "`yaml_path'"
    }

    *---------------------------------------------------------------------------
    * Apply filters and search
    *---------------------------------------------------------------------------
    quietly {
        * Apply source filter (by ID)
        * Zero-pad single-digit IDs to match YAML format (e.g. "2" -> "02")
        if ("`source'" != "") {
            local src_filter "`source'"
            if (length("`src_filter'") == 1 & real("`src_filter'") != .) {
                local src_filter "0`src_filter'"
            }
            keep if field_source_id == "`src_filter'" | field_source_id == "`source'"
        }

        * Apply topic filter (by ID - check if ID is in semicolon-separated list)
        * Must use word-boundary matching to avoid "1" matching "11", "14", "21" etc.
        if ("`topic'" != "") {
            gen byte topic_match = 0
            * Exact match (single topic)
            replace topic_match = 1 if field_topic_ids == "`topic'"
            * First in list: "1;..."
            replace topic_match = 1 if strpos(field_topic_ids, "`topic';") == 1
            * Middle of list: "...;1;..."
            replace topic_match = 1 if strpos(field_topic_ids, ";`topic';") > 0
            * End of list: "...;1" - use regex for end anchor
            replace topic_match = 1 if regexm(field_topic_ids, ";`topic'$")
            keep if topic_match
            drop topic_match
        }

        * Apply keyword search
        gen byte hit = 0

        if ("`kw'" != "") {
            if ("`exact'" != "") {
                * Exact match on code only
                replace hit = 1 if upper(ind_code) == upper("`kw'")
            }
            else if (`use_regex') {
                * Regex/wildcard search
                if (`search_code')   replace hit = 1 if regexm(lower(ind_code), lower("`regex_pattern'"))
                if (`search_name')   replace hit = 1 if regexm(lower(field_name), lower("`regex_pattern'"))
                if (`search_desc')   replace hit = 1 if regexm(lower(field_desc), lower("`regex_pattern'"))
                if (`search_source') replace hit = 1 if regexm(lower(field_source), lower("`regex_pattern'"))
                if (`search_topic')  replace hit = 1 if regexm(lower(field_topic), lower("`regex_pattern'"))
                if (`search_note')   replace hit = 1 if regexm(lower(field_note), lower("`regex_pattern'"))
            }
            else if (`multi_kw') {
                * Multi-keyword AND search: all keywords must match
                gen str1000 all_text = ""
                if (`search_code')   replace all_text = all_text + " " + lower(ind_code)
                if (`search_name')   replace all_text = all_text + " " + lower(field_name)
                if (`search_desc')   replace all_text = all_text + " " + lower(field_desc)
                if (`search_source') replace all_text = all_text + " " + lower(field_source)
                if (`search_topic')  replace all_text = all_text + " " + lower(field_topic)
                if (`search_note')   replace all_text = all_text + " " + lower(field_note)

                replace hit = 1
                forvalues k = 1/`n_keywords' {
                    replace hit = 0 if strpos(all_text, "`kw`k''") == 0
                }
                drop all_text
            }
            else {
                * Simple single-keyword substring search
                if (`search_code')   replace hit = 1 if strpos(lower(ind_code), "`kw_lower'") > 0
                if (`search_name')   replace hit = 1 if strpos(lower(field_name), "`kw_lower'") > 0
                if (`search_desc')   replace hit = 1 if strpos(lower(field_desc), "`kw_lower'") > 0
                if (`search_source') replace hit = 1 if strpos(lower(field_source), "`kw_lower'") > 0
                if (`search_topic')  replace hit = 1 if strpos(lower(field_topic), "`kw_lower'") > 0
                if (`search_note')   replace hit = 1 if strpos(lower(field_note), "`kw_lower'") > 0
            }
            keep if hit
        }

        drop hit
        sort ind_code
    }

    if ("`debug'" != "") {
        di as text "[debug] Parsed YAML and applied filters."
    }

    quietly count
    local n = r(N)

    if ("`debug'" != "") {
        di as text "[debug] Match count: " `n'
    }

    *---------------------------------------------------------------------------
    * Handle no results
    *---------------------------------------------------------------------------
    if (`n' == 0) {
        if ("`kw'" != "") {
            di as text "No indicators matched: " as result "`kw'"
            if (strpos("`kw'", " ") > 0) {
                local kw_plus = subinstr("`kw'", " ", "+", .)
                di as text ""
                di as text "Tip: Use " as result "`kw_plus'" as text " to find indicators matching ALL words"
            }
        }
        else {
            di as text "No indicators found with specified filters"
        }
        if ("`source'" != "") di as text "  Source filter: `source'"
        if ("`topic'" != "")  di as text "  Topic filter: `topic'"
        if ("`field'" != "")  di as text "  Field filter: `field'"

        restore
        return scalar n_results = 0
        return scalar n_displayed = 0
        return scalar page = 1
        return scalar n_pages = 0
        return local keyword = "`kw'"
        return local source_filter = "`source'"
        return local topic_filter = "`topic'"
        return local field_filter = "`field'"
        return local yaml_path = "`yaml_path'"
        return local cache_method = "`cache_method'"
        exit 0
    }

    if ("`debug'" != "") {
        * Apply same paging rules as the display path so r() values are consistent.
        local display_page  = `page'
        local display_limit = `limit'
        if (`n' <= 30) {
            local display_page = 1
            local n_pages      = 1
            local n_displayed  = `n'
        }
        else {
            local n_pages = ceil(`n' / `display_limit')
            if (`display_page' < 1) local display_page = 1
            if (`display_page' > `n_pages') local display_page = `n_pages'
            local start       = (`display_page' - 1) * `display_limit' + 1
            local n_displayed = min(`display_limit', `n' - `start' + 1)
        }
        restore
        return scalar n_results   = `n'
        return scalar n_displayed = `n_displayed'
        return scalar page        = `display_page'
        return scalar n_pages     = `n_pages'
        return local keyword      = "`kw'"
        return local source_filter = "`source'"
        return local topic_filter  = "`topic'"
        return local field_filter  = "`field'"
        return local yaml_path     = "`yaml_path'"
        return local cache_method  = "`cache_method'"
        exit 0
    }

    *---------------------------------------------------------------------------
    * Display results with SMCL navigation
    *---------------------------------------------------------------------------
    * Sanitize strings: replace embedded double-quotes with single-quotes
    * so that local macro expansion never encounters unmatched quotes (r(132))
    quietly {
        foreach var of varlist field_name field_desc field_source field_topic field_note {
            capture replace `var' = subinstr(`var', char(34), "'", .)
        }
        replace field_name = "N/A" if field_name == ""
        replace field_source = "N/A" if field_source == ""
    }

    * Pagination: small result sets display on a single page (matching the
    * pre-pagination UX); larger sets honor `limit' as per-page size.
    if (`n' <= 30) {
        local total_pages = 1
        local page = 1
        local pg_start = 1
        local pg_end = `n'
    }
    else {
        local total_pages = ceil(`n' / `limit')
        if (`total_pages' < 1) local total_pages = 1
        if (`page' > `total_pages') local page = `total_pages'
        local pg_start = (`page' - 1) * `limit' + 1
        local pg_end = min(`page' * `limit', `n')
    }
    local lim = `pg_end' - `pg_start' + 1

    * Build header: show pagination info only when there is more than one page
    if (`total_pages' > 1) {
        local hdr_tail "(page `page' of `total_pages' — showing `pg_start'-`pg_end' of `n')"
    }
    else {
        local hdr_tail "(showing `n' of `n')"
    }
    di as text ""
    if ("`kw'" != "") {
        di as result "Search results for " as text `""`kw'""' as result " `hdr_tail'"
    }
    else if ("`source'" != "") {
        di as result "Indicators from source `source'" as text " `hdr_tail'"
    }
    else if ("`topic'" != "") {
        di as result "Indicators in topic `topic'" as text " `hdr_tail'"
    }

    * Build return values
    local codes ""
    local names ""
    local sources ""
    local topics ""

    *---------------------------------------------------------------------------
    * Display format: DETAIL (wrapped) vs TABLE (compact)
    *---------------------------------------------------------------------------
    if ("`detail'" != "") {
        *-----------------------------------------------------------------------
        * DETAIL format: one block per indicator with wrapped text
        *-----------------------------------------------------------------------
        di as text "{hline}"

        forvalues i = `pg_start'/`pg_end' {
            local code = ind_code[`i']
            local nm = field_name[`i']
            local src_id = field_source_id[`i']
            local topic_nm = field_topic[`i']
            local topic_id = field_topic_ids[`i']
            if ("`topic_nm'" == "") local topic_nm "-"

            * Build clickable links
            local info_cmd `"wbopendata, info(`code')"'
            local get_cmd `"wbopendata, indicator(`code') clear"'
            local src_cmd `"wbopendata, search() searchsource(`src_id')"'
            local topic_cmd `"wbopendata, search() searchtopic(`topic_id')"'

            * Display block with wrapped fields
            di as result "`code'" as text "  " ///
               `"{stata "`info_cmd'":[Info]}"' " " ///
               `"{stata "`get_cmd'":[Get]}"'
            di in smcl `"{p 4 4 4}{result:Name}: `nm'{p_end}"'
            di in smcl `"{p 4 4 4}{result:Source}: {stata "`src_cmd'":`src_id'}  {result:Topic}: {stata "`topic_cmd'":`topic_nm'}{p_end}"'
            di as text "{hline}"

            * Build return values
            local codes "`codes' `code'"
            local names `"`names' "`nm'""'
            local sources "`sources' `src_id'"
            local topics `"`topics' "`topic_nm'""'
        }

        * Pagination nav (shown only when there is more than one page)
        __wbod_search_pagenav, page(`page') totalpages(`total_pages') ///
            keyword(`"`kw'"') source("`source'") topic("`topic'") ///
            field("`field'") limit(`limit') `exact' `detail'

        * Navigation tips for detail format
        di as text ""
        di as text "Click " as result "[Info]" as text " for full metadata, " as result "[Get]" as text " to download"
    }
    else {
        *-----------------------------------------------------------------------
        * TABLE format: Src alias (6) + Topic ID (4) + legend below
        *-----------------------------------------------------------------------
        local linesize = c(linesize)
        local name_width = min(max(30, `linesize' - 53), 80)
        local name_trunc  = `name_width' - 3

        * Source alias lookup (6-char max)
        local src_alias_1   "DoingB"
        local src_alias_2   "WDI"
        local src_alias_3   "WGI"
        local src_alias_5   "SubMal"
        local src_alias_6   "IDS"
        local src_alias_11  "AfrDev"
        local src_alias_12  "EdStat"
        local src_alias_13  "EntSrv"
        local src_alias_14  "Gender"
        local src_alias_15  "GEM"
        local src_alias_16  "HNP"
        local src_alias_18  "IDA"
        local src_alias_19  "MDGs"
        local src_alias_20  "QPSD"
        local src_alias_22  "QEDSS"
        local src_alias_23  "QEDSG"
        local src_alias_25  "Jobs"
        local src_alias_27  "GEP"
        local src_alias_28  "Findex"
        local src_alias_29  "ASPIRE"
        local src_alias_30  "ExpDB"
        local src_alias_31  "CPIA"
        local src_alias_32  "FinDev"
        local src_alias_33  "G20FI"
        local src_alias_34  "GPE"
        local src_alias_35  "SE4All"
        local src_alias_37  "LAC"
        local src_alias_38  "SubPov"
        local src_alias_39  "HNPWQ"
        local src_alias_40  "PopEst"
        local src_alias_41  "CPSIN"
        local src_alias_43  "AdjNS"
        local src_alias_45  "INDO"
        local src_alias_46  "SDGs"
        local src_alias_50  "SubPop"
        local src_alias_54  "JEDH"
        local src_alias_57  "WDIArc"
        local src_alias_58  "UHC"
        local src_alias_59  "WltAcc"
        local src_alias_60  "EcFit"
        local src_alias_61  "PPPQ"
        local src_alias_62  "ICP11"
        local src_alias_63  "HCI"
        local src_alias_64  "WWBI"
        local src_alias_65  "HEFP"
        local src_alias_66  "LPI"
        local src_alias_67  "PEF11"
        local src_alias_68  "PEF16"
        local src_alias_69  "GFCPS"
        local src_alias_70  "EcFt2"
        local src_alias_71  "ICP05"
        local src_alias_73  "GFCPI"
        local src_alias_75  "ESG"
        local src_alias_76  "RPWS"
        local src_alias_77  "RPWR"
        local src_alias_78  "ICP17"
        local src_alias_79  "PEFGR"
        local src_alias_80  "GDLD"
        local src_alias_81  "IDSDS"
        local src_alias_82  "GPP"
        local src_alias_83  "SPI"
        local src_alias_84  "EdPol"
        local src_alias_85  "PEFSN"
        local src_alias_86  "JOIN"
        local src_alias_87  "CCDR"
        local src_alias_88  "FPN"
        local src_alias_89  "ID4D"
        local src_alias_90  "ICP21"
        local src_alias_91  "PEFCR"
        local src_alias_92  "DDH"
        local src_alias_93  "FPNA"

        * Source full names (for legend)
        local src_name_1   "Doing Business"
        local src_name_2   "World Development Indicators"
        local src_name_3   "Worldwide Governance Indicators"
        local src_name_5   "Subnational Malnutrition Database"
        local src_name_6   "International Debt Statistics"
        local src_name_11  "Africa Development Indicators"
        local src_name_12  "Education Statistics"
        local src_name_13  "Enterprise Surveys"
        local src_name_14  "Gender Statistics"
        local src_name_15  "Global Economic Monitor"
        local src_name_16  "Health Nutrition and Population"
        local src_name_18  "IDA Results Measurement System"
        local src_name_19  "Millennium Development Goals"
        local src_name_20  "Quarterly Public Sector Debt"
        local src_name_22  "QEDS SDDS"
        local src_name_23  "QEDS GDDS"
        local src_name_25  "Jobs"
        local src_name_27  "Global Economic Prospects"
        local src_name_28  "Global Findex"
        local src_name_29  "ASPIRE"
        local src_name_30  "Exporter Dynamics Database"
        local src_name_31  "Country Policy & Institutional Assessment"
        local src_name_32  "Global Financial Development"
        local src_name_33  "G20 Financial Inclusion"
        local src_name_34  "Global Partnership for Education"
        local src_name_35  "Sustainable Energy for All"
        local src_name_37  "LAC Equity Lab"
        local src_name_38  "Subnational Poverty"
        local src_name_39  "HNP by Wealth Quintile"
        local src_name_40  "Population Estimates & Projections"
        local src_name_41  "India Country Partnership Strategy"
        local src_name_43  "Adjusted Net Savings"
        local src_name_45  "Indonesia Database for Policy & Economic Research"
        local src_name_46  "Sustainable Development Goals"
        local src_name_50  "Subnational Population"
        local src_name_54  "Joint External Debt Hub"
        local src_name_57  "WDI Database Archives"
        local src_name_58  "Universal Health Coverage"
        local src_name_59  "Wealth Accounts"
        local src_name_60  "Economic Fitness"
        local src_name_61  "PPPs Regulatory Quality"
        local src_name_62  "ICP 2011"
        local src_name_63  "Human Capital Index"
        local src_name_64  "Worldwide Bureaucracy Indicators"
        local src_name_65  "Health Equity & Financial Protection"
        local src_name_66  "Logistics Performance Index"
        local src_name_67  "PEFA 2011"
        local src_name_68  "PEFA 2016"
        local src_name_69  "Global Financial Inclusion & Consumer Protection"
        local src_name_70  "Economic Fitness 2"
        local src_name_71  "ICP 2005"
        local src_name_73  "Global Financial Inclusion Survey (Internal)"
        local src_name_75  "ESG Data"
        local src_name_76  "Remittance Prices Worldwide (Sending)"
        local src_name_77  "Remittance Prices Worldwide (Receiving)"
        local src_name_78  "ICP 2017"
        local src_name_79  "PEFA GRPFM"
        local src_name_80  "Gender Disaggregated Labor Database"
        local src_name_81  "International Debt Statistics: DSSI"
        local src_name_82  "Global Public Procurement"
        local src_name_83  "Statistical Performance Indicators"
        local src_name_84  "Education Policy"
        local src_name_85  "PEFA 2021 SNG"
        local src_name_86  "Global Jobs Indicators Database"
        local src_name_87  "Country Climate and Development Report"
        local src_name_88  "Food Prices for Nutrition"
        local src_name_89  "ID4D Data"
        local src_name_90  "ICP 2021"
        local src_name_91  "PEFA CRPFM"
        local src_name_92  "Disability Data Hub"
        local src_name_93  "FPN Datahub Archive"

        * Topic name lookup (for legend)
        local topic_name_1  "Agric & Rural Dev"
        local topic_name_2  "Aid Effectiveness"
        local topic_name_3  "Economy & Growth"
        local topic_name_4  "Education"
        local topic_name_5  "Energy & Mining"
        local topic_name_6  "Environment"
        local topic_name_7  "Financial Sector"
        local topic_name_8  "Health"
        local topic_name_9  "Infrastructure"
        local topic_name_10 "Social Protection & Labor"
        local topic_name_11 "Poverty"
        local topic_name_12 "Private Sector"
        local topic_name_13 "Public Sector"
        local topic_name_14 "Science & Technology"
        local topic_name_15 "Social Development"
        local topic_name_16 "Urban Development"
        local topic_name_17 "Gender"
        local topic_name_18 "MDGs"
        local topic_name_19 "Climate Change"
        local topic_name_20 "External Debt"
        local topic_name_21 "Trade"

        * Legend accumulators (populated during row loop, deduplicated)
        local legend_srcs ""
        local legend_topics ""

        di as text "{hline}"
        di as text %-22s "Code" " " %-`name_width's "Name" " " %6s "Src" " " %-8s "Top" " " "[Info]" " " "[Get]"
        di as text "{hline}"

        forvalues i = `pg_start'/`pg_end' {
            local code     = ind_code[`i']
            local nm       = field_name[`i']
            local src_id   = field_source_id[`i']
            local topic_nm = field_topic[`i']
            local topic_id = field_topic_ids[`i']

            * Truncate long name for display
            local nm_disp = "`nm'"
            if (strlen("`nm_disp'") > `name_trunc') {
                local nm_disp = substr("`nm_disp'", 1, `name_trunc') + "..."
            }

            * Build clickable commands
            local info_cmd `"wbopendata, info(`code')"'
            local get_cmd  `"wbopendata, indicator(`code') clear"'
            local src_cmd  `"wbopendata, search() searchsource(`src_id')"'

            * Source alias (6 chars, right-aligned)
            local alias "`src_alias_`src_id''"
            if ("`alias'" == "") local alias "`src_id'"
            local src_disp = "`alias'"
            while (strlen("`src_disp'") < 6) {
                local src_disp " `src_disp'"
            }

            * All topic IDs for column (8 chars, space-separated, left-aligned)
            local first_tid = word(subinstr("`topic_id'", ";", " ", .), 1)
            if ("`first_tid'" == "") local first_tid "-"
            local topic_cmd `"wbopendata, search() searchtopic(`first_tid')"'
            local tid_disp = subinstr("`topic_id'", ";", " ", .)
            if ("`tid_disp'" == "") local tid_disp "-"
            if (strlen("`tid_disp'") > 8) local tid_disp = substr("`tid_disp'", 1, 7) + "+"
            while (strlen("`tid_disp'") < 8) {
                local tid_disp "`tid_disp' "
            }

            * Accumulate source legend (dedup by alias)
            if (0`seen_src_`alias'' != 1) {
                local seen_src_`alias' = 1
                local sfull "`src_name_`src_id''"
                if ("`sfull'" == "") local sfull "Source `src_id'"
                local sleg `"{stata "`src_cmd'":`alias'} = `sfull'"'
                local legend_srcs `"`legend_srcs'  `sleg'"'
            }

            * Accumulate topic legend — all topic IDs on this page (dedup)
            local tid_list = subinstr("`topic_id'", ";", " ", .)
            foreach tid of local tid_list {
                if (0`seen_topic_`tid'' != 1) {
                    local seen_topic_`tid' = 1
                    local tnm "`topic_name_`tid''"
                    if ("`tnm'" == "") local tnm "Topic `tid'"
                    local tc `"wbopendata, search() searchtopic(`tid')"'
                    local tleg `"{stata "`tc'":[`tid']} `tnm'"'
                    local legend_topics `"`legend_topics'  `tleg'"'
                }
            }

            * Display row
            di as result %-22s "`code'" as text " " %-`name_width's "`nm_disp'" " " ///
               `"{stata "`src_cmd'":`src_disp'}"' " " ///
               `"{stata "`topic_cmd'":`tid_disp'}"' " " ///
               `"{stata "`info_cmd'":[Info]}"' " " ///
               `"{stata "`get_cmd'":[Get]}"'

            * Build return values
            local codes "`codes' `code'"
            local names `"`names' "`nm'""'
            local sources "`sources' `src_id'"
            local topics `"`topics' "`topic_nm'""'
        }

        di as text "{hline}"

        * Legend: topics and sources seen on this page
        if (`"`legend_topics'"' != "") {
            local helplink `"{stata "help wbopendata_topicid":[topic guide]}"'
            di as text `"{p 0 8 2}Topics:`legend_topics'  `helplink'{p_end}"'
        }
        if (`"`legend_srcs'"' != "") {
            di as text `"{p 0 9 2}Sources:`legend_srcs'{p_end}"'
        }

        * Pagination nav (shown only when there is more than one page)
        __wbod_search_pagenav, page(`page') totalpages(`total_pages') ///
            keyword(`"`kw'"') source("`source'") topic("`topic'") ///
            field("`field'") limit(`limit') `exact' `detail'

        * Navigation tips
        di as text ""
        di as text "Click " as result "[Info]" as text " for details, " as result "[Get]" as text " to download, " ///
            as result "Src" as text "/" as result "Top" as text " to browse by source/topic"
    }

    *---------------------------------------------------------------------------
    * Return values
    *---------------------------------------------------------------------------
    return scalar n_results = `n'
    return scalar n_displayed = `lim'
    return scalar page = `page'
    return scalar n_pages = `total_pages'
    local first = ind_code[1]
    return local first_code = "`first'"
    return local codes = strtrim("`codes'")
    local names_trim = strtrim(`"`names'"')
    local topics_trim = strtrim(`"`topics'"')
    return local names = `"`names_trim'"'
    return local sources = strtrim("`sources'")
    return local topics = `"`topics_trim'"'
    return local keyword = "`kw'"
    return local source_filter = "`source'"
    return local topic_filter = "`topic'"
    return local field_filter = "`field'"
    return local yaml_path = "`yaml_path'"
    return local cache_method = "`cache_method'"

    * Build reproducible command
    local cmd "wbopendata, search(`kw')"
    if ("`source'" != "") local cmd "`cmd' source(`source')"
    if ("`topic'" != "")  local cmd "`cmd' topic(`topic')"
    if ("`field'" != "")  local cmd "`cmd' field(`field')"
    if ("`exact'" != "")  local cmd "`cmd' exact"
    if ("`detail'" != "") local cmd "`cmd' detail"
    local cmd "`cmd' limit(`limit') page(`page')"
    return local cmd = "`cmd'"

    restore
    exit 0
end
