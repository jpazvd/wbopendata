# wbopendata Roadmap

[← Back to README](../../README.md) | [Doc Hub](../README.md) | [FAQ](../user-guide/FAQ.md) | [Examples](../user-guide/examples/)

---

## Overview

This roadmap consolidates all improvement plans and enhancement ideas for `wbopendata`. It reflects the current state after v17.7 release and prioritizes features based on user impact and implementation effort.

**Last Updated:** January 29, 2026  
**Current Version:** v18.0.0 (in development)  
**Reference Implementations:** unicefData, yaml.ado, stataci

---

## ✅ Completed in v17.x & v18.x

### v18.0 (January 2026) — In Development
- [x] Discovery commands: `search()` and `info()` subcommands
- [x] Cache management: `sync`, `syncforce`, `checkupdate`, `clearcache`, `cacheinfo`
- [x] Expanded test suite to 57 tests (9 categories including CACHE-01 to SYNC-05)
- [x] Auto-detecting repo paths for multi-machine test compatibility
- [x] Version bump to 18.0.0 with consolidated package files
- [x] Workflow migration: metadata updates via GitHub Actions
- [ ] **NEXT:** Implement helper ados for discovery and cache (currently stub files)
- [ ] **NEXT:** YAML metadata parsing and sync logic
- [ ] **NEXT:** Populate _wbopendata_*.yaml metadata files

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
| **P1** | Discovery subcommands (search, info) | 🟡 Stubbed | High | Medium | v18.0 |
| **P1** | YAML-based metadata sync | 🟡 Stubbed | High | High | v18.0 |
| **P1** | Helper ado implementations | 🔴 TODO | High | Medium | v18.0 |
| **P2** | Caching system | 🟢 Planned | Medium | Medium | v18.1 |
| **P2** | Search index optimization | 🟢 Planned | Medium | Low | v18.1 |
| **P2** | Progress indicators | 🟢 Planned | Medium | Low | v18.1 |
| **P3** | Batch download mode | 🟢 Planned | Low | Low | v18.2 |
| **P3** | Favorites/bookmarks | 🟢 Planned | Low | Low | v18.2 |
| **P3** | Multiple output formats | 🟢 Planned | Low | Medium | v18.2 |

---

## � NEXT IMMEDIATE STEPS (v18.0 Completion)

The infrastructure is in place (atomic commits in feature/pathway-c-auto-sync). Now implement:

### PHASE 1: Helper ADO Implementation (Week 1-2)

1. **_wbopendata_cache.ado** (Priority 1)
   - [ ] `cache, info` — Display cache location, version, timestamp
   - [ ] `cache, checkversion` — Compare local vs GitHub versions
   - [ ] `cache, update [force]` — Download/update YAML from GitHub
   - [ ] `cache, clear` — Remove cached files
   - **Dependencies:** GitHub API call, file versioning
   - **Test:** CACHE-01 to CACHE-08

2. **_wbopendata_get_yaml_path.ado** (Priority 1)
   - [ ] Return path to cached or packaged YAML
   - [ ] Priority: cache > package install
   - [ ] Return source indicator (cache vs package)
   - **Dependencies:** File system checks
   - **Test:** CACHE-02

3. **_wbopendata_download_yaml.ado** (Priority 1)
   - [ ] Download from GitHub releases
   - [ ] Extract version from filename
   - [ ] Validate file integrity (checksum)
   - [ ] Populate cache directory
   - **Dependencies:** Network I/O, GitHub API
   - **Test:** SYNC-01 to SYNC-05

### PHASE 2: Discovery Commands (Week 2-3)

4. **_wbopendata_search.ado** (Priority 1)
   - [ ] Parse YAML indicators metadata
   - [ ] Search by keyword (title, description, source)
   - [ ] Apply limit() and source() filters
   - [ ] Return matched indicators with details
   - [ ] Return `r(yaml_source)` (cache or package)
   - **Dependencies:** _wbopendata_get_yaml_path, YAML parsing
   - **Test:** (add SRCH-01 to SRCH-05 tests)

5. **_wbopendata_info.ado** (Priority 1)
   - [ ] Display full metadata for single indicator
   - [ ] Show source, topic, availability
   - [ ] Format for readability in Stata
   - [ ] Return structured metadata
   - **Dependencies:** _wbopendata_get_yaml_path, YAML parsing
   - **Test:** (add INFO-01 to INFO-03 tests)

### PHASE 3: YAML Metadata Population (Week 3-4)

6. **Populate _wbopendata_*.yaml files** (Priority 1)
   - [ ] _wbopendata_indicators.yaml — All 20,000+ indicators
   - [ ] _wbopendata_sources.yaml — All 51 data sources
   - [ ] _wbopendata_topics.yaml — All topic categories
   - **Automation:** Use src/py/update_metadata.py (already stubbed)
   - **Format:** Match schema in wbopendata.pkg documentation

### PHASE 4: Integration & Testing (Week 4)

7. **Integration testing**
   - [ ] Run full test suite (57 tests)
   - [ ] Verify CACHE-01 to SYNC-05 tests pass
   - [ ] Manual search/info testing
   - [ ] YAML fallback testing (cache → package)

8. **Documentation**
   - [ ] Update wbopendata.sthlp with search/info examples
   - [ ] Add YAML caching explanation
   - [ ] Document offline usage (package YAML fallback)
   - [ ] Update examples_gallery.md

---

## 🔴 P1: High Priority (v18.0) — Implementation Status

### 1.1 Discovery Subcommands

**Status:** Commands integrated in wbopendata.ado (v18.0). Helper ados need implementation.

Interactive indicator discovery inspired by `unicefdata`:

```stata
* Search indicators by keyword
wbopendata, search("education")
wbopendata, search("GDP") limit(20) source(2)

* Get detailed metadata for indicator
wbopendata, info("SE.ADT.LITR.ZS")
```

**Implementation Status:**
- [x] Main command syntax added to wbopendata.ado
- [ ] `_wbopendata_search.ado` — Parse YAML, apply filters
- [ ] `_wbopendata_info.ado` — Display indicator metadata
- [ ] YAML metadata files populated
- **Test Coverage:** 57/57 (CACHE + SYNC tests stubbed, pass gracefully)

### 1.2 YAML-Based Metadata System

**Status:** Commands integrated in wbopendata.ado (v18.0). Helper ados need implementation.

Replace static `.sthlp` files with structured YAML:

```yaml
# _wbopendata_indicators.yaml
_metadata:
  version: 2.0.0
  synced_at: "2025-01-29T00:00:00Z"
  
indicators:
  SE.ADT.LITR.ZS:
    name: "Literacy rate, adult total"
    source_id: 2
    topic_id: 4
```

**Commands:**
```stata
wbopendata, sync              // Sync all metadata
wbopendata, checkupdate       // Check for updates
wbopendata, clearcache        // Clear local cache
```

**Implementation Status:**
- [x] Main command syntax added to wbopendata.ado
- [ ] `_wbopendata_cache.ado` — Cache operations (info, update, clear)
- [ ] `_wbopendata_download_yaml.ado` — GitHub download logic
- [ ] `_wbopendata_check_version.ado` — Version comparison
- [ ] `_wbopendata_get_yaml_path.ado` — Cache/package resolution
- [ ] Populate _wbopendata_*.yaml with live data
- **Dependencies:** `yaml.ado` from SSC (for parsing)
- **Test Coverage:** 13 tests (CACHE-01 to SYNC-05, currently pass/skip gracefully)

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

*Last updated: January 29, 2026 — v18.0 development in progress*
