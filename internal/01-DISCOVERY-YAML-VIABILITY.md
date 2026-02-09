# Discovery + YAML-Based Metadata System: Viability Assessment

**Date:** January 20, 2026  
**Project:** wbopendata-dev  
**Scope:** Internal planning (NOT for public release)  
**Status:** Research & Planning Phase

---

## Executive Summary

This document assesses the viability of adding a **Discovery subsystem** (inspired by unicefdata-dev) and **YAML-based metadata sync** to wbopendata. Both features are on the v18.0 roadmap as P1 (high priority).

**Key Findings:**
- ✅ **Technically viable** - unicefdata-dev demonstrates the pattern
- ✅ **Architecture-compatible** - wbopendata can adopt without major refactoring
- ⚠️ **Effort: Medium-High** - ~8-12 weeks of development
- ⚠️ **Maintenance burden** - requires YAML sync pipeline with API
- ✅ **User impact: High** - solves key discoverability issues

**Recommendation:** Proceed with phased implementation (Phase 1: Discovery, Phase 2: YAML sync)

---

## Current State Analysis

### wbopendata Architecture (v17.7)

**Strengths:**
- Clean separation: `wbopendata.ado` (main) → `_api_read.ado` (HTTP) → `.sthlp` metadata
- Well-structured option parsing
- 695 lines of focused code
- Mature API integration

**Metadata Limitations:**
- Static `.sthlp` files (170+ files for indicators)
- Manual parsing required for metadata discovery
- No full-text search capability
- Limited programmatic access to metadata
- Source/Topic information split across multiple files
- No central metadata cache

**Current Data Flow:**
```
User Query → wbopendata.ado → _api_read.ado → WB API → Parse → Dataset
                                    ↓
                             .sthlp help files (static)
```

### unicefdata-dev Discovery Pattern

**YAML Configuration Structure:**
```
config/
├── common_indicators.yaml      # Shared indicators (trilingual)
├── indicators.yaml             # Full indicator registry
└── metadata/
    ├── indicators_py.yaml      # Python-specific metadata
    ├── indicators_r.yaml       # R-specific metadata
    └── indicators_stata.yaml   # Stata-specific metadata
```

**Discovery Commands (implemented in Python/R, planned for Stata):**
```stata
// Search by keyword
unicefdata, search("malnutrition") limit(10)

// Get detailed info
unicefdata, info("NT_ANT_HAZ_NE2_MOD")

// List all sources
unicefdata, sources detail

// List all dataflows
unicefdata, dataflows
```

**Implementation Files (unicefdata):**
- `stata/src/u/_unicef_get_indicator_filters.ado`
- `stata/src/u/_unicef_get_indicator_dataflow.ado`
- `stata/src/u/_unicef_parse_indicator_yaml.ado`
- `stata/src/g/get_unicef_data.ado` (main discovery entry)

---

## Design Approach: Three Pathways

### Pathway A: Minimal Discovery (Light)

**Scope:** Search + Info subcommands only, static metadata cache  
**Effort:** 3-4 weeks  
**Complexity:** Low

**Architecture:**
```
wbopendata.ado
├── [search subcommand] → _wbopendata_search.ado
│   └── Parse local .dta metadata cache
├── [info subcommand] → _wbopendata_info.ado
│   └── Lookup indicator details
└── [existing] → _api_read.ado (unchanged)
```

**Implementation:**
1. Create flat metadata `.dta` file (indicators, topics, sources)
2. Build search index (keyword → indicator mapping)
3. Implement `_wbopendata_search.ado` (keyword matching)
4. Implement `_wbopendata_info.ado` (detail display)
5. Add `search()`, `info()` options to wbopendata

**Limitations:**
- ❌ No YAML integration
- ❌ Manual metadata updates required
- ❌ Search limited to local cache

**When to use:** If YAML sync is deferred; quick wins needed

---

### Pathway B: YAML-Lite Discovery (Medium)

**Scope:** Discovery + YAML metadata, no auto-sync  
**Effort:** 6-8 weeks  
**Complexity:** Medium

**Architecture:**
```
wbopendata.ado → [search|info] → _wbopendata_search.ado
                                 _wbopendata_info.ado
                                 _yaml_read.ado ← _wbopendata_indicators.yaml
                                                  _wbopendata_topics.yaml
                                                  _wbopendata_sources.yaml
```

**Implementation:**
1. Define YAML schema (indicators, topics, sources, metadata)
2. Create 3 core YAML files (mirrors World Bank API structure)
3. Implement `_yaml_read.ado` (wrapper over yaml.ado from SSC)
4. Implement metadata search on YAML (in-memory parsing)
5. Add `sync` option to manually update YAML from WB API

**Advantages:**
- ✅ Structured, version-controllable metadata
- ✅ Non-breaking change (existing API workflow untouched)
- ✅ Foundation for future automation
- ✅ Reusable for multiplatform consistency

**Limitations:**
- ⚠️ Still requires manual sync to update metadata
- ⚠️ Dependency on `yaml.ado` from SSC
- ⚠️ Storage: YAML files can be large (indicators.yaml ~500KB)

