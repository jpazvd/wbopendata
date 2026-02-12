# wbopendata v18.1.0 — PR Messages, Release Note & Tag

**Public repo:** https://github.com/jpazvd/wbopendata
**Current state:** main = develop = v17.7.1 | staging = v18.1.0 (synced from wbopendata-dev)

---

## 1. PR: staging → develop

**URL:** https://github.com/jpazvd/wbopendata/compare/develop...staging?expand=1

**Title:** `Release v18.1.0: discovery commands, char metadata, offline testing`

**Body:**

### Summary

This PR brings v18.1.0 from staging into develop, synced from wbopendata-dev. It is the largest update since v16.0 (2019), spanning two internal milestones (v18.0 + v18.1).

- **Discovery commands**: `sources`, `alltopics`, `search()`, `info()` for offline catalog browsing (~29,323 indicators)
- **YAML metadata architecture**: 2 YAML files replace 89 per-indicator `.sthlp` files
- **Sync system redesign**: safe dryrun default, `replace` safety gate, Python/Stata/GitHub pathways
- **Variable-level `char` metadata**: indicator code stored as Stata `char` on data variables (default-on, `nochar` to suppress)
- **Deterministic offline testing**: `offline()` option loads CSV fixtures for Gould (2001) Phase 6 certification
- **89-test QA suite** across 17 categories (up from 44/9 in v17.7.1)
- **Bug fixes**: compound quoting for SMCL tags, `foreach` with parentheses, `_rc` leaking, YAML parser embedded quotes

### Key metrics

| Metric | v17.7.1 | v18.1.0 |
|--------|---------|---------|
| Indicators | 20,147 | 29,323 |
| Data sources | 51 | 71 |
| Tests | 44 | 89 |
| Test categories | 9 | 17 |
| `.ado` files | 12 | 34 |
| Metadata format | 89 `.sthlp` files | 2 YAML files |

### Files changed

203 files, +482,642/−375,581 lines (bulk of deletions = 89 removed `.sthlp` files)

### Source

