# Release v18.1.0: Discovery Commands, Char Metadata & Offline Testing

**Release Date:** February 10, 2026

---

## Highlights

This release is the largest update since v16.0 (2019). It introduces **offline discovery commands** for browsing the World Bank data catalog, a **YAML metadata architecture** replacing 89 per-indicator help files, a redesigned **sync system** with safe-by-default behavior, **variable-level `char` metadata** for self-documenting datasets, and **deterministic offline testing** with CSV fixtures. The QA suite grows from 44 to 89 tests across 17 categories.

---

## What's New (v17.7.1 → v18.1.0)

### At a Glance

| Metric | v17.7.1 | v18.1.0 |
|--------|---------|---------|
| **Indicators** | 20,147 | 29,323 |
| **Data sources** | 51 | 71 |
| **Total tests** | 44 | 89 |
| **Test categories** | 9 | 17 |
| **`.ado` files** | 12 | 34 |
| **Metadata format** | 89 `.sthlp` files | 2 YAML files |

---

### Discovery Commands (v18.0)

Browse the World Bank data catalog directly from Stata — no network required after initial sync:

| Command | Description |
|---------|-------------|
| `wbopendata, sources` | List all 71 data sources |
| `wbopendata, alltopics` | List all 21 topic categories with indicator counts |
| `wbopendata, search(query)` | Search indicators by keyword with topic/source/field filters |
| `wbopendata, info(ID)` | Display full indicator metadata with clickable URLs |

```stata
* Search for GDP indicators in topic 3 (Economy & Growth)
wbopendata, search(GDP) searchtopic(3)

* Get detailed metadata for a specific indicator
wbopendata, info(NY.GDP.MKTP.CD)

* Browse all data sources
wbopendata, sources
```

### YAML Metadata Architecture (v18.0)

Replaced **89 per-indicator `.sthlp` files** with 2 compact YAML metadata files:

| File | Size | Contents |
|------|------|----------|
| `_wbopendata_indicators.yaml` | 17 MB | ~29,323 indicators with full metadata |
| `_wbopendata_parameters.yaml` | 5 KB | Configuration parameters |

**Performance:** Frame-cached search (Stata 16+) returns results in <0.5s after initial 9s parse. Older Stata versions use per-call parsing with comparable results.

### Sync System Redesign (v18.0)

The sync command now defaults to a **safe dryrun preview**. The `replace` option is an explicit safety gate:

| Command | Behavior |
|---------|----------|
| `wbopendata, sync` | Preview metadata changes (dry run — always safe) |
| `wbopendata, sync detail` | Detailed preview with per-source/topic breakdown |
| `wbopendata, sync replace` | Apply metadata sync |
| `wbopendata, sync replace force` | Force re-download regardless of local version |

Three download pathways attempted in order: Python canonical → pure-Stata fallback → GitHub releases.

### Char Metadata (v18.1)

Indicator codes and descriptive metadata are now stored as Stata **characteristics** on variables and `_dta`, following the `freduse` pattern (Drukker 2006). Datasets become self-documenting and metadata persists across save/use cycles.

```stata
* Download with char metadata (default)
wbopendata, indicator(SP.POP.TOTL) clear long
char list

* Suppress char metadata
wbopendata, indicator(SP.POP.TOTL) clear long nochar
```

### Offline Deterministic Testing (v18.1)

The `offline(directory)` option loads pre-recorded CSV fixtures instead of querying the live API, implementing Gould (2001) Phase 6 certification:

```stata
* Run with local fixtures — no network needed
wbopendata, indicator(SP.POP.TOTL) country(USA) clear long offline("qa/fixtures")
```

---

## Bug Fixes

- **Compound quoting for SMCL tags**: `sourcecite`, `description_line`, and `note_line` returns now handle embedded double quotes from `{browse "url"}` SMCL tags
- **YAML parser**: handles embedded quotes using Mata `st_sstore()` bypass
- **`foreach` with parentheses**: topic names containing parentheses no longer cause errors (switched to `gettoken` loop)
- **`_rc` leaking**: internal sub-calls properly isolated via `capture noisily`
- **Windows paths**: repo detection in QA suite now normalizes paths correctly
- **Stray `set trace on`**: removed from dead code in `_api_read.ado` and `_query_indicators.ado`

---

## Deprecations

The following options now display user-facing warnings and will be removed in a future version:

| Deprecated | Replacement |
|------------|-------------|
| `update query` | `sync` |
| `update check` | `sync` / `checkupdate` |
| `update all` | `sync replace` |
| `metadataoffline` | Discovery commands (`sources`, `search`, `info`) |
| `syncforce` | `sync replace force` |
| `syncpreview` | `sync replace` |
| `syncdryrun` | `sync` |

---

## Quality Assurance

| Cat | Category | Tests | Type | Network? |
|-----|----------|-------|------|----------|
| 0 | ENV | 5 | Environment | No |
| 1 | DL | 5 | Integration | Yes |
| 2 | FMT | 3 | Integration | Yes |
| 3 | CTRY | 10 | Integration | Yes |
| 4 | REG | 4 | Regression | Yes |
| 5 | LW | 4 | Integration | Yes |
| 6 | UPD | 6 | Integration | Yes |
| 7 | TOPIC/LANG | 2 | Integration | Yes |
| 8 | Advanced | 6 | Integration | Yes |
| 9 | CACHE/SYNC | 13 | Integration | Mixed |
| 10 | DISC | 7 | Certification | No |
| 11 | CHAR | 6 | Integration | Yes |
| 12 | ERR | 8 | Certification | Mixed |
| 13 | EXT | 4 | Integration | Yes |
| 14 | DET | 6 | Certification | No |
| | **Total** | **89** | | |

**New since v17.7.1:** CACHE (8), SYNC (5), DISC (7), CHAR (6), ERR (8), EXT (4), DET (6) = 45 new tests

**Testing methodology:** ERR tests use `rcof` for exact return-code verification; DET tests use `offline()` fixtures for deterministic reproducibility (Gould 2001).

---

## Installation

```stata
* Install from GitHub (latest)
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace

* After install, sync metadata
wbopendata, sync replace
```

---

## Full Changelog

**Compare:** [v17.7.1...v18.1.0](https://github.com/jpazvd/wbopendata/compare/v17.7.1...v18.1.0)

### Merged Pull Requests

- Discovery commands and enhanced search ([#4](https://github.com/jpazvd/wbopendata/pull/4))
- Release v18.0.0 ([#5](https://github.com/jpazvd/wbopendata/pull/5))
- QA test suite expansion ([#6](https://github.com/jpazvd/wbopendata/pull/6))
- Char metadata, offline testing, 89-test QA suite ([#7](https://github.com/jpazvd/wbopendata-dev/pull/7))

---

## References

- Drukker, D. M. (2006). Importing Federal Reserve economic data. *The Stata Journal*, 6(3), 384–396.
- Gould, W. (2001). Statistical software certification. *The Stata Journal*, 1(1), 29–50.
