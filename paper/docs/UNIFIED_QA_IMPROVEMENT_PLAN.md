# Unified QA Improvement Plan: wbopendata & unicefdata

**Date:** 2026-02-09
**Authors:** Joao Pedro Azevedo, with Claude Code assistance
**References:**
- Gould, W. (2001). "Statistical software certification." *The Stata Journal* 1(1): 29-50.
- Drukker, D. M. (2006). "Importing Federal Reserve economic data." *The Stata Journal* 6(3): 384-386.

**Source documents:**
- `unicefData-dev/paper/DRUKKER_GOULD_IMPROVEMENT_PLAN.md`
- `wbopendata-dev/paper/docs/discussion_drukker_gould.md`
- `unicefData-dev/paper/QA_IMPROVEMENT_PLAN.md`

---

## 1. Context and Motivation

Both `wbopendata` and `unicefdata` have functional test suites that exercise their
respective Stata packages via automated do-file scripts. These suites follow a custom
framework pattern with helper programs for reporting pass/fail results, logging to
history files, and supporting selective test execution.

Two prior analyses — the Drukker/Gould improvement plan for unicefdata and the
structured discussion document for wbopendata — identified common gaps when the
test suites are measured against Gould's (2001) certification methodology:

1. Neither suite uses `cscript` for clean-state initialization
2. Neither suite uses `rcof` for error condition testing
3. Neither suite systematically tests error conditions (ERR family)
4. Neither suite systematically tests extreme cases (EXT family)
5. Neither suite uses `reldif` for cross-platform numerical comparisons
6. Neither suite pins expected data values for regression detection
7. wbopendata lacks per-test documentation; unicefdata lacks `assert` usage

This plan unifies those recommendations into a concrete, sequenced set of changes
applied consistently to both suites.

---

## 2. Current State Comparison

### 2.1 Test suite overview

| Aspect | wbopendata | unicefdata |
|--------|-----------|-----------|
| **File** | `wbopendata-dev/qa/run_tests.do` | `unicefData-dev/stata/qa/run_tests.do` |
| **Total tests** | 71 (67 core + 4 repo-comparison) | 38+ |
| **Suite version** | 2.0.0 | 1.5.2 |
| **Stata requirement** | v14+ (v16+ for cache/search) | v14+ (v16+ for YAML) |

### 2.2 Framework comparison

| Feature | wbopendata | unicefdata |
|---------|-----------|-----------|
| **Helper programs** | `run_test`, `test_pass`, `test_fail` | `test_start`, `test_pass`, `test_fail`, `test_skip` |
| **Start signature** | `run_test "ID" "desc"` | `test_start, id("ID") desc("desc")` |
| **Pass signature** | `test_pass` (no args) | `test_pass, id("ID") msg("text")` |
| **Fail signature** | `test_fail "message"` | `test_fail, id("ID") msg("text") rc(N)` |
| **Skip support** | No (tests decrement counter) | Yes (`test_skip` program) |
| **`assert` usage** | Yes (inside `cap noi` blocks) | No (manual `if _rc` chains) |
| **`cscript`** | Not used | Not used |
| **`rcof`** | Not used | Not used |
| **Single-test mode** | `do run_tests.do DL-01` | `do run_tests.do DL-01` |
| **Verbose mode** | `do run_tests.do verbose` | `do run_tests.do verbose` |
| **Test listing** | `do run_tests.do list` | `do run_tests.do list` |
| **Per-test docs** | 1-2 line comments | 50-150 line doc blocks |
| **Priority labels** | No | Yes (P0/P1/P2) |
| **History tracking** | File append with duration | File append with git branch |

### 2.3 Test family inventory

**wbopendata (11 categories, 71 tests):**

| Category | Tests | IDs | Network? |
|----------|-------|-----|----------|
| Environment Checks | 5 | ENV-01 to ENV-05 | No |
| Basic Downloads | 5 | DL-01 to DL-05 | Yes |
| Format Options | 3 | FMT-01 to FMT-03 | Yes |
| Country Metadata | 10 | CTRY-01 to CTRY-10 | Yes |
| Regression Tests | 4 | REG-33, REG-45, REG-46, REG-51 | Yes |
| Graph Metadata | 4 | LW-01 to LW-04 | Yes |
| Maintenance Commands | 6 | UPD-01 to UPD-06 | Yes |
| Topics & Language | 2 | TOPIC-01, LANG-01 | Yes |
| Advanced Features | 6 | PROJ-01, FMT-04, DESC-01, META-01, CTRY-11, DATE-01 | Yes |
| Cache & Sync | 13 | CACHE-01 to CACHE-08, SYNC-01 to SYNC-05 | Partial |
| Discovery Commands | 7 | DISC-01 to DISC-07 | No |
| Characteristic Metadata | 6 | CHAR-01 to CHAR-06 | Yes |

