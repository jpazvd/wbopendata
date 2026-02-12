# Phase 6: Offline/Deterministic Testing & Scalable CI/CD Discussion

## Overview

Phase 6 of the Unified QA Improvement Plan implements **offline/deterministic tests** (DET family) for both `wbopendata` and `unicefdata`. These tests run entirely from local CSV fixtures, requiring no network access. This addresses a key gap identified in our Gould (2001) and Drukker (2006) analysis: the inability to verify program correctness without depending on a live, mutable API.

**Date:** February 2026
**Branch:** feat/pr28-navigation-structure
**Plan reference:** [UNIFIED_QA_IMPROVEMENT_PLAN.md](UNIFIED_QA_IMPROVEMENT_PLAN.md)

---

## 1. What Was Implemented

### 1.1 wbopendata: `offline()` Option

Five `.ado` files were modified to support an `offline(string)` option that passes a fixture directory path through the entire call chain via Stata locals (not globals):

```
wbopendata.ado  →  offline("qa/fixtures")
  ├─ _query.ado          → reads data CSVs from offline/
  ├─ _query_metadata.ado → passes offline/ to _api_read
  │    └─ _api_read.ado  → reads XML from offline/api/
  └─ _api_read_indicators.ado → reads XML from offline/api/
```

#### `_query.ado` — Data CSV Download
- **Option:** `offline(string)` added to syntax
- **Fixture naming convention:** `{INDICATOR_underscored}_{country}.csv`
  - Example: `SP.POP.TOTL` + country `USA` → `SP_POP_TOTL_USA.csv`
  - Example: `SP.POP.TOTL` + all countries → `SP_POP_TOTL_all.csv`
  - Dots replaced with underscores, semicolons replaced with underscores
- **Behavior:** When `offline()` is non-empty, `copy` reads from the fixture directory instead of the World Bank API. The rest of the import pipeline (CSV parsing, variable creation, metadata) runs identically.

```stata
* User calls:
wbopendata, indicator(SP.POP.TOTL) country(USA) clear nometadata long offline("qa/fixtures")

* Inside _query.ado:
if ("`offline'" != "") {
    local _ind_name = subinstr("`indicator1'", ".", "_", .)
    local _cty_name = subinstr("`country2'", ";", "_", .)
    local _fixture_file "`offline'/`_ind_name'_`_cty_name'.csv"
    ...
}
```

#### `_api_read.ado` — XML Metadata Download
- **Option:** `offline(string)` added to syntax
- **Fixture path:** `{offline}/api/api_read_response.xml`

#### `_api_read_indicators.ado` — Paginated Indicator List Download
- **Option:** `offline(string)` added to syntax
- **Fixture paths:** `{offline}/api/indicators_page{1,2,3}.xml`

#### `_query_metadata.ado` — Metadata Coordinator
- **Option:** `offline(string)` added to syntax
- **Passes** `offline()` through to `_api_read`

### 1.2 unicefdata: No Code Changes Needed

`unicefdata.ado` already has a `fromfile()` option (line ~1260) that loads data from a local CSV file and bypasses the SDMX API entirely. DET tests use this existing capability directly:

```stata
unicefdata, indicator(CME_MRY0T4) fromfile("fixtures/CME_MRY0T4_USA_2020_pinning.csv") clear
```

### 1.3 DET Test Suites

#### wbopendata: 6 DET tests (Category 14)

| Test | Description | Fixture |
|------|------------|---------|
| DET-01 | Single indicator, single country | `SP_POP_TOTL_USA.csv` |
| DET-02 | Single indicator, all countries | `SP_POP_TOTL_all.csv` |
| DET-03 | Value pinning (USA pop 2020) | `SP_POP_TOTL_USA.csv` |
| DET-04 | Different indicator (GDP) | `NY_GDP_MKTP_CD_USA.csv` |
| DET-05 | Country-only query | `country_USA.csv` |
| DET-06 | Missing fixture error handling | (none — tests error path) |

#### unicefdata: 6 DET tests (Category 9)

| Test | Description | Fixture |
|------|------------|---------|
| DET-01 | Single indicator via fromfile | `CME_MRY0T4_all_2020.csv` |
| DET-02 | Value pinning (U5MR USA 2020) | `CME_MRY0T4_USA_2020_pinning.csv` |
| DET-03 | Multi-country fixture | `CME_MRY0T4_USA_BRA_2020.csv` |
| DET-04 | Time series fixture | `CME_MRY0T4_USA_2015_2023.csv` |
| DET-05 | Disaggregation by sex | `CME_MRY0T4_BRA_sex_2020.csv` |
| DET-06 | Missing fixture error | (none — tests error path) |

---

## 2. Design Rationale

### Why Offline Tests Matter

Gould (2001) emphasizes that certification tests must be **reproducible**: running the same test twice should produce the same result. When tests depend on a live API:

1. **Data changes over time** — The World Bank and UNICEF revise historical data, add new countries, and deprecate indicators. A test that passes today may fail tomorrow with no code change.
2. **Network failures cause false negatives** — A timeout or DNS failure looks like a program bug to the test suite.
3. **Rate limiting and availability** — Running 80+ tests against a live API puts strain on the endpoint and may trigger rate limits.
4. **CI/CD environments lack network** — Many CI runners (GitHub Actions with restricted networking, air-gapped environments) cannot reach external APIs.

Offline fixtures solve all four problems. The fixture files are version-controlled snapshots of real API responses, frozen at a known point in time.

### Injection vs. `fromfile()` Approach

We used two different strategies for the two packages:

| Aspect | wbopendata (injection) | unicefdata (fromfile) |
|--------|----------------------|----------------------|
| Code changes | 3 `.ado` files modified | None |
| Control mechanism | `$wbopendata_offline` global | `fromfile()` option |
| Granularity | Directory-level (all queries redirect) | File-level (per-call) |
| Transparency | Original code path preserved in `else` | Built-in feature |
| Maintenance | Must keep fixture names in sync | Self-documenting |

The `fromfile()` approach (unicefdata) is cleaner — it was designed into the program from the start. The global-variable injection (wbopendata) is a pragmatic retrofit that avoids changing the user-facing API.

---

## 3. Discussion: Scalable CI/CD Approaches

During Phase 6 planning, we explored the question: *Can we create a wrapper `.ado` file combined with YAML to facilitate deployment and maintenance of CI/CD pipelines?*

### 3.1 YAML-Driven Test Framework (Proposed and Critiqued)

**Concept:** Define tests declaratively in YAML:

```yaml
tests:
  - id: DL-01
    command: "wbopendata, indicator(SP.POP.TOTL) country(USA) clear nometadata long"
    assertions:
      - "_N > 50"
      - "countrycode == 'USA'"
    expected_vars: [countrycode, year, sp_pop_totl]
    value_pins:
      - filter: "countrycode == 'USA' & year == 2020"
        variable: sp_pop_totl
        bounds: [300000000, 400000000]
