# wbopendata Test Protocol

[← Back to README](../README.md) | [FAQ](../doc/FAQ.md) | [Examples](../doc/examples/) | [Testing Guide](TESTING_GUIDE.md)

---

## Overview

This document outlines the testing protocol for validating `wbopendata` functionality before releases. The automated test suite is in `run_tests.do`.

**Test Suite Version**: 2.0.0  
**Compatible with**: wbopendata v17.7.1+  
**Last Updated**: January 2026  
**Total Tests**: 57 automated tests across 10 categories (53 core + 4 repo-comparison)

> **See also:** [README](README.md) for quick start | [Testing Guide](TESTING_GUIDE.md) for best practices

---

## Quick Start

```stata
* Run all tests (from qa/ folder - auto-detects repo path)
cd "C:/path/to/wbopendata-dev/qa"
do run_tests.do

* Run all tests but skip repo-comparison tests (ENV-01 to ENV-04)
do run_tests.do norepo

* Run a single test
do run_tests.do DL-01

* Run with verbose/trace mode
do run_tests.do DL-01 verbose

* List all available tests
do run_tests.do list

* Configure repo path manually (alternative to auto-detection)
global wbopendata_repo "D:/Projects/wbopendata-dev"
do run_tests.do
```

---

## Test Environment Requirements

- Stata 14+ (preferably Stata 17+)
- Active internet connection
- Clean Stata session (no data in memory)
- wbopendata installed (via SSC or from dev repo)

**For repo-comparison tests (ENV-01 to ENV-04):**
- Access to the wbopendata-dev repository
- Either run from `qa/` folder (auto-detection) or set: `global wbopendata_repo "path/to/repo"`
- Or skip with: `do run_tests.do norepo`

---

## Test Categories

### Category 0: Environment Checks (4 tests)

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| ENV-01 | wbopendata version matches repo | Installed version = repo version |
| ENV-02 | Ado files sync status | All source files in sync |
| ENV-03 | wbopendata.pkg matches src directories | All src files listed in pkg |
| ENV-04 | All pkg files exist in repo | No missing files |

### Category 1: Basic Downloads (5 tests)

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| DL-01 | Single indicator download | `wbopendata, indicator(SP.POP.TOTL) clear` | Data loads, >200 obs |
| DL-02 | Single country download | `wbopendata, indicator(SP.POP.TOTL) country(USA) clear` | 1 country, >50 years |
| DL-03 | Multiple countries download | `wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear` | 3 countries |
| DL-04 | Multiple indicators download | `wbopendata, indicator(SP.POP.TOTL;NY.GDP.MKTP.CD) clear long` | Both indicator variables exist |
| DL-05 | Poverty and GDP per capita download | `wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long` | Both variables exist |

### Category 2: Format Options (3 tests)

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| FMT-01 | Long format | `wbopendata, indicator(SP.POP.TOTL) country(USA) clear long` | Year variable exists |
| FMT-02 | Year range filter | `wbopendata, indicator(SP.POP.TOTL) country(USA) year(2010:2020) clear long` | Years within range |
| FMT-03 | Latest option | `wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear long latest` | 1 obs per country |

### Category 3: Country Metadata (10 tests)

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| CTRY-01 | Match basic | `countryname` variable added |
| CTRY-02 | Match with full option | `longitude`, `latitude`, `capital` added |
| CTRY-03 | Full country metadata with indicator | All geographic variables exist |
| CTRY-04 | ISO 2-digit codes option | `region_iso2` variable exists |
| CTRY-05 | Geographic GEO group option | `capital`, `latitude`, `longitude` added |
| CTRY-06 | Capital geographic option | `capital` variable exists |
| CTRY-07 | Latitude and longitude options | Both coordinate variables exist |
| CTRY-08 | Regions group option | `regionname` variable exists |
| CTRY-09 | Income and Lending group options | `incomelevel`, `lendingtype` exist |
| CTRY-10 | Geographic options with indicator | All geographic vars with data download |

### Category 4: Regression Tests (4 tests)

| Test ID | Issue | Description | Expected Result |
|---------|-------|-------------|-----------------|
| REG-33 | #33 | Latest with long indicator names | No error |
| REG-45 | #45 | URL in metadata parsing | No parsing error |
| REG-46 | #46 | Update without varlist error | No error |
| REG-51 | #51 | Match+indicator incompatibility check | Returns error as expected |

### Category 5: Graph Metadata - v17.6 features (4 tests)

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| LW-01 | Linewrap option basic | `r(name1_stack)` populated |
| LW-02 | Linewrap with maxlength | Both name and description stacks populated |
| LW-03 | Latest returns scalars | `r(latest)`, `r(latest_ncountries)`, `r(latest_avgyear)` exist |
| LW-04 | Linewrap all fields | `r(name1_stack)` populated with all fields |

