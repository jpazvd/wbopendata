# Release Notes

[← Back to README](README.md) | [Changelog](CHANGELOG.md) | [FAQ](doc/FAQ.md) | [Examples](doc/examples_gallery.md)

---

**Minimum requirement:** Stata 14 or later.

## wbopendata v18.7.0 — Shared Search-Alias Helper (Internal Refactor)

**Release Date:** April 25, 2026

---

### Highlights

Pure internal refactor — no user-facing syntax change. The hardcoded source-alias, source-full-name, and topic-name lookup tables previously duplicated inside both search backends (`__wbopendata_search.ado` for Stata 14–15 and `__wbopendata_search_cache.ado` for Stata 16+) have been extracted into a single shared helper, `__wbod_search_aliases.ado`. Each backend now calls the helper once before its row loop; the helper populates the lookup locals in the caller's scope via `c_local`, so the existing `` `src_alias_`src_id'' `` lookup pattern is preserved unchanged.

This closes the maintenance hazard flagged by code review on PR #86: adding a new World Bank source previously required editing both backends in lock-step. Future source additions now require editing the single helper only.

### Changes

| Area | Description |
| ---- | ----------- |
| **`__wbod_search_aliases.ado`** | New helper (v1.0.0) with 71 source aliases (`DoingB`, `WDI`, `SDGs`, etc.), 71 source full names, and 21 topic names. Populates locals in caller scope via `c_local`. |
| **`__wbopendata_search.ado`** | v2.6.1 → v2.7.0. 165-line inline lookup block replaced with a single helper call. |
| **`__wbopendata_search_cache.ado`** | v3.3.1 → v3.4.0. Same diff. |
| **Test coverage — pagination** | New HELP-55 / HELP-56 in `tests/test_help_examples.do` exercise the v18.5 `page(N)` option that was documented in the help file but never tested. |
| **Test coverage — cache & discovery** | New HELP-57 (`cachedays(30)`), HELP-58 (`verbose`), HELP-59 (`allsources`) close further documentation-vs-test audit gaps from v18.2 / v17.6. |
| **Net code change** | ~330 duplicated lines removed; ~106 lines net deletion across the package. |

### Examples (unchanged from v18.5+)

```stata
. wbopendata, search(GDP)
. wbopendata, searchsource(2)              // legend: WDI = World Development Indicators
. wbopendata, searchtopic(11)              // legend: [11] Poverty
. wbopendata, searchtopic(11) limit(20) page(2)   // pagination, now tested
```

### Test Results

- Full QA suite: **92/92 PASS** (run on `feature/dedup-search-aliases` @ `120cd8b`, 26m 15s)
- Help examples: **76/76 PASS** (including the 5 new HELP-55..59)
- Alias-helper smoke: **10/10 PASS** (`qa/smoke_search_aliases.do`)

### Full Changelog

