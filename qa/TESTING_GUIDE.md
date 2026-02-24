# wbopendata Testing Guide

**Test Suite Version:** 3.1.0
**Compatible with:** wbopendata v18.3.2+
**Last Updated:** February 2026

[← Back to README](../README.md) | [Test Protocol](test_protocol.md) | [QA README](README.md) | [FAQ](../doc/FAQ.md)

---

## Overview

This guide documents best practices for testing Stata ADO packages, specifically for `wbopendata`.

## Testing Philosophy: wbopendata vs. CRAN/PyPI

### The Two Paradigms

Software testing in the statistical ecosystem follows two fundamentally different paradigms, each serving distinct purposes and audiences:

| Aspect | CRAN / PyPI (Release Gates) | wbopendata (Hybrid Validation) |
|--------|----------------------------|-------------------------------------|
| **Primary Goal** | Certify software correctness | Validate real-world operations + certify logic |
| **Network Access** | Prohibited | Required for integration; optional for certification |
| **Environment** | Sandboxed, offline | Interactive, trusted |
| **Determinism** | Fully reproducible | Integration: depends on live data; DET: fully reproducible |
| **Failure Meaning** | Software bug | Could be API outage, data change, or bug |

### Software Certification (CRAN / PyPI Approach)

The automated test suites used for CRAN and PyPI releases are designed to **certify the intrinsic correctness and safety of the software**, independent of external conditions. These tests are:

- **Deterministic and fully reproducible** — same inputs always produce same outputs
- **Isolated from the network** — no external API calls or data downloads
- **Platform-agnostic** — must pass on Windows, macOS, and Linux
- **Focused on public-API behavior** — output structure and enforceable invariants

This design follows CRAN and PyPI expectations, where package checks must succeed in constrained, offline environments. Nondeterminism and hidden side effects are explicitly discouraged.

**Example (R/Python style):**
```r
# Uses pre-saved fixture data, not live API
test_that("parse_indicator returns expected structure", {
  mock_response <- readRDS("fixtures/api_response.rds")
  result <- parse_indicator(mock_response)
  expect_equal(names(result), c("countrycode", "year", "value"))
})
```

### Operational Validation (wbopendata Approach)

In contrast, `wbopendata` adopts **integration-style tests** that deliberately exercise:

- **Live APIs** — actual World Bank Data API calls
- **Real data downloads** — verifying data retrieval end-to-end
- **Environment configuration** — installed package versions, file sync status
- **Network behavior** — timeout handling, error recovery

These tests serve a different purpose: **diagnosing real-world behavior in trusted, interactive statistical environments** like Stata.

**Example (wbopendata style):**
```stata
* Actually downloads live data from World Bank API
wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nometadata
assert _N > 50  // Verify we got data
```

### Why wbopendata Uses Live Tests

The `wbopendata` testing approach is intentional and appropriate for its context:

1. **Stata's Ecosystem Context**
   - Stata does not have a CRAN-equivalent automated submission system
   - Packages are installed via `ssc install` or `net install` without automated pre-checks
   - Users run in trusted, interactive environments with network access

2. **The Core Function IS Network Dependent**
   - `wbopendata`'s primary purpose is fetching data from the World Bank API
   - Mocking the API would test the mock, not the actual functionality
   - Live tests catch real issues: API changes, endpoint deprecations, data format changes

3. **User Expectations**
   - Users expect the package to "just work" with current API state
   - A passing test suite means "this works right now with the live API"
   - This is more valuable than "this works with data from 2024"

4. **Failure Diagnosis**
   - When tests fail, the combination of live tests helps distinguish:
     - Package bugs (multiple unrelated tests fail)
     - API issues (download tests fail, metadata tests pass)
     - Network issues (all network tests fail, ENV tests pass)

### Bridging the Gap: Deterministic Offline Tests (v18.1)

Starting with v18.1.0, `wbopendata` adopted a **hybrid approach** by introducing deterministic offline tests (DET category) that follow Gould (2001) Phase 6 — "certification" testing:

- **`offline()` option**: Routes `_query.ado` to local CSV fixture files instead of the live API
- **Value pinning**: Known data values (e.g., USA population 2020 = 331,002,651) are asserted exactly
- **No network required**: DET tests pass in completely offline environments
- **Reproducible**: Same fixtures always produce the same results

This bridges the two paradigms: live integration tests validate real-world operations, while DET tests certify that parsing, reshaping, and metadata logic produce correct results independent of network state.

### Relationship Between the Two Approaches

These approaches are **complementary, not competing**:

| If you're building... | Use... |
|-----------------------|--------|
| R package for CRAN submission | Offline mocked tests only |
| Python package for PyPI | Offline mocked tests + optional live integration tests |
| Stata package like wbopendata | Live integration tests + offline certification (DET) |
| Multi-language ecosystem tool | Both: mocked for CI/release, live for validation |

For projects that span ecosystems (like World Bank/UNICEF tools with R, Python, and Stata implementations), the release-gate tests should be understood as a **translation, not a simplification**, of integration-testing practices into CRAN/PyPI's stricter governance regime.

### wbopendata Test Categories Mapped to Purpose

| Cat | Category | Tests | Type | Network? | Purpose |
|-----|----------|-------|------|----------|---------|
| 0 | ENV (01-05) | 5 | Environment | No | Certify installation integrity |
| 1 | DL (01-05) | 5 | Integration | Yes | Validate core download functionality |
| 2 | FMT (01-03) | 3 | Integration | Yes | Validate format/reshape options |
| 3 | CTRY (01-10) | 10 | Integration | Yes | Validate metadata merge features |
| 4 | REG (33-51) | 4 | Regression | Yes | Prevent bug recurrence |
| 5 | LW (01-04) | 4 | Integration | Yes | Validate graph metadata features |
| 6 | UPD (01-06) | 6 | Integration | Yes | Validate update/maintenance commands |
| 7 | TOPIC/LANG | 2 | Integration | Yes | Validate topics API path and language |
| 8 | Advanced | 6 | Integration | Yes | PROJ, FMT-04, DESC, META, CTRY-11, DATE |
| 9 | CACHE/SYNC | 13 | Integration | Mixed | Cache management and metadata sync |
| 10 | DISC (01-07) | 7 | Certification | No | Discovery commands (offline YAML search) |
| 11 | CHAR (01-06) | 6 | Integration | Yes | Variable/dataset `char` metadata (v18.1) |
| 12 | ERR (01-08) | 8 | Certification | Mixed | Error conditions via `rcof` (Gould 2001) |
| 13 | EXT (01-04) | 4 | Integration | Yes | Boundary/extreme cases (Gould 2001) |
| 14 | DET (01-06) | 6 | Certification | No | Deterministic offline fixtures (Gould 2001) |
| | **Total** | **89** | | | |

### Summary

| Principle | CRAN/PyPI | wbopendata |
|-----------|-----------|------------|
| **Test isolation** | From network | From other tests |
| **Reproducibility** | Absolute | Integration: session-level; DET: absolute |
| **Failure = bug?** | Yes | Integration: not necessarily; ERR/DET: yes |
| **Primary audience** | Automated reviewers | Human developers |
| **Passes mean...** | "Code is correct" | "API works & code handles it correctly" |

**In short:** CRAN/PyPI tests certify correctness in isolation. wbopendata uses a hybrid approach: live integration tests validate operations in context, while ERR/DET/DISC tests certify logic correctness offline. Both paradigms coexist in the same suite (Gould 2001).

---

## Test Structure

### Test Suite Organization

The `run_tests.do` file implements a comprehensive test framework with:

1. **Argument Parsing**: Run all tests, single tests, or with verbose mode
2. **Test Categories**: Organized by functionality
3. **Test Framework**: Reusable programs for consistent test execution
4. **Logging**: Automatic logging with timestamps and history tracking

### Usage Examples

