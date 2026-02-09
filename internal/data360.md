# Data360 API Review and `wbopendata` Extension Notes

**Last updated:** 29 Jan 2026

## Purpose
Summarize the World Bank Data360 API and outline a clear, low-risk path to extend `wbopendata` to support Data360 sources alongside the classic World Bank v2 API.

## Key Sources
- Data360 API landing page: https://data360.worldbank.org/en/api
- Data360 OpenAPI specs (World Bank): https://github.com/worldbank/open-api-specs
- Data360 R client (endpoint hints): https://cran.r-project.org/web/packages/data360r/data360r.pdf
- Classic World Bank API call structure (v2): https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures

## Executive Summary
- **Data360 is not the classic v2 API.** It appears to expose new endpoints and object models beyond the `https://api.worldbank.org/v2/` indicators API that `wbopendata` currently wraps.
- **The OpenAPI spec is the authoritative contract.** It should be treated as the single source of truth for endpoints, parameters, and schemas.
- **Minimal risk path:** add a **new adapter** for Data360 and keep the existing v2 workflow untouched. This prevents regressions and preserves compatibility.

## What Data360 Likely Adds (from sources)
Based on the OpenAPI specs and the `data360r` package documentation:

- **Multiple Data360 “sites”** (e.g., TCdata360, Govdata360) with different catalogs.
- **Search endpoints** for indicators, datasets, countries, and categories.
- **Data endpoints** to retrieve indicator values or dataset tables.
- **Metadata endpoints** for indicators, datasets, and country context.
- **Navigation-related endpoints** (hierarchies, categories, toolkits, related content).

## Current `wbopendata` Architecture (relevant constraints)
- The v2 API workflow is a **thin wrapper** over `https://api.worldbank.org/v2/` endpoints.
- Data parsing is tightly coupled to the v2 response format and paging strategy.
- Update and metadata features are v2-specific and rely on v2 endpoints and schemas.

## Extension Strategy (Recommended)
### 1) Add a Data360 adapter (parallel path)
Create a new set of internal helpers instead of modifying `_api_read.ado` or v2 parsing:

- `_api_read_360.ado` — build and execute Data360 requests.
- `_query_360.ado` — high-level query builder (search, data, metadata).
- `_parse_360.ado` — parse Data360 responses into Stata datasets.

### 2) Add a top-level command surface
Two clean options (pick one):

**Option A: new command**
- `wbdata360 ...` for Data360 only, keep `wbopendata` unchanged.

**Option B: new source option**
- `wbopendata, source(data360) ...` to branch into the Data360 adapter.

Option A minimizes risk and avoids mixing response schemas. Option B may be preferred if a unified UX is required.

### 3) Define a minimal feature subset for v1
Start with:
- Search (indicator/dataset/country)
- Data pull by indicator/dataset
- Metadata retrieval

Defer advanced endpoints (related content, toolkits, nav trees) until core data flow is stable.

### 4) Cache + paging strategy
Data360 response sizes and paging rules may differ. Implement:
- explicit `page` + `per_page` controls
- a deterministic cache path (mirror the v2 cache design)
- a strict cap/guard to avoid oversized downloads by default

### 5) Compatibility safeguards
- Do **not** change v2 defaults or parsing logic.
- Gate Data360 features behind explicit options.
- Keep metadata output names distinct to avoid collisions with v2 metadata.

## Proposed Stata Interface (Draft)
This is a strawman for discussion, not final syntax.

```
wbdata360, site(tc) search("education")
wbdata360, site(gov) indicator("XYZ.123") country(BRA) year(2000/2023)
wbdata360, site(tc) metadata indicator("XYZ.123")
```

Or unified:

```
wbopendata, source(data360) site(tc) indicator("XYZ.123")
```

## Implementation Checklist
1. **Extract OpenAPI endpoints** into an internal table (endpoint, method, parameters, response schema).
2. **Prototype one endpoint** (search) and validate parsing in Stata.
3. **Add paging and rate-limit handling** if required by API.
4. **Add metadata mapping** to align with `wbopendata` return conventions.
5. **Create tests** (stataci) for search + data + metadata.
6. **Document** in `doc/` with usage examples and limitations.

## Risks / Open Questions
- Does Data360 enforce auth keys or rate limits? (Confirm in OpenAPI spec.)
- Response formats may be nested or hierarchical; parsing strategy must be robust.
- Country/indicator IDs may not match v2 IDs; mapping will be needed if users expect v2 codes.

## Next Action (Recommended)
- Open the OpenAPI spec JSON and inventory the concrete endpoints/parameters used by Data360.
- Decide on command surface (new command vs. new `source()` option).
- Build a small proof-of-concept for search + metadata.

review the World Bank data360 api documentation https://data360.worldbank.org/en/api ; and who wbopendata can be extended to accomdoate that
I'll fetch the World Bank Data360 API documentation to understand its structure and capabilities.

Web Fetchhttps://data360.worldbank.org/en/api
Fetched from https://data360.worldbank.org/en/api
The main page didn't contain detailed documentation. Let me search for more specific API details and explore related documentation pages.

Web SearchWorld Bank Data360 API documentation endpoints REST 2025 2026
OUT
Web search results for query: "World Bank Data360 API documentation endpoints REST 2025 2026"

Links: [{"title":"API | World Bank Data360","url":"https://data360.worldbank.org/en/api"},{"title":"World Bank Open Data | Data","url":"https://data.worldbank.org/"},{"title":"API Basic Call Structures – World Bank Data Help Desk","url":"https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures"},{"title":"Package ‘data360r’ July 22, 2025 Type Package","url":"https://cran.r-project.org/web/packages/data360r/data360r.pdf"},{"title":"API Document","url":"https://documents.worldbank.org/en/publication/documents-reports/api"},{"title":"GitHub - worldbank/open-api-specs","url":"https://github.com/worldbank/open-api-specs"},{"title":"Unlocking Global Insights: A Deep Dive into the World Bank Data MCP Server","url":"https://skywork.ai/skypage/en/global-insights-world-bank-data/1980822954013011968"},{"title":"Data360 About | World Bank Data360","url":"https://data360.worldbank.org/en/about"},{"title":"Developer Information: Overview – World Bank Data Help Desk","url":"https://datahelpdesk.worldbank.org/knowledgebase/articles/889386-developer-information-overview"},{"title":"World Bank API - PublicAPI","url":"https://publicapi.dev/world-bank-api"}]

Based on my search, here's what I found about the World Bank Data360 API:

## World Bank Data360 API Overview

Data360 is currently in Beta, and the World Bank open data site is expanding to Data360, a newly curated collection of data, analytics, and tools to foster development.

### About Data360

The World Bank's Open Data portal is becoming Data360, an even more comprehensive, integrated set of curated development data from across the World Bank Group and partners. By opening up to 300 million data points in one place and by launching new search and analytics functions, Data360 is designed to make World Bank Group and partner data more accessible, user-friendly, and actionable.

### API Documentation Resources

1. **Official API Page**: There is a GitHub repository (worldbank/open-api-specs) that contains the open-api specs file that feeds the Data360 API documentation page.

2. **Base URL**: The World Bank API base URL is https://api.worldbank.org

### R Package (data360r) - Endpoint Details

The `data360r` R package (updated July 2025) reveals several API endpoints and parameters:

- The API connects to data360 sites with possible choices: 'tc' for TCdata360, 'gov' for Govdata360.

- Resource types include: 'related' (to find WBG content related to certain topics and countries - note this endpoint calls external APIs and may take ~10s initially), 'toolkits' (to find WBG toolkits related to topics/subtopics), and 'nav' (to list root categories in navigational hierarchy).

- Key functions include: search_360 to search indicators/countries/categories/datasets, get_data360 to get actual indicator/dataset/country-level data, and get_metadata360 to get indicator/dataset/country-level metadata.

### Recent Developments (2025)

The World Bank's own development of an MCP server for its Data360 platform signals a strategic shift towards AI-native data access.

### Key Links
- Official Data360 API page: https://data360.worldbank.org/en/api
- GitHub OpenAPI specs: https://github.com/worldbank/open-api-specs
- World Bank Data Help Desk: https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures


REMINDER: You MUST include the sources above in your response to the user using markdown hyperlinks.
Web Fetchhttps://data360.worldbank.org/api
OUT
Request failed with status code 404
Found useful leads. Let me explore the OpenAPI specs on GitHub and the data360r R package documentation for detailed API structure.

Web Fetchhttps://github.com/worldbank/open-api-specs
Fetched from https://github.com/worldbank/open-api-specs
Web Fetchhttps://cran.r-project.org/web/packages/data360r/data360r.pdf
Fetched from https://cran.r-project.org/web/packages/data360r/data360r.pdf
Web Searchwbopendata Stata package World Bank API source code documentation
OUT
Web search results for query: "wbopendata Stata package World Bank API source code documentation"

