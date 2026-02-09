# Pathway C: Stata Sync & Caching Implementation Guide

**Date:** January 20, 2026  
**Project:** wbopendata-dev  
**Scope:** Complete Stata implementation for caching and sync mechanism

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Cache Management](#cache-management)
3. [Version Checking](#version-checking)
4. [Download Mechanism](#download-mechanism)
5. [Integration with Discovery](#integration-with-discovery)
6. [User Commands](#user-commands)
7. [Testing Suite](#testing-suite)

---

## Architecture Overview

### Stata File Structure

```
src/
├── w/
│   └── wbopendata.ado              (main command - updated)
└── _/
    ├── _wbopendata_indicators.yaml (bundled metadata)
    ├── _wbopendata_sources.yaml
    ├── _wbopendata_topics.yaml
    ├── _yaml_read.ado              (YAML parser wrapper)
    ├── _wbopendata_search.ado      (search command)
    ├── _wbopendata_info.ado        (info command)
    ├── _wbopendata_cache.ado       (↑ NEW - cache manager)
    ├── _wbopendata_check_version.ado (↑ NEW - version checker)
    ├── _wbopendata_download_yaml.ado (↑ NEW - downloader)
    └── _wbopendata_get_yaml_path.ado (↑ NEW - path resolver)
```

### Cache Directory Structure

```
User's cache location:
C:\Users\{username}\ado\personal\wbopendata\cache\

Files in cache:
├── metadata_version.txt           (current version, e.g., "2.1.0")
├── cache_timestamp.txt            (last updated timestamp)
├── _wbopendata_indicators.yaml    (downloaded YAML)
├── _wbopendata_sources.yaml       (downloaded YAML)
└── _wbopendata_topics.yaml        (downloaded YAML)
```

---

## Cache Management

### Helper 1: `_wbopendata_cache.ado`

**Purpose:** Central cache management

```stata
*! _wbopendata_cache v1.0.0  20Jan2026
*! Cache manager for wbopendata YAML metadata

program define _wbopendata_cache, rclass
    version 14.0
    
    syntax [, ///
        CHECKversion  /// Check if update available
        UPDAte        /// Download update if available
        FORCe         /// Force update even if current
        CLEAR         /// Clear cache directory
        INFO          /// Display cache status
    ]
    
    * Get cache directory
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    
    * Initialize cache if doesn't exist
    if ("`checkversion'" != "" | "`update'" != "" | "`info'" != "") {
        _wbopendata_init_cache
    }
    
    * Execute requested operation
    if ("`checkversion'" != "") {
        _wbopendata_check_version
        return add
    }
    
    if ("`update'" != "" | "`force'" != "") {
        if ("`force'" != "") {
            _wbopendata_download_yaml, force
        }
        else {
            * Check if update needed
            _wbopendata_check_version
            if (r(needs_update) == 1) {
                display as text "Update available: v" r(remote_version)
                _wbopendata_download_yaml
            }
            else {
                display as text "Metadata is up-to-date (v" r(local_version) ")"
            }
        }
        return add
    }
    
    if ("`clear'" != "") {
        _wbopendata_clear_cache
        display as result "Cache cleared"
        return local cache_cleared = "1"
    }
    
    if ("`info'" != "") {
        _wbopendata_cache_info
        return add
    }
    
    * Default: return cache location
    return local cache_dir = "`cache_dir'"
    return local cache_exists = file_exists("`cache_dir'metadata_version.txt")
    
end

* Helper: Initialize cache directory
program define _wbopendata_init_cache
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    
    * Create directory if doesn't exist
    capture mkdir "`cache_dir'"
    
    * Verify writable
    tempname fh
    local test_file = "`cache_dir'_test.tmp"
    capture file open `fh' using "`test_file'", write replace
    if (_rc != 0) {
        display as error "Cannot write to cache directory: `cache_dir'"
        error 603
    }
    file close `fh'
    capture erase "`test_file'"
end

* Helper: Clear cache
program define _wbopendata_clear_cache
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    
    * Remove all cache files
    local files "metadata_version.txt cache_timestamp.txt"
    local files "`files' _wbopendata_indicators.yaml"
    local files "`files' _wbopendata_sources.yaml"
    local files "`files' _wbopendata_topics.yaml"
    
    foreach file of local files {
        local full_path = "`cache_dir'`file'"
        capture erase "`full_path'"
    }
end

* Helper: Display cache info
program define _wbopendata_cache_info, rclass
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    
    display as text "{hline 60}"
    display as result "wbopendata Cache Status"
    display as text "{hline 60}"
    
    * Check if cache exists
    local version_file = "`cache_dir'metadata_version.txt"
    if file_exists("`version_file'") {
        * Read version
        tempname fh
        file open `fh' using "`version_file'", read
        file read `fh' local_version
        file close `fh'
        
        * Read timestamp
        local timestamp_file = "`cache_dir'cache_timestamp.txt"
        if file_exists("`timestamp_file'") {
            file open `fh' using "`timestamp_file'", read
            file read `fh' timestamp
            file close `fh'
        }
        else {
            local timestamp = "Unknown"
        }
        
        display as text "  Cache location: " as result "`cache_dir'"
        display as text "  Current version: " as result "v`local_version'"
        display as text "  Last updated: " as result "`timestamp'"
        
        * Check file sizes
        local ind_file = "`cache_dir'_wbopendata_indicators.yaml"
        if file_exists("`ind_file'") {
            quietly _file_size "`ind_file'"
            display as text "  Indicators size: " as result r(size_kb) " KB"
        }
        
        return local cache_version = "`local_version'"
        return local cache_timestamp = "`timestamp'"
        return scalar cache_exists = 1
    }
    else {
        display as text "  Status: " as error "No cache found"
        display as text "  Location: " as result "`cache_dir'"
        display as text ""
        display as text "  Run {cmd:wbopendata, sync} to initialize cache"
        
        return scalar cache_exists = 0
    }
    
    display as text "{hline 60}"
end

* Helper: Get file size
program define _file_size, rclass
    args filepath
    
    * Platform-specific file size check
    if (c(os) == "Windows") {
        tempname fh
        file open `fh' using "`filepath'", read binary
        file seek `fh' eof
        local size = r(loc)
        file close `fh'
    }
    else {
        * Unix: use shell command
        shell ls -l "`filepath'" > tempsize.txt
        tempname sh
        file open `sh' using "tempsize.txt", read
        file read `sh' line
        file close `sh'
        erase tempsize.txt
        
        * Parse size (5th field)
        local size = word("`line'", 5)
    }
    
    local size_kb = round(`size' / 1024, 0.01)
    return scalar size_kb = `size_kb'
end
```

---

### Helper 2: `_wbopendata_check_version.ado`

**Purpose:** Check GitHub for latest metadata version

```stata
*! _wbopendata_check_version v1.0.0  20Jan2026
*! Check for metadata updates from GitHub

program define _wbopendata_check_version, rclass
    version 14.0
    
    * Read local version from cache
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local version_file = "`cache_dir'metadata_version.txt"
    
    if file_exists("`version_file'") {
        tempname fh
        file open `fh' using "`version_file'", read
        file read `fh' local_version
        file close `fh'
        
        * Clean version string
        local local_version = trim("`local_version'")
    }
    else {
        * No cache, assume v0.0.0
        local local_version = "0.0.0"
    }
    
    * Query GitHub API for latest release
    local remote_version = ""
    local check_success = 0
    
    * Try to fetch from GitHub API
    quietly {
        * Use copy command to fetch GitHub API response
        local api_url = "https://api.github.com/repos/jpazvd/wbopendata/releases/latest"
        local temp_json = "`c(tmpdir)'gh_version.json"
        
        capture copy "`api_url'" "`temp_json'", replace
        
        if (_rc == 0) {
            * Parse JSON to extract tag_name
            _wbopendata_parse_github_json "`temp_json'"
            local remote_version = r(tag_version)
            local check_success = 1
            
            * Cleanup
            capture erase "`temp_json'"
        }
    }
    
    * Fallback: if GitHub check failed, assume no update
    if (`check_success' == 0) {
        display as text "(Could not check for updates - using local version)"
        local remote_version = "`local_version'"
    }
    
    * Compare versions
    local needs_update = 0
    if ("`remote_version'" != "`local_version'") {
        * Parse version numbers for proper comparison
        _wbopendata_compare_versions "`local_version'" "`remote_version'"
        local needs_update = r(newer)
    }
    
    * Return results
    return local local_version = "`local_version'"
    return local remote_version = "`remote_version'"
    return scalar needs_update = `needs_update'
    return scalar check_success = `check_success'
    
end

* Helper: Parse GitHub API JSON response
program define _wbopendata_parse_github_json, rclass
    args json_file
    
    * Read JSON file line by line to find tag_name
    tempname fh
    file open `fh' using "`json_file'", read
    
    local tag_version = ""
    file read `fh' line
    while (r(eof) == 0) {
        * Look for "tag_name": "metadata-v2.1.0"
        if (strpos(`"`line'"', `""tag_name""') > 0) {
            * Extract version between quotes
            local start = strpos(`"`line'"', `""metadata-v"') + 12
            local end = strpos(substr(`"`line'"', `start', .), `"""')
            local tag_version = substr(`"`line'"', `start', `end'-1)
            
            * Clean up
            local tag_version = trim("`tag_version'")
            continue, break
        }
        file read `fh' line
    }
    file close `fh'
    
    return local tag_version = "`tag_version'"
end

* Helper: Compare semantic versions
program define _wbopendata_compare_versions, rclass
    args version1 version2
    
    * Parse version1 (e.g., "2.1.0")
    tokenize "`version1'", parse(".")
    local v1_major = `1'
    local v1_minor = `3'
    local v1_patch = `5'
    
    * Parse version2
    tokenize "`version2'", parse(".")
    local v2_major = `1'
    local v2_minor = `3'
    local v2_patch = `5'
    
    * Compare
    local newer = 0
    if (`v2_major' > `v1_major') {
        local newer = 1
    }
    else if (`v2_major' == `v1_major') {
        if (`v2_minor' > `v1_minor') {
            local newer = 1
        }
        else if (`v2_minor' == `v1_minor') {
            if (`v2_patch' > `v1_patch') {
                local newer = 1
            }
        }
    }
    
    return scalar newer = `newer'
end
```

---

### Helper 3: `_wbopendata_download_yaml.ado`

**Purpose:** Download latest YAML files from GitHub

```stata
*! _wbopendata_download_yaml v1.0.0  20Jan2026
*! Download metadata YAML files from GitHub

program define _wbopendata_download_yaml, rclass
    version 14.0
    
    syntax [, FORCe]
    
    * Check if update needed (unless force)
    if ("`force'" == "") {
        _wbopendata_check_version
        if (r(needs_update) == 0) {
            display as text "Metadata is up-to-date (v" r(local_version) ")"
            return local already_current = "1"
            exit 0
        }
        local target_version = r(remote_version)
    }
    else {
        * Force: get latest version
        _wbopendata_check_version
        local target_version = r(remote_version)
    }
    
    * Setup paths
    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local base_url = "https://raw.githubusercontent.com/jpazvd/wbopendata"
    local tag = "metadata-v`target_version'"
    
    display as text "{hline 60}"
    display as result "Downloading metadata v`target_version'..."
    display as text "{hline 60}"
    
    * Download each YAML file
    local yaml_files "indicators sources topics"
    local download_success = 1
    
    foreach file of local yaml_files {
        local remote_url = "`base_url'/`tag'/src/_/_wbopendata_`file'.yaml"
        local local_file = "`cache_dir'_wbopendata_`file'.yaml"
        
        display as text "  Downloading `file'.yaml..." _continue
        
        capture copy "`remote_url'" "`local_file'", replace
        
        if (_rc == 0) {
            display as result " ✓"
        }
        else {
            display as error " ✗ (failed)"
            local download_success = 0
        }
    }
    
    if (`download_success' == 0) {
        display as error "Download failed. Check internet connection."
        return local download_success = "0"
        error 603
    }
    
    * Update version file
    tempname fh
    local version_file = "`cache_dir'metadata_version.txt"
    file open `fh' using "`version_file'", write replace
    file write `fh' "`target_version'"
    file close `fh'
    
    * Update timestamp
    local timestamp_file = "`cache_dir'cache_timestamp.txt"
    file open `fh' using "`timestamp_file'", write replace
    file write `fh' "`c(current_date)' `c(current_time)'"
    file close `fh'
    
    display as text "{hline 60}"
    display as result "✓ Metadata updated to v`target_version'"
    display as text "{hline 60}"
    
    return local new_version = "`target_version'"
    return local download_success = "1"
    
end
```

---

### Helper 4: `_wbopendata_get_yaml_path.ado`

**Purpose:** Resolve YAML file path (cache vs package)

```stata
*! _wbopendata_get_yaml_path v1.0.0  20Jan2026
*! Resolve YAML file path with cache priority

program define _wbopendata_get_yaml_path, rclass
    version 14.0
    
    syntax anything(name=file_type id="file type"), [NOCache]
    
    * Validate file type
    if !inlist("`file_type'", "indicators", "sources", "topics") {
        display as error "Invalid file type: `file_type'"
        error 198
    }
    
    local filename = "_wbopendata_`file_type'.yaml"
    
    * Priority 1: Local cache (if exists and nocache not specified)
    if ("`nocache'" == "") {
        local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
        local cache_path = "`cache_dir'`filename'"
        
        if file_exists("`cache_path'") {
            return local yaml_path = "`cache_path'"
            return local source = "cache"
            exit 0
        }
    }
    
    * Priority 2: Package installation
    local package_path = c(sysdir_plus) + "_/`filename'"
    
    if file_exists("`package_path'") {
        return local yaml_path = "`package_path'"
        return local source = "package"
        exit 0
    }
    
    * Fallback: Check sysdir_personal (legacy)
    local personal_path = c(sysdir_personal) + "_/`filename'"
    
    if file_exists("`personal_path'") {
        return local yaml_path = "`personal_path'"
        return local source = "personal"
        exit 0
    }
    
    * Error: No YAML file found
    display as error "Metadata file not found: `filename'"
    display as error "Expected locations:"
    display as error "  1. `cache_path'"
    display as error "  2. `package_path'"
    display as text ""
    display as text "Run {cmd:wbopendata, sync} to download metadata"
    error 601
    
end
```

---

## Integration with Discovery

### Updated `_wbopendata_search.ado`

**Changes:** Use cache-aware YAML path resolution

```stata
program def _wbopendata_search, rclass
    syntax anything(name=keyword id="search term"), ///
        [limit(integer 20) source(string) NOCache]
    
    * Get YAML path (cache-aware)
    _wbopendata_get_yaml_path indicators, `nocache'
    local yaml_path = r(yaml_path)
    local yaml_source = r(source)
    
    * Auto-check for updates (once per session)
    if ("`c(WBOD_version_checked)'" == "" & "`nocache'" == "") {
        quietly _wbopendata_cache, checkversion
        if (r(needs_update) == 1) {
            display as text "{hline 60}"
            display as result "Metadata update available: v" r(remote_version)
            display as text "Run {cmd:wbopendata, sync} to update"
            display as text "{hline 60}"
            display ""
        }
        global WBOD_version_checked = "1"
    }
    
    * Load YAML and perform search
    quietly yaml_read using "`yaml_path'", replace
    
    * [Rest of search implementation...]
    * (Same as Pathway B implementation)
    
    * Return metadata source
    return local metadata_source = "`yaml_source'"
    
end
```

---

## User Commands

### Main Command Integration (`wbopendata.ado`)

**Updated Syntax:**

```stata
syntax [, 
    ... existing options ...
    SYNC                    // NEW: check and sync metadata
    SYNCForce              // NEW: force sync
    CHECKUpdate            // NEW: check for updates
    CLEARCACHE             // NEW: clear cache
    CACHEInfo              // NEW: display cache status
    ... other options ...
]

* Handle metadata management subcommands first
if ("`sync'" != "" | "`syncforce'" != "") {
    if ("`syncforce'" != "") {
        _wbopendata_cache, update force
    }
    else {
        _wbopendata_cache, update
    }
    exit 0
}

if ("`checkupdate'" != "") {
    _wbopendata_cache, checkversion
    
    if (r(needs_update) == 1) {
        display as result "Update available!"
        display as text "  Local version:  v" r(local_version)
        display as text "  Remote version: v" r(remote_version)
        display ""
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

if ("`cacheinfo'" != "") {
    _wbopendata_cache, info
    exit 0
}

* [Continue with existing discovery/download commands...]
```

---

### User Command Examples

```stata
*===============================================================================
* METADATA SYNC COMMANDS
*===============================================================================

* 1. Check if metadata update is available
wbopendata, checkupdate

* Output:
*   Update available!
*     Local version:  v2.0.0
*     Remote version: v2.1.0
*   
*   Run wbopendata, sync to update

*===============================================================================

* 2. Sync metadata (download if newer)
wbopendata, sync

* Output:
*   ------------------------------------------------------------
*   Downloading metadata v2.1.0...
*   ------------------------------------------------------------
*     Downloading indicators.yaml... ✓
*     Downloading sources.yaml... ✓
*     Downloading topics.yaml... ✓
*   ------------------------------------------------------------
*   ✓ Metadata updated to v2.1.0
*   ------------------------------------------------------------

*===============================================================================

* 3. Force sync (re-download even if current)
wbopendata, sync force

*===============================================================================

* 4. Display cache status
wbopendata, cacheinfo

* Output:
*   ------------------------------------------------------------
*   wbopendata Cache Status
*   ------------------------------------------------------------
*     Cache location: C:\Users\user\ado\personal\wbopendata\cache\
*     Current version: v2.1.0
*     Last updated: 20 Jan 2026 15:30:00
*     Indicators size: 512.5 KB
*   ------------------------------------------------------------

*===============================================================================

* 5. Clear cache (force re-download next time)
wbopendata, clearcache

*===============================================================================

* 6. Search using cached metadata
wbopendata, search("education") limit(10)

* (Automatically uses cache if available)

*===============================================================================

* 7. Search using package metadata (bypass cache)
wbopendata, search("GDP") nocache

*===============================================================================
```

---

## Testing Suite

### `tests/test_sync_mechanism.do`

```stata
*! test_sync_mechanism.do
*! Test suite for wbopendata sync and caching

clear all
set more off

log using "test_sync_mechanism.log", replace

*===============================================================================
* TEST SETUP
*===============================================================================

* Clear any existing cache
capture wbopendata, clearcache

*===============================================================================
* TEST 1: Cache Initialization
*===============================================================================

display as text _n "TEST 1: Cache Initialization" _n

wbopendata, cacheinfo

* Verify cache doesn't exist initially
assert r(cache_exists) == 0

display as result "✓ TEST 1 PASSED: Cache correctly reports not existing" _n

*===============================================================================
* TEST 2: First Sync
*===============================================================================

display as text "TEST 2: First Sync" _n

wbopendata, sync

* Verify cache now exists
wbopendata, cacheinfo
assert r(cache_exists) == 1
assert "`r(cache_version)'" != ""

display as result "✓ TEST 2 PASSED: First sync created cache" _n

*===============================================================================
* TEST 3: Version Checking
*===============================================================================

display as text "TEST 3: Version Checking" _n

wbopendata, checkupdate

local local_ver = r(local_version)
local remote_ver = r(remote_version)

assert "`local_ver'" != ""
assert "`remote_ver'" != ""

display as text "  Local version: `local_ver'"
display as text "  Remote version: `remote_ver'"

display as result "✓ TEST 3 PASSED: Version check works" _n

*===============================================================================
* TEST 4: Search with Cache
*===============================================================================

display as text "TEST 4: Search with Cached Metadata" _n

wbopendata, search("GDP") limit(5)

assert r(n_results) > 0
assert r(n_results) <= 5
assert "`r(metadata_source)'" == "cache"

display as result "✓ TEST 4 PASSED: Search uses cache" _n

*===============================================================================
* TEST 5: Search without Cache
*===============================================================================

display as text "TEST 5: Search Bypassing Cache" _n

wbopendata, search("population") limit(3) nocache

assert r(n_results) > 0
assert "`r(metadata_source)'" == "package"

display as result "✓ TEST 5 PASSED: Search can bypass cache" _n

*===============================================================================
* TEST 6: Force Sync
*===============================================================================

display as text "TEST 6: Force Sync" _n

wbopendata, sync force

assert r(download_success) == "1"

display as result "✓ TEST 6 PASSED: Force sync works" _n

*===============================================================================
* TEST 7: Clear Cache
*===============================================================================

display as text "TEST 7: Clear Cache" _n

wbopendata, clearcache

wbopendata, cacheinfo
assert r(cache_exists) == 0

display as result "✓ TEST 7 PASSED: Cache cleared successfully" _n

*===============================================================================
* TEST 8: Search Falls Back to Package
*===============================================================================

display as text "TEST 8: Search Falls Back to Package After Clear" _n

wbopendata, search("education") limit(2)

assert r(n_results) > 0
assert "`r(metadata_source)'" == "package"

display as result "✓ TEST 8 PASSED: Fallback to package works" _n

*===============================================================================
* TEST SUMMARY
*===============================================================================

display as text _n "{hline 60}"
display as result "ALL TESTS PASSED!"
display as text "{hline 60}"

log close
```

---

### Performance Benchmark

```stata
*! benchmark_cache.do
*! Benchmark cache vs package performance

clear all

display as text "{hline 60}"
display as result "Cache Performance Benchmark"
display as text "{hline 60}" _n

* Ensure cache is populated
wbopendata, sync

* Benchmark 1: Search with cache
timer clear 1
timer on 1
wbopendata, search("development") limit(100)
timer off 1

timer list 1
local cache_time = r(t1)

* Benchmark 2: Search without cache
timer clear 2
timer on 2
wbopendata, search("development") limit(100) nocache
timer off 2

timer list 2
local package_time = r(t2)

* Display results
display as text _n "Results:"
display as text "  Cache time:   " as result %6.3f `cache_time' as text " seconds"
display as text "  Package time: " as result %6.3f `package_time' as text " seconds"

local speedup = `package_time' / `cache_time'
display as text "  Speedup:      " as result %6.2fx `speedup' _n

display as text "{hline 60}"
```

---

## Return Values

### Cache Commands

```stata
* After: wbopendata, cacheinfo
r(cache_exists)      = 1
r(cache_version)     = "2.1.0"
r(cache_timestamp)   = "20 Jan 2026 15:30:00"
r(cache_dir)         = "C:\Users\...\wbopendata\cache\"

* After: wbopendata, checkupdate
r(local_version)     = "2.0.0"
r(remote_version)    = "2.1.0"
r(needs_update)      = 1
r(check_success)     = 1

* After: wbopendata, sync
r(new_version)       = "2.1.0"
r(download_success)  = "1"

* After: wbopendata, search(...) with cache
r(n_results)         = 15
r(metadata_source)   = "cache"
r(indicator1)        = "SE.ADT.LITR.ZS"
...
```

---

**Document Status:** Stata Implementation Complete  
**Next:** Begin coding and testing sync mechanism  
**Dependencies:** Pathway B discovery commands completed
