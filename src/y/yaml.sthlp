{smcl}
{* *! version 1.3.0  04Dec2025}{...}
{viewerjumpto "Syntax" "yaml##syntax"}{...}
{viewerjumpto "Description" "yaml##description"}{...}
{viewerjumpto "Subcommands" "yaml##subcommands"}{...}
{viewerjumpto "Options" "yaml##options"}{...}
{viewerjumpto "Examples" "yaml##examples"}{...}
{viewerjumpto "Stored results" "yaml##results"}{...}
{viewerjumpto "Author" "yaml##author"}{...}

{title:Title}

{phang}
{bf:yaml} {hline 2} Read and write YAML files in Stata


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:yaml} {it:subcommand} [{cmd:using} {it:filename}] [{cmd:,} {it:options}]


{marker subcommands}{...}
{title:Subcommands}

{synoptset 16 tabbed}{...}
{synopthdr:subcommand}
{synoptline}
{synopt:{opt read}}read YAML file into current dataset (default) or frame{p_end}
{synopt:{opt write}}write Stata data to YAML file{p_end}
{synopt:{opt describe}}display structure of loaded YAML data{p_end}
{synopt:{opt list}}list keys and values{p_end}
{synopt:{opt get}}get metadata attributes for a specific key{p_end}
{synopt:{opt validate}}validate YAML data against requirements{p_end}
{synopt:{opt dir}}list all YAML data in memory (dataset and frames){p_end}
{synopt:{opt frames}}list only YAML frames in memory (Stata 16+){p_end}
{synopt:{opt clear}}clear YAML data from memory{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:yaml} provides a unified interface for working with YAML files in Stata.
YAML (YAML Ain't Markup Language) is a human-readable data serialization format 
commonly used for configuration files and data exchange.

{pstd}
{bf:Default behavior:} YAML data is loaded into the {bf:current dataset}.
This allows the command to work with Stata 14 and later.

{pstd}
{bf:Frame option:} Use {opt frame(name)} to store YAML data in a separate Stata
frame, allowing multiple YAML files in memory simultaneously. This requires
Stata 16 or later.


{marker read}{...}
{title:yaml read}

{p 8 17 2}
{cmd:yaml read}
{cmd:using} {it:filename}
[{cmd:,} {opt frame(name)} {opt l:ocals} {opt s:calars} {opt p:refix(string)} {opt replace} {opt v:erbose}]

{pstd}
Reads a YAML file and parses its contents into the current dataset (default) or a frame.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt frame(name)}}load into frame yaml_{it:name} instead of dataset (Stata 16+){p_end}
{synopt:{opt l:ocals}}also store values as local macros in r(){p_end}
{synopt:{opt s:calars}}also store numeric values as Stata scalars{p_end}
{synopt:{opt p:refix(string)}}prefix for macro/scalar names; default is "yaml_"{p_end}
{synopt:{opt replace}}replace existing data in memory{p_end}
{synopt:{opt v:erbose}}display parsing progress{p_end}
{synoptline}

{pstd}
The following variables are created:
{p_end}
{phang2}{cmd:key} - Full key name (nested keys use underscore separator){p_end}
{phang2}{cmd:value} - Value as string{p_end}
{phang2}{cmd:level} - Nesting level (1 = root){p_end}
{phang2}{cmd:parent} - Parent key name{p_end}
{phang2}{cmd:type} - Value type (string, numeric, boolean, null, parent){p_end}


{marker write}{...}
{title:yaml write}