Synced from [wbopendata-dev@c4f9d9f](https://github.com/jpazvd/wbopendata-dev/commit/c4f9d9f) via `sync-to-public.yml` workflow.

### Test plan

- [ ] `do run_tests.do` — 89/89 passed (last run: 5m 4s, Stata 17)
- [ ] `do run_tests.do DET-01` through `DET-06` — no network needed
- [ ] `do run_tests.do ERR-01` through `ERR-08` — `rcof` assertions
- [ ] Compile paper: pdflatex + bibtex — 48 pages, no undefined refs

---

## 2. PR: develop → main

**URL:** https://github.com/jpazvd/wbopendata/compare/main...develop (after staging merge)

**Title:** `Release v18.1.0: discovery, YAML metadata, char, offline testing`

**Body:**

### Summary

Promotes v18.1.0 from develop to main for public release. This release adds discovery commands for offline catalog browsing, replaces 89 per-indicator help files with a YAML metadata architecture, redesigns the sync system, adds variable-level `char` metadata for self-documenting datasets, and introduces deterministic offline testing. The QA suite grows from 44 to 89 tests across 17 categories.

### What's new (v17.7.1 → v18.1.0)

**v18.0 features:**
- Discovery commands: `sources`, `alltopics`, `search()`, `info()`
- YAML metadata: 2 files replace 89 `.sthlp` files (~29,323 indicators)
- Sync redesign: safe dryrun default, `replace` safety gate, 3 download pathways
- Cache management: `cache(info|checkversion|update|clear)`
- Modular architecture: 34 `.ado` files

**v18.1 features:**
- `char` metadata layer (default-on, `nochar` to suppress) — Drukker (2006) pattern
- `offline(directory)` option for deterministic testing — Gould (2001) Phase 6
- Error condition tests via `rcof` methodology

**Bug fixes:**
- Compound quoting for SMCL `{browse}` tags in metadata returns
- `foreach` failure with topic names containing parentheses
- `_rc` leaking from internal sub-calls
- YAML parser embedded quotes via Mata `st_sstore()` bypass

**Deprecations with warnings:**
- `update query/check/all` → `sync` commands
- `metadataoffline` → discovery commands
- `syncforce/preview/dryrun` → `sync replace [force]`

### QA

89 tests across 17 categories: ENV (5), DL (5), FMT (3), CTRY (10), REG (4), LW (4), UPD (6), TOPIC/LANG (2), Advanced (6), CACHE/SYNC (13), DISC (7), CHAR (6), ERR (8), EXT (4), DET (6)

### Test plan

- [ ] `do run_tests.do` — 89/89 passed
- [ ] Offline: `do run_tests.do DET-01` through `DET-06`
- [ ] Error: `do run_tests.do ERR-01` through `ERR-08`
- [ ] Paper: pdflatex + bibtex — 48 pages
- [ ] Verify chars: `wbopendata, indicator(SP.POP.TOTL) clear long` then `char list`
- [ ] Install: `net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace`

---

## 3. GitHub Release Note

**Tag:** v18.1.0
**Target:** main (after develop merge)
**Title:** Release v18.1.0: Discovery Commands, Char Metadata & Offline Testing

**Body:**

This is the largest update since v16.0 (2019). It introduces **offline discovery commands** for browsing the World Bank data catalog, a **YAML metadata architecture** replacing 89 per-indicator help files, a redesigned **sync system** with safe-by-default behavior, **variable-level `char` metadata** for self-documenting datasets, and **deterministic offline testing** with CSV fixtures. The QA suite grows from 44 to 89 tests across 17 categories.

### At a Glance

| Metric | v17.7.1 | v18.1.0 |
|--------|---------|---------|
| **Indicators** | 20,147 | 29,323 |
| **Data sources** | 51 | 71 |
| **Total tests** | 44 | 89 |
| **Test categories** | 9 | 17 |
| **`.ado` files** | 12 | 34 |
| **Metadata format** | 89 `.sthlp` files | 2 YAML files |

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
wbopendata, search(GDP) topic(3)

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

**Performance:** Frame-cached search (Stata 16+) returns results in <0.5s after initial 9s parse.

### Sync System Redesign (v18.0)

The sync command now defaults to a **safe dryrun preview**:

| Command | Behavior |
|---------|----------|
| `wbopendata, sync` | Preview metadata changes (dry run — always safe) |
| `wbopendata, sync detail` | Detailed preview with per-source/topic breakdown |
| `wbopendata, sync replace` | Apply metadata sync |
| `wbopendata, sync replace force` | Force re-download regardless of local version |

Three download pathways: Python canonical → pure-Stata fallback → GitHub releases.

### Char Metadata (v18.1)

Indicator codes and descriptive metadata stored as Stata **characteristics** on variables and `_dta`, following the `freduse` pattern (Drukker 2006). Datasets become self-documenting; metadata persists across save/use cycles.

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

### Bug Fixes

- **Compound quoting for SMCL tags**: metadata returns now handle embedded double quotes from `{browse "url"}` SMCL tags
- **YAML parser**: handles embedded quotes using Mata `st_sstore()` bypass
- **`foreach` with parentheses**: topic names containing parentheses no longer cause errors (switched to `gettoken` loop)
- **`_rc` leaking**: internal sub-calls properly isolated via `capture noisily`
- **Windows paths**: repo detection in QA suite now normalizes paths correctly
- **Stray `set trace on`**: removed from dead code in `_api_read.ado` and `_query_indicators.ado`

### Deprecations

| Deprecated | Replacement |
|------------|-------------|
| `update query` | `sync` |
| `update check` | `sync` / `checkupdate` |
| `update all` | `sync replace` |
| `metadataoffline` | Discovery commands (`sources`, `search`, `info`) |
| `syncforce` | `sync replace force` |
| `syncpreview` | `sync replace` |
| `syncdryrun` | `sync` |

### Quality Assurance: 89 Tests

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

### Installation

```stata
* Install from GitHub (latest)
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace

* After install, sync metadata
wbopendata, sync replace
```

### Full Changelog

**Compare:** [v17.7.1...v18.1.0](https://github.com/jpazvd/wbopendata/compare/v17.7.1...v18.1.0)

### References

- Drukker, D. M. (2006). Importing Federal Reserve economic data. *The Stata Journal*, 6(3), 384–396.
- Gould, W. (2001). Statistical software certification. *The Stata Journal*, 1(1), 29–50.

---

## 4. Tag v18.1.0

### Annotated tag message

```
wbopendata v18.1.0 — Discovery, Char Metadata & Offline Testing

Features (v18.0):
  - Discovery commands: sources, alltopics, search(), info()
  - YAML metadata architecture: 2 files replace 89 sthlp files
  - Sync system redesign: safe dryrun default, replace safety gate
  - Cache management: cache(info|checkversion|update|clear)
  - Modular architecture: 34 ado files

Features (v18.1):
  - Variable-level char metadata (default-on, nochar to suppress)
  - Deterministic offline testing via offline() option
  - Error condition tests via rcof methodology (Gould 2001)

Bug fixes:
  - Compound quoting for SMCL {browse} tags in metadata returns
  - YAML parser embedded quotes via Mata st_sstore() bypass
  - foreach failure with topic names containing parentheses
  - _rc leaking from internal sub-calls
  - Stray set trace on in dead code

QA: 89 tests across 17 categories (up from 44/9 in v17.7.1)
Indicators: 29,323 from 71 sources (up from 20,147 from 51)
Paper: 48-page Stata Journal manuscript with reproducible examples
```

### Command to create the annotated tag

Note: Delete the existing lightweight v18.1.0 tag first, then recreate as annotated.

```bash
# Delete existing lightweight tag (local + remote)
git tag -d v18.1.0
git push origin :refs/tags/v18.1.0

# Create annotated tag on main (after develop merge)
git tag -a v18.1.0 -m "wbopendata v18.1.0 — Discovery, Char Metadata & Offline Testing

Features (v18.0):
  - Discovery commands: sources, alltopics, search(), info()
  - YAML metadata architecture: 2 files replace 89 sthlp files
  - Sync system redesign: safe dryrun default, replace safety gate
  - Cache management: cache(info|checkversion|update|clear)
  - Modular architecture: 34 ado files

Features (v18.1):
  - Variable-level char metadata (default-on, nochar to suppress)
  - Deterministic offline testing via offline() option
  - Error condition tests via rcof methodology (Gould 2001)

Bug fixes:
  - Compound quoting for SMCL {browse} tags in metadata returns
  - YAML parser embedded quotes via Mata st_sstore() bypass
  - foreach failure with topic names containing parentheses
  - _rc leaking from internal sub-calls
  - Stray set trace on in dead code

QA: 89 tests across 17 categories (up from 44/9 in v17.7.1)
Indicators: 29,323 from 71 sources (up from 20,147 from 51)
Paper: 48-page Stata Journal manuscript with reproducible examples"

# Push tag
git push origin v18.1.0
```
