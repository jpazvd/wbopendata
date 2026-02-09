# Discovery Commands Architecture Proposal

**Date:** February 2026
**Version:** Draft 1.2
**Branch:** `feat/updates-search`

---

## Overview

This document proposes a unified discovery command structure for wbopendata, leveraging the existing YAML metadata infrastructure. All discovery commands produce **navigable outputs** with clickable SMCL links for drill-down exploration.

---

## Design Principles

1. **Navigable outputs**: Every result includes clickable SMCL links to related commands
2. **Consistent filtering**: `source()` and `topic()` filters work uniformly across commands
3. **Unified search**: Keywords search across code, name, description, source_org, topic_names, note
4. **Offline-first**: All discovery uses cached metadata - no API calls required
5. **Progressive disclosure**: Start broad (sources/topics) → narrow (search) → specific (indicator)
6. **rclass returns**: All commands return structured data for automation and reproducibility
7. **Scriptable**: Every interactive click can be replicated programmatically

---

## Command Structure

### Four Core Discovery Commands

| Command | Purpose | Output |
|---------|---------|--------|
| `sources` | List all data sources | Clickable list → drill to indicators |
| `topics` | List all topic categories | Clickable list → drill to indicators |
| `search(string)` | Search by keyword | Clickable results → drill to indicator details |
| `indicator(code)` | Show indicator metadata | Full details + download link |

---

## 1. `sources` - List All Data Sources

**Syntax:**
```stata
wbopendata, sources [limit(#)]
```

**Output with Navigation:**
```
World Bank Data Sources (71 sources, 29,323 indicators)
{hline 78}
 Code  Name                                        Indicators  [Browse]
{hline 78}
    1  Doing Business                                      89  {stata wbopendata, search() source(1)}
    2  World Development Indicators                     1,477  {stata wbopendata, search() source(2)}
    3  Worldwide Governance Indicators                      6  {stata wbopendata, search() source(3)}
    5  Subnational Malnutrition Database                   42  {stata wbopendata, search() source(5)}
    6  International Debt Statistics                    4,523  {stata wbopendata, search() source(6)}
   ...
{hline 78}
Tip: Click [Browse] to see all indicators from a source
     Use search(keyword) source(#) to filter within a source
```

**Return Values:**
```stata
r(n_sources)      // 71
r(n_indicators)   // 29323
r(source_codes)   // "1 2 3 5 6 11 12 ..."
```

**Implementation:** `_wbopendata_sources.ado` (new)

---

## 2. `topics` - List All Topic Categories

**Syntax:**
```stata
wbopendata, topics [limit(#)]
```

**Output with Navigation:**
```
World Bank Topics (21 categories)
{hline 78}
 ID  Name                                          Indicators  [Browse]
{hline 78}
  1  Agriculture & Rural Development                      456  {stata wbopendata, search() topic(1)}
  2  Aid Effectiveness                                     89  {stata wbopendata, search() topic(2)}
  3  Economy & Growth                                   1,234  {stata wbopendata, search() topic(3)}
  4  Education                                            567  {stata wbopendata, search() topic(4)}
  5  Energy & Mining                                      234  {stata wbopendata, search() topic(5)}
  ...
{hline 78}
Tip: Click [Browse] to see all indicators in a topic
     Use search(keyword) topic(#) to filter within a topic
```

**Return Values:**
```stata
r(n_topics)       // 21
r(topic_ids)      // "1 2 3 4 5 6 7 ..."
```

**Implementation:** `_wbopendata_topics.ado` (new)

---

## 3. `search(string)` - Search Indicators

**Syntax:**
```stata
wbopendata, search(pattern) [source(#)] [topic(#)] [limit(#)] [field(string)] [exact]
```

**Behavior:**
- If `source()` specified: search only within that source
- If `topic()` specified: search only within that topic
- If neither specified: search across ALL indicators
- If `field()` specified: search only in that metadata field
- If `exact` specified: require exact match (no wildcards)

### Field-Specific Search

The `field()` option directs the search to specific metadata fields. Default is `all`.