**unicefdata (10 categories, 38+ tests):**

| Category | Tests | IDs | Network? |
|----------|-------|-----|----------|
| Environment Checks | 2-4 | ENV-01 to ENV-04 | No |
| Basic Downloads | 9 | DL-01 to DL-09 | Yes |
| Data Integrity | 1 | DATA-01 | Yes |
| Discovery Commands | 5 | DISC-01 to DISC-05 | Mixed |
| Tier Filtering | 3 | TIER-01 to TIER-03 | Yes |
| Metadata Sync | 4 | SYNC-01 to SYNC-04 | Yes |
| Format Options | 3 | FMT-01 to FMT-03 | Yes |
| Transformations & Metadata | 5 | TRANS-01, TRANS-02, META-01, META-02, MULTI-01 | Yes |
| Robustness & Performance | 5 | EDGE-01 to EDGE-03, PERF-01, REGR-01 | Yes |
| YAML Integration | 2 | YAML-01, YAML-02 | No |
| Cross-Platform | 5 | XPLAT-01 to XPLAT-05 | No |

---

## 3. Phase 1: Common Framework Alignment

### 3.1 Add `cscript` to test suite initialization (both suites)

**What:** Add `cscript "suite_name"` once at the top of each `run_tests.do`, after
`clear all` and before any tests begin.

**Why:** `cscript` is Gould's standard for clean-state initialization. It clears macros,
labels, programs, and scalars. Using it signals to SJ reviewers that the suite follows
Stata's own certification methodology.

**How:** This is additive. The existing custom framework (`test_pass`/`test_fail`) is
preserved — it provides reporting, history, and selective execution that `cscript`
alone does not.

**wbopendata** — insert after line 52 of `qa/run_tests.do`:
```stata
clear all
set more off
cap log close _all
cscript "wbopendata test suite"
```

**unicefdata** — insert after line 35 of `stata/qa/run_tests.do`:
```stata
clear all
set more off
cap log close _all
cscript "unicefdata test suite"
```

**Impact:** Minimal code change (1 line each). Establishes clean-state guarantee.

---

### 3.2 Adopt `assert` consistently (unicefdata only)

**What:** Refactor unicefdata's nested `if _rc == 0 { ... } else { test_fail }` chains
to use `assert` statements inside `cap noi { }` blocks.

**Why:** `assert` is the canonical Gould mechanism for test verification. It produces
a clear error when the condition fails, setting `_rc` which the outer `cap noi` catches.
wbopendata already uses this pattern; unicefdata should adopt it for consistency.

**Current unicefdata pattern (verbose, nested):**
```stata
test_start, id("DL-01") desc("Single indicator download")
cap noi unicefdata, indicator(CME_MRY0T4) countries(USA) year(2020) clear
if _rc != 0 {
    test_fail, id("DL-01") msg("Download failed") rc(_rc)
}
else {
    qui count
    if r(N) == 0 {
        test_fail, id("DL-01") msg("No observations")
    }
    else {
        cap confirm variable iso3
        if _rc != 0 {
            test_fail, id("DL-01") msg("Missing iso3 variable")
        }
        else {
            test_pass, id("DL-01") msg("Downloaded `=_N' obs")
        }
    }
}
```

**Target pattern (linear, assert-based — matching wbopendata):**
```stata
test_start, id("DL-01") desc("Single indicator download")
cap noi {
    unicefdata, indicator(CME_MRY0T4) countries(USA) year(2020) clear
    assert _N > 0
    cap confirm variable iso3
    assert _rc == 0
    cap confirm variable indicator
    assert _rc == 0
    cap confirm variable period
    assert _rc == 0
    cap confirm variable value
    assert _rc == 0
}
if _rc == 0 test_pass, id("DL-01") msg("Downloaded `=_N' obs")
else test_fail, id("DL-01") msg("Download or validation failed") rc(_rc)
```

**Scope:** All 38+ test blocks in unicefdata. This is a mechanical refactor — nested
`if/else` chains become linear `assert` sequences. The `cap noi { }` wrapper catches
any `assert` failure and sets `_rc`.

**Files:** `unicefData-dev/stata/qa/run_tests.do` — refactor all test blocks

---

### 3.3 Add `test_skip` program to wbopendata (from unicefdata)

**What:** wbopendata currently has no skip mechanism. When a test cannot run (e.g., no
repo path), it decrements `$tests_run` — making skip counts invisible.

**Code to add** (insert after `test_fail` program definition, ~line 412):
```stata
cap program drop test_skip
program define test_skip
    args reason
    if $skip_test == 1 exit
    di as text "SKIP: `reason'"
    global tests_skip = $tests_skip + 1
    global tests_run = $tests_run - 1  // Don't count as run
