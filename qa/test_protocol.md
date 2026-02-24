# wbopendata Test Protocol

[Back to README](../README.md) | [FAQ](../doc/FAQ.md) | [Examples](../doc/examples/) | [Testing Guide](TESTING_GUIDE.md)

---

## Overview

This document outlines the testing protocol for validating `wbopendata` functionality before releases. The automated test suite is in `run_tests.do`.

**Test Suite Version**: 3.1.0
**Compatible with**: wbopendata v18.3.2+
**Last Updated**: February 2026
**Total Tests**: 92 automated tests across 15 categories

> **See also:** [README](README.md) for quick start | [Testing Guide](TESTING_GUIDE.md) for best practices

---

## Methodological References

This test suite draws on two complementary testing traditions:

1. **Gould (2001)** -- W. Gould, "Statistical Software Certification," *The Stata Journal*, 1(1), pp. 29--50.
   Establishes the gold standard for certifying statistical software: test known results, test boundary/extreme inputs, test error conditions, and test deterministic (offline) reproducibility. Categories ERR, EXT, and DET directly implement Gould's phases.

2. **CRAN/PyPI release-gate testing** -- Deterministic, offline, platform-agnostic tests that certify intrinsic correctness independently of network conditions. Categories ENV and DET follow this paradigm.

3. **Operational validation (integration testing)** -- Live API tests that verify end-to-end functionality in real-world conditions. Categories DL, FMT, CTRY, LW, UPD, TOPIC, LANG, and advanced features follow this paradigm.

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for a detailed comparison of these two paradigms and why `wbopendata` uses both.

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

- Stata 14+ (preferably Stata 17+ for frame-cached search)
- Active internet connection (for categories DL, FMT, CTRY, REG, LW, UPD, TOPIC, LANG, advanced)
- Clean Stata session (no data in memory)
- wbopendata installed (via SSC or from dev repo)

**For repo-comparison tests (ENV-01 to ENV-04):**
- Access to the wbopendata-dev repository
- Either run from `qa/` folder (auto-detection) or set: `global wbopendata_repo "path/to/repo"`
- Or skip with: `do run_tests.do norepo`

**For deterministic/offline tests (DET-01 to DET-06):**
- CSV fixture files in `qa/fixtures/` (decompress via `do decompress_fixtures.do` if needed)

---

## Test Family Summary

| # | Family | Tests | Network | Paradigm | Purpose |
|---|--------|-------|---------|----------|---------|
| 0 | ENV | 5 | No | Certification | Installation integrity, file sync, package completeness |
| 1 | DL | 5 | Yes | Integration | Core data download from World Bank API |
| 2 | FMT | 3 | Yes | Integration | Output format options (long, year range, latest) |
| 3 | CTRY | 10 | Yes | Integration | Country metadata merge features (match, geo, regions) |
| 4 | REG | 4 | Yes | Regression | Prevent recurrence of closed GitHub issues |
| 5 | LW | 4 | Yes | Integration | Graph metadata (linewrap, maxlength) -- v17.6+ |
| 6 | UPD | 6 | Yes | Integration | Maintenance commands (update, describe, sync) |
| 7 | TOPIC/LANG | 2 | Yes | Integration | Topics API path and language option |
| 8 | Advanced | 6 | Yes | Integration | Projection, nobasic, describe-only, nometadata, adminregion, date |
| 9 | CACHE/SYNC | 13 | Mixed | Integration | Cache lifecycle and metadata sync operations |
| 10 | DISC | 10 | No | Certification | Offline discovery commands (search, info, sources, topics) |
| 11 | CHAR | 6 | Yes | Integration | Variable-level char metadata -- v18.1 |
| 12 | ERR | 8 | Mixed | Gould (2001) | Error conditions: invalid inputs must fail gracefully |
| 13 | EXT | 4 | Yes | Gould (2001) | Extreme/boundary cases: stress inputs |
| 14 | DET | 6 | No | Gould (2001) | Deterministic offline tests with CSV fixtures |
| | **Total** | **92** | | | |

---

## Category 0: Environment Checks (5 tests)

**Purpose:** Certify that the installed package matches the repository source and that metadata files are accessible. These tests run without network access and verify installation integrity.