Links: [{"title":"wbopendata: Stata module to access World Bank databases – World Bank Data Help Desk","url":"https://datahelpdesk.worldbank.org/knowledgebase/articles/889464-wbopendata-stata-module-to-access-world-bank-data"},{"title":"New release of WBOPENDATA Stata module","url":"https://blogs.worldbank.org/en/opendata/new-release-wbopendata-stata-module"},{"title":"GitHub - jpazvd/wbopendata: WBOPENDATA: Stata module to access World Bank databases","url":"https://github.com/jpazvd/wbopendata"},{"title":"Accessing World Bank Open Data in Stata","url":"https://blogs.worldbank.org/en/opendata/accessing-world-bank-open-data-stata"},{"title":"wbopendata/doc/wbopendata.md at master · jpazvd/wbopendata","url":"https://github.com/jpazvd/wbopendata/blob/master/doc/wbopendata.md"},{"title":"WBOPENDATA: Stata module to access World Bank databases","url":"https://ideas.repec.org/c/boc/bocode/s457234.html"},{"title":"Accessing the World Bank Data APIs in Python, R, Ruby & Stata","url":"https://blogs.worldbank.org/en/opendata/accessing-world-bank-data-apis-python-r-ruby-stata"},{"title":"World Bank Open Data","url":"https://data.worldbank.org/products/third-party-apps"},{"title":"Releases · jpazvd/wbopendata","url":"https://github.com/jpazvd/wbopendata/releases"},{"title":"Wbopendata Stata Module Upgrade","url":"https://blogs.worldbank.org/en/opendata/wbopendata-stata-module-upgrade"}]

Here are the search results for the **wbopendata** Stata package for World Bank API access:

## Overview

wbopendata allows Stata users to download over 3,000 series of indicators from the World Bank databases, including: Development Africa Development Indicators; Doing Business; Education Statistics; Enterprise Surveys; Global Development Finance; Gender Statistics; Health Nutrition and Population Statistics; International Development Association - Results Measurement System; Millennium Development Goals; World Development Indicators; Worldwide Governance Indicators.(no content)These indicators include information from over 256 countries and regions, since 1960.

## Source Code & Documentation

The main resources are:

1. **GitHub Repository**: The source code is hosted at [github.com/jpazvd/wbopendata](https://github.com/jpazvd/wbopendata) - "WBOPENDATA: Stata module to access World Bank databases."

2. **Official World Bank Help Desk**: For more updated information and beta releases of WBOPENDATA, follow the GitHub repository.

3. For more information, including examples on how to use wbopendata, please visit the code and example section of the WBOPENDATA GitHub repository.

## Installation

This module should be installed from within Stata by typing "ssc install wbopendata".

## Version & Licensing

The latest version of the wbopendata module is 16.3. This version is required to work with the latest updates to the API as of July 8, 2020.(no content)The module is made available under terms of the GPL v3.

## Key Features

Three possible downloads options are currently supported: country - all indicators for all years for a single country; topic - all indicators within a specific topic, for all years and all countries; indicator - all years for all countries for a single indicator.(no content)Users can chose from one of three of the languages supported by the database (and Stata), namely, English, Spanish, or French.

## How It Works

The World Bank indicators API provides a RESTful interface onto their data, and it supports basic querying using selection parameters. The API calls return data or metadata in either XML or JSON formats. All the modules above are "wrappers" for this simple interface.

## Author

The wbopendata module was developed and is maintained by Joao Pedro Azevedo from the Poverty, Gender and Equity Unit from the Poverty Reduction and Economic Management Team (LCSPP) in the Latin America and Caribbean Region of the World Bank.


REMINDER: You MUST include the sources above in your response to the user using markdown hyperlinks.
Let me get the actual source code and OpenAPI specification files to understand the implementation details.

Web Fetchhttps://github.com/jpazvd/wbopendata/blob/master/doc/wbopendata.md
Fetched from https://github.com/jpazvd/wbopendata/blob/master/doc/wbopendata.md
Web Fetchhttps://raw.githubusercontent.com/worldbank/open-api-specs/main/Data360%20Open_API.json
Fetched from https://raw.githubusercontent.com/worldbank/open-api-specs/main/Data360%20Open_API.json
Web Fetchhttps://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
Fetched from https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structures
Excellent! Now let me look at the actual wbopendata source code to understand its architecture.

Web Fetchhttps://github.com/jpazvd/wbopendata
Fetched from https://github.com/jpazvd/wbopendata
Web Fetchhttps://raw.githubusercontent.com/jpazvd/wbopendata/master/src/wbopendata.ado
OUT
Request failed with status code 404
Web Fetchhttps://github.com/jpazvd/wbopendata/tree/master/src
Fetched from https://github.com/jpazvd/wbopendata/tree/master/src
Web Fetchhttps://github.com/jpazvd/wbopendata/tree/master/src/w
Fetched from https://github.com/jpazvd/wbopendata/tree/master/src/w
Bash Fetch wbopendata.ado source code
IN
curl -s "https://raw.githubusercontent.com/jpazvd/wbopendata/master/src/w/wbopendata.ado" | head -300

OUT
*******************************************************************************
* wbopendata             
*! v 17.7.1  	 04Jan2026               by Joao Pedro Azevedo
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

version 9.0

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
						LINEWRAP(string) 	///
						MAXLENGTH(string) 	///
						LINEWRAPFORMAT(string) 	///
						DESCRIBE		///
                 ]