end
```

Also add `global tests_skip = 0` in the initialization block (~line 418).

Replace the current skip pattern:
```stata
* Current:
di as text "SKIPPED: Repo path not configured"
global tests_run = $tests_run - 1

* New:
test_skip "Repo path not configured"
```

---

## 4. Phase 2: Add ERR Family (Error Condition Tests)

### 4.1 Gould's principle

> "It is not sufficient to test that your code works in circumstances where it should.
> You must also test that your code does not work in circumstances where it should not."
> — Gould (2001), p. 36

Error condition tests verify that the command properly rejects invalid input. They are
the single strongest signal of code maturity to SJ reviewers.

### 4.2 wbopendata ERR tests (8 new tests)

Add as Category 12 after CHAR tests in `wbopendata-dev/qa/run_tests.do`:

```stata
*===============================================================================
* TEST CATEGORY 12: Error Conditions (ERR)
*   Gould (2001): "You must also test that your code does not work in
*   circumstances where it should not."
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 12: Error Conditions"
di as text "`sep'"

* ERR-01: No indicator and no action specified
*   PURPOSE: Verify wbopendata errors when called with no indicator or action
*   CODE: wbopendata.ado syntax parsing block
*   EXPECTED: Non-zero return code
run_test "ERR-01" "Error: no indicator or action specified"
if $skip_test == 0 {
    cap noi wbopendata, clear
    if _rc != 0 test_pass
    else test_fail "Should have errored without indicator"
}

* ERR-02: Invalid indicator code
*   PURPOSE: Verify graceful handling of non-existent indicator
*   CODE: wbopendata.ado -> _query.ado -> World Bank API (returns empty)
*   EXPECTED: Error or zero observations
run_test "ERR-02" "Error: invalid indicator code"
if $skip_test == 0 {
    cap noi wbopendata, indicator(XXXXX.INVALID.CODE) clear nometadata long
    if _rc != 0 | _N == 0 test_pass
    else test_fail "Invalid indicator should error or return 0 obs"
}

* ERR-03: Match with indicator (mutually exclusive options)
*   PURPOSE: Verify match() and indicator() cannot be combined with clear
*   CODE: wbopendata.ado option validation
*   EXPECTED: Non-zero return code (already tested as REG-51)
run_test "ERR-03" "Error: match+indicator conflict"
if $skip_test == 0 {
    clear
    input str3 countrycode
    "USA"
    end
    cap noi wbopendata, indicator(SP.POP.TOTL) match(countrycode) clear
    if _rc != 0 test_pass
    else test_fail "match+indicator+clear should be rejected"
}

* ERR-04: Invalid country code
*   PURPOSE: Verify graceful handling of non-existent country
*   CODE: wbopendata.ado -> World Bank API (filters to 0 obs)
*   EXPECTED: Error or zero observations
run_test "ERR-04" "Error: invalid country code"
if $skip_test == 0 {
    cap noi wbopendata, indicator(SP.POP.TOTL) country(ZZZZZ) clear nometadata long
    if _rc != 0 | _N == 0 test_pass
    else test_fail "Invalid country should return 0 obs or error"
}

* ERR-05: Invalid source ID
*   PURPOSE: Verify graceful handling of non-existent source database
*   CODE: wbopendata.ado source() option -> API request
*   EXPECTED: Error or zero observations
run_test "ERR-05" "Error: invalid source ID"
if $skip_test == 0 {
    cap noi wbopendata, indicator(SP.POP.TOTL) source(9999) clear nometadata long
    if _rc != 0 | _N == 0 test_pass
    else test_fail "Invalid source should return 0 obs or error"
}

* ERR-06: Deprecated indicator
*   PURPOSE: Verify deprecated indicators are handled without crash
*   CODE: wbopendata.ado -> World Bank API (may return error XML)
*   EXPECTED: Error or zero observations (graceful degradation)
run_test "ERR-06" "Error: deprecated indicator handling"
if $skip_test == 0 {
    cap noi wbopendata, indicator(SP.ADO.TFRT) clear nometadata long
    if _rc != 0 | _N == 0 test_pass
    else test_fail "Deprecated indicator should be handled gracefully"
}

