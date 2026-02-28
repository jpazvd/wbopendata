# wbopendata Stata Journal Submission - QA Framework

This folder contains the quality assurance (QA) tests for the **wbopendata** package submission to the Stata Journal. All tests are self-contained and portable.

## Quick Start

### Step 1: Setup Fixtures (First Time Only)
To enable offline/deterministic tests, decompress the fixture archive:

```stata
cd "C:\path\to\qa"
do setup_qa_environment.do
```

This script:
- Extracts `fixtures.tar.gz` to `qa/fixtures/`
- Verifies all required fixture files
- Validates installed wbopendata package
- Syncs metadata (YAML) if internet available

### Step 2: Run All Tests
```stata
do run_submission_qa.do
```

### Run Specific Test Suite
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
- **DISC-08/10**: Browse by source/topic (requires API/cache)

## Path Portability

All scripts use **relative paths** based on:
- `c(filename)` — Detect running script location
- `c(pwd)` — Detect current working directory
- `regexm()` — Parse paths to find repo root

Run from anywhere: `do "...../qa/run_submission_qa.do"`

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
