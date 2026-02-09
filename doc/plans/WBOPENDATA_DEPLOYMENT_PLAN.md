# wbopendata deployment implementation plan

Date: 07Feb2026

Scope
- Target repo: wbopendata-dev.
- Goal: full deployment of metadata sync and cache workflow with Python canonical pipeline and Stata fallback.

Principles
- Python output is canonical.
- Stata fallback preserves the same user-facing functionality.
- Cache location and naming remain unchanged.
- YAML schema standard: YAML 1.2 JSON Schema subset; wbopendata schema v2.0.0 in config/schema_yaml_v2.json.

Reference architecture
- Design patterns are informed by unicefData (parser selection, Python-first for large payloads, Stata fallback).
- Reference materials:
  - unicefData-dev/stata/src/u/unicefdata_sync.ado
  - unicefData-dev/stata/src/u/unicefdata_xmltoyaml.ado
  - unicefData-dev/stata/src/u/unicefdata_xmltoyaml_py.ado
  - unicefData-dev/stata/src/_/_unicefdata_sync_ind_meta.ado
  - unicefData-dev/internal

Phase 1: Baseline and prerequisites
- Confirm Python pipeline runs from repo root with current config.
- Confirm Stata fallback runs end-to-end without errors.
- Capture current parity status and known deltas.
- Document cache locations and expected YAML filenames.

Baseline checks (commands)
- Python pipeline:
  - `python wbopendata-dev/src/py/update_metadata.py --no-validate --skip-diff`
- Stata fallback:
  - `do wbopendata-dev/tests/run_yaml_parity.do`
- Parity compare:
  - `python wbopendata-dev/tests/compare_yaml_parity.py --stata-dir wbopendata-dev/tests/parity_out/stata --python-dir wbopendata-dev/tests/parity_out/python`
- Cache check:
  - `wbopendata, cacheinfo`

Phase 2: Orchestrator implementation
- Add `_wbopendata_sync.ado` (internal orchestrator).
- Route `wbopendata, sync` to the orchestrator.
- Implement pathway selection logic:
  - Python canonical pipeline.
  - Stata fallback.
  - GitHub release download (last resort).
- Record cache metadata (version, timestamp, method/source).
- Write cache history (`cache_sync_history.yaml`) for auditability.

Phase 3: Validation and parity
- Implement validation hook for schema v2.0.0 (Python path) and basic checks (Stata path).
- Run parity tests with strict tolerance = 0.
- Normalize text fields before compare (HTML entities, whitespace).
- Document any known differences and resolution decisions.
- Track fallback caveats (encoding normalization, key typing).

Phase 4: User-facing parity checks
- Verify commands: `sources`, `topics`, `search`, `info`, `sync`, `checkupdate`.
- Verify options: `match`, `countrymetadata`, `nometadata`, `metadataoffline`, `linewrap`, `maxlength`, `linewrapformat`.
- Confirm consistent errors and return values.

Phase 5: Documentation and release prep
- Update architecture docs with schema standards and pipeline notes.
- Update user guide and examples for sync behavior.
- Prepare release notes and version bump.

Deliverables
- `_wbopendata_sync.ado` implemented and wired.
- Updated docs in doc/architecture and doc/user-guide.
- Parity test results logged.
- Release checklist completed.

Risks and mitigations
- API changes: keep schema validation strict and add diff summary.
- Stata parsing limits: preserve fallback as best-effort, but document differences if any.
- Cache drift: enforce version/timestamp checks on sync.
- Parity drift: keep parity comparator tolerant to encoding, but fix root cause in Stata emit.
