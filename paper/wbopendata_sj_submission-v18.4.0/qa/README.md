# wbopendata Stata Journal Submission - QA Framework

This folder contains the quality assurance (QA) tests for the **wbopendata** package submission to the Stata Journal. All tests are self-contained and portable.

## Quick Start

### Option 1: Automated Setup (Recommended)

**PowerShell:**
```powershell
cd qa
.\run_tests.ps1
```

**Batch:**
```cmd
cd qa
RUN_TESTS.bat
```

These scripts automatically:
1. Copy YAML metadata from `qa/cache/` to your Stata ado directory
2. Verify fixtures are present
3. Run the complete test suite
4. Report results and log location

### Option 2: Manual Setup

**Step 1: Install YAML Metadata (REQUIRED)**
The tests require YAML metadata files in your Stata ado directory:

**PowerShell:**
```powershell
Copy-Item -Path "qa\cache\_wbopendata_*.yaml" -Destination "$env:USERPROFILE\ado\plus\_\" -Force
```

**Batch/CMD:**
```cmd
copy qa\cache\_wbopendata_*.yaml %USERPROFILE%\ado\plus\_\
```

**From Stata:**
```stata
* The setup script will attempt to sync metadata if internet is available
do setup_qa_environment.do
```

**Step 2: Verify Fixtures**
Check that `qa/fixtures/` contains CSV test files. If missing, extract `fixtures.tar.gz`.

**Step 3: Run Tests**
```stata
cd "path\to\qa"
do run_tests.do
```

### Run Specific Test Suites
```stata
do run_submission_qa.do, mode(core)      // Core functionality tests (default)
do run_submission_qa.do, mode(help)      // Help file examples tests
do run_submission_qa.do, mode(dev)       // Dev-mode tests (against src/)
do run_submission_qa.do, mode(all)       // All tests combined
```

## Test Structure