```stata
* Run all tests (from qa/ folder - auto-detects repo path)
cd "C:/path/to/wbopendata-dev/qa"
do run_tests.do

* Run all tests but skip repo-comparison tests (ENV-01 to ENV-04)
do run_tests.do norepo

* Run single test
do run_tests.do CTRY-01

* Run with verbose/trace mode
do run_tests.do CTRY-01 verbose

* List available tests
do run_tests.do list

* Configure repo path manually (alternative to auto-detection)
global wbopendata_repo "D:/Projects/wbopendata-dev"
do run_tests.do
```

> **See also:** [README.md](README.md) for quick start | [Test Protocol](test_protocol.md) for detailed test descriptions

## Best Practices for Stata Testing

### 1. NEVER Use Empty Capture Blocks

**Problem**: Empty `cap {}` or `cap noi {}` blocks don't execute meaningful commands before checking `_rc`.

**WRONG - This fails silently**:
```stata
cap {
    * Just comments, no actual commands run
}
if _rc == 0 test_pass  // _rc is meaningless here
else test_fail "Error"
```

**RIGHT - Explicit checks with informative errors**:
```stata
capture noisily wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nometadata
if _rc != 0 {
    test_fail "Failed to download: r(`=_rc')"
}
else {
    * 1) Check variable exists
    capture confirm variable countryname
    if _rc != 0 {
        test_fail "Variable countryname is missing"
    }
    else {
        * 2) Check variable has data
        quietly count if !missing(countryname)
        if r(N) == 0 {
            test_fail "Variable countryname exists but has no data"
        }
        else test_pass
    }
}
```

### 2. Avoid Macro Length Issues

**Problem**: Auto-generated metadata files (like `_wbod_tmpfile1.ado`) contain thousands of lines that can exceed Stata's macro substitution limits.

**Critical Fix**: Remove corrupted auto-generated files before running tests:

```stata
* Remove corrupted auto-generated files that cause r(920)
local autogen_files "_parameters _wbod_tmpfile1 _wbod_tmpfile2 _wbod_tmpfile3"
foreach f of local autogen_files {
    cap qui findfile `f'.ado
    if _rc == 0 {
        local fpath "`r(fn)'"
        cap erase "`fpath'"
        if _rc == 0 di as text "Removed corrupted: `fpath'"
    }
}
```

**Solution for match() tests**: Use real datasets instead of manually created test data:

```stata
* ❌ BAD - Can cause macro length errors
clear
input str3 countrycode
"USA"
"BRA"
end
wbopendata, match(countrycode)  // May fail with r(920)

* ✅ GOOD - Uses real dataset
wbopendata, indicator(SP.POP.TOTL) country(USA;BRA) clear long nometadata
wbopendata, match(countrycode)  // Works reliably
```

### 2. Test Framework Structure

Use consistent helper programs:

```stata
* Define test runner
program define run_test
    args test_id description
    * Check if test should run
    if "$target_test" != "" & upper("$target_test") != upper("`test_id'") {
        global skip_test 1
        exit
    }
    global skip_test 0
    di as text _n "--- TEST `test_id': `description' ---"
    global current_test "`test_id'"
    global tests_run = $tests_run + 1
end

* Define pass handler
program define test_pass
    if $skip_test == 1 exit
    di as result "PASS"
    global tests_pass = $tests_pass + 1
end

* Define fail handler
program define test_fail
    args message
    if $skip_test == 1 exit
    di as error "FAIL: `message'"
    global tests_fail = $tests_fail + 1
    global failed_tests "$failed_tests, $current_test"
end
```

### 3. Test Pattern

Each test follows this pattern:

```stata
run_test "TEST-ID" "Description of test"
if $skip_test == 0 {
    cap noi {
        * Test code here
        * Use assert to verify conditions
        assert condition
    }
    if _rc == 0 test_pass
    else test_fail "Error message"
}
```

### 4. Resource Management

Set appropriate limits at the start:

```stata
clear all
set more off
set maxvar 32767          // Increase variable limit
set varabbrev off         // Disable variable abbreviation
adopath ++ "path/to/dev"  // Add development path
```

### 5. Logging Best Practices

```stata
* Create timestamped log files
local datestr = subinstr("`c(current_date)'", " ", "", .)
local logfile "test_results_v`version'_`datestr'.log"
log using "`logfile'", replace text

