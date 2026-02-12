# wbopendata Roadmap

[← Back to README](../../README.md) | [Doc Hub](../README.md) | [FAQ](../user-guide/FAQ.md) | [Examples](../user-guide/examples/)

---

## Overview

This roadmap consolidates all improvement plans and enhancement ideas for `wbopendata`. It reflects the current state after the v18.0.0 release and prioritizes features based on user impact and implementation effort.

**Last Updated:** February 12, 2026
**Current Version:** v18.1.0 (released)
**Reference Implementations:** unicefData, yaml.ado, stataci

---

## ✅ Completed in v17.x & v18.x

### v18.0.0 (February 2026) — Released
- [x] Discovery commands: `sources`, `allsources`, `topics`, `alltopics`, `search()`, `info()`
- [x] YAML metadata architecture: replaced 89 per-indicator sthlp files with 2 YAML files
- [x] Sync system redesign: `sync` (dryrun), `sync replace` (apply), `sync replace force`
- [x] Cache management: `cache(info|checkversion|update|clear)`
- [x] Modular architecture: 34 `.ado` files with `_`/`__` naming convention
- [x] Expanded test suite to 65 tests across 15 categories
- [x] Auto-detecting repo paths for multi-machine test compatibility
- [x] Version bump to 18.0.0 with consolidated package files
- [x] Workflow migration: metadata updates via GitHub Actions

### v18.1.0 (February 2026) — Released
- [x] Variable-level char metadata (default-on, `nochar` to suppress)
- [x] Offline deterministic testing (`offline()` option, Phase 6 Gould 2001)
- [x] Compound quoting fix for SMCL `{browse}` tags in metadata returns
- [x] Deprecated legacy options with user-facing warnings
- [x] 24 new ERR tests using `rcof` methodology
- [x] EXT and DET test categories
- [x] Expanded test suite to 89 tests across 17 categories

### v17.x (December 2025 - January 2026)
- [x] Documentation reorganization with user-guide/, reference/, roadmap/ structure
- [x] Comprehensive doc/README.md navigation hub
- [x] Consolidated examples in single location with assets
- [x] Updated all internal documentation links
- [x] Basic metadata (`region`, `income`, etc.) included by default
- [x] `nobasic` option to suppress default metadata variables

### v17.4 (December 2025)
- [x] `linewrap()` option with `maxlength()` for graph-ready metadata
- [x] Multiple `maxlength()` values per field
- [x] Dynamic subtitle returns: `r(latest)`, `r(latest_ncountries)`, `r(latest_avgyear)`
- [x] Graph metadata returns: `r(sourcecite#)`, `r(name#_stack)`, `r(description#_stack)`
- [x] New utilities: `_linewrap.ado`, `_metadata_linewrap.ado`
- [x] Examples gallery with embedded figures