| Field Option | Searches In | Use Case |
|--------------|-------------|----------|
| `field(all)` | code, name, description, source_org, topic_names, note | **Default** - Broad discovery |
| `field(code)` | indicator code only | Find specific indicator patterns |
| `field(name)` | indicator name only | Search by indicator title |
| `field(description)` | description only | Search detailed definitions |
| `field(source)` | source_org only | Find by data source |
| `field(topic)` | topic_names only | Find by topic category |
| `field(note)` | note only | Search methodology notes |

**Multiple fields** can be specified with semicolons:
```stata
wbopendata, search(GDP) field(code;name)      // Search in code AND name
wbopendata, search(poverty) field(name;description)  // Search title and description
```

### Wildcard & Pattern Matching

| Pattern | Meaning | Example | Matches |
|---------|---------|---------|---------|
| `*` | Match any characters (0 or more) | `NY.GDP.*` | NY.GDP.MKTP.CD, NY.GDP.PCAP.KD |
| `?` | Match single character | `SP.POP.????.IN` | SP.POP.TOTL.IN, SP.POP.GROW.IN |
| `[abc]` | Match any character in set | `NY.GDP.[MP]*` | NY.GDP.MKTP.CD, NY.GDP.PCAP.CD |
| `[a-z]` | Match character range | `[A-Z][A-Z].*` | NY.*, SP.*, SL.* |
| `~` | Regex mode (advanced) | `~^NY\.GDP\..*CD$` | NY.GDP.MKTP.CD, NY.GDP.PCAP.CD |

**Pattern Examples:**
```stata
* Wildcard searches
wbopendata, search(NY.GDP.*)              // All GDP indicators starting with NY.GDP
wbopendata, search(*poverty*)             // Any indicator containing "poverty"
wbopendata, search(SP.POP.????)           // Population indicators with 4-char suffix
wbopendata, search(*.CD)                  // All indicators ending in .CD (current $)

* Code-specific search
wbopendata, search(NY.GDP.*) code         // Search only in indicator codes
wbopendata, search(education) name        // Search only in indicator names

* Exact match (no wildcards)
wbopendata, search(NY.GDP.MKTP.CD) exact  // Exact code match only

* Combined filters
wbopendata, search(NY.GDP.*) source(2) code    // GDP codes in WDI only

* Regex mode (advanced users)
wbopendata, search(~^SP\.DYN\..*\.IN$)    // Regex: SP.DYN.*.IN pattern
```

### Field Option Examples

```stata
* Default: search all fields
wbopendata, search(GDP)                           // Searches code, name, description, etc.

* Search specific field
wbopendata, search(NY.GDP.*) field(code)          // Code patterns only
wbopendata, search(gross domestic) field(name)   // Names only
wbopendata, search(purchasing power) field(description)  // Descriptions only
wbopendata, search(OECD) field(source)            // Source organization only
wbopendata, search(poverty) field(topic)          // Topic names only
wbopendata, search(aggregation) field(note)       // Methodology notes only

* Multiple fields
wbopendata, search(GDP) field(code;name)          // Code OR name
wbopendata, search(poverty) field(name;description;note)  // Title, description, or notes

* Combined with other filters
wbopendata, search(per capita) field(name) source(2)      // Names in WDI
wbopendata, search(NY.GDP.*) field(code) topic(3) exact   // Exact code in Economy topic
```

**Output with Navigation:**
```
Search results for "GDP" (showing 20 of 847 matches)
{hline 85}
 Code                    Name                                    Source   [Info] [Get]
{hline 85}
 NY.GDP.MKTP.CD         GDP (current US$)                       WDI      {stata wbopendata, indicator(NY.GDP.MKTP.CD)} {stata wbopendata, indicator(NY.GDP.MKTP.CD) clear}
 NY.GDP.MKTP.KD         GDP (constant 2015 US$)                 WDI      {stata ...} {stata ...}
 NY.GDP.PCAP.CD         GDP per capita (current US$)            WDI      {stata ...} {stata ...}
 NY.GDP.PCAP.KD         GDP per capita (constant 2015 US$)      WDI      {stata ...} {stata ...}
 ...
{hline 85}
Showing 20 of 847 results. Use limit(#) to see more.
```