**Logic:** Compare installed .ado files against the repository source tree. Verify that the package manifest (`wbopendata.pkg`) lists all files and that all listed files exist. Confirm YAML metadata files are readable.

| Test ID | Description | Validation Logic | Expected Result |
|---------|-------------|------------------|-----------------|
| ENV-01 | Version matches repo | Compare installed `wbopendata` version string against version in `src/w/wbopendata.ado` header | Versions are identical |
| ENV-02 | Ado files sync status | Diff each installed .ado against its source in `src/` | All source files in sync |
| ENV-03 | Package manifest completeness | Parse `wbopendata.pkg` file list; check each `f` and `F` entry exists in `src/` | All pkg entries have corresponding files |
| ENV-04 | All pkg files exist in repo | Reverse check: every file listed in .pkg physically exists on disk | No missing files |
| ENV-05 | YAML files present and accessible | Call `_wbopendata_get_yaml_path` for parameters and indicators; verify `r()` returns valid paths | Both YAML metadata files found and readable |

**Requires:** Repository path (auto-detected from `qa/` folder or set via `global wbopendata_repo`). ENV-01 to ENV-04 are skipped if repo path is unavailable (use `norepo`).

---

## Category 1: Basic Downloads (5 tests)

**Purpose:** Validate the core data download functionality -- the primary use case of `wbopendata`. Each test downloads live data from the World Bank API and verifies the result has expected structure and row counts.

**Logic:** Issue `wbopendata` commands with different indicator/country/format combinations. Verify data loads into memory with expected variables and observation counts.

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| DL-01 | Single indicator download | `wbopendata, indicator(SP.POP.TOTL) clear` | Data loads, >200 obs |
| DL-02 | Single country download | `wbopendata, indicator(SP.POP.TOTL) country(USA) clear` | 1 country, >50 years |
| DL-03 | Multiple countries download | `wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear` | 3 countries present |
| DL-04 | Multiple indicators download | `wbopendata, indicator(SP.POP.TOTL;NY.GDP.MKTP.CD) clear long` | Both indicator variables exist |
| DL-05 | Poverty and GDP per capita | `wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long` | Both variables exist |

**Requires:** Active internet connection to World Bank API.

---

## Category 2: Format Options (3 tests)

**Purpose:** Verify that output format options (`long`, `year()`, `latest`) correctly reshape and filter the downloaded data.

**Logic:** Download data with format options applied, then assert the resulting dataset structure (year variable existence, row counts, year ranges) matches expectations.

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| FMT-01 | Long format | `wbopendata, indicator(SP.POP.TOTL) country(USA) clear long` | `year` variable exists, data in long layout |
| FMT-02 | Year range filter | `wbopendata, indicator(SP.POP.TOTL) country(USA) year(2010:2020) clear long` | All years in 2010--2020 range |
| FMT-03 | Latest option | `wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear long latest` | Exactly 1 obs per country |

---

## Category 3: Country Metadata (10 tests)

**Purpose:** Validate the `match()` option and its sub-options that merge country-level metadata (region, income level, lending type, geographic coordinates) into downloaded data.

**Logic:** Download indicator data, then apply `match()` with various sub-options. Verify that the expected metadata variables are created and populated.

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| CTRY-01 | Match basic | `countryname` variable added via `match(countrycode)` |
| CTRY-02 | Match with full option | `longitude`, `latitude`, `capital` added via `match(countrycode) full` |
| CTRY-03 | Full metadata with indicator | All geographic variables exist alongside indicator data |
| CTRY-04 | ISO 2-digit codes option | `region_iso2` variable created via `iso` sub-option |
| CTRY-05 | Geographic GEO group option | `capital`, `latitude`, `longitude` added via `geo` |
| CTRY-06 | Capital geographic option | `capital` variable exists via `capital` sub-option |
| CTRY-07 | Latitude and longitude | Both coordinate variables exist via `latitude longitude` |
| CTRY-08 | Regions group option | `regionname` variable exists via `regions` |
| CTRY-09 | Income and Lending groups | `incomelevel`, `lendingtype` exist via `income lending` |
| CTRY-10 | Geographic options with indicator | All geographic vars present with data download |

---

## Category 4: Regression Tests (4 tests)

