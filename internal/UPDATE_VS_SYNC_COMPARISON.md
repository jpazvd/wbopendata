# wbopendata: `update` vs `sync` — Comparison & Path Forward

**Date:** 09 Feb 2026  
**Author:** Internal Development Document  
**Branch:** feat/discovery-sync  

---

## Executive Summary

The wbopendata package currently has two parallel metadata management systems:

| Feature | `update` (Legacy) | `sync` (New) |
|---------|-------------------|--------------|
| Version | v16.3 (Jul 2020) | v1.0.0 (Feb 2026) |
| Primary focus | Update help files and internal state | Orchestrate metadata YAML generation |
| Data source | Direct WB API calls | Python or Stata → YAML cache |
| Architecture | Monolithic, procedural | Modular, pathway-based |
| Extensibility | Low | High |

**Recommendation:** Consolidate to `sync` as the single metadata orchestrator, deprecating the `update` pathway in v19.0.0.

---

## 1. `wbopendata, update` — Legacy System

### 1.1 Architecture

```
wbopendata, update [query|check|all|force]
    └── _update_wbopendata.ado (v16.3)
            ├── _parameters.ado          → Read current state from YAML
            ├── _api_read.ado            → Direct WB API calls
            ├── _update_indicators.ado   → Generate indicator help files
            ├── _update_countrymetadata.ado → Refresh country list
            └── Writes _wbopendata_parameters.yaml
```

### 1.2 What It Does

| Sub-option | Behavior |
|------------|----------|
| `update query` | Display current indicator counts, last check dates, and update status. No data fetched. |
| `update check` | Query WB API for current indicator/country counts; compare to local state; display discrepancies. |
| `update check detail` | Same as `check`, but also list per-source and per-topic counts with SAME/CHANGED tags. |
| `update all` | Download new indicator metadata; regenerate per-source `.sthlp` files; update `_wbopendata_parameters.yaml`. |
| `update force` | Same as `all`, but forces regeneration even when counts match. Also triggers `_wbopendata_refresh_yaml`. |

### 1.3 Files Produced

- `_wbopendata_parameters.yaml` — Stores last-checked/last-updated timestamps, source/topic counts
- `wbopendata_sourceid##.sthlp` (71+ files) — Per-source indicator help files
- `wbopendata_topicid##.sthlp` — Per-topic indicator help files
- `wbopendata_ctrylist.sthlp` — Country list help file

### 1.4 Dependencies

| Program | Purpose |
|---------|---------|
| `_parameters.ado` | Parse `_wbopendata_parameters.yaml` for baseline state |
| `_api_read.ado` | Low-level WB API HTTP calls |
| `_api_read_indicators.ado` | Fetch paginated indicator list |
| `_update_indicators.ado` | Generate `.sthlp` help files by source/topic |
| `_update_countrymetadata.ado` | Update country metadata cache |

### 1.5 Strengths

- ✓ Mature, tested since 2019
- ✓ Detailed per-source/topic comparison reports
- ✓ Interactive clickable links in report output
- ✓ Generates comprehensive `.sthlp` documentation files

### 1.6 Weaknesses

- ✗ Monolithic — all logic in a single 730-line ado
- ✗ Only Stata pathway — no Python support
- ✗ Generates 71+ `.sthlp` files, increasing package size
- ✗ No versioned cache or schema validation
- ✗ No parity testing with Python outputs
- ✗ Timestamps but no version numbers on metadata

---

## 2. `wbopendata, sync` — New System

### 2.1 Architecture

```
wbopendata, sync [force|forcepython|forcestata]
    └── _wbopendata_sync.ado (v1.0.0)
            ├── Pathway B: Python canonical (preferred)
            │       └── update_metadata.py → YAML generation
            ├── Pathway A: Stata fallback
            │       └── _wbopendata_refresh_yaml.ado
            └── Pathway C: GitHub download (last resort)
                    └── _wbopendata_download_yaml.ado
```

### 2.2 What It Does