**Filtered Example:**
```stata
wbopendata, search(poverty) source(2)     // Search "poverty" in WDI only
wbopendata, search(education) topic(4)    // Search "education" in Education topic
wbopendata, search() source(37)           // List ALL indicators from source 37
wbopendata, search() topic(11)            // List ALL indicators in Poverty topic
```

**Return Values:**
```stata
r(n_results)      // 847
r(n_displayed)    // 20
r(first_code)     // "NY.GDP.MKTP.CD"
r(codes)          // "NY.GDP.MKTP.CD NY.GDP.MKTP.KD ..."
```

**Implementation:** Enhance existing `_wbopendata_search.ado`

---

## 4. `indicator(code)` - Indicator Metadata

**Syntax:**
```stata
wbopendata, indicator(NY.GDP.MKTP.CD) [describe]
```

**Note:** The `describe` option shows metadata without downloading data. Without `describe`, it downloads data (existing behavior).

**Output with Navigation (describe mode):**
```
{hline 78}
Indicator: NY.GDP.MKTP.CD
{hline 78}
Name:        GDP (current US$)
Source:      World Development Indicators (2)  {stata wbopendata, search() source(2)}
Topics:      Economy & Growth (3)              {stata wbopendata, search() topic(3)}

Description:
GDP at purchaser's prices is the sum of gross value added by all resident
producers in the economy plus any product taxes and minus any subsidies...

Source Organization:
World Bank national accounts data, and OECD National Accounts data files.

Note:
(aggregation method: Gap-filled total)

{hline 78}
Download:    {stata wbopendata, indicator(NY.GDP.MKTP.CD) clear}
             {stata wbopendata, indicator(NY.GDP.MKTP.CD) clear long}
             {stata wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA;USA;CHN) clear long}
{hline 78}
```

**Return Values:**
```stata
r(indicator)      // "NY.GDP.MKTP.CD"
r(name)           // "GDP (current US$)"
r(source_id)      // "2"
r(source_name)    // "World Development Indicators"
r(topic_ids)      // "3"
r(topic_names)    // "Economy & Growth"
r(description)    // "GDP at purchaser's prices..."
r(source_org)     // "World Bank national accounts..."
r(note)           // "(aggregation method: Gap-filled total)"
```

**Implementation:** Enhance existing `_wbopendata_info.ado` → rename to align with `indicator()` option

---

## Navigation Flow

```
┌─────────────┐     ┌─────────────┐
│   sources   │     │   topics    │
│  (71 items) │     │  (21 items) │
└──────┬──────┘     └──────┬──────┘
       │                   │
       │  click [Browse]   │  click [Browse]
       ▼                   ▼
┌──────────────────────────────────┐
│         search(keyword)          │
│   [optional: source() topic()]   │
│        (filtered results)        │
└───────────────┬──────────────────┘
                │
                │  click [Info] or [Get]
                ▼
┌──────────────────────────────────┐
│      indicator(code) describe    │
│    (full metadata + download)    │
└──────────────────────────────────┘
```

---

## Existing Infrastructure to Leverage

### YAML Files (already cached)

| File | Records | Key Fields |
|------|---------|------------|
| `_wbopendata_indicators.yaml` | 29,323 | code, name, source_id, source_name, topic_ids, topic_names, description, source_org, note, limited_data |
| `_wbopendata_sources.yaml` | 71 | code, name, description, data_availability, metadata_availability |
| `_wbopendata_topics.yaml` | 21 | id, name, source_note |

### Existing ADO Files

| File | Status | Changes Needed |
|------|--------|----------------|
| `_wbopendata_search.ado` | Exists | Add `source()`, `topic()` filters; add SMCL navigation |
| `_wbopendata_info.ado` | Exists | Add SMCL navigation links |
| `_wbopendata_cache.ado` | Exists | No changes |
| `_wbopendata_get_yaml_path.ado` | Exists | No changes |

### New ADO Files Needed

| File | Purpose |
|------|---------|
| `_wbopendata_sources.ado` | List sources with navigation |
| `_wbopendata_topics.ado` | List topics with navigation |

---

## Main Entry Point Changes

Update `wbopendata.ado` syntax:

