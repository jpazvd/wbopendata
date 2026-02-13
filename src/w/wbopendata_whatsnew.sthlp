{smcl}
{* *! version 18.1.0  10Feb2026}{...}
{vieweralsosee "wbopendata" "help wbopendata"}{...}
{viewerjumpto "What's New" "wbopendata_whatsnew##whatsnew"}{...}
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

{marker v181}{...}
{title:Version 18.1.0 (10Feb2026)}

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
