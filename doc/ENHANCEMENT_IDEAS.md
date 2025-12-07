# wbopendata Enhancement Ideas and Roadmap

Based on analysis of Stata packages in `C:\ado\plus`, this document outlines potential improvements and new features for `wbopendata`.

## Executive Summary

After reviewing 50+ installed Stata packages including `datalibweb`, `github`, `spmap`, `estout`, `markdoc`, `ftools`, `alorenz`, `adecomp`, and others, several patterns and features emerge that could enhance `wbopendata`.

---

## 1. Architecture Improvements

### 1.1 Version Management System (from `datalibweb`)

**Current State**: Single version with no backward compatibility layer.

**Proposed Enhancement**:
```stata
* Allow version selection like datalibweb
wbopendata, version(2) indicator(SP.POP.TOTL)

* Global version setting
global WBOPENDATA_VERSION 2
```

**Benefits**:
- Backward compatibility during API changes
- Easier testing of new features
- User can pin to known-working version

### 1.2 Modular Helper System (from `spmap`, `ftools`)

**Current State**: 16 helper files in `src/_/` directory.

**Proposed Enhancement**:
- Create clear helper categories:
  - `_wbod_api_*.ado` - API communication
  - `_wbod_parse_*.ado` - Response parsing  
  - `_wbod_meta_*.ado` - Metadata handling
  - `_wbod_util_*.ado` - Utilities

### 1.3 Mata Integration (from `ftools`, `moremata`)

**Proposed Enhancement**:
- Move performance-critical parsing to Mata
- Create `wbopendata.mata` library for:
  - JSON/XML parsing
  - Large dataset reshaping
  - Indicator code validation

---

## 2. User Experience Improvements

### 2.1 Interactive Dialog Improvements (from `datazoom_*`)

**Current State**: Basic dialog (`wbopendata.dlg`).

**Proposed Enhancement**:
- Multi-language dialogs (English, Spanish, French) like `datazoom_*_en.dlg`
- Topic browser with descriptions
- Indicator search within dialog
- Country selection with checkboxes

### 2.2 Progress Indicators (from `github`, `datalibweb`)

**Proposed Enhancement**:
```stata
* Show download progress for large requests
wbopendata, indicator(SP.POP.TOTL) progress
```

Output:
```
Downloading indicator SP.POP.TOTL...
  Countries: [##########----------] 50% (128/256)
  Time elapsed: 12s
```

### 2.3 Caching System (from `datalibweb`, `github`)

**Proposed Enhancement**:
```stata
* Cache data locally for faster repeated access
wbopendata, indicator(SP.POP.TOTL) cache
wbopendata, indicator(SP.POP.TOTL) cache(refresh)
wbopendata, clearcache

* Set cache directory
global WBOPENDATA_CACHE "D:/data/wbcache"
```

**Implementation**:
- Store downloaded data in `c(sysdir_plus)wbopendata_cache/`
- Track freshness with timestamps
- Auto-refresh after configurable period (default: 7 days)

---

## 3. New Features

### 3.1 Search Functionality (from `github search`)

**Proposed Enhancement**:
```stata
* Search indicators by keyword
wbopendata search "education enrollment"
wbopendata search "GDP", source(2)

* Results displayed as clickable links
```

### 3.2 Favorites/Bookmarks System

**Proposed Enhancement**:
```stata
* Save frequently used indicators
wbopendata favorite add SP.POP.TOTL "Total Population"
wbopendata favorite add NY.GDP.PCAP.CD "GDP per capita"
wbopendata favorite list
wbopendata, favorite(1) clear  // Use by index
```

### 3.3 Batch Download Mode

**Proposed Enhancement**:
```stata
* Download from indicator list file
wbopendata batch using "my_indicators.txt", clear

* Where my_indicators.txt contains:
* SP.POP.TOTL
* NY.GDP.PCAP.CD
* SE.PRM.ENRR
```

### 3.4 Data Comparison Tool (from `alorenz compare`)

**Proposed Enhancement**:
```stata
* Compare indicator values across time periods
wbopendata compare, indicator(SP.POP.TOTL) ///
    country(USA;CHN;BRA) ///
    periods(2000 2010 2020)
```

### 3.5 Automatic Dependency Installation (from `alorenz`, `github`)