```

A wrapper `.ado` would parse the YAML, execute each test, and report results.

**Strengths of this approach:**
- **Declarative:** Non-programmers can add tests by editing YAML
- **Machine-readable:** CI/CD tools can parse results, generate badges, track trends
- **Consistent structure:** Every test follows the same template
- **Portable:** Same YAML works across different CI runners

**Weaknesses (why we did NOT implement this):**

1. **Stata's YAML parsing is slow.** The 17 MB indicators YAML takes ~9 seconds to parse. Even a small test-definition YAML would add overhead to every test run. Stata has no native YAML parser — we'd need a custom line-by-line reader.

2. **Complex tests don't fit templates.** Tests like CACHE-01 (which sets up a cache, runs a query, checks the cache file exists, then cleans up) or REGR-01 (which compares cross-platform baselines with `reldif`) have multi-step logic that doesn't reduce to `command + assertions`. Forcing them into YAML either limits what you can test or makes the YAML as complex as the Stata code.

3. **Debugging is worse.** When a YAML-driven test fails, the error message points to the wrapper program, not the test definition. The developer must mentally map YAML line → Stata command → actual failure. With native Stata tests, the error points directly at the assertion that failed.

4. **Two sources of truth.** If both YAML definitions and Stata test files exist, they can drift apart. Which is authoritative? Maintenance doubles.

5. **Escape-character hell.** Stata's compound quoting (`` `"..."' ``), combined with YAML's own quoting rules, creates a fragile parsing layer. Special characters in indicator names or descriptions would need double-escaping.

### 3.2 Recommended Scalable Approach: YAML as Registry + Stata Logic + Python CI

Instead of putting test *logic* in YAML, use YAML only as a **test registry** (metadata):

```yaml
# test_registry.yaml
suites:
  wbopendata:
    path: "wbopendata-dev/qa/run_tests.do"
    stata_version: 17
    families:
      - {id: ENV, count: 5, priority: P0, network: false}
      - {id: DL, count: 5, priority: P0, network: true}
      - {id: ERR, count: 8, priority: P1, network: true}
      - {id: EXT, count: 4, priority: P2, network: true}
      - {id: DET, count: 6, priority: P0, network: false}
    fixtures: "qa/fixtures/"

  unicefdata:
    path: "unicefData-dev/stata/qa/run_tests.do"
    stata_version: 17
    families:
      - {id: ENV, count: 4, priority: P0, network: false}
      - {id: DL, count: 9, priority: P0, network: true}
      - {id: DET, count: 6, priority: P0, network: false}
    fixtures: "stata/qa/fixtures/"
```

**Architecture:**

