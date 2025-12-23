# wbopendata Roadmap

[← Back to README](../../README.md) | [FAQ](../FAQ.md)

---

## Overview

This roadmap consolidates all improvement plans and enhancement ideas for `wbopendata`. It reflects the current state after v17.4 release and prioritizes features based on user impact and implementation effort.

**Last Updated:** December 23, 2025  
**Current Version:** v17.4  
**Reference Implementations:** unicefData, yaml.ado, stataci

---

## ✅ Completed in v17.x

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

| Priority | Feature | Impact | Effort | Target |
|----------|---------|--------|--------|--------|
| **P1** | Discovery subcommands | High | Medium | v18.0 |
| **P1** | YAML-based metadata sync | High | High | v18.0 |
| **P2** | Caching system | Medium | Medium | v18.1 |
| **P2** | Search functionality | Medium | Medium | v18.1 |
| **P2** | Progress indicators | Medium | Low | v18.1 |
| **P3** | Batch download mode | Low | Low | v18.2 |
| **P3** | Favorites/bookmarks | Low | Low | v18.2 |
| **P3** | Multiple output formats | Low | Medium | v18.2 |

---

## 🔴 P1: High Priority (v18.0)

### 1.1 Discovery Subcommands

Interactive indicator discovery inspired by `unicefdata`:

```stata
* Search indicators by keyword
wbopendata, search("education")
wbopendata, search("GDP") limit(20) source(2)

* Get detailed metadata for indicator
wbopendata, info("SE.ADT.LITR.ZS")

* List available sources/topics
wbopendata, sources
wbopendata, topics detail
```

**Implementation:**
- Create `_wbopendata_search.ado`
- Create `_wbopendata_info.ado`
- Parse local metadata cache (YAML)

### 1.2 YAML-Based Metadata System

Replace static `.sthlp` files with structured YAML:

```yaml
# _wbopendata_indicators.yaml
_metadata:
  version: 2.0.0
  synced_at: "2025-12-23T10:00:00Z"
  
indicators:
  SE.ADT.LITR.ZS:
    name: "Literacy rate, adult total"
    source_id: 2
    topic_id: 4
```

**Commands:**
```stata
wbopendata, sync              // Sync all metadata
wbopendata, sync(indicators)  // Sync indicators only
wbopendata, sync verbose      // Show progress
```

**Dependencies:** `yaml.ado` from SSC

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

| Document | Description | Status |
|----------|-------------|--------|
| [STATA_ADO_BEST_PRACTICES.md](STATA_ADO_BEST_PRACTICES.md) | Coding standards | Reference |

### Archived
- [ENHANCEMENT_IDEAS.md](_archive/ENHANCEMENT_IDEAS.md) — Detailed feature proposals
- [IMPROVEMENT_PLAN.md](_archive/IMPROVEMENT_PLAN.md) — Original improvement plan  
- [ISSUE_RESOLUTION_PLAN.md](_archive/ISSUE_RESOLUTION_PLAN.md) — Issue tracking history

---

## Contributing

See [Contributing Guidelines](../../CONTRIBUTING.md) for how to propose new features or report bugs.

---

*Last updated: December 23, 2025*
