# wbopendata sync sketch (draft)

Date: 07Feb2026

Goal
- Provide a single orchestration entry point for metadata sync that prefers the Python canonical pipeline and falls back to Stata parsing when needed.

Guiding principles
- Python output is canonical.
- Stata fallback is best-effort, documented, and parity-tested.
- Metadata artifacts are versioned and cached for offline use.
- Python and Stata pathways must preserve the same user-facing functionality.

Proposed entry points
- User-facing command: `wbopendata, sync` (already exists).
- Internal orchestrator: `_wbopendata_sync` (new ado) that coordinates the steps below.

Inputs
- Remote WB API endpoints for sources, topics, indicators.
- Optional GitHub release tag for prebuilt YAML assets.
- Cache directory for metadata artifacts.

Outputs
- YAML: `sources.yaml`, `topics.yaml`, `indicators.yaml` in cache.
- Cache metadata: `metadata_version.txt`, `cache_timestamp.txt`.
- Optional logs for parity and diagnostics.

Orchestration flow (high level)
1. Resolve cache directory and ensure it exists.
2. Decide pathway in priority order:
  a. Run Python canonical generation (Pathway B) when available.
  b. Else fallback to Stata-only refresh (Pathway A).
  c. Else download YAML from GitHub (Pathway C, last resort).
3. Validate outputs (basic schema checks + record counts).
4. Update cache metadata files and return status.

Pathway details
- Pathway B: Python canonical generation
  - Invoke `update_metadata.py` + `yaml_generator.py` (existing).
  - Copy generated YAML into cache.
  - Record Python version and commit hash in cache metadata.

- Pathway A: Stata-only fallback
  - Run `_wbopendata_refresh_yaml`.
  - On failure, preserve previous cache and return error.

- Pathway C: download YAML from GitHub (last resort)
  - Use `_wbopendata_download_yaml`.
  - Update cache version and timestamp.

Parser selection (if XML is used)
- Prefer Python if XML payload > size threshold (like unicefdata).
- Allow `forcepython` and `forcestata` options for debugging.

Validation checks
- YAML must contain `_metadata` section.
- Count indicators, sources, topics and compare to API counts.
- Verify required keys: id, name, description, url, etc.
- Validate against schema v2.0.0 (config/schema_yaml_v2.json) when possible.

Decisions (aligned)
- Cache location and naming stay as current behavior.
- YAML schema standard: YAML 1.2 JSON Schema subset; wbopendata schema v2.0.0 in config/schema_yaml_v2.json.
- Python and Stata pathways must keep user-facing functionality aligned (no feature drift).
- Parity checks are strict by default (tolerance = 0) unless explicitly relaxed for dev.

Reference architecture
- Informed by unicefData design (parser selection, Python-first for large payloads, Stata fallback).
- Reference materials:
  - unicefData-dev/stata/src/u/unicefdata_sync.ado
  - unicefData-dev/stata/src/u/unicefdata_xmltoyaml.ado
  - unicefData-dev/stata/src/u/unicefdata_xmltoyaml_py.ado
  - unicefData-dev/stata/src/_/_unicefdata_sync_ind_meta.ado
  - unicefData-dev/internal

Compatibility checklist (user-facing parity)
- Commands: `sources`, `topics`, `search`, `info`, `sync`, `checkupdate`.
- Options: `match`, `countrymetadata`, `nometadata`, `metadataoffline`, `linewrap`, `maxlength`, `linewrapformat`.
- Outputs: return values, SMCL display, and YAML cache content are consistent.
- Errors: same error codes/messages for missing metadata or invalid options.
- Offline behavior: cache discovery, cache timestamps, and version checks behave the same.

Compatibility test cases (draft)
- `wbopendata, sources` returns the same count and ordering for Python vs Stata cache.
- `wbopendata, topics` returns the same count and ordering for Python vs Stata cache.
- `wbopendata, search` with a keyword yields the same top 10 results.
- `wbopendata, info` for a known indicator returns identical key fields.
- `wbopendata, sync` updates cache version and timestamp consistently.
- `wbopendata, checkupdate` reports the same status across pathways.
- `wbopendata, countrymetadata` prints the same fields and labels.
- `wbopendata, match(countrycode)` returns identical matches.
- `wbopendata, nometadata` does not attempt metadata fetch.
- `wbopendata, metadataoffline` generates all expected files without errors.
- `wbopendata, linewrap(40) maxlength(60)` produces identical wrapped text.
- Missing cache triggers the same error text and guidance in both pathways.

Parity test plan (dev)
- Purpose: verify Stata fallback outputs match Python canonical outputs.
- Trigger: manual in dev, optional CI hook later.
- Inputs: Python-generated YAML vs Stata-generated YAML for the same run.
- Tools: `tests/run_yaml_parity.do` + `tests/compare_yaml_parity.py`.
- Steps:
  1. Clear cache or write to a temp cache path.
  2. Run Python canonical pipeline and capture YAML outputs.
  3. Run Stata fallback and capture YAML outputs.
  4. Compare record counts and key fields (id, name, source, topic).
  5. Report mismatches with sample IDs and line numbers.
- Pass criteria:
  - Counts match for sources/topics/indicators.
  - No missing IDs, and no extra IDs in Stata output.
  - Key text fields match after normalization (trim, decode entities).
- Fail criteria:
  - YAML parse errors or missing `_metadata` section.
  - Count mismatch beyond tolerance (default tolerance = 0).
  - Field-level mismatches above threshold.
- Notes:
  - Normalize HTML entities and whitespace before comparisons.
  - Keep a small fixture set for fast checks.

Command examples (current tooling)
- Python canonical generation (from repo root):
  - `python wbopendata-dev/py/update_metadata.py`
  - `python wbopendata-dev/py/yaml_generator.py`
- Stata fallback refresh (from Stata):
  - `do wbopendata-dev/tests/run_yaml_parity.do`
- Direct parity compare (from repo root):
  - `python wbopendata-dev/tests/compare_yaml_parity.py`

CLI options (proposed)
- `sync` (existing): run the orchestrator with defaults.
- `sync, forcepython`: always use Python pipeline.
- `sync, forcestata`: always use Stata fallback.
- `sync, githubrelease(tag)`: pull prebuilt YAML from release.
- `sync, refreshcache`: rebuild cache even if up to date.

Telemetry and logs
- Write a compact sync log to `logs/` when run from dev repo.
- Optional parity report output for dev testing.

Integration points
- `wbopendata.ado`: route `sync` option into `_wbopendata_sync`.
- `_wbopendata_cache.ado`: use for cache path discovery.
- `_wbopendata_check_version.ado`: use for remote version check.