### v17.1 (December 2025)
- [x] Fixed `latest` option for long indicator names (#33)
- [x] Fixed country metadata sub-options (#35)
- [x] Fixed URL parsing errors in metadata (#45)
- [x] Fixed variable list handling (#46)
- [x] Updated `match()` option documentation (#51)

---

## 🎯 Priority Matrix

| Priority | Feature | Status | Impact | Effort | Target |
|----------|---------|--------|--------|--------|--------|
| **P1** | Discovery subcommands (search, info) | ✅ Done | High | Medium | v18.0 |
| **P1** | YAML-based metadata sync | ✅ Done | High | High | v18.0 |
| **P1** | Helper ado implementations | ✅ Done | High | Medium | v18.0 |
| **P1** | Char metadata & offline testing | ✅ Done | High | Medium | v18.1 |
| **P2** | Search index optimization | 🟢 Planned | Medium | Low | v18.2 |
| **P2** | Progress indicators | 🟢 Planned | Medium | Low | v18.2 |
| **P3** | Batch download mode | 🟢 Planned | Low | Low | v18.2 |
| **P3** | Favorites/bookmarks | 🟢 Planned | Low | Low | v18.2 |
| **P3** | Multiple output formats | 🟢 Planned | Low | Medium | v18.2 |

---

## ✅ COMPLETED PHASES (v18.0–v18.1)

All P1 implementation phases are complete. The infrastructure, helper ADOs, discovery commands, YAML population, and integration testing have been delivered.

### PHASE 1: Helper ADO Implementation — Done (v18.0)

1. **_wbopendata_cache.ado**
   - [x] `cache, info` — Display cache location, version, timestamp
   - [x] `cache, checkversion` — Compare local vs GitHub versions
   - [x] `cache, update [force]` — Download/update YAML from GitHub
   - [x] `cache, clear` — Remove cached files
   - **Test:** CACHE-01 to CACHE-08 (all passing)

2. **_wbopendata_get_yaml_path.ado**
   - [x] Return path to cached or packaged YAML
   - [x] Priority: cache > PLUS > adopath(findfile) > cwd
   - [x] Return source indicator (cache vs package)
   - **Test:** CACHE-02 (passing)

3. **_wbopendata_download_yaml.ado**
   - [x] Download from GitHub releases
   - [x] Validate file integrity
   - [x] Populate cache directory
   - **Test:** SYNC-01 to SYNC-05 (all passing)

### PHASE 2: Discovery Commands — Done (v18.0)

4. **_wbopendata_search.ado**
   - [x] Parse YAML indicators metadata (~29,323 indicators)
   - [x] Search by keyword with topic/field/source filters
   - [x] Frame-cached search (<0.5s after initial parse)
   - **Test:** DISC-01 to DISC-07 (all passing)

5. **_wbopendata_info.ado**
   - [x] Display full metadata for single indicator
   - [x] Clickable URLs via SMCL `{browse}` tags
   - **Test:** DISC tests (passing)

### PHASE 3: YAML Metadata Population — Done (v18.0)

6. **YAML files populated**
   - [x] _wbopendata_indicators.yaml — ~29,323 indicators (18 MB)
   - [x] _wbopendata_sources.yaml — All data sources
   - [x] _wbopendata_topics.yaml — All topic categories
   - [x] _wbopendata_parameters.yaml — Configuration parameters

### PHASE 4: Integration & Testing — Done (v18.1)

7. **Integration testing**
   - [x] Full test suite: 89 tests, 17 categories, all passing
   - [x] CACHE, SYNC, DISC categories all passing
   - [x] ERR tests with `rcof` methodology (24 tests)
   - [x] DET tests with offline CSV fixtures

8. **Documentation**
   - [x] Updated wbopendata.sthlp with discovery examples
   - [x] YAML caching and sync documented
   - [x] Offline testing framework (`offline()` option)
   - [x] Paper updated for 89-test suite

---

## ✅ P1: High Priority — Completed (v18.0–v18.1)

### 1.1 Discovery Subcommands — Done

**Status:** Fully implemented and tested.

```stata
* Search indicators by keyword
wbopendata, search("education")
wbopendata, search("GDP") limit(20) source(2)

* Get detailed metadata for indicator
wbopendata, info("SE.ADT.LITR.ZS")
```

**Implementation:**
- [x] Main command syntax in wbopendata.ado
- [x] `_wbopendata_search.ado` — Frame-cached YAML parsing with filters
- [x] `_wbopendata_info.ado` — Full indicator metadata display
- [x] YAML metadata files populated (~29,323 indicators)
- **Test Coverage:** 89/89 (DISC-01 to DISC-07 + all other categories)

### 1.2 YAML-Based Metadata System — Done

**Status:** Fully implemented and tested.

**Commands:**
```stata
wbopendata, sync              // Preview metadata changes (dryrun)
wbopendata, sync replace      // Apply metadata sync
wbopendata, checkupdate       // Check for updates
wbopendata, clearcache        // Clear local cache
```

**Implementation:**
- [x] `_wbopendata_cache.ado` — Cache operations (info, update, clear)
- [x] `_wbopendata_download_yaml.ado` — GitHub download logic
- [x] `_wbopendata_check_version.ado` — Version comparison
- [x] `_wbopendata_get_yaml_path.ado` — Cache/PLUS/adopath/cwd resolution
- [x] All 4 YAML files populated with live data
- **Dependencies:** `yaml.ado` (bundled in package)
- **Test Coverage:** CACHE-01 to SYNC-05 (all passing)

---

## 🟡 P2: Medium Priority (v18.1)

### 2.1 Caching System

```stata
* Cache data locally for faster repeated access
wbopendata, indicator(SP.POP.TOTL) cache
wbopendata, indicator(SP.POP.TOTL) cache(refresh)
wbopendata, clearcache

* Configure cache directory
global WBOPENDATA_CACHE "D:/data/wbcache"
```

### 2.2 Progress Indicators

```stata
wbopendata, indicator(SP.POP.TOTL) progress

* Output:
* Downloading indicator SP.POP.TOTL...
*   Countries: [##########----------] 50% (128/256)
```

### 2.3 Built-in Diagnostics

```stata
wbopendata, check

* Output:
*   wbopendata version: 17.4 ✓
*   API connection: OK ✓
*   Dependencies: all installed ✓
*   Cache status: 15 indicators
```

---

## 🟢 P3: Lower Priority (v18.2+)

### 3.1 Batch Download Mode

```stata
wbopendata batch using "my_indicators.txt", clear
```

### 3.2 Favorites/Bookmarks

```stata
wbopendata favorite add SP.POP.TOTL "Population"
wbopendata favorite list
wbopendata, favorite(1) clear
```

### 3.3 Multiple Output Formats

```stata
wbopendata, indicator(SP.POP.TOTL) export(excel, "population.xlsx")
wbopendata, indicator(SP.POP.TOTL) export(csv, "population.csv")
```

### 3.4 Multi-Language Dialogs

- English, Spanish, French dialog files
- Like `datazoom_*_en.dlg` pattern

---

## 🐛 Open Issues

### High Priority
| Issue | Title | Status |
|-------|-------|--------|
| [#54](https://github.com/jpazvd/wbopendata/issues/54) | Country import issue | Investigate |
| [#39](https://github.com/jpazvd/wbopendata/issues/39) | Source missing in metadata | Investigate |

### Medium Priority
| Issue | Title | Status |
|-------|-------|--------|
| [#48](https://github.com/jpazvd/wbopendata/issues/48) | Red text display | Review SMCL |
| [#47](https://github.com/jpazvd/wbopendata/issues/47) | AFE/AFW as aggregates | Update metadata |
| [#49](https://github.com/jpazvd/wbopendata/issues/49) | WDI version selection | Document API |

### Closed in v17.x
- ~~#33~~, ~~#35~~, ~~#45~~, ~~#46~~, ~~#51~~ — Fixed and closed

---

## 📐 Architecture Guidelines

### File Organization
```
src/
├── w/
│   ├── wbopendata.ado          # Main entry point
│   ├── wbopendata.sthlp        # Help file
│   └── wbopendata.dlg          # Dialog
└── _/
    ├── _api_read.ado           # API communication
    ├── _query.ado              # Query building
    ├── _query_metadata.ado     # Metadata parsing
    ├── _linewrap.ado           # Text wrapping
    └── _wbopendata_*.yaml      # Metadata files

doc/
├── README.md                   # Navigation hub
├── wbopendata.md              # Complete help
├── user-guide/
│   ├── examples_gallery.md    # Visual guide
│   ├── FAQ.md                 # Troubleshooting
│   └── examples/              # Runnable code
└── roadmap/
    └── ROADMAP.md             # This file

../.github/
└── STATA_ADO_BEST_PRACTICES.md  # Workspace-wide standards
```

### Naming Conventions
| Type | Pattern | Example |
|------|---------|---------|
| Main command | lowercase | `wbopendata.ado` |
| Helpers | underscore prefix | `_query.ado` |
| Private helpers | `_wbod_` prefix | `_wbod_parse.ado` |
| YAML metadata | `_wbopendata_*.yaml` | `_wbopendata_indicators.yaml` |

### Return Values
All subcommands should return structured results:
```stata
return local indicator "SP.POP.TOTL"
return local name "Population, total"
return scalar n_countries = 217
return matrix data = ...
```

---

## 📚 Related Documents

| Document | Description |
|----------|-------------|
| [Doc Hub](../README.md) | Central navigation for all documentation |
| [STATA ADO Best Practices](../../../.github/STATA_ADO_BEST_PRACTICES.md) | Coding standards reference (workspace-wide) |
| [Examples Gallery](../user-guide/examples_gallery.md) | Visual examples with code |
| [FAQ](../user-guide/FAQ.md) | Troubleshooting guide |

---

## Contributing

See [Contributing Guidelines](../../CONTRIBUTING.md) for how to propose new features or report bugs.

---

*Last updated: February 12, 2026 — v18.1.0 released*