{p 8 17 2}
{cmd:yaml write}
{cmd:using} {it:filename}
[{cmd:,} {opt frame(name)} {opt scalars(namelist)} 
{opt replace} {opt v:erbose} {opt indent(#)} {opt header(string)}]

{pstd}
Writes Stata data from the current dataset (default) or a frame to a YAML file.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt frame(name)}}write from frame yaml_{it:name} (Stata 16+){p_end}
{synopt:{opt scalars(namelist)}}write specified scalars{p_end}
{synopt:{opt replace}}replace existing file{p_end}
{synopt:{opt v:erbose}}display progress{p_end}
{synopt:{opt indent(#)}}spaces per indent level; default is 2{p_end}
{synopt:{opt header(string)}}custom header comment{p_end}
{synoptline}

{pstd}
{bf:Note:} To write scalar values to YAML, create scalars first, then use the {opt scalars()} option.
Local macros cannot be passed to programs in Stata.


{marker describe}{...}
{title:yaml describe}

{p 8 17 2}
{cmd:yaml describe}
[{cmd:,} {opt frame(name)} {opt level(#)}]

{pstd}
Displays the structure of YAML data in the current dataset (default) or a frame.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt frame(name)}}describe frame yaml_{it:name} (Stata 16+){p_end}
{synopt:{opt level(#)}}maximum nesting level to display; default is all{p_end}
{synoptline}


{marker list}{...}
{title:yaml list}

{p 8 17 2}
{cmd:yaml list}
[{it:parent}]
[{cmd:,} {opt frame(name)} {opt keys} {opt values} {opt sep:arator(string)} {opt child:ren} {opt stata} {opt noh:eader}]

{pstd}
Lists keys and values from YAML data. Optional {it:parent} filters to keys under that parent.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt frame(name)}}list from frame yaml_{it:name} (Stata 16+){p_end}
{synopt:{opt keys}}return matching keys as delimited list in r(keys){p_end}
{synopt:{opt values}}return matching values as delimited list in r(values){p_end}
{synopt:{opt sep:arator(string)}}delimiter for lists; default is space{p_end}
{synopt:{opt child:ren}}return only immediate children of parent{p_end}
{synopt:{opt stata}}format output as Stata compound quotes: {cmd:`"item1"' `"item2"'}{p_end}
{synopt:{opt noh:eader}}suppress column headers in listing{p_end}
{synoptline}


{marker get}{...}
{title:yaml get}

{p 8 17 2}
{cmd:yaml get}
{it:parent}{cmd::}{it:keyname} | {it:keyname}
[{cmd:,} {opt frame(name)} {opt attr:ibutes(namelist)} {opt q:uiet}]

{pstd}
Gets metadata attributes for a specific key (e.g., indicator code) and returns them
as separate r() macros. This is useful for querying indicator metadata by code.

{pstd}
{bf:Colon syntax:} Use {it:parent}{cmd::}{it:keyname} to specify the parent hierarchy.
For example, {cmd:indicators:CME_MRY0T4} searches for CME_MRY0T4 under indicators.
This is equivalent to searching for key {cmd:indicators_CME_MRY0T4_*}.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt frame(name)}}get from frame yaml_{it:name} (Stata 16+){p_end}
{synopt:{opt attr:ibutes(namelist)}}specific attributes to retrieve; default is all{p_end}
{synopt:{opt q:uiet}}suppress output display{p_end}
{synoptline}

{pstd}
{bf:Stored results:}
{p_end}
{phang2}{cmd:r(key)} - the key that was searched{p_end}
{phang2}{cmd:r(parent)} - the parent hierarchy (if colon syntax used){p_end}
{phang2}{cmd:r(found)} - 1 if attributes found, 0 otherwise{p_end}
{phang2}{cmd:r(n_attrs)} - number of attributes found{p_end}
{phang2}{cmd:r({it:attribute})} - value for each attribute found (e.g., r(label), r(unit)){p_end}


{marker dir}{...}
{title:yaml dir}

{p 8 17 2}
{cmd:yaml dir}
[{cmd:,} {opt det:ail}]

{pstd}
Lists all YAML data currently loaded in memory. This includes both the current 
dataset (if it contains YAML data) and any YAML frames (Stata 16+).

{pstd}
YAML data is identified by:
{p_end}
{phang2}1. Presence of standard YAML variables: {cmd:key}, {cmd:value}, {cmd:level}, {cmd:parent}, {cmd:type}{p_end}
{phang2}2. The {cmd:_dta[yaml_source]} characteristic set by {cmd:yaml read}{p_end}
{phang2}3. Frame names with {cmd:yaml_} prefix (for frames){p_end}

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt det:ail}}show number of entries and source file for each{p_end}
{synoptline}

{pstd}
{bf:Stored results:}
{p_end}
{phang2}{cmd:r(n_total)} - total number of YAML sources in memory{p_end}
{phang2}{cmd:r(n_dataset)} - 1 if YAML data in current dataset, 0 otherwise{p_end}
{phang2}{cmd:r(n_frames)} - number of YAML frames loaded{p_end}


{marker frames}{...}
{title:yaml frames}

{p 8 17 2}
{cmd:yaml frames}
[{cmd:,} {opt det:ail}]

{pstd}
Lists only YAML frames currently loaded in memory. Requires Stata 16+.
Use {cmd:yaml dir} to see both the current dataset and frames.

{pstd}
YAML frames are identified by the {cmd:yaml_} prefix in their frame name.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt det:ail}}show number of entries and source file for each frame{p_end}
{synoptline}

{pstd}
{bf:Stored results:}
{p_end}
{phang2}{cmd:r(n_frames)} - number of YAML frames loaded{p_end}


{marker clear}{...}
{title:yaml clear}

{p 8 17 2}
{cmd:yaml clear}
[{it:framename}]
[{cmd:,} {opt all}]

{pstd}
Clears YAML data from memory.

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:(no argument)}clear current dataset (default){p_end}
{synopt:{it:framename}}clear specific frame yaml_{it:framename} (Stata 16+){p_end}
{synopt:{opt all}}clear all yaml_* frames (Stata 16+){p_end}
{synoptline}