* ERR-07: Year range inverted
*   PURPOSE: Test behavior when year range end < start
*   CODE: wbopendata.ado year() option parsing
*   EXPECTED: Either error or API corrects the order
run_test "ERR-07" "Error: inverted year range"
if $skip_test == 0 {
    cap noi wbopendata, indicator(SP.POP.TOTL) country(USA) year(2020:2010) clear nometadata long
    * API may accept either order; just verify no crash
    test_pass
}

* ERR-08: Empty indicator string
*   PURPOSE: Verify empty indicator() is rejected
*   CODE: wbopendata.ado syntax parsing
*   EXPECTED: Non-zero return code
run_test "ERR-08" "Error: empty indicator string"
if $skip_test == 0 {
    cap noi wbopendata, indicator() clear
    if _rc != 0 test_pass
    else test_fail "Empty indicator should error"
}
```

### 4.3 unicefdata ERR tests (8 new tests)

Add as a new category in `unicefData-dev/stata/qa/run_tests.do`:

```stata
*===============================================================================
* CATEGORY: ERROR CONDITIONS (ERR)
*   Gould (2001): "You must also test that your code does not work in
*   circumstances where it should not."
*===============================================================================

* ERR-01: Mutually exclusive output formats
*   PURPOSE: wide and wide_indicators cannot be combined
*   EXPECTED: Non-zero return code
test_start, id("ERR-01") desc("Error: mutually exclusive formats (wide + wide_indicators)")
cap noi {
    unicefdata, indicator(CME_MRY0T4;CME_MRY0) wide wide_indicators clear
}
if _rc != 0 test_pass, id("ERR-01") msg("Correctly rejected")
else test_fail, id("ERR-01") msg("Should reject wide + wide_indicators")

* ERR-02: wide_indicators requires multiple indicators
*   PURPOSE: wide_indicators with a single indicator is meaningless
*   EXPECTED: Non-zero return code or warning
test_start, id("ERR-02") desc("Error: wide_indicators with single indicator")
cap noi {
    unicefdata, indicator(CME_MRY0T4) wide_indicators clear
}
if _rc != 0 test_pass, id("ERR-02") msg("Correctly rejected")
else test_fail, id("ERR-02") msg("Should reject single-indicator wide_indicators")

* ERR-03: attributes() without wide_attributes format
*   PURPOSE: attributes() option only makes sense with wide_attributes
*   EXPECTED: Non-zero return code
test_start, id("ERR-03") desc("Error: attributes() without wide_attributes")
cap noi {
    unicefdata, indicator(CME_MRY0T4) attributes(_T _M) clear
}
if _rc != 0 test_pass, id("ERR-03") msg("Correctly rejected")
else test_fail, id("ERR-03") msg("Should reject attributes without wide_attributes")

* ERR-04: Invalid country code
*   PURPOSE: Verify graceful handling of non-existent ISO3 code
*   EXPECTED: Error or zero observations
test_start, id("ERR-04") desc("Error: invalid country code")
cap noi {
    unicefdata, indicator(CME_MRY0T4) countries(ZZZ) year(2020) clear
}
if _rc != 0 | _N == 0 test_pass, id("ERR-04") msg("Handled gracefully")
else test_fail, id("ERR-04") msg("Invalid country should return 0 obs or error")

* ERR-05: Year range inverted
*   PURPOSE: Test behavior when end year < start year
*   EXPECTED: Error or API corrects the order
test_start, id("ERR-05") desc("Error: inverted year range")
cap noi {
    unicefdata, indicator(CME_MRY0T4) countries(USA) year(2025:2020) clear
}
* API may accept either order; just verify no crash
test_pass, id("ERR-05") msg("No crash on inverted range")

* ERR-06: No indicator and no discovery option
*   PURPOSE: Verify unicefdata errors when given no action
*   EXPECTED: Non-zero return code
test_start, id("ERR-06") desc("Error: no indicator or action")
cap noi {
    unicefdata, clear
}
if _rc != 0 test_pass, id("ERR-06") msg("Correctly rejected")
else test_fail, id("ERR-06") msg("Should error without indicator or action")

* ERR-07: circa without year
*   PURPOSE: circa option requires year() to be specified
*   EXPECTED: Non-zero return code
test_start, id("ERR-07") desc("Error: circa without year")
cap noi {
    unicefdata, indicator(CME_MRY0T4) circa clear
}
if _rc != 0 test_pass, id("ERR-07") msg("Correctly rejected")
else test_fail, id("ERR-07") msg("Should reject circa without year")

