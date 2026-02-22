{smcl}
{* *! version 1.9.0  20Feb2026}{...}
{vieweralsosee "yaml" "help yaml"}{...}
{vieweralsosee "yaml what's new" "help yaml_whatsnew"}{...}
{viewerjumpto "Basic usage" "yaml_examples##basic"}{...}
{viewerjumpto "Frames" "yaml_examples##frames"}{...}
{viewerjumpto "Querying" "yaml_examples##querying"}{...}
{viewerjumpto "Validation" "yaml_examples##validation"}{...}
{viewerjumpto "Fast-read" "yaml_examples##fastread"}{...}
{viewerjumpto "Bulk and collapse" "yaml_examples##bulk"}{...}
{viewerjumpto "Indicators preset" "yaml_examples##indicators"}{...}
{viewerjumpto "Round-trip" "yaml_examples##roundtrip"}{...}
{viewerjumpto "Real-world" "yaml_examples##realworld"}{...}
{hline}
{cmd:help yaml examples}{right:{bf:version 1.9.0}}
{hline}

{title:Title}

{phang}
{bf:yaml} {hline 2} Examples


{marker basic}{...}
{title:Basic usage}

{pstd}
{bf:Read a YAML file into the current dataset:}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", replace}{p_end}
{phang2}{cmd:. yaml describe}{p_end}

{pstd}
{bf:Read with return locals (for immediate use):}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", locals replace}{p_end}
{phang2}{cmd:. display r(yaml_name)}{p_end}
{phang2}{cmd:. display r(yaml_version)}{p_end}

{pstd}
{bf:Read with scalars (numeric values only):}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", scalars replace}{p_end}
{phang2}{cmd:. scalar list}{p_end}

{pstd}
{bf:Use abbreviations for common subcommands:}{p_end}