{marker examples}{...}
{title:Examples}

{pstd}
{bf:Example YAML file (config.yaml):}{p_end}

{phang2}{cmd:name: My Project}{p_end}
{phang2}{cmd:version: 1.0}{p_end}
{phang2}{cmd:indicators:}{p_end}
{phang2}{cmd:  CME_MRY0T4:}{p_end}
{phang2}{cmd:    label: Under-5 mortality rate}{p_end}
{phang2}{cmd:    unit: deaths per 1000 live births}{p_end}
{phang2}{cmd:  CME_MRY0:}{p_end}
{phang2}{cmd:    label: Neonatal mortality rate}{p_end}
{phang2}{cmd:    unit: deaths per 1000 live births}{p_end}

{pstd}
{bf:Example 1: Read YAML into current dataset (default)}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", replace}{p_end}

{pstd}
{bf:Example 2: Read YAML into a frame (Stata 16+)}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", frame(config)}{p_end}
{phang2}// Creates frame yaml_config, preserves current dataset{p_end}

{pstd}
{bf:Example 3: Work with multiple YAML files using frames}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", frame(cfg)}{p_end}
{phang2}{cmd:. yaml read using "settings.yaml", frame(settings)}{p_end}
{phang2}{cmd:. yaml frames, detail}{p_end}
{phang2}{res:  1. cfg (12 entries) - frame: yaml_cfg}{p_end}
{phang2}{res:  2. settings (8 entries) - frame: yaml_settings}{p_end}