| Sub-option | Behavior |
|------------|----------|
| `sync` | Auto-detect best pathway; run Python if available, else Stata fallback, else GitHub download. |
| `sync, force` | Force refresh even if cache is fresh. |
| `sync, forcepython` | Explicitly use Python pipeline (fail if unavailable). |
| `sync, forcestata` | Explicitly use Stata fallback (no Python). |
| `checkupdate` | Check GitHub for newer package version; display guidance if update available. |
| `cacheinfo` | Display cache status, version, last sync timestamp, sync method. |
| `clearcache` | Remove local cache files. |

### 2.3 Files Produced

| File | Purpose |
|------|---------|
| `_wbopendata_indicators.yaml` | Full indicator metadata (~30k records) |
| `_wbopendata_sources.yaml` | Source metadata + indicator counts |
| `_wbopendata_topics.yaml` | Topic metadata + indicator counts |
| `cache_metadata.yaml` | Sync timestamp, method, source |
| `cache_timestamp.txt` | Human-readable last sync date |
| `metadata_version.txt` | Schema version (e.g., 2.0.0) |
| `cache_sync_history.yaml` | Append-only sync log |

### 2.4 Dependencies

| Program | Purpose |
|---------|---------|
| `_wbopendata_sync.ado` | Orchestrator |
| `_wbopendata_refresh_yaml.ado` | Stata-only YAML generation from WB API |
| `_wbopendata_check_version.ado` | GitHub release version check |
| `_wbopendata_download_yaml.ado` | Download prebuilt YAML from GitHub |
| `_wbopendata_cache.ado` | Cache management utilities |
| `update_metadata.py` | Python canonical pipeline |
| `yaml_generator.py` | Python YAML serialization |
| `schema_validator.py` | JSON Schema validation |

### 2.5 Strengths

- ✓ Modular, pathway-based architecture
- ✓ Python-first for performance and accuracy; Stata fallback for compatibility
- ✓ Schema-validated outputs (config/schema_yaml_v2.json)
- ✓ Versioned metadata with sync history
- ✓ Parity testing between Python and Stata outputs
- ✓ Offline support via GitHub release download
- ✓ No `.sthlp` file proliferation — uses discovery commands instead

### 2.6 Weaknesses

- ✗ New (v1.0.0, Feb 2026) — less field testing
- ✗ Requires Python for canonical outputs (optional but preferred)
- ✗ Does not yet generate legacy `.sthlp` files (by design)
- ✗ Cache management not yet exposed in help documentation

---

## 3. Feature Comparison Matrix

| Capability | `update` | `sync` | Notes |
|------------|----------|--------|-------|
| Query current state | ✓ | ✓ (via cacheinfo) | update has richer report |
| Check for API changes | ✓ | ✓ (via checkupdate) | update compares counts; sync checks version |
| Refresh indicator metadata | ✓ | ✓ | Both fetch from WB API |
| Python pipeline | ✗ | ✓ | Python is canonical for sync |
| Stata fallback | ✓ | ✓ | Stata-only possible in both |
| Offline download | ✗ | ✓ | GitHub release fallback |
| Schema validation | ✗ | ✓ | JSON Schema v2.0.0 |
| Cache versioning | Timestamps only | Version + timestamps | Semantic versioning |
| Sync history log | ✗ | ✓ | Append-only YAML log |
| Generate `.sthlp` files | ✓ | ✗ (by design) | sync uses discovery commands |
| Per-source/topic reports | ✓ | ✗ | Could be added to sync |
| Force update | ✓ | ✓ | Both support force |
| Interactive SMCL links | ✓ | Limited | update has richer links |

---

## 4. Path Forward: Recommended Consolidation

### 4.1 Phase 1: Parallel Operation (v18.x, Current)

- Both `update` and `sync` coexist
- `sync` is the documented primary pathway
- `update` remains for backward compatibility
- Discovery commands (`sources`, `topics`, `search`, `info`) use YAML from `sync`

### 4.2 Phase 2: Deprecation Warning (v18.1 or v18.2)

- Add deprecation notice to `update` output:
  ```stata
  di as text "Note: wbopendata, update is deprecated. Use wbopendata, sync instead."
  ```
- Update help files to recommend `sync`
- Ensure `sync` covers all user-facing needs

### 4.3 Phase 3: Remove `.sthlp` Generation (v18.x or v19.0)

