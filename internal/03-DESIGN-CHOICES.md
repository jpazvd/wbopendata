# Discovery System: Design Choices & Technical Decisions

**Date:** January 20, 2026  
**Project:** wbopendata-dev  
**Scope:** Technical architecture and implementation decisions (assuming Pathway B)

---

## Table of Contents

1. [Overview](#overview)
2. [Core Design Decisions](#core-design-decisions)
3. [YAML Schema Design](#yaml-schema-design)
4. [Stata Implementation Strategy](#stata-implementation-strategy)
5. [Integration Points](#integration-points)
6. [Testing & Validation](#testing--validation)
7. [Performance Considerations](#performance-considerations)
8. [Future Extensibility](#future-extensibility)

---

## Overview

This document outlines the **technical design choices** for implementing Discovery + YAML using **Pathway B (YAML-Lite)**.

**Key architectural principles:**
- Non-breaking changes (existing API untouched)
- Minimal external dependencies (only yaml.ado)
- Modular design (discovery helpers are independent)
- Future-proof structure (foundation for v18.1+ automation)

---

## Core Design Decisions

### Decision 1: YAML vs Alternative Formats

**Options considered:**
1. **YAML** ← CHOSEN
2. JSON
3. Stata native (.dta)
4. Custom format

**Rationale for YAML:**
| Criterion | YAML | JSON | .dta | Custom |
|-----------|------|------|------|--------|
| Human readable | ✅ | ✅ | ❌ | ❌ |
| Stata parsing | ✅ (yaml.ado) | ❌ (no SSC) | ✅ | ❌ |
| Multiplatform | ✅ | ✅ | ❌ | ❌ |
| Space efficient | ✅ | ⚠️ | ❌ | ✅ |
| Git-friendly | ✅ | ✅ | ❌ | ✅ |
| unicefdata alignment | ✅ | ❌ | ⚠️ | ❌ |

**Decision:** YAML maximizes compatibility and aligns with unicefdata strategy.

---

### Decision 2: Single YAML File vs Split Files

**Options:**
1. **One mega-file** `_wbopendata_metadata.yaml` (all 13K+ indicators)
2. **Three split files** ← CHOSEN
   - `_wbopendata_indicators.yaml`
   - `_wbopendata_sources.yaml`
   - `_wbopendata_topics.yaml`

**Rationale:**
| Criterion | Mega-file | Split |
|-----------|-----------|-------|
| File size | 700+ MB | ~600 KB + ~50 KB + ~20 KB |
| Parse time | Slow (minutes) | Fast (< 1 sec) |
| Git diffs | Huge, unreadable | Manageable |
| Modularity | Low | High |
| Memory usage | Very high | Normal |
| Update frequency | Rare | Indicators frequent, sources rare |

**Decision:** Split files enable fast parsing, selective updates, and better maintainability.

---

### Decision 3: Metadata Caching Strategy

**Options:**
1. **No cache** - Parse YAML from disk every search
2. **In-memory cache** (per session) ← CHOSEN
3. **On-disk cache** (persistent)
4. **Hybrid** (both in-memory + disk)

**Rationale:**
- In-memory cache: Fast for repeated searches within session
- Simplest implementation
- Can add persistent cache in v18.1
- Aligns with Stata best practices

**Implementation:**
```stata
* First search in session: read YAML into memory
if ("`c(search_cache_loaded)'" == "") {
  yaml_read indicators_path
  global search_cache_loaded 1
}

* Subsequent searches: use cached data
use $search_cache_data, clear
```

---

### Decision 4: Search Algorithm

**Options:**
1. **Simple substring match** - Fast, low precision
2. **Fuzzy matching** - Tolerates typos
3. **Weighted keyword match** ← CHOSEN
   - Weight name (2x) > description (1x)
   - Case-insensitive
   - Whole-word preference

**Implementation:**
```stata
* Build search score
gen score = 0
if strpos(lower(name), "`keyword'") > 0 {
  local score = 2  // Name match: weight 2x
}
if strpos(lower(description), "`keyword'") > 0 {
  local score = max(`score', 1)  // Description match: weight 1x
}

* Sort by score (highest first) + name alphabetically
sort score name
```

**Rationale:**
- Balances recall vs precision
- Hits on indicator name (more relevant) rank higher
- Predictable ranking for users
- No external fuzzy-match library needed

---

### Decision 5: Return Values Format

**Design choice:** Mimic wbopendata's existing return pattern

**Example:**
```stata
// wbopendata, search("education") limit(3)
// Returns:
r(n_results)      = "3"
r(indicator1)     = "SE.ADT.LITR.ZS"
r(name1)          = "Literacy rate, adult total"
r(indicator2)     = "SE.PRY.CMPL.ZS"
r(name2)          = "School completion rate, primary"
r(indicator3)     = "SE.ADT.LITR.FE.ZS"
r(name3)          = "Literacy rate, adult female"
```

**Rationale:**
- Matches existing `r()` patterns in wbopendata
- Scriptable (users can loop through results)
- Returns matrix data for large result sets
- Familiar to current users

---

## YAML Schema Design

### Structure: Three-File Model

#### File 1: `_wbopendata_indicators.yaml`

**Purpose:** Complete indicator registry (13,150+ indicators)

```yaml
# _wbopendata_indicators.yaml
# =========================================================================
# World Bank Open Data Indicators Metadata
# Generated: 2025-12-01T10:00:00Z
# Source: World Bank Open Data API (bulk export)
# Schema Version: 2.0.0
# =========================================================================

_metadata:
  version: "2.0.0"
  generated_at: "2025-12-01T10:00:00Z"
  source: "WB Open Data API - bulk indicators endpoint"
  total_indicators: 13150
  compression: "uncompressed"
  encoding: "UTF-8"
  checksum_sha256: "a1b2c3d4e5f6..."
  
indicators:
  SP.POP.TOTL:
    # Core identifier
    code: "SP.POP.TOTL"
    name: "Population, total"
    
    # Classification
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["19"]
    topic_names: ["Population dynamics"]
    
    # Description
    description: >-
      Total population is based on the de facto definition of population,
      which counts all residents regardless of legal status or citizenship.
      Values are midyear estimates.
    
    # Data availability
    latest_year: "2023"
    first_year: "1960"
    
    # Metadata
    unit: "Units"
    aggregation_method: "Population"
    note: ""
    note_indicator: ""
    note_topic: ""
    
    # Status flags
    limited_data: false
    discontinued: false
    
  SE.ADT.LITR.ZS:
    code: "SE.ADT.LITR.ZS"
    name: "Literacy rate, adult total (% of people ages 15+)"
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["4"]
    topic_names: ["Education"]
    description: "..."
    latest_year: "2023"
    first_year: "2000"
    unit: "% of people ages 15+"
    aggregation_method: "Education"
    note: "Data unavailable for some countries"
    note_indicator: ""
    note_topic: ""
    limited_data: true
    discontinued: false
```

**Schema Notes:**
- `_metadata` block at top (required)
- Each indicator keyed by code (stable identifier)
- Required fields: code, name, source_id, topic_ids
- Optional fields: descriptions, notes, flags
- Enables partial updates (only regenerate indicators.yaml if sources/topics change)

---

#### File 2: `_wbopendata_sources.yaml`

**Purpose:** Source/dataset registry (51 sources)

```yaml
# _wbopendata_sources.yaml

_metadata:
  version: "2.0.0"
  generated_at: "2025-12-01T10:00:00Z"
  total_sources: 51

sources:
  "1":
    code: "1"
    name: "Metadata and Poverty Data"
    description: >-
      Contains metadata about World Bank operations including projects,
      staff, offices. Also includes poverty indicators.
    
  "2":
    code: "2"
    name: "World Development Indicators"
    description: >-
      The primary World Bank source of time-series development indicators
      covering 217 economies. Includes 1500+ indicators across all sectors.
    
  "3":
    code: "3"
    name: "International Debt Statistics"
    description: "External debt statistics for World Bank borrowing countries"
    
  # ... (50 more sources)
```

**Schema Notes:**
- Simple 1:1 code-to-metadata mapping
- Description can be multi-line (YAML folded string `>-`)
- Code is primary key

---

#### File 3: `_wbopendata_topics.yaml`

**Purpose:** Topic/thematic classification (21 topics)

```yaml
# _wbopendata_topics.yaml

_metadata:
  version: "2.0.0"
  generated_at: "2025-12-01T10:00:00Z"
  total_topics: 21

topics:
  "1":
    code: "1"
    name: "Agriculture & Rural Development"
    description: >-
      Covers agricultural production, land use, rural infrastructure,
      and development initiatives in agriculture sector.
  
  "2":
    code: "2"
    name: "Aid Effectiveness"
    description: >-
      Indicators on aid disbursement, effectiveness, coordination,
      and development assistance flows.
  
  "4":
    code: "4"
    name: "Education"
    description: >-
      Primary and secondary education enrollment, completion rates,
      literacy, and learning outcomes.
    
  # ... (18 more topics)
```

**Schema Notes:**
- Parallel structure to sources
- Code is primary key
- Small file (easily cached in memory)

---

### Schema Version Strategy

**Why versioning?**
- API changes require schema migration
- Backwards compatibility for Stata helpers
- Version pinning in code (known good schemas)

**Version numbering:**
- `2.0.0` = Major.Minor.Patch
- Major: breaking schema changes
- Minor: new optional fields
- Patch: data corrections, no schema change

**Version check in Stata:**
```stata
* Check if loaded YAML version matches expected
if ("`yaml_version'" != "2.0.0") {
  display as error "YAML schema version mismatch"
  display as error "Expected 2.0.0, got `yaml_version'"
  error 999
}
```

---

## Stata Implementation Strategy

### File Organization

```
src/_/
├── wbopendata_indicators.yaml      (data file)
├── wbopendata_sources.yaml         (data file)
├── wbopendata_topics.yaml          (data file)
├── _yaml_read.ado                  (NEW - helper)
├── _wbopendata_search.ado          (NEW - discovery)
├── _wbopendata_info.ado            (NEW - discovery)
├── _wbopendata_sources.ado         (NEW - list sources)
└── _wbopendata_topics.ado          (NEW - list topics)
```

### Helper 1: `_yaml_read.ado`

**Purpose:** Thin wrapper over yaml.ado to standardize YAML reading

```stata
program def _yaml_read, rclass
  syntax using/, [SECTION(string) MAP(string)]
  
  * Path resolution
  local yaml_path = c(sysdir_personal) + "ado/plus/_/" + "`using'"
  if ("`using'" contains "/") {
    * Full path provided
    local yaml_path = "`using'"
  }
  
  if (!file_exists("`yaml_path'")) {
    display as error "YAML file not found: `yaml_path'"
    error 601
  }
  
  * Use yaml.ado to parse
  yaml_read using "`yaml_path'", replace
  
  * Extract metadata for version check
  capture label list _metadata_version
  local version = r(max)
  return local version = "`version'"
  
end
```

### Helper 2: `_wbopendata_search.ado`

**Purpose:** Search indicators by keyword

```stata
program def _wbopendata_search, rclass
  syntax anything(name=keyword id="search term"), [limit(integer 20) source(string)]
  
  * Load YAML (use cached data if available)
  if ("`c(WBOD_search_cache)'" == "") {
    yaml_read using "_wbopendata_indicators.yaml", replace
    global WBOD_search_cache 1
  } else {
    use $WBOD_search_cache_data, clear
  }
  
  * Filter by source if specified
  if ("`source'" != "") {
    keep if source_id == "`source'"
  }
  
  * Build search score
  local kw = lower("`keyword'")
  gen score = 0
  
  * Name match (weighted 2x)
  replace score = 2 if strpos(lower(name), "`kw'") > 0
  
  * Description match (weighted 1x)
  replace score = max(score, 1) if strpos(lower(description), "`kw'") > 0
  
  * Keep only matches
  keep if score > 0
  
  if (_N == 0) {
    display as text "No indicators found matching: "`keyword'""
    return scalar n_results = 0
    exit 0
  }
  
  * Sort and limit
  sort - score name
  keep in 1/min(`limit', _N)
  
  * Return results
  local n = _N
  forvalue i = 1/`n' {
    return local indicator`i' = code[`i']
    return local name`i' = name[`i']
    return scalar score`i' = score[`i']
  }
  return scalar n_results = `n'
  
  * Display results (if not quiet)
  if ("`quietly'" == "") {
    display as text "Found `n' matches for: "`keyword'""
    display as text "{hline 70}"
    foreach var of varlist code name source_name {
      display in smcl %20s "`: var label `var''"
    }
    list code name source_name in 1/`n', subvarname
  }
  
end
```

### Helper 3: `_wbopendata_info.ado`

**Purpose:** Display detailed information about specific indicator

```stata
program def _wbopendata_info, rclass
  syntax anything(name=indicator_code id="indicator code")
  
  * Load YAML
  yaml_read using "_wbopendata_indicators.yaml", replace
  
  * Find indicator
  keep if code == "`indicator_code'"
  
  if (_N == 0) {
    display as error "Indicator not found: "`indicator_code'""
    error 111
  }
  
  if (_N > 1) {
    display as warning "Multiple matches found, showing first"
    keep in 1
  }
  
  * Extract all fields
  foreach var of varlist * {
    local `var' = `var'[1]
  }
  
  * Return all fields as r() values
  return local code = "`code'"
  return local name = "`name'"
  return local source_id = "`source_id'"
  return local source_name = "`source_name'"
  return local topic_ids = "`topic_ids'"
  return local topic_names = "`topic_names'"
  return local description = "`description'"
  return local latest_year = "`latest_year'"
  return local first_year = "`first_year'"
  return local unit = "`unit'"
  
  * Display formatted info
  display as result "Indicator: "`code'""
  display as text "  Name: `name'"
  display as text "  Source: `source_name'"
  display as text "  Topics: `topic_names'"
  display as text "  Unit: `unit'"
  display as text "  Data range: `first_year' - `latest_year'"
  display as text ""
  display as text "Description:"
  display as text "  `description'"
  
end
```

---

## Integration Points

### Option Parsing in Main Command

**Update `wbopendata.ado` syntax:**

```stata
syntax [, 
  ... existing options ...
  SEARCH(string)          // NEW: search("keyword")
  INFO(string)            // NEW: info("code")
  SOURCES                 // NEW: list sources
  TOPICS                  // NEW: list topics
  LIMIT(integer 20)       // NEW: for search
  DETAIL                  // NEW: for sources/topics
  ... other options ...
]
```

**Routing logic:**

```stata
* Check for discovery subcommands first
if ("`search'" != "") {
  _wbopendata_search "`search'", limit(`limit')
  exit 0
}

if ("`info'" != "") {
  _wbopendata_info "`info'"
  exit 0
}

if ("`sources'" != "") {
  _wbopendata_sources `if' `in', `detail'
  exit 0
}

if ("`topics'" != "") {
  _wbopendata_topics `if' `in', `detail'
  exit 0
}

* Otherwise, continue with existing data download workflow
...
```

---

### Help File Updates

**Update `wbopendata.sthlp`:**

```smcl
{cmd:wbopendata} - World Bank data access with metadata

DISCOVERY SUBCOMMANDS:
{it:Search for indicators}
{cmd:wbopendata, search("education")} [{cmd:limit(20)} {cmd:source(2)}]

{it:Get indicator details}
{cmd:wbopendata, info("SE.ADT.LITR.ZS")}

{it:List available sources}
{cmd:wbopendata, sources} [{cmd:detail}]

{it:List available topics}
{cmd:wbopendata, topics} [{cmd:detail}]

EXAMPLES:
{com}. wbopendata, search("GDP")
. wbopendata, search("school") source(2) limit(10)
. wbopendata, info("NY.GDP.MKTP.CD")
. wbopendata, sources detail
{txt}
```

---

## Testing & Validation

### Test Suite: `test_discovery.do`

```stata
* Test 1: Search basic functionality
capture program drop test_search
program def test_search
  wbopendata, search("education") limit(5)
  assert `r(n_results)' <= 5
  assert "`r(indicator1)'" != ""
end

* Test 2: Search with source filter
program def test_search_source
  wbopendata, search("GDP") source(2)
  assert `r(n_results)' > 0
  * Verify all results have source_id = 2
end

* Test 3: Info command
program def test_info
  wbopendata, info("SP.POP.TOTL")
  assert "`r(code)'" == "SP.POP.TOTL"
  assert "`r(source_id)'" == "2"
end

* Test 4: Non-existent indicator
program def test_info_notfound
  capture wbopendata, info("ZZ.NOT.EXIST")
  assert _rc == 111  // Variable not found
end

* Test 5: YAML schema validation
program def test_yaml_schema
  * Verify all required fields present
  * Verify version matches
  * Verify no duplicate codes
end
```

### Validation Checklist

- [ ] YAML files parse correctly
- [ ] No duplicate indicator codes
- [ ] All required metadata fields present
- [ ] Schema version matches expected
- [ ] Search returns relevant results
- [ ] Search ranking correct (name > description)
- [ ] Info returns all expected fields
- [ ] Limit option respects max
- [ ] Source filter works
- [ ] Performance < 1 second per search
- [ ] No memory leaks (cache cleanup)
- [ ] Existing wbopendata commands unaffected

---

## Performance Considerations

### Benchmark Targets

| Operation | Target | Acceptable |
|-----------|--------|-----------|
| Load YAML into memory | < 500ms | < 1000ms |
| Search 13K indicators | < 1000ms | < 2000ms |
| Info lookup | < 100ms | < 500ms |
| Sources list | < 100ms | < 200ms |
| Cache hit (repeat search) | < 50ms | < 100ms |

### Optimization Strategies

1. **Lazy loading:** Parse only requested YAML file
   ```stata
   if ("`search'" != "") {
     yaml_read "indicators"  // Only load indicators.yaml
   }
   ```

2. **In-memory caching:** Keep parsed YAML in memory
   ```stata
   if (c(WBOD_cache_loaded) == 1) {
     use $WBOD_cache_data, clear
   }
   ```

3. **Index pre-building:** Create search index at package install time
   - Generate search terms → indicator mapping
   - Store as .dta reference file
   - Speeds searches 10x

4. **Selective loading:** Load only needed fields
   ```yaml
   # Minimal search mode
   indicators:
     SP.POP.TOTL:
       code: "SP.POP.TOTL"
       name: "Population, total"
       # description omitted to reduce file size
   ```

---

## Future Extensibility

### v18.1 Enhancements (Pathway C Upgrades)

**1. Persistent Caching**
```stata
wbopendata, search("education") cache(persistent)
* Stores YAML in user's AppData for session reuse
```

**2. Automated Sync**
```stata
wbopendata, sync(check)      // Check for updates
wbopendata, sync(force)      // Force remote fetch
```

**3. Advanced Search**
```stata
wbopendata, search("school") AND source(2) limit(50)
* Support boolean operators
```

**4. Fuzzy Matching**
```stata
wbopendata, search("populaton", fuzzy)  // Typo tolerance
```

### Extension Points

**1. Plugin system:**
```stata
* Allow external .ado files to extend search
* Example: search plugin for custom indicators
_wbopendata_search_plugin "custom_keywords"
```

**2. Export formats:**
```stata
wbopendata, info("SP.POP.TOTL") export(csv|json|html)
```

**3. Saved searches:**
```stata
wbopendata, savesearch("development_indicators") 
wbopendata, loadsearch("development_indicators")
```

---

## Architecture Diagram: Complete Flow

```
User Command
    ↓
wbopendata.ado (syntax parser)
    ├─ [search] → route to _wbopendata_search
    ├─ [info]   → route to _wbopendata_info
    ├─ [sources]→ route to _wbopendata_sources
    └─ [existing] → route to existing API workflow

Discovery Router (_wbopendata_search.ado)
    ├─ Check cache (_WBOD_cache_loaded)
    ├─ If miss: yaml_read "indicators"
    ├─ Parse YAML to memory
    ├─ Build search index
    ├─ Execute search algorithm
    └─ Return r() values + display results

YAML Files (src/_/)
    ├─ _wbopendata_indicators.yaml (600 KB)
    ├─ _wbopendata_sources.yaml (50 KB)
    └─ _wbopendata_topics.yaml (20 KB)

Helper Libraries
    ├─ _yaml_read.ado (path resolution + version check)
    └─ yaml.ado (SSC - actual YAML parsing)
```

---

## Summary of Key Design Choices

| Choice | Decision | Rationale |
|--------|----------|-----------|
| Format | YAML | Multiplatform, human-readable, parsed via SSC |
| Files | 3 split files | Fast parsing, selective updates |
| Cache | In-memory | Balance performance + simplicity |
| Search | Weighted match | Balances precision + recall |
| Returns | Structured r() | Matches existing patterns |
| Schema | Versioned | Supports future evolution |
| Testing | Unit + integration | Validates correctness + performance |
| Performance | < 1 sec search | Meets user expectations |

---

*Document Status: DRAFT - Technical Reference*  
*For architects and developers implementing Pathway B*
