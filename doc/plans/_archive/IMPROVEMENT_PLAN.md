# wbopendata Improvement Plan

[← Back to README](../../README.md) | [FAQ](../FAQ.md) | [**📍 ROADMAP**](ROADMAP.md)

> ⚠️ **ARCHIVED**: This document has been consolidated into [ROADMAP.md](ROADMAP.md). See that file for the current development plan.

---

## Overview

This improvement plan draws insights from the recently developed [`unicefData`](https://github.com/jpazvd/unicefData) Stata package. The goal is to modernize `wbopendata` while maintaining backward compatibility with the 13+ years of existing user workflows.

**Document Created:** December 21, 2025  
**Archived:** December 23, 2025  
**Current wbopendata Version:** 17.4  
**Reference Implementation:** unicefData v1.5.1

---

## Executive Summary

| Priority | Feature | Impact | Effort |
|----------|---------|--------|--------|
| **HIGH** | Discovery subcommands (`search`, `info`, `sources`) | Users can find indicators interactively | Medium |
| **HIGH** | YAML-based metadata sync | Offline indicator discovery, faster lookups | High |
| **MEDIUM** | Modern test infrastructure | CI/CD automation, quality assurance | Medium |
| **MEDIUM** | Enhanced output formats (`wide_indicators`) | Better multi-indicator analysis | Low |
| **MEDIUM** | Metadata enrichment (`addmeta`) | Region, income_group without separate calls | Medium |
| **LOW** | Cross-language parity (R/Python) | Broader ecosystem | High |
| **LOW** | GitHub Actions CI | Automated testing on commits | Low |

---

## Phase 1: Discovery Subcommands (HIGH Priority)

### Current State

`wbopendata` relies on static help files (`wbopendata_sourceid_indicators*.sthlp`) generated offline. Users must:
1. Know the exact indicator code, OR
2. Browse through long help files to find indicators

### Proposed Changes

Add interactive discovery commands (inspired by `unicefdata`):

#### 1.1 Search Subcommand
```stata
* Find indicators by keyword
wbopendata, search("education")
wbopendata, search("GDP") limit(20) source(2)  // WDI only

* Output:
* ----------------------------------------------------------------------
* Search Results for: education
* ----------------------------------------------------------------------
*  Indicator            Source   Name
*  SE.ADT.LITR.ZS       WDI      Literacy rate, adult total (%)
*  SE.PRM.ENRR          WDI      School enrollment, primary (% gross)
*  ...
```

**Implementation:**
- Create `_wbopendata_search_indicators.ado` helper
- Parse YAML or local metadata file
- Support case-insensitive keyword matching
- Return list: `r(indicators)`, `r(n_matches)`

#### 1.2 Indicator Info Subcommand
```stata
* Get detailed metadata for single indicator
wbopendata, info("SE.ADT.LITR.ZS")

* Output:
* ----------------------------------------------------------------------
* Indicator: SE.ADT.LITR.ZS
* ----------------------------------------------------------------------
* Name:           Literacy rate, adult total (% of people ages 15+)
* Source:         World Development Indicators
* Description:    Percentage of population age 15 and above who can...
* Last Updated:   2025-01-15
* Time Coverage:  1970-2023
* Source Org:     UNESCO Institute for Statistics
```

**Implementation:**
- Create `_wbopendata_indicator_info.ado` helper
- Query API metadata endpoint OR use local YAML cache
- Display formatted output with clickable links

#### 1.3 List Sources/Topics Subcommand
```stata
* List all data sources
wbopendata, sources

* List all topics
wbopendata, topics detail

* List indicators in a specific source
wbopendata, indicators(2)  // Source 2 = WDI
```

**Files to Create:**
```
src/_/
├── _wbopendata_search_indicators.ado
├── _wbopendata_indicator_info.ado
├── _wbopendata_list_sources.ado
├── _wbopendata_list_topics.ado
└── _wbopendata_list_indicators.ado
```

---

## Phase 2: YAML-Based Metadata System (HIGH Priority)

### Current State

- Metadata is generated offline into `.sthlp` files
- Over 90+ static help files in `src/w/`
- Updates require re-running `update` commands
- No structured data for programmatic access

### Proposed Changes

Adopt YAML metadata architecture from `unicefData`:

#### 2.1 Metadata File Structure
```
src/_/
├── _wbopendata_sources.yaml       # Source definitions (WDI, GEM, etc.)
├── _wbopendata_topics.yaml        # Topic definitions
├── _wbopendata_indicators.yaml    # Indicator → source/topic mappings
├── _wbopendata_countries.yaml     # Country metadata with regions
├── _wbopendata_sync_history.yaml  # Sync timestamps
```

#### 2.2 Sample YAML Format
```yaml
# _wbopendata_indicators.yaml
_metadata:
  platform: stata
  version: 2.0.0
  synced_at: "2025-12-21T10:00:00Z"
  source: "https://api.worldbank.org/v2/"
  
indicators:
  SE.ADT.LITR.ZS:
    code: "SE.ADT.LITR.ZS"
    name: "Literacy rate, adult total"
    source_id: 2
    topic_id: 4
    source_org: "UNESCO"
    
  NY.GDP.MKTP.CD:
    code: "NY.GDP.MKTP.CD"
    name: "GDP (current US$)"
    source_id: 2
    topic_id: 3
    source_org: "World Bank national accounts"
```

#### 2.3 Sync Command
```stata
* Sync metadata from World Bank API
wbopendata, sync              // Sync all metadata
wbopendata, sync(indicators)  // Sync indicators only
wbopendata, sync verbose      // Show progress
wbopendata, sync history      // Show sync history
```

**Implementation:**
- Create `wbopendata_sync.ado` (similar to `unicefdata_sync.ado`)
- Use `yaml.ado` from SSC for YAML read/write
- Parse World Bank API responses to YAML

**Dependencies:**
- `yaml.ado` (install from SSC or bundle)

---

## Phase 3: Enhanced Output Formats (MEDIUM Priority)

### Current State

- Supports `long` and implicit wide format
- Multiple indicators require post-processing reshapes

### Proposed Changes

#### 3.1 Wide Indicators Format
```stata
* Multiple indicators as columns
wbopendata, indicator(SE.ADT.LITR.ZS;NY.GDP.MKTP.CD) country(BRA;USA) ///
    wide_indicators clear

* Result:
*   countrycode  year  SE_ADT_LITR_ZS  NY_GDP_MKTP_CD
*   BRA          2020  93.2            1.4e+12
*   USA          2020  99.0            2.1e+13
```

#### 3.2 Metadata Enrichment
```stata
* Add region, income level automatically
wbopendata, indicator(SE.ADT.LITR.ZS) addmeta(region income) clear

* Result includes:
*   countrycode  countryname  region     incomelevel  year  value
*   BRA          Brazil       LAC        Upper-mid    2020  93.2
*   USA          United States NAC       High         2020  99.0
```

**Implementation:**
- Add `wide_indicators` option to syntax
- Add `addmeta(string)` option
- Merge country metadata after data retrieval

---

## Phase 4: Test Infrastructure (MEDIUM Priority)

### Current State

- Manual test protocols in `qa/test_protocol*.txt`
- No automated tests
- No CI/CD pipeline

### Proposed Changes

#### 4.1 Automated Test Suite
Create structured test files:

```
qa/
├── tests/
│   ├── test_basic.do          # Core functionality
│   ├── test_discovery.do      # Search, info, list
│   ├── test_sync.do           # Metadata sync
│   ├── test_outputs.do        # Output format tests
│   └── test_edge_cases.do     # Error handling
├── run_tests.do               # Master test runner
└── README.md
```

#### 4.2 Test Runner Template
```stata
* run_tests.do - Master test runner
program define run_test
    syntax , TEstnum(integer) TItle(string) CMd(string asis)
    
    timer on `testnum'
    capture noisily `cmd'
    local rc = _rc
    timer off `testnum'
    
    if (`rc' == 0) {
        global tests_passed = $tests_passed + 1
        di as result "PASSED: `title'"
    }
    else {
        global tests_failed = $tests_failed + 1
        di as err "FAILED: `title' (rc=`rc')"
    }
end
```

#### 4.3 GitHub Actions CI
Create `.github/workflows/stata-tests.yaml`:

```yaml
name: Stata Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Stata
        uses: stata-actions/setup-stata@v1
        with:
          version: 17
          
      - name: Run tests
        run: stata-mp -b do qa/run_tests.do
        
      - name: Check results
        run: grep -q "FAILED:" qa/run_tests.log && exit 1 || exit 0
```

---

## Phase 5: Code Architecture Improvements (MEDIUM Priority)

### 5.1 Modular Helper Structure

Refactor to match `unicefData` pattern:

| Current | Proposed |
|---------|----------|
| `_query.ado` | `_wbopendata_fetch.ado` |
| `_query_metadata.ado` | `_wbopendata_metadata.ado` |
| `_api_read.ado` | `_wbopendata_api.ado` |
| (none) | `_wbopendata_parse_yaml.ado` |
| (none) | `_wbopendata_search_indicators.ado` |

### 5.2 Frame Support (Stata 16+)

Add frame-based operations for better data isolation:

```stata
* Example from unicefdata - use frames when available
local use_frames = (c(stata_version) >= 16)

if (`use_frames') {
    frame create wbopendata_temp
    frame wbopendata_temp {
        // fetch and process data
    }
    frame copy wbopendata_temp default, replace
    frame drop wbopendata_temp
}
```

### 5.3 Improved Error Messages

Adopt structured error codes (from unicefData pattern):

```stata
* Current
di as err "Error: No data available"

* Proposed
di as err "{bf:wbopendata error 601}: Indicator not found"
di as err "  Searched for: `indicator'"
di as err "  Try: wbopendata, search(`indicator')"
di as err "  See: {stata help wbopendata_indicators}"
```

---

## Phase 6: Documentation Improvements (LOW Priority)

### 6.1 Interactive Help

Update `wbopendata.sthlp` with clickable examples:

```smcl
{title:Examples - Interactive Discovery}

{pstd}Find education indicators:{p_end}
{phang2}{stata `"wbopendata, search("education")"'}{p_end}

{pstd}Get indicator details:{p_end}
{phang2}{stata `"wbopendata, info("SE.ADT.LITR.ZS")"'}{p_end}
```

### 6.2 Markdown Documentation

Add/update:
- `doc/DISCOVERY.md` - How to find indicators
- `doc/FORMATS.md` - Output format guide
- `doc/MIGRATION.md` - Upgrade guide from v16 to v17+

---

## Implementation Roadmap

### Sprint 1 (Weeks 1-2): Foundation
- [ ] Add `yaml.ado` dependency or bundle
- [ ] Create `_wbopendata_search_indicators.ado`
- [ ] Add `search()` option to main command
- [ ] Basic tests for search functionality

### Sprint 2 (Weeks 3-4): Metadata System
- [ ] Create `wbopendata_sync.ado`
- [ ] Define YAML file formats
- [ ] Implement API-to-YAML sync
- [ ] Create `_wbopendata_indicator_info.ado`

### Sprint 3 (Weeks 5-6): Output Enhancements
- [ ] Add `wide_indicators` option
- [ ] Add `addmeta()` option
- [ ] Update help file with new options
- [ ] Comprehensive test suite

### Sprint 4 (Weeks 7-8): CI/CD & Polish
- [ ] Set up GitHub Actions
- [ ] Performance optimization
- [ ] Documentation updates
- [ ] SSC package update preparation

---

## Backward Compatibility

All changes MUST maintain backward compatibility:

| Feature | Backward Compatible? | Notes |
|---------|---------------------|-------|
| `search()` | ✅ Yes | New option, doesn't affect existing |
| `info()` | ✅ Yes | New option |
| `sync` | ✅ Yes | New subcommand |
| `wide_indicators` | ✅ Yes | New option |
| `addmeta()` | ✅ Yes | New option |
| YAML metadata | ✅ Yes | Supplements existing sthlp files |
| Frame support | ✅ Yes | Falls back to preserve/restore |

---

## File Changes Summary

### New Files
```
src/w/
├── wbopendata_sync.ado          # Metadata sync command
├── wbopendata_sync.sthlp        # Sync help file

src/_/
├── _wbopendata_search_indicators.ado
├── _wbopendata_indicator_info.ado
├── _wbopendata_list_sources.ado
├── _wbopendata_list_topics.ado
├── _wbopendata_parse_yaml.ado
├── _wbopendata_sources.yaml
├── _wbopendata_topics.yaml
├── _wbopendata_indicators.yaml
├── _wbopendata_countries.yaml
└── _wbopendata_sync_history.yaml

qa/
├── tests/
│   ├── test_basic.do
│   ├── test_discovery.do
│   ├── test_sync.do
│   └── test_outputs.do
├── run_tests.do
└── README.md

.github/
└── workflows/
    └── stata-tests.yaml
```

### Modified Files
```
src/w/wbopendata.ado            # Add discovery subcommands
src/w/wbopendata.sthlp          # Update help with new features
README.md                       # Update documentation
wbopendata.pkg                  # Update package manifest
```

---

## Success Metrics

1. **User Experience**: Users can find indicators in <5 seconds via search
2. **Reliability**: Automated tests pass on every commit
3. **Maintainability**: New indicator additions via YAML edit, not code changes
4. **Performance**: Search across 17,000+ indicators < 2 seconds
5. **Compatibility**: All existing user scripts continue to work

---

## References

- [unicefData Stata Implementation](C:/GitHub/others/unicefData/stata)
- [unicefData Improvement Plan](C:/GitHub/others/unicefData/stata/IMPROVEMENT_PLAN.md)
- [unicefData TODO](C:/GitHub/others/unicefData/stata/TODO.md)
- [World Bank API Documentation](https://datahelpdesk.worldbank.org/knowledgebase/topics/125589-developer-information)
- [yaml.ado (SSC)](https://ideas.repec.org/c/boc/bocode/s459111.html)