quietly {


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

	* describe option: just fetch metadata and exit
	if ("`describe'" != "") {
		if ("`indicator'" == "") {
			noi di as err "describe option requires indicator()"
			exit 198
		}
		noi _query_metadata , indicator("`indicator'") linewrap("`linewrap'") maxlength("`maxlength'") linewrapformat("`linewrapformat'")
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
	
		set checksum off
	
	* update : update query / does not triger the download of any data
		if ("`update'" == "update") & wordcount("`query' `check' `countrymetadata' `all'")==0 {
		
			noi wbopendata, update query
			break
		}
		
	* update : update query / triger the download of selected data
	* update : force  - creates new help files and metadata documentation by source and topics
	* trigger: _parameters
	* triggers _update indicators.ado
	*		refresh Source
	*		refresh Indicators
	
		if ("`update'" == "update") & wordcount("`query' `check' `countrymetadata' `all'")== 1 {

			noi _update_wbopendata, update `query' `check'	`countrymetadata' `all' `force' `short' `detail' `ctrylist'
			break
					
		}

	* metadataoffline options
	* this option will refress all meatadata and generate 71 files with all metadata indicators by source id and topic id.
		if ("`metadataoffline'" == "metadataoffline") {

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
										 `nometadata'
					local time  "`r(time)'"
					local namek "`r(name)'"


					if (`needmeta' == 1) & ("`indicator'" != "") {
						cap: noi _query_metadata  , indicator("``i''") linewrap("`linewrap'") maxlength("`maxlength'") linewrapformat("`linewrapformat'")
						local qm1rc = _rc
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
									capture local lineval "`r(description_line`ln')'"
									if (_rc == 0 & "`lineval'" != "") return local description`idx'_line`ln' "`lineval'"
								}
							}
							if (`lw_nnl' > 0) {
								forvalues ln = 1/`lw_nnl' {
									capture local lineval "`r(note_line`ln')'"
									if (_rc == 0 & "`lineval'" != "") return local note`idx'_line`ln' "`lineval'"
								}
							}
							if (`lw_snl' > 0) {
								forvalues ln = 1/`lw_snl' {
									capture local lineval "`r(source_line`ln')'"
									if (_rc == 0 & "`lineval'" != "") return local source`idx'_line`ln' "`lineval'"
								}
							}
							if (`lw_tnl' > 0) {
Bash Get _query subroutine that makes API calls
IN
curl -s "https://raw.githubusercontent.com/jpazvd/wbopendata/master/src/w/wbopendata.ado" | grep -A 100 "program def _query"

OUT
0
Bash Find API URL patterns in wbopendata
IN
curl -s "https://raw.githubusercontent.com/jpazvd/wbopendata/master/src/w/wbopendata.ado" | grep -n "api.worldbank\|copy\|insheet\|import\|http"

OUT
275:							* copy line-by-line returns when present (linewrapformat(all))
620:* _website.ado : screens a text file and converts and http or www "word" to a SMCL
Bash List files in src/_ directory
IN
curl -s "https://api.github.com/repos/jpazvd/wbopendata/contents/src/_" | grep -o '"name": "[^"]*"' | head -20

OUT
"name": "_api_read.ado"
"name": "_api_read_indicators.ado"
"name": "_countrymetadata.ado"
"name": "_linewrap.ado"
"name": "_metadata_linewrap.ado"
"name": "_parameters.ado"
"name": "_query.ado"
"name": "_query_indicators.ado"
"name": "_query_metadata.ado"
"name": "_tknz.ado"
"name": "_update_countrymetadata.ado"
"name": "_update_indicators.ado"
"name": "_update_regionmetadata.ado"
"name": "_update_wbopendata.ado"
"name": "_wbod_tmpfile1.ado"
"name": "_wbod_tmpfile2.ado"
"name": "_wbod_tmpfile3.ado"
"name": "_website.ado"
Bash Get API read implementation
IN
curl -s "https://raw.githubusercontent.com/jpazvd/wbopendata/master/src/_/_api_read.ado"

OUT
*******************************************************************************
* _api_read                                                                   
*! v 16.3  	8Jul2020               by Joao Pedro Azevedo
* 	change API end point to HTTPS
*******************************************************************************

program define _api_read, rclass

	*====================================================================================

	version 9
	
    syntax                                 	///
                 ,                         	///
							[				///
                        per_page(int 1)		///
						page(int 1) 		///
						qline(int 1) 		///
						skinumber(int 1) 	///
						trimnumber(int 1)	///
						single				///
						list				///
						parameter(string)	///
						query(string)		///
						nopreserve			///
						verbose 			///
							]

		if ("`verbose'" == "") {
			local noi ""
		}
		else {
			local noi "noi "
		}
							
							
		quietly {
	*======================== 		set up     	===========================================*/
			
		set checksum off
		
		if ("`nopreserve'" == "") {
			return add
		}
		
		tempfile in out source out3 source3 hlp1 hlp2 indicator help indicator1 
		tempname in2 in3 out2 in_tmp saving source1 source2 hlp hlp01 hlp02
			   
		if ("`single'"  == "") {
			local single "single"
		}
		
	*========================		api			 ===========================================*/
	
		if ("`query'" == "") {
			local query1 "https://api.worldbank.org/v2/indicators/?per_page=`per_page'&page=`page'"
		}
		else {
			local query1 "`query'?per_page=`per_page'&page=`page'"
		}
		
		cap: copy "`query1'" "`indicator1'", text replace		

	*========================begin conversion ===========================================*/
	
	   
		file open `in2'     using 	`indicator1'		, read

		if ("`preserveout'" == "") {
			file open `out2'    using 	`out'     		, write text replace
		}
		else {
			file open `out2'    using 	out.txt    		, write text replace
		}
		file open `source2' using 	`indicator'  		, write text replace
		file open `hlp01'	using 	`hlp1', write text replace
		
		
			file read `in2' line
			
			local l = 0
				 
				qui while !r(eof) {
					
				   local ++l
				   file read `in2' line
					
				   if ("`single'" != "") {
				   
						if(`l' == `qline') {
							local line`l' = subinstr(`"`line'"', `"""', "", .)
							return local line`l' "`line`l''"
						}
					
						if ("`parameter'" != "") {
						
							foreach name in `parameter' {
								
								local pchar = length(`"`line`l''"')
								
								local tmp = word(substr(`"`line`l''"',strpos(`"`line`l''"',`"`name'="'),`pchar'),1)

								local tmp = subinstr(`"`tmp'"',`"`name'="',"",.)
								
								return local `name'`l' `tmp'

							}
						}
					}
					
					
				   if ("`list'" != "") {
						
						if((`l'>`qline')) {
							local line`l' = subinstr(`"`line'"', `"""', "", .)
*							noi di ""
*							noi di `"`line'"'
*							noi di ""
*							noi di "`line`l''"
							return local line`l'  "`line`l''"
						}
				   		
						if ("`parameter'" != "") {

							/* BEGIN: Replace '?' by "_" in all parameter names */
							
							local new_parameter ""					/* clear list */
							local multiparametersinsingleline ""	/* clear list */

							foreach name in `parameter' {

								if (strmatch("`name'","*?*") == 1) {
									local parorg = subinstr("`name'","?"," ",.)
									local name = subinstr("`name'","?","_",.)
									local line`l' = subinstr(`"`line`l''"',"`parorg'","`name'",.)

								}
								
								local new_parameter "`new_parameter' `name' "
							
							}
							
							/* END: Replace '?' by "_" in all parameter names */
							
							
							/* BEGIN: Screen and Report how many (and which) parameters per line */

							local c = 0

							foreach name in `new_parameter' {
							
								if (strmatch(`"`line`l''"',"*`name'*") == 1) {
									local c = 1 + `c'
									local multiparametersinsingleline "`multiparametersinsingleline' `name'"
								}
								
							}

							if (`c'== 1) {
								`noi' di in g ""
								`noi' di in g  "Original Parameters: `parameter'"
								`noi' di in g  "New Parameters: `new_parameter'"
								`noi' di in g  ""
								`noi' di in y "--------------------------"
								`noi' di in y "SINGLE START VAR: "
								`noi' di in y "BEFORE LOOP"
								`noi' di in y "--------------------------"
								`noi' di in g "`c': single: `multiparametersinsingleline' "
								`noi' di "`line`l''"
							}
							if (`c' >= 2) {
								`noi' di in g ""
								`noi' di in g  "Original Parameters: `parameter'"
								`noi' di in g  "New Parameters: `new_parameter'"
								`noi' di in g  ""
								`noi' di in y "--------------------------"
								`noi' di in y "MULTI START VAR: "
								`noi' di in y "BEFORE LOOP"
								`noi' di in y "--------------------------"
								`noi' di in g "`c': multi: `multiparametersinsingleline' "
								`noi' di "`line`l''"
							}
							/* END: Screen and Report how many (and which) parameters per line */
							
							/* Extract only relevant parameters as determined by previous loop */
							
							local k = 0
							
							foreach name in `multiparametersinsingleline' {
								
								local k = 1 + `k'

								if (`k'==1) {
									local stub = word(subinstr("`name'","_"," ",.),1)
									`noi' di "stub: `stub'"
								}
								
								if (strmatch(`"`line`l''"',"*`name'*") == 1) {
						
									if (strmatch(`"`line`l''"',"*=*") == 1) {
									
										local line`l' = subinstr(`"`line`l''"',"</wb:`name'>","",.)
										
*										local line`l' = subinstr(`"`line`l''"',"<wb:`name'>","",.)

										local line`l' = subinstr(`"`line`l''"',"<wb:","",.)
									
										if (`k'<`c') {
										
											local nextparameter = word("`multiparametersinsingleline'",(`k'+1))
									
											local str =strpos(`"`line`l''"',`"`name'="')
											
											local end =strpos(`"`line`l''"',"`nextparameter'")
										
											`noi' di  ""
											`noi' di in g "start: 	`str'"
											`noi' di in g "end:	`end'"
											`noi' di  in g "`k'<`c' " in g ": `nextparameter' : stub: `stub'"
											`noi' di  in y "--------------------------"
											`noi' di  in y "INSIDE THE LOOP (K<C)"
											`noi' di  in y "--------------------------"
											`noi' di  in g ""
											`noi' di `"`line`l''"'
											`noi' di  in g ""

										
										}
										if (`k'==`c')  {
										
											local str =strpos(`"`line`l''"',`"`name'="')
											if (`str'==0) {
												local str =strpos(`"`line`l''"',`"`name'>"')
												local adj = length(`"`name'>"')
												local str = `str'+`adj'
											}
											local end =strpos(`"`line`l''"',`"</wb:`stub'>"')
											if (`end'==0) {	
												local end =length(`"`line`l''"')
											}

											`noi' di in g "start: 	`str'"
											`noi' di in g "end:	`end'"
											`noi' di in g "`k'=`c' " in g ": `nextparameter' : stub: `stub'"
											`noi' di  in y "--------------------------"
											`noi' di  in y "INSIDE THE LOOP (K=C)"
											`noi' di  in y "--------------------------"
											`noi' di  in g ""
											`noi' di `"`line`l''"'
											`noi' di  in g ""

										}
										
										
										if (`end' == 0) {
											local end = 50
										}
										
										local len = `end'-`str'
									
										`noi' di `"`line`l''"'

									
										local tmp = substr(`"`line`l''"',`str',(`end'-1))
										local tmp = subinstr(`"`tmp'"',`"`name'="',"",.)
										local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)
*										local tmp = subinstr(`"`line`l''"',"&amp;","and",.)
										local tmp = trim("`tmp'")

										`noi' di "`tmp'"

									}
									
									if (strmatch(`"`line`l''"',"*=*") != 1) {
									
										local tmp = subinstr(`"`line`l''"',"<wb:`name'>","",.)
										local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)
*										noi di `"local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)"'
*										local tmp = subinstr(`"`line`l''"',"&amp;","and",.)
										local tmp = trim("`tmp'")
									}
									
									local tmp = subinstr(`"`tmp'"',"/"," ",.)
									local tmp = subinstr(`"`tmp'"',">"," ",.)
									local tmp = subinstr(`"`tmp'"',"&amp;","and",.)
									local tmp = trim("`tmp'")
																		
									return local `name'`l' "`tmp'"

									`noi' di "`name'`l': `tmp'"
									
								}
								
								`noi' di in y "--------------------------"
								`noi' di in y " END VAR: `name'			 "
								`noi' di in y "--------------------------"
								`noi' di in g ""

								
							}
							
							local stub ""
						}
					}
					
				}
				

		file close `in2'
		
		return local date = c(current_date)
		return local time = c(current_time)

	}
	
	end

	
*******************************************************************************
* v 15.2  	8Mar2019               by Joao Pedro Azevedo
*	flexible API address
* 	fix API query when option query was not selected
/*******************************************************************************


cd "C:\GitHub_myados\wbopendata\src"

! git checkout dev

discard

/* Coutries */

_api_read , query("http://api.worldbank.org/v2/countries/") ///
		nopreserve single parameter(page pages total)
return list

_api_read , query("http://api.worldbank.org/v2/countries/") ///
		per_page(5) page(1) list nopreserve ///
		parameter( country?id iso2Code name region?id adminregion?id incomeLevel?id lendingType?id iso2code capitalCity latitude longitude )
return list


			
/* Indicators */

_api_read, single parameter(pages per_page total)
return list

_api_read, per_page(50) single parameter(pages per_page total)
return list

_api_read, per_page(200) single parameter(pages per_page total)
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.NFSV.CD")
return list

cls
clear
_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.OSRV.CD") ///
		nopreserve
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.TOTL.CD") ///
		nopreserve parameter( indicator?id name topic?id ) 
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.TOTL.CD") ///
		nopreserve parameter( indicator?id name topic?id ) verbose
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/6.1_LEG.CA") ///
		parameter( indicator?id name topic?id ) verbose
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/6.1_LEG.CA") ///
		parameter( indicator?id name topic?id ) 
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/IN.HLTH.HIVDEATH.EST") ///
		parameter( indicator?id name topic?id source?id sourceNote sourceOrganization ) ///
		verbose 
return list

set trace on
_api_read , page(1728) per_page(1) list parameter( indicator?id name topic?id ///
		source?id sourceNote sourceOrganization) verbose
return list

local sourceNote "Control of Corruption captures perceptions of the extent to which public power is exercised for private gain, including both petty and grand forms of corruption, as well as capture of the state by elites and private interests. Estimate gives the country's score on the aggregate indicator, in units of a standard normal distribution, i.e. ranging from approximately -2.5 to 2.5."
di "`sourceNote'"
local pchar = length("`sourceNote'")
di `pchar'


*******************************************************************************/
Bash Get query implementation
IN
curl -s "https://raw.githubusercontent.com/jpazvd/wbopendata/master/src/_/_query.ado" | head -200

OUT
*******************************************************************************
* _query   
*! v 16.3  	8Jul2020               by Joao Pedro Azevedo
* 	change API end point to HTTPS
*******************************************************************************

program def _query, rclass

version 9.0

    syntax                                          ///
                 [,                                 ///
                         LANGUAGE(string)           ///
                         COUNTRY(string)            ///
                         TOPICS(string)             ///
                         INDICATOR(string)          ///
                         YEAR(string)               ///
						 DATE(string)				///
                         LONG                       ///
                         CLEAR                      ///
                         LATEST                     ///
                         NOMETADATA                 ///
						 PROJECTION					///	
						 SOURCE(string)				///
                 ]


quietly {

    if ("`language'" == "") {
        local language "en"
    }

    if ("`language'" != "") {
        local language = word("`language'",1)
    }

    if ("`country'" != "") {

        local country1 = word("`country'",1)
        local t = substr("`country1'",-1,1    )
        if ("`t'" == ";") {
            local l = length("`country1'")
            local l = `l'-1
            local country1 = substr("`country'",1,`l')
        }
        local q = subinstr("`country1'",";"," ",.)
        local q = wordcount("`q'")
        if (`q'>1) & ("`indicator'" == "") {
            noi di as err "Users can not select multiple countries without specifying the indicator of interest. Please try again."
            exit 198
        }
        local parameter "Countries/`country1'"
        local id "indicatorname indicatorcode "
    }

    if ("`topics'" != "") {
        local topics1 = word("`topics'",1)
        local parameter "Topics/`topics1'"
        local id " countryname countrycode indicatorname indicatorcode "
    }

    if ("`indicator'" != "") {
        local indicator1 = word("`indicator'",1)
        local indicator2 = subinstr("`indicator'","`indicator1'","",.)
        local indicator2 = trim(subinstr("`indicator2'","-","",.))
        if ("`indicator2'" == "") {
            local indicator2 "`indicator1'"
        }
        if ("`projection'" != "") {
			local source "source=40&"
		}
		if ("`date'" != "") {
			local date1 "&date=`date'"
		}
		else {
			local date1 ""
		}
		if ("`year'" != "") {
			local year1	"&date=`year'"
		}
		else {
			local year1 	""
		}
		
        local parameter "Indicators/`indicator1'?`source'downloadformat=CSV&HREQ=N&filetype=data`year1'`date1'"
        local id " countryname countrycode "
    }


    if  ("`country'" == "") & ("`topics'" == "") & ("`indicator'" == "") {
        di  as err "Users need to select either a country, a topic, or an indicator. Please try again."
        exit 198
    }
    if  ("`country'" != "") & ("`topics'" != "") & ("`indicator'" == "") {
        di  as err "Users can not select a country and a topic at the same time. Please try again."
        exit 198
    }
    if  ("`country'" == "") & ("`topics'" != "") & ("`indicator'" != "") {
        di  as err "Users can not select an indicator and a topic at the same time. Please try again."
        exit 198
    }
    if  ("`indicator'" == "") & ("`year'" != "") {
        di  as err "year option can only be used for the selection of specific indicators. Please try again."
        exit 198
    }
    if  ("`indicator'" == "") & ("`latest'" != "") {
        di  as err "latest option can only be used for the selection of specific indicators in the long format. Please try again."
        exit 198
    }
    if  ("`indicator'" != "") & ("`latest'" != "") & ("`long'" == "") {
        di  as err "latest option can only be used for the selection of specific indicators in the long format. Please try again."
        exit 198
    }
	if ("`year'" != "") & ("`date'" != "") {
		di  as err "only YEAR or DATE can be specified at once. Please try again."
		exit 198
	}
    if ("`country'" == "") & ("`indicator'" != "") {
        local country2 "all"
    }
    if ("`country'" != "") & ("`indicator'" != "") {
        local country2 "`country1'"
    }

    tempfile temp


	loc servername "https://api.worldbank.org/v2"  /* Query server v2 */


/* country selection */
    if  (("`country'" != "") | ("`topics'" != "")) &  ("`indicator'" == "") {
        local queryspec "`servername'/`language'/`parameter'/?downloadformat=CSV&HREQ=N&filetype=data"
        local queryspec2 "topic `topics1'"
        capture : copy "`queryspec'" `temp' , public
        local rc1 = _rc
        if (`rc1' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "https://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "https://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please consider setting Stata checksum off. {help set checksum}{p_end}"'
            noi dis as text `"{p 4 4 2} (5) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc1'
            break
        }
    }
/* Indicator selection */	
    if  ("`indicator'" != "") {
        local queryspec "`servername'/`language'/countries/`country2'/`parameter'"
        local queryspec2 "indicator `indicator1'"
        capture : copy "`queryspec'" `temp' , public
        local rc2 = _rc
        if (`rc2' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "https://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "https://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please consider setting Stata checksum off. {help set checksum}{p_end}"'
            noi dis as text `"{p 4 4 2} (5) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc2'
            break
        }
    }

    cap : insheet using `temp', `clear' name
    local rc3 = _rc
    if (`rc3' != 0) {
        noi di ""
        di  as err "you must start with an empty dataset; or enable the clear option."
        noi di ""
        exit `rc3'
        noi di ""
        break
    }


***************************************************

    qui foreach var of varlist _all {

        local varname : variable label `var'
        if (real("`varname'") != .) {
            rename `var' yr`varname'
            local l1    "yr"
            local l2    "year"
            local l3    ""
            local l4    "lab var year Year"
            local t1  "year"
        }
        else {
            if match("`varname'","*Q*") == 1 {
                local tmp0 = subinstr("`varname'","Q","-",.)
Now I have comprehensive information about both APIs. Let me compile the analysis.

Data360 API vs. wbopendata Analysis
Data360 API Overview (New)
Base URL: https://data360api.worldbank.org

Endpoint	Method	Purpose
/data360/data	GET	Retrieve indicator data with filters
/data360/searchv2	POST	Vector/keyword search across Data360
/data360/metadata	POST	Query metadata with OData-style filters
/data360/indicators	GET	List available indicators in a dataset
/data360/disaggregation	GET	Get disaggregation options for an indicator
Key Parameters for /data360/data:

DATABASE_ID (required) - e.g., "WB_WDI"
INDICATOR, REF_AREA, SEX, AGE, URBANISATION
TIME_PERIOD, timePeriodFrom, timePeriodTo
skip for pagination (max 1000 records per call)
Current wbopendata Architecture
Base URL: https://api.worldbank.org/v2

The wbopendata module is structured with modular .ado files:

File	Purpose
wbopendata.ado	Main entry point, command parsing
_query.ado	Core API query logic
_api_read.ado	Low-level API read/parse
_query_metadata.ado	Metadata retrieval
_countrymetadata.ado	Country-level metadata
Extension Strategy for Data360 Support
Option 1: New Subcommand (Recommended)
Add a data360 subcommand or source(data360) option:


wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) country(USA;BRA) clear
Implementation approach:

Create _query_data360.ado - New query handler for Data360 API
Create _api_read_data360.ado - JSON parsing (Data360 returns JSON, not CSV/XML)
Modify wbopendata.ado - Add routing logic for data360 option
Option 2: Unified Interface
Detect database availability and route automatically:


wbopendata, indicator(SP.POP.TOTL) source(data360) ...
Key Implementation Differences
Aspect	wbopendata (v2 API)	Data360 API
Response format	CSV/XML	JSON
Pagination	page/per_page	skip (max 1000)
Search	None	Vector + keyword search
Disaggregation	Limited	Rich (SEX, AGE, URBANISATION, etc.)
Metadata	Separate calls	OData-style $filter/$select
Proposed New Files

src/
├── _/
│   ├── _query_data360.ado        # Data360 query handler
│   ├── _api_read_data360.ado     # JSON parsing for Data360
│   ├── _search_data360.ado       # Vector/keyword search
│   └── _metadata_data360.ado     # OData metadata queries
├── w/
│   └── wbopendata.ado            # Modify to add routing
Sample Implementation Skeleton

*! _query_data360.ado
program def _query_data360, rclass
    syntax, DATABASE(string) [INDICATOR(string) COUNTRY(string) ...]
    
    local baseurl "https://data360api.worldbank.org/data360/data"
    local query "`baseurl'?DATABASE_ID=`database'"
    
    if ("`indicator'" != "") {
        local query "`query'&INDICATOR=`indicator'"
    }
    if ("`country'" != "") {
        local query "`query'&REF_AREA=`country'"
    }
    
    * JSON parsing required - use jsonio or custom parser
    tempfile jsonfile
    copy "`query'" `jsonfile'
    
    * Parse JSON response...
end
Challenges to Address
JSON Parsing - wbopendata uses CSV/XML; Data360 returns JSON. Consider:

Stata 16+ jsonio command
Custom JSON parser (like existing XML parser in _api_read.ado)
Pagination - Data360 uses skip with 1000-record limit vs. page-based

Disaggregation dimensions - Data360 has richer breakdowns (SEX, AGE, etc.) that need new options

Search functionality - Data360's vector search is a new capability not in v2 API

Sources
World Bank Data360 API
GitHub: worldbank/open-api-specs
GitHub: jpazvd/wbopendata
wbopendata documentation
World Bank API Help Desk
data360r R package
can you prepare an improvement plan
EnterPlanMode
OUT
Entered plan mode. You should now focus on exploring the codebase and designing an implementation approach.

In plan mode, you should:
1. Thoroughly explore the codebase to understand existing patterns
2. Identify similar features and architectural approaches
3. Consider multiple approaches and their trade-offs
4. Use AskUserQuestion if you need to clarify the approach
5. Design a concrete implementation strategy
6. When ready, use ExitPlanMode to present your plan for approval

Remember: DO NOT write or edit any files yet. This is a read-only exploration and planning phase.
I've already gathered extensive information about both APIs. Let me create a comprehensive improvement plan based on my research.

Write C:\Users\jpazevedo\.claude\plans\whimsical-popping-sutton.md
313 lines
# wbopendata Extension Plan: Data360 API Support

## Overview

Extend the `wbopendata` Stata module to support the World Bank's new Data360 API alongside the existing v2 API. This enables access to 300+ million data points with enhanced disaggregation, vector search, and modern JSON responses.

---

## Current State

### Existing wbopendata Architecture
- **Base URL:** `https://api.worldbank.org/v2`
- **Response formats:** CSV, XML
- **Core files:**
  - `src/w/wbopendata.ado` - Main entry point
  - `src/_/_query.ado` - Query construction and execution
  - `src/_/_api_read.ado` - Low-level API read/XML parsing
  - `src/_/_query_metadata.ado` - Metadata retrieval

### Data360 API Capabilities
- **Base URL:** `https://data360api.worldbank.org`
- **Response format:** JSON only
- **Endpoints:**
  - `GET /data360/data` - Retrieve indicator data
  - `POST /data360/searchv2` - Vector/keyword search
  - `POST /data360/metadata` - OData-style metadata queries
  - `GET /data360/indicators` - List indicators by database
  - `GET /data360/disaggregation` - Get disaggregation options

---

## Implementation Plan

### Phase 1: Core Infrastructure

#### 1.1 JSON Parsing Utility
**File:** `src/_/_json_parse.ado`

Create a lightweight JSON parser for Data360 responses:
- Parse JSON arrays and objects
- Extract `count` and `value` fields from responses
- Handle nested structures for metadata
- Convert JSON to Stata dataset format

```stata
program def _json_parse, rclass
    syntax using/, [FIELD(string)]
    * Parse JSON file and return as Stata variables
end
```

#### 1.2 Data360 API Read Handler
**File:** `src/_/_api_read_data360.ado`

Low-level API handler for Data360:
- Construct URLs with query parameters
- Handle pagination via `skip` parameter (1000 record limit)
- Retry logic for API failures
- Convert JSON response to Stata dataset

---

### Phase 2: Query Modules

#### 2.1 Data Query Handler
**File:** `src/_/_query_data360.ado`

Main data retrieval for Data360:
```stata
program def _query_data360, rclass
    syntax, DATABASE(string) ///
           [INDICATOR(string) COUNTRY(string) ///
            SEX(string) AGE(string) URBANISATION(string) ///
            TIMEFROM(string) TIMETO(string) ///
            SKIP(integer 0)]
```

**Parameters mapping:**
| wbopendata option | Data360 parameter |
|-------------------|-------------------|
| `database()` | `DATABASE_ID` |
| `indicator()` | `INDICATOR` |
| `country()` | `REF_AREA` |
| `sex()` | `SEX` |
| `age()` | `AGE` |
| `urban()` | `URBANISATION` |
| `year()` | `TIME_PERIOD` or `timePeriodFrom/To` |

#### 2.2 Search Handler
**File:** `src/_/_search_data360.ado`

Vector and keyword search capability (new feature):
```stata
program def _search_data360, rclass
    syntax, SEARCH(string) ///
           [TOP(integer 10) SKIP(integer 0) ///
            FILTER(string) ORDERBY(string)]
```

#### 2.3 Metadata Handler
**File:** `src/_/_metadata_data360.ado`

OData-style metadata queries:
```stata
program def _metadata_data360, rclass
    syntax, [FILTER(string) SELECT(string)]
```

#### 2.4 Indicators List Handler
**File:** `src/_/_indicators_data360.ado`

List available indicators for a database:
```stata
program def _indicators_data360, rclass
    syntax, DATABASE(string)
```

---

### Phase 3: Main Module Integration

#### 3.1 Modify wbopendata.ado
**File:** `src/w/wbopendata.ado`

Add new options to syntax:
```stata
syntax [, ///
    ... existing options ... ///
    DATA360                    /// Enable Data360 API
    DATABASE(string)           /// Database ID (e.g., WB_WDI)
    SEX(string)               /// Sex disaggregation
    AGE(string)               /// Age disaggregation
    URBAN(string)             /// Urbanisation filter
    SEARCH(string)            /// Search query (Data360 only)
]
```

Add routing logic:
```stata
if ("`data360'" != "") {
    * Route to Data360 handlers
    if ("`search'" != "") {
        noi _search_data360, search("`search'") ...
    }
    else {
        noi _query_data360, database("`database'") ...
    }
}
else {
    * Existing v2 API logic
    noi _query, ...
}
```

---

### Phase 4: Database Catalog

#### 4.1 Database List Help File
**File:** `src/w/wbopendata_data360_databases.sthlp`

Document available Data360 databases:
- WB_WDI (World Development Indicators)
- WB_GEP (Global Economic Prospects)
- WB_DOING_BUSINESS
- etc.

#### 4.2 Update Main Help File
**File:** `src/w/wbopendata.sthlp`

Add Data360 section with:
- New options documentation
- Usage examples
- Database reference

---

### Phase 5: Update Mechanism

#### 5.1 Data360 Update Handler
**File:** `src/_/_update_data360.ado`

Refresh Data360 metadata:
- Fetch available databases
- Update indicator lists per database
- Generate help files

---

## New Command Syntax

### Basic Data360 Query
```stata
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) country(USA;BRA) clear
```

### With Disaggregation
```stata
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) ///
    country(USA) sex(M;F) age(Y15-24) year(2010:2020) long clear