- Deprecate the 71+ per-source `.sthlp` files
- Replace with `wbopendata, info(indicator)` discovery command
- Clean up package by removing generated help files from distribution

### 4.4 Phase 4: Consolidate to `sync` Only (v19.0)

- Remove `update` option from syntax
- Archive `_update_wbopendata.ado` and related programs
- `sync` becomes the sole metadata orchestrator
- Simplify help documentation

### 4.5 Features to Port from `update` to `sync`

Before deprecation, ensure `sync` supports:

| Feature | Priority | Status |
|---------|----------|--------|
| Per-source indicator counts display | Medium | Not started |
| Per-topic indicator counts display | Medium | Not started |
| SAME/CHANGED comparison report | Low | Not needed (version-based now) |
| Interactive SMCL links in reports | Medium | Partial |
| `metadataoffline` equivalent | Low | Covered by forcestata |

---

## 5. Migration Guide for Users

### Current Workflow (update)

```stata
wbopendata, update query        // See current state
wbopendata, update check detail // Detailed comparison
wbopendata, update all          // Refresh metadata
```

### New Workflow (sync)

```stata
wbopendata, cacheinfo           // See current state
wbopendata, checkupdate         // Check for new version
wbopendata, sync                // Refresh metadata
wbopendata, sources             // List sources + counts
wbopendata, alltopics           // List topics + counts
wbopendata, search(pattern)     // Find indicators
wbopendata, info(NY.GDP.MKTP.CD) // Get indicator details
```

---

## 6. Technical Recommendations

### 6.1 Immediate Actions (v18.x)

1. **Add deprecation notice** to `_update_wbopendata.ado` output
2. **Document `sync` workflow** in main help file
3. **Add source/topic counts** to `wbopendata, sources` and `wbopendata, alltopics` output
4. **Test parity** between update and sync outputs

### 6.2 Short-Term (v18.1–18.2)

1. **Merge per-source counts** into sync workflow via `wbopendata, sources detail`
2. **Add quick compare** option to show what changed since last sync
3. **Improve SMCL output** in sync-related commands

### 6.3 Medium-Term (v19.0)

1. **Remove `update` option** from main syntax
2. **Archive legacy files** to `archive/` folder
3. **Simplify package** by removing auto-generated `.sthlp` files
4. **Update SSC/net distribution** with slimmer package

---

## 7. Conclusion

The `sync` system is architecturally superior:

- **Modular**: Clear separation of concerns
- **Multi-pathway**: Python canonical + Stata fallback + GitHub download
- **Validated**: Schema-checked outputs
- **Versioned**: Semantic versioning with history
- **Modern**: Aligns with unicefData architecture

The `update` system served its purpose (2019–2025) but should be retired in favor of the unified `sync` orchestrator.

**Recommended version timeline:**

| Version | Milestone |
|---------|-----------|
| v18.0 | Both coexist; sync is primary |
| v18.1 | Add deprecation notice to update |
| v18.2 | Port remaining update features to sync |
| v19.0 | Remove update; sync is sole orchestrator |

---

## Appendix A: Program Inventory

### Programs to Keep (sync pathway)

- `_wbopendata_sync.ado`
- `_wbopendata_refresh_yaml.ado`
- `_wbopendata_cache.ado`
- `_wbopendata_check_version.ado`
- `_wbopendata_download_yaml.ado`
- `_wbopendata_get_yaml_path.ado`
- `_wbopendata_info.ado`
- `_wbopendata_search.ado`
- `_wbopendata_sources.ado`
- `_wbopendata_topics.ado`
- `_parameters.ado` (YAML-based, keep)

### Programs to Deprecate (update pathway)

- `_update_wbopendata.ado`
- `_update_indicators.ado`
- `_update_countrymetadata.ado`
- `_api_read_indicators.ado` (if only used by update)
- `wbopendata_sourceid##.sthlp` (71+ files)
- `wbopendata_topicid##.sthlp`

---

## Appendix B: Reference Implementation

See also:
- [WBOPENDATA_SYNC_SKETCH.md](../doc/plans/WBOPENDATA_SYNC_SKETCH.md) — Sync architecture design
- [unicefData sync](../../unicefData-dev/stata/src/u/unicefdata_sync.ado) — Reference implementation