### Category 6: Maintenance Commands (6 tests)

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| UPD-01 | Update query command | `wbopendata, update query` | Shows current vintage |
| UPD-02 | Describe indicators | `wbopendata, indicator(SP.POP.TOTL) describe clear` | Metadata returned |
| UPD-03 | Update basic | `wbopendata, update` | No error |
| UPD-04 | Update check detail | `wbopendata, update check detail` | No error |
| UPD-05 | Update all | `wbopendata, update all` | No error |
| UPD-06 | Update all force | `wbopendata, update all force` | No error |

### Category 7: Topics & Language (2 tests)

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| TOPIC-01 | Topics download | `wbopendata, topics(1) clear long` | Data loads, >100 obs |
| LANG-01 | Language option Spanish | `wbopendata, indicator(SP.POP.TOTL) country(USA) language(es) clear long` | `r(varlabel1)` populated |

### Category 8: Advanced Features (6 tests)

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| PROJ-01 | Projection data download | `sp_pop_totl` variable exists |
| FMT-04 | nobasic option | Default vars (region, incomelevel, etc.) NOT present |
| DESC-01 | Describe option (metadata only) | Metadata returned, no data in memory |
| META-01 | nometadata suppresses metadata returns | No stack returns populated |
| CTRY-11 | Admin regions option | `adminregion`, `adminregionname` exist |
| DATE-01 | Date range option | Data within date range |

### Category 9: Cache & Sync System - v18.x features (13 tests)

**Note**: These tests are for features under development. Some may fail until implementation is complete.

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| CACHE-01 | Cache directory initialization | Cache dir created in ado/plus path |
| CACHE-02 | Get YAML path (cache vs package) | Returns appropriate path |
| CACHE-03 | Cache info display | Shows cache status |
| CACHE-04 | Clear cache | Cache directory emptied |
| CACHE-05 | Cache persistence | Cached files persist |
| CACHE-06 | Version file tracking | Version file created/updated |
| CACHE-07 | Timestamp tracking | Timestamps recorded |
| CACHE-08 | Search with cached YAML | Search uses cached data |
| SYNC-01 | Check for updates command | Shows update availability |
| SYNC-02 | Sync command (download) | Downloads latest metadata |
| SYNC-03 | Force sync command | Forces re-download |
| SYNC-04 | Sync when already up-to-date | Reports no updates needed |
| SYNC-05 | Discovery commands use cache | After sync, uses cache |

---

## Performance Benchmarks

| Test | Command | Target Time |
|------|---------|-------------|
| Single indicator, all countries | `wbopendata, indicator(SP.POP.TOTL) clear` | < 30 seconds |
| Topic download | `wbopendata, topics(1) clear` | < 60 seconds |
| Multiple indicators (3) | `wbopendata, indicator(A;B;C) clear` | < 60 seconds |
| Full test suite (57 tests) | `do run_tests.do` | < 6 minutes |

---

## Test Execution Checklist

- [ ] ENV tests pass (environment checks)
- [ ] DL tests pass (basic downloads)
- [ ] FMT tests pass (format options)
- [ ] CTRY tests pass (country metadata)
- [ ] REG tests pass (regression tests)
- [ ] LW tests pass (graph metadata)
- [ ] UPD tests pass (maintenance commands)
- [ ] TOPIC/LANG tests pass
- [ ] Advanced feature tests pass
- [ ] CACHE/SYNC tests pass (v18.x)
- [ ] Performance within targets

---

## Test Output Files

| File | Description |
|------|-------------|
| `run_tests.log` | Latest test run log (canonical copy) |
| `test_results_vX.Y.Z_DDMMMYYYY.log` | Dated log for specific version |
| `test_history.txt` | Append-only history of all test runs |

---

## Reporting

After running `do run_tests.do`, the script automatically:

1. Logs all output to `test_results_vX.Y.Z_DDMMMYYYY.log`
2. Copies to `run_tests.log` for quick access
3. Appends summary to `test_history.txt`
4. Displays pass/fail counts and failed test IDs

**Test history entry format:**
```
======================================================================
Test Run: DD Mon YYYY
Started:  HH:MM:SS
Ended:    HH:MM:SS
Duration: Xm Ys
Version:  X.Y.Z
Build:    DDMMMYYYY
Stata:    XX
Tests:    NN run, NN passed, NN failed
Result:   ALL TESTS PASSED / FAILED
Failed:   TEST-ID, TEST-ID, ...
Log:      test_results_vX.Y.Z_DDMMMYYYY.log
======================================================================
```

---

## Latest Test Results

**Last Successful Full Run:** 28 Jan 2026  
**Version:** 17.7.2  
**Result:** 57 run, 57 passed, 0 failed

---

## Related Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Quick start guide for running tests |
| [TESTING_GUIDE.md](TESTING_GUIDE.md) | Best practices for Stata testing |
| [run_tests.do](run_tests.do) | Automated test script |
| [test_history.txt](test_history.txt) | Append-only history of all test runs |