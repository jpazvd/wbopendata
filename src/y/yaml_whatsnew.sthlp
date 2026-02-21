{smcl}
{* *! version 1.9.0  20Feb2026}{...}
{viewerjumpto "Overview" "yaml_whatsnew##overview"}{...}
{viewerjumpto "Version history" "yaml_whatsnew##history"}{...}

{title:yaml: What's new}

{marker overview}{...}
{title:Overview}

{pstd}
This file tracks feature updates to the {cmd:yaml} command.

{marker history}{...}
{title:Version history}

{pstd}{bf:1.9.0} (20Feb2026) — {bf:INDICATORS preset}
{p 4 8 2}- Added {cmd:indicators} option as preset for wbopendata/unicefdata metadata.{p_end}
{p 4 8 2}- Automatically enables {cmd:bulk} and {cmd:collapse} with standard field selection.{p_end}
{p 4 8 2}- Replaces custom indicator parsers with single unified yaml command.{p_end}
{p 4 8 2}- Usage: {cmd:yaml read using indicators.yaml, indicators replace}{p_end}

{pstd}{bf:1.8.0} (20Feb2026) — {bf:Collapse filter options}
{p 4 8 2}- Added {cmd:colfields()} option to filter collapsed output to specific field names.{p_end}
{p 4 8 2}- Added {cmd:maxlevel()} option to limit collapsed columns by nesting depth.{p_end}
{p 4 8 2}- Designed for wbopendata/unicefdata indicator metadata parsing scenarios.{p_end}
{p 4 8 2}- Added FEAT-09 test for collapse filter options (qa/scripts/test_collapse_options.do).{p_end}

{pstd}{bf:1.7.0} (20Feb2026) — {bf:Mata bulk-load and collapse}
{p 4 8 2}- Added {cmd:bulk} option for high-performance Mata-based YAML parsing.{p_end}
{p 4 8 2}- Added {cmd:collapse} option to produce wide-format output from bulk parse.{p_end}
{p 4 8 2}- Added {cmd:strl} option for values exceeding 2045 characters.{p_end}
{p 4 8 2}- Added FEAT-05/FEAT-06 tests for bulk and collapse features.{p_end}

{pstd}{bf:1.6.0} (18Feb2026)
{p 4 8 2}- Mata st_sstore for embedded quote safety in canonical parser.{p_end}
{p 4 8 2}- Block scalar support in canonical parser.{p_end}
{p 4 8 2}- Continuation lines for multi-line scalars.{p_end}

{pstd}{bf:1.5.1} (18Feb2026)
{p 4 8 2}- Fixed {cmd:last_key} assignment for leaf keys in {cmd:yaml read}; list items after a leaf key now reference the correct parent (BUG-1).{p_end}
{p 4 8 2}- Fixed {cmd:parent_stack} update after storing parent keys in {cmd:yaml read}; nested hierarchy tracking is now correct (BUG-2).{p_end}
{p 4 8 2}- Fixed return value propagation from frame context in {cmd:yaml get} and {cmd:yaml list}; {cmd:r()} values now persist after the frame block exits (BUG-3).{p_end}
{p 4 8 2}- Added subcommand abbreviations: {cmd:desc} for {cmd:describe}, {cmd:frame} for {cmd:frames}, {cmd:check} for {cmd:validate}.{p_end}
{p 4 8 2}- Improved error messages: empty and unknown subcommands now list all valid subcommands.{p_end}
{p 4 8 2}- Added {cmd:yaml_examples.sthlp} with comprehensive usage examples.{p_end}
{p 4 8 2}- Added regression tests (REG-01, REG-02, REG-03) to the QA runner.{p_end}

{pstd}{bf:1.5.0} (04Feb2026)
{p 4 8 2}- Added canonical early-exit targets and streaming tokenization options.{p_end}
{p 4 8 2}- Added index frame materialization for repeated queries (Stata 16+).{p_end}
{p 4 8 2}- Added fast-read block-scalar capture and unsupported-feature checks.{p_end}
{p 4 8 2}- Added file readability and empty-file checks for yaml read.{p_end}
{p 4 8 2}- Added benchmark script and performance targets in scripts/benchmark_yaml_parse.do.{p_end}

{pstd}{bf:1.4.0} (04Feb2026)
{p 4 8 2}- Added {cmd:fastread} mode for speed-first parsing of large, regular YAML files.{p_end}
{p 4 8 2}- Added {cmd:fields()} to restrict extraction to specific keys.{p_end}
{p 4 8 2}- Added {cmd:listkeys()} for list-block extraction in fast-read mode.{p_end}
{p 4 8 2}- Added {cmd:cache()} to store parsed output in a frame (Stata 16+).{p_end}
{p 4 8 2}- Updated help examples to show fast-read usage.{p_end}

{pstd}{bf:1.3.1} (17Dec2025)
{p 4 8 2}- Fixed return value propagation from frame context in {cmd:yaml get} and {cmd:yaml list}.{p_end}
{p 4 8 2}- Fixed hyphen-to-underscore normalization in {cmd:yaml get} search prefix.{p_end}