**When to use:** Balanced approach; recommended baseline

---

### Pathway C: Full YAML + Auto-Sync (Heavy)

**Scope:** Discovery + YAML + API sync pipeline + caching  
**Effort:** 10-14 weeks  
**Complexity:** High

**Architecture:**
```
┌─────────────────────────────────────────────────────────────┐
│ Update Pipeline (Python script, runs quarterly/as-needed)   │
│ update_metadata.py                                          │
│ └─→ Fetch from WB API (bulk) → Normalize → YAML validation │
│     └─→ Git commit + SSC publish                            │
└─────────────────────────────────────────────────────────────┘
         ↓ (versioned YAML files in src/_/)
┌─────────────────────────────────────────────────────────────┐
│ Discovery Runtime (Stata)                                   │
│ wbopendata, search/info/sources/sync ← YAML cache (local)   │
│                                    ↓                        │
│                            _yaml_read.ado                   │
└─────────────────────────────────────────────────────────────┘
```

**Implementation:**
1. YAML-Lite foundation (Pathway B)
2. Python update script: `update_metadata.py`
   - Fetch WB API bulk endpoints
   - Cache responses (prevent API throttling)
   - Normalize to YAML schema
   - Generate checksums (integrity validation)
   - Git commit with version tag
3. Implement `sync()` option:
   ```stata
   wbopendata, sync              // Check remote vs local
   wbopendata, sync(force)       // Force remote fetch
   ```
4. Add caching layer:
   ```stata
   wbopendata, indicator(SP.POP.TOTL) cache   // Use local cache
   wbopendata, clearcache                     // Clear cache
   ```

**Advantages:**
- ✅ Always up-to-date metadata (automated)
- ✅ No manual intervention needed
- ✅ Scales well with many indicators
- ✅ Can support versioning (release → production metadata)

**Challenges:**
- ❌ Requires Python infrastructure (separate from Stata)
- ❌ Complex CI/CD integration for metadata releases
- ⚠️ Dependency management (must keep YAML versions in sync)
- ⚠️ Testing complexity (versioning, rollback procedures)

**When to use:** Long-term vision; recommend after Pathway B stabilizes

---

## Comparison Matrix

| Criterion | Pathway A | Pathway B | Pathway C |
|-----------|-----------|-----------|-----------|
| **Timeline** | 3-4 wks | 6-8 wks | 10-14 wks |
| **Complexity** | Low | Medium | High |
| **Auto-update** | ❌ | ❌ | ✅ |
| **YAML support** | ❌ | ✅ | ✅ |
| **Search capability** | Basic | Full | Full |
| **External deps** | None | yaml.ado | yaml.ado + Python |
| **User value** | Medium | High | High |
| **Maintenance** | Low | Medium | High |
| **Roadmap fit** | Partial | Recommended | Future |

---

## Recommended Approach: Pathway B (YAML-Lite)

**Rationale:**
- Reasonable timeline (6-8 weeks)
- High user value (full discovery, YAML foundation)
- Minimal external dependencies
- Non-breaking changes
- Foundation for future v18.1+ enhancements

**Why not Pathway A:**
- Misses YAML benefits (structure, maintainability, multiplatform sync)
- Still requires manual metadata updates

**Why not Pathway C (yet):**
- Python infrastructure adds complexity
- Better to validate Pathway B with users first
- Can defer to v18.1 (after user feedback)

---

## Implementation Roadmap: Pathway B

### Phase 1: Schema & Files (Weeks 1-2)

**Deliverables:**
1. YAML schema design document (`YAML_SCHEMA_DESIGN.md`)
2. Three core YAML files:
   - `_wbopendata_indicators.yaml` (~500KB, 13K+ indicators)
   - `_wbopendata_sources.yaml` (~50KB, ~50 sources)
   - `_wbopendata_topics.yaml` (~20KB, ~20 topics)
3. Sample/test YAML files (10-20 indicators for testing)

**Tasks:**
- [ ] Design YAML schema (ref: unicefdata config/indicators.yaml)
- [ ] Extract WB API metadata → YAML format
- [ ] Validate schema (all required fields present)
- [ ] Version metadata (add checksum/version field)
- [ ] Document schema in markdown

### Phase 2: Stata Infrastructure (Weeks 3-4)

**Deliverables:**
1. `_yaml_read.ado` - YAML parsing wrapper
2. `_wbopendata_search.ado` - Search implementation
3. `_wbopendata_info.ado` - Detail lookup

**Tasks:**
- [ ] Implement `_yaml_read.ado` (thin wrapper over yaml.ado)
- [ ] Test YAML parsing on all three files
- [ ] Build search index (in-memory from YAML)
- [ ] Implement keyword matching algorithm
- [ ] Implement info display formatting
- [ ] Handle edge cases (missing fields, encoding)

### Phase 3: Integration & Options (Weeks 5-6)

**Deliverables:**
1. Updated `wbopendata.ado` with new options
2. Subcommands: `search()`, `info()`, `sources`, `topics`
3. Updated help file