* Close log and save history
log close
file open history using "test_history.txt", write append
file write history "Test Run: `c(current_date)' `c(current_time)'" _n
file close history
```

### 6. Capture and Report Errors

Use `cap noi` to capture errors while still displaying output:

```stata
cap noi {
    wbopendata, indicator(SP.POP.TOTL) clear nometadata long
    desc, short
    assert _N > 200  // Verify we got data
}
if _rc == 0 test_pass
else test_fail "Failed with return code `_rc'"
```

### 7. Test Isolation

Each test should:
- Clear data at the start
- Not depend on previous tests
- Clean up after itself
- Test one specific feature

### 8. Assertions

Use meaningful assertions:

```stata
* ✅ GOOD - Clear what's being tested
cap confirm variable countryname
assert _rc == 0

* ✅ GOOD - Verify data content
levelsof countryname, local(names) clean
assert wordcount("`names'") >= 3

* ✅ GOOD - Check specific values
qui count if inlist(countrycode, "USA", "BRA", "CHN")
assert r(N) >= 3
```

## Test Categories

### Category 0: Environment Checks (ENV-01 to ENV-05) — 5 tests
Verify installation, file sync, package integrity, and YAML readability. ENV-01 to ENV-04 require repo path; ENV-05 validates parameters YAML parsing.

### Category 1: Basic Downloads (DL-01 to DL-05) — 5 tests
Test core data download functionality: single indicator, single country, multiple countries, multiple indicators, and poverty/GDP indicator pairs.

### Category 2: Format Options (FMT-01 to FMT-03) — 3 tests
Test long format reshaping, year range filtering, and latest-available-year option.

### Category 3: Country Metadata (CTRY-01 to CTRY-10) — 10 tests
Test `match()` option, full country metadata, ISO codes, geographic groups, capital coordinates, lat/long, regions, income/lending groups, and geographic options with indicator downloads.

### Category 4: Regression Tests (REG-33, REG-45, REG-46, REG-51) — 4 tests
Prevent previously fixed bugs from reoccurring. Each test corresponds to a closed GitHub issue.

### Category 5: Graph Metadata (LW-01 to LW-04) — 4 tests
Test v17.6 `linewrap()` option, `maxlength()` control, `r(latest)` scalars, and multi-field line wrapping.

### Category 6: Maintenance Commands (UPD-01 to UPD-06) — 6 tests
Test `update query`, `describe`, `update`, `update check detail`, `update all`, and `sync replace force`.

### Category 7: Topics & Language (TOPIC-01, LANG-01) — 2 tests
Test topics API download path and Spanish language option.

### Category 8: Advanced Features — 6 tests
Test projection data (PROJ-01), `nobasic` option (FMT-04), describe-only mode (DESC-01), `nometadata` verification (META-01), admin regions (CTRY-11), and date ranges (DATE-01).

### Category 9: Cache & Sync System (CACHE-01 to CACHE-08, SYNC-01 to SYNC-05) — 13 tests
Test v18.0 cache directory initialization, YAML path resolution, cache info/clear/persistence, version tracking, timestamps, search with cached YAML, update checking, sync replace, sync force, up-to-date detection, and discovery commands using cache.

### Category 10: Discovery Commands (DISC-01 to DISC-07) — 7 tests
Test v18.0 offline discovery: keyword search, filtered search (source/topic/field), pattern matching (wildcard/AND/exact), sources listing, topics listing, indicator info lookup, and search router by Stata version. No network required.

### Category 11: Characteristic Metadata (CHAR-01 to CHAR-06) — 6 tests
Test v18.1 `char` metadata: dataset-level `_dta` chars, variable-level indicator chars, variable-level metadata chars (with metadata download), `nochar` suppression, multi-indicator per-variable chars, and char persistence across save/use cycles.

### Category 12: Error Conditions (ERR-01 to ERR-08) — 8 tests
Test error handling using Gould (2001) `rcof` methodology: no indicator specified, invalid indicator code, match+indicator conflict, invalid country code, invalid source ID, deprecated indicator handling, inverted year range, and empty indicator string.

### Category 13: Extreme Cases (EXT-01 to EXT-04) — 4 tests
Test boundary conditions per Gould (2001): minimal query (1 country, 1 year), all-countries single-year, long indicator names, and topics with special characters (compound quoting stress).

### Category 14: Deterministic/Offline Tests (DET-01 to DET-06) — 6 tests
Test Gould (2001) Phase 6 certification using `offline()` option with CSV fixtures: single indicator/country, single indicator/all countries, value pinning (USA population 2020), different indicator (GDP), country-only query, and missing fixture error handling. No network required.

## Common Issues and Solutions

### Issue: r(920) - Macro substitution line too long

**Cause**: Auto-generated files with thousands of replace statements

**Solution**: Use real datasets instead of manual input (see section 1)

### Issue: Tests pass individually but fail when run together

**Cause**: State leaking between tests (globals, locals, data)

**Solution**: Ensure each test starts with `clear` and initializes its own state

### Issue: Tests work in interactive mode but fail in batch

**Cause**: Different adopath or missing dependencies

**Solution**: Explicitly set adopath in test file

## Maintenance

### Adding New Tests

1. Choose appropriate category
2. Assign unique test ID (e.g., CTRY-11)
3. Follow the standard test pattern
4. Update the `list` help text
5. Document in this guide

### Updating Tests After Bug Fixes

When fixing a bug:
1. Add regression test in Category 4
2. Name it REG-XX where XX is the issue number
3. Test that bug is fixed and doesn't recur

## Performance Tips

1. **Use `nometadata`**: Skip metadata download when not needed
2. **Limit data**: Use specific countries/years for faster tests
3. **Cache common downloads**: If testing non-download features
4. **Run targeted tests**: Use single-test mode during development

## References

### Methodological
- Gould, W. (2001). "Statistical Software Certification." *The Stata Journal*, 1(1), 29–50.
  - Phase 1: Known results → DL, FMT, CTRY tests
  - Phase 2: Boundary inputs → EXT tests
  - Phase 3: Error conditions → ERR tests (via `rcof`)
  - Phase 6: Deterministic reproducibility → DET tests (via `offline()`)

### Stata Programming
- Stata Programming Reference: `help programming`
- Stata Error Codes: `help error codes`
- Stata Certification Script: `help cscript`, `help rcof`
- File I/O: `help file`
- Assertions: `help assert`
- Capture: `help capture`
- Characteristics: `help char`

## Version History

- **18.3.1** (Feb 2026): 92 tests, 15 categories. Added DISC-08/09/10, consolidated categories. Data response cache tests. Test suite v3.1.0.
- **18.1.0** (Feb 2026): 89 tests, 17 categories. Added CHAR (6), ERR (8), EXT (4), DET (6). Offline deterministic testing via `offline()`. Gould (2001) `rcof` methodology. Test suite v3.0.0.
- **18.0.0** (Feb 2026): 65 tests, 15 categories. Added CACHE (8), SYNC (5), DISC (7). YAML metadata architecture. `cscript` framework. Auto-detecting repo paths.
- **17.7.1** (Jan 2026): Expanded to 44 tests; added Topics, Language, Projection, Date, and Advanced Features tests
- **17.7.0** (Jan 2026): Added default basic variables behavior; added FMT-04 (nobasic) test
- **17.6.3** (Jan 2026): Fixed macro length issues in CTRY tests
- **17.6.0** (Dec 2025): Added linewrap and graph metadata tests (LW-01 to LW-04)
- **17.0.0**: Initial test suite creation
