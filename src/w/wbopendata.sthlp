{smcl}
{hline}
{* 21Apr2026  }{...}
{cmd:help wbopendata}{right:dialog:  {bf:{dialog wbopendata}}}
{right:Indicator List:  {bf:{help wbopendata_sourceid##indicators:Indicators List}}}
{right:What's New:  {bf:{help wbopendata_whatsnew:What's New}}}
{right: {bf:version 18.6.0}}
{hline}

{title:Title}

{p2colset 9 24 22 2}{...}
{p2col :{hi:wbopendata} {hline 2}}World Bank Open Databases.{p_end}
{p2colreset}{...}
{pstd}Requires Stata 14 or later.{p_end}
{title:Syntax}

{p 6 16 2}
{cmd:wbopendata}{cmd:,} {it:{help wbopendata##Options2:Parameters}} [{it:{help wbopendata##options:Options}}]

{synoptset 27 tabbed}{...}
{synopthdr:Parameters}
{synoptline}
{synopt :{opt country}(acronym)}list of country code (accepts multiples){p_end}
{p 20 20 6}{it:(and)}{p_end}
{synopt :{opt topics}(acronym)}topic code (only accepts one){p_end}
{p 20 20 6}{it:(or)}{p_end}
{synopt :{opt indicator}(acronym)}list of indicator code(accepts multiples){p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt :{opt long}} imports the data in the long format. {p_end}
{synopt :{opt clear}} replace data in memory.{p_end}
{synopt :{opt latest}} keep only the latest available value per country (common year across indicators).{p_end}
{synopt :{opt nometadata}} omits the display of the metadata.{p_end}
{synopt :{opt year}{cmd:(}{it:date1}{cmd::}{it:date2}{cmd:)}} time interval (in yearly, quarterly or monthly depending on the series).{p_end}
{synopt :{opt date}{cmd:(}{it:date}{cmd:)}} alternative time specification for monthly/quarterly series (mutually exclusive with {opt year}).{p_end}
{synopt :{opt source}{cmd:(}{it:#}{cmd:)}} restrict download to a specific World Bank source database (e.g., 2 for WDI).{p_end}
{synopt :{opt language}{cmd:(}{it:language}{cmd:)}} select the language.{p_end}
{synopt :{opt full}} adds full list of country attributes.{p_end}
{synopt :{opt basic}} adds basic country context variables (default as of v17.7).{p_end}
{synopt :{opt nobasic}} suppresses the default basic country context variables.{p_end}
{synopt :{opt nochar}} suppresses variable and dataset characteristics ({cmd:char}). By default, wbopendata attaches metadata to variables and the dataset via {help char}; use this to suppress.{p_end}
{synopt :{opt iso}} adds 2 digits ISO codes to country attributes.{p_end}
{synopt :{opt geo}} adds geographic metadata (capital city name, latitude, and longitude).{p_end}
{synopt :{opt capital}} adds capital city name to country attributes.{p_end}
{synopt :{opt latitude}} adds capital city latitude to country attributes.{p_end}
{synopt :{opt longitude}} adds capital city longitude to country attributes.{p_end}
{synopt :{opt regions}} adds region codes and names to country attributes.{p_end}
{synopt :{opt adminr}} adds administrative region codes and names to country attributes.{p_end}
{synopt :{opt income}} adds income level codes and names to country attributes.{p_end}
{synopt :{opt lending}} adds lending type codes and names to country attributes.{p_end}
{synopt :{opt sync}} preview metadata changes without applying (dry run). Safe default.{p_end}
{synopt :{opt sync} {opt detail}} preview with per-source and per-topic indicator breakdown.{p_end}
{synopt :{opt sync} {opt force}} force-refresh preview diagnostic (re-query API). Still dry run.{p_end}
{synopt :{opt sync} {opt replace}} apply metadata sync — download latest release from GitHub.{p_end}
{synopt :{opt sync} {opt replace} {opt force}} force re-download metadata regardless of local version.{p_end}
{synopt :{opt checkupdate}} check whether newer YAML metadata is available without downloading it.{p_end}
{synopt :{opt nocache}} bypass the data response cache and force a fresh API download.{p_end}
{synopt :{opt cachedays(#)}} set cache time-to-live in days (default 7).{p_end}
{synopt :{opt clearcache}} remove the local metadata cache (forces re-download on next sync).{p_end}
{synopt :{opt cleardatacache}} remove all cached API response files.{p_end}
{synopt :{opt resetdatacache}} expire all cached data entries (files kept, re-fetched on next query).{p_end}
{synopt :{opt verbose}} display diagnostic messages during cache lookups and API queries.{p_end}
{synopt :{opt cacheinfo}} display cache location, version, and timestamp for the metadata YAML files and data cache.{p_end}
{synopt :{opt match(varname)}} merge {help wbopendata##attributes:country attributes} into an existing dataset containing WDI (3 digit) countrycodes. Cannot be used with the data download options.{p_end}
{synopt :{opt projection}} World Bank {help wbopendata_sourceid##sourceid_40:population estimates and projections} (HPP) .{p_end}
{synopt :{opt describe}} display indicator metadata only (no data download). Requires {opt indicator()}. Supports {opt linewrap()}, {opt maxlength()}, and {opt linewrapformat()} when present.{p_end}
{synopt :{opt linewrap(fields)}} wrap metadata text for graph titles. Fields: name, description, note, source, topic, or all.{p_end}
{synopt :{opt maxlength(# [# ...])}} maximum characters per line for linewrap. Single value (default 50) or multiple values matching linewrap field order.{p_end}
{synopt :{opt linewrapformat(fmt)}} output format: stack (default), newline, nlines, lines, or all.{p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Discovery Commands}
{synoptline}
{synopt :{opt sources}} list World Bank data sources with indicator counts and clickable navigation.{p_end}
{synopt :{opt allsources}} list all World Bank data sources without the default display limit.{p_end}
{synopt :{opt alltopics}} list all World Bank topics with indicator counts and clickable navigation.{p_end}
{synopt :{opt search(pattern)}} search indicators by keyword, wildcard, or regex pattern.{p_end}
{synopt :{opt searchsource(#)}} filter search results to a specific source ID.{p_end}
{synopt :{opt searchtopic(#)}} filter search results to a specific topic ID.{p_end}
{synopt :{opt searchfield(fields)}} search in specific fields: code, name, description, source, topic, note, or all.{p_end}
{synopt :{opt exact}} require exact match (no partial matching).{p_end}
{synopt :{opt detail}} display search results in wrapped block format (full labels).{p_end}
{synopt :{opt limit(#)}} maximum results per page (default 20).{p_end}
{synopt :{opt page(#)}} page of search results to display (default 1). Result sets with 30 or fewer matches are always shown on a single page regardless of {cmd:limit()}; otherwise total pages = ceil(matches / limit). Clickable [Prev]/[Next] links appear below the results when paging is available.{p_end}
{synopt :{opt info(code)}} display detailed metadata for a specific indicator.{p_end}
{synoptline}
{p 4 6 2}
{cmd:wbopendata} requires a connection to the internet and supports the Stata dialogue function ({dialog wbopendata}).{p_end}
 

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help wbopendata##desc:Command description}}
		{it:{help wbopendata##param:Parameters description}}
		{it:{help wbopendata##options:Options description}}
		{it:{help wbopendata##syncmeta:Metadata management}}
		{it:{help wbopendata##discovery:Discovery commands}}
		{it:{help wbopendata##storedresults:Stored results}}
		{it:{help wbopendata##charmetadata:Characteristic metadata (v18.1+)}}
		{it:{help wbopendata##deprecated:Deprecated options}}
		{it:{help wbopendata##attributes:List of supported country attributes}}
		{it:{help wbopendata##countries:Country code and names by selected attributes}}
		{it:{help wbopendata##sourceid:Indicators by Source}}
		{it:{help wbopendata##topic:Topic List}}
		{it:{help wbopendata##Examples:Examples}}
		{it:{help wbopendata##disclaimer:Disclaimer}}
		{it:{help wbopendata##termsofuse:Terms of use}}
		{it:{help wbopendata##howtocite:How to cite}}
		{it:{help wbopendata##references:References}}
		{it:{help wbopendata##acknowled:Acknowledgements}}


{marker desc}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Description}
{pstd}

{p 4 4 2}{cmd:wbopendata} provides Stata users with programmatic access to the World Bank's Open Data API, enabling scripted, reproducible downloads of over 29,000 indicators from 71 databases covering 296 countries and regions from 1960 to present. First released in February 2011, one year after the World Bank Open Data Initiative, {cmd:wbopendata} has maintained backward compatibility across fifteen years of API changes while adding features for metadata inspection, multilingual support, and publication-ready output formatting.{p_end}

{p 4 4 2}The command exemplifies data acquisition as code: indicator selections, country lists, time ranges, and filters are explicitly parameterized in analysis scripts rather than buried in manual downloads, ensuring that data provenance is explicit and enabling analyses to be reproduced exactly or systematically updated as new data become available.{p_end}

{p 4 4 2}The accessible databases include: World Development Indicators (WDI),
Doing Business, Worldwide Governance Indicators, International Debt Statistics,
Africa Development Indicators, Education Statistics, Enterprise Surveys,
Gender Statistics, Health Nutrition and Population Statistics,
Global Financial Inclusion (Findex), Poverty and Equity, Human Capital Index,
Climate Change (CCDR), Sustainable Development Goals, and many more.{p_end}

{p 4 4 2}Users can choose from one of three {cmd:languages} supported by the database (and Stata), namely, English, Spanish, or French.{p_end}

{p 4 4 2}Five possible download modes are currently supported:{p_end}

{synopt:{opt country}} All WDI indicators for a single country across selected years.{p_end}
{synopt:{opt topics}} All indicators within a thematic category (e.g., Education, Health) for all countries.{p_end}
{synopt:{opt indicator}} A single indicator for all countries and years (from any of the 71 databases: 29,000+ series).{p_end}
{synopt:{opt indicator and country}} A single indicator for selected countries (from any of the 71 databases: 29,000+ series).{p_end}
{synopt:{opt multiple indicator}} Multiple indicators separated by ; (from any of the 71 databases: 29,000+ series).{p_end}

{p 4 4 2}Users can also choose to have the data displayed in either the {cmd:wide} or {cmd:long} format (wide is the default option).
Note that the reshape is done on the local machine, so it will require the appropriate amount of RAM to work properly.{p_end}

{p 4 4 2}{cmd:wbopendata} retrieves data directly from the World Bank API (JSON over HTTP), ensuring transparency and provenance. All data reflect officially-recognized international sources compiled by the World Bank, presenting the most current and accurate global development data available, including national, regional and global estimates.{p_end}

{p 4 4 2}The access to this databases is made possible by the {it:World Bank's Open Data Initiative} which provide 
open full access to {browse "http://data.worldbank.org/" : World Bank databases}.{p_end}


{marker param}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Parameters description}

{dlgtab: Parameters}

{synopt:{opt country(string)}}{help wbopendata##countries:Countries and Regions Abbreviations and acronyms}. If solely specified, this option
will return all the WDI indicators for a single country or region (no multiple country selection allowed in 
this case). If this option is selected jointly with a specific indicator, the output is a series for a specific 
country or region, or multiple countries or regions. When selecting multiple countries please use the three letters code, separated by 
a semicolon (;), with no spaces.{p_end}

{synopt:{opt topics(numlist)}}{help wbopendata##topics:Topic List} 21 topic lists are currently supported and include Agriculture & Rural Development; 
Aid Effectiveness; Economy & Growth; Education; Energy & Mining; Environment; Financial Sector; Health; Infrastructure; Social Protection & Labor; 
Poverty; Private Sector; Public Sector; Science & Technology; Social Development; Urban Development; Gender; Millennium Development Goals; Climate Change; 

External Debt; and, Trade (only one topic collection can be requested at the time).{p_end}
{synopt:{opt indicator(string)}}{help wbopendata_sourceid##indicators:Indicators List} list of indicator codes (All series). When selecting multiple 
indicators please use semicolon (;) to separate different indicators.{p_end}


{marker options}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Options description}

{dlgtab:Options}

{synopt:{opt long}} imports the data in the long format. The default option is to import the data in the wide format. It is important 
note that {cmd:wbopendata} uses Stata resources to reshape the variables, hence user has to make sure that Stata will have sufficient 
RAM to complete this operation.{p_end}

{synopt:{opt clear}} replace data in memory.{p_end}

{synopt:{opt latest}} keep only the latest available value per country (requires {opt long} format). 
With multiple indicators, keeps only observations where {bf:all} indicators are non-missing in the {bf:same year}, 
ensuring comparability across indicators within each country. Different countries may have different years, 
but within each country all indicators share the same reference year. 
Returns {cmd:r(latest)} with a formatted subtitle string (e.g., "Latest Available Year, 186 Countries (avg year 2019.6)"), 
{cmd:r(latest_ncountries)} with the country count, {cmd:r(latest_avgyear)} with the average year, 
and {cmd:r(latest_year)} with the maximum year.{p_end}

{synopt:{opt nometadata}} omits the display of the metadata information from the series. Metadata information is only available when downloading specific series (indicator option). The metadata available include information on the name of the series, the source, a detailed description 
of the indicator, and the organization responsible for compiling this indicator.{p_end}

{synopt:{opt year:(date1:date2)}} allow users to select a specific time interval. Date1=Initial date; Date2=Final date. For most indicators Date should be expressed in yearly format, however for specific series quartely and montly series will be supported. Please check data documentation
at the World Bank Data website to identify which format is supported.{p_end}

{synopt:{opt date(date)}}alternative time specification for monthly or quarterly
series. Mutually exclusive with {opt year()}; only one may be specified. The date
string is passed directly to the World Bank API {cmd:date} parameter.{p_end}

{synopt:{opt source(#)}}restrict the data download to a specific World Bank source
database. The source number corresponds to the Source ID shown by {opt sources}.
For example, {cmd:source(2)} restricts to the World Development Indicators; {cmd:source(11)}
to Africa Development Indicators. The {opt projection} option is a shortcut for
{cmd:source(40)}.{p_end}

{synopt:{opt language(option)}}three languages are supported: The default language is English.{p_end}

{center: English:  {cmd:en}          }
{center: Spanish:  {cmd:es}          }
{center: French:   {cmd:fr}          }

{synopt :{opt full}} adds full list of country attributes.{p_end}

{synopt :{opt basic}} adds basic country context variables: region, regionname, adminregion, adminregionname, incomelevel, incomelevelname, lendingtype, lendingtypename. This is the {bf:default behavior} as of v17.7.{p_end}

{synopt :{opt nobasic}} suppresses the default basic country context variables. Use this option when you only want the core data without country classification metadata.{p_end}

{synopt :{opt nochar}} suppresses dataset and variable characteristics ({help char}). By default (v18.1+), {cmd:wbopendata} stores
metadata in Stata {cmd:char} attributes that persist across {cmd:save}/{cmd:use} cycles: dataset-level ({cmd:_dta[]})
captures session provenance (version, timestamp, syntax), while variable-level ({cmd:{it:varname}[]}) captures
indicator metadata (code, source, description, topics, notes). Use {cmd:nochar} to suppress all
{cmd:char} writes if you prefer minimal .dta files. See {help wbopendata##charmetadata:Characteristic metadata} below.{p_end}

{synopt :{opt iso}} adds only 2 digits ISO codes to country attributes.{p_end}

{synopt :{opt geo}} adds geographic metadata variables including capital city name, latitude, and longitude coordinates for each country.{p_end}

{synopt :{opt capital}} adds the capital city name variable. Use this option to merge only the capital city name without other geographic information. Can be combined with other geographic options (latitude, longitude) or metadata options (iso, full).{p_end}

{synopt :{opt latitude}} adds the capital city latitude coordinate variable. Useful for mapping and geographic analysis. Can be combined with capital and/or longitude options.{p_end}

{synopt :{opt longitude}} adds the capital city longitude coordinate variable. Useful for mapping and geographic analysis. Can be combined with capital and/or latitude options.{p_end}

{synopt :{opt regions}} adds region codes (3-letter codes) and region names (English names) to the dataset.{p_end}

{synopt :{opt adminr}} adds administrative region codes and names, including subcategories such as East Asia & Pacific, Europe & Central Asia, Latin America & Caribbean, Middle East & North Africa, and Sub-Saharan Africa.{p_end}

{synopt :{opt income}} adds income level classifications (Low income, Lower-middle income, Upper-middle income, High income) and their ISO 2-digit codes.{p_end}

{synopt :{opt lending}} adds lending type classifications (IBRD only, Blend, IDA only, etc.) and their ISO 2-digit codes.{p_end}

{synopt :{opt match(varname)}} merge {it:{help wbopendata##attributes:country attributes}} using WDI countrycodes.{p_end}

{synopt :{opt projection}} World Bank staff {help wbopendata_sourceid##sourceid_40:population projection estimates} using the World Bank's total population and age/sex distributions of the United Nations Population Division's World Population Prospects: 2019 Revision.{p_end} 

{synopt :{opt linewrap(fields)}} wrap metadata text for use in graph titles and notes. This option processes the specified metadata fields and returns wrapped versions suitable for Stata graphs. Available fields:{p_end}
{p 8 12 2}- {opt name}: indicator name{p_end}
{p 8 12 2}- {opt description}: indicator description{p_end}
{p 8 12 2}- {opt note}: source notes{p_end}
{p 8 12 2}- {opt source}: source information{p_end}
{p 8 12 2}- {opt topic}: topic classification{p_end}
{p 8 12 2}- {opt all}: all fields{p_end}
{p 8 8 2}Returns {cmd:r({it:field}1_stack)} in the format {cmd:\"line1\" \"line2\"} for use with {cmd:title()}.{p_end}
{p 8 8 2}Also returns {cmd:r(sourcecite1)}, {cmd:r(sourcecite2)}, etc. with clean organization names for graph source attribution.{p_end}

{synopt :{opt maxlength(# [# ...])}} maximum number of characters per line when using {opt linewrap()}. 
Can be a single value (default 50) applied to all fields, or multiple values applied in order to fields 
specified in {opt linewrap()}. For example, {cmd:maxlength(40 100 80) linewrap(name description note)} 
sets name to 40 chars, description to 100 chars, and note to 80 chars. If fewer values than fields,
the last value is used for remaining fields.{p_end}

{synopt :{opt linewrapformat(fmt)}} controls output format for linewrap. Options:{p_end}
{p 8 12 2}- {opt stack}: (default) returns only {cmd:r({it:field}1_stack)} format for {cmd:title()}{p_end}
{p 8 12 2}- {opt newline}: returns {cmd:r({it:field}1_newline)} with embedded newline characters{p_end}
{p 8 12 2}- {opt nlines}: returns {cmd:r({it:field}1_nlines)} scalar with line count{p_end}
{p 8 12 2}- {opt lines}: returns {cmd:r({it:field}1_line1)}, {cmd:r({it:field}1_line2)}, etc. for each line{p_end}
{p 8 12 2}- {opt all}: returns all formats ({cmd:_stack}, {cmd:_newline}, {cmd:_nlines}, {cmd:_line1}, etc.){p_end}


{marker syncmeta}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Metadata management (v18.0+)}

{pstd}
These commands manage the local YAML metadata cache that powers the
{help wbopendata##discovery:discovery commands}
({opt sources}, {opt alltopics}, {opt search()}, {opt info()}).
The default {opt sync} is a safe dry run that previews changes without
modifying any files.{p_end}

{dlgtab:Sync preview (dry run)}

{synopt :{opt sync}}Preview metadata changes without applying them. Compares
the local cache version against the latest available release and displays a
summary of what would change. This is the safe default — no files are
modified.{p_end}

{synopt :{opt sync} {opt detail}}Extended preview with per-source and per-topic
indicator breakdowns, showing how many indicators each source contributes and
how they are distributed across topic categories.{p_end}

{synopt :{opt sync} {opt force}}Force-refresh the preview diagnostic by
re-querying the API rather than relying on cached diagnostics. Still a dry
run — no files are modified.{p_end}

{dlgtab:Sync apply}

{synopt :{opt sync} {opt replace}}Apply the metadata synchronization — downloads
the latest YAML metadata release from the GitHub repository and updates the
local cache files. Displays the same preview as {opt sync} before applying
changes, then shows a diff of added and removed indicators (v18.6+).{p_end}

{synopt :{opt sync} {opt replace} {opt force}}Force re-download of metadata
regardless of the local cache version, bypassing staleness checks. Use this
when the local cache may be corrupted or you want a clean refresh.{p_end}

{dlgtab:Cache management}

{synopt :{opt checkupdate}}Query the remote repository for the latest release
version and report whether an update is available, without downloading or
modifying any files. Equivalent to checking for updates only.{p_end}

{synopt :{opt cacheinfo}}Display the cache directory location, current metadata
version, schema version, and last synchronization timestamp.{p_end}

{synopt :{opt clearcache}}Remove the local metadata cache entirely, forcing a
full re-download on the next {opt sync replace} or discovery command.{p_end}

{synopt :{opt cleardatacache}}Remove all cached API response files from the data
cache folder. The next data download will fetch fresh data from the World Bank
API.{p_end}

{dlgtab:Data response cache (v18.2+)}

{pstd}
As of v18.2, {cmd:wbopendata} caches API responses locally so that repeated
queries for the same indicator, country, and language combination return
instantly from disk instead of re-downloading from the World Bank API. The
default TTL is 7 days; use {opt cachedays(#)} to change it (v18.3+).{p_end}

{pstd}
The cache is {bf:on by default}. Use {opt nocache} to bypass it for a single
query, {opt cleardatacache} to remove all cached files, or
{opt resetdatacache} to expire all entries without deleting them.{p_end}

{synopt :{opt nocache}}Skip the data cache lookup and force a fresh download
from the API. The downloaded data still gets saved to the cache for future
use.{p_end}

{synopt :{opt cachedays(#)}}Set the cache time-to-live in days (default 7).
Cached API responses older than this many days are automatically re-fetched.
For example, {opt cachedays(1)} re-downloads data daily; {opt cachedays(30)}
keeps cached data for a month.{p_end}

{synopt :{opt resetdatacache}}Mark all cached data entries as expired without
deleting the CSV files. On the next query, fresh data will be fetched from
the API. This is useful when you want to force a refresh but keep the cached
files as a safety net.{p_end}

{synopt :{opt verbose}}Display diagnostic messages during cache lookups and
API queries, including cache hit/miss status and YAML metadata resolution
steps. Useful for troubleshooting download or caching issues.{p_end}


{marker discovery}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Discovery Commands}

{pstd}
Discovery commands help you explore the World Bank Open Data catalog without downloading data.
All discovery outputs feature clickable SMCL navigation links that let you drill down from
sources to topics to individual indicators, and then download data with a single click.{p_end}

{pstd}
The discovery architecture in {cmd:wbopendata} follows the model introduced by {cmd:{help unicefdata}}
(Azevedo, 2026), which pioneered offline catalog browsing with YAML-backed metadata, keyword search,
and clickable SMCL navigation in Stata. The {cmd:wbopendata} implementation extends this pattern to
the World Bank's 71 data sources and 29,000+ indicators.{p_end}

{dlgtab:List Sources}

{synopt :{opt sources}}Lists World Bank data sources (databases) with clickable navigation.{p_end}

{pstd}Displays a table showing source ID, name, indicator count, and a clickable [Browse] link
to see all indicators in that source. Use {opt limit(#)} to control display.{p_end}

{p 8 12}{stata "wbopendata, sources" :. wbopendata, sources}{p_end}

{synopt :{opt allsources}}Same as {opt sources} but shows all sources without the default
display limit.{p_end}

{p 8 12}{stata "wbopendata, allsources" :. wbopendata, allsources}{p_end}

{pstd}Returns: {cmd:r(n_sources)}, {cmd:r(n_indicators)}, {cmd:r(source_codes)}, {cmd:r(source_names)}, {cmd:r(cmd)}{p_end}

{dlgtab:List Topics}

{synopt :{opt alltopics}}Lists all 21 World Bank topic categories with clickable navigation.{p_end}

{pstd}Displays a table showing topic ID, name, indicator count, and a clickable [Browse] link
to see all indicators in that topic. Use {opt limit(#)} to control display.{p_end}

{p 8 12}{stata "wbopendata, alltopics" :. wbopendata, alltopics}{p_end}

{pstd}Returns: {cmd:r(n_topics)}, {cmd:r(topic_ids)}, {cmd:r(topic_names)}, {cmd:r(cmd)}{p_end}

{dlgtab:Search Indicators}

{synopt :{opt search(pattern)}}Search indicators by keyword, wildcard pattern, or regex.{p_end}

{pstd}The search command scans indicator codes, names, descriptions, source organizations,
topic names, and notes. Results include clickable [Info] and [Get] links for each indicator.{p_end}

{pstd}{ul:{bf:Basic search:}}{p_end}

{p 8 12}{stata "wbopendata, search(GDP)" :. wbopendata, search(GDP)}{p_end}
{p 8 12}{stata "wbopendata, search(poverty) limit(50)" :. wbopendata, search(poverty) limit(50)}{p_end}

{pstd}{ul:{bf:Multi-keyword AND search:}} Use {cmd:+} between keywords to require ALL words match:{p_end}

{p 8 12}{stata "wbopendata, search(learning+poverty)" :. wbopendata, search(learning+poverty)}{p_end}
{p 8 12}{stata "wbopendata, search(GDP+per+capita)" :. wbopendata, search(GDP+per+capita)}{p_end}

{pstd}{ul:{bf:Wildcard patterns:}}{p_end}

{p 8 12 2}- {cmd:*} matches any characters (0 or more){p_end}
{p 8 12 2}- {cmd:?} matches any single character{p_end}
{p 8 12 2}- {cmd:[abc]} matches any character in the set{p_end}
{p 8 12 2}- {cmd:[a-z]} matches any character in the range{p_end}

{p 8 12}{stata "wbopendata, search(NY.GDP.*)" :. wbopendata, search(NY.GDP.*)}{p_end}
{p 8 12}{stata "wbopendata, search(SP.POP.????)" :. wbopendata, search(SP.POP.????)}{p_end}

{pstd}{ul:{bf:Regex mode:}} Prefix with {cmd:~} for full regex syntax:{p_end}

{p 8 12}{stata "wbopendata, search(~^SP\.DYN\..*\.IN$)" :. wbopendata, search(~^SP\.DYN\..*\.IN$)}{p_end}

{pstd}{ul:{bf:Filter by source or topic:}}{p_end}

{p 8 12}{stata "wbopendata, search(GDP) searchsource(2)" :. wbopendata, search(GDP) searchsource(2)}{p_end}
{p 8 12}{stata "wbopendata, search(poverty) searchtopic(11)" :. wbopendata, search(poverty) searchtopic(11)}{p_end}
{p 8 12}{stata "wbopendata, searchsource(2) limit(30)" :. wbopendata, searchsource(2) limit(30)}{p_end}

{pstd}{ul:{bf:Search specific fields:}} The {opt searchfield()} option restricts search to specific metadata fields:{p_end}

{p 8 12 2}- {cmd:code}: indicator code only{p_end}
{p 8 12 2}- {cmd:name}: indicator name only{p_end}
{p 8 12 2}- {cmd:description}: detailed description{p_end}
{p 8 12 2}- {cmd:source}: source organization{p_end}
{p 8 12 2}- {cmd:topic}: topic names{p_end}
{p 8 12 2}- {cmd:note}: methodology notes{p_end}
{p 8 12 2}- {cmd:all}: all fields (default){p_end}

{p 8 12}{stata "wbopendata, search(NY.GDP.*) searchfield(code)" :. wbopendata, search(NY.GDP.*) searchfield(code)}{p_end}
{p 8 12}{stata "wbopendata, search(purchasing power) searchfield(description)" :. wbopendata, search(purchasing power) searchfield(description)}{p_end}

{pstd}Multiple fields can be specified with semicolons:{p_end}

{p 8 12}{stata "wbopendata, search(GDP) searchfield(code;name)" :. wbopendata, search(GDP) searchfield(code;name)}{p_end}

{pstd}{ul:{bf:Display format options:}}{p_end}

{synopt :{opt detail}}Show results in wrapped block format with full indicator names and topic labels (no truncation).{p_end}

{p 8 12}{stata "wbopendata, search(GDP) detail limit(5)" :. wbopendata, search(GDP) detail limit(5)}{p_end}

{pstd}Without {opt detail}, results display in a compact table format where long names are truncated.
Column widths automatically adjust to your terminal's {cmd:linesize}.{p_end}

{pstd}{ul:{bf:Paginating large result sets:}} For larger result sets, {opt limit(#)} controls how many
results are shown per page. Use {opt page(#)} to jump to a specific page; [Prev] / [Next] / page-number
links are rendered below the results only when the output spans more than one page. Result sets with
30 or fewer matches always render on a single page with no pagination controls.{p_end}

{p 8 12}{stata "wbopendata, searchtopic(11) limit(20) page(2)" :. wbopendata, searchtopic(11) limit(20) page(2)}{p_end}
{p 8 12}{stata "wbopendata, search(poverty) limit(10) page(3)" :. wbopendata, search(poverty) limit(10) page(3)}{p_end}

{synopt :{opt exact}}Require exact code match (case-insensitive, no partial matching).{p_end}

{p 8 12}{stata "wbopendata, search(NY.GDP.MKTP.CD) exact" :. wbopendata, search(NY.GDP.MKTP.CD) exact}{p_end}

{pstd}Returns: {cmd:r(n_results)}, {cmd:r(n_displayed)}, {cmd:r(first_code)}, {cmd:r(codes)},
{cmd:r(names)}, {cmd:r(sources)}, {cmd:r(topics)}, {cmd:r(keyword)}, {cmd:r(source_filter)},
{cmd:r(topic_filter)}, {cmd:r(field_filter)}, {cmd:r(cmd)}{p_end}

{dlgtab:Indicator Info}

{synopt :{opt info(code)}}Display detailed metadata for a specific indicator.{p_end}

{pstd}Shows comprehensive indicator metadata in a structured layout:{p_end}

{p 8 12 2}- {bf:Indicator}: Indicator code{p_end}
{p 8 12 2}- {bf:Name}: Full indicator name{p_end}
{p 8 12 2}- {bf:Unit}: Measurement unit (when available){p_end}
{p 8 12 2}- {bf:Source ID}: Numeric source database ID{p_end}
{p 8 12 2}- {bf:Source}: Source database name{p_end}
{p 8 12 2}- {bf:Topic ID(s)}: All topic IDs (semicolon-separated){p_end}
{p 8 12 2}- {bf:Topic(s)}: All topic names (semicolon-separated){p_end}
{p 8 12 2}- {bf:Description}: Full description{p_end}
{p 8 12 2}- {bf:Note}: Methodology note with clickable URLs{p_end}
{p 8 12 2}- {bf:Limited data warning}: Displayed when data availability is limited{p_end}
{p 8 12 2}- {bf:Filters}: Clickable commands to browse related indicators{p_end}
{p 8 12 2}- {bf:Download}: Clickable commands to download data in various formats{p_end}

{pstd}URLs in the Note and Description fields are automatically converted to clickable hyperlinks using SMCL {cmd:{browse}} tags.{p_end}

{p 8 12}{stata "wbopendata, info(NY.GDP.MKTP.CD)" :. wbopendata, info(NY.GDP.MKTP.CD)}{p_end}
{p 8 12}{stata "wbopendata, info(SI.POV.DDAY)" :. wbopendata, info(SI.POV.DDAY)}{p_end}
{p 8 12}{stata "wbopendata, info(SP.POP.TOTL)" :. wbopendata, info(SP.POP.TOTL)}{p_end}

{pstd}Returns: {cmd:r(indicator)}, {cmd:r(name)}, {cmd:r(source_name)}, {cmd:r(source_org)},
{cmd:r(source_id)}, {cmd:r(topics)}, {cmd:r(topic_ids)}, {cmd:r(topic1)}, {cmd:r(topic2)}, {cmd:r(topic3)},
{cmd:r(description)}, {cmd:r(note)}, {cmd:r(unit)}, {cmd:r(limited_data)}, {cmd:r(cmd)}{p_end}

{dlgtab:Discovery Workflow Example}

{pstd}A typical discovery workflow:{p_end}

{p 8 12}1. Browse available sources:{p_end}
{p 8 12}{stata "wbopendata, sources" :. wbopendata, sources}{p_end}

{p 8 12}2. Explore a specific source (World Development Indicators = 2):{p_end}
{p 8 12}{stata "wbopendata, searchsource(2) limit(30)" :. wbopendata, searchsource(2) limit(30)}{p_end}

{p 8 12}3. Search for indicators of interest:{p_end}
{p 8 12}{stata "wbopendata, search(poverty) searchtopic(11)" :. wbopendata, search(poverty) searchtopic(11)}{p_end}

{p 8 12}4. Get detailed info on a specific indicator:{p_end}
{p 8 12}{stata "wbopendata, info(SI.POV.DDAY)" :. wbopendata, info(SI.POV.DDAY)}{p_end}

{p 8 12}5. Download the data:{p_end}
{p 8 12}{stata "wbopendata, indicator(SI.POV.DDAY) clear long" :. wbopendata, indicator(SI.POV.DDAY) clear long}{p_end}


{marker attributes}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:List Country attributes currently supported}

{synoptset 33 tabbed}{...}
{synopthdr: Country attributes}
{synoptline}
{synopt:{opt countrycode}}Country Code{p_end}
{synopt:{opt countryname}}Country Name{p_end}
{synopt:{opt region_iso2}}Region Code (ISO 2 digits){p_end}
{synopt:{opt regionname}}Region Name{p_end}
{synopt:{opt adminregion}}Administrative Region Code{p_end}
{synopt:{opt adminregion_iso2}}Administrative Region Code (ISO 2 digits){p_end}
{synopt:{opt adminregionname}}Administrative Region Name{p_end}
{synopt:{opt incomelevel}}Income Level Code{p_end}
{synopt:{opt incomelevel_iso2}}Income Level Code (ISO 2 digits){p_end}
{synopt:{opt incomelevelname}}Income Level Name{p_end}
{synopt:{opt lendingtype}}Lending Type Code{p_end}
{synopt:{opt region}}Region Code{p_end}
{synopt:{opt lendingtype_iso2}}Lending Type Code (ISO 2 digits){p_end}
{synopt:{opt lendingtypename}}Lending Type Name{p_end}
{synopt:{opt capital}}Capital Name{p_end}
{synopt:{opt latitude}}Capital Latitude{p_end}
{synopt:{opt longitude}}Capital Longitude{p_end}
{synoptline}

{pstd}
{bf:Geographic Attributes:} Capital city information (name, latitude, longitude) is stored in the Stata working path and can be merged using the {opt geo}, {opt capital}, {opt latitude}, or {opt longitude} options. These options work with both data download mode (country, indicator) and merge mode ({opt match()}). When using {opt match()}, specify the 3-digit WDI country code variable for merging. The {opt geo} option is a shortcut that loads all three geographic variables simultaneously.{p_end}


{marker countries}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Country Names and Codes by Groups}

{synoptset 33 tabbed}{...}
{marker region}
{synopthdr: Regions}
{synoptline}
{synopt:{opt NA}}{help wbopendata_region##NA:Aggregates}{p_end}
{synopt:{opt EAS}}{help wbopendata_region##EAS:East Asia and Pacific}{p_end}
{synopt:{opt ECS}}{help wbopendata_region##ECS:Europe and Central Asia}{p_end}
{synopt:{opt LCN}}{help wbopendata_region##LCN:Latin American and the Caribbean}{p_end}
{synopt:{opt MEA}}{help wbopendata_region##MEA:Middle East and North Africa}{p_end}
{synopt:{opt NAC}}{help wbopendata_region##NAC:North America}{p_end}
{synopt:{opt SAS}}{help wbopendata_region##SAS:South Asia}{p_end}
{synopt:{opt SSF}}{help wbopendata_region##SSF:Sub-Saharan Africa}{p_end}
{synoptline}


{marker adminregion}
{synopthdr: Administrative Regions}
{synoptline}
{synopt:{opt EAP}}{help wbopendata_adminregion##EAP:East Asia and Pacific}{p_end}
{synopt:{opt ECA}}{help wbopendata_adminregion##ECA:Europe and Central Asia}{p_end}
{synopt:{opt LAC}}{help wbopendata_adminregion##LAC:Latin American and the Caribbean}{p_end}
{synopt:{opt MNA}}{help wbopendata_adminregion##MNA:Middle East and North Africa}{p_end}
{synopt:{opt SAS}}{help wbopendata_adminregion##SAS:South Asia}{p_end}
{synopt:{opt SSA}}{help wbopendata_adminregion##SSA:Sub-Saharan Africa}{p_end}
{synoptline}


{marker incomelevel}
{synopthdr: Income Level Groups}
{synoptline}
{synopt:{opt NA}}{help wbopendata_incomelevel##NA:Aggregates}{p_end}
{synopt:{opt HIC}}{help wbopendata_incomelevel##HIC:High income}{p_end}
{synopt:{opt UMC}}{help wbopendata_incomelevel##UMC:Upper middle income}{p_end}
{synopt:{opt LMC}}{help wbopendata_incomelevel##LMC:Lower middle income}{p_end}
{synopt:{opt LIC}}{help wbopendata_incomelevel##LIC:Low income}{p_end}
{synoptline}


{marker lendingtype}
{synopthdr: Lending Type Group}
{synoptline}
{synopt:{opt IBD}}{help wbopendata_lendingtype##IBD:IBRD}{p_end}
{synopt:{opt IDX}}{help wbopendata_lendingtype##IDX:IDA}{p_end}
{synopt:{opt IDB}}{help wbopendata_lendingtype##IDB:Blend}{p_end}
{synopt:{opt LNX}}{help wbopendata_lendingtype##LNX:Not classified}{p_end}
{synoptline}


{marker sourceid}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Indicators by Source}

{pstd}
World Bank data is organized across 71 sources (databases). Use the {opt sources}
discovery command to list all sources with indicator counts and clickable navigation:{p_end}

{p 8 12}{stata "wbopendata, sources" :. wbopendata, sources}{p_end}

{pstd}To browse all indicators in a specific source:{p_end}

{p 8 12}{stata "wbopendata, search(*) searchsource(2)" :. wbopendata, search(*) searchsource(2)}{p_end}

{pstd}To search within a source by keyword:{p_end}

{p 8 12}{stata "wbopendata, search(GDP) searchsource(2)" :. wbopendata, search(GDP) searchsource(2)}{p_end}

{pstd}See also: {help wbopendata_sourceid##toc:Source reference list}{p_end}


{marker topic}{marker topicid}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Topic List}

{pstd}
World Bank indicators are classified into 21 thematic topics. Use the {opt alltopics}
discovery command to list all topics with indicator counts and clickable navigation:{p_end}

{p 8 12}{stata "wbopendata, alltopics" :. wbopendata, alltopics}{p_end}

{pstd}To browse all indicators in a specific topic:{p_end}

{p 8 12}{stata "wbopendata, search(*) searchtopic(11)" :. wbopendata, search(*) searchtopic(11)}{p_end}

{pstd}To search within a topic by keyword:{p_end}

{p 8 12}{stata "wbopendata, search(poverty) searchtopic(11)" :. wbopendata, search(poverty) searchtopic(11)}{p_end}

{pstd}See also: {help wbopendata_topicid##toc:Topics reference list}{p_end}


{marker storedresults}{...}
{title:Stored results}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{pstd}
{cmd:wbopendata} is an {help return:r-class} command and stores results in {cmd:r()}.
These stored results are critical for automation: they allow downstream code to 
programmatically access indicator metadata, construct dynamic graph titles, and 
build reproducible pipelines without manual intervention.
Results are organized into macros (text strings) and scalars (numeric values).
See {manhelp return P} for details on stored results conventions.{p_end}

{pstd}{ul:{bf:Indicator codes and variable names}}{p_end}

{pstd}World Bank indicator codes like {cmd:SI.POV.DDAY} contain periods, which Stata does not 
allow in variable names. The command automatically converts indicator codes to Stata-safe 
variable names by replacing periods with underscores and converting to lowercase: 
{cmd:SI.POV.DDAY} becomes {cmd:si_pov_dday}. Both forms are stored: {cmd:r(indicator{it:#})} 
preserves the original API code for documentation and re-querying, while {cmd:r(varname{it:#})} 
provides the Stata variable name for use in analysis commands.{p_end}

{pstd}{ul:{bf:Indexed versus aggregate returns}}{p_end}

{pstd}Results come in two forms. Indexed returns ({cmd:r(varname1)}, {cmd:r(varname2)}, ...) 
store metadata for each indicator separately, enabling indicator-specific labeling and citation. 
Aggregate returns store combined information: {cmd:r(indicator)} contains the full semicolon-separated 
query string as entered, while {cmd:r(name)} contains all variable names as a space-separated list 
suitable for {cmd:foreach} loops or variable lists.{p_end}

{pstd}{ul:{bf:Macros: Aggregate returns (always)}}{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 26 2: Macro}{p_end}
{synoptline}
{synopt:{cmd:r(indicator)}}Full query string (semicolon-separated){p_end}
{synopt:{cmd:r(name)}}All Stata variable names (space-separated){p_end}
{synoptline}

{pstd}{ul:{bf:Macros: Indexed returns (per indicator, always)}}{p_end}

{pstd}For each requested indicator, where {it:#} = 1, 2, ... indexes multiple indicators:{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 26 2: Macro}{p_end}
{synoptline}
{synopt:{cmd:r(indicator{it:#})}}Original API indicator code (e.g., SI.POV.DDAY){p_end}
{synopt:{cmd:r(varname{it:#})}}Stata-safe variable name (e.g., si_pov_dday){p_end}
{synopt:{cmd:r(varlabel{it:#})}}Indicator label (short name) from the API{p_end}
{synopt:{cmd:r(source{it:#})}}Source database identifier{p_end}
{synopt:{cmd:r(time{it:#})}}Time dimension name{p_end}
{synopt:{cmd:r(sourcecite{it:#})}}Clean organization name (when Note is non-empty){p_end}
{synoptline}

{pstd}{ul:{bf:With {opt year()} option}}{p_end}

{pstd}When {opt year()} is specified, the requested year range is stored:{p_end}

{synoptset 22 tabbed}{...}
{p2col 5 22 26 2: Macro}{p_end}
{synoptline}
{synopt:{cmd:r(year{it:#})}}Year or year range requested{p_end}
{synoptline}

{pstd}{ul:{bf:With {opt latest} option}}{p_end}

{pstd}When {opt latest} is specified, additional results summarize the temporal coverage:{p_end}

{synoptset 26 tabbed}{...}
{p2col 5 26 30 2: Result}{p_end}
{synoptline}
{synopt:{cmd:r(latest)}}Formatted subtitle string for graphs{p_end}
{synopt:{cmd:r(latest_ncountries)}}Number of countries with non-missing data{p_end}
{synopt:{cmd:r(latest_avgyear)}}Average year across retained observations{p_end}
{synopt:{cmd:r(latest_year)}}Maximum year among retained observations{p_end}
{synoptline}

{pstd}{ul:{bf:With {opt linewrap()} option}}{p_end}

{pstd}The {opt linewrap()} option generates publication-ready text for graph titles. For each indicator ({it:#} = 1, 2, ...) and each requested field:{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 28 32 2: Macro}{p_end}
{synoptline}
{synopt:{cmd:r(name{it:#}_stack)}}Indicator name, wrapped for use in {opt title()}{p_end}
{synopt:{cmd:r(description{it:#}_stack)}}Full indicator definition, wrapped for captions{p_end}
{synopt:{cmd:r(note{it:#}_stack)}}Wrapped methodological notes{p_end}
{synopt:{cmd:r(source{it:#}_stack)}}Wrapped source text{p_end}
{synopt:{cmd:r(topic{it:#}_stack)}}Wrapped topic name{p_end}
{synoptline}

{pstd}The {cmd:_stack} suffix indicates formatting compatible with Stata's {opt title()} option,
where multiple quoted strings stack vertically: {cmd:"line1" "line2" "line3"}.{p_end}

{pstd}With {opt linewrapformat(all)}, additional formats are returned:{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 28 32 2: Result}{p_end}
{synoptline}
{synopt:{cmd:r({it:field#}_newline)}}Text with embedded newline characters{p_end}
{synopt:{cmd:r({it:field#}_nlines)}}Line count for each field (scalar){p_end}
{synopt:{cmd:r({it:field#}_line1)}, ...}Individual wrapped lines{p_end}
{synoptline}

{pstd}{ul:{bf:Discovery commands stored results}}{p_end}

{pstd}Discovery commands ({opt sources}, {opt alltopics}, {opt search()}, {opt info()})
return metadata for programmatic use and automation.{p_end}

{pstd}{bf:wbopendata, sources}{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 28 32 2: Result}{p_end}
{synoptline}
{synopt:{cmd:r(n_sources)}}Total number of data sources (scalar){p_end}
{synopt:{cmd:r(n_available)}}Sources with data availability flag (scalar){p_end}
{synopt:{cmd:r(n_indicators)}}Total indicator count across all sources (scalar){p_end}
{synopt:{cmd:r(source_codes)}}Space-separated list of source IDs{p_end}
{synopt:{cmd:r(source_names)}}Compound-quoted list of source names{p_end}
{synopt:{cmd:r(cmd)}}Reproducible command string{p_end}
{synoptline}

{pstd}{bf:wbopendata, alltopics}{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 28 32 2: Result}{p_end}
{synoptline}
{synopt:{cmd:r(n_topics)}}Total number of topics (scalar){p_end}
{synopt:{cmd:r(topic_ids)}}Space-separated list of topic IDs{p_end}
{synopt:{cmd:r(topic_names)}}Compound-quoted list of topic names{p_end}
{synopt:{cmd:r(cmd)}}Reproducible command string{p_end}
{synoptline}

{pstd}{bf:wbopendata, search(pattern)}{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 28 32 2: Result}{p_end}
{synoptline}
{synopt:{cmd:r(n_results)}}Total matches found (scalar){p_end}
{synopt:{cmd:r(n_displayed)}}Matches displayed after limit (scalar){p_end}
{synopt:{cmd:r(first_code)}}First matching indicator code{p_end}
{synopt:{cmd:r(codes)}}Space-separated list of indicator codes{p_end}
{synopt:{cmd:r(names)}}Compound-quoted list of indicator names{p_end}
{synopt:{cmd:r(sources)}}Space-separated list of source IDs{p_end}
{synopt:{cmd:r(topics)}}Compound-quoted list of topic names{p_end}
{synopt:{cmd:r(keyword)}}Search keyword used{p_end}
{synopt:{cmd:r(source_filter)}}Source filter if specified{p_end}
{synopt:{cmd:r(topic_filter)}}Topic filter if specified{p_end}
{synopt:{cmd:r(field_filter)}}Field filter if specified{p_end}
{synopt:{cmd:r(cmd)}}Reproducible command string{p_end}
{synoptline}

{pstd}{bf:wbopendata, info(code)}{p_end}

{synoptset 28 tabbed}{...}
{p2col 5 28 32 2: Result}{p_end}
{synoptline}
{synopt:{cmd:r(indicator)}}Indicator code{p_end}
{synopt:{cmd:r(name)}}Indicator name{p_end}
{synopt:{cmd:r(varlabel)}}Variable label (same as name){p_end}
{synopt:{cmd:r(source)}}Collection string (ID + name){p_end}
{synopt:{cmd:r(collection)}}Collection string (ID + name){p_end}
{synopt:{cmd:r(source_id)}}Source database ID{p_end}
{synopt:{cmd:r(source_name)}}Source database name{p_end}
{synopt:{cmd:r(source_org)}}Source organization (detailed attribution){p_end}
{synopt:{cmd:r(sourcecite)}}Source citation (same as source_org){p_end}
{synopt:{cmd:r(topic_ids)}}Semicolon-separated topic IDs{p_end}
{synopt:{cmd:r(topics)}}Semicolon-separated topic names{p_end}
{synopt:{cmd:r(topic1)}}First topic ID{p_end}
{synopt:{cmd:r(topic2)}}Second topic ID (if applicable){p_end}
{synopt:{cmd:r(topic3)}}Third topic ID (if applicable){p_end}
{synopt:{cmd:r(description)}}Full indicator description (plain text){p_end}
{synopt:{cmd:r(note)}}Methodology note (plain text){p_end}
{synopt:{cmd:r(unit)}}Measurement unit{p_end}
{synopt:{cmd:r(limited_data)}}1 if limited data availability, 0 otherwise{p_end}
{synopt:{cmd:r(yaml_path)}}Path to local YAML metadata file{p_end}
{synopt:{cmd:r(cmd)}}Reproducible command string{p_end}
{synoptline}

{pstd}{ul:{bf:Example: Using stored results}}{p_end}

{p 4 4 2}Extract metadata for automated figure annotation. This workflow demonstrates how {cmd:wbopendata} enables fully automated pipelines: the script downloads data, extracts wrapped metadata for the title, and uses the latest-year subtitle---all without hardcoding any text:{p_end}

{cmd}
.     wbopendata, indicator(SI.POV.DDAY) clear long latest linewrap(name note)
.     return list
.     local title `r(name1_stack)'
.     local subtitle "`r(latest)'"
.     local source "Source: `r(sourcecite1)'"
.     twoway line si_pov_dday year if countrycode == "BRA", ///
          title(`title') subtitle("`subtitle'") note("`source'")
{txt}

{p 4 4 2}See {help return} for details on accessing stored results.{p_end}


{marker charmetadata}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Characteristic metadata (v18.1+)}

{pstd}
As of v18.1, {cmd:wbopendata} stores persistent metadata in Stata {help char:variable characteristics}
that survive {cmd:save}/{cmd:use} cycles. This follows the pattern established by
{cmd:freduse} ({it:Drukker, Stata Journal 2006}), making downloaded datasets self-documenting.{p_end}

{pstd}
Three layers of metadata now coexist:{p_end}
{p 8 12 2}1. The {bf:do-file} — authoritative provenance record (unchanged){p_end}
{p 8 12 2}2. {bf:r() returns} — ephemeral session metadata for programmatic use (unchanged){p_end}
{p 8 12 2}3. {bf:char characteristics} — persistent metadata embedded in the .dta file (new){p_end}

{pstd}
Use {opt nochar} to suppress all {cmd:char} writes.{p_end}

{pstd}{ul:{bf:Dataset-level characteristics (_dta)}}{p_end}

{pstd}Set once per download. These capture the session context:{p_end}

{synoptset 30 tabbed}{...}
{p2col 5 30 34 2: Characteristic}{p_end}
{synoptline}
{synopt:{cmd:_dta[wbopendata_version]}}Package version (e.g., 18.1.1){p_end}
{synopt:{cmd:_dta[wbopendata_timestamp]}}Date and time of download{p_end}
{synopt:{cmd:_dta[wbopendata_user]}}Stata username at download time{p_end}
{synopt:{cmd:_dta[wbopendata_syntax]}}Exact command syntax used{p_end}
{synopt:{cmd:_dta[wbopendata_indicator]}}Indicator code(s) requested{p_end}
{synopt:{cmd:_dta[wbopendata_country]}}Country filter (if any){p_end}
{synopt:{cmd:_dta[wbopendata_language]}}Language (en/es/fr){p_end}
{synopt:{cmd:_dta[wbopendata_source_id]}}Source database filter (if any){p_end}
{synopt:{cmd:_dta[wbopendata_topics]}}Topic filter (if any){p_end}
{synoptline}

{pstd}{ul:{bf:Variable-level characteristics (per indicator)}}{p_end}

{pstd}Each indicator variable carries its own metadata:{p_end}

{synoptset 30 tabbed}{...}
{p2col 5 30 34 2: Characteristic}{p_end}
{synoptline}
{synopt:{cmd:{it:varname}[indicator]}}Original indicator code (e.g., NY.GDP.MKTP.CD){p_end}
{synopt:{cmd:{it:varname}[source]}}Source database name{p_end}
{synopt:{cmd:{it:varname}[description]}}Indicator description{p_end}
{synopt:{cmd:{it:varname}[topic]}}Topic classification(s){p_end}
{synopt:{cmd:{it:varname}[note]}}Methodological notes{p_end}
{synopt:{cmd:{it:varname}[sourcecite]}}Source organization citation{p_end}
{synoptline}

{pstd}{ul:{bf:Example}}{p_end}

{cmd}
.     wbopendata, indicator(NY.GDP.MKTP.CD) clear long
.     char list _dta[]
.     char list ny_gdp_mktp_cd[]
.
.     * Access specific metadata programmatically:
.     local desc : char ny_gdp_mktp_cd[description]
.     display "`desc'"
.
.     * Suppress all char metadata:
.     wbopendata, indicator(NY.GDP.MKTP.CD) nochar clear long
.     char list _dta[]        // empty
{txt}


{marker deprecated}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Deprecated options}

{pstd}
The following options have been deprecated and will be removed in a future release.
They continue to function for backward compatibility but issue a warning when used.{p_end}

{synoptset 30 tabbed}{...}
{p2col 5 30 34 2: Option}Description{p_end}
{synoptline}
{synopt:{cmd:update query}}Replaced by {opt sync}.  Use {cmd:sync} to preview
metadata changes (dry run); use {cmd:checkupdate} to check version.{p_end}
{synopt:{cmd:update check}}Replaced by {opt checkupdate}.{p_end}
{synopt:{cmd:update all}}Replaced by {opt sync replace}.  Downloads latest YAML
metadata from GitHub.{p_end}
{synopt:{cmd:metadataoffline}}Replaced by {opt sync replace} + {opt sources}/{opt search()}/{opt info()}.
Previously generated 71 local {cmd:.sthlp} files (~15 MB). The YAML metadata
architecture (v18.0) provides the same content via discovery commands without
creating per-indicator help files.{p_end}
{synopt:{cmd:syncforce}}Replaced by {opt sync replace force}.{p_end}
{synopt:{cmd:syncpreview}}Replaced by {opt sync replace}.{p_end}
{synopt:{cmd:syncdryrun}}Replaced by {opt sync} (dry run is now the default).{p_end}
{synoptline}

{pstd}
{ul:{bf:Removed files}} (v18.0): 89 per-indicator {cmd:.sthlp} files
({cmd:wbopendata_sourceid_indicators*.sthlp} and {cmd:wbopendata_topicid_indicators*.sthlp})
have been replaced by 2 YAML metadata files serving ~29,000 indicators via the
{opt sources}, {opt alltopics}, {opt search()}, and {opt info()} commands.{p_end}


{marker Examples}{...}
{title:Examples}{p 50 20 2}{p_end}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{pstd}

{pstd}{ul:{bf:Discovery Commands (v17.8+)}}{p_end}

{p 8 12}{stata "wbopendata, sources" :. wbopendata, sources}{p_end}

{p 8 12}{stata "wbopendata, alltopics" :. wbopendata, alltopics}{p_end}

{p 8 12}{stata "wbopendata, search(GDP)" :. wbopendata, search(GDP)}{p_end}

{p 8 12}{stata "wbopendata, search(poverty) searchtopic(11)" :. wbopendata, search(poverty) searchtopic(11)}{p_end}

{p 8 12}{stata "wbopendata, search(learning+poverty)" :. wbopendata, search(learning+poverty)}{p_end}

{p 8 12}{stata "wbopendata, search(NY.GDP.*) searchfield(code)" :. wbopendata, search(NY.GDP.*) searchfield(code)}{p_end}

{p 8 12}{stata "wbopendata, searchsource(2) limit(30) detail" :. wbopendata, searchsource(2) limit(30) detail}{p_end}

{p 8 12}{stata "wbopendata, info(SI.POV.DDAY)" :. wbopendata, info(SI.POV.DDAY)}{p_end}

{pstd}{ul:{bf:Data Download Commands}}{p_end}

{p 8 12}{stata "wbopendata, country(chn - China) clear" :. wbopendata, country(chn - China) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear" :. wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) indicator(SP.POP.TOTL - Population, total) clear" :. wbopendata, language(en - English) indicator(SP.POP.TOTL - Population, total) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) indicator(SP.POP.TOTL - Population, total) long clear" :. wbopendata, language(en - English) indicator(SP.POP.TOTL - Population, total) long clear}{p_end}

{p 8 12}{stata "wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear" :. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.1014.FE; SP.POP.1014.MA) year(1990:2050) projection clear" :. wbopendata, indicator(SP.POP.1014.FE; SP.POP.1014.MA) year(1990:2050) projection clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long": . wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long}{p_end}

{p 8 12}{stata "wbopendata, indicator(SI.POV.DDAY) geo clear" :. wbopendata, indicator(SI.POV.DDAY) geo clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.TOTL) capital clear" :. wbopendata, indicator(SP.POP.TOTL) capital clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(NY.GDP.PCAP.KD) full geo clear" :. wbopendata, indicator(NY.GDP.PCAP.KD) full geo clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long clear" :. wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long clear} (default: includes basic country context){p_end}

{p 8 12}{stata "wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long nobasic clear" :. wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long nobasic clear} (no country metadata){p_end}

{pstd}{ul:{bf:Example: Geographic Metadata}}{p_end}

{cmd}
	. wbopendata, indicator(SP.POP.TOTL) clear
	. wbopendata, indicator(SP.POP.TOTL) geo clear
	. describe capital latitude longitude
{txt}      ({stata "wbopendata_examples example_geo":click to run})
 
{cmd}
        . tempfile tmp
        . wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest
        . sort countrycode
        . save `tmp', replace
        . sysuse world-d, clear
        . merge countrycode using `tmp'
        . sum year
        . local avg = string(`r(mean)',"%16.1f")
        . spmap  it_cel_sets_p2 using "world-c.dta", id(_ID)                                  ///
                clnumber(20) fcolor(Reds2) ocolor(none ..)                                  ///
                title("Mobile cellular subscriptions (per 100 people)", size(*1.2))         ///
                legstyle(3) legend(ring(1) position(3))                                     ///
                note("Source: World Development Indicators (latest available year: `avg') using ///
                Azevedo, J.P. (2026) wbopendata: Stata module to " "access World Bank databases, ///
                Statistical Software Components S457234 Boston College Department of Economics.", ///
				size(*.7))
{txt}      ({stata "wbopendata_examples example01":click to run})

{cmd}
        . wbopendata, indicator(si.pov.dday ) clear long
        . drop if  si_pov_dday == .
        . sort  countryname year
        . bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
        . encode region, gen(reg)
        . encode countryname, gen(reg2)
        . alorenz diff_pov, gp points(100) fullview  xdecrease markvar(reg2)  ///                                         
            ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional ///
            episodes of poverty reduction (%)") legend(off) title("Poverty Reduction") ///
        	mlabelangle(45)	legend(off)	///
			note("Source: World Development Indicators using Azevedo, J.P. (2026) ///
            wbopendata: Stata module to " "access World Bank databases, Statistical ///
            Software Components S457234 Boston College Department of Economics.", ///
			size(*.7))
{txt}      ({stata "wbopendata_examples example02":click to run})

{cmd}
        . wbopendata, indicator(si.pov.dday ) clear long
        . drop if  si_pov_dday == .
        . sort  countryname year
        . keep if regionname == "Aggregates"
        . bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
        . gen baseline = si_pov_dday if year == 1990
        . sort countryname baseline
        . bysort countryname : replace baseline = baseline[1] if baseline == .
        . gen mdg1 = baseline/2
        . gen present = si_pov_dday if year == 2008
        . sort countryname present
        . bysort countryname : replace present = present[1] if present == .
        . gen target = ((baseline-mdg1)/(2008-1990))*(2015-1990)
        . sort countryname year
        . gen angel45x = .
        . gen angle45y = .
        . replace angel45x = 0 in 1
        . replace angle45y = 0 in 1
        . replace angel45x = 80 in 2
        . replace angle45y = 80 in 2
        . graph twoway ///
               (scatter present  target  if year == 2008, mlabel( countrycode))    ///
               (line  angle45y angel45x ),                                         ///
                   legend(off) xtitle("Target for 2008")  ytitle(Present)          ///
                   title("MDG 1 - 1.9 USD")                                         ///
                   note("Source: World Development Indicators (latest available year: 2008) ///
                   using Azevedo, J.P. (2026) wbopendata: Stata module to " "access ///
                   World Bank databases, Statistical Software Components S457234 Boston ///
                   College Department of Economics.", size(*.7))
{txt}      ({stata "wbopendata_examples example03":click to run})


{cmd}
       . wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

       . graph twoway ///
           (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.6)) ///
           (scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8) ///
           mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
           (lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
               xtitle("GDP per capita, PPP (constant 2011 international $)") ///
               ytitle("Poverty headcount ratio at the International Poverty Line") ///
               mlabelangle(45)	legend(off) ///
               note("Source: World Development Indicators (latest available year as off 2012-08-08) ///
               using Azevedo, J.P. (2026) wbopendata: Stata module to " "access World Bank databases, ///
               Statistical Software Components S457234 Boston College Department of Economics.", /// 
               size(*.7))

{txt}      ({stata "wbopendata_examples example04":click to run})

{cmd}
.     sysuse world-d, clear
.     wbopendata, match(countrycode) 
.     keep countrycode countryname adminregion incomelevel area perimeter 
.     list in 1/5

{txt}      ({stata "wbopendata_examples example05":click to run})

{pstd}{ul:{bf:Example 6: Using linewrap for graph titles}}{p_end}

{p 4 4 2}Download indicator with linewrap option to create graph-ready titles:{p_end}

{cmd}
.     wbopendata, indicator(SI.POV.DDAY) clear long linewrap(name) maxlength(45)
.     return list
.     * Use wrapped title in graph
.     twoway line si_pov_dday year if countrycode == "BRA", ///
           title(`r(name1_stack)') ///
           subtitle("Brazil") ///
           ytitle("% of population")
{txt}      ({stata "wbopendata_examples example_linewrap":click to run})

{p 4 4 2}Use different maxlength values for different fields:{p_end}

{cmd}
.     wbopendata, indicator(SI.POV.DDAY) clear long ///
          linewrap(name description note) maxlength(40 100 80)
.     * name wraps at 40 chars, description at 100, note at 80

{p 4 4 2}Use sourcecite for clean source attribution with multiple indicators:{p_end}

{cmd}
.     wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest linewrap(name)
.     local xtit `"`r(name1_stack)'"'
.     local ytit `"`r(name2_stack)'"'
.     twoway scatter sh_dyn_mort si_pov_dday, ///
           xtitle(`xtit') ytitle(`ytit') ///
           note("Sources: `r(sourcecite1)'; `r(sourcecite2)'")

{p 4 4 2}Use dynamic subtitle showing country count and average year:{p_end}

{cmd}
.     wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
          linewrap(name description) maxlength(40 180)
.     local subtitle "`r(latest)'"
.     twoway scatter sh_dyn_mort si_pov_dday, ///
           title("Poverty and Child Mortality") ///
           subtitle("`subtitle'") ///
           note("Sources: `r(sourcecite1)'; `r(sourcecite2)'")
.     * subtitle displays: "Latest Available Year, 186 Countries (avg year 2019.6)"

{pstd}{ul:{bf:Example 7: Default basic country context variables (v17.7)}}{p_end}

{p 4 4 2}As of v17.7, wbopendata adds 8 basic country context variables by default: region, regionname, adminregion, adminregionname, incomelevel, incomelevelname, lendingtype, lendingtypename. Use {opt nobasic} to suppress them:{p_end}

{cmd}
.     * Default behavior - includes basic context variables
.     wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long clear
.     describe, short   // Shows 12 variables
.     
.     * Suppress basic variables with nobasic
.     wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long nobasic clear  
.     describe, short   // Shows 4 variables
{txt}      ({stata "wbopendata_examples example_basic":click to run})

{pstd}{ul:{bf:Example 8: Manage cached YAML metadata (v18.x)}}{p_end}

{p 4 4 2}Preview metadata status (dry run — safe default):{p_end}

{p 8 12}{stata "wbopendata, sync" :. wbopendata, sync}{p_end}
{p 8 12}{stata "wbopendata, sync detail" :. wbopendata, sync detail}{p_end}

{p 4 4 2}Check for updates:{p_end}

{p 8 12}{stata "wbopendata, checkupdate" :. wbopendata, checkupdate}{p_end}

{p 4 4 2}Apply metadata sync (download latest from GitHub):{p_end}

{p 8 12}{stata "wbopendata, sync replace" :. wbopendata, sync replace}{p_end}

{p 4 4 2}Force re-download even when versions match:{p_end}

{p 8 12}{stata "wbopendata, sync replace force" :. wbopendata, sync replace force}{p_end}
{p 8 12}{stata "wbopendata, cacheinfo" :. wbopendata, cacheinfo}{p_end}

{p 4 4 2}Clear cached files and metadata when you need a clean slate:{p_end}

{p 8 12}{stata "wbopendata, clearcache" :. wbopendata, clearcache}{p_end}

{pstd}{ul:{bf:Example 9: Data response cache (v18.2+)}}{p_end}

{p 4 4 2}First download hits the API; second download is served from the local cache:{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.TOTL) clear" :. wbopendata, indicator(SP.POP.TOTL) clear}{p_end}
{p 8 12}(first call downloads from World Bank API; repeat call uses cached data){p_end}

{p 4 4 2}Force a fresh download, bypassing the cache:{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.TOTL) clear nocache" :. wbopendata, indicator(SP.POP.TOTL) clear nocache}{p_end}

{p 4 4 2}Clear all cached data files:{p_end}

{p 8 12}{stata "wbopendata, cleardatacache" :. wbopendata, cleardatacache}{p_end}

{p 4 4 2}Expire all cached entries (files kept, re-fetched on next query):{p_end}

{p 8 12}{stata "wbopendata, resetdatacache" :. wbopendata, resetdatacache}{p_end}

{p 4 4 2}Keep cached data for 30 days instead of the default 7:{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.TOTL) clear cachedays(30)" :. wbopendata, indicator(SP.POP.TOTL) clear cachedays(30)}{p_end}

{p 4 4 2}Show diagnostic messages during cache lookups and API queries:{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.TOTL) clear verbose" :. wbopendata, indicator(SP.POP.TOTL) clear verbose}{p_end}

{marker disclaimer}{...}
{title:Disclaimer}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{p 4 4 2}Users should not use {cmd:wbopendata} without checking first for more detailed information on the 
definitions of each {browse "http://data.worldbank.org/indicator/":indicator} 
and {browse "http://data.worldbank.org/data-catalog/":data-catalogues} . The indicators names and codes used 
by {cmd:wbopendata} are precisely the same used in the World Bank data catalogue in order to facilitate such 
cross reference.{p_end}

{p 4 4 2}When downloading specific series, through the indicator options, {cmd:wbopendata} will by default display in the Stata results window the metadata available for this 
particular series, including information on the name of the series, the source, a detailed description of the indicator, and the organization 
responsible for compiling this indicator.{p_end}

{marker termsofuse}{...}
{title:Terms of use {cmd:World Bank Data}}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{p 8 12 2}The use of World Bank datasets listed in the Data Catalog is governed by a specific 
{browse "http://data.worldbank.org/summary-terms-of-use/":Terms of Use for World Bank Data}. 
The terms of use of the APIs is governed by {browse "http://go.worldbank.org/C09SUA7BK0/":the World Bank Terms and Conditions}.{p_end}


{marker howtocite}{...}
{title:Thanks for citing {cmd:wbopendata} as follows}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{p 8 12 2}Azevedo, Jo\~{a}o Pedro (2011). "WBOPENDATA: Stata module to access World Bank databases." Statistical Software Components S457234, Boston College Department of Economics. {browse "https://ideas.repec.org/c/boc/bocode/s457234.html"}.{p_end}

{p 8 12 2}For version 17.7.1+ with graph metadata features:{p_end}
{p 8 12 2}Azevedo, Jo\~{a}o Pedro (2026). "wbopendata: Fifteen Years of Programmatic Access to World Bank Open Data." Mimeo.{p_end}

{p 8 12 2}Please make reference to the date when the database was downloaded, as indicator values and availability may change.{p_end}


{marker references}{...}
{title:References}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

    {p 4 4 2}Azevedo, Jo\~{a}o Pedro (2026). "wbopendata: Fifteen Years of Programmatic Access to World Bank Open Data." Mimeo.{p_end}

    {p 4 4 2}Azevedo, Jo\~{a}o Pedro (2026). "unicefdata: Unified access to UNICEF indicators across R, Python, and Stata." UNICEF Chief Statistician Office. {browse "https://github.com/unicef-drp/unicefdata"}.{p_end}

    {p 4 4 2}Drukker, David M. (2006). "Importing Federal Reserve economic data." The Stata Journal, 6(3), 384-386.{p_end}

    {p 4 4 2}David C. Elliott, 2002. "TKNZ: Stata module to tokenize string into named macros," Statistical Software Components
S426302, Boston College Department of Economics, revised 17 Oct 2006.{p_end}

    {p 4 4 2}Gould, William (2001). "Statistical software certification." The Stata Journal, 1(1), 29-50.{p_end}

{marker acknowled}{...}
{title:Acknowledgements}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

    {p 4 4 2}This program was developed by Joao Pedro Azevedo.{p_end} 
    {p 4 4 2}A special thanks to the World Bank API team, in particular, Malarvizhi Veerappan, Lakshmikanthan Subramanian, Shanmugam Natarajan, Ugendran Machakkalai, Rochelle Glenene O'Hagan, Timothy Grant Herzog, 
	and Ana Florina Pirlea.{p_end}
    {p 4 4 2}The author would like to thanks comments received from Minh Cong Nguyen, John Luke Gallup, Aart C. Kraay, Amer Hasan, Johan Mistiaen, Roy Shuji Katayama, Dean Mitchell Jolliffe, Nobuo Yoshida,
    Manohar Sharma, Gabriel Demombynes, Paolo Verme, Elizaveta Perova, Kit Baum, Kerry Kammire, Derek Wagner, Neil Fantom and Loiuse J. Cord. The usual disclaimer applies.{p_end}

{p 4 4 2}{bf:Community Contributors:} The following users have contributed valuable bug reports, feature suggestions, and feedback that helped improve wbopendata:{p_end}
    {p 8 8 2}{it:Bug Reports & Fixes:} dianagold, claradaia, SylWeber, cuannzy, oliverfiala, KarstenKohler, ckrf, flxflks, Koko-Clovis, tenaciouslyantediluvian{p_end}
    {p 8 8 2}{it:Feature Suggestions:} santoshceft, Shijie-Shi, JavierParada, yukinko-iwasaki{p_end}
    {p 4 4 2}Thank you all for helping make wbopendata better!{p_end}

    {p 4 4 2}I would like to dedicate this ado file to Dr Richard Sperling, who asked us to support intelligent and well 
    thought out public policies that help those in society who are less fortunate than we are. {browse "www.stata.com/statalist/archive/2011-02/msg00062.html"}{p_end}
    {p 4 4 2}{cmd:wbopendata} uses the Stata user written command {cmd:_pecats} produced by J. Scott Long and Jeremy Freese, {cmd:tknz} written by David C. Elliott and 
    Nick Cox, and {cmd:_linewrap} (based on {cmd:linewrap} v2.1 by Mead Over & Joao Pedro Azevedo) for formatting graph footnotes in example files.{p_end} 
       
{title:Author}

    {p 4 4 2}Jo\~{a}o Pedro Azevedo{p_end}
    {p 4 4 2}Deputy Director and Chief Statistician{p_end}
    {p 4 4 2}UNICEF, Division of Data, Analytics, Planning and Monitoring{p_end}
    {p 4 4 2}{browse "https://jpazvd.github.io"}{p_end}

{title:GitHub Repository}

{p 4 4 2}For previous releases and additional examples please visit wbopendata {browse "https://github.com/jpazvd/wbopendata" :GitHub Repo}{p_end}

{p 4 4 2}Please make any enhancement suggestions and/or report any problems with wbopendata at {browse "https://github.com/jpazvd/wbopendata/issues" :Issues and Suggestions page}{p_end}

{title:Also see}

{psee}
Online: {helpb linewrap} {helpb alorenz} {helpb spmap} {helpb tknz} (if installed)
{p_end}