**Tasks:**
- [ ] Add syntax options: search(), info(), sources, topics
- [ ] Route to appropriate helper (search/info/sources)
- [ ] Implement return values (consistent with current pattern)
- [ ] Update wbopendata.sthlp
- [ ] Add examples

### Phase 4: Testing & Documentation (Weeks 7-8)

**Deliverables:**
1. Test suite (test_discovery.do)
2. Examples (examples_discovery.do)
3. User documentation

**Tasks:**
- [ ] Unit tests: search correctness
- [ ] Unit tests: info field extraction
- [ ] Integration tests: search + data download flow
- [ ] Regression tests: existing commands unaffected
- [ ] Write user guide section
- [ ] Add to examples gallery

---

## Technical Details: YAML Schema

### File 1: `_wbopendata_indicators.yaml`

```yaml
# _wbopendata_indicators.yaml
# World Bank Indicators Metadata
# Generated: [TIMESTAMP]
# Source: WB Open Data API
# Schema Version: 2.0.0

_metadata:
  version: "2.0.0"
  sync_date: "2025-12-01T00:00:00Z"
  source: "WB Open Data API"
  total_indicators: 13150
  checksum: "sha256:abc123..."

indicators:
  SP.POP.TOTL:
    code: "SP.POP.TOTL"
    name: "Population, total"
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["19"]
    topic_names: ["Population dynamics"]
    description: "Total population..."
    unit: "Units"
    latest_year: "2023"
    
  SE.ADT.LITR.ZS:
    code: "SE.ADT.LITR.ZS"
    name: "Literacy rate, adult total (% of people ages 15+)"
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["4"]
    topic_names: ["Education"]
    ...
```

### File 2: `_wbopendata_sources.yaml`

```yaml
# _wbopendata_sources.yaml
_metadata:
  version: "2.0.0"
  total_sources: 51

sources:
  "1":
    code: "1"
    name: "Metadata and Poverty Data"
    
  "2":
    code: "2"
    name: "World Development Indicators"
    description: "Time-series data on various topics..."
    
  ...
```

### File 3: `_wbopendata_topics.yaml`

```yaml
# _wbopendata_topics.yaml
_metadata:
  version: "2.0.0"
  total_topics: 21

topics:
  "1":
    code: "1"
    name: "Agriculture & Rural Development"
    
  "2":
    code: "2"
    name: "Aid Effectiveness"
    
  ...
```

---

## Stata Implementation Snippets

### `_wbopendata_search.ado`

```stata
program def _wbopendata_search, rclass
  syntax anything(name=keyword id="search term"), [limit(integer 20) source(string)]
  
  * Read YAML into memory
  yaml_read using "`c(sysdir_personal)'wbopendata/_wbopendata_indicators.yaml", ///
    clear map(indicators)
  
  * Build search index on-the-fly (name + description)
  gen searchtext = lower(name + " " + description)
  
  * Keyword matching
  local kw = lower("`keyword'")
  keep if strpos(searchtext, "`kw'") > 0
  
  * Apply limit
  keep in 1/`limit'
  
  * Return results
  local n = _N
  forvalue i = 1/`n' {
    return local indicator`i' = code[`i']
    return local name`i' = name[`i']
  }
  return scalar n_results = `n'
  
end
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| **YAML files too large** | Medium | Medium | Implement lazy loading; split by decade |
| **yaml.ado dependency failure** | Low | High | Fallback parser (native Stata); vendor yaml.ado |
| **Metadata drift (API changes)** | Medium | Medium | Version schema; automated validation |
| **Performance issues (large YAML parse)** | Low | Medium | Pre-build search index at install time |
| **Backward compatibility break** | Low | High | All new options; existing API untouched |

---

## Success Criteria

### Phase Completion
- [ ] YAML files validated (checksums match)
- [ ] All Stata code passes linter (Stata strict)
- [ ] 100% unit test coverage for search/info
- [ ] No regression in existing commands
- [ ] Help file updated and examples work

### User Satisfaction
- [ ] Users can search 100+ indicators by keyword
- [ ] Info command returns all necessary fields
- [ ] Source/topic browsing works smoothly
- [ ] Discovery + download workflow is seamless

### Performance
- [ ] Search on 13K indicators: < 1 second
- [ ] Info lookup: < 100ms
- [ ] YAML parsing overhead: < 5% vs current

---

## Next Steps

1. **Approval:** Review this document with stakeholders
2. **Schema Design:** Create detailed YAML schema (→ `YAML_SCHEMA_DESIGN.md`)
3. **Prototype:** Build sample YAML files and test parsing
4. **Estimation:** Refine effort estimates based on YAML size
5. **Kickoff:** Begin Phase 1 (Schema & Files)

---

## References

- **unicefdata-dev:** `config/` and `stata/src/u/_unicef_*.ado`
- **Roadmap:** `doc/roadmap/ROADMAP.md` (Discovery = P1 v18.0)
- **Stata ADO Standards:** `.github/STATA_ADO_BEST_PRACTICES.md`
- **yaml.ado documentation:** SSC package reference

---

*Document Status: DRAFT - For Internal Review*  
*Next Review: After schema design phase*