```

### Search Functionality
```stata
wbopendata, data360 search("GDP per capita purchasing power") top(20) clear
```

### List Indicators
```stata
wbopendata, data360 database(WB_WDI) indicators clear
```

---

## File Summary

### New Files (8)
| File | Purpose |
|------|---------|
| `src/_/_json_parse.ado` | JSON parsing utility |
| `src/_/_api_read_data360.ado` | Low-level Data360 API handler |
| `src/_/_query_data360.ado` | Data retrieval |
| `src/_/_search_data360.ado` | Vector/keyword search |
| `src/_/_metadata_data360.ado` | Metadata queries |
| `src/_/_indicators_data360.ado` | List indicators |
| `src/_/_update_data360.ado` | Update mechanism |
| `src/w/wbopendata_data360_databases.sthlp` | Database catalog |

### Modified Files (2)
| File | Changes |
|------|---------|
| `src/w/wbopendata.ado` | Add data360 option, routing logic |
| `src/w/wbopendata.sthlp` | Document new options |

---

## Technical Considerations

### JSON Parsing Strategy
Stata 16+ has `jsonio` but for backward compatibility:
1. Use `fileread` to load JSON as string
2. Parse using string functions (`strpos`, `substr`)
3. Handle arrays by detecting `[` and `]`
4. Extract key-value pairs iteratively

### Pagination Handling
Data360 returns max 1000 records per call:
```stata
local total = `count'
local pages = ceil(`total'/1000)
forvalues p = 0/`=`pages'-1' {
    local skip = `p' * 1000
    * Fetch page with skip(`skip')
    * Append to dataset
}
```

### Backward Compatibility
- All existing options remain functional
- Default behavior unchanged (v2 API)
- Data360 only activated with `data360` option

---

## Verification Plan

### Unit Tests
1. Test JSON parser with sample responses
2. Test each query handler independently
3. Verify pagination with large datasets

### Integration Tests
```stata
* Test 1: Basic query
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) country(USA) clear
assert _N > 0

