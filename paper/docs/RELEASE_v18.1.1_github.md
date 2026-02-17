# Release v18.1.1: Discovery Commands, Char Metadata & Offline Testing

**Tag:** v18.1.1
**Date:** February 17, 2026

---

## Highlights

This release is the largest update since v16.0 (2019). It introduces **offline discovery commands** for browsing the World Bank data catalog, a **YAML metadata architecture** replacing 89 per-indicator help files, a redesigned **sync system** with safe-by-default behavior, **variable-level `char` metadata** for self-documenting datasets, and **deterministic offline testing** with CSV fixtures. The QA suite grows from 44 to 89 tests across 17 categories.

## What's New (v17.7.1 → v18.1.1)

### At a Glance

| Metric | v17.7.1 | v18.1.1 |
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
| `wbopendata, alltopics` | List all 21 topic categories |
| `wbopendata, search(query)` | Search indicators by keyword with topic/source/field filters |
| `wbopendata, info(ID)` | Display full indicator metadata with clickable URLs |

### Char Metadata (v18.1)

Every `.dta` file now embeds **persistent provenance** via Stata `char` metadata:
- **Dataset-level**: query parameters, timestamp, version, indicator codes
- **Variable-level**: indicator code, name, source on each downloaded variable
- Use `nochar` option to suppress

### Sync System Redesign (v18.1)

| Deprecated | Replacement | Behavior |
|------------|-------------|----------|
| `update query` | `sync` | Preview metadata changes (dry run, safe default) |
| `update check` | `checkupdate` | Compare local vs remote version |
| `update all` | `sync replace` | Download latest YAML metadata |

### Additional Changes in v18.1.1

- Documentation fixes: corrected database count (51 → 71) across help files
- Version check and component manifest infrastructure
- CI workflow improvements for sync-to-public

## Installation

```stata
* From GitHub (recommended)
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace

* This specific version
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/v18.1.1") replace
```

**Requires:** Stata 14+

**Compare:** [v17.7.1...v18.1.1](https://github.com/jpazvd/wbopendata/compare/v17.7.1...v18.1.1)