{pstd}
{bf:Example 4: Get indicator codes for looping}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", replace}{p_end}
{phang2}{cmd:. yaml list indicators, keys children}{p_end}
{phang2}{res:Keys under indicators: CME_MRY0T4 CME_MRY0}{p_end}
{phang2}{cmd:. foreach ind in `r(keys)' {c -(}}{p_end}
{phang2}{cmd:.     display "Processing: `ind'"}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

{pstd}
{bf:Example 5: Get values with Stata compound quotes}{p_end}

{phang2}{cmd:. yaml list indicators, keys children stata}{p_end}
{phang2}{res:Keys under indicators: `"CME_MRY0T4"' `"CME_MRY0"'}{p_end}
{phang2}{cmd:. foreach ind in `r(keys)' {c -(}}{p_end}
{phang2}{cmd:.     display "Processing: `ind'"}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

{pstd}
{bf:Example 6: Get indicator metadata by code (colon syntax)}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", replace}{p_end}
{phang2}{cmd:. yaml get indicators:CME_MRY0T4}{p_end}
{phang2}{res:  label: Under-five mortality rate}{p_end}
{phang2}{res:  unit: Deaths per 1000 live births}{p_end}
{phang2}{res:  dataflow: CME}{p_end}
{phang2}{cmd:. return list}{p_end}
{phang2}{res:r(key) : "CME_MRY0T4"}{p_end}
{phang2}{res:r(parent) : "indicators"}{p_end}
{phang2}{res:r(label) : "Under-five mortality rate"}{p_end}
{phang2}{res:r(unit) : "Deaths per 1000 live births"}{p_end}
{phang2}{res:r(dataflow) : "CME"}{p_end}

{pstd}
{bf:Example 7: Get specific attributes only}{p_end}

{phang2}{cmd:. yaml get indicators:CME_MRY0T4, attributes(label unit)}{p_end}
{phang2}{res:  label: Under-five mortality rate}{p_end}
{phang2}{res:  unit: Deaths per 1000 live births}{p_end}

{pstd}
{bf:Example 8: Loop over indicators and get metadata}{p_end}

{phang2}{cmd:. yaml list indicators, keys children}{p_end}
{phang2}{cmd:. foreach ind in `r(keys)' {c -(}}{p_end}
{phang2}{cmd:.     yaml get indicators:`ind', quiet}{p_end}
{phang2}{cmd:.     display "`ind': `r(label)' (`r(unit)')"}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

{pstd}
{bf:Example 9: Query from frame}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", frame(cfg)}{p_end}
{phang2}{cmd:. yaml get indicators:CME_MRY0, frame(cfg)}{p_end}
{phang2}{res:  label: Infant mortality rate}{p_end}
{phang2}{res:  unit: Deaths per 1000 live births}{p_end}
{phang2}{res:  dataflow: CME}{p_end}

{pstd}
{bf:Example 10: Write from dataset to YAML}{p_end}

{phang2}{cmd:. yaml write using "output.yaml", replace}{p_end}

{pstd}
{bf:Example 11: Clear YAML data}{p_end}

{phang2}{cmd:. yaml clear}{p_end}
{phang2}// Clears current dataset{p_end}
{phang2}{cmd:. yaml clear config}{p_end}
{phang2}// Clears yaml_config frame (Stata 16+){p_end}
{phang2}{cmd:. yaml clear, all}{p_end}
{phang2}// Clears all yaml_* frames (Stata 16+){p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:yaml read} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(n_keys)}}number of keys parsed{p_end}
{synopt:{cmd:r(max_level)}}maximum nesting depth{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(filename)}}name of file read{p_end}
{synopt:{cmd:r(frame)}}name of frame created (if frame option used){p_end}
{synopt:{cmd:r(yaml_*)}}values from YAML file (when {opt locals} specified){p_end}

{pstd}
{cmd:yaml list} stores the following in {cmd:r()} when {opt keys} or {opt values} specified:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(keys)}}delimited list of matching keys{p_end}
{synopt:{cmd:r(values)}}delimited list of matching values{p_end}
{synopt:{cmd:r(parent)}}parent key used for filtering{p_end}
{p2colreset}{...}


{marker limitations}{...}
{title:Limitations}

{pstd}
{cmd:yaml} requires Stata 14.0 for basic functionality.
The {opt frame()} option requires Stata 16.0 or later.

{pstd}
{cmd:yaml} handles common YAML structures but does not support:

{phang2}- Multi-line strings (block scalars){p_end}
{phang2}- Anchors and aliases (&anchor, *alias){p_end}
{phang2}- Complex keys{p_end}
{phang2}- Flow style ({c -(}key: value{c )-}){p_end}
{phang2}- Document markers (---){p_end}


{marker author}{...}
{title:Author}

{pstd}
João Pedro Azevedo{break}
UNICEF{break}
jpazevedo@unicef.org


{marker seealso}{...}
{title:Also see}

{psee}
{space 2}Help: {help frames}, {help infile}, {help import delimited}, {help file}
{p_end}