**Compare:** [v18.6.1...v18.7.0](https://github.com/jpazvd/wbopendata/compare/v18.6.1...v18.7.0)

---

## wbopendata v18.6.1 — Fixes from PR #85 / #86 Review

**Release Date:** April 23, 2026

---

### Highlights

Three fix commits addressing inline review comments on the v18.6.0 production PRs. No new user-facing functionality; production correctness only.

### Changes

| Area | Description |
| ---- | ----------- |
| **Leading-zero source IDs in search display** | When the indicator YAML stored `source_id` as a string with a leading zero (e.g., `'02'`), the alias lookup `` "`src_alias_`src_id''" `` failed because the local table is keyed on bare integers (`src_alias_2`). Both `__wbopendata_search` (v2.6.0 → v2.6.1) and `__wbopendata_search_cache` (v3.3.0 → v3.3.1) now apply `real()` and reassign before the lookup, matching the fix already in `__wbod_get_source_name` v1.0.1. |
| **`__wbod_sync_preview` file-handle safety** | The version-extraction block previously wrapped `file open`, the read loop, and `file close` in a single `capture` block. A `file read` error would skip the close call and leak the open handle. Split into two captures (`__wbod_sync_preview` v1.4.0 → v1.4.1) so `file close` always runs. |
| **Help header date** | `wbopendata.sthlp` showed `21Apr2026`; corrected to `22Apr2026` to match the v18.6.0 release date. |
| **Package version alignment** | `src/wbopendata.pkg` was at `v 18.6.0` despite the v18.6.1 tag; bumped to align. |

### Full Changelog

**Compare:** [v18.6.0...v18.6.1](https://github.com/jpazvd/wbopendata/compare/v18.6.0...v18.6.1)

---

## wbopendata v18.6.0 — Sync Diff by Source

**Release Date:** April 22, 2026

---

### Highlights

After `wbopendata, sync replace` completes, a source-level breakdown table is now displayed showing how many indicators were added or removed per World Bank data source since the previous sync. Sources are sorted by absolute net change so the most-impacted databases appear first; only sources with actual changes are shown. Up to 10 sources are displayed by default; any beyond the limit are summarised in a footer line. The total row always shows the overall net.

### Changes

| Area | Description |
| ---- | ----------- |
| **`__wbod_sync_diff.ado`** | New helper (v1.0.0) snapshots indicator codes and source names before sync, then merges against the new YAML after completion. Codes are extracted into `str244` to prevent silent truncation of long indicator codes that previously caused the same indicator to appear as both added and removed. |
| **Sync diff display** | Source breakdown table appears automatically after `sync replace` succeeds. Sample output: `Gender Statistics  188   56  +132`. |
| **`sync detail` source table fix** | Now correctly resolves source names for IDs stored with leading zeros in the indicator YAML (e.g., `'02'` → `World Development Indicators`). World Bank vintage/archive sources with non-standard IDs (prefixed `VG*`) are collapsed into a single summary line rather than flooding the table with hundreds of 1-indicator entries. |
| **`[sync & see breakdown]` link** | The hyperlink next to `Change: +N new` in the Remote Status section now runs `wbopendata, sync replace` so clicking it performs the sync and immediately shows the breakdown. |
| **QA log filenames** | `qa/run_tests.do` log filename now includes `HH:MM` time suffix so multiple runs on the same day each write to a unique file, avoiding Windows file-lock failures. |

### Examples

```stata
. wbopendata, sync replace
*  → followed automatically by the source-level diff table
```

### Full Changelog

**Compare:** [v18.5.0...v18.6.0](https://github.com/jpazvd/wbopendata/compare/v18.5.0...v18.6.0)

---

## wbopendata v18.5.0 — Paginated Search Results

**Release Date:** April 21, 2026

---

### Highlights

Search results (by keyword, source, or topic) can now be navigated across multiple pages. A new `page(#)` option, paired with the existing `limit(#)` per-page size, lets users reach records beyond the first page. Clickable `[Prev]` / `[Next]` / page-number links are rendered below the results whenever matches exceed one page. Small result sets (≤30 matches) continue to render on a single page with no pagination nav, so the UX only gets more complex when it actually needs to.

### Changes

| Area | Description |
| ---- | ----------- |
| **`page(#)` option** | New integer option on `search()` / `searchsource()` / `searchtopic()`. Default: `1`. Total pages = `ceil(matches / limit)`. |
| **Clickable nav** | `[Prev]` / `[Next]` and per-page-number SMCL links rendered below results when `total_pages > 1`. Collapses to `[1] [2] ... [N-1] [N]` for >10 pages. |
| **Dynamic single-page** | Result sets of ≤30 matches render on a single page with no pagination nav, matching pre-v18.5 behavior. |
| **Return scalars** | `r(page)` and `r(n_pages)` added for scripting. |
| **Shared helper** | New `__wbod_search_pagenav.ado` renders pagination nav for both the Stata 14-15 and Stata 16+ search backends. |

### Examples

```stata
. wbopendata, searchtopic(11) limit(20) page(2)   // records 21-40 in topic 11
. wbopendata, search(poverty) limit(10) page(3)   // third page, 10 per page
```

### Full Changelog

**Compare:** [v18.4.1...v18.5.0](https://github.com/jpazvd/wbopendata/compare/v18.4.1...v18.5.0)

---

## wbopendata v18.3.2 — Cache Architecture Refinement

**Release Date:** February 23, 2026

---

### Highlights

This patch fixes cache architecture completeness and adds documentation for proper cache consolidation operations. All three metadata frames (indicators, sources, topics) are now properly invalidated during sync operations, and cache manifest format is documented to prevent future parsing breaks.

### Changes

| Area | Description |
| ---- | ----------- |
| **Frame Cache Invalidation** | All three metadata frames (indicators, sources, topics) now properly dropped on sync |
| **Cache Manifest** | Documented pipe-delimiter format and TTL assumptions for cache consolidation |
| **Test Documentation** | Clarified SYNC-05 test purpose as cross-validation (v18.3.0+) |

### Full Changelog

**Compare:** [v18.3.1...v18.3.2](https://github.com/jpazvd/wbopendata/compare/v18.3.1...v18.3.2)

---

## wbopendata v18.3.1 — Reset Data Cache & Verbose Option

**Release Date:** February 23, 2026

---

### Highlights

This patch adds **`resetdatacache`** to expire all cached data entries without deleting files (fresh data re-fetched on next query), and a **`verbose`** option for targeted error handling in cache and metadata operations.

### New Features

| Feature | Description |
| ------- | ----------- |
| **`resetdatacache`** | Expire all cached entries without deleting files (re-fetched on next query) |
| **`verbose`** | Targeted error handling for cache and metadata operations |

### Full Changelog

**Compare:** [v18.3.0...v18.3.1](https://github.com/jpazvd/wbopendata/compare/v18.3.0...v18.3.1)

---

## wbopendata v18.3.0 — Cache-Aware Discovery, Configurable TTL & QA Hardening

**Release Date:** February 23, 2026

---

### Highlights

This release adds **YAML metadata lookup on cache hit** so that discovery commands (`search`, `info`, `sources`, `alltopics`) resolve from local YAML without API calls when the cache is current. A new **`cachedays(#)`** option lets users configure the data response cache TTL (default 7 days). The QA suite is hardened with **post-sync validation** (hard asserts on YAML file creation) and **conditional sync optimization** (~50% runtime reduction).

### New Features

| Feature | Description |
| ------- | ----------- |
| **Cache-aware discovery** | Discovery commands skip API calls when local YAML cache is current |
| **`cachedays(#)`** | Configurable data cache TTL in days (default 7) |

### Quality Assurance

- Post-sync validation: every sync test now hard-asserts all 3 YAML files exist (prevents silent false-pass like v18.1.1)
- Conditional sync: 5 tests reuse existing cache instead of redundant re-downloads
- Clean-slate startup: `clearcache` + `cleardatacache` before `net install` ensures deterministic state
- Expected runtime: ~15 min (down from ~28 min in v18.2.0)

### Full Changelog

**Compare:** [v18.2.0...v18.3.0](https://github.com/jpazvd/wbopendata/compare/v18.2.0...v18.3.0)

---

## wbopendata v18.2.0 — Data Response Cache & Cache Consolidation

**Release Date:** February 22, 2026

---

### Highlights

This release adds a **data response cache** that stores API responses locally with a 7-day TTL, so repeated queries for the same indicator/country/language return instantly from disk. All cache operations are **consolidated to `sysdir_plus`**, eliminating the split-brain between `sysdir_personal` and `sysdir_plus`. Three orphaned standalone cache files are inlined into their parent programs.

### New Features

| Feature | Description |
| ------- | ----------- |
| **Data response cache** | API responses cached locally; 7-day TTL; on by default |
| **`nocache`** | Bypass data cache for a single query |
| **`cleardatacache`** | Remove all cached API response files |
| **`cacheinfo`** | Now displays data cache statistics alongside metadata cache status |

### Internal Changes

- Cache consolidation to `sysdir_plus` (no more `sysdir_personal` split)
- YAML path resolver simplified from 5-level to 2-level (`findfile` + fallback)
- Frame cache (`_wbod_indicators`) invalidated on sync
- Inlined `_wbopendata_download_yaml.ado`, `_wbopendata_cache_clear.ado`, `_wbopendata_cache_info.ado`

### Full Changelog

**Compare:** [v18.1.1...v18.2.0](https://github.com/jpazvd/wbopendata/compare/v18.1.1...v18.2.0)

---

## wbopendata v18.1.1 — Search Fixes, XML Robustness & Discovery Regression Tests

**Release Date:** February 22, 2026

---

### Highlights

This patch release fixes **clickable SMCL links** in search results (`searchsource`/`searchtopic`), adds robustness for **self-closing XML tags** in World Bank API responses, and expands the discovery test suite with **3 regression tests** (DISC-08/09/10), bringing the total to **92 tests** across 20 categories.

### Bug Fixes

- **Search SMCL links**: `searchsource()` and `searchtopic()` clickable links in discovery results now generate correct commands
- **Self-closing XML tags**: API reader handles `<wb:value />` empty elements without parser errors
- **YAML parser**: Synced `yaml_read.ado` v1.9.2 with list/stack fixes from yaml-dev

### New Tests

| Test | Description |
| ---- | ----------- |
| **DISC-08** | Browse by `searchsource`/`searchtopic` via main command |
| **DISC-09** | Search results include topic display names (not empty) |
| **DISC-10** | Info lookup for indicator with multiple topics |

### Quality Assurance

| Metric | v18.1.0 | v18.1.1 |
| ------ | ------- | ------- |
| **Total Tests** | 89 | 92 |
| **Test Categories** | 17 | 20 |
| **Final Run** | 89 passed, 0 failed | 92 passed, 0 failed |
| **Duration** | 5m 4s | 5m 54s |

### Full Changelog

**Compare:** [v18.1.0...v18.1.1](https://github.com/jpazvd/wbopendata/compare/v18.1.0...v18.1.1)

---

## wbopendata v18.1.0 — Char Metadata, Offline Testing & Compound Quoting Fix

**Release Date:** February 10, 2026

---

### Highlights

This release adds **variable-level char metadata** (indicator code stored as Stata `char` on data variables), introduces an **offline deterministic testing** framework (`offline()` option for fixture-based QA), fixes a **compound quoting bug** that broke metadata returns containing SMCL `{browse}` tags, and expands the test suite to **89 tests** across 17 categories.

### New Features

| Feature | Description |
| ------- | ----------- |
| **Char metadata** | Indicator code automatically stored as `char` on data variables (suppress with `nochar`) |
| **Offline testing** | `offline(path)` option loads CSV fixtures instead of calling World Bank API |
| **CHAR tests (6)** | Characteristic metadata validation across download modes |
| **ERR tests (8)** | Error handling validation using `rcof` methodology (Gould 2001) |
| **EXT tests (4)** | Extended option combination coverage |
| **DET tests (6)** | Deterministic tests using offline CSV fixtures |

### Bug Fixes

- **Compound quoting for SMCL tags**: `sourcecite`, `description_line`, and `note_line` returns now use compound quotes `` `"..."' `` to handle embedded double quotes from `{browse "url"}` SMCL tags
- **Stray `set trace on`**: Removed dead-code instances in `_api_read.ado` and `_query_indicators.ado`

### Deprecations

The following options now display user-facing deprecation warnings:

- `update query`, `update check`, `update all` (use `sync` commands instead)
- `metadataoffline` (use `offline()` option instead)
- `syncforce`, `syncpreview`, `syncdryrun` (use `sync replace [force]` instead)

### Quality Assurance

| Metric | v18.0.0 | v18.1.0 |
| ------ | ------- | ------- |
| **Total Tests** | 65 | 89 |
| **Test Categories** | 15 | 17 |
| **Final Run** | 65 passed, 0 failed | 89 passed, 0 failed |

New test categories: CHAR (char metadata), ERR (error handling), EXT (extended formats), DET (deterministic/offline).

### Full Changelog

**Compare:** [v18.0.0...v18.1.0](https://github.com/jpazvd/wbopendata/compare/v18.0.0...v18.1.0)

---

## wbopendata v18.0.0 — Discovery Commands, YAML Metadata & Sync Redesign

**Release Date:** February 9, 2026

---

### 🎉 Highlights

This is a **major release** that introduces offline discovery commands for browsing the World Bank data catalog, replaces 89 per-indicator help files with a compact YAML metadata architecture, and redesigns the sync system with a safe dryrun-by-default workflow.

### 🔍 Discovery Commands

Browse the World Bank data catalog directly from Stata — no network required after initial sync:

| Command | Description |
|---------|-------------|
| `wbopendata, sources` | List all data sources with clickable navigation |
| `wbopendata, allsources` | Detailed source listing with indicator counts |
| `wbopendata, topics` | List topic categories |
| `wbopendata, alltopics` | Detailed topic listing with indicator counts |
| `wbopendata, search(query)` | Search indicators by keyword with topic/field filters |
| `wbopendata, info(ID)` | Display full indicator metadata with clickable URLs |

```stata
* Search for GDP indicators in topic 3
wbopendata, search(GDP) topic(3)

* Get detailed metadata for a specific indicator
wbopendata, info(NY.GDP.MKTP.CD)

* Browse all data sources
wbopendata, sources
```

### 🔄 Sync System Redesign

The sync command now defaults to a **safe dryrun preview**. The `replace` option is an explicit safety gate required to apply changes:

| Command | Behavior |
|---------|----------|
| `wbopendata, sync` | Preview metadata changes (dry run) |
| `wbopendata, sync detail` | Detailed preview with per-source/topic breakdown |
| `wbopendata, sync replace` | Apply metadata sync |
| `wbopendata, sync replace force` | Force re-download regardless of local version |

Backward-compatible aliases: `syncdryrun` → `sync`, `syncpreview` → `sync replace`, `syncforce` → `sync replace force`.

### 📦 YAML Metadata Architecture

Replaced **89 per-indicator `.sthlp` files** with 2 compact YAML metadata files:

| File | Size | Contents |
|------|------|----------|
| `_wbopendata_indicators.yaml` | 18 MB | ~29,323 indicators with full metadata |
| `_wbopendata_parameters.yaml` | 5 KB | Configuration parameters |

**Performance:** Frame-cached search (Stata 16+) returns results in <0.5s after initial parse. Older Stata versions use per-call parsing with comparable results.

### 🗃️ Cache Management

| Command | Description |
|---------|-------------|
| `wbopendata, cache(info)` | Display cache status and file locations |
| `wbopendata, cache(checkversion)` | Check for newer GitHub releases |
| `wbopendata, cache(update)` | Update cached metadata files |
| `wbopendata, cache(clear)` | Clear local metadata cache |

### 🏗️ Modular Architecture

The codebase now comprises **34 `.ado` files** organized with a consistent naming convention:

- `_` prefix — sub-routines (e.g., `_wbopendata_search`)
- `__` prefix — internal sub-sub-routines (e.g., `__wbopendata_search_cache`)

Key layers: discovery, search/parsing, metadata utilities, cache management, sync orchestration, data download, and formatting.

### 🧪 Quality Assurance

| Metric | v17.7.1 | v18.0.0 |
|--------|---------|---------|
| **Total Tests** | 44 | 65 |
| **Test Categories** | 9 | 15 |
| **Final Run** | — | 65 passed, 0 failed |

**Test Categories:** ENV, DL, FMT, CTRY, REG, LW, UPD, TOPIC, LANG, DESC, PROJ, ADV, CACHE, SYNC, DISC

New test categories added: CACHE (cache lifecycle), SYNC (sync dryrun/replace/force), DISC (offline discovery commands).

The QA framework now includes **history tracking** with drift safeguards to prevent test artifacts from writing to incorrect locations.

### 🐛 Bug Fixes

- Fixed YAML parser to handle embedded quotes using Mata `st_sstore()` bypass
- Fixed `foreach` failure with topic names containing parentheses (switched to `gettoken` loop)
- Fixed Windows path normalization for repo detection in QA suite
- Fixed `_rc` leaking from internal sub-calls via `capture noisily` isolation
- Fixed pkg file validation to read both `f ` (lowercase) and `F ` (uppercase) entries

### 🔀 Merged Pull Requests

- Discovery commands and enhanced search ([#4](https://github.com/jpazvd/wbopendata/pull/4))
- Sync preview and stats history (feat/discovery-sync)
- QA test suite expansion and fixes ([#6](https://github.com/jpazvd/wbopendata/pull/6))
- Release v18.0.0 ([#5](https://github.com/jpazvd/wbopendata/pull/5))

### Full Changelog

**Compare:** [v17.7.1...v18.0.0](https://github.com/jpazvd/wbopendata/compare/v17.7.1...v18.0.0)

---

## wbopendata v17.7.1 — Test Suite Expansion & Documentation Overhaul

**Release Date:** January 4, 2026

---

### 🎉 Highlights

This release significantly expands the test suite to 44 tests across 9 categories and adds comprehensive documentation cross-references. The testing guide now includes a detailed philosophy section comparing wbopendata's integration testing approach with CRAN/PyPI offline testing patterns.

### 🧪 Test Suite Expansion

| Metric | v17.7 | v17.7.1 |
|--------|-------|---------|
| **Total Tests** | 36 | 44 |
| **Test Categories** | 7 | 9 |
| **New Categories** | - | TOPIC, LANG, Advanced |

**New Tests Added:**
- TOPIC-01: Topics API download validation
- LANG-01: Language option (Spanish metadata)
- PROJ-01: Projection data (source=40)
- FMT-04: nobasic option verification
- DESC-01: Describe-only mode
- META-01: nometadata verification
- CTRY-11: Admin regions (adminr option)
- DATE-01: Date range option

### 📚 Documentation Improvements

- Added testing philosophy section to TESTING_GUIDE.md
- Cross-referenced all critical documentation files
- Updated version references across all docs
- Enhanced changelog with v17.5–v17.7.1 entries

---

## wbopendata v17.7 — Basic Metadata by Default

**Release Date:** January 2, 2026

---

### 🎉 Highlights

This release adds **basic country context variables by default** to all downloads, providing immediate access to region, income level, and lending type information without requiring the `match()` option.

### 📊 New Default Variables

Every download now includes these 8 variables automatically:

| Variable | Description |
|----------|-------------|
| `region` | Region code (e.g., "ECS", "LCN") |
| `regionname` | Region name (e.g., "Europe & Central Asia") |
| `adminregion` | Admin region code |
| `adminregionname` | Admin region name |
| `incomelevel` | Income level code (e.g., "HIC", "LMC") |
| `incomelevelname` | Income level name |
| `lendingtype` | Lending type code |
| `lendingtypename` | Lending type name |

### 🆕 New Options

- **`nobasic`**: Suppress default country context variables for minimal downloads

### Usage Examples

```stata
* Default: includes basic metadata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long
desc  // Shows 12 variables including 8 basic metadata

* Minimal: suppress basic metadata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long nobasic
desc  // Shows only 4 core variables
```

---

## wbopendata v17.6 — Graph Metadata Features

**Release Date:** December 28, 2025

---

### 🎉 Highlights

This release adds powerful **graph metadata features** for creating publication-ready visualizations with automatic text formatting and dynamic subtitles.

### 🆕 New Options

| Option | Description |
|--------|-------------|
| `linewrap()` | Wrap metadata text (name, description, note) |
| `maxlength()` | Set maximum characters per line (default: 50) |
| `linewrapformat()` | Output format: stack, newline, lines, all |

### 📈 New Return Values

| Return | Description |
|--------|-------------|
| `r(name#_stack)` | Wrapped indicator name for titles |
| `r(description#_newline)` | Wrapped description with `\n` |
| `r(latest)` | Dynamic subtitle string |
| `r(latest_ncountries)` | Number of countries |
| `r(latest_avgyear)` | Average year of data |
| `r(sourcecite#)` | Clean organization name |

### Usage Examples

```stata
* Graph with wrapped title and dynamic subtitle
wbopendata, indicator(SP.DYN.LE00.IN) clear linewrap(name description) maxlength(50)
twoway scatter ..., title("`r(name1_stack)'") subtitle("`r(latest)'")

* Get text with newline characters for notes
wbopendata, indicator(SP.DYN.LE00.IN) clear linewrap(description) linewrapformat(newline)
local desc = r(description1_newline)
```

---

## wbopendata v17.1 — Documentation Overhaul & Community Bug Fixes

**Release Date:** December 21, 2025

---

### 🎉 Highlights

This release focuses on community-driven bug fixes, comprehensive documentation improvements, and repository professionalization. Special thanks to our community contributors who reported issues and helped improve the package.

### 📊 Updated Metadata (December 2025)

| Metric | Value |
|--------|-------|
| **Total Indicators** | 20,147 |
| **Data Sources** | 51 |
| **Topic Categories** | 21 |
| **Countries & Regions** | 296 |
| **Time Coverage** | 1960–present |

**New Data Sources Added:**
- Source 92: Disability Data Hub (DDH) — 1,333 indicators
- Source 93: FPN Datahub Archive — 42 indicators

---

### 🐛 Bug Fixes

| Issue | Description | Contributor |
|-------|-------------|-------------|
| [#33](https://github.com/jpazvd/wbopendata/issues/33) | Fixed `latest` option functionality | @lucaslindoso |
| [#35](https://github.com/jpazvd/wbopendata/issues/35) | Fixed country metadata retrieval | @lucaslindoso |
| [#45](https://github.com/jpazvd/wbopendata/issues/45) | Resolved URL construction errors | @lucaslindoso |
| [#46](https://github.com/jpazvd/wbopendata/issues/46) | Fixed varlist option handling | @lucaslindoso |
| [#51](https://github.com/jpazvd/wbopendata/issues/51) | Updated documentation to match API behavior | @daniel-klein |

---

### 📚 New Documentation

- **[FAQ](doc/FAQ.md)** — Common questions compiled from GitHub issues
- **[Examples Gallery](doc/examples_gallery.md)** — Visual showcase with example figures and ready-to-run Stata code
- **Example Do-Files:**
  - [`basic_usage.do`](doc/examples/basic_usage.do) — 10 introductory examples
  - [`advanced_usage.do`](doc/examples/advanced_usage.do) — 10 advanced use cases
- **Enhanced [README](README.md)** — Installation instructions, quick start guide, documentation table, and contributing guidelines
- **Updated Help File** — Added Community Contributors section acknowledging bug reporters

---

### 🧪 Quality Assurance

- **[Test Protocol](qa/test_protocol.md)** — Comprehensive testing checklist for releases
- **[Automated Test Suite](qa/run_tests.do)** — 257-line test script covering all major functionality

---

### 📁 Repository Organization

Reorganized documentation into structured subdirectories:

```
doc/
├── plans/      # Future improvement plans
├── logs/       # Development logs  
├── images/     # Example figures
└── examples/   # Example do-files

qa/             # Quality assurance materials
```

---

### 👥 Community Contributors

We thank the following contributors for their bug reports and suggestions:

- **@ckrf** — Country metadata fixes ([PR #44](https://github.com/jpazvd/wbopendata/pull/44)) 🆕
- **@lucaslindoso** — Issues #33, #35, #45, #46
- **@daniel-klein** — Issue #51
- **@randrescastaneda** — Extensive testing and feedback
- **@zhaowill** — Early adoption and testing

---

### 📦 Installation

```stata
* Install from SSC (recommended)
ssc install wbopendata, replace

* Install from GitHub (latest version)
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace
```

---

### 🔗 Resources

| Resource | Description |
|----------|-------------|
| [Full Documentation](doc/wbopendata.md) | Complete command reference |
| [Examples Gallery](doc/examples_gallery.md) | Visual examples with code |
| [FAQ](doc/FAQ.md) | Frequently asked questions |
| [Report Issues](https://github.com/jpazvd/wbopendata/issues) | Bug reports and feature requests |

---

### 🔀 Merged Pull Requests

- Country metadata fixes by @ckrf in [#44](https://github.com/jpazvd/wbopendata/pull/44)
- v17 by @jpazvd in [#50](https://github.com/jpazvd/wbopendata/pull/50)
- update 20240702 by @jpazvd in [#52](https://github.com/jpazvd/wbopendata/pull/52)
- Develop by @jpazvd in [#53](https://github.com/jpazvd/wbopendata/pull/53)

### 🌟 New Contributors

- **@ckrf** made their first contribution in [#44](https://github.com/jpazvd/wbopendata/pull/44)

---

### Full Changelog

**Compare:** [v16.3...v17.1](https://github.com/jpazvd/wbopendata/compare/v16.3...v17.1)

---

## Previous Releases

For complete version history including all releases from v1.0.0 (2011) to present, see the **[Changelog](CHANGELOG.md)**.

### Version Timeline

```
2026 ─┬─ v18.3.1          Reset data cache, verbose option
      ├─ v18.3.0          Cache-aware discovery, configurable TTL
      ├─ v18.2.0          Data response cache, cache consolidation
      ├─ v18.1.1          Search fixes, XML robustness, 92 tests
      ├─ v18.1.0          Char metadata, offline testing, 89 tests
      ├─ v18.0.0          Discovery commands, YAML metadata, sync redesign
      ├─ v17.7.1          Test suite expansion, documentation
      ├─ v17.7            Basic country context by default
      └─ v17.6            Graph metadata (linewrap) features

2025 ─── v17.1            Community bug fixes, documentation overhaul

2023 ─── v17.0            Region metadata, enhanced matching

2020 ─┬─ v16.3            HTTPS API migration
      ├─ v16.2.2–16.2.3   Metadata query rewrite, server update
      └─ v16.1–16.2.1     Offline metadata option, flow check

2019 ─┬─ v16.0–16.0.1     Multiple indicators, modular architecture, match()
      ├─ v15.1            Update options, 16,000+ indicators
      ├─ v15.0.1          Maintenance release
      ├─ v14.2–15.0       Bug fixes, major version bump
      ├─ v14.1            Indicator update + nopreserve
      └─ v14.0            New API server

2016 ─── v13.5            Last SSC release before major overhaul ◄──

2014 ─┬─ v13.3–13.4       Error control (clear option), long reshape
      └─ v13.0–13.2       Duplicate fix, error control, regional codes, 9,960 indicators

2013 ─── v12.0            7,349 indicators, return list enhancements

...

2011 ─── v1.0.0           Initial launch ◄──
```

### SSC vs GitHub Versions

| Channel | Current | Notes |
|---------|---------|-------|
| **[SSC](https://ideas.repec.org/c/boc/bocode/s457234.html)** | v17.7.1 | Stable, install via `ssc install wbopendata` |
| **GitHub** | v18.3.1 | Latest features, install via `net install` |

> **Note:** The SSC version (v17.7.1) is several releases behind the latest GitHub version. For the newest features including discovery commands, data response cache, configurable TTL, and reset data cache, install from GitHub.

---

*For questions or support, visit [jpazvd.github.io](https://jpazvd.github.io) or open an [issue](https://github.com/jpazvd/wbopendata/issues).*
