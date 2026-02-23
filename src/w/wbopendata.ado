*******************************************************************************
* wbopendata
*! v 18.3.1  	 23Feb2026               by Joao Pedro Azevedo
*   18.3.1: Add verbose option; targeted error handling for cache/metadata operations
*   18.3.0: YAML metadata lookup on cache hit (no API call); configurable cachedays() TTL; fix cache lookup
*   18.2.0: Data response cache (7-day TTL, on by default); nocache/cleardatacache options; cache consolidated to sysdir_plus
*   18.1.1: Copilot PR review fixes: strtrim() in sources/topics, simplified download_yaml, improved checksum, path traversal safety
*   18.1.0: Added char metadata (default-on, nochar to suppress); deprecated update query/check/all, metadataoffline, syncforce/preview/dryrun with warnings
*   18.0.0: Deprecated 89 per-indicator sthlp files; replaced with discovery commands (sources, search, info)
*   17.8.1: Pass detail option through to search for wrapped display format
*   17.8.0: Added sources, alltopics discovery commands; enhanced search with topic/field filters and wildcards
* 	17.7.1: Fixed bug where latest option with multiple indicators caused variable name truncation error
* 	17.7: basic country context variables (region/admin/income/lending) now added by default; use nobasic to disable
* 	17.6.0: Added linewrap, maxlength, linewrapformat, describe options for graph metadata
* 	17.6.1: Fixed missing value handling in captured nlines scalars to prevent forvalues syntax errors
* 	17.6.2: Fixed double-quoting issue in captured return locals for wrapped metadata
* 	17.6.3: Use macval() in capture to preserve original quoting of wrapped metadata returns
* 	17.6.5: Added _newline format return values - was missing from wbopendata return capture
* 	17.6.4: Fixed r() capture syntax - use compound quotes without = to preserve stacked strings
*******************************************************************************

program def wbopendata, rclass

version 14.0

    syntax                                          ///
                 [,                                 ///
                        LANGUAGE(string)           ///
                        COUNTRY(string)            ///
                        TOPICS(string)             ///
                        INDICATORs(string)         ///
                        YEAR(string)               ///
						DATE(string)				///
						SOURCE(string)				///
 						PROJECTION					///
                        LONG                       ///
                        CLEAR                      ///
                        LATEST                     ///
                        NOMETADATA                 ///
						UPDATE						///
						QUERY						///
						CHECK						///
						NOPRESERVE					///
						PRESERVEOUT				///
						COUNTRYMETADATA			///
						ALL						///
						BREAKNOMETADATA			///
						METADATAOFFLINE			///
						FORCE						///
						SHORT						///
						DETAIL						///
						CTRYLIST					///
						MATCH(string)				///
						ISO					///
						REGIONS				///
						ADMINR				///
						INCOME				///
						LENDING				///
						GEO					///
						noBASIC				///
						noCHAR				///
						FULL				///
						COUNTRYCODE_ISO2 	///
						REGION 				///
						REGION_ISO2 		///
						REGIONNAME 			///
						ADMINREGION 		///
						ADMINREGION_ISO2 	///
						ADMINREGIONNAME 	///
						INCOMELEVEL 		///
						INCOMELEVEL_ISO2 	///
						INCOMELEVELNAME 	///
						LENDINGTYPE 		///
						LENDINGTYPE_ISO2 	///
						LENDINGTYPENAME 	///
						capital 			///
						latitude 			///
						longitude 			///
						countryname		///
						SYNC			///
						REPLACE			///
						SYNCFORCE		///
						SYNCPREVIEW		///
						SYNCDRYRUN		///
						CHECKUPDATE		///
						CLEARCACHE		///
						CACHEINFO		///
						SOURCES			///
						ALLSOURCES		///
						ALLTOPICS		///
						SEARCH(string)	///
						LIMIT(string)	///
						SEARCHSOURCE(string)	///
						SEARCHTOPIC(string)	///
						SEARCHFIELD(string)	///
						EXACT			///
						INFO(string)	///
						LINEWRAP(string) 	///
						MAXLENGTH(string) 	///
						LINEWRAPFORMAT(string) 	///
						DESCRIBE		///
						OFFLINE(string)	///
						NOCACHE			///
						CACHEDAYS(integer 7)	///
						CLEARDATACACHE	///
						RESETDATACACHE	///
						VERBOSE			///
                 ]