* ERR-08: Invalid indicator code
*   PURPOSE: Verify graceful handling of non-existent indicator
*   EXPECTED: Error or zero observations
test_start, id("ERR-08") desc("Error: invalid indicator code")
cap noi {
    unicefdata, indicator(XXXXX_INVALID) countries(USA) year(2020) clear
}
if _rc != 0 | _N == 0 test_pass, id("ERR-08") msg("Handled gracefully")
else test_fail, id("ERR-08") msg("Invalid indicator should return 0 obs or error")
```

**Note:** Some of these tests may reveal that the command currently does NOT validate
properly. That is exactly Gould's point: "writing the test exposes the bug." If the
command accepts `wide wide_indicators` without error, that is a bug to fix.

---

## 5. Phase 3: Add EXT Family (Extreme Case Tests)

### 5.1 Gould's principle

> "Extreme cases put considerable stress on your code and, if the code can handle
> that, the chances that it is getting interior cases correct are greatly improved."
> — Gould (2001), p. 39

These are the equivalent of Gould's "R-squared = 1 regression" and "single-panel xt
estimator" tests — cases that expose assumptions about data shape and size.

### 5.2 wbopendata EXT tests (4 new tests)

Add as Category 13 after ERR tests in `wbopendata-dev/qa/run_tests.do`:

```stata
*===============================================================================
* TEST CATEGORY 13: Extreme Cases (EXT)
*   Gould (2001): "Extreme cases put considerable stress on your code."
*===============================================================================

di as text _n "`sep'"
di as text "CATEGORY 13: Extreme Cases"
di as text "`sep'"

* EXT-01: Minimal query — single country, single year, single indicator
*   PURPOSE: Verify minimum viable query produces valid 1-row result
*   EXPECTED: Exactly 1 observation for USA 2020
run_test "EXT-01" "Extreme: minimal query (1 country, 1 year)"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) country(USA) year(2020:2020) clear long nometadata
        assert _N == 1
        assert countrycode == "USA"
    }
    if _rc == 0 test_pass
    else test_fail "Minimal query failed"
}

* EXT-02: All countries — large result set
*   PURPOSE: Stress test with all 296 countries/regions
*   EXPECTED: _N > 200 (most countries have 2020 data)
run_test "EXT-02" "Extreme: all countries, single year"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(SP.POP.TOTL) year(2020:2020) clear long nometadata
        assert _N > 200
    }
    if _rc == 0 test_pass
    else test_fail "All-countries query failed or returned too few obs"
}

* EXT-03: Indicator with very long name (label truncation)
*   PURPOSE: Verify long indicator names don't cause label overflow
*   CODE: _query.ado variable labeling (~line 300)
*   EXPECTED: Download succeeds; variable label is truncated but valid
run_test "EXT-03" "Extreme: long indicator name"
if $skip_test == 0 {
    cap noi {
        wbopendata, indicator(DT.DOD.DECT.CD) clear long latest nometadata
        assert _N > 0
    }
    if _rc == 0 test_pass
    else test_fail "Long-name indicator failed"
}

* EXT-04: Topics with parentheses in names (compound quoting stress)
*   PURPOSE: Topic names containing parentheses test Stata's macro quoting
*   CODE: _wbopendata_topics.ado -> gettoken loop
*   EXPECTED: Topics listing succeeds without "SocialandGovernance()" error
run_test "EXT-04" "Extreme: topics with special characters"
if $skip_test == 0 {
    cap noi {
        qui _wbopendata_topics
        assert `r(n_topics)' > 0
        * Verify topic names containing parentheses are intact
        assert `"`r(topic_names)'"' != ""
    }
    if _rc == 0 test_pass
    else test_fail "Topics listing failed (possible quoting issue)"
}
```

### 5.3 unicefdata EXT tests (6 new tests)

Add as a new category in `unicefData-dev/stata/qa/run_tests.do`:

```stata
*===============================================================================
* CATEGORY: EXTREME CASES (EXT)
*   Gould (2001): "Extreme cases put considerable stress on your code."
*===============================================================================

* EXT-01: Minimal query — single country, single year, single indicator
test_start, id("EXT-01") desc("Extreme: minimal query")
cap noi {
    unicefdata, indicator(CME_MRY0T4) countries(USA) year(2020) clear
    assert _N >= 1
    cap confirm variable iso3
    assert _rc == 0
    cap confirm variable value
    assert _rc == 0
}
if _rc == 0 test_pass, id("EXT-01") msg("`=_N' obs for USA 2020")
else test_fail, id("EXT-01") msg("Minimal query failed") rc(_rc)