* Test 2: Disaggregation
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) sex(M;F) clear
assert _N > 0

* Test 3: Search
wbopendata, data360 search("population total") top(5) clear
assert _N == 5

* Test 4: Backward compatibility (v2 API)
wbopendata, indicator(SP.POP.TOTL) country(USA) clear
assert _N > 0
```

### Manual Testing
1. Compare v2 and Data360 results for same indicator
2. Test error handling (invalid database, no results)
3. Test large dataset pagination

---

## Implementation Order

1. **Week 1:** JSON parser + basic API read
2. **Week 2:** Query handler + main module integration
3. **Week 3:** Search + metadata handlers
4. **Week 4:** Documentation + testing
5. **Week 5:** Update mechanism + release

---

## Open Questions

1. **Minimum Stata version?** - JSON parsing approach depends on this
2. **Database priority?** - Which databases to document first
3. **Search default behavior?** - Return indicators, datasets, or both?
I've created a comprehensive improvement plan. Let me clarify a few key decisions before finalizing.

AskUserQuestion
OUT
User has answered your questions: "What is the minimum Stata version you want to support for Data360 features?"="Stata 16+ (Recommended)", "How should the Data360 API be activated in the command syntax?"="data360 option (Recommended)", "Should I include the vector search capability as a new feature?"="Yes, include search". You can now continue with the user's answers in mind.
Let me update the plan with your decisions.

Edit C:\Users\jpazevedo\.claude\plans\whimsical-popping-sutton.md
Added 10 lines
The plan is now complete with your decisions incorporated. Let me present it for your approval.

Claude’s Plan
wbopendata Extension Plan: Data360 API Support
Overview
Extend the wbopendata Stata module to support the World Bank's new Data360 API alongside the existing v2 API. This enables access to 300+ million data points with enhanced disaggregation, vector search, and modern JSON responses.

Current State
Existing wbopendata Architecture
Base URL: https://api.worldbank.org/v2
Response formats: CSV, XML
Core files:
src/w/wbopendata.ado - Main entry point
src/_/_query.ado - Query construction and execution
src/_/_api_read.ado - Low-level API read/XML parsing
src/_/_query_metadata.ado - Metadata retrieval
Data360 API Capabilities
Base URL: https://data360api.worldbank.org
Response format: JSON only
Endpoints:
GET /data360/data - Retrieve indicator data
POST /data360/searchv2 - Vector/keyword search
POST /data360/metadata - OData-style metadata queries
GET /data360/indicators - List indicators by database
GET /data360/disaggregation - Get disaggregation options
Implementation Plan
Phase 1: Core Infrastructure
1.1 JSON Parsing Utility
File: src/_/_json_parse.ado

Create a lightweight JSON parser for Data360 responses:

Parse JSON arrays and objects
Extract count and value fields from responses
Handle nested structures for metadata
Convert JSON to Stata dataset format

program def _json_parse, rclass
    syntax using/, [FIELD(string)]
    * Parse JSON file and return as Stata variables
end
1.2 Data360 API Read Handler
File: src/_/_api_read_data360.ado

Low-level API handler for Data360:

Construct URLs with query parameters
Handle pagination via skip parameter (1000 record limit)
Retry logic for API failures
Convert JSON response to Stata dataset
Phase 2: Query Modules
2.1 Data Query Handler
File: src/_/_query_data360.ado

Main data retrieval for Data360:


program def _query_data360, rclass
    syntax, DATABASE(string) ///
           [INDICATOR(string) COUNTRY(string) ///
            SEX(string) AGE(string) URBANISATION(string) ///
            TIMEFROM(string) TIMETO(string) ///
            SKIP(integer 0)]
Parameters mapping:

wbopendata option	Data360 parameter
database()	DATABASE_ID
indicator()	INDICATOR
country()	REF_AREA
sex()	SEX
age()	AGE
urban()	URBANISATION
year()	TIME_PERIOD or timePeriodFrom/To
2.2 Search Handler
File: src/_/_search_data360.ado

Vector and keyword search capability (new feature):


program def _search_data360, rclass
    syntax, SEARCH(string) ///
           [TOP(integer 10) SKIP(integer 0) ///
            FILTER(string) ORDERBY(string)]
2.3 Metadata Handler
File: src/_/_metadata_data360.ado

OData-style metadata queries:


program def _metadata_data360, rclass
    syntax, [FILTER(string) SELECT(string)]
2.4 Indicators List Handler
File: src/_/_indicators_data360.ado

List available indicators for a database:


program def _indicators_data360, rclass
    syntax, DATABASE(string)
Phase 3: Main Module Integration
3.1 Modify wbopendata.ado
File: src/w/wbopendata.ado

Add new options to syntax:


syntax [, ///
    ... existing options ... ///
    DATA360                    /// Enable Data360 API
    DATABASE(string)           /// Database ID (e.g., WB_WDI)
    SEX(string)               /// Sex disaggregation
    AGE(string)               /// Age disaggregation
    URBAN(string)             /// Urbanisation filter
    SEARCH(string)            /// Search query (Data360 only)
]
Add routing logic:


if ("`data360'" != "") {
    * Route to Data360 handlers
    if ("`search'" != "") {
        noi _search_data360, search("`search'") ...
    }
    else {
        noi _query_data360, database("`database'") ...
    }
}
else {
    * Existing v2 API logic
    noi _query, ...
}
Phase 4: Database Catalog
4.1 Database List Help File
File: src/w/wbopendata_data360_databases.sthlp

