{smcl}
{* *! version 18.7.0  25Apr2026}{...}
{vieweralsosee "wbopendata" "help wbopendata"}{...}
{viewerjumpto "What's New" "wbopendata_whatsnew##whatsnew"}{...}
{viewerjumpto "Version 18.7.0" "wbopendata_whatsnew##v1870"}{...}
{viewerjumpto "Version 18.6.1" "wbopendata_whatsnew##v1861"}{...}
{viewerjumpto "Version 18.6.0" "wbopendata_whatsnew##v1860"}{...}
{viewerjumpto "Version 18.5.0" "wbopendata_whatsnew##v1850"}{...}
{viewerjumpto "Version 18.4.1" "wbopendata_whatsnew##v1841"}{...}
{viewerjumpto "Version 18.3.2" "wbopendata_whatsnew##v1832"}{...}
{viewerjumpto "Version 18.3.1" "wbopendata_whatsnew##v1831"}{...}
{viewerjumpto "Version 18.3.0" "wbopendata_whatsnew##v1830"}{...}
{viewerjumpto "Version 18.2" "wbopendata_whatsnew##v182"}{...}
{viewerjumpto "Version 18.1" "wbopendata_whatsnew##v181"}{...}
{viewerjumpto "Version 18.0" "wbopendata_whatsnew##v180"}{...}
{viewerjumpto "Version 17.8" "wbopendata_whatsnew##v178"}{...}
{viewerjumpto "Version 17.7" "wbopendata_whatsnew##v177"}{...}
{viewerjumpto "Version 17.6" "wbopendata_whatsnew##v176"}{...}
{viewerjumpto "Earlier Versions" "wbopendata_whatsnew##earlier"}{...}
{title:What's New in wbopendata}

{pstd}
{it:Return to {help wbopendata:main help file}}
{p_end}

{marker whatsnew}{...}
{title:What's New}

{pstd}
This file documents recent changes and new features in the {cmd:wbopendata} module.
For complete documentation, see {help wbopendata:help wbopendata}.

{marker v1870}{...}
{title:Version 18.7.0 (25Apr2026)}

{pstd}
{bf:Internal refactor: shared search-alias helper} - The hardcoded source-alias
({it:DoingB}, {it:WDI}, {it:SDGs}, etc.), source-full-name, and topic-name
lookup tables that were previously duplicated inside both search backends
({cmd:__wbopendata_search} for Stata 14-15 and {cmd:__wbopendata_search_cache}
for Stata 16+) have been extracted into a single new helper,
{cmd:__wbod_search_aliases}. Each backend now calls the helper once before
its row loop; the helper populates {it:src_alias_*}, {it:src_name_*}, and
{it:topic_name_*} locals in the caller's scope via {cmd:c_local}, so the
existing lookup pattern (`src_alias_`src_id'') is unchanged.

{pstd}
This is a {it:pure refactor} - no user-facing syntax change, no behavioral
change. Adding a new World Bank source in future releases now requires
editing a single file (the helper) instead of two backends in lock-step.
Net change: ~330 lines of duplicated tables removed.

{phang2}{cmd:. wbopendata, search(GDP)}{p_end}
{phang2}{cmd:. wbopendata, searchsource(2)}      // legend: WDI = World Development Indicators{p_end}
{phang2}{cmd:. wbopendata, searchtopic(11)}      // legend: [11] Poverty{p_end}

{pstd}
{bf:Test coverage} - Five new help-example tests added to close gaps from a
documentation-vs-test audit: pagination ({opt page(N)}, v18.5), {opt cachedays(N)}
override and {opt verbose} passthrough (v18.2), and {opt allsources} (v17.6).
Full QA suite: 92/92 PASS. Help examples: 76/76 PASS.

{marker v1861}{...}
{title:Version 18.6.1 (23Apr2026)}

{pstd}
{bf:Fix: leading-zero source IDs in search display} - When the indicator YAML
stored {it:source_id} as a string with a leading zero (e.g., {it:'02'}), the
alias lookup ("`src_alias_`src_id''") failed because the local table is keyed
on bare integers ({it:src_alias_2}). Both {cmd:__wbopendata_search} and
{cmd:__wbopendata_search_cache} now apply {cmd:real()} and reassign before
the lookup, matching the fix already in {cmd:__wbod_get_source_name} v1.0.1.

{pstd}
{bf:Fix: file-handle safety in sync_preview} - {cmd:__wbod_sync_preview.ado}
extracts the installed package version by reading the first lines of
{it:wbopendata.ado}. The block previously wrapped {cmd:file open}, the read
loop, and {cmd:file close} in a single {cmd:capture} block, so a {cmd:file read}
error would leak the open handle. Split into two captures so {cmd:file close}
always runs.

{pstd}
{bf:Fix: help header date} - {cmd:wbopendata.sthlp} header date corrected
from {it:21Apr2026} to {it:22Apr2026} to match the v18.6.0 release.

{marker v1860}{...}
{title:Version 18.6.0 (22Apr2026)}

{pstd}
{bf:New feature: Sync diff by source} - After {cmd:wbopendata, sync replace}
completes, a source-level breakdown table is displayed showing how many
indicators were added or removed per World Bank data source since the
previous sync. Only sources with actual changes are shown (sources with
no net movement are suppressed). Sources are sorted by absolute net change
so the most-impacted databases appear first. Up to 10 sources are displayed
by default; any beyond the limit are counted in a summary line.

{phang2}{cmd:. wbopendata, sync replace}{p_end}

{pstd}
Example output after sync:

{phang2}{result:  Changes since last sync}{p_end}
{phang2}{result:  ----------------------------------------------------------}{p_end}
{phang2}{result:  Source                                  Added  Removed  Net}{p_end}
{phang2}{result:  ----------------------------------------------------------}{p_end}
{phang2}{result:  Gender Statistics                         188       56 +132}{p_end}
{phang2}{result:  (Unknown source)                           56        0  +56}{p_end}
{phang2}{result:  (3 more sources)}{p_end}
{phang2}{result:  ----------------------------------------------------------}{p_end}
{phang2}{result:  TOTAL                                     244       56 +188}{p_end}

{pstd}
When the indicator list is unchanged the output reads {result:Indicator list: unchanged}.

{pstd}
{bf:Improved: Sync detail source table} - {cmd:wbopendata, sync detail} now
correctly resolves source names for IDs stored with leading zeros in the
indicator YAML (e.g., {it:'02'} now correctly displays as
{it:World Development Indicators}). World Bank vintage/archive sources with
non-standard IDs (prefixed {it:VG*}) are collapsed into a single summary
line rather than flooding the table with hundreds of 1-indicator entries.

{pstd}
{bf:Improved: [sync & see breakdown] link} - The {result:[see breakdown]}
hyperlink next to {result:Change: +N new} in the Remote Status section now
runs {cmd:wbopendata, sync replace}, so clicking it performs the sync and
immediately displays the source-level diff table.

{marker v1850}{...}
{title:Version 18.5.0 (21Apr2026)}

{pstd}
{bf:New feature: Paginated search results} - Search results (by keyword, topic,
or source) now support a new {opt page(#)} option so users can navigate beyond
the first {opt limit(#)} records. Clickable SMCL {opt [Prev]}, {opt [Next]},
and page-number links are rendered below the results whenever matches exceed
one page. Small result sets (<=30 matches) continue to render on a single
page with no pagination nav - the navigation only appears when it is useful.

{pstd}
New return values: {cmd:r(page)} and {cmd:r(n_pages)} expose the current page
and total page count for scripting.

{phang2}{cmd:. wbopendata, searchtopic(11) limit(20) page(2)}{p_end}
{phang2}{cmd:. wbopendata, search(poverty) limit(10) page(3)}{p_end}

{marker v1841}{...}
{title:Version 18.4.1 (19Apr2026)}

{pstd}
{bf:Bug fix: Country context variables restored} - The 8 default country context
variables ({opt region}, {opt regionname}, {opt adminregion}, {opt adminregionname},
{opt incomelevel}, {opt incomelevelname}, {opt lendingtype}, {opt lendingtypename})
were silently missing since v18.0.0 despite being the documented default since v17.7.
Fixed by re-including the country lookup programs ({cmd:_wbod_tmpfile1/2/3.ado}) in
the package. Use {opt nobasic} to suppress these variables.
Users can refresh country metadata from the World Bank API with:
{cmd:wbopendata, update countrymetadata}

{pstd}
{bf:Bug fix: Help file truncation} - The database list in {cmd:help wbopendata}
was truncated mid-word ("Gender Statist lth Nutrition...") due to a SMCL line
length limit. Fixed by splitting the physical line.

{marker v1832}{...}
{title:Version 18.3.2 (23Feb2026)}

{pstd}
{bf:Frame cache completeness} - All three metadata frames ({it:_wbod_indicators}, {it:_wbod_sources}, {it:_wbod_topics})
are now properly invalidated on sync operations. Cache manifest documentation added; test documentation clarified.

{marker v1831}{...}
{title:Version 18.3.1 (23Feb2026)}

{pstd}
{bf:Reset Data Cache} - New {opt resetdatacache} option expires all cached data
entries without deleting the CSV files. The next query re-fetches fresh data
from the API while keeping cached files as a fallback. This complements
{opt cleardatacache} (which deletes everything) and {opt nocache} (per-query bypass).

{pstd}
{bf:Verbose Option} - New {opt verbose} option provides targeted error handling
for cache and metadata operations.

{marker v1830}{...}
{title:Version 18.3.0 (23Feb2026)}

{pstd}
{bf:YAML Metadata Lookup on Cache Hit} - When the local YAML cache is current,
discovery commands ({opt search()}, {opt info()}, {opt sources}, {opt alltopics})
now resolve metadata directly from the cached YAML files without making any
API call. This eliminates network latency for common catalog browsing workflows.

{pstd}
{bf:Configurable Cache TTL} - New {opt cachedays(#)} option (default 7) controls
how many days cached API responses are kept before automatic re-fetch.
Use {cmd:cachedays(1)} for daily freshness or {cmd:cachedays(30)} for monthly.

{pstd}
{bf:QA Suite Hardened} - Post-sync validation now uses hard asserts to verify
YAML files are actually created after every sync operation, preventing silent
false-pass results. Redundant sync calls in tests replaced with conditional
checks, reducing test suite runtime by ~50%.

{marker v182}{...}
{title:Version 18.2.0 (22Feb2026)}

{pstd}
{bf:Data Response Cache} - API responses are now cached locally with a 7-day
TTL. Repeated queries for the same indicator, country, and language return
instantly from disk instead of re-downloading. The cache is on by default;
use {opt nocache} to bypass for a single query.

{pstd}
{bf:New Options} - {opt nocache} bypasses the data cache for a fresh download;
{opt cleardatacache} removes all cached API response files. The {opt cacheinfo}
command now also displays data cache statistics.

{pstd}
{bf:Cache Consolidation} - All metadata cache operations consolidated to
{cmd:sysdir_plus} (eliminated split-brain with {cmd:sysdir_personal}).
Simplified YAML path resolver from 5-level to 2-level (findfile + fallback).
Removed 3 orphaned cache files. Frame cache now invalidated on sync.

{marker v181}{...}
{title:Version 18.1.1 (22Feb2026)}

{pstd}
{bf:Characteristic Metadata} - Indicator metadata (name, description, source, note)
is now stored as Stata characteristics ({cmd:char}) on the dataset, accessible via
{cmd:char list} after any download. Use {opt nochar} to suppress.

{pstd}
{bf:Linewrap Fix} - The {opt linewrap()} option is now passed to {cmd:_query_metadata}
only when explicitly specified, preventing errors when older subroutine versions
are installed.

{pstd}
{bf:Expanded QA Suite} - Test suite expanded from 65 to 89 tests across 16 categories,
including new CHAR, ERR, EXT, and DET test groups for characteristic metadata,
error conditions, extreme cases, and deterministic/offline validation.

{marker v180}{...}
{title:Version 18.0.0 (05Feb2026)}

{pstd}
{bf:YAML-Based Architecture} - Parameters data moved from hardcoded Stata code to
{cmd:_wbopendata_parameters.yaml}, making metadata human-readable and independently
updatable without code changes.

{pstd}
{bf:Streamlined Help Files} - Deprecated 89 per-indicator help files
({cmd:wbopendata_sourceid_indicators*.sthlp} and {cmd:wbopendata_topicid_indicators*.sthlp}).
Source and topic help files now point users to the interactive discovery commands
({cmd:sources}, {cmd:alltopics}, {cmd:search}, {cmd:info}) instead of static indicator
listings that required regeneration with each metadata update.

{marker v178}{...}
{title:Version 17.8.1 (04Feb2026)}

{pstd}
{bf:Discovery Commands} - New interactive commands for exploring World Bank data:

{p2colset 5 28 30 2}{...}
{p2col:{opt sources}}List all 71 World Bank data sources with indicator counts{p_end}
{p2col:{opt alltopics}}List all 21 topic categories with indicator counts{p_end}
{p2col:{opt search(string)}}Search indicators by keyword, wildcard, or regex{p_end}
{p2col:{opt info(code)}}Get detailed metadata for a specific indicator{p_end}
{p2colreset}{...}

{pstd}
{bf:Search Features:}

{phang2}{cmd:. wbopendata, sources}{break}
Lists all data sources with clickable {result:[Browse]} links for navigation.

{phang2}{cmd:. wbopendata, alltopics}{break}
Lists all topic categories with clickable {result:[Browse]} links.

{phang2}{cmd:. wbopendata, search(GDP)}{break}
Search indicators by keyword. Supports multiple words, wildcards (*), and regex patterns.

{phang2}{cmd:. wbopendata, search(education) searchtopic(4)}{break}
Filter search results by topic.

{phang2}{cmd:. wbopendata, search(GDP) searchsource(2)}{break}
Filter search results by source (e.g., 2 = World Development Indicators).

{phang2}{cmd:. wbopendata, search(poverty) detail}{break}
Show full indicator details with wrapped text instead of truncated table.

{phang2}{cmd:. wbopendata, info(NY.GDP.MKTP.CD)}{break}
Display detailed metadata for a specific indicator.

{pstd}
{bf:Search Options:}

{p2colset 5 28 30 2}{...}
{p2col:{opt searchsource(#)}}Filter results to specific source ID{p_end}
{p2col:{opt searchtopic(#)}}Filter results to specific topic ID{p_end}
{p2col:{opt searchfield(str)}}Search in: {it:code}, {it:name}, {it:description}, or {it:all} (default){p_end}
{p2col:{opt exact}}Require exact word match (no partial matching){p_end}
{p2col:{opt detail}}Show full wrapped details instead of truncated table{p_end}
{p2col:{opt limit(#)}}Maximum results to display (default: 20){p_end}
{p2colreset}{...}

{pstd}
{bf:Dynamic Column Widths:}

{pstd}
Search results now adapt to your terminal width ({cmd:c(linesize)}). Wider terminals
show more of indicator names and topics without truncation.

{pstd}
{bf:Clickable Navigation:}

{pstd}
All discovery commands include clickable SMCL links:
{p_end}
{phang2}- {result:[Browse]} links to explore indicators within a source or topic{p_end}
{phang2}- {result:[Info]} links to view detailed indicator metadata{p_end}
{phang2}- {result:[Download]} links to fetch data directly{p_end}

{marker v177}{...}
{title:Version 17.7 (January 2026)}

{pstd}
{bf:Basic Country Context by Default:}

{pstd}
Every data download now automatically includes 8 country context variables:
{p_end}
{phang2}{cmd:region}, {cmd:regionname} - World Bank region classification{p_end}
{phang2}{cmd:adminregion}, {cmd:adminregionname} - Administrative region{p_end}
{phang2}{cmd:incomelevel}, {cmd:incomelevelname} - Income level classification{p_end}
{phang2}{cmd:lendingtype}, {cmd:lendingtypename} - World Bank lending type{p_end}

{pstd}
Use {opt nobasic} to suppress these variables if not needed.

{pstd}
{bf:Graph Metadata Options:}

{p2colset 5 28 30 2}{...}
{p2col:{opt linewrap(fields)}}Wrap text for graph-ready display{p_end}
{p2col:{opt maxlength(#)}}Maximum characters per line (default: 50){p_end}
{p2col:{opt linewrapformat(fmt)}}Output format: {it:stack}, {it:newline}, {it:lines}, {it:all}{p_end}
{p2colreset}{...}

{marker v176}{...}
{title:Version 17.6 (December 2025)}

{pstd}
{bf:Metadata Caching and Sync:}

{p2colset 5 28 30 2}{...}
{p2col:{opt sync}}Sync metadata cache from GitHub{p_end}
{p2col:{opt checkupdate}}Check if metadata updates are available{p_end}
{p2col:{opt cacheinfo}}Display cache status and location{p_end}
{p2col:{opt clearcache}}Clear local metadata cache{p_end}
{p2colreset}{...}

{marker earlier}{...}
{title:Earlier Versions}

{pstd}
For complete version history, see the {browse "https://github.com/jpazvd/wbopendata/blob/main/CHANGELOG.md":CHANGELOG} on GitHub.

{p2colset 5 18 20 2}{...}
{p2col:{bf:Version}}{bf:Highlights}{p_end}
{p2line}
{p2col:v17.1}Community bug fixes, documentation overhaul{p_end}
{p2col:v17.0}Region metadata, enhanced country matching{p_end}
{p2col:v16.3}HTTPS API migration{p_end}
{p2col:v16.2.3}Metadata query rewrite (_api_read.ado){p_end}
{p2col:v16.2.2}Metadata server update{p_end}
{p2col:v16.2.1}Flow check for metadataoffline{p_end}
{p2col:v16.2}Offline metadata option (SOURCEID/TOPICID docs){p_end}
{p2col:v16.1}Removed SOURCEID/TOPICSID from package{p_end}
{p2col:v16.0.1}Minor functionality improvements{p_end}
{p2col:v16.0}Multiple indicators, modular architecture{p_end}
{p2col:v15.1}Update options, 16,000+ indicators{p_end}
{p2col:v15.0.1}Maintenance release{p_end}
{p2col:v15.0}Major version bump{p_end}
{p2col:v14.3}_wbopendata_update.ado revised (no out.txt){p_end}
{p2col:v14.2}Checksum off; update fixes{p_end}
{p2col:v14.1}Indicator update + nopreserve{p_end}
{p2col:v14.0}New API server, indicator list revised{p_end}
{p2col:v13.5}Last SSC release (2016){p_end}
{p2col:v13.4}Long reshape{p_end}
{p2col:v13.3}New error control (clear option){p_end}
{p2col:v13.2}New error control mechanisms{p_end}
{p2col:v13.1}Regional code/name/iso2code support{p_end}
{p2col:v13.0}Duplicates fix; indicator list to 9,960{p_end}
{p2col:v12.0}Indicator list to 7,349; return list labels{p_end}
{p2colreset}{...}

{title:Author}

{pstd}
Joao Pedro Azevedo{break}
{browse "https://github.com/jpazvd/wbopendata":github.com/jpazvd/wbopendata}
{p_end}

{pstd}
{it:Return to {help wbopendata:main help file}}
{p_end}