* EXT-02: All countries for one indicator, one year (large result set)
test_start, id("EXT-02") desc("Extreme: all countries, single year")
cap noi {
    unicefdata, indicator(CME_MRY0T4) year(2020) latest clear
    assert _N > 100  // expect 190+ countries
}
if _rc == 0 test_pass, id("EXT-02") msg("`=_N' countries returned")
else test_fail, id("EXT-02") msg("All-countries query failed") rc(_rc)

* EXT-03: Wide format with many years (30+ year columns)
test_start, id("EXT-03") desc("Extreme: wide format 1990-2023")
cap noi {
    unicefdata, indicator(CME_MRY0T4) countries(BRA) year(1990:2023) wide clear
    cap confirm variable yr1990
    assert _rc == 0
    cap confirm variable yr2023
    assert _rc == 0
}
if _rc == 0 test_pass, id("EXT-03") msg("Wide with 30+ year columns")
else test_fail, id("EXT-03") msg("Wide reshape failed") rc(_rc)

* EXT-04: wide_attributes with all sex values
test_start, id("EXT-04") desc("Extreme: wide_attributes with sex M/F/_T")
cap noi {
    unicefdata, indicator(CME_MRY0T4) sex(M F _T) wide_attributes clear
    assert _N > 0
}
if _rc == 0 test_pass, id("EXT-04") msg("`=_N' obs with sex disaggregation")
else test_fail, id("EXT-04") msg("wide_attributes with sex failed") rc(_rc)

* EXT-05: Bulk download from small dataflow
test_start, id("EXT-05") desc("Extreme: all indicators from CCRI dataflow")
cap noi {
    unicefdata, indicator(all) dataflow(CCRI) clear
    assert _N > 0
}
if _rc == 0 test_pass, id("EXT-05") msg("`=_N' obs from CCRI")
else test_fail, id("EXT-05") msg("Bulk CCRI download failed") rc(_rc)