```
┌─────────────────────────────────────────────────┐
│  test_registry.yaml (metadata only)             │
│  - Suite paths, test families, priorities        │
│  - Network requirements, fixture locations       │
│  - Expected test counts for drift detection      │
└──────────────────────┬──────────────────────────┘
                       │ read by
                       ▼
┌─────────────────────────────────────────────────┐
│  ci_runner.py (Python CI harness)               │
│  - Parses YAML registry                         │
│  - Selects tests by priority / network avail    │
│  - Launches Stata in batch mode                  │
│  - Parses Stata log output                       │
│  - Generates JUnit XML / GitHub annotations      │
│  - Tracks test history / trends                  │
└──────────────────────┬──────────────────────────┘
                       │ executes
                       ▼
┌─────────────────────────────────────────────────┐
│  run_tests.do (Stata test logic)                │
│  - All test logic stays in native Stata          │
│  - assert, cap noi, test_pass/test_fail          │
│  - Full debugging with trace/breakpoints         │
└─────────────────────────────────────────────────┘
```

**Benefits:**
- **Test logic stays in Stata** — debug with `set trace on`, read naturally
- **Python handles CI complexity** — log parsing, JUnit XML, parallel execution
- **YAML is lightweight** — only metadata, no quoting issues, fast to parse
- **Priority-based selection** — CI runs P0 (offline) tests on every push, P1 (network) nightly
- **Drift detection** — Python checks that expected test counts match actual `list` output

**Example CI workflow (GitHub Actions):**

```yaml
# .github/workflows/stata-tests.yml
jobs:
  offline-tests:
    runs-on: self-hosted  # needs Stata license
    steps:
      - uses: actions/checkout@v4
      - run: python ci_runner.py --suite wbopendata --priority P0
      - run: python ci_runner.py --suite unicefdata --priority P0

  network-tests:
    runs-on: self-hosted
    if: github.event_name == 'schedule'  # nightly only
    steps:
      - uses: actions/checkout@v4
      - run: python ci_runner.py --suite wbopendata --priority P0,P1,P2
```

### 3.3 Migration Path

1. **Now (Phase 6):** DET tests work with manual `do run_tests.do` execution
2. **Next:** Create `ci_runner.py` that launches Stata batch mode and parses logs
3. **Then:** Add `test_registry.yaml` for multi-suite orchestration
4. **Later:** GitHub Actions workflow with self-hosted runner (Stata license required)

---

## 4. Files Modified in Phase 6

| File | Change |
|------|--------|
| `wbopendata-dev/src/_/_query.ado` | Added `$wbopendata_offline` injection (lines 130-162) |
| `wbopendata-dev/src/_/_api_read.ado` | Added `$wbopendata_offline_api` injection (lines 62-74) |
| `wbopendata-dev/src/_/_api_read_indicators.ado` | Added `$wbopendata_offline_api` injection (lines 52-82) |
| `wbopendata-dev/qa/run_tests.do` | Added Category 14: DET-01 to DET-06 (6 tests) |
| `unicefData-dev/stata/qa/run_tests.do` | Added Category 9: DET-01 to DET-06 (6 tests) |
| `wbopendata-dev/paper/docs/phase6_offline_testing.md` | This document |

**No changes needed:**
| File | Reason |
|------|--------|
| `unicefData-dev/stata/src/u/unicefdata.ado` | Already has `fromfile()` option |
| `unicefData-dev/stata/src/g/get_sdmx.ado` | Bypassed by `fromfile()` |

---

## 5. Test Counts After Phase 6

| Suite | Before | + DET | Total |
|-------|--------|-------|-------|
| wbopendata | 83 | +6 | **89** |
| unicefdata | 52+ | +6 | **58+** |

---

## 6. Running DET Tests

### wbopendata
```stata
cd "path/to/wbopendata-dev/qa"
* Run all tests (DET tests auto-skip if fixtures missing)
do run_tests.do

* Run only DET tests
do run_tests.do DET-01
do run_tests.do DET-02
* ... etc.
```

### unicefdata
```stata
cd "path/to/unicefData-dev/stata/qa"
* Run all tests
do run_tests.do

* Run only DET tests
do run_tests.do DET-01
```

### Fixture Setup
wbopendata fixtures are stored in `qa/fixtures/` and compressed in `qa/fixtures/fixtures.tar.gz`. On first clone:
```stata
cd "path/to/wbopendata-dev/qa/fixtures"
do decompress_fixtures.do
```

unicefdata fixtures are stored directly in `stata/qa/fixtures/` (no compression needed).

---

## 7. Relationship to Gould (2001)

Phase 6 directly addresses Gould's principle that certification tests must be **reproducible across time and environments**. The DET family complements the existing ERR (error conditions) and EXT (extreme cases) families added in Phases 2-3:

| Gould Principle | ERR (Phase 2) | EXT (Phase 3) | DET (Phase 6) |
|----------------|---------------|---------------|---------------|
| "Test that code fails when it should" | ✓ | | |
| "Test extreme cases" | | ✓ | |
| "Tests must be reproducible" | | | ✓ |
| "Never delete, always add" | ✓ | ✓ | ✓ |

The DET tests are the first tests in either suite that can run in a CI/CD pipeline without network access, making them the foundation for automated regression testing.