quietly {

local limit_specified = ("`limit'" != "")
local limit_val = 20
if (`limit_specified') {
	local limit_val = real("`limit'")
	if (missing(`limit_val') | `limit_val' <= 0) local limit_val = 20
}


local indicator `indicators'

	* Default: add basic country context variables unless nobasic is specified
	* With noBASIC syntax: basic="" means add basic vars, basic="nobasic" means skip them
	* Basic adds: region regionname adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename
	if ("`basic'" == "") {
		local basic "basic"
	}
	else if ("`basic'" == "nobasic") {
		local basic ""
	}

	* Decide when metadata is needed (linewrap/described even if nometadata is set)
	local needmeta 0
	if ("`nometadata'" == "") local needmeta 1
	if ("`linewrap'" != "") local needmeta 1
	if ("`linewrapformat'" != "") local needmeta 1
	if ("`maxlength'" != "") local needmeta 1

	* Discovery commands: sources, allsources, topics, search, info
	* Note: search can be empty if searchsource or searchtopic is provided (browse mode)
	local has_search_filter = ("`searchsource'" != "" | "`searchtopic'" != "")
	if ("`sources'" != "" | "`allsources'" != "" | "`alltopics'" != "" | "`search'" != "" | `has_search_filter' | "`info'" != "") {
		* List sources (sources=20 default, allsources=all)
		if ("`sources'" != "") {
			noisily _wbopendata_sources, limit(`limit_val')
			return add
			exit _rc
		}
		if ("`allsources'" != "") {
			if (`limit_specified') {
				noisily _wbopendata_sources, limit(`limit_val')
			}
			else {
				noisily _wbopendata_sources
			}
			return add
			exit _rc
		}
		* List all topics
		if ("`alltopics'" != "") {
			if (`limit_specified') {
				noisily _wbopendata_topics, limit(`limit_val')
			}
			else {
				noisily _wbopendata_topics
			}
			return add
			exit _rc
		}
		* Search indicators (also handles browse mode when only filter is provided)
		if ("`search'" != "" | `has_search_filter') {
			noisily _wbopendata_search "`search'", limit(`limit_val') ///
				source("`searchsource'") topic("`searchtopic'") ///
				field("`searchfield'") `exact' `detail'
			return add
			exit _rc
		}
		* Get indicator info
		if ("`info'" != "") {
			capture noisily _wbopendata_info, indicator("`info'")
			if (_rc == 0) {
				return add
			}
			exit _rc
		}
	}

	* Sync and cache maintenance commands
	* Resolve backward-compatible aliases into canonical modifiers (deprecated v18.0):
	*   syncforce   → sync + replace + force
	*   syncpreview → sync + replace
	*   syncdryrun  → sync (dryrun is the default)
	if ("`syncforce'" != "") {
		noi di as txt "{bf:Note:} {cmd:syncforce} is deprecated; use {cmd:sync replace force} instead."
		local sync "sync"
		local replace "replace"
	}
	if ("`syncpreview'" != "") {
		noi di as txt "{bf:Note:} {cmd:syncpreview} is deprecated; use {cmd:sync replace} instead."
		local sync "sync"
		local replace "replace"
	}
	if ("`syncdryrun'" != "") {
		noi di as txt "{bf:Note:} {cmd:syncdryrun} is deprecated; use {cmd:sync} instead."
		local sync "sync"
	}

	if ("`cleardatacache'" != "") {
		_wbopendata_cache, cleardatacache
		exit 0
	}

	if ("`resetdatacache'" != "") {
		_wbopendata_cache, resetdatacache
		exit 0
	}

	if ("`sync'" != "" | "`checkupdate'" != "" | "`clearcache'" != "" | "`cacheinfo'" != "") {
		if ("`clearcache'" != "") {
			_wbopendata_cache, clear
			exit _rc
		}
		if ("`cacheinfo'" != "") {
			_wbopendata_cache, info
			exit _rc
		}
		if ("`checkupdate'" != "") {
			_wbopendata_cache, checkversion
			if (r(needs_update)) {
				di as result "Update available!"
				di as text "  Local version:  v" r(local_version)
				di as text "  Remote version: v" r(remote_version)
				di as text ""
				di as text `"Run {stata wbopendata, sync replace:wbopendata, sync replace} to update"'
			}
			else di as text "Metadata is up-to-date (v" r(local_version) ")"
			exit _rc
		}
		* sync: always show preview first
		noi _wbopendata_sync_preview, `detail'
		return add
		* sync without replace: dryrun (safe default) — stop after preview
		if ("`replace'" == "") {
			di as text ""
			if ("`force'" != "") {
				di as text `"To apply changes, run: {stata wbopendata, sync replace force:wbopendata, sync replace force}"'
			}
			else {
				di as text `"To apply changes, run: {stata wbopendata, sync replace:wbopendata, sync replace}"'
			}
			exit 0
		}
		* sync replace: actually apply the sync (force passes through to _wbopendata_sync)
		di as text ""
		di as text "Proceeding with sync..."
		di as text ""
		if ("`force'" != "") _wbopendata_sync, force
		else _wbopendata_sync
		local sync_rc = _rc
		if (`sync_rc' == 0) {
			* Get counts after sync for history
			quietly _wbopendata_sync_preview
			local ind_count = r(ind_count)
			local src_count = r(src_count)
			local top_count = r(top_count)
			local ctry_count = r(ctry_count)
			local method = r(cache_method)
			local by_source = r(by_source)
			local by_topic = r(by_topic)
			if ("`method'" == "") local method = "unknown"
			* Write stats history with breakdown (suppress rclass warning)
			capture quietly _wbopendata_write_stats_history, ///
				method("`method'") ///
				indicators(`ind_count') ///
				sources(`src_count') ///
				topics(`top_count') ///
				countries(`ctry_count') ///
				bysource("`by_source'") ///
				bytopic("`by_topic'")
		}
		exit `sync_rc'
	}

	* describe option: just fetch metadata and exit
	if ("`describe'" != "") {
		if ("`indicator'" == "") {
			noi di as err "describe option requires indicator()"
			exit 198
		}
		local _lw_opts ""
		if "`linewrap'" != "" local _lw_opts `"linewrap("`linewrap'") maxlength("`maxlength'") linewrapformat("`linewrapformat'")"'
		noi _query_metadata , indicator("`indicator'") `_lw_opts' offline("`offline'") `verbose'
		return add
		exit _rc
	}

	* query and check can not be selected at the same time
	if ("`query'" == "query") & ("`check'" == "check") {
		noi di  as err "update query and update check options cannot be selected at the same time."
		exit 198
	}

	* match and indicators can not be selected at the same time
		if ("`match'" != "") & ("`indicator'" != "") {
			noi di  as err "{p 4 4 2}Error: The {bf:match} option cannot be used with the {bf:indicators} option. The {bf:match} option is used to retrieve country metadata only and does not download indicator data.{p_end}"
			noi di  as err "{p 4 4 2}Please use either {bf:match} alone for country metadata, or {bf:indicators} without {bf:match} to download indicator data.{p_end}"
			exit 198
		}
	
	* Check if no substantive options provided - show help message
	local has_data_request = wordcount("`indicator' `country' `topics' `match'") > 0
	local has_sync_request = wordcount("`sync' `syncforce' `syncpreview' `syncdryrun' `checkupdate' `clearcache' `cacheinfo'") > 0
	local has_discovery_request = wordcount("`search' `info' `sources' `allsources' `alltopics' `searchsource' `searchtopic'") > 0
	local has_update_request = wordcount("`update' `query' `check' `countrymetadata' `all' `metadataoffline'") > 0
	
	if !(`has_data_request') & !(`has_sync_request') & !(`has_discovery_request') & !(`has_update_request') {
		noi di as err "You must specify either indicator(), country(), topics(), or match() to download data."
		noi di ""
		noi di as text "Discovery commands:"
		noi di `"{stata `"wbopendata, sources"':  wbopendata, sources}                   - List data sources (limited list)"'
		noi di `"{stata `"wbopendata, allsources"':  wbopendata, allsources}             - List all data sources"'
		noi di `"{stata `"wbopendata, alltopics"':  wbopendata, alltopics}               - List all topic categories"'
		noi di `"{stata `"wbopendata, search(GDP)"':  wbopendata, search(GDP)}           - Search indicators by keyword"'
		noi di `"{stata `"wbopendata, search(NY.GDP.*) searchfield(code)"':  wbopendata, search(NY.GDP.*) searchfield(code)} - Wildcard search in codes"'
		noi di `"{stata `"wbopendata, search(health) searchsource(2)"':  wbopendata, search(health) searchsource(2)} - Search within a source"'
		noi di `"{stata `"wbopendata, info(NY.GDP.MKTP.CD)"':  wbopendata, info(NY.GDP.MKTP.CD)} - Get indicator details"'
		noi di ""
		noi di as text "Cache & sync commands:"
		noi di `"{stata `"wbopendata, checkupdate"':  wbopendata, checkupdate}       - Check for metadata updates"'
		noi di `"{stata `"wbopendata, sync"':  wbopendata, sync}              - Preview metadata changes (dry run)"'
		noi di `"{stata `"wbopendata, sync detail"':  wbopendata, sync detail}       - Detailed preview with source/topic breakdown"'
		noi di `"{stata `"wbopendata, sync replace"':  wbopendata, sync replace}     - Apply metadata sync"'
		noi di `"{stata `"wbopendata, sync replace force"':  wbopendata, sync replace force} - Force re-download metadata"'
		noi di `"{stata `"wbopendata, cacheinfo"':  wbopendata, cacheinfo}           - Display cache status"'
		noi di `"{stata `"wbopendata, cleardatacache"':  wbopendata, cleardatacache}   - Clear cached API data"'
		noi di ""
		noi di as text "Data retrieval examples:"
		noi di `"{stata `"wbopendata, indicator(NY.GDP.MKTP.CD) clear"':  wbopendata, indicator(NY.GDP.MKTP.CD) clear}"'
		noi di `"{stata `"wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA;USA) clear"':  wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA;USA) clear}"'
		noi di `"{stata `"wbopendata, country(BRA) clear"':  wbopendata, country(BRA) clear}"'
		noi di `"{stata `"wbopendata, topics(1) clear"':  wbopendata, topics(1) clear}"'
		noi di ""
		noi di as text "For full documentation:"
		noi di `"{stata `"help wbopendata"':  help wbopendata}"'
		exit 198
	}
	
		set checksum off
	
	* update commands (deprecated v18.1 — replaced by sync family)
		if ("`update'" == "update") & wordcount("`query' `check' `countrymetadata' `all'")==0 {

			noi di as txt ""
			noi di as txt "{bf:Note:} {cmd:update query} is deprecated; use {cmd:sync} or {cmd:checkupdate} instead."
			noi di as txt "  See {help wbopendata##deprecated:help wbopendata, deprecated options}."
			noi di as txt ""
			noi wbopendata, update query
			break
		}

		if ("`update'" == "update") & wordcount("`query' `check' `countrymetadata' `all'")== 1 {

			if ("`query'" != "") {
				noi di as txt "{bf:Note:} {cmd:update query} is deprecated; use {cmd:sync} instead."
			}
			if ("`check'" != "") {
				noi di as txt "{bf:Note:} {cmd:update check} is deprecated; use {cmd:checkupdate} instead."
			}
			if ("`all'" != "") {
				noi di as txt "{bf:Note:} {cmd:update all} is deprecated; use {cmd:sync replace} instead."
			}
			noi di as txt "  See {help wbopendata##deprecated:help wbopendata, deprecated options}."
			noi di as txt ""
			noi _update_wbopendata, update `query' `check'	`countrymetadata' `all' `force' `short' `detail' `ctrylist'
			break

		}

	* metadataoffline options (deprecated v18.1 — replaced by sync + discovery commands)
		if ("`metadataoffline'" == "metadataoffline") {

			noi di as txt ""
			noi di as txt "{bf:Note:} {cmd:metadataoffline} is deprecated as of v18.1."
			noi di as txt "  Use {cmd:sync replace} to update metadata and {cmd:sources}/{cmd:search()}/{cmd:info()} for discovery."
			noi di as txt "  See {help wbopendata##deprecated:help wbopendata, deprecated options}."
			noi di as txt ""
			noi _update_wbopendata, update force all
			local update "update"
			local force  "force"
			local all    "all"
			break
					
		}
		
**********************************************************************************
* option to match	
	
	
	qui if ("`match'" != "") {

		_countrymetadata, match(`match') `full' `iso' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `geo' `isolist' `countryname' `region'  `region_iso2' `regionname' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname'  `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude'

	}

**********************************************************************************
	
	
		local f = 1

		if ("`indicator'" != "") & ("`update'" == "") & ("`match'" == "") {

			_tknz "`indicator'" , parse(;)

			forvalues i = 1(1)`s(items)'  {

			   if ("``i''" != ";") &  ("``i''" != "") {

				   tempfile file`f'

				   noi _query ,       language("`language'")      		///
										 country("`country'")         	///
										 topics("`topics'")           	///
										 indicator("``i''")             ///
										 year("`year'")               	///
										 date("`date'")					///
										 source("`source'")				///
										`projection'					///
										 `long'                       	///
										 `clear'                      	///
										 `nometadata'					///
										 `char'							///
										 offline("`offline'")			///
										 `nocache'						///
										 cachedays(`cachedays')			///
										 `verbose'
					local time  "`r(time)'"
					local namek "`r(name)'"
					local _from_cache "`r(_from_cache)'"


					if (`needmeta' == 1) & ("`indicator'" != "") {
						local _lw_opts ""
						if "`linewrap'" != "" local _lw_opts `"linewrap("`linewrap'") maxlength("`maxlength'") linewrapformat("`linewrapformat'")"'
						* Try YAML frame lookup on cache hit (no API call needed)
						* Skip YAML path when linewrap requested — linewrap processing lives in _query_metadata
						local _used_yaml = 0
						if ("`_from_cache'" == "1" & "`linewrap'" == "") {
							capture frame _wbod_indicators: count
							if (_rc == 0 & r(N) > 0) {
								cap noi _wbod_yaml_metadata, indicator("``i''") frame(_wbod_indicators)
								if (_rc == 0 & "`r(_yaml_found)'" == "1") {
									local _used_yaml = 1
								}
							}
						}
						if (!`_used_yaml') {
							cap: noi _query_metadata  , indicator("``i''") `_lw_opts' offline("`offline'") `verbose'
						}
						if ("`verbose'" != "") {
							noi di as text "(metadata: " cond(`_used_yaml', "YAML frame", "API") " for ``i'')"
						}
						local qm1rc = cond(`_used_yaml', 0, _rc)
						if (`qm1rc' != 0) {
							noi di ""
							noi di as err "{p 4 4 2} Sorry... No metadata available for " as result "`indicator'. {p_end}"
							noi di ""
							if ("`breaknometadata'" != "") {
								break
								exit 21
							}
						}
						else {
							local idx = `f'
								local lw_name `"`r(name_stack)'"'
								if (`"`lw_name'"' != "") {
									return local name`idx'_stack `"`lw_name'"'
								}
								local lw_desc `"`r(description_stack)'"'
								if (`"`lw_desc'"' != "") {
									return local description`idx'_stack `"`lw_desc'"'
								}
								local lw_note `"`r(note_stack)'"'
								if (`"`lw_note'"' != "") {
									return local note`idx'_stack `"`lw_note'"'
								}
								local lw_source `"`r(source_stack)'"'
								if (`"`lw_source'"' != "") {
									return local source`idx'_stack `"`lw_source'"'
								}
								local lw_topic `"`r(topic_stack)'"'
								if (`"`lw_topic'"' != "") {
									return local topic`idx'_stack `"`lw_topic'"'
								}
							* _newline format returns (linewrapformat(newline) or (all))
							local lw_name_nl `"`r(name_newline)'"'
							if (`"`lw_name_nl'"' != "") {
								return local name`idx'_newline `"`lw_name_nl'"'
							}
							local lw_desc_nl `"`r(description_newline)'"'
							if (`"`lw_desc_nl'"' != "") {
								return local description`idx'_newline `"`lw_desc_nl'"'
							}
							local lw_note_nl `"`r(note_newline)'"'
							if (`"`lw_note_nl'"' != "") {
								return local note`idx'_newline `"`lw_note_nl'"'
							}
							local lw_source_nl `"`r(source_newline)'"'
							if (`"`lw_source_nl'"' != "") {
								return local source`idx'_newline `"`lw_source_nl'"'
							}
							local lw_topic_nl `"`r(topic_newline)'"'
							if (`"`lw_topic_nl'"' != "") {
								return local topic`idx'_newline `"`lw_topic_nl'"'
							}
							local lw_nlines 0
							local lw_dnl 0
							local lw_nnl 0
							local lw_snl 0
							local lw_tnl 0

							capture local lw_nlines = r(name_nlines)
							if (_rc == 0 & `lw_nlines' != .) return scalar name`idx'_nlines = `lw_nlines'
							if (_rc | `lw_nlines' == .) local lw_nlines 0
							capture local lw_dnl = r(description_nlines)
							if (_rc == 0 & `lw_dnl' != .) return scalar description`idx'_nlines = `lw_dnl'
							if (_rc | `lw_dnl' == .) local lw_dnl 0
							capture local lw_nnl = r(note_nlines)
							if (_rc == 0 & `lw_nnl' != .) return scalar note`idx'_nlines = `lw_nnl'
							if (_rc | `lw_nnl' == .) local lw_nnl 0
							capture local lw_snl = r(source_nlines)
							if (_rc == 0 & `lw_snl' != .) return scalar source`idx'_nlines = `lw_snl'
							if (_rc | `lw_snl' == .) local lw_snl 0
							capture local lw_tnl = r(topic_nlines)
							if (_rc == 0 & `lw_tnl' != .) return scalar topic`idx'_nlines = `lw_tnl'
							if (_rc | `lw_tnl' == .) local lw_tnl 0

							* copy line-by-line returns when present (linewrapformat(all))
							if (`lw_nlines' > 0) {
								forvalues ln = 1/`lw_nlines' {
									capture local lineval "`r(name_line`ln')'"
									if (_rc == 0 & "`lineval'" != "") return local name`idx'_line`ln' "`lineval'"
								}
							}
							if (`lw_dnl' > 0) {
								forvalues ln = 1/`lw_dnl' {
									capture local lineval `"`r(description_line`ln')'"'
									if (_rc == 0 & `"`lineval'"' != "") return local description`idx'_line`ln' `"`lineval'"'
								}
							}
							if (`lw_nnl' > 0) {
								forvalues ln = 1/`lw_nnl' {
									capture local lineval `"`r(note_line`ln')'"'
									if (_rc == 0 & `"`lineval'"' != "") return local note`idx'_line`ln' `"`lineval'"'
								}
							}
							if (`lw_snl' > 0) {
								forvalues ln = 1/`lw_snl' {
									capture local lineval "`r(source_line`ln')'"
									if (_rc == 0 & "`lineval'" != "") return local source`idx'_line`ln' "`lineval'"
								}
							}
							if (`lw_tnl' > 0) {
								forvalues ln = 1/`lw_tnl' {
									capture local lineval "`r(topic_line`ln')'"
									if (_rc == 0 & "`lineval'" != "") return local topic`idx'_line`ln' "`lineval'"
								}
							}

							capture local scite `"`r(sourcecite)'"'
							if (_rc == 0 & `"`scite'"' != "") return local sourcecite`idx' `"`scite'"'

							* --- variable-level char metadata from _query_metadata ---
							if ("`char'" != "nochar") {
								local _vname = trim(lower(subinstr(word("``i''",1),".","_",.)))
								capture confirm variable `_vname'
								if (_rc == 0) {
									char `_vname'[source]      `"`r(source)'"'
									char `_vname'[description] `"`r(description)'"'
									char `_vname'[note]        `"`r(note)'"'
									char `_vname'[sourcecite]  `"`r(sourcecite)'"'
									local _t1 "`r(topic1)'"
									local _t2 "`r(topic2)'"
									local _t3 "`r(topic3)'"
									local _topics "`_t1'"
									if ("`_t2'" != "") local _topics "`_topics'; `_t2'"
									if ("`_t3'" != "") local _topics "`_topics'; `_t3'"
									char `_vname'[topic] "`_topics'"
								}
							}
						}
					}

					local w1 = word("``i''",1)
					return local varname`f'     = trim(lower(subinstr(word("`w1'",1),".","_",.)))
					return local indicator`f'  "`w1'"
					return local topics`f'     "`topics'"
					return local year`f'       "`year'"
					return local source`f'     "`r(source)'"
					return local varlabel`f'   "`r(varlabel)'"
					return local time`f'       "`time'"

					local namek = trim(lower(subinstr(word("`w1'",1),".","_",.)))

					if ("`long'" != "") {
						sort countrycode `time'
					}

					save `file`f''

					local f = `f'+1

				}
				
				local name "`name' `namek'"

			}

		}

		 else {

			if ("`update'" == "") & ("`match'" == "") {
			 
				noi _query , language("`language'")       	///
									country("`country'")    ///
									topics("`topics'")      ///
									indicator("``i''")      ///
									year("`year'")          ///
									date("`date'")			///
									source("`source'")		///
									`projection'			///
									`long'                  ///
									`clear'                 ///
									`latest'                ///
									`nometadata'			///
									`char'					///
									offline("`offline'")	///
									`nocache'				///
									cachedays(`cachedays')	///
									`verbose'
				local time  "`r(time)'"
				local name "`r(name)'"
				local _from_cache "`r(_from_cache)'"


				if (`needmeta' == 1) & ("`indicator'" != "") {
					local _lw_opts ""
					if "`linewrap'" != "" local _lw_opts `"linewrap("`linewrap'") maxlength("`maxlength'") linewrapformat("`linewrapformat'")"'
					* Try YAML frame lookup on cache hit (no API call needed)
					* Skip YAML path when linewrap requested — linewrap processing lives in _query_metadata
					local _used_yaml = 0
					if ("`_from_cache'" == "1" & "`linewrap'" == "") {
						capture frame _wbod_indicators: count
						if (_rc == 0 & r(N) > 0) {
							cap noi _wbod_yaml_metadata, indicator("``i''") frame(_wbod_indicators)
							if (_rc == 0 & "`r(_yaml_found)'" == "1") {
								local _used_yaml = 1
							}
						}
					}
					if (!`_used_yaml') {
						cap: noi _query_metadata  , indicator("``i''") `_lw_opts' offline("`offline'") `verbose'
					}
					if ("`verbose'" != "") {
						noi di as text "(metadata: " cond(`_used_yaml', "YAML frame", "API") " for ``i'')"
					}
					local qm2rc = cond(`_used_yaml', 0, _rc)
					if ("`qm2rc'" == "") {
						noi di ""
						noi di as err "{p 4 4 2} Sorry... No metadata available for " as result "`indicator'. {p_end}"
						noi di ""
						if ("`breaknometadata'" != "") {
							break
							exit 22
						}
					}
					else {
						local idx = 1
						local lw_name `"`r(name_stack)'"'
						if (`"`lw_name'"' != "") {
							return local name`idx'_stack `"`lw_name'"'
						}
						local lw_desc `"`r(description_stack)'"'
						if (`"`lw_desc'"' != "") {
							return local description`idx'_stack `"`lw_desc'"'
						}
						local lw_note `"`r(note_stack)'"'
						if (`"`lw_note'"' != "") {
							return local note`idx'_stack `"`lw_note'"'
						}
						local lw_source `"`r(source_stack)'"'
						if (`"`lw_source'"' != "") {
							return local source`idx'_stack `"`lw_source'"'
						}
						local lw_topic `"`r(topic_stack)'"'
						if (`"`lw_topic'"' != "") {
							return local topic`idx'_stack `"`lw_topic'"'
						}

						* _newline format returns (linewrapformat(newline) or (all))
						local lw_name_nl `"`r(name_newline)'"'
						if (`"`lw_name_nl'"' != "") {
							return local name`idx'_newline `"`lw_name_nl'"'
						}
						local lw_desc_nl `"`r(description_newline)'"'
						if (`"`lw_desc_nl'"' != "") {
							return local description`idx'_newline `"`lw_desc_nl'"'
						}
						local lw_note_nl `"`r(note_newline)'"'
						if (`"`lw_note_nl'"' != "") {
							return local note`idx'_newline `"`lw_note_nl'"'
						}
						local lw_source_nl `"`r(source_newline)'"'
						if (`"`lw_source_nl'"' != "") {
							return local source`idx'_newline `"`lw_source_nl'"'
						}
						local lw_topic_nl `"`r(topic_newline)'"'
						if (`"`lw_topic_nl'"' != "") {
							return local topic`idx'_newline `"`lw_topic_nl'"'
						}

						local lw_nlines 0
						local lw_dnl 0
						local lw_nnl 0
						local lw_snl 0
						local lw_tnl 0

						capture local lw_nlines = r(name_nlines)
						if (_rc == 0 & `lw_nlines' != .) return scalar name`idx'_nlines = `lw_nlines'
						if (_rc | `lw_nlines' == .) local lw_nlines 0
						capture local lw_dnl = r(description_nlines)
						if (_rc == 0 & `lw_dnl' != .) return scalar description`idx'_nlines = `lw_dnl'
						if (_rc | `lw_dnl' == .) local lw_dnl 0
						capture local lw_nnl = r(note_nlines)
						if (_rc == 0 & `lw_nnl' != .) return scalar note`idx'_nlines = `lw_nnl'
						if (_rc | `lw_nnl' == .) local lw_nnl 0
						capture local lw_snl = r(source_nlines)
						if (_rc == 0 & `lw_snl' != .) return scalar source`idx'_nlines = `lw_snl'
						if (_rc | `lw_snl' == .) local lw_snl 0
						capture local lw_tnl = r(topic_nlines)
						if (_rc == 0 & `lw_tnl' != .) return scalar topic`idx'_nlines = `lw_tnl'
						if (_rc | `lw_tnl' == .) local lw_tnl 0

						if (`lw_nlines' > 0) {
							forvalues ln = 1/`lw_nlines' {
								capture local lineval "`r(name_line`ln')'"
								if (_rc == 0 & "`lineval'" != "") return local name`idx'_line`ln' "`lineval'"
							}
						}
						if (`lw_dnl' > 0) {
							forvalues ln = 1/`lw_dnl' {
								capture local lineval `"`r(description_line`ln')'"'
								if (_rc == 0 & `"`lineval'"' != "") return local description`idx'_line`ln' `"`lineval'"'
							}
						}
						if (`lw_nnl' > 0) {
							forvalues ln = 1/`lw_nnl' {
								capture local lineval `"`r(note_line`ln')'"'
								if (_rc == 0 & `"`lineval'"' != "") return local note`idx'_line`ln' `"`lineval'"'
							}
						}
						if (`lw_snl' > 0) {
							forvalues ln = 1/`lw_snl' {
								capture local lineval "`r(source_line`ln')'"
								if (_rc == 0 & "`lineval'" != "") return local source`idx'_line`ln' "`lineval'"
							}
						}
						if (`lw_tnl' > 0) {
							forvalues ln = 1/`lw_tnl' {
								capture local lineval "`r(topic_line`ln')'"
								if (_rc == 0 & "`lineval'" != "") return local topic`idx'_line`ln' "`lineval'"
							}
						}

						capture local scite `"`r(sourcecite)'"'
						if (_rc == 0 & `"`scite'"' != "") return local sourcecite`idx' `"`scite'"'

						* --- variable-level char metadata from _query_metadata ---
						if ("`char'" != "nochar") {
							local _vname = trim(lower(subinstr(word("`indicator'",1),".","_",.)))
							capture confirm variable `_vname'
							if (_rc == 0) {
								char `_vname'[source]      `"`r(source)'"'
								char `_vname'[description] `"`r(description)'"'
								char `_vname'[note]        `"`r(note)'"'
								char `_vname'[sourcecite]  `"`r(sourcecite)'"'
								local _t1 "`r(topic1)'"
								local _t2 "`r(topic2)'"
								local _t3 "`r(topic3)'"
								local _topics "`_t1'"
								if ("`_t2'" != "") local _topics "`_topics'; `_t2'"
								if ("`_t3'" != "") local _topics "`_topics'; `_t3'"
								char `_vname'[topic] "`_topics'"
							}
						}
					}
				}

			}

			local w1 = word("`indicator'",1)
			return local varname1     = trim(lower(subinstr(word("`w1'",1),".","_",.)))
			return local indicator1  "`w1'"
			return local country1    "`country'"
			return local topics1     "`topics'"
			return local year1       "`year'"
			return local source1     "`r(source)'"
			return local varlabel1   "`r(varlabel)'"
			return local time1       "`time'"

			local name = trim(lower(subinstr(word("`w1'",1),".","_",.)))
			
		}

		return local indicator  "`indicator'"
		local f = `f'-1

		if (`f' != 0) {

			if ("`long'" != "") {
				use `file1'
				forvalues i = 2(1)`f'  {
					merge countrycode year using `file`i''
					drop _merge
					sort countrycode `time'
				}
			}

			if ("`long'" == "") {
				use `file1'
				forvalues i = 2(1)`f'  {
					append using `file`i''
				}
			}
		}

		if ("`latest'" != "") &  ("`long'" != "") {
		    
			* Keep the full name for rowmiss (may contain multiple indicators)
			local name_full = trim("`name'")
			
			* Check if name is too long for return value
		    local length_name = length("`name_full'")
			* shorten name if too long (only for return value, not for variable reference)
			if (`length_name' > 20) {
				* Only return first 20 chars for r(name)
				return local name = substr("`name_full'",1,20)
			}
			
			tempvar tmp
			egen `tmp' = rowmiss(`name_full')
			keep if `tmp' == 0
			sort countryname countrycode `time'
			bysort countryname countrycode : keep if _n==_N

			* latest return values for graph subtitles
			capture confirm variable `time'
			if (_rc == 0) {
				quietly count if !missing(`time')
				local ncountries = r(N)
				if (`ncountries' > 0) {
					quietly summarize `time', meanonly
					local avgyear = r(mean)
					local maxyear = r(max)
					local avgyear_str : display %9.1f `avgyear'
					local subtitle "Latest Available Year, `ncountries' countries (avg year `avgyear_str')"
					return local latest "`subtitle'"
					return local latest_ncountries "`ncountries'"
					return local latest_avgyear "`avgyear_str'"
					return local latest_year "`maxyear'"
				}
			}
		}

	}
	
	local nametmp  = "`indicator'"
	local nametmp = lower("`nametmp'")
	local nametmp = subinstr("`nametmp'",";"," ",.)	
	local nametmp = subinstr("`nametmp'",".","_",.) 
	return local name "`nametmp'"
	
**********************************************************************************
	

	qui if ("`update'" == "") {

		tostring  countryname countrycode, replace

		_countrymetadata, match(countrycode) `full' `iso' `regions' `adminr' `income' `lending' `geo' `basic' `countrycode_iso2' `region' `region_iso2' `regionname' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname' `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' `countryname'

	}

**********************************************************************************
* char metadata: dataset-level provenance (default-on, suppressed by nochar)
**********************************************************************************

	if ("`char'" != "nochar") & ("`update'" == "") {
		char _dta[wbopendata_version]   "18.3.1"
		char _dta[wbopendata_timestamp] "`c(current_date)' `c(current_time)'"
		char _dta[wbopendata_user]      "`c(username)'"
		char _dta[wbopendata_syntax]    `"wbopendata, `0'"'
		if ("`indicator'" != "")  char _dta[wbopendata_indicator] "`indicator'"
		if ("`country'" != "")    char _dta[wbopendata_country]   "`country'"
		if ("`language'" != "")   char _dta[wbopendata_language]  "`language'"
		if ("`source'" != "")     char _dta[wbopendata_source_id] "`source'"
		if ("`topics'" != "")     char _dta[wbopendata_topics]    "`topics'"
	}

**********************************************************************************


	if ("`nopreserve'" == "") {
		return add
	}
	

	
	
	
end


*******************************************************************************
*  v 16.3  	8Jul2020               by Joao Pedro Azevedo
* 	change API end point to HTTPS
*******************************************************************************
**********************************************************************************
*  v 16.2.3    29Jun2020 				by Joao Pedro Azevedo
*	 rewrote query metadata. It now uses _api_read.ado
**********************************************************************************
*  v 16.2.2    28Jun2020 				by Joao Pedro Azevedo
*	 changed server used to query metadata
***********************************************************************************
*  v 16.2.1    14Apr2020 				by Joao Pedro Azevedo
*    add flow check before runing _query.ado / _query.ado should not run if 
*    metadataoffline option is selected.
**********************************************************************************
*  v 16.2      13Apr2020 				by Joao Pedro Azevedo
*    create option metadataoffline 
*       generates SORUCEID and TOPICID metadata in local installation
*       71 sthlp files are generated and 15mb of documentation is created
**********************************************************************************
*  v 16.1      12Apr2020 				by Joao Pedro Azevedo
*	remove metadata of SOURCID and TOPICSID from the main dissemination package                                                     
**********************************************************************************
*  v 16.0.1    31Oct2019               by Joao Pedro Azevedo 
 * improve a few small functionalities
**********************************************************************************
*  v 16.0	    27Oct2019               by Joao Pedro Azevedo 
* created and tested new functions, namely:
*  _api_read_indicators.ado : download indicator list from API, for formats 
*    output in a Stata readable form
*  _update_indicators.ado: calls _api_read_indicators.ado, and uses its output to  
*  generate additioanl documentation 
*  outputs for wbopendata:
*     dialogue indicator list
*     sthlp indicator list by Source and Topic
*     sthlp indicator metadata by Source and Topic
*  match option supported in wbopendata (add countrymetadata matching on MATCH var) 
* _website.ado : screens a text file and converts and http or www "word" to a SMCL 
*    web compatible code.
* _parameters.ado: now include detailed count of indicators by SOURCE and TOPIC
* _wbopendata.ado: renamned _update_wbopendata
* _indicator: renamed _update_indicators
* _update_wbopendata.ado: now checks for changes at the SOURCE or TOPIC level
* fixed return list when multiple indicators are selected
* updated help file to allow for the search of indicators by Source and Topics
**********************************************************************************
*  v 15.1	    04Mar2019               by Joao Pedro Azevedo 
*	New Features
*		new error categories to faciliate debuging
*		error 23: series no longer supported moved to archive
*		country attribute table fully revised and linked to api
*		update check, update query, and update
*		auto refresh indicators
*		revised _wbopendata.ado 		
*		update query; update check; and update options are included
* 		country attributes revised
*		update countrymetadata option created
*		country metadata documentation in help file revised
*		break code when no metadata is available is now an option
*   Revisions
*       over 16,000 indicators
**********************************************************************************
*  v 15.0.1		8Fev2019				by Joao Pedro Azevedo
**********************************************************************************
*  v 15.0	    2Fev2019               	by Joao Pedro Azevedo 
**********************************************************************************
*  v 14.3 	2Feb2019               by Joao Pedro Azevedo 
* 	Bug Fixed
*		_wbopendata_update.ado revised; out.txt file no longer created
**********************************************************************************
*  v 14.2 	31Jan2019               by Joao Pedro Azevedo 
* Bug Fixed
	* update _wbopendata_update.ado
	* set checksum off
**********************************************************************************
*  v 14.1 	19Jan2019               by Joao Pedro Azevedo 
* 	New options: 
     * indicator update function
     * nopreserve option (return list is can be preserved)
* 	Bugs fixed
    * latest option
    * _query_metadata.ado (source id return list) fixed
* 	Revisions
     * examples
     * update help file
     * list of indicators
**********************************************************************************
*  v 14.0  14Jan2019               by Joao Pedro Azevedo 
*		revised indicator list
*		change to new API server 
**********************************************************************************
*  v 13.4  01jul2014               by Joao Pedro Azevedo                        *
*       long reshape
**********************************************************************************
*  v 13.3  30june2014               by Joao Pedro Azevedo                        *
*       new error control (clear option)
**********************************************************************************
*  v 13.2  24june2014               by Joao Pedro Azevedo                        *
*       new error control
**********************************************************************************
*  v 13.1  23june2014               by Joao Pedro Azevedo                        *
*       regional code, name and iso2code
**********************************************************************************
*  v 13  20june2014               by Joao Pedro Azevedo                        *
* 		fix the dups problem                                                    *
*       improve the error messages                                              *
*       update the list of indicators to 9960                                 *
**********************************************************************************
*  v 12  31jan2013               by Joao Pedro Azevedo                        *
*       update to 7349 indicators
*       return list include variable name and label
**********************************************************************************