Document available Data360 databases:

WB_WDI (World Development Indicators)
WB_GEP (Global Economic Prospects)
WB_DOING_BUSINESS
etc.
4.2 Update Main Help File
File: src/w/wbopendata.sthlp

Add Data360 section with:

New options documentation
Usage examples
Database reference
Phase 5: Update Mechanism
5.1 Data360 Update Handler
File: src/_/_update_data360.ado

Refresh Data360 metadata:

Fetch available databases
Update indicator lists per database
Generate help files
New Command Syntax
Basic Data360 Query

wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) country(USA;BRA) clear
With Disaggregation

wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) ///
    country(USA) sex(M;F) age(Y15-24) year(2010:2020) long clear
Search Functionality

wbopendata, data360 search("GDP per capita purchasing power") top(20) clear
List Indicators

wbopendata, data360 database(WB_WDI) indicators clear
File Summary
New Files (8)
File	Purpose
src/_/_json_parse.ado	JSON parsing utility
src/_/_api_read_data360.ado	Low-level Data360 API handler
src/_/_query_data360.ado	Data retrieval
src/_/_search_data360.ado	Vector/keyword search
src/_/_metadata_data360.ado	Metadata queries
src/_/_indicators_data360.ado	List indicators
src/_/_update_data360.ado	Update mechanism
src/w/wbopendata_data360_databases.sthlp	Database catalog
Modified Files (2)
File	Changes
src/w/wbopendata.ado	Add data360 option, routing logic
src/w/wbopendata.sthlp	Document new options
Design Decisions
Decision	Choice	Rationale
Minimum Stata version	16+	Use native jsonio for JSON parsing
API activation	data360 option	Explicit opt-in, clear user intent
Search feature	Include	Valuable new capability for discovery
Technical Considerations
JSON Parsing Strategy
Use Stata 16+ native jsonio command:


