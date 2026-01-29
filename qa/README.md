# wbopendata Test Suite

**Test Suite Version:** 2.0.0  
**Compatible with:** wbopendata v17.7.1+  
**Last Updated:** January 2026

This document explains how to run the `wbopendata` test suite on any machine.

---

## Quick Start

```stata
* Navigate to the qa/ folder and run
cd "C:/path/to/wbopendata/qa"
do run_tests.do
```

---

## Test Categories

The test suite includes **44 tests** organized into 9 categories:

| Category | Tests | Description |
|----------|-------|-------------|
| **ENV-01 to ENV-04** | Environment | Repo comparison tests (optional, see below) |
| **DL-01 to DL-05** | Downloads | Single/multiple indicator and country downloads |
| **FMT-01 to FMT-03** | Format | Long format, year range, latest option |
| **CTRY-01 to CTRY-10** | Country Metadata | Match, geographic options, regions, income |
| **REG-33 to REG-51** | Regression | Bug fixes for issues #33, #45, #46, #51 |
| **LW-01 to LW-04** | Graph Metadata | Linewrap, maxlength, latest returns (v17.6+) |
| **UPD-01 to UPD-06** | Maintenance | Update query, describe, update all |
| **TOPIC-01, LANG-01** | Topics & Language | Topics download, language option |
| **PROJ/FMT-04/DESC/META/CTRY-11/DATE** | Advanced | Projection, nobasic, describe, nometadata, adminregion, date range |

> **See also:** [Test Protocol](test_protocol.md) for detailed test descriptions | [Testing Guide](TESTING_GUIDE.md) for best practices

---

## Running the Tests

### Option 1: Auto-Detection (Recommended)

If you run from the `qa/` folder inside the repository, the script auto-detects the repo path:

```stata
cd "C:/GitHub/wbopendata/qa"
do run_tests.do
```

**Result:** All 44 tests run, including ENV-01 to ENV-04.

### Option 2: Configure Repo Path Manually

Set the global before running:

```stata
global wbopendata_repo "D:/Projects/wbopendata"
do run_tests.do
```

**Result:** All 44 tests run, including ENV-01 to ENV-04.

### Option 3: Skip Repo-Comparison Tests

If you don't have access to the repository source (e.g., installed via SSC only):

```stata
do run_tests.do norepo
```

**Result:** 40 core tests run; ENV-01 to ENV-04 are skipped.

### Option 4: No Configuration

If neither auto-detection works nor a global is set:

```stata
do run_tests.do
```

**Result:** 40 core tests run; ENV-01 to ENV-04 are skipped with informational message.

---

## Repo-Comparison Tests (ENV-01 to ENV-04)

These tests verify that the installed version matches the repository source:

| Test | Purpose |
|------|---------|
| **ENV-01** | `net install` from repo works |
| **ENV-02** | Package file (`wbopendata.pkg`) exists |
| **ENV-03** | TOC file (`stata.toc`) exists |
| **ENV-04** | `net describe` from repo works |

### When Are These Tests Run?

| Condition | ENV Tests |
|-----------|-----------|
| Repo path auto-detected from `qa/` folder | ✅ Run |
| `global wbopendata_repo` is set | ✅ Run |
| Neither configured | ⏭️ Skipped |
| `norepo` argument passed | ⏭️ Skipped |

### Why Skip?

These tests require access to the local repository. Users who:
- Installed via `ssc install wbopendata`
- Don't have the GitHub repo cloned
- Are running on CI without repo access

...can still run all 40 core functionality tests by using `norepo`.

---

## Configuration Reference

### Global Variables

| Global | Purpose | Example |
|--------|---------|---------|
| `wbopendata_repo` | Path to repo root | `global wbopendata_repo "C:/GitHub/wbopendata"` |

### Command-Line Arguments

| Argument | Effect |
|----------|--------|
| `norepo` | Skip ENV-01 to ENV-04 repo-comparison tests |
| `TEST_ID` | Run single test (e.g., `do run_tests.do IND-03`) |

### Auto-Detection Logic

The script attempts to detect the repo path automatically:

1. Check if `global wbopendata_repo` is already set → use it
2. Check if current directory ends with `/qa` or `\qa`:
   - If yes, parent directory is the repo root
3. If neither works, repo tests are skipped gracefully

---

## Output Files

| File | Location | Description |
|------|----------|-------------|
| `test_results_v*.log` | `qa/` folder | Timestamped test log |
| `run_tests.log` | `qa/` folder | Canonical copy of latest run |
| `test_history.txt` | `qa/` folder | Append-only history of all runs |

**Note:** Log files are only written if `$qadir` is configured (automatic when running from `qa/` folder).

---

## Troubleshooting

### "ENV tests skipped - repo not configured"

**Cause:** The script couldn't find the repository path.

**Solutions:**
1. Run from the `qa/` folder: `cd "path/to/wbopendata/qa"`
2. Set the global: `global wbopendata_repo "path/to/repo"`
3. Accept the skip if you don't need repo tests: `do run_tests.do norepo`

### "Could not copy log to qadir"

**Cause:** The `qa/` folder path wasn't detected.

**Solution:** Run from within the `qa/` folder, or the log will only be saved with the timestamped name.

### Test fails with network error

**Cause:** World Bank API is temporarily unavailable.

**Solution:** Wait a few minutes and retry. The API occasionally has brief outages.

---

## Example Session

```stata
. cd "C:/GitHub/wbopendata/qa"
C:\GitHub\wbopendata\qa

. do run_tests.do

================================================================================
 wbopendata Test Suite v17.7.2
================================================================================
 Date: 28 Jan 2026  Time: 14:30:00
 Stata: 17.0 MP
================================================================================

 PATH CONFIGURATION
 ------------------
 Auto-detected repo from qa/ folder
 Repo root: C:/GitHub/wbopendata
 QA directory: C:/GitHub/wbopendata/qa

================================================================================
 CATEGORY 1: BASIC DOWNLOADS
================================================================================
 [DL-01] PASS: Single indicator download
 [DL-02] PASS: Single country download
 ...

================================================================================
 CATEGORY 9: ENVIRONMENT & VERSION TESTS
================================================================================
 [ENV-01] PASS: net install from repo works
 [ENV-02] PASS: Package file exists
 [ENV-03] PASS: TOC file exists
 [ENV-04] PASS: net describe from repo works

================================================================================
 TEST SUMMARY
================================================================================
 Tests run:    44
 Tests passed: 44
 Tests failed: 0
 
 Result: ALL TESTS PASSED
================================================================================
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | Jan 2026 | Independent test suite versioning; generic paths; `norepo` option; auto-detection |
| 1.0.0 | Jan 2026 | Initial structured test suite (44 tests) |

---

## Related Documentation

| Document | Description |
|----------|-------------|
| [Test Protocol](test_protocol.md) | Detailed test descriptions and expected results |
| [Testing Guide](TESTING_GUIDE.md) | Best practices for Stata testing |
| [run_tests.do](run_tests.do) | The automated test script |
| [../README.md](../README.md) | Main wbopendata documentation |
| [../doc/FAQ.md](../doc/FAQ.md) | Frequently asked questions |