{phang2}{cmd:. yaml desc}{space 8}{it:// same as yaml describe}{p_end}
{phang2}{cmd:. yaml check}{space 7}{it:// same as yaml validate}{p_end}
{phang2}{cmd:. yaml frame}{space 7}{it:// same as yaml frames}{p_end}


{marker frames}{...}
{title:Working with frames (Stata 16+)}

{pstd}
{bf:Load into a named frame (preserves current dataset):}{p_end}

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. yaml read using "config.yaml", frame(cfg)}{p_end}
{phang2}{cmd:. display _N}{p_end}
{phang2}{res:  74}{p_end}
{phang2}{it:// auto dataset is untouched}{p_end}

{pstd}
{bf:Load multiple YAML files simultaneously:}{p_end}

{phang2}{cmd:. yaml read using "dev_config.yaml", frame(dev)}{p_end}
{phang2}{cmd:. yaml read using "prod_config.yaml", frame(prod)}{p_end}
{phang2}{cmd:. yaml frames, detail}{p_end}

{pstd}
{bf:Query from a specific frame:}{p_end}

{phang2}{cmd:. yaml get database:host, frame(dev)}{p_end}
{phang2}{cmd:. local dev_host = r(host)}{p_end}
{phang2}{cmd:. yaml get database:host, frame(prod)}{p_end}
{phang2}{cmd:. local prod_host = r(host)}{p_end}

{pstd}
{bf:Clean up frames:}{p_end}

{phang2}{cmd:. yaml clear dev}{space 6}{it:// clear one frame}{p_end}
{phang2}{cmd:. yaml clear, all}{space 3}{it:// clear all yaml_* frames}{p_end}


{marker querying}{...}
{title:Querying YAML data}

{pstd}
{bf:Get indicator metadata using colon syntax:}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", replace}{p_end}
{phang2}{cmd:. yaml get indicators:CME_MRY0T4}{p_end}
{phang2}{res:  label: Under-five mortality rate}{p_end}
{phang2}{res:  unit: Deaths per 1000 live births}{p_end}
{phang2}{res:  dataflow: CME}{p_end}

{pstd}
{bf:Get specific attributes only:}{p_end}

{phang2}{cmd:. yaml get indicators:CME_MRY0T4, attributes(label unit)}{p_end}

{pstd}
{bf:List child keys under a parent:}{p_end}

{phang2}{cmd:. yaml list indicators, keys children}{p_end}
{phang2}{res:Keys under indicators: CME_MRY0T4 CME_MRY0 CME_MRY0T27D}{p_end}

{pstd}
{bf:Loop over indicator codes:}{p_end}

{phang2}{cmd:. yaml list indicators, keys children}{p_end}
{phang2}{cmd:. foreach ind in `r(keys)' {c -(}}{p_end}
{phang2}{cmd:.     yaml get indicators:`ind', quiet}{p_end}
{phang2}{cmd:.     display "`ind': `r(label)' (`r(unit)')"}{p_end}
{phang2}{cmd:. {c )-}}{p_end}

{pstd}
{bf:Use Stata compound quotes (for keys with special characters):}{p_end}

{phang2}{cmd:. yaml list indicators, keys children stata}{p_end}
{phang2}{cmd:. foreach ind in `r(keys)' {c -(}}{p_end}
{phang2}{cmd:.     display "Processing: `ind'"}{p_end}
{phang2}{cmd:. {c )-}}{p_end}


{marker validation}{...}
{title:Validation}

{pstd}
{bf:Check that required keys exist:}{p_end}

{phang2}{cmd:. yaml read using "pipeline_config.yaml", replace}{p_end}
{phang2}{cmd:. yaml validate, required(name version database api)}{p_end}

{pstd}
{bf:Validate types:}{p_end}

{phang2}{cmd:. yaml validate, types(database_port:numeric api_timeout:numeric debug:boolean)}{p_end}

{pstd}
{bf:Use in a pipeline guard:}{p_end}

{phang2}{cmd:. yaml check, required(name version)}{p_end}
{phang2}{cmd:. if (r(valid) == 0) {c -(}}{p_end}
{phang2}{cmd:.     display as error "Configuration validation failed!"}{p_end}
{phang2}{cmd:.     exit 198}{p_end}
{phang2}{cmd:. {c )-}}{p_end}


{marker fastread}{...}
{title:Fast-read mode}

{pstd}
{bf:Fast-read} is a speed-first parser for large YAML files with regular structure
(e.g., indicator catalogs). It produces a flat table with columns:
{cmd:key}, {cmd:field}, {cmd:value}, {cmd:list}, {cmd:line}.

{pstd}
{bf:Basic fast-read:}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", fastread replace}{p_end}
{phang2}{cmd:. list in 1/5}{p_end}

{pstd}
{bf:Fast-read with field filtering:}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", fastread replace ///}{p_end}
{phang2}{cmd:.     fields(name description source_id)}{p_end}

{pstd}
{bf:Fast-read with list extraction:}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", fastread replace ///}{p_end}
{phang2}{cmd:.     fields(name topic_ids) listkeys(topic_ids)}{p_end}

{pstd}
{bf:Fast-read with caching (Stata 16+):}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", fastread replace ///}{p_end}
{phang2}{cmd:.     fields(name description) cache(ind_cache)}{p_end}
{phang2}{it:// second call hits cache:}{p_end}
{phang2}{cmd:. yaml read using "indicators.yaml", fastread replace ///}{p_end}
{phang2}{cmd:.     fields(name description) cache(ind_cache)}{p_end}
{phang2}{cmd:. display r(cache_hit)}{p_end}
{phang2}{res:  1}{p_end}


{marker bulk}{...}
{title:Bulk parsing and collapse (Stata 16+)}

{pstd}
{bf:Mata bulk-load} ({opt bulk}) provides high-performance parsing via Mata.
Combined with {opt collapse} it produces wide-format output with one row per
top-level key.

{pstd}
{bf:Bulk parse (long format):}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", bulk replace}{p_end}

{pstd}
{bf:Bulk parse with collapse (wide format):}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", bulk collapse replace}{p_end}

{pstd}
{bf:Collapse with field filtering:}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", bulk collapse replace ///}{p_end}
{phang2}{cmd:.     colfields(code;name;source_id;description)}{p_end}

{pstd}
{bf:Collapse with depth limit:}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", bulk collapse replace maxlevel(2)}{p_end}

{pstd}
{bf:Use strL for long values (>2045 chars):}{p_end}

{phang2}{cmd:. yaml read using "indicators.yaml", bulk strl replace}{p_end}


{marker indicators}{...}
{title:Indicators preset}

{pstd}
The {opt indicators} preset is a one-step shortcut for parsing wbopendata and
unicefdata indicator metadata YAML files. It automatically enables {opt bulk}
and {opt collapse} with standard field selection.

{pstd}
{bf:Parse indicator metadata:}{p_end}

{phang2}{cmd:. yaml read using "unicef_indicators.yaml", indicators replace}{p_end}
{phang2}{it:// equivalent to: bulk collapse colfields(code;name;source_id;...)}{p_end}
{phang2}{cmd:. list key code name in 1/5}{p_end}


{marker roundtrip}{...}
{title:Round-trip: read, modify, write}

{pstd}
{bf:Read a YAML file, modify a value, and write it back:}{p_end}

{phang2}{cmd:. yaml read using "config.yaml", replace}{p_end}
{phang2}{cmd:. replace value = "new_value" if key == "settings_timeout"}{p_end}
{phang2}{cmd:. yaml write using "config_modified.yaml", replace}{p_end}

{pstd}
{bf:Write scalars to a new YAML file:}{p_end}

{phang2}{cmd:. scalar project = 1}{p_end}
{phang2}{cmd:. scalar year = 2026}{p_end}
{phang2}{cmd:. yaml write using "output.yaml", scalars(project year) replace}{p_end}


{marker realworld}{...}
{title:Real-world: efficient metadata ingestion with frames}

{pstd}
This pattern is used by {cmd:unicefdata} and {cmd:wbopendata} for processing
large indicator catalogs. Direct dataset queries are ~50x faster than iterating
{cmd:yaml get} calls.

{phang2}{cmd:. yaml read using "indicators_catalog.yaml", frame(metadata)}{p_end}
{phang2}{cmd:. frame yaml_metadata {c -(}}{p_end}
{phang2}{cmd:.     gen is_match = regexm(key, "^indicators_[A-Za-z0-9_]+_dataflow$") ///}{p_end}
{phang2}{cmd:.                    & value == "NUTRITION"}{p_end}
{phang2}{cmd:.     gen indicator_code = regexs(1) if ///}{p_end}
{phang2}{cmd:.         regexm(key, "^indicators_([A-Za-z0-9_]+)_dataflow$") & is_match}{p_end}
{phang2}{cmd:.     levelsof indicator_code if is_match, local(nutrition_indicators) clean}{p_end}
{phang2}{cmd:.     foreach ind of local nutrition_indicators {c -(}}{p_end}
{phang2}{cmd:.         levelsof value if key == "indicators_`ind'_name", local(ind_name) clean}{p_end}
{phang2}{cmd:.         display "`ind': `ind_name'"}{p_end}
{phang2}{cmd:.     {c )-}}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. frame drop yaml_metadata}{p_end}


{title:Also see}

{psee}
{space 2}Help: {help yaml}, {help yaml_whatsnew:what's new}
{p_end}