jsonio kv, file("`jsonfile'") elem("value")
This simplifies implementation significantly and provides robust JSON handling.

Pagination Handling
Data360 returns max 1000 records per call:


local total = `count'
local pages = ceil(`total'/1000)
forvalues p = 0/`=`pages'-1' {
    local skip = `p' * 1000
    * Fetch page with skip(`skip')
    * Append to dataset
}
Backward Compatibility
All existing options remain functional
Default behavior unchanged (v2 API)
Data360 only activated with data360 option
Verification Plan
Unit Tests
Test JSON parser with sample responses
Test each query handler independently
Verify pagination with large datasets
Integration Tests

* Test 1: Basic query
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) country(USA) clear
assert _N > 0

* Test 2: Disaggregation
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) sex(M;F) clear
assert _N > 0

* Test 3: Search
wbopendata, data360 search("population total") top(5) clear
assert _N == 5

* Test 4: Backward compatibility (v2 API)
wbopendata, indicator(SP.POP.TOTL) country(USA) clear
assert _N > 0
Manual Testing
Compare v2 and Data360 results for same indicator
Test error handling (invalid database, no results)
Test large dataset pagination
Implementation Order
Week 1: JSON parser + basic API read
Week 2: Query handler + main module integration
Week 3: Search + metadata handlers
Week 4: Documentation + testing
Week 5: Update mechanism + release
Open Questions
Minimum Stata version? - JSON parsing approach depends on this
Database priority? - Which databases to document first
Search default behavior? - Return indicators, datasets, or both?
User approved the plan
The improvement plan has been created and approved. Here's a summary:

wbopendata Data360 Extension Plan
Key Decisions Made
Decision	Choice
Stata version	16+ (use native jsonio)
API activation	data360 option
Search feature	Included
New Files to Create (8)
_json_parse.ado - JSON parsing utility
_api_read_data360.ado - Low-level API handler
_query_data360.ado - Data retrieval
_search_data360.ado - Vector/keyword search
_metadata_data360.ado - Metadata queries
_indicators_data360.ado - List indicators
_update_data360.ado - Update mechanism
wbopendata_data360_databases.sthlp - Database catalog
Files to Modify (2)
wbopendata.ado - Add routing logic
wbopendata.sthlp - Document new options
New Command Examples

* Basic query
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) country(USA) clear

* With disaggregation
wbopendata, data360 database(WB_WDI) indicator(SP.POP.TOTL) sex(M;F) clear

* Search
wbopendata, data360 search("GDP per capita") top(20) clear
The full plan is saved at whimsical-popping-sutton.md.

Would you like me to start implementing any of the phases?

how similar is the data360 api in respect to the api v2 wbopendata is currentl using; compare the two and present what is similar and what is different?
Based on my research, here's a detailed comparison of the two APIs:

World Bank API Comparison: v2 vs Data360
Base Architecture
Aspect	API v2 (Current)	Data360 (New)
Base URL	https://api.worldbank.org/v2	https://data360api.worldbank.org
Response formats	XML, CSV, JSON, JSONP	JSON only
Authentication	None (public)	None (public)
License	CC BY 4.0	CC BY 4.0
Data Retrieval Endpoints
Function	API v2	Data360
Get indicator data	GET /countries/{country}/indicators/{indicator}	GET /data360/data?DATABASE_ID=...&INDICATOR=...
List indicators	GET /indicators	GET /data360/indicators?datasetId=...
Get metadata	GET /indicators/{indicator}	POST /data360/metadata
Search	None	POST /data360/searchv2 (vector + keyword)
Disaggregation info	None	GET /data360/disaggregation
Query Parameters - SIMILAR
Parameter	API v2	Data360	Notes
Country filter	country in URL path	REF_AREA	Same concept, different syntax
Indicator	indicator in URL path	INDICATOR	Same concept
Time period	date=2000:2010	timePeriodFrom, timePeriodTo	Similar range syntax
Language	/v2/{lang}/...	Not documented	v2 supports en/es/fr
Query Parameters - DIFFERENT
Feature	API v2	Data360
Disaggregation	Limited	Rich: SEX, AGE, URBANISATION, COMP_BREAKDOWN_1/2/3
Database selection	source=2 (numeric ID)	DATABASE_ID=WB_WDI (string code)
Pagination	page=1&per_page=50	skip=0 (max 1000 per call)
Most recent value	mrv=5, mrnev=5	Not available
Gap filling	gapfill=Y	Not available
Frequency	frequency=Q/M/Y	FREQ parameter
Response Structure
API v2 (XML/JSON):


<wb:data>
  <wb:data page="1" pages="1" per_page="50" total="1">
    <wb:country id="USA">United States</wb:country>
    <wb:indicator id="SP.POP.TOTL">Population, total</wb:indicator>
    <wb:date>2020</wb:date>
    <wb:value>331002651</wb:value>
  </wb:data>
</wb:data>
Data360 (JSON):


{
  "count": 1,
  "value": [{
    "DATABASE_ID": "WB_WDI",
    "INDICATOR": "SP.POP.TOTL",
    "REF_AREA": "USA",
    "TIME_PERIOD": "2020",
    "OBS_VALUE": "331002651",
    "SEX": "_T",
    "AGE": "_T",
    "URBANISATION": "_T",
    "OBS_STATUS": "A",
    "DATA_SOURCE": "...",
    "LATEST_DATA": true
  }]
}
Key Similarities
Same indicator codes - SP.POP.TOTL works in both
Same country codes - ISO 3166 alpha-3 (USA, BRA, CHN)
Same time period format - Years as strings
Same data values - Underlying data is identical
No authentication - Both are fully public
RESTful design - Both use HTTP GET for queries
Key Differences
Category	API v2	Data360
Response format	XML default, JSON optional	JSON only
Disaggregation	None	Full (sex, age, urban, custom)
Search	None	Vector + keyword search
Pagination	Page-based (any size)	Skip-based (max 1000)
Database scope	Single source per call	Explicit database selection
Metadata query	Simple GET	OData-style $filter/$select
Data structure	Nested XML/simple JSON	Flat SDMX-like structure
Implementation Impact for wbopendata
Component	Reusable from v2	Needs New Code
Country code handling	Yes	-
Indicator code handling	Yes	-
Year/date parsing	Yes	-
URL construction	-	Yes (different pattern)
Response parsing	-	Yes (JSON vs XML/CSV)
Pagination logic	-	Yes (skip vs page)
Disaggregation options	-	Yes (new feature)
Search functionality	-	Yes (new feature)
Error handling	Partial	Adapt messages
Mapping Table for Migration

API v2 Parameter          →  Data360 Parameter
─────────────────────────────────────────────
country(usa)              →  REF_AREA=USA
indicator(SP.POP.TOTL)    →  INDICATOR=SP.POP.TOTL
source(2)                 →  DATABASE_ID=WB_WDI
date=2000:2010            →  timePeriodFrom=2000&timePeriodTo=2010
per_page=1000             →  (implicit, max 1000)
page=2                    →  skip=1000
format=json               →  (always JSON)
Conclusion
~40% similar - Core concepts (indicators, countries, time) are identical, making conceptual mapping straightforward.

~60% different - Response format, pagination, disaggregation, and search require new implementation. The JSON-only response and SDMX-style flat structure mean the parsing logic needs to be completely rewritten.

The good news: existing wbopendata users won't need to learn new indicator or country codes. The data360 option simply unlocks additional disaggregation and search capabilities.

is data360 more aligned with the unicefData api structure?
Let me research the UNICEF Data API structure to compare.

Web SearchUNICEF Data API documentation SDMX REST endpoints structure 2025
OUT
Web search results for query: "UNICEF Data API documentation SDMX REST endpoints structure 2025"

Links: [{"title":"SDMX API Queries - Structure and Data Access - UNICEF Data","url":"https://data.unicef.org/sdmx-api-documentation/"},{"title":"SDMX REST Web Service. How to use API calls to query UNICEF’s… | by Felix Schwebel | Medium","url":"https://medium.com/@schwebel.felix/sdmx-rest-web-service-eafe4107117c"},{"title":"UNICEF Indicator Data Warehouse","url":"https://sdmx.data.unicef.org/"},{"title":"Data sources - sdmx1","url":"https://sdmx1.readthedocs.io/en/latest/sources.html"},{"title":"IMF SDMX CENTRAL Web Services (API) Guide Last updated: May 2025 Abstract","url":"https://dsbb.imf.org/content/pdfs/IMFSDMXCentralWebServicesGuide.pdf"},{"title":"Typical use cases - .Stat Suite documentation","url":"https://sis-cc.gitlab.io/dotstatsuite-documentation/using-api/typical-use-cases/"},{"title":"sdmx/doc/sources.rst at main · khaeru/sdmx","url":"https://github.com/khaeru/sdmx/blob/main/doc/sources.rst?plain=true"},{"title":"Open Data - UNICEF DATA","url":"https://data.unicef.org/open-data/"},{"title":"https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/schema ...","url":"https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/schema/dataflow/UNICEF/MG/1.0?format=sdmx-2.1"},{"title":"UNdata | api manual","url":"http://data.un.org/Host.aspx?Content=API"}]

