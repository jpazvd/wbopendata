# wbopendata Testing Guide

[← Back to README](../README.md) | [Test Protocol](test_protocol.md) | [Test Coverage](additional_tests.md) | [FAQ](../doc/FAQ.md)

---

## Overview

This guide documents best practices for testing Stata ADO packages, specifically for `wbopendata`.

## Testing Philosophy: wbopendata vs. CRAN/PyPI

### The Two Paradigms

Software testing in the statistical ecosystem follows two fundamentally different paradigms, each serving distinct purposes and audiences:

| Aspect | CRAN / PyPI (Release Gates) | wbopendata (Operational Validation) |
|--------|----------------------------|-------------------------------------|
| **Primary Goal** | Certify software correctness | Validate real-world operations |
| **Network Access** | Prohibited | Required |
| **Environment** | Sandboxed, offline | Interactive, trusted |
| **Determinism** | Fully reproducible | Depends on live data |
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

### Relationship Between the Two Approaches

These approaches are **complementary, not competing**:

| If you're building... | Use... |
|-----------------------|--------|
| R package for CRAN submission | Offline mocked tests only |
| Python package for PyPI | Offline mocked tests + optional live integration tests |
| Stata package like wbopendata | Live integration tests (primary) |
| Multi-language ecosystem tool | Both: mocked for CI/release, live for validation |

For projects that span ecosystems (like World Bank/UNICEF tools with R, Python, and Stata implementations), the release-gate tests should be understood as a **translation, not a simplification**, of integration-testing practices into CRAN/PyPI's stricter governance regime.

### wbopendata Test Categories Mapped to Purpose

| Category | Type | Network? | Purpose |
|----------|------|----------|---------|
| ENV (01-04) | Environment | No | Certify installation integrity |
| DL (01-05) | Integration | Yes | Validate core download functionality |
| FMT (01-04) | Integration | Yes | Validate format/reshape options |
| CTRY (01-11) | Integration | Yes | Validate metadata merge features |
| REG (33-51) | Regression | Yes | Prevent bug recurrence |
| LW (01-04) | Integration | Yes | Validate graph metadata features |
| UPD (01-06) | Integration | Yes | Validate update/maintenance commands |
| TOPIC (01) | Integration | Yes | Validate topics API path |
| LANG (01) | Integration | Yes | Validate language option |
| PROJ/DESC/META/DATE | Integration | Yes | Validate advanced features |

### Summary

| Principle | CRAN/PyPI | wbopendata |
|-----------|-----------|------------|
| **Test isolation** | From network | From other tests |
| **Reproducibility** | Absolute | Session-level |
| **Failure = bug?** | Yes | Not necessarily |
| **Primary audience** | Automated reviewers | Human developers |
| **Passes mean...** | "Code is correct" | "API is working & code handles it" |

**In short:** CRAN/PyPI tests certify correctness in isolation. wbopendata tests validate operations in context. Both are important—they serve different audiences and constraints.

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
* Run all tests
do run_tests.do

* Run single test
do run_tests.do CTRY-01

* Run with verbose/trace mode
do run_tests.do CTRY-01 verbose

* List available tests
do run_tests.do list
```

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

### Category 0: Environment Checks (ENV-01 to ENV-04)
Verify installation, file sync, and package integrity

### Category 1: Basic Downloads (DL-01 to DL-05)
Test core data download functionality

### Category 2: Format Options (FMT-01 to FMT-04)
Test long format, year ranges, latest option, and nobasic option

### Category 3: Country Metadata (CTRY-01 to CTRY-11)
Test match option and country metadata features including admin regions

### Category 4: Regression Tests (REG-33, REG-45, REG-46, REG-51)
Prevent previously fixed bugs from reoccurring

### Category 5: Graph Metadata (LW-01 to LW-04)
Test v17.6 linewrap and metadata features

### Category 6: Maintenance Commands (UPD-01 to UPD-06)
Test update, query, and describe commands

### Category 7: Topics & Language (TOPIC-01, LANG-01)
Test topics API path and language options

### Category 8: Advanced Features (PROJ-01, DESC-01, META-01, DATE-01)
Test projection data, describe-only mode, nometadata verification, and date ranges

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

- Stata Programming Reference: `help programming`
- Stata Error Codes: `help error codes`
- File I/O: `help file`
- Assertions: `help assert`
- Capture: `help capture`

## Version History

- **17.7.1** (Jan 2026): Expanded to 44 tests; added Topics, Language, Projection, Date, and Advanced Features tests
- **17.7.0** (Jan 2026): Added default basic variables behavior; added FMT-04 (nobasic) test
- **17.6.3** (Jan 2026): Fixed macro length issues in CTRY tests
- **17.6.0** (Dec 2025): Added linewrap and graph metadata tests (LW-01 to LW-04)
- **17.0.0**: Initial test suite creation