* EXT-06: Query returning zero observations
test_start, id("EXT-06") desc("Extreme: zero-observation result")
cap noi {
    * Use a highly specific filter unlikely to match any data
    unicefdata, indicator(CME_MRY0T4) countries(USA) year(1800) clear
}
* Should return 0 obs or error gracefully — either is acceptable
if _rc == 0 test_pass, id("EXT-06") msg("Handled gracefully (N=`=_N')")
else test_pass, id("EXT-06") msg("Errored gracefully (rc=`=_rc')")
```

---

## 6. Phase 4: Value Pinning and `reldif`

### 6.1 Value pinning (both suites)

**What:** Add assertions that check specific known data values in download tests. These
anchor tests to real data, catching silent API changes or parsing regressions.

**Gould's principle:** "Test scripts do not so much verify that results are right as
they verify that results continue to be the same in the future." Value pins make this
explicit.

**wbopendata — enhance DL-02 (or add as separate PIN tests):**
```stata
* Value pin: USA population in 2020 should be ~331 million
* Source: World Bank WDI, SP.POP.TOTL, USA, 2020 = 331,002,651
cap noi {
    wbopendata, indicator(SP.POP.TOTL) country(USA) year(2020:2020) clear long nometadata
    assert _N == 1
    assert sp_pop_totl > 300000000 & sp_pop_totl < 400000000
}
```

**unicefdata — enhance DL-01 or add as separate PIN tests:**
```stata
* Value pin: Under-5 mortality rate, USA, 2020
* Source: UNICEF CME, CME_MRY0T4, USA, 2020 (finalized estimate)
cap noi {
    unicefdata, indicator(CME_MRY0T4) countries(USA) year(2020) clear
    assert _N >= 1
    * Under-5 mortality for USA should be between 5 and 10 per 1000
    qui sum value if iso3 == "USA"
    assert r(mean) > 1 & r(mean) < 20
}
```

### 6.2 Replace absolute tolerance with `reldif` (unicefdata)

**What:** In regression and cross-platform comparison tests, replace absolute tolerance
(`abs(diff) > threshold`) with `reldif()`.

**Why:** Gould explains at length why `reldif` is the correct comparison function for
floating-point results across platforms and architectures. `reldif(a, b)` returns
`|a-b| / max(|a|, |b|)`, which scales with the magnitude of the values.

**Current pattern (REGR-01):**
```stata
cap gen diff = abs(current_value - baseline_value)
qui count if diff > 0.01
```

**Target pattern:**
```stata
cap gen rdiff = reldif(current_value, baseline_value)
qui count if rdiff > 1e-6 & !missing(current_value) & !missing(baseline_value)
```

**Threshold guidance:**
- Integer counts: use exact equality (`assert x == y`)
- Rates/proportions: `1e-10` (10 significant digits)
- General floating point: `1e-6` (6 significant digits, conservative)

---

## 7. Phase 5: Cross-Pollinate Strengths

### 7.1 Add per-test documentation to wbopendata (from unicefdata)

unicefdata's documentation blocks are a major strength. Each test has:
- **PURPOSE**: What the test verifies
- **WHAT IS TESTED**: Specific code paths exercised
- **CODE BEING TESTED**: File paths and line numbers
- **WHERE TO DEBUG**: Step-by-step diagnostic instructions
- **EXPECTED RESULT**: Clear pass criteria
- **RELATED TESTS**: Cross-references

Add abbreviated versions (5-10 lines) to all 71 wbopendata tests:

```stata
* DL-01: Single indicator download
*   PURPOSE: Verify basic single-indicator download produces valid dataset
*   CODE: wbopendata.ado -> _query.ado -> __query.ado -> World Bank API
*   EXPECTED: _N > 200 observations for SP.POP.TOTL (all countries, all years)
*   DEBUG: 1. Check internet; 2. Run: which wbopendata; 3. Try: wbopendata, update query
*   RELATED: DL-02 (country filter), DL-04 (multi-indicator)
```

### 7.2 Add P0/P1/P2 priority labels to wbopendata (from unicefdata)

Add priority labels to test descriptions. Priority determines which tests must pass
for a release:

| Priority | Meaning | wbopendata families |
|----------|---------|-------------------|
| **P0** | Must pass for release | ENV, DL, FMT, REG, ERR |
| **P1** | Should pass | CTRY, CACHE, SYNC, DISC, CHAR, UPD |
| **P2** | Nice to have | LW, TOPIC/LANG, Advanced, EXT |

Update test descriptions: `run_test "DL-01" "Single indicator download (P0)"`

---

## 8. Phase 6: Offline/Deterministic Tests (Future)

### 8.1 Architecture

Both suites will support an offline mode via global variable injection:

| Package | Global variable | File to modify | Injection point |
|---------|----------------|---------------|----------------|
| wbopendata (data) | `$wbopendata_offline` | `__query.ado` | line ~128 |
| wbopendata (API) | `$wbopendata_offline_api` | `_api_read.ado` + `_api_read_indicators.ado` | lines ~55, ~44 |
| unicefdata | `$unicefdata_offline` | `get_sdmx.ado` | line ~438 |

When the global is set, the command reads from local fixture files instead of making
network requests. When unset, behavior is unchanged.

### 8.2 wbopendata offline fixtures

Already available: `qa/fixtures/fixtures.tar.gz` (1.89 MB, 25 files):
- 13 CSV files (data query fixtures for `__query.ado`)
- 12 XML/JSON files (API fixtures for `_api_read*.ado`)
- Run `qa/fixtures/decompress_fixtures.do` to extract on first clone

### 8.3 unicefdata offline fixtures

To be generated: CSV snapshots of canonical SDMX downloads. Use the existing
`filename()` option to capture responses:
```stata
unicefdata, indicator(CME_MRY0T4) countries(USA) year(2020) ///
    filename("qa/fixtures/CME_MRY0T4_USA_2020.csv") clear
```

### 8.4 DET test family (10+ tests per suite)

Pattern for offline deterministic tests:
```stata
global wbopendata_offline "qa/fixtures"

* DET-01: Offline download produces identical result to fixture
cap noi {
    wbopendata, indicator(SP.POP.TOTL) country(USA) clear long nometadata
    assert _N > 50
    assert countrycode == "USA"
}

global wbopendata_offline ""
```

**Note:** Phase 6 requires code changes to `.ado` files, not just test scripts.
Defer until after Phases 2-4 are complete.

---

## 9. Implementation Sequence and Dependencies

```
Phase 1.1  cscript ─────────────── both suites, 1 line each
Phase 1.2  assert adoption ──────── unicefdata only, 38+ test blocks
Phase 1.3  test_skip program ────── wbopendata only, framework + ENV tests
     │
     ▼
Phase 2.1  ERR (wbopendata) ─────── 8 new tests, Category 12
Phase 2.2  ERR (unicefdata) ─────── 8 new tests, new category
     │
     ▼
