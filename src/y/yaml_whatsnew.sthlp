{smcl}
{* *! version 1.9.2  22Feb2026}{...}
{vieweralsosee "yaml" "help yaml"}{...}
{vieweralsosee "yaml examples" "help yaml_examples"}{...}
{viewerjumpto "v1.9.2" "yaml_whatsnew##v192"}{...}
{viewerjumpto "v1.9.0" "yaml_whatsnew##v190"}{...}
{viewerjumpto "v1.8.0" "yaml_whatsnew##v180"}{...}
{viewerjumpto "v1.7.0" "yaml_whatsnew##v170"}{...}
{viewerjumpto "v1.6.0" "yaml_whatsnew##v160"}{...}
{viewerjumpto "v1.5.1" "yaml_whatsnew##v151"}{...}
{viewerjumpto "v1.5.0" "yaml_whatsnew##v150"}{...}
{viewerjumpto "v1.4.0" "yaml_whatsnew##v140"}{...}
{viewerjumpto "v1.3.1" "yaml_whatsnew##v131"}{...}
{hline}
{cmd:help yaml what's new}{right:{bf:version 1.9.2}}
{hline}

{title:What's New in yaml}

{pstd}
{it:Return to {help yaml:main help file}}
{p_end}


{marker v192}{...}
{title:Version 1.9.2 (22Feb2026) {hline 2} Parser parity fixes}

{pstd}
{bf:List-item quote stripping} {hline 2} The canonical parser now strips surrounding
quotes from YAML list item values, matching the Mata bulk parser behavior.
Previously, values like {cmd:"Climate Change"} retained their quotes in canonical
mode but not in bulk mode.
{p_end}

{pstd}
{bf:Sibling parent_stack fix} {hline 2} Fixed parent_stack contamination where
adjacent parent keys at the same indent level (e.g., {cmd:topic_ids:} followed by
{cmd:topic_names:}) could produce incorrect field names. Both canonical and Mata
bulk parsers now correctly restore the parent context for sibling keys.
{p_end}


{marker v190}{...}
{title:Version 1.9.0 (20Feb2026) {hline 2} Indicators preset}

{pstd}
{bf:Indicators Preset} {hline 2} One-step shortcut for parsing wbopendata and
unicefdata indicator metadata YAML files. Automatically enables {cmd:bulk}
and {cmd:collapse} with standard field selection.
{p_end}

{phang2}{cmd:. yaml read using indicators.yaml, indicators replace}{p_end}


{marker v180}{...}
{title:Version 1.8.0 (20Feb2026) {hline 2} Collapse filter options}

{pstd}
{bf:Collapse Filters} {hline 2} Added {cmd:colfields()} to filter collapsed
output to specific field names (semicolon-separated), and {cmd:maxlevel()}
to limit collapsed columns by nesting depth. Designed for large indicator
metadata catalogs.
{p_end}

{pstd}
Added FEAT-09 test for collapse filter options.
{p_end}


{marker v170}{...}
{title:Version 1.7.0 (20Feb2026) {hline 2} Mata bulk-load and collapse}

{pstd}
{bf:Bulk Parser} {hline 2} Added {cmd:bulk} option for high-performance
Mata-based YAML parsing. Combined with {cmd:collapse}, produces wide-format
output with one row per top-level key. Added {cmd:strl} option for values
exceeding 2045 characters.
{p_end}

{pstd}
Added FEAT-05 and FEAT-06 tests for bulk and collapse features.
{p_end}


{marker v160}{...}
{title:Version 1.6.0 (18Feb2026)}

{pstd}
Mata {cmd:st_sstore()} for embedded quote safety in canonical parser.
Block scalar support ({cmd:|}, {cmd:>}) in canonical parser.
Continuation lines for multi-line scalars.
{p_end}


{marker v151}{...}
{title:Version 1.5.1 (18Feb2026)}

{pstd}
{bf:Bug Fixes}
{p_end}

{phang2}BUG-1: Fixed {cmd:last_key} assignment for leaf keys in {cmd:yaml read};
list items after a leaf key now reference the correct parent.{p_end}

{phang2}BUG-2: Fixed {cmd:parent_stack} update after storing parent keys in
{cmd:yaml read}; nested hierarchy tracking is now correct.{p_end}

{phang2}BUG-3: Fixed return value propagation from frame context in {cmd:yaml get}
and {cmd:yaml list}; {cmd:r()} values now persist after the frame block exits.{p_end}

{pstd}
{bf:Enhancements}
{p_end}

{phang2}Added subcommand abbreviations: {cmd:desc} for {cmd:describe},
{cmd:frame} for {cmd:frames}, {cmd:check} for {cmd:validate}.{p_end}

{phang2}Improved error messages: empty and unknown subcommands now list all
valid subcommands.{p_end}

{phang2}Added {cmd:yaml_examples.sthlp} with comprehensive usage examples.{p_end}

{phang2}Added regression tests REG-01, REG-02, REG-03 to the QA runner.{p_end}


{marker v150}{...}
{title:Version 1.5.0 (04Feb2026)}

{pstd}
Added canonical early-exit targets and streaming tokenization options.
Index frame materialization for repeated queries (Stata 16+).
Fast-read block-scalar capture and unsupported-feature checks.
File readability and empty-file checks for {cmd:yaml read}.
Benchmark script and performance targets.
{p_end}


{marker v140}{...}
{title:Version 1.4.0 (04Feb2026)}

{pstd}
Added {cmd:fastread} mode for speed-first parsing of large, regular YAML files.
Added {cmd:fields()} to restrict extraction to specific keys,
{cmd:listkeys()} for list-block extraction in fast-read mode, and
{cmd:cache()} to store parsed output in a frame (Stata 16+).
{p_end}


{marker v131}{...}
{title:Version 1.3.1 (17Dec2025)}

{pstd}
Fixed return value propagation from frame context in {cmd:yaml get} and
{cmd:yaml list}. Fixed hyphen-to-underscore normalization in {cmd:yaml get}
search prefix.
{p_end}


{title:Also see}

{psee}
{space 2}Help: {help yaml}, {help yaml_examples:yaml examples}
{p_end}
