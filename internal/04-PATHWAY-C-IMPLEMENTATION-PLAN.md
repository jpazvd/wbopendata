# Pathway C Implementation Plan: Full Auto-Sync Discovery System

**Date:** January 20, 2026  
**Project:** wbopendata-dev  
**Scope:** Detailed implementation plan for Pathway C (Full Auto-Sync)  
**Status:** Planning Phase  
**Timeline:** 12-14 weeks (extended from initial estimate)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Overview](#architecture-overview)
3. [Phase Breakdown](#phase-breakdown)
4. [Automated Update Pipeline](#automated-update-pipeline)
5. [Caching & Sync Mechanism](#caching--sync-mechanism)
6. [Version Management](#version-management)
7. [Testing Strategy](#testing-strategy)
8. [Deployment & Rollout](#deployment--rollout)
9. [Maintenance & Operations](#maintenance--operations)

---

## Executive Summary

**Pathway C** delivers a fully automated metadata synchronization system that keeps wbopendata's indicator metadata always up-to-date without manual intervention.

### What Makes Pathway C Different?

| Feature | Pathway B | Pathway C |
|---------|-----------|-----------|
| YAML metadata | ✅ Manual updates | ✅ **Automated updates** |
| Discovery commands | ✅ Yes | ✅ Yes |
| Sync mechanism | ❌ None | ✅ **Automated (monthly/quarterly)** |
| Version tracking | ✅ Manual | ✅ **Automated git tags** |
| Caching | In-memory only | ✅ **Persistent + in-memory** |
| Update notification | ❌ | ✅ **User alerts** |
| Metadata freshness | Stale until manual update | ✅ **Always current** |
| Python infrastructure | ❌ | ✅ **Required** |

### Key Deliverables

1. **All Pathway B features** (YAML schema, discovery commands, search/info)
2. **Python update pipeline** (fetches WB API → generates YAML → commits)
3. **GitHub Actions automation** (scheduled runs, CI/CD integration)
4. **Caching system** (persistent local cache + version checking)
5. **Sync command** (`wbopendata, sync` for manual triggers)
6. **Version management** (semantic versioning for metadata)
7. **User notifications** (alerts when updates available)

---

## Architecture Overview

### Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    METADATA UPDATE PIPELINE (Python)                 │
│                    Runs: Monthly (scheduled) or On-Demand            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  [1] Fetch WB API                                                   │
│      ├─ GET /v2/indicators?per_page=20000 (bulk)                   │
│      ├─ GET /v2/sources                                             │
│      └─ GET /v2/topics                                              │
│                                                                       │
│  [2] Transform & Normalize                                          │
│      ├─ Parse JSON responses                                        │
│      ├─ Map to YAML schema v2.0.0                                   │
│      ├─ Validate all required fields                                │
│      └─ Handle encoding/special characters                          │
│                                                                       │
│  [3] Generate YAML Files                                            │
│      ├─ _wbopendata_indicators.yaml (500 KB)                        │
│      ├─ _wbopendata_sources.yaml (50 KB)                            │
│      ├─ _wbopendata_topics.yaml (20 KB)                             │
│      └─ Add metadata block (version, checksum, timestamp)           │
│                                                                       │
│  [4] Quality Checks                                                 │
│      ├─ Schema validation (YAML structure)                          │
│      ├─ Data integrity (no duplicates, all fields present)          │
│      ├─ Diff analysis (what changed vs previous version)            │
│      └─ Size checks (file not corrupted)                            │
│                                                                       │
│  [5] Git Version Control                                            │
│      ├─ git add _wbopendata_*.yaml                                  │
│      ├─ git commit -m "Update metadata: v2.1.0 (2026-02-01)"        │
│      ├─ git tag metadata-v2.1.0                                     │
│      └─ git push origin metadata-v2.1.0                             │
│                                                                       │
│  [6] Publish to SSC (if needed)                                     │
│      └─ Update wbopendata package on SSC with new YAML              │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                        METADATA DISTRIBUTION                         │
│                     (GitHub Release + SSC Package)                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  GitHub Repository                                                   │
│  ├─ src/_/_wbopendata_indicators.yaml (tagged v2.1.0)               │
│  ├─ src/_/_wbopendata_sources.yaml                                  │
│  └─ src/_/_wbopendata_topics.yaml                                   │
│                                                                       │
│  SSC Package (wbopendata)                                           │
│  └─ Contains latest YAML files                                      │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
                                    ↓
┌─────────────────────────────────────────────────────────────────────┐
│                    USER'S LOCAL ENVIRONMENT (Stata)                  │
│                                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  [User runs discovery command]                                      │
│  wbopendata, search("education")                                    │
│         ↓                                                            │
│  [1] Check Local Cache                                              │
│      ├─ Location: C:\Users\{user}\ado\personal\wbopendata\cache\   │
│      ├─ Check version: metadata_version.txt                         │
│      └─ If cache miss or old → proceed to [2]                       │
│                                                                       │
│  [2] Version Check (if enabled)                                     │
│      ├─ Query GitHub API: latest release tag                        │
│      ├─ Compare local version vs remote version                     │
│      └─ If remote newer → download new YAML                         │
│                                                                       │
│  [3] Load Metadata                                                  │
│      ├─ Read YAML from cache (or package install)                   │
│      ├─ Parse into Stata memory                                     │
│      └─ Execute search/info command                                 │
│                                                                       │
│  [User can manually sync]                                           │
│  wbopendata, sync                                                   │
│      ├─ Force check remote version                                  │
│      ├─ Download if newer available                                 │
│      └─ Display: "Metadata updated to v2.1.0"                        │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase Breakdown

### Phase 1: Foundation (Pathway B) - Weeks 1-8

**Goal:** Complete all Pathway B deliverables first

**Deliverables:**
- [x] YAML schema designed
- [x] 3 YAML files generated (manual process)
- [x] `_yaml_read.ado` implemented
- [x] `_wbopendata_search.ado` implemented
- [x] `_wbopendata_info.ado` implemented
- [x] Main command integration
- [x] Testing & documentation

**Status:** ✅ Completed in Pathway B phase

---

### Phase 2: Python Automation Pipeline - Weeks 9-10

**Goal:** Build automated YAML generation pipeline

#### Week 9: Core Pipeline

**Tasks:**

1. **Setup Python Environment**
   ```bash
   # Create virtual environment
   python -m venv .venv-metadata
   .venv-metadata\Scripts\activate
   pip install requests pyyaml jsonschema gitpython
   ```

2. **Create `update_metadata.py`** (main script)
   - WB API client
   - JSON → YAML transformer
   - Schema validator
   - Git integration

3. **Create `config_update.yaml`** (pipeline configuration)
   ```yaml
   # Pipeline settings
   wb_api:
     base_url: "https://api.worldbank.org/v2"
     timeout: 30
     retry_count: 3
   
   yaml_output:
     indicators_file: "src/_/_wbopendata_indicators.yaml"
     sources_file: "src/_/_wbopendata_sources.yaml"
     topics_file: "src/_/_wbopendata_topics.yaml"
   
   metadata:
     schema_version: "2.0.0"
     compression: "none"
   
   git:
     auto_commit: true
     tag_prefix: "metadata-v"
     commit_message_template: "Update metadata: {version} ({date})"
   ```

4. **Implement WB API Client**
   - Bulk fetch indicators
   - Handle pagination
   - Error handling & retries
   - Rate limiting

#### Week 10: Validation & Git Integration

**Tasks:**

1. **Implement YAML Generator**
   - JSON normalization
   - YAML formatting
   - Metadata block generation
   - Checksum calculation

2. **Schema Validation**
   - JSON Schema definition for YAML structure
   - Automated validation
   - Field presence checks
   - Data type validation

3. **Git Integration**
   - Auto-commit changes
   - Semantic versioning
   - Tag creation
   - Push to remote

4. **Diff Analysis**
   - Compare old vs new YAML
   - Generate change summary
   - Detect breaking changes

**Deliverables:**
- [x] `update_metadata.py` (complete)
- [x] `wb_api_client.py` (API wrapper)
- [x] `yaml_generator.py` (transformation)
- [x] `schema_validator.py` (validation)
- [x] `git_manager.py` (version control)
- [x] `config_update.yaml` (settings)

---

### Phase 3: GitHub Actions & CI/CD - Weeks 11

**Goal:** Automate pipeline execution via GitHub Actions

#### Workflow Design

**File:** `.github/workflows/update-metadata.yml`

```yaml
name: Update WB Metadata

on:
  schedule:
    # Run on 1st day of every month at 00:00 UTC
    - cron: '0 0 1 * *'
  
  workflow_dispatch:
    # Allow manual trigger
    inputs:
      force_update:
        description: 'Force update even if no changes'
        required: false
        type: boolean
        default: false

jobs:
  update-metadata:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for version comparison
      
      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements-metadata.txt
      
      - name: Fetch WB API metadata
        run: python scripts/update_metadata.py --fetch
        env:
          WB_API_KEY: ${{ secrets.WB_API_KEY }}
      
      - name: Generate YAML files
        run: python scripts/update_metadata.py --generate
      
      - name: Validate YAML schema
        run: python scripts/update_metadata.py --validate
      
      - name: Run tests
        run: pytest tests/test_metadata.py
      
      - name: Check for changes
        id: changes
        run: |
          if git diff --quiet src/_/_wbopendata_*.yaml; then
            echo "has_changes=false" >> $GITHUB_OUTPUT
          else
            echo "has_changes=true" >> $GITHUB_OUTPUT
          fi
      
      - name: Commit and tag
        if: steps.changes.outputs.has_changes == 'true'
        run: python scripts/update_metadata.py --commit
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
      
      - name: Create GitHub Release
        if: steps.changes.outputs.has_changes == 'true'
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ steps.changes.outputs.version_tag }}
          release_name: Metadata Update ${{ steps.changes.outputs.version }}
          body_path: METADATA_CHANGELOG.md
      
      - name: Notify on failure
        if: failure()
        uses: actions/github-script@v7
        with:
          script: |
            github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: 'Metadata update failed',
              body: 'Automated metadata update workflow failed. Check logs.',
              labels: ['automation', 'metadata']
            })
```

**Tasks for Week 11:**
1. Create GitHub Actions workflow
2. Setup secrets (WB_API_KEY if needed)
3. Test manual workflow trigger
4. Configure notifications
5. Document workflow in README

**Deliverables:**
- [x] `.github/workflows/update-metadata.yml`
- [x] Workflow testing & validation
- [x] Documentation

---

### Phase 4: Caching & Sync Mechanism - Week 12

**Goal:** Implement persistent caching and sync commands in Stata

#### 4.1 Cache Directory Structure

```
C:\Users\{user}\ado\personal\wbopendata\cache\
├── metadata_version.txt              (current version: v2.1.0)
├── _wbopendata_indicators.yaml       (cached YAML)
├── _wbopendata_sources.yaml          (cached YAML)
├── _wbopendata_topics.yaml           (cached YAML)
└── cache_timestamp.txt               (last updated: 2026-02-01)
```

#### 4.2 Implement `_wbopendata_cache.ado`

**Purpose:** Manage local YAML cache

```stata
program def _wbopendata_cache, rclass
  syntax [, CHECKversion UPDAte FORCe CLEAR]
  
  * Define cache directory
  local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
  
  * Create cache directory if doesn't exist
  capture mkdir "`cache_dir'"
  
  if ("`checkversion'" != "") {
    * Check local vs remote version
    _wbopendata_check_version
    return local local_version = r(local_version)
    return local remote_version = r(remote_version)
    return scalar needs_update = r(needs_update)
  }
  
  if ("`update'" != "" | "`force'" != "") {
    * Download latest YAML from GitHub
    _wbopendata_download_yaml, `force'
  }
  
  if ("`clear'" != "") {
    * Clear cache
    capture shell rmdir /s /q "`cache_dir'"
    display as text "Cache cleared"
  }
  
  * Return cache status
  return local cache_dir = "`cache_dir'"
  return scalar cache_exists = file_exists("`cache_dir'metadata_version.txt")
  
end
```

#### 4.3 Implement `_wbopendata_check_version.ado`

**Purpose:** Check GitHub for latest metadata version

```stata
program def _wbopendata_check_version, rclass
  
  * Read local version
  local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
  local version_file = "`cache_dir'metadata_version.txt"
  
  if file_exists("`version_file'") {
    file open vf using "`version_file'", read
    file read vf local_ver
    file close vf
  }
  else {
    local local_ver = "0.0.0"
  }
  
  * Query GitHub API for latest release
  * (Use shell curl or Stata's copy command)
  capture shell curl -s "https://api.github.com/repos/jpazvd/wbopendata/releases/latest" > temp_version.json
  
  if _rc == 0 {
    * Parse JSON to extract version tag
    file open jf using "temp_version.json", read
    file read jf line
    * Extract tag_name field (metadata-v2.1.0)
    local remote_ver = regexs(1) if regexm("`line'", "metadata-v([0-9.]+)")
    file close jf
    erase "temp_version.json"
  }
  else {
    * GitHub API failed, assume no update
    local remote_ver = "`local_ver'"
  }
  
  * Compare versions
  local needs_update = ("`local_ver'" != "`remote_ver'")
  
  return local local_version = "`local_ver'"
  return local remote_version = "`remote_ver'"
  return scalar needs_update = `needs_update'
  
end
```

#### 4.4 Implement `_wbopendata_download_yaml.ado`

**Purpose:** Download latest YAML files from GitHub

```stata
program def _wbopendata_download_yaml
  syntax [, FORCe]
  
  * Check if update needed (unless force)
  if ("`force'" == "") {
    _wbopendata_check_version
    if (r(needs_update) == 0) {
      display as text "Metadata is up-to-date (v" r(local_version) ")"
      exit 0
    }
  }
  
  local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
  local base_url = "https://raw.githubusercontent.com/jpazvd/wbopendata"
  local tag = "metadata-v" + r(remote_version)
  
  * Download 3 YAML files
  foreach file in indicators sources topics {
    local remote = "`base_url'/`tag'/src/_/_wbopendata_`file'.yaml"
    local local = "`cache_dir'_wbopendata_`file'.yaml"
    
    display as text "Downloading `file'.yaml..."
    capture copy "`remote'" "`local'", replace
    
    if _rc != 0 {
      display as error "Failed to download `file'.yaml"
      error 603
    }
  }
  
  * Update version file
  file open vf using "`cache_dir'metadata_version.txt", write replace
  file write vf r(remote_version)
  file close vf
  
  * Update timestamp
  file open tf using "`cache_dir'cache_timestamp.txt", write replace
  file write tf "`c(current_date)' `c(current_time)'"
  file close tf
  
  display as result "Metadata updated to v" r(remote_version)
  
end
```

#### 4.5 Integrate Caching into Discovery Commands

**Update `_wbopendata_search.ado`:**

```stata
program def _wbopendata_search, rclass
  syntax anything(name=keyword), [limit(integer 20) source(string)]
  
  * Check cache and load YAML
  _wbopendata_cache, checkversion
  
  * Use cached YAML if available, otherwise use package install
  local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
  if file_exists("`cache_dir'_wbopendata_indicators.yaml") {
    local yaml_path = "`cache_dir'_wbopendata_indicators.yaml"
  }
  else {
    local yaml_path = c(sysdir_plus) + "_/_wbopendata_indicators.yaml"
  }
  
  * Load and search (rest of implementation)
  yaml_read using "`yaml_path'", replace
  ...
end
```

**Tasks for Week 12:**
1. Implement all caching helpers
2. Integrate with existing discovery commands
3. Add cache status to return values
4. Test cache hit/miss scenarios
5. Document caching behavior

**Deliverables:**
- [x] `_wbopendata_cache.ado`
- [x] `_wbopendata_check_version.ado`
- [x] `_wbopendata_download_yaml.ado`
- [x] Updated search/info commands
- [x] Cache testing suite

---

### Phase 5: Sync Command & User Features - Week 13

**Goal:** Add user-facing sync commands and notifications

#### 5.1 Implement `wbopendata, sync` Subcommand

**Add to main `wbopendata.ado` syntax:**

```stata
syntax [, 
  ... existing options ...
  SYNC                    // NEW: check and sync metadata
  SYNCForce              // NEW: force sync even if up-to-date
  CHECKUpdate            // NEW: check for updates without syncing
  CLEARCACHE             // NEW: clear local cache
  ... other options ...
]
```

**Routing logic:**

```stata
* Handle sync subcommands
if ("`sync'" != "" | "`syncforce'" != "") {
  if ("`syncforce'" != "") {
    _wbopendata_cache, update force
  }
  else {
    _wbopendata_cache, checkversion
    if (r(needs_update)) {
      display as text "Update available: v" r(remote_version)
      display as text "Downloading..."
      _wbopendata_cache, update
    }
    else {
      display as text "Metadata is up-to-date (v" r(local_version) ")"
    }
  }
  exit 0
}

if ("`checkupdate'" != "") {
  _wbopendata_cache, checkversion
  if (r(needs_update)) {
    display as result "Update available!"
    display as text "  Local version:  v" r(local_version)
    display as text "  Remote version: v" r(remote_version)
    display as text ""
    display as text "Run {cmd:wbopendata, sync} to update"
  }
  else {
    display as text "Metadata is up-to-date (v" r(local_version) ")"
  }
  exit 0
}

if ("`clearcache'" != "") {
  _wbopendata_cache, clear
  exit 0
}
```

#### 5.2 Auto-Check on First Use (Optional)

**Add to discovery commands:**

```stata
* At start of _wbopendata_search.ado or _wbopendata_info.ado
if ("`c(WBOD_version_checked)'" == "") {
  * Check version once per session
  quietly _wbopendata_cache, checkversion
  if (r(needs_update)) {
    display as text "{hline}"
    display as result "Metadata update available: v" r(remote_version)
    display as text "Run {cmd:wbopendata, sync} to update"
    display as text "{hline}"
  }
  global WBOD_version_checked 1
}
```

#### 5.3 User Commands & Examples

```stata
* Check for metadata updates
wbopendata, checkupdate

* Sync metadata (download if newer available)
wbopendata, sync

* Force sync (even if up-to-date)
wbopendata, sync force

* Clear local cache
wbopendata, clearcache

* Check cache status
wbopendata, cacheinfo
```

**Tasks for Week 13:**
1. Implement sync subcommands
2. Add auto-check notification
3. Update help file with sync examples
4. Create user guide section
5. Test all sync scenarios

**Deliverables:**
- [x] Sync command integration
- [x] Auto-check feature
- [x] Help file updates
- [x] User documentation
- [x] Example scripts

---

### Phase 6: Testing & Validation - Week 14

**Goal:** Comprehensive testing of entire system

#### 6.1 Python Pipeline Tests

```python
# tests/test_metadata_pipeline.py

def test_wb_api_fetch():
    """Test WB API fetching"""
    client = WBAPIClient()
    indicators = client.fetch_indicators()
    assert len(indicators) > 10000  # Expect 13K+ indicators
    assert all('id' in ind for ind in indicators)

def test_yaml_generation():
    """Test YAML file generation"""
    generator = YAMLGenerator()
    yaml_data = generator.generate_indicators_yaml(sample_data)
    assert '_metadata' in yaml_data
    assert 'version' in yaml_data['_metadata']
    assert 'indicators' in yaml_data

def test_schema_validation():
    """Test YAML schema compliance"""
    validator = SchemaValidator()
    is_valid = validator.validate_yaml('test_indicators.yaml')
    assert is_valid

def test_git_integration():
    """Test git commit and tagging"""
    git_mgr = GitManager()
    git_mgr.commit_changes("Test update")
    tags = git_mgr.get_tags()
    assert 'metadata-v2.0.0' in tags
```

#### 6.2 Stata Discovery Tests

```stata
* tests/test_sync_mechanism.do

clear all

* Test 1: Cache directory creation
wbopendata, sync
assert r(cache_exists) == 1

* Test 2: Version checking
wbopendata, checkupdate
assert "`r(local_version)'" != ""

* Test 3: Forced sync
wbopendata, sync force
assert r(sync_success) == 1

* Test 4: Search with cached YAML
wbopendata, search("GDP") limit(5)
assert r(n_results) > 0

* Test 5: Clear cache
wbopendata, clearcache
wbopendata, cacheinfo
assert r(cache_exists) == 0
```

#### 6.3 Integration Tests

**Scenarios:**
1. Fresh install → first sync → search
2. Cached metadata → version check → no update needed
3. Old cache → version check → update available → sync → search
4. GitHub API failure → graceful fallback
5. Invalid YAML → error handling
6. Concurrent access → cache locking

#### 6.4 Performance Tests

```stata
* Test search performance with large dataset
timer clear 1
timer on 1
wbopendata, search("development") limit(100)
timer off 1
timer list 1
* Expect: < 1 second
assert r(t1) < 1
```

**Tasks for Week 14:**
1. Write Python test suite
2. Write Stata test suite
3. Integration testing
4. Performance benchmarking
5. Error handling validation
6. Documentation of test results

**Deliverables:**
- [x] Complete test suite (Python + Stata)
- [x] Integration test scenarios
- [x] Performance benchmarks
- [x] Test coverage report
- [x] Bug fixes from testing

---

## Automated Update Pipeline

### Component Architecture

```
scripts/
├── update_metadata.py              # Main orchestrator
├── wb_api_client.py               # WB API wrapper
├── yaml_generator.py              # JSON → YAML transformer
├── schema_validator.py            # YAML validation
├── git_manager.py                 # Git operations
├── diff_analyzer.py               # Change detection
└── config_update.yaml             # Pipeline configuration

requirements-metadata.txt:
├── requests>=2.31.0
├── pyyaml>=6.0
├── jsonschema>=4.20.0
├── gitpython>=3.1.40
└── python-dateutil>=2.8.2
```

### Python Script: `update_metadata.py`

```python
#!/usr/bin/env python3
"""
WB Open Data Metadata Update Pipeline
Fetches latest metadata from World Bank API and generates YAML files
"""

import argparse
import sys
from datetime import datetime
from pathlib import Path

from wb_api_client import WBAPIClient
from yaml_generator import YAMLGenerator
from schema_validator import SchemaValidator
from git_manager import GitManager
from diff_analyzer import DiffAnalyzer

def main():
    parser = argparse.ArgumentParser(description='Update WB metadata YAML files')
    parser.add_argument('--fetch', action='store_true', help='Fetch from WB API')
    parser.add_argument('--generate', action='store_true', help='Generate YAML files')
    parser.add_argument('--validate', action='store_true', help='Validate YAML schema')
    parser.add_argument('--commit', action='store_true', help='Commit and tag changes')
    parser.add_argument('--all', action='store_true', help='Run all steps')
    parser.add_argument('--force', action='store_true', help='Force update even if no changes')
    parser.add_argument('--dry-run', action='store_true', help='Dry run (no commits)')
    
    args = parser.parse_args()
    
    # Default to all if no specific step
    if not any([args.fetch, args.generate, args.validate, args.commit]):
        args.all = True
    
    try:
        # Step 1: Fetch from WB API
        if args.fetch or args.all:
            print("=" * 70)
            print("STEP 1: Fetching metadata from World Bank API...")
            print("=" * 70)
            
            client = WBAPIClient()
            indicators = client.fetch_indicators()
            sources = client.fetch_sources()
            topics = client.fetch_topics()
            
            print(f"✓ Fetched {len(indicators)} indicators")
            print(f"✓ Fetched {len(sources)} sources")
            print(f"✓ Fetched {len(topics)} topics")
            
            # Save raw data to temp
            client.save_raw_data({
                'indicators': indicators,
                'sources': sources,
                'topics': topics
            })
        
        # Step 2: Generate YAML
        if args.generate or args.all:
            print("\n" + "=" * 70)
            print("STEP 2: Generating YAML files...")
            print("=" * 70)
            
            generator = YAMLGenerator()
            
            # Load raw data
            raw_data = generator.load_raw_data()
            
            # Generate each YAML file
            generator.generate_indicators_yaml(raw_data['indicators'])
            generator.generate_sources_yaml(raw_data['sources'])
            generator.generate_topics_yaml(raw_data['topics'])
            
            print("✓ Generated _wbopendata_indicators.yaml")
            print("✓ Generated _wbopendata_sources.yaml")
            print("✓ Generated _wbopendata_topics.yaml")
        
        # Step 3: Validate
        if args.validate or args.all:
            print("\n" + "=" * 70)
            print("STEP 3: Validating YAML schema...")
            print("=" * 70)
            
            validator = SchemaValidator()
            
            files = [
                'src/_/_wbopendata_indicators.yaml',
                'src/_/_wbopendata_sources.yaml',
                'src/_/_wbopendata_topics.yaml'
            ]
            
            all_valid = True
            for file in files:
                is_valid = validator.validate(file)
                if is_valid:
                    print(f"✓ {file} is valid")
                else:
                    print(f"✗ {file} has schema errors")
                    all_valid = False
            
            if not all_valid:
                print("\nERROR: Schema validation failed")
                sys.exit(1)
        
        # Step 4: Commit and tag
        if args.commit or args.all:
            print("\n" + "=" * 70)
            print("STEP 4: Committing changes...")
            print("=" * 70)
            
            git_mgr = GitManager()
            diff_analyzer = DiffAnalyzer()
            
            # Check for changes
            has_changes = git_mgr.has_changes('src/_/_wbopendata_*.yaml')
            
            if not has_changes and not args.force:
                print("No changes detected. Skipping commit.")
                return
            
            # Analyze differences
            changes = diff_analyzer.analyze_changes()
            print(f"Changes detected:")
            print(f"  - Indicators added: {changes['indicators_added']}")
            print(f"  - Indicators modified: {changes['indicators_modified']}")
            print(f"  - Indicators removed: {changes['indicators_removed']}")
            
            # Get next version
            current_version = git_mgr.get_latest_version()
            next_version = git_mgr.bump_version(current_version, 'minor')
            
            # Commit
            if not args.dry_run:
                commit_msg = f"Update metadata: v{next_version} ({datetime.now().strftime('%Y-%m-%d')})"
                git_mgr.commit_changes(commit_msg)
                
                # Tag
                tag_name = f"metadata-v{next_version}"
                git_mgr.create_tag(tag_name, f"Metadata release v{next_version}")
                
                print(f"✓ Committed and tagged as {tag_name}")
            else:
                print(f"[DRY RUN] Would commit as v{next_version}")
        
        print("\n" + "=" * 70)
        print("SUCCESS: Metadata update complete!")
        print("=" * 70)
        
    except Exception as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
```

### Update Schedule

**Automated (GitHub Actions):**
- **Monthly:** 1st day of month at 00:00 UTC
- **On-demand:** Manual workflow trigger via GitHub UI

**Manual:**
- **Quarterly:** Major releases (with SSC package update)
- **Ad-hoc:** Critical fixes or API changes

---

## Caching & Sync Mechanism

### Cache Lifecycle

```
[User installs wbopendata]
        ↓
[No local cache exists]
        ↓
[First discovery command: wbopendata, search(...)]
        ↓
[Load YAML from package install (src/_/)]
        ↓
[Auto-check: is newer version available?]
        ├─ YES → [Display notification]
        └─ NO  → [Continue with current]
        ↓
[Search executes normally]

[User runs: wbopendata, sync]
        ↓
[Check GitHub for latest version]
        ↓
[Download YAML to local cache]
        ↓
[Update metadata_version.txt]
        ↓
[Future commands use cached YAML]
```

### Cache Priority

```stata
* YAML loading priority:
1. Local cache (if exists and valid)
   → C:\Users\{user}\ado\personal\wbopendata\cache\
   
2. Package install
   → C:\ado\plus\_\_wbopendata_indicators.yaml
   
3. Fallback: Error (no metadata available)
```

---

## Version Management

### Semantic Versioning for Metadata

**Format:** `v{MAJOR}.{MINOR}.{PATCH}`

**Incrementing rules:**
- **MAJOR:** Breaking schema changes (field removals, type changes)
- **MINOR:** New indicators added, non-breaking field additions
- **PATCH:** Data corrections, no schema/structure change

**Examples:**
- `v2.0.0` → Initial YAML schema
- `v2.1.0` → 50 new indicators added
- `v2.1.1` → Fixed encoding issues in descriptions
- `v3.0.0` → Schema change (new required field)

### Version Checking Algorithm

```stata
* Compare versions: "2.1.0" vs "2.2.0"
local v1_parts = tokenize("`local_version'", ".")
local v2_parts = tokenize("`remote_version'", ".")

local needs_update = 0
if (v2_major > v1_major) local needs_update = 1
else if (v2_major == v1_major) & (v2_minor > v1_minor) local needs_update = 1
else if (v2_major == v1_major) & (v2_minor == v1_minor) & (v2_patch > v1_patch) local needs_update = 1

return scalar needs_update = `needs_update'
```

---

## Testing Strategy

### Test Pyramid

```
             ┌──────────────┐
             │   E2E Tests  │  (5% - Full user workflows)
             └──────────────┘
          ┌───────────────────┐
          │ Integration Tests │  (20% - Component interaction)
          └───────────────────┘
       ┌────────────────────────┐
       │     Unit Tests         │  (75% - Individual functions)
       └────────────────────────┘
```

### Test Coverage Targets

| Component | Target Coverage |
|-----------|----------------|
| Python pipeline | 90%+ |
| Stata helpers | 80%+ |
| Integration | 100% critical paths |
| Performance | All commands benchmarked |

---

## Deployment & Rollout

### Rollout Plan

**Phase 1: Beta Release (Week 15)**
- Deploy to test repository
- Invite 5-10 beta testers
- Monitor for issues
- Collect feedback

**Phase 2: Soft Launch (Week 16)**
- Release v18.0-beta on GitHub
- Update SSC package (beta flag)
- Announce to early adopters
- Monitor sync usage

**Phase 3: General Availability (Week 17)**
- Full v18.0 release
- SSC stable update
- Documentation complete
- Public announcement

---

## Maintenance & Operations

### TODO: Stata YAML Writer Refactor

- **Problem:** Stata YAML generation uses `postfile` with `str2045`, which truncates long descriptions and causes parity diffs against Python outputs.
- **Impact:** Long `description` fields are clipped in Stata-generated YAML; parity checks fail for indicators with long text.
- **Proposed fix:** Replace `postfile` + `yaml write` with direct `file write` YAML emission (or multi-line literal blocks) to preserve full text while keeping Stata 11/12 compatibility.
- **Status:** Deferred.

### Ongoing Tasks

**Monthly:**
- Monitor automated pipeline runs
- Review GitHub Actions logs
- Check for API failures

**Quarterly:**
- Audit metadata quality
- Review user feedback
- Plan schema enhancements

**As-needed:**
- Fix pipeline failures
- Update dependencies
- Handle API changes

### Monitoring & Alerts

**GitHub Actions:**
- Email on workflow failure
- Create GitHub issue on failure
- Slack notification (optional)

**User Support:**
- Monitor wbopendata issues for sync problems
- Track download metrics
- User satisfaction surveys

---

## Summary Timeline

```
TOTAL: 14-17 weeks from start to GA

Week 1-8:   Pathway B foundation (YAML + discovery)
Week 9-10:  Python automation pipeline
Week 11:    GitHub Actions setup
Week 12:    Caching & sync in Stata
Week 13:    User-facing sync commands
Week 14:    Comprehensive testing
Week 15:    Beta release
Week 16:    Soft launch
Week 17:    General availability
```

---

**Document Status:** Planning Complete  
**Next Action:** Begin Python pipeline development (Week 9)  
**Dependencies:** Pathway B completion, Python environment, GitHub Actions access