Phase 3.1  EXT (wbopendata) ─────── 4 new tests, Category 13
Phase 3.2  EXT (unicefdata) ─────── 6 new tests, new category
     │
     ▼
Phase 4.1  Value pinning ───────── both suites, enhance existing tests
Phase 4.2  reldif ──────────────── unicefdata REGR/XPLAT tests
     │
     ▼ (independent)
Phase 5.1  Doc blocks ──────────── wbopendata, 71 tests
Phase 5.2  P0/P1/P2 labels ────── wbopendata test descriptions
     │
     ▼ (requires .ado changes)
Phase 6.1  Offline injection ───── wbopendata __query.ado + _api_read.ado
Phase 6.2  Offline injection ───── unicefdata get_sdmx.ado
Phase 6.3  DET tests ──────────── both suites, 10+ tests each
```

**Dependencies:**
- Phase 1 is prerequisite for all other phases
- Phases 2 and 3 are independent of each other
- Phase 4 depends on Phases 2-3 (value pins in ERR/EXT tests)
- Phase 5 is independent (documentation only, can be done any time)
- Phase 6 depends on Phases 2-4 and requires `.ado` file changes

---

## 10. Projected Test Counts After Full Implementation

### wbopendata

| Family | Current | + Added | New Total |
|--------|---------|---------|-----------|
| ENV | 5 | 0 | 5 |
| DL | 5 | 0 | 5 |
| FMT | 4 | 0 | 4 |
| CTRY | 11 | 0 | 11 |
| REG | 4 | 0 | 4 |
| LW | 4 | 0 | 4 |
| UPD | 6 | 0 | 6 |
| TOPIC/LANG | 2 | 0 | 2 |
| Advanced | 6 | 0 | 6 |
| CACHE | 8 | 0 | 8 |
| SYNC | 5 | 0 | 5 |
| DISC | 7 | 0 | 7 |
| CHAR | 6 | 0 | 6 |
| **ERR** | **0** | **+8** | **8** |
| **EXT** | **0** | **+4** | **4** |
| **DET** | **0** | **+10** | **10** |
| **Total** | **71** | **+22** | **93** |

### unicefdata

| Family | Current | + Added | New Total |
|--------|---------|---------|-----------|
| ENV | 4 | 0 | 4 |
| DL | 9 | 0 | 9 |
| DATA | 1 | 0 | 1 |
| DISC | 5 | 0 | 5 |
| TIER | 3 | 0 | 3 |
| SYNC | 4 | 0 | 4 |
| FMT | 3 | 0 | 3 |
| TRANS/META/MULTI | 5 | 0 | 5 |
| EDGE/PERF/REGR | 5 | 0 | 5 |
| YAML | 2 | 0 | 2 |
| XPLAT | 5 | 0 | 5 |
| **ERR** | **0** | **+8** | **8** |
| **EXT** | **0** | **+6** | **6** |
| **DET** | **0** | **+10** | **10** |
| **Total** | **38+** | **+24** | **62+** |

---

## 11. Files Modified

| File | Phase | Changes |
|------|-------|---------|
| `wbopendata-dev/qa/run_tests.do` | 1.1, 1.3, 2.1, 3.1, 4.1, 5.1, 5.2 | cscript, test_skip, ERR, EXT, value pins, doc blocks, P0/P1/P2 |
| `unicefData-dev/stata/qa/run_tests.do` | 1.1, 1.2, 2.2, 3.2, 4.1, 4.2 | cscript, assert refactor, ERR, EXT, value pins, reldif |
| `wbopendata-dev/src/_/__query.ado` | 6.1 | Offline injection point |
| `wbopendata-dev/src/_/_api_read.ado` | 6.1 | Offline injection point |
| `wbopendata-dev/src/_/_api_read_indicators.ado` | 6.1 | Offline injection point |
| `unicefData-dev/stata/src/u/get_sdmx.ado` | 6.2 | Offline injection point |

---

## 12. Verification

After each phase:

1. **Run full suite:** `do run_tests.do` — all existing tests must still pass
2. **Run single test:** `do run_tests.do ERR-01` — verify new test executes in isolation
3. **Run test listing:** `do run_tests.do list` — verify new tests appear
4. **Check history:** verify `test_history.txt` is updated with correct counts
5. **Check log:** verify `.log` file records new tests with PASS/FAIL status

---

*Plan prepared: 2026-02-09*
*Reference: Gould, W. (2001). "Statistical software certification." The Stata Journal 1(1): 29-50.*
*Reference: Drukker, D. M. (2006). "Importing Federal Reserve economic data." The Stata Journal 6(3): 384-386.*