**Purpose:** Prevent previously fixed bugs from reoccurring. Each test corresponds to a closed GitHub issue and reproduces the original failing scenario.

**Logic:** Execute the exact command that triggered the original bug. Verify that the command now succeeds (or fails with the correct error code, depending on the issue).

| Test ID | Issue | Description | Expected Result |
|---------|-------|-------------|-----------------|
| REG-33 | [#33](https://github.com/jpazvd/wbopendata/issues/33) | `latest` with long indicator names truncated variable names | No error; variable created |
| REG-45 | [#45](https://github.com/jpazvd/wbopendata/issues/45) | URL in metadata caused parsing error (`_website.ado` SMCL injection) | No parsing error |
| REG-46 | [#46](https://github.com/jpazvd/wbopendata/issues/46) | `update` without varlist caused error | No error |
| REG-51 | [#51](https://github.com/jpazvd/wbopendata/issues/51) | `match()` + `indicator()` + `clear` were incorrectly allowed together | Returns rc 198 (expected) |

---

## Category 5: Graph Metadata -- v17.6 Features (4 tests)

**Purpose:** Validate the `linewrap()` and related options that format metadata text for use in Stata graph titles, subtitles, and notes.

**Logic:** Download indicator data with `linewrap()` option and verify that `r()` return macros contain properly formatted stacked text.

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| LW-01 | Linewrap option basic | `r(name1_stack)` populated with wrapped indicator name |
| LW-02 | Linewrap with maxlength | Both `r(name1_stack)` and `r(description1_stack)` populated |
| LW-03 | Latest returns scalars | `r(latest)`, `r(latest_ncountries)`, `r(latest_avgyear)` exist |
| LW-04 | Linewrap all fields | `r(name1_stack)` populated when all fields specified |

---

## Category 6: Maintenance Commands (6 tests)

**Purpose:** Validate update, query, describe, and sync commands that manage the installed metadata and package state.

**Logic:** Execute each maintenance command and verify it completes without error. Some commands produce return values that are checked.

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| UPD-01 | Update query command | `wbopendata, update query` | Shows current vintage, no error |
| UPD-02 | Describe indicators | `wbopendata, indicator(SP.POP.TOTL) describe clear` | Metadata returned in `r()` |
| UPD-03 | Update basic | `wbopendata, update` | No error |
| UPD-04 | Update check detail | `wbopendata, update check detail` | No error |
| UPD-05 | Update all | `wbopendata, update all` | No error |
| UPD-06 | Sync replace force | `wbopendata, sync replace force` | Forces re-download, no error |

**Note:** UPD-01 through UPD-05 test legacy maintenance commands. UPD-06 tests the v18.x sync system. Legacy commands display deprecation warnings in v18.1+.

---

## Category 7: Topics and Language (2 tests)

**Purpose:** Validate the topics download path (which uses a different API endpoint than indicator downloads) and the language option.

**Logic:** Download data via topic selection and verify structure. Download with `language(es)` and verify Spanish-language labels are returned.

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| TOPIC-01 | Topics download | `wbopendata, topics(1) clear long` | Data loads, >100 obs, `indicatorcode` or `indicator` variable exists |
| LANG-01 | Language option (Spanish) | `wbopendata, indicator(SP.POP.TOTL) country(USA) language(es) clear long` | `r(varlabel1)` contains Spanish text |

---

## Category 8: Advanced Features (6 tests)

**Purpose:** Validate specialized options that extend the core download functionality.

**Logic:** Each test exercises a specific advanced option and verifies its effect on the output.

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| PROJ-01 | Projection data download (`source(40)`) | `sp_pop_totl` variable exists with projection data |
| FMT-04 | `nobasic` option suppresses default metadata | Default vars (`region`, `incomelevel`, etc.) are NOT present |
| DESC-01 | `describe` option (metadata only, no data download) | Metadata returned in `r(indicator1)` and `r(name1)`, no data in memory |
| META-01 | `nometadata` suppresses metadata returns | No `_stack` return macros populated |
| CTRY-11 | `adminr` option adds admin region variables | `adminregion`, `adminregionname` variables exist |
| DATE-01 | `date()` option for quarterly/monthly data | Data within specified date range |

---

## Category 9: Cache and Sync System (13 tests)

**Purpose:** Validate the v18.x local metadata caching and sync system that stores YAML files locally for offline discovery.

**Logic:** Tests follow the cache lifecycle: initialize cache directory, store files, verify persistence, clear cache, then test sync operations that download metadata from GitHub.

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| CACHE-01 | Cache directory initialization | Cache dir created under ado/plus path |
| CACHE-02 | Get YAML path (cache vs package) | `_wbopendata_get_yaml_path` returns appropriate path with source indicator |
| CACHE-03 | Cache info display | `wbopendata, cache(info)` shows cache status without error |
| CACHE-04 | Clear cache | `wbopendata, cache(clear)` empties cache directory |
| CACHE-05 | Cache persistence | Cached files persist across Stata commands |
| CACHE-06 | Version file tracking | Version file created/updated after sync |
| CACHE-07 | Timestamp tracking | Timestamps recorded in cache metadata |
| CACHE-08 | Search with cached YAML | Search commands use cached data when available |
| SYNC-01 | Check for updates | `wbopendata, checkupdate` shows update availability |
| SYNC-02 | Sync replace (download) | `wbopendata, sync replace` downloads latest metadata |
| SYNC-03 | Sync replace force (re-download) | `wbopendata, sync replace force` forces re-download |
| SYNC-04 | Sync when already up-to-date | Reports no updates needed |
| SYNC-05 | Cross-validation: sync preview vs. discovery counts | Verify that sync preview counts (ind_count, src_count, top_count) match discovery command return values (n_results, n_sources, n_topics) |

**Note on SYNC-05 (v18.3.0+):** This test verifies internal consistency between the metadata sync preview and discovery commands. It ensures that the indicator/source/topic counts reported by `wbopendata, sync` match what's returned by `wbopendata, search/sources/alltopics`. This is a cross-validation test, not strictly a "cache" test.

---

## Category 10: Discovery Commands (7 tests)

**Purpose:** Validate offline catalog browsing commands that search and display indicator metadata from local YAML files.

**Logic:** Execute each discovery command and verify `r()` return values are populated. These tests do NOT require network access -- they read from local YAML files.

| Test ID | Description | Expected Result |
|---------|-------------|-----------------|
| DISC-01 | Search basic (keyword) | `wbopendata, search(population)` returns matching indicators; `r(n_results)` > 0 |
| DISC-02 | Search with filters (source, topic, field) | Filtered results returned with reduced count |
| DISC-03 | Search patterns (wildcard, AND, exact) | Pattern matching works; `exact` restricts results |
| DISC-04 | Sources listing | `wbopendata, sources` lists data sources without error |
| DISC-05 | Topics listing | `wbopendata, topics` lists topic categories without error |
| DISC-06 | Indicator info lookup | `wbopendata, info(SP.POP.TOTL)` returns full metadata |
| DISC-07 | Search router (cache method by Stata version) | Frame-cached search (Stata 16+) or per-call parsing (older) |

---

## Category 11: Characteristic Metadata -- v18.1 Features (6 tests)

**Purpose:** Validate that Stata `char` metadata is automatically attached to datasets and variables after download. This enables programmatic access to provenance information (which indicator, when downloaded, by whom) without parsing variable labels.

**Logic:** Download data and inspect `char` values at both `_dta` (dataset) and variable levels. Verify `nochar` suppresses all chars, and chars persist across save/use cycles.

**Background:** Stata `char` (characteristics) are string metadata attached to variables or the dataset (`_dta`). Unlike labels (limited to 80 chars), chars have no length limit and are preserved in `.dta` files. This feature was added in v18.1 for programmatic provenance tracking.

| Test ID | Description | Validation Logic | Expected Result |
|---------|-------------|------------------|-----------------|
| CHAR-01 | Dataset-level `_dta` chars set by default | Download with defaults; check `char _dta[wbopendata_version]`, `char _dta[wbopendata_timestamp]`, `char _dta[wbopendata_indicator]` | All five `_dta` chars populated |
| CHAR-02 | Variable-level indicator char | Download SP.POP.TOTL; check `char sp_pop_totl[indicator]` | Equals `"SP.POP.TOTL"` |
| CHAR-03 | Variable-level metadata chars (with metadata) | Download WITH metadata; check `char sp_pop_totl[source]`, `char sp_pop_totl[description]`, `char sp_pop_totl[topic]` | At minimum `indicator` char is set |
| CHAR-04 | `nochar` suppresses all chars | Download with `nochar`; check `char _dta[wbopendata_version]` and `char sp_pop_totl[indicator]` | All chars are empty strings |
| CHAR-05 | Multi-indicator chars per variable | Download SP.POP.TOTL + NY.GDP.MKTP.CD; check each variable's `[indicator]` char | Each variable has its own indicator code |
| CHAR-06 | Chars persist across save/use | Download, save to tempfile, clear, use; verify chars survive | All chars intact after round-trip |

---

## Category 12: Error Conditions -- Gould (2001) (8 tests)

**Purpose:** Verify that invalid inputs produce graceful, informative errors rather than crashes or silent failures. This implements Gould's (2001) principle: "Test with known-to-be-wrong data and verify the appropriate error messages are produced."

**Logic:** Each test supplies deliberately invalid input and verifies that `wbopendata` returns the correct Stata return code (typically rc 198 for syntax errors) or gracefully returns zero observations. Tests use `rcof` where exact return codes are expected.

**Method:** `rcof` (Gould 2001) -- a Stata certification command that asserts a specific return code from a command. If the command returns a different code, `rcof` itself fails, causing the test to fail.

| Test ID | Description | Input | Expected rc | Method |
|---------|-------------|-------|-------------|--------|
| ERR-01 | No indicator or action specified | `wbopendata, clear` | 198 | `rcof` |
| ERR-02 | Invalid indicator code | `indicator(XXXXX.INVALID.CODE)` | != 0 or _N == 0 | Graceful degradation |
| ERR-03 | `match()` + `indicator()` conflict | `indicator(SP.POP.TOTL) match(countrycode) clear` | 198 | `rcof` |
| ERR-04 | Invalid country code | `country(ZZZZZ)` | != 0 or _N == 0 | Graceful degradation |
| ERR-05 | Invalid source ID | `source(9999)` | != 0 or _N == 0 | Graceful degradation |
| ERR-06 | Empty API response (deprecated indicator) | Offline fixture with headers-only CSV | != 0 or _N == 0 | Offline fixture |
| ERR-07 | Inverted year range | `year(2020:2010)` | No crash | Graceful (API may accept either order) |
| ERR-08 | Empty indicator string | `indicator()` | 198 | `rcof` |

**Note:** ERR-06 uses an offline fixture (`DEPRECATED_INDICATOR_all.csv`) to avoid dependency on the World Bank's deprecation status, which can change without notice (e.g., SP.ADO.TFRT was reinstated).

---

## Category 13: Extreme Cases -- Gould (2001) (4 tests)

**Purpose:** Put considerable stress on the code by testing boundary conditions: minimal queries, maximal result sets, long indicator names, and special characters in topic names. Per Gould (2001): "Extreme cases put considerable stress on your code."

**Logic:** Each test uses a deliberately extreme input and verifies the command handles it correctly without crashing.

| Test ID | Description | Stress Condition | Expected Result |
|---------|-------------|------------------|-----------------|
| EXT-01 | Minimal query (1 country, 1 year) | `country(USA) year(2020:2020)` -- single observation expected | Exactly 1 obs; value pinned: USA pop 2020 in 300M--400M range |
| EXT-02 | All countries, single year | `year(2020:2020)` with no country filter -- 296 countries/regions | >200 obs returned |
| EXT-03 | Long indicator name | `indicator(DT.DOD.DECT.CD)` with `latest` -- variable name may be truncated to 20 chars | Download succeeds; label preserved |
| EXT-04 | Topics with parentheses in names | `_wbopendata_topics` -- topic names like "Environment, Social and Governance (ESG)" contain `()` | Topics listing succeeds; no `SocialandGovernance()` macro error |

**Note:** EXT-01 includes a **value pin**: it asserts that USA population in 2020 falls within 300M--400M. This catches both data corruption and gross API format changes. EXT-04 tests the `gettoken` loop fix for compound quoting -- see `_wbopendata_topics.ado`.

---

## Category 14: Deterministic/Offline Tests -- Gould (2001), Phase 6 (6 tests)

**Purpose:** Provide fully reproducible tests that do not depend on network access or live API state. These tests use pre-captured CSV fixture files that simulate World Bank API responses, enabling:
- Deterministic results (same output every run)
- Offline execution (no network required)
- Value pinning (assert exact data values)
- CI/CD compatibility (no external dependencies)

This implements Gould's (2001) Phase 6 principle of using known test datasets with known correct answers.

**Logic:** The `offline(path)` option in `_query.ado` redirects data loading from the API to local CSV files. Fixture naming convention: `{INDICATOR_dots_to_underscores}_{country}.csv` (e.g., `SP_POP_TOTL_USA.csv`).

**Fixture files** (in `qa/fixtures/`):

| Fixture | Contents |
|---------|----------|
| `SP_POP_TOTL_USA.csv` | Total population, USA, all years |
| `SP_POP_TOTL_all.csv` | Total population, all countries, all years |
| `NY_GDP_MKTP_CD_USA.csv` | GDP (current US$), USA, all years |
| `country_USA.csv` | Country-level query for USA |
| `DEPRECATED_INDICATOR_all.csv` | Headers-only CSV (0 data rows) for ERR-06 |

| Test ID | Description | Validation Logic | Expected Result |
|---------|-------------|------------------|-----------------|
| DET-01 | Single indicator, single country | Load `SP_POP_TOTL_USA.csv` via `offline()`; assert >50 obs, `countrycode` and `year` vars exist | Data structure matches live API format |
| DET-02 | Single indicator, all countries | Load `SP_POP_TOTL_all.csv`; assert >10,000 obs, >200 distinct countries | Large dataset loads correctly |
| DET-03 | Value pinning (USA pop 2020) | Filter to USA+2020; assert exactly 1 obs; assert value in 300M--400M range | Exact data value verified |
| DET-04 | Different indicator (GDP) | Load `NY_GDP_MKTP_CD_USA.csv`; assert >0 obs, `countrycode` exists | Multiple indicators work offline |
| DET-05 | Country-only query | Load `country_USA.csv` via `country(USA)` + `offline()`; assert >0 obs | Non-indicator queries work offline |
| DET-06 | Missing fixture error handling | Request non-existent indicator with `offline()`; fixture file doesn't exist | Returns rc 601 ("file not found") |

**Requires:** Fixture CSV files in `qa/fixtures/`. If fixtures are missing, tests are skipped with an informational message (not counted as failures).

---

## Performance Benchmarks

| Test | Command | Target Time |
|------|---------|-------------|
| Single indicator, all countries | `wbopendata, indicator(SP.POP.TOTL) clear` | < 30 seconds |
| Topic download | `wbopendata, topics(1) clear` | < 60 seconds |
| Multiple indicators (3) | `wbopendata, indicator(A;B;C) clear` | < 60 seconds |
| YAML first parse (indicators) | `wbopendata, search(population)` (cold) | < 25 seconds |
| YAML cached search | `wbopendata, search(population)` (warm) | < 0.5 seconds |
| Full test suite (92 tests) | `do run_tests.do` | < 20 minutes |

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
- [ ] CACHE/SYNC tests pass
- [ ] DISC tests pass (discovery commands)
- [ ] CHAR tests pass (characteristic metadata)
- [ ] ERR tests pass (error conditions)
- [ ] EXT tests pass (extreme cases)
- [ ] DET tests pass (deterministic/offline)
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

**Last Successful Full Run:** 10 Feb 2026
**Version:** 18.1.0
**Result:** 89 run, 89 passed, 0 failed
**Duration:** 5m 4s

---

## References

- Gould, W. (2001). Statistical Software Certification. *The Stata Journal*, 1(1), 29--50.
- Stata Programming Reference Manual: `help cscript`, `help rcof`, `help assert`, `help capture`
- [TESTING_GUIDE.md](TESTING_GUIDE.md) -- Best practices for Stata testing and dual-paradigm philosophy

---

## Related Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Quick start guide for running tests |
| [TESTING_GUIDE.md](TESTING_GUIDE.md) | Best practices for Stata testing |
| [run_tests.do](run_tests.do) | Automated test script |
| [test_history.txt](test_history.txt) | Append-only history of all test runs |
