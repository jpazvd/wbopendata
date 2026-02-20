{smcl}
{* *! version 1.5.1  18Feb2026}{...}
{viewerjumpto "Overview" "yaml_whatsnew##overview"}{...}
{viewerjumpto "Version history" "yaml_whatsnew##history"}{...}

{title:yaml: What's new}

{marker overview}{...}
{title:Overview}

{pstd}
This file tracks feature updates to the {cmd:yaml} command.

{marker history}{...}
{title:Version history}

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