```stata
syntax [, ... existing options ...
    /// Discovery Commands
    SOURCES                     /// List all sources
    TOPICS                      /// List all topics
    SEARCH(string)              /// Search indicators
    SOURCE(string)              /// Filter by source ID (for search)
    TOPIC(string)               /// Filter by topic ID (for search)
    LIMIT(integer 20)           /// Limit results
    DESCRIBE                    /// Show metadata only (no download)
]
```

**Routing Logic:**
```stata
* Discovery commands
if ("`sources'" != "") {
    _wbopendata_sources, limit(`limit')
    exit
}
if ("`topics'" != "") {
    _wbopendata_topics, limit(`limit')
    exit
}
if ("`search'" != "") {
    _wbopendata_search "`search'", limit(`limit') source("`source'") topic("`topic'")
    exit
}
if ("`describe'" != "" & "`indicator'" != "") {
    _wbopendata_info, indicator("`indicator'")
    exit
}
```

---

## SMCL Link Patterns

### Clickable Command Links
```stata
* Display clickable link to run a command
di `"{stata `"wbopendata, search() source(2)"':[Browse]}"'

* Display with custom text
di `"{stata `"wbopendata, indicator(NY.GDP.MKTP.CD) describe"':NY.GDP.MKTP.CD}"'

* Download link
di `"{stata `"wbopendata, indicator(NY.GDP.MKTP.CD) clear"':[Download]}"'
```

### Navigation Footer Pattern
```stata
di as text "{hline 78}"
di as text "Navigation:"
di `"  {stata wbopendata, sources:← Sources}  "'
di `"  {stata wbopendata, topics:← Topics}  "'
di `"  {stata wbopendata, search(`keyword'):↻ Refine search}"'
```

---

## Implementation Priority

| Phase | Feature | Files | Effort |
|-------|---------|-------|--------|
| **1** | `sources` command | `_wbopendata_sources.ado`, `wbopendata.ado` | Low |
| **1** | `topics` command | `_wbopendata_topics.ado`, `wbopendata.ado` | Low |
| **2** | Add `source()`/`topic()` filters to search | `_wbopendata_search.ado` | Medium |
| **2** | Add SMCL navigation to all outputs | All discovery ado files | Medium |
| **3** | `indicator(code) describe` mode | `_wbopendata_info.ado` | Low |

---

## rclass Returns for Automation

All discovery commands are **rclass** and return structured data for scripting, automation, and reproducibility.

### `wbopendata, sources`

```stata
. wbopendata, sources
. return list

scalars:
    r(n_sources)       =  71           // Total number of sources
    r(n_available)     =  68           // Sources with data available
    r(n_indicators)    =  29323        // Total indicators across all sources

macros:
    r(source_codes)    : "1 2 3 5 6 11 12 ..."    // Space-separated source IDs
    r(source_names)    : `""Doing Business" "World Development Indicators" ..."'
    r(cmd)             : "wbopendata, sources"    // Command for reproducibility
```

### `wbopendata, topics`

```stata
. wbopendata, topics
. return list

scalars:
    r(n_topics)        =  21           // Total number of topics

macros:
    r(topic_ids)       : "1 2 3 4 5 6 7 ..."      // Space-separated topic IDs
    r(topic_names)     : `""Agriculture & Rural Development" "Aid Effectiveness" ..."'
    r(cmd)             : "wbopendata, topics"
```

### `wbopendata, search(keyword) [source(#)] [topic(#)] [field(string)]`

```stata
. wbopendata, search(GDP) source(2) field(code;name) limit(10)
. return list

scalars:
    r(n_results)       =  847          // Total matches (before limit)
    r(n_displayed)     =  10           // Matches shown (after limit)

macros:
    r(keyword)         : "GDP"
    r(source_filter)   : "2"           // Empty if no filter
    r(topic_filter)    : ""            // Empty if no filter
    r(field_filter)    : "code;name"   // Empty if all (default)
    r(codes)           : "NY.GDP.MKTP.CD NY.GDP.MKTP.KD NY.GDP.PCAP.CD ..."
    r(first_code)      : "NY.GDP.MKTP.CD"
    r(names)           : `""GDP (current US$)" "GDP (constant 2015 US$)" ..."'
    r(cmd)             : "wbopendata, search(GDP) source(2) field(code;name) limit(10)"
```

### `wbopendata, indicator(code) describe`

```stata
. wbopendata, indicator(NY.GDP.MKTP.CD) describe
. return list

macros:
    r(indicator)       : "NY.GDP.MKTP.CD"
    r(name)            : "GDP (current US$)"
    r(source_id)       : "2"
    r(source_name)     : "World Development Indicators"
    r(source_org)      : "World Bank national accounts data..."
    r(topic_ids)       : "3"
    r(topic_names)     : "Economy & Growth"
    r(description)     : "GDP at purchaser's prices is the sum..."
    r(note)            : "(aggregation method: Gap-filled total)"
    r(unit)            : "current US$"
    r(limited_data)    : "0"           // 1 if limited coverage
    r(cmd)             : "wbopendata, indicator(NY.GDP.MKTP.CD) describe"
```

### Automation Examples

**Loop through sources:**
```stata
* Get all sources, then iterate
wbopendata, sources
local src_list = r(source_codes)
foreach src of local src_list {
    wbopendata, search() source(`src') limit(5)
    di "Source `src': " r(n_results) " indicators"
}
```

**Build indicator dataset from search:**
```stata
* Search and capture results
wbopendata, search(poverty) limit(100)
local n = r(n_results)
local codes = r(codes)

* Create dataset of matching indicators
clear
set obs `n'
gen str32 code = ""
local i = 1
foreach c of local codes {
    replace code = "`c'" in `i'
    local i = `i' + 1
}
```

**Reproducible workflow:**
```stata
* Log the exact command used
wbopendata, search(education) source(2) topic(4) limit(50)
local cmd = r(cmd)
di "Reproducibility: `cmd'"
* Output: "wbopendata, search(education) source(2) topic(4) limit(50)"
```

**Chained discovery:**
```stata
* Find indicator, get details, download
wbopendata, search(GDP per capita) limit(1)
local ind = r(first_code)

wbopendata, indicator(`ind') describe
local name = r(name)
di "Downloading: `name'"

wbopendata, indicator(`ind') clear long
```

---

## Testing Checklist

- [ ] `sources` displays all 71 sources with clickable links
- [ ] `topics` displays all 21 topics with clickable links
- [ ] `search(GDP)` returns results across all sources
- [ ] `search(GDP) source(2)` filters to WDI only
- [ ] `search(education) topic(4)` filters to Education topic
- [ ] `search() source(37)` lists ALL indicators from source 37
- [ ] `indicator(NY.GDP.MKTP.CD) describe` shows metadata with download links
- [ ] All SMCL links are clickable and execute correct commands
- [ ] Return values are populated correctly

---

## Example Session

```stata
. wbopendata, sources
World Bank Data Sources (71 sources)
...
    2  World Development Indicators  1,477  [Browse]
...

. * User clicks [Browse] next to source 2

. wbopendata, search() source(2)
Indicators from Source 2: World Development Indicators (showing 20 of 1,477)
...
 NY.GDP.MKTP.CD  GDP (current US$)  [Info] [Get]
...

. * User clicks [Info]

. wbopendata, indicator(NY.GDP.MKTP.CD) describe
Indicator: NY.GDP.MKTP.CD
Name: GDP (current US$)
...
Download: [Wide format] [Long format] [Specific countries]

. * User clicks [Long format]

. wbopendata, indicator(NY.GDP.MKTP.CD) clear long
(downloading data...)
```

---

## Open Questions

1. **Rename `info()` to `indicator() describe`?**
   - Pro: Consistent with existing `indicator()` option
   - Con: Breaking change for users of `info()`
   - Recommendation: Support both, deprecate `info()` in v18

2. **Empty search string behavior?**
   - `search() source(2)` = list ALL indicators from source 2
   - `search() topic(4)` = list ALL indicators in topic 4
   - `search()` alone = error (too many results)

---

## Implementation Strategy: Frame + Mata

### Recommended Architecture

Use Stata frames (v16+) with Mata for optimal performance:

```
┌─────────────────────────────────────────────────────────────┐
│                      wbopendata.ado                         │
│                    (main entry point)                       │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              _wbopendata_discovery.ado                      │
│         (frame manager + Mata query dispatcher)             │
│                                                             │
│  1. Ensure frame exists (_wbopendata_ind)                   │
│  2. Load .dta into frame if needed                          │
│  3. Dispatch to Mata query functions                        │
│  4. Format and display results with SMCL                    │
└─────────────────────────┬───────────────────────────────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│  Frame:     │   │  Frame:     │   │  Frame:     │
│ _wb_ind     │   │ _wb_src     │   │ _wb_topic   │
│ (29K rows)  │   │ (71 rows)   │   │ (21 rows)   │
└─────────────┘   └─────────────┘   └─────────────┘
```

### Data Flow Options

**Option A: YAML → .dta → Frame (Recommended)**
```
[sync command]
     │
     ▼
┌──────────────────┐     ┌──────────────────┐
│  YAML files      │ ──► │  .dta files      │  (parse once)
│  (GitHub/cache)  │     │  (local cache)   │
└──────────────────┘     └────────┬─────────┘
                                  │
                         [first discovery cmd per session]
                                  │  (~0.5 sec)
                                  ▼
                         ┌──────────────────┐
                         │  Stata Frames    │
                         │  (in memory)     │
                         └────────┬─────────┘
                                  │
                          [Mata queries]  (<0.1 sec)
                                  │
                                  ▼
                         ┌──────────────────┐
                         │  SMCL Output     │
                         │  + rclass values │
                         └──────────────────┘
```

**Option B: YAML → Frame (Direct, Simpler)**
```
[first discovery cmd per session]
     │
     ▼
┌──────────────────┐
│  YAML files      │  (parse each session: 2-5 sec)
│  (local cache)   │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│  Stata Frames    │
│  (in memory)     │
└────────┬─────────┘
         │
  [Mata queries]  (<0.1 sec)
         │
         ▼
┌──────────────────┐
│  SMCL Output     │
│  + rclass values │
└──────────────────┘
```

**Comparison:**

| Metric | Option A (YAML→.dta→Frame) | Option B (YAML→Frame) |
|--------|---------------------------|----------------------|
| First load per session | ~0.5 sec | 2-5 sec |
| Sync overhead | +2-5 sec (build .dta) | None |
| Files in cache | YAML + .dta | YAML only |
| Complexity | Medium | Low |
| **Recommendation** | **Production** | Prototyping |

---

## Stress Test Analysis

### Performance Benchmarks (Estimated)

| Operation | Current (YAML parse) | .dta Load | Frame + Mata |
|-----------|---------------------|-----------|--------------|
| First search | 3-5 sec | 0.5-1 sec | 0.5-1 sec |
| Subsequent search | 3-5 sec | 0.5-1 sec | **<0.1 sec** |
| sources (71 rows) | 0.5 sec | 0.1 sec | <0.1 sec |
| topics (21 rows) | 0.3 sec | 0.1 sec | <0.1 sec |
| indicator info | 2-4 sec | 0.3 sec | <0.1 sec |
| Memory usage | Low (temp) | Medium | Medium (persistent) |

### Strengths

| Strength | Description | Impact |
|----------|-------------|--------|
| **Speed** | Mata is compiled; frame data stays in memory | 10-50x faster for repeated queries |
| **Isolation** | Frames don't disturb user's working dataset | Zero impact on user workflow |
| **Persistence** | Frame survives across commands in session | Load once, query many times |
| **Native types** | Stata's optimized string storage | Efficient memory layout |
| **Vectorization** | Mata can process columns in bulk | Fast filtering |
| **SMCL integration** | Easy to build clickable output | Good UX |

### Weaknesses

| Weakness | Description | Severity | Mitigation |
|----------|-------------|----------|------------|
| **Stata 16+ required** | Frames not available in Stata 14-15 | High | Fallback to .dta reload |
| **Memory footprint** | 29K indicators × ~10 fields ≈ 20-50MB | Medium | Acceptable for modern systems |
| **Stale data risk** | Frame persists even if cache updates | Medium | Version check on frame load |
| **String length limit** | Stata strings max 2,045 chars (strL: 2B) | Low | Use strL for description/note |
| **Frame cleared** | User may run `frames reset` | Low | Lazy reload on next query |
| **Complexity** | Mata code harder to debug | Medium | Good error handling, logging |
| **Initial load** | First query still takes 0.5-1 sec | Low | Acceptable trade-off |

### Edge Cases & Error Handling

| Edge Case | Risk | Handling Strategy |
|-----------|------|-------------------|
| **Cache not found** | User never ran `sync` | Clear error: "Run wbopendata, sync first" |
| **Corrupted .dta** | File damaged | Detect with `confirm file`, prompt re-sync |
| **Frame already exists but stale** | Cache updated, frame not | Check version marker in frame vs cache |
| **Unicode in indicator names** | Special chars break SMCL | Escape with `char()` or use `{c ...}` |
| **Very long descriptions** | >244 chars in str244 | Use strL type in .dta generation |
| **Concurrent Stata sessions** | Two instances, one syncs | Frame is per-session; .dta shared (OK) |
| **Network drive I/O** | Slow cache access | Consider `tempfile` copy for frame load |
| **Empty search results** | No matches for keyword | Graceful message with suggestions |
| **Invalid source/topic ID** | User types wrong number | Validate against known IDs, suggest alternatives |
| **Indicator code not found** | Typo or deprecated | Fuzzy match suggestion, list similar codes |

### Memory Analysis

```
Indicator frame estimate (29,323 rows):
┌────────────────────┬──────────┬─────────────┐
│ Field              │ Type     │ Est. Size   │
├────────────────────┼──────────┼─────────────┤
│ code               │ str32    │ 0.9 MB      │
│ name               │ str100   │ 2.9 MB      │
│ source_id          │ str4     │ 0.1 MB      │
│ source_name        │ str50    │ 1.5 MB      │
│ topic_ids          │ str20    │ 0.6 MB      │
│ topic_names        │ str100   │ 2.9 MB      │
│ description        │ strL     │ 10-20 MB    │
│ source_org         │ strL     │ 5-10 MB     │
│ note               │ strL     │ 2-5 MB      │
│ limited_data       │ byte     │ 0.03 MB     │
├────────────────────┼──────────┼─────────────┤
│ TOTAL              │          │ 25-45 MB    │
└────────────────────┴──────────┴─────────────┘

Additional frames:
- Sources (71 rows): ~50 KB
- Topics (21 rows): ~20 KB

Total memory: ~25-50 MB (acceptable for discovery feature)
```

### Version Compatibility Strategy

```stata
program define _wbopendata_discovery
    * Check Stata version
    if (c(stata_version) >= 16) {
        * Use frame + Mata (fast path)
        _wbopendata_discovery_frame, `0'
    }
    else {
        * Fallback: reload .dta each time (slower but works)
        _wbopendata_discovery_legacy, `0'
    }
end
```

| Stata Version | Strategy | Performance |
|---------------|----------|-------------|
| 14-15 | .dta reload per query | ~0.5s per search |
| 16+ | Frame + Mata | <0.1s after first load |

---

## Areas for Improvement

### Short-term (v17.8)

1. **Lazy frame loading**
   - Don't load frame until first discovery command
   - Reduces startup overhead for users who don't use discovery

2. **Frame version tracking**
   ```stata
   * Store version in frame characteristic
   frame _wbopendata_ind: char _dta[cache_version] "2.0.0"

   * Check on each query
   if ("`c(frame_char[cache_version])'" != "`cache_version'") {
       _wb_reload_frame
   }
   ```

3. **Graceful degradation**
   - If Mata fails, fall back to Stata loop
   - If frame fails, fall back to .dta reload

### Medium-term (v17.9)

4. **Search indexing**
   - Pre-compute lowercase versions of searchable fields
   - Add `_search_text` column: concatenated lowercase fields
   ```stata
   gen _search_text = lower(code + " " + name + " " + description)
   ```

5. **Partial frame loading**
   - For `sources` command: only load _wb_src frame (71 rows)
   - For `topics` command: only load _wb_topic frame (21 rows)
   - Load full indicator frame only for `search()` and `info()`

6. **Result caching**
   - Cache recent search results in Mata matrix
   - Invalidate on frame reload
   ```mata
   struct _wb_cache {
       string scalar last_keyword
       string scalar last_source
       string matrix results
   }
   ```

### Long-term (v18.0)

7. **Fuzzy matching**
   - Implement Levenshtein distance in Mata
   - Suggest corrections for typos
   ```
   . wbopendata, search(GDQ)
   No exact matches for "GDQ". Did you mean:
     GDP (847 indicators)
     GDI (12 indicators)
   ```

8. **Indicator recommendations**
   - "Users who downloaded X also downloaded Y"
   - Based on co-occurrence in topic_ids

9. **Offline-first with background sync**
   - Check for updates in background
   - Notify user if new metadata available
   - Never block on network

10. **Full-text search**
    - Index description and note fields
    - Support phrase search: `search("per capita")`
    - Support exclusion: `search(GDP -growth)`

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Frame feature removed in future Stata | Very Low | High | Maintain legacy fallback |
| Memory issues on low-RAM systems | Low | Medium | Document 50MB requirement |
| YAML format changes upstream | Low | High | Version-aware parser |
| Mata performance varies by Stata version | Medium | Low | Benchmark and document |
| SMCL rendering issues in different UIs | Medium | Low | Test in Stata GUI, console, VSCode |
| User clears frames accidentally | Medium | Low | Lazy reload handles this |

---

## Testing Strategy

### Unit Tests

```stata
* Frame management
_wb_ensure_frame
assert "`r(frame_loaded)'" == "1"

* Search accuracy
wbopendata, search(GDP) source(2)
assert r(n_results) > 100
assert strpos(r(first_code), "GDP") > 0

* Filter combination
wbopendata, search(education) topic(4) limit(5)
assert r(n_displayed) == 5

* Edge cases
wbopendata, search(xyznonexistent123)
assert r(n_results) == 0
```

### Performance Tests

```stata
* Benchmark: 100 searches in sequence
timer clear
timer on 1
forvalues i = 1/100 {
    quietly wbopendata, search(indicator`i') limit(10)
}
timer off 1
timer list 1
* Expected: <10 seconds total (0.1s each)
```

### Stress Tests

```stata
* Large result set
wbopendata, search() source(2) limit(2000)
assert r(n_results) > 1000

* Rapid sequential queries
forvalues i = 1/50 {
    wbopendata, search(test`i')
}
* Should not crash or leak memory

* Frame recovery
frames reset
wbopendata, search(GDP)
* Should auto-reload frame
```

---

## Comparison: Implementation Approaches

| Approach | Pros | Cons | Verdict |
|----------|------|------|---------|
| **YAML parse each time** | Simple, low memory | Slow (3-5s) | Current, needs upgrade |
| **.dta reload each time** | Simple, medium speed | Repeated I/O (0.5s) | Good fallback |
| **Frame + Stata loops** | Frame isolation | Stata loops slow | Not recommended |
| **Frame + Mata** | Fast, persistent | Complexity, v16+ | **Recommended** |
| **Pure Mata (no frame)** | Very fast | No isolation, complex | Overkill |
| **External index (SQLite)** | Powerful search | Dependency, complexity | Future option |

---

## Decision Log

| Decision | Rationale | Date |
|----------|-----------|------|
| Use frames over preserve/restore | Frames don't disturb user data | 2026-02 |
| Mata for queries, Stata for display | Best of both worlds | 2026-02 |
| .dta intermediate format | Faster than YAML, Stata-native | 2026-02 |
| Lazy frame loading | Reduce startup overhead | 2026-02 |
| Support Stata 14+ with fallback | Maintain broad compatibility | 2026-02 |
| strL for long text fields | Handle descriptions >244 chars | 2026-02 |

---

## Next Steps

1. [ ] Review and approve architecture
2. [ ] Implement `_wbopendata_build_dta.ado` (YAML → .dta converter)
3. [ ] Implement `_wbopendata_discovery.ado` (frame manager)
4. [ ] Implement Mata query functions
5. [ ] Create `_wbopendata_sources.ado` with SMCL navigation
6. [ ] Create `_wbopendata_topics.ado` with SMCL navigation
7. [ ] Enhance `_wbopendata_search.ado` with `source()`/`topic()` filters
8. [ ] Add SMCL navigation to all discovery outputs
9. [ ] Update `wbopendata.ado` routing
10. [ ] Implement Stata 14-15 fallback path
11. [ ] Write unit tests and performance benchmarks
12. [ ] Update help file documentation
13. [ ] Add tests to `qa/run_tests.do`