**Proposed Enhancement**:
```stata
* Auto-check and install dependencies at runtime
* (Already partially implemented in alorenz)

program _wbod_checkdeps
    local deps tknz linewrap
    foreach dep of local deps {
        cap which `dep'
        if _rc == 111 {
            di as txt "Installing required package: `dep'"
            ssc install `dep'
        }
    }
end
```

---

## 4. Documentation Improvements

### 4.1 Literate Documentation (from `markdoc`)

**Proposed Enhancement**:
- Embed examples directly in source code
- Auto-generate help files from source
- Create package vignettes

Example in source:
```stata
/***
wbopendata
==========

__wbopendata__ downloads World Bank data.

Example
-------
    . wbopendata, indicator(SP.POP.TOTL) clear
***/
```

### 4.2 Comprehensive Help System (from `estout`, `spmap`)

**Proposed Enhancement**:
- Section-based help with `viewerjumpto`
- More examples with expected output
- Troubleshooting section
- FAQ section

### 4.3 Online Documentation Portal

**Proposed Enhancement**:
- GitHub Pages site with:
  - Searchable indicator database
  - Interactive examples
  - Video tutorials
  - Change log

---

## 5. API & Integration

### 5.1 Multiple API Support

**Proposed Enhancement**:
```stata
* Support additional data sources
wbopendata, indicator(SP.POP.TOTL) api(v2)     // Current
wbopendata, indicator(SP.POP.TOTL) api(sdmx)   // SDMX format
wbopendata, indicator(SP.POP.TOTL) api(bulk)   // Bulk download
```

### 5.2 API Key/Token Support (from `datalibweb`)

**Proposed Enhancement**:
```stata
* For users with API keys (future World Bank feature)
wbopendata, indicator(SP.POP.TOTL) token(abc123)
global WBOPENDATA_TOKEN "abc123"
```

### 5.3 Proxy Support

**Proposed Enhancement**:
```stata
* For users behind corporate firewalls
wbopendata, indicator(SP.POP.TOTL) ///
    proxy("http://proxy.company.com:8080")
```

---

## 6. Output Enhancements

### 6.1 Multiple Output Formats (from `estout`, `markdoc`)

**Proposed Enhancement**:
```stata
* Export to various formats
wbopendata, indicator(SP.POP.TOTL) ///
    export(excel, "population.xlsx")
    
wbopendata, indicator(SP.POP.TOTL) ///
    export(csv, "population.csv")
    
wbopendata, indicator(SP.POP.TOTL) ///
    export(json, "population.json")
```

### 6.2 Automatic Variable Labels

**Proposed Enhancement**:
- Apply indicator descriptions as variable labels
- Apply country names as value labels
- Apply year labels

```stata
wbopendata, indicator(SP.POP.TOTL) labels
```

### 6.3 Metadata Dataset Creation

**Proposed Enhancement**:
```stata
* Create metadata companion dataset
wbopendata, indicator(SP.POP.TOTL) savemeta("pop_meta.dta")
```

---

## 7. Quality & Testing

### 7.1 Built-in Diagnostics (from `ftools check`)

**Proposed Enhancement**:
```stata
* Check installation and dependencies
wbopendata, check

Output:
  wbopendata version: 17.0 ✓
  API connection: OK ✓
  Dependencies:
    - tknz: installed ✓
    - linewrap: installed ✓
  Cache status: 15 indicators cached
  Last update: 2025-01-24
```

### 7.2 Validation Mode

**Proposed Enhancement**:
```stata
* Validate indicator codes before downloading
wbopendata validate SP.POP.TOTL NY.GDP.PCAP.CD INVALID.CODE

Output:
  SP.POP.TOTL: Valid (WDI)
  NY.GDP.PCAP.CD: Valid (WDI)
  INVALID.CODE: NOT FOUND
```

### 7.3 Unit Test Framework

**Proposed Enhancement**:
- Create `wbopendata_test.ado` for automated testing
- Integration with CI/CD (GitHub Actions)
- Test coverage for all options

---

## 8. Priority Roadmap

### Phase 1 (v17.1) - Quick Wins
- [ ] Progress indicators
- [ ] Better error messages
- [ ] `check` subcommand
- [ ] Auto-dependency installation

### Phase 2 (v18.0) - Core Enhancements
- [ ] Caching system
- [ ] Search functionality
- [ ] Multiple output formats
- [ ] Improved dialogs

### Phase 3 (v19.0) - Advanced Features
- [ ] Mata integration for performance
- [ ] Version management system
- [ ] Batch download mode
- [ ] API token support

### Phase 4 (v20.0) - Ecosystem
- [ ] Online documentation portal
- [ ] Integration with other WB tools
- [ ] Community indicator lists
- [ ] Plugin architecture

---

## 9. Competitive Analysis

| Feature | wbopendata | datalibweb | WDI (R) | wbstats (R) |
|---------|------------|------------|---------|-------------|
| Caching | ❌ | ✅ | ✅ | ✅ |
| Search | ❌ | ❌ | ✅ | ✅ |
| Progress | ❌ | ❌ | ✅ | ❌ |
| Multiple formats | ❌ | ❌ | ✅ | ✅ |
| Auto-labels | Partial | ❌ | ✅ | ✅ |
| Version mgmt | ❌ | ✅ | N/A | N/A |
| Offline mode | ❌ | ❌ | ❌ | ❌ |

---

## 10. Implementation Notes

### Breaking Changes to Avoid
- Keep `indicator()` syntax unchanged
- Maintain backward compatibility with existing scripts
- Don't remove any current options

### Deprecation Strategy
- Mark old options as deprecated in help
- Show warning for 2 versions
- Remove in v20.0

### Testing Requirements
- All new features need unit tests
- Regression tests for existing functionality
- API mock for offline testing

---

*Document created: December 2025*  
*Based on analysis of 50+ Stata packages*