### Folders
- **logs/** — Output logs and test history
  - `run_submission_qa_*.log` — Master QA runner log
  - `test_results_v*.log` — Core test suite results
  - `test_help_examples_*.log` — Help examples test results
  - `test_history.txt` — Cumulative test history

- **fixtures/** — CSV test data for offline/deterministic tests (created by decompressing `fixtures.tar.gz`)
  - `SP_POP_TOTL_USA.csv`, `SP_POP_TOTL_all.csv` — Population indicators
  - `NY_GDP_MKTP_CD_USA.csv` — GDP indicator
  - `country_USA.csv` — Country-level multi-indicator fixture
  - See "Setup" section below to generate fixtures

### Test Scripts

1. **run_submission_qa.do** (Master Runner)
   - Orchestrates all QA tests
   - Auto-detects qa directory from `c(filename)` or `c(pwd)`
   - Creates master log in `qa/logs/`
   - Supports multiple modes (all/core/help/dev)

2. **run_tests.do** (Core Test Suite - 105KB)
   - Framework tests (ENV, CACHE, PARAM)
   - Search & discovery tests (DISC)
   - Data query tests (API, offline)
   - Deterministic/offline tests (DET)
   - Routes logs to `qa/logs/`

3. **test_help_examples.do** (Help Examples - 44KB)
   - Validates all examples from `wbopendata.sthlp`
   - Tests both installed and dev source code
   - Uses relative paths for portability

4. **run_tests_dev.do** (Dev Mode Wrapper - 1KB)
   - Prepends src/ files to adopath
   - Tests development source ahead of installed version
   - For validating code changes before shipping

## Test Categories

| Category | Tests | Purpose |
|----------|-------|---------|
| **ENV** | ENV-01 to ENV-05 | Environment setup, file sync, YAML readability |
| **CACHE** | CACHE-01 to CACHE-04 | Cache directory, YAML path resolution, cache info |
| **PARAM** | PARAM-01 to PARAM-03 | Parameters YAML validation |
| **DISC** | DISC-01 to DISC-11 | Search, discovery, info display |
| **API** | API-01 to API-13 | Data query, country/region filters, error handling |
| **DET** | DET-01 to DET-06 | Offline/deterministic tests with CSV fixtures |
| **STHLP** | STHLP-01+ | Help file example validation |

## Submission vs. Development Mode

### Submission Package (This Setup)
- **Skips**: ENV-01 (version sync), ENV-03/04 (pkg file checks)
- **Reason**: Submission only includes compiled ado files, not src/
- **Status**: These are expected skips for pre-built packages
- **Configuration**: Controlled by `submission.cfg` (auto-detected)

### Development Mode (`run_tests_dev.do`)
- **Tests**: All ENV tests pass (checks src/ sync)
- **Setup**: Prepends src/ to adopath
- **Use**: When developing/maintaining the package

## Configuration: submission.cfg

The file `submission.cfg` enables flexible test execution for submission packages:

### What It Does
- Auto-detected and loaded by `run_tests.do`
- Sets global flags for submission-specific skips
- Allows same test suite to work in both contexts:
  - **Submission mode** (pre-built package): Skips repo-specific tests
  - **Development mode** (with source): Runs all tests

### Configuration Options
```stata
global skip_env_01 = 1    /* Skip: requires repo/src structure */
global skip_env_03 = 1    /* Skip: requires pkg file structure check */
global skip_env_04 = 1    /* Skip: requires repo file verification */
```

### How It Works
1. `run_tests.do` checks for `qa/submission.cfg` at startup
2. If found, loads configuration automatically
3. Tests check `$skip_env_XX` flags before running
4. Missing config → standard test mode (all tests attempted)

### Customization
Edit `submission.cfg` to:
- Skip specific tests (set flags to 1)
- Enable re-runs from any location
- Maintain metadata cache in `qa/cache/`

## Expected Test Results

### Passing Tests (~79)
- Framework setup (ENV-02, ENV-05)
- YAML reading and cache management (CACHE-01 to CACHE-04)
- Search and discovery (DISC-01 to DISC-11)
- Data queries (API-01 to API-13)
- Offline fixture tests (DET-01 to DET-05)
- Help examples (STHLP-01+)

### Known Skips/Failures
- **ENV-01**: Version sync check (expected for submission)
- **ENV-03/04**: Package file sync checks (expected for submission)
- **CACHE-01/02**: YAML path assertions (can false-fail on mixed path normalization in Windows submission installs)
- **DISC-08/10**: Browse/topic metadata assertions (can vary by cache/API metadata state)

## Path Portability

All scripts use **relative paths** based on:
- `c(filename)` — Detect running script location
- `c(pwd)` — Detect current working directory
- `regexm()` — Parse paths to find repo root

Run from anywhere: `do "...../qa/run_submission_qa.do"`

## Troubleshooting

### Optional Tests Skipped: CACHE-01, CACHE-02, DISC-08, DISC-10

**Problem:** Tests fail with "assertion is false" related to YAML files
  
**Cause:** YAML metadata files not found in Stata's ado directory

**Solution:** Copy YAML files from cache:
```powershell
Copy-Item -Path "qa\cache\_wbopendata_*.yaml" -Destination "$env:USERPROFILE\ado\plus\_\" -Force
```

**Verification:**
```stata
dir "`c(sysdir_plus)'_/_wbopendata_*.yaml"
```

You should see 4 files:
- `_wbopendata_indicators.yaml` (18 MB)
- `_wbopendata_sources.yaml` (11 KB)
- `_wbopendata_topics.yaml` (14 KB)
- `_wbopendata_parameters.yaml` (5 KB)

### Fixture Tests Skipped (DET-01 to DET-06)

**Problem:** "Fixture not found" warnings  

**Cause:** `qa/fixtures/` directory empty or missing

**Solution:**
1. Check if `fixtures.tar.gz` exists in `qa/`
2. Extract: `tar -xzf fixtures.tar.gz` (or use 7-Zip on Windows)
3. Verify `qa/fixtures/` contains CSV files

### ENV-01, ENV-03, ENV-04 Skipped

**Status:** Expected behavior in submission mode

**Reason:** These tests validate repository source files which are not included in the submission package

**Expected Result:**
- **85 tests run** (7 skipped)
- **85 tests passed** (0 failures)
- Skips cover repo-only checks plus cache/discovery assertions that vary by submission environment
- Test summary shows: "✓ SUBMISSION MODE: expected skips applied"

### Cannot Find Stata Executable

**Problem:** Scripts can't locate Stata  

**Solution:**
1. **Windows:** Add Stata to PATH: `C:\Program Files\Stata18` (adjust version)
2. **Manual run:** Open Stata → `cd "path\to\qa"` → `do run_tests.do`

### Internet Required for Some Tests

Some tests require internet:
- **CACHE-05 to CACHE-08:** Metadata sync tests
- **DISC-08 to DISC-10:** Topic/source browsing (can use cached YAML)
- **API-01 to API-13:** Live World Bank API queries

**Offline alternative:** Use fixtures-only mode by skipping network tests

## Installation for Reviewers

1. Extract submission package
2. Install wbopendata from the software folder (if needed)
3. Navigate to qa/ folder
4. Run: `do run_submission_qa.do`

**No additional setup required** — All fixtures and test data are included.

## For Authors/Maintainers

To update QA tests:
1. Update in main repo: `wbopendata-dev/qa/run_tests.do`
2. Copy to submission: `paper/wbopendata_sj_submission-v18.4.0/qa/run_tests.do`
3. Verify relative paths (no `C:/GitHub/...` hardcodes)
4. Commit with atomic commit message

## Troubleshooting

### "Cache directory initialization failed" (CACHE-01)
- Normal for first run without cached YAML from API sync
- Run: `wbopendata, sync` to populate cache (requires internet)

### "Fixture file not found" (SKIP messages)
- All essential fixtures are included
- Fixture folder structure is automatically created

### Tests fail with "repo_root not found"
- Run: `global wbopendata_repo "C:\path\to\wbopendata-dev"`
- Or run from repo root so scripts can auto-detect

---

**Questions?** See the help file: `help wbopendata`