Based on the search results, here's what I found about UNICEF Data API documentation for SDMX REST endpoints:

## UNICEF SDMX API Documentation

### Base Endpoint
The entry URL for UNICEF's SDMX REST Web Service is: `endpoint = "https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/"`(no content)Any SDMX-aware client or library can access the REST JSON data services at: https://sdmx.data.unicef.org/webservice/data.html.(no content)The convenient query constructor makes it easy to craft any custom query.

### API Structure

#### Retrieving Dataflows
To obtain the JSON version of available dataflows, use the call: `https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/dataflow/all/all/latest/?format=sdmx-json&detail=full&references=none`. The generic API call to download a specific structure is: `https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/dataflow/all/{DataflowId}/latest/?format=sdmx-json&detail=full&references=all`

#### Data Query Structure
The complete data endpoint format is: `/data/{SELECTED_AGENCY_ID},{SELECTED_DFLOW_ID},{SELECTED_DFLOW_VER}/all`(no content)In the query syntax, the "dot" separates the dimensions, the "+" separates the values for the dimension.

#### Response Format
The data response contains the keys 'dataSets' for the encoded values and 'structure' for the corresponding structure.(no content)Data can be downloaded in CSV format using the format=csv parameter. As of this registry version, the csv download is limited to labels only (not codes), and can be used for data visualization tasks but not for data exchange purposes.

### Key Concepts

Data Flows can be understood as an ongoing publication of a data set which is still "in flow". They contain the data sets within a common structure defined in a Data Structure Definition (DSD). A Data Flow can only be linked to one DSD, but a DSD can be the basis for multiple Data Flows, ensuring those structures' reusability.(no content)This source always returns structure-specific messages for SDMX-ML data queries. UNICEF also serves data for the Countdown to 2030 initiative under a data flow with the ID CONSOLIDATED.

### Support Documentation
The support web location is: https://data.unicef.org/sdmx-api-documentation/


REMINDER: You MUST include the sources above in your response to the user using markdown hyperlinks.
Web Fetchhttps://data.unicef.org/resources/api-documentation/
OUT
Request failed with status code 403
Web Fetchhttps://data.unicef.org/sdmx-api-documentation/
OUT
Request failed with status code 403
Web Fetchhttps://medium.com/@schwebel.felix/sdmx-rest-web-service-eafe4107117c
OUT
Request failed with status code 403
Bash Fetch UNICEF SDMX API dataflows sample
IN
curl -s "https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/dataflow/UNICEF/all/latest/?format=sdmx-json" | head -100

OUT
<persisted-output>
Output too large (37.5KB). Full output saved to: C:\Users\jpazevedo\.claude\projects\c--GitHub\b34e34d5-f94d-4511-9c64-ccdcfa3be57d\tool-results\toolu_01N8wy7uv6roVx6RRh3bQFpP.txt

Preview (first 2KB):
{"meta":{"id":"IREF092199","test":false,"schema":"https://raw.githubusercontent.com/sdmx-twg/sdmx-json/develop/structure-message/tools/schemas/1.0/sdmx-json-structure-schema.json","prepared":"2026-01-29T17:53:30Z","contentLanguages":["en"],"sender":{"id":"UNICEF"}},"data":{"dataflows":[{"name":"Cause of death","names":{"en":"Cause of death"},"id":"CAUSE_OF_DEATH","version":"1.0","agencyID":"UNICEF","isExternalReference":false,"isFinal":false,"structure":"urn:sdmx:org.sdmx.infomodel.datastructure.DataStructure=UNICEF:CAUSE_OF_DEATH(1.0)","links":[{"rel":"self","urn":"urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=UNICEF:CAUSE_OF_DEATH(1.0)","uri":"https://raw.githubusercontent.com/sdmx-twg/sdmx-json/develop/structure-message/tools/schemas/1.0/sdmx-json-structure-schema.json","type":"dataflow","hreflang":"en"}]},{"name":"Children’s Climate and Environment Risk Index","names":{"en":"Children’s Climate and Environment Risk Index"},"description":"Children’s Climate and Environment Risk Index (CCRI)","descriptions":{"en":"Children’s Climate and Environment Risk Index (CCRI)"},"id":"CCRI","version":"1.0","agencyID":"UNICEF","isExternalReference":false,"isFinal":false,"structure":"urn:sdmx:org.sdmx.infomodel.datastructure.DataStructure=UNICEF:CCRI(1.0)","links":[{"rel":"self","urn":"urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=UNICEF:CCRI(1.0)","uri":"https://raw.githubusercontent.com/sdmx-twg/sdmx-json/develop/structure-message/tools/schemas/1.0/sdmx-json-structure-schema.json","type":"dataflow","hreflang":"en"}]},{"name":"Child-related SDGs 2020","names":{"en":"Child-related SDGs 2020"},"id":"CHILD_RELATED_SDG","version":"1.0","agencyID":"UNICEF","isExternalReference":false,"isFinal":false,"structure":"urn:sdmx:org.sdmx.infomodel.datastructure.DataStructure=UNICEF:CHILD_RELATED_SDG(1.0)","links":[{"rel":"self","urn":"urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=UNICEF:CHILD_RELATED_SDG(1.0)","uri":"https://raw.githubusercontent.com/sdmx-twg/sdmx-json/devel
...
</persisted-output>
Bash Fetch UNICEF data sample to see structure
IN
curl -s "https://sdmx.data.unicef.org/ws/public/sdmxapi/rest/data/UNICEF,GLOBAL_DATAFLOW,1.0/all?format=sdmx-json&lastNObservations=1" | head -150

OUT
<persisted-output>
Output too large (16.4MB). Full output saved to: C:\Users\jpazevedo\.claude\projects\c--GitHub\b34e34d5-f94d-4511-9c64-ccdcfa3be57d\tool-results\toolu_01AZgsVfB3hRpfRpMsbho8M8.txt

Preview (first 2KB):
{"meta":{"id":"IREF989582","prepared":"2026-01-29T15:02:31","test":false,"sender":{"id":"UNICEF"},"receiver":{"id":"ANONYMOUS"},"links":[{"href":"data/UNICEF,GLOBAL_DATAFLOW,1.0/all/all?lastNObservations=1&detail=full","rel":"self","uri":"https://raw.githubusercontent.com/sdmx-twg/sdmx-json/develop/structure-message/tools/schemas/1.0/sdmx-json-structure-schema.json"}]},"data":{"dataSets":[{"links":[{"rel":"dataflow","urn":"urn:sdmx:org.sdmx.infomodel.datastructure.Dataflow=UNICEF:GLOBAL_DATAFLOW(1.0)","uri":"https://raw.githubusercontent.com/sdmx-twg/sdmx-json/develop/structure-message/tools/schemas/1.0/sdmx-json-structure-schema.json"}],"action":"Information","series":{"0:0:0":{"attributes":[],"observations":{"0":["3.64794849095631",0,0,0,null,null,null,null,0,null,0,0,null,null,null,0,0]}},"0:1:1":{"attributes":[],"observations":{"1":["50.725",null,0,1,0,null,null,null,1,0,1,null,null,0,null,1,1]}},"0:1:2":{"attributes":[],"observations":{"1":["50.593",null,0,1,0,null,null,null,2,0,1,null,null,0,null,1,1]}},"0:1:0":{"attributes":[],"observations":{"1":["50.657",null,0,1,0,null,null,null,3,0,1,null,null,0,null,1,1]}},"0:2:1":{"attributes":[],"observations":{"1":["10.582",null,0,1,0,null,null,null,4,0,2,null,null,0,null,1,2]}},"0:2:2":{"attributes":[],"observations":{"1":["10.486",null,0,1,0,null,null,null,5,0,2,null,null,0,null,1,2]}},"0:2:0":{"attributes":[],"observations":{"1":["10.537",null,0,1,0,null,null,null,6,0,2,null,null,0,null,1,2]}},"0:3:1":{"attributes":[],"observations":{"1":["48.736",null,0,1,0,null,null,null,1,1,1,null,null,0,null,1,1]}},"0:3:2":{"attributes":[],"observations":{"1":["43.561",null,0,1,0,null,null,null,2,1,1,null,null,0,null,1,1]}},"0:3:0":{"attributes":[],"observations":{"1":["46.132",null,0,1,0,null,null,null,3,1,1,null,null,0,null,1,1]}},"0:4:0":{"attributes":[],"observations":{"1":["0.926",null,0,1,0,null,null,null,7,0,1,null,null,0,null,1,3]}},"0:5:1":{"attributes":[],"observations":{"1":["57.778",null,0,1,0,null,null,null,8,0,1,n
...
</persisted-output>
You've hit your limit · resets Jan 30, 4pm (America/New_York)

