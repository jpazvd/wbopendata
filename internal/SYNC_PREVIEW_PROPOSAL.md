# Proposal: Pre-Sync Diagnostic for `wbopendata, sync`

**Date:** 09 Feb 2026  
**Status:** Draft Proposal  
**Branch:** feat/discovery-sync  

---

## Problem Statement

Currently, `wbopendata, update query` provides a rich pre-execution diagnostic:
- Shows existing indicator count
- Shows last check/update timestamps
- Displays per-source and per-topic counts (with `detail`)
- Suggests next actions with clickable SMCL links

In contrast, `wbopendata, sync` executes immediately without preview. Users cannot see:
- What pathway will be used (Python vs Stata vs GitHub)
- Current cache state before refresh
- What might change after sync

---

## Proposed Solution

Add a **`preview`** (or `dryrun`) option to `sync` that displays diagnostic information without executing the sync.

### New Syntax

```stata
wbopendata, sync                    // Execute sync (current behavior)
wbopendata, sync preview            // Show diagnostic, then prompt to continue
wbopendata, sync dryrun             // Show diagnostic only, don't execute
wbopendata, sync [force] [preview]  // Preview even when forcing
```

---

## Design Options

### Option A: Simple Preview Before Execute

When `preview` is specified, show cache status and confirm before sync:

```
─────────────────────────────────────────────────────────────────────
wbopendata Sync Preview
─────────────────────────────────────────────────────────────────────

  Cache location:       C:/Users/user/ado/personal/wbopendata/cache/
  Cache exists:         yes
  Current version:      v2.0.0
  Last sync:            08 Feb 2026 14:30:22
  Sync method used:     python
  
  Remote check:         v2.0.1 available on GitHub
  
  Pathway to use:       Python (detected: python 3.11.5)
  
─────────────────────────────────────────────────────────────────────
  
Proceed with sync?

  {stata wbopendata, sync:  Yes, sync now}    |    {stata noi di "Cancelled":  Cancel}
```

### Option B: Detailed Preview with Record Counts

Query the WB API for current counts (same as `update check`) and compare to cache:

```
─────────────────────────────────────────────────────────────────────
wbopendata Sync Preview
─────────────────────────────────────────────────────────────────────

  Local Cache Status
  ──────────────────
  Cache version:        v2.0.0
  Last sync:            08 Feb 2026 14:30:22
  Method:               python
  Indicators cached:    24,847
  
  Remote Status (from WB API)
  ───────────────────────────
  Total indicators:     24,912   (+65 new)
  Total sources:        67       (same)
  Total topics:         21       (same)
  
  Sync Pathway
  ────────────
  Python available:     ✓ (python 3.11.5)
  Stata fallback:       available
  GitHub download:      available (v2.0.1)
  
  Will use:             Python canonical pipeline

─────────────────────────────────────────────────────────────────────

Possible actions:

  {stata wbopendata, sync:  Sync metadata now}
  {stata wbopendata, sync forcestata:  Force Stata pathway}
  {stata wbopendata, cacheinfo:  View full cache info}
```

### Option C: Merged `cacheinfo` Enhancement

Enhance existing `cacheinfo` to show more details and add sync suggestions:

```stata
wbopendata, cacheinfo detail   // Enhanced diagnostic
wbopendata, sync               // Same as current (no preview)
```

---

## Recommendation: Option B (Detailed Preview)

**Rationale:**
1. Most informative for users deciding whether to sync
2. Shows pathway selection (valuable for debugging)
3. Record count comparison helps users understand scope of changes
4. Clickable actions improve UX

**Implementation complexity:** Medium
- Need to query API for quick count check
- Parse existing cache YAML for indicator count
- Check Python availability

---

## Implementation Plan

### Phase 1: Core Infrastructure

1. **Add `_wbopendata_sync_preview.ado`** — New program for preview logic
2. **Modify `_wbopendata_sync.ado`** — Add `PREVIEW` and `DRYRUN` options
3. **Add `_wbopendata_get_api_counts.ado`** — Quick API query for record counts

### Phase 2: Cache Introspection

1. **Add `_wbopendata_get_cache_counts.ado`** — Count records in cached YAML
2. **Enhance `_wbopendata_cache_info`** — Add `detail` option

### Phase 3: Display and UX

1. **Rich SMCL output** with clickable actions
2. **Pathway detection display** showing which method will be used
3. **Diff summary** when counts differ

---

## Proposed Program: `_wbopendata_sync_preview`

```stata
program define _wbopendata_sync_preview, rclass
    version 14.0
    syntax [, DETAIL]
    
    * 1. Check cache status
    local cache_dir "`c(sysdir_personal)'wbopendata/cache/"
    local cache_dir : subinstr local cache_dir "\" "/" , all
    
    local has_cache = 0
    local cache_ver = ""
    local cache_ts = ""
    local cache_method = ""
    
    if (fileexists("`cache_dir'metadata_version.txt")) {
        local has_cache = 1
        * Read version, timestamp, method from cache files
        ... (implementation details)
    }
    
    * 2. Query API for current counts (quick single request)
    _api_read, parameter(total)
    local api_indicators = r(total1)
    
    * 3. Check Python availability
    local python_ok = 0
    capture shell python -V
    if (_rc == 0) local python_ok = 1
    
    * 4. Check remote version on GitHub
    capture _wbopendata_check_version
    local remote_ver = r(remote_version)
    local needs_update = r(needs_update)
    
    * 5. Display diagnostic
    di as text "{hline 65}"
    di as result "wbopendata Sync Preview"
    di as text "{hline 65}"
    di ""
    
    if (`has_cache') {
        di as text "  Local Cache"
        di as text "  ───────────"
        di as text "  Version:          " as result "v`cache_ver'"
        di as text "  Last sync:        " as result "`cache_ts'"
        di as text "  Method:           " as result "`cache_method'"
        * Count indicators in cache
        ... count from YAML ...
        di as text "  Indicators:       " as result "`cache_ind_count'"
    }
    else {
        di as text "  Local Cache:      " as error "Not found"
    }
    
    di ""
    di as text "  Remote Status"
    di as text "  ─────────────"
    di as text "  API indicators:   " as result "`api_indicators'"
    if (`needs_update') {
        di as text "  GitHub version:   " as result "v`remote_ver'" as text " (update available)"
    }
    
    di ""
    di as text "  Sync Pathway"
    di as text "  ────────────"
    if (`python_ok') {
        di as text "  Will use:         " as result "Python canonical"
    }
    else {
        di as text "  Will use:         " as result "Stata fallback"
    }
    
    di ""
    di as text "{hline 65}"
    di ""
    di as text "Possible actions:"
    di ""
    di `"  {stata wbopendata, sync:  Sync metadata now}"'
    di `"  {stata wbopendata, sync force:  Force sync (even if fresh)}"'
    di `"  {stata wbopendata, sync forcestata:  Force Stata pathway}"'
    
    * Return values for programmatic use
    return scalar has_cache = `has_cache'
    return scalar api_indicators = `api_indicators'
    return scalar python_available = `python_ok'
    return scalar needs_update = `needs_update'
end
```

---

## Changes to `wbopendata.ado` Syntax

```stata
syntax [...existing...] ///
    SYNC            ///
    SYNCFORCE       ///
    SYNCPREVIEW     ///   ← NEW: show preview before sync
    SYNCDRYRUN      ///   ← NEW: preview only, no sync
    ...
```

### Routing Logic

```stata
if ("`sync'" != "" | "`syncforce'" != "" | "`syncpreview'" != "" | "`syncdryrun'" != "") {
    
    * Preview or dryrun: show diagnostic first
    if ("`syncpreview'" != "" | "`syncdryrun'" != "") {
        _wbopendata_sync_preview
        
        * If dryrun, stop here
        if ("`syncdryrun'" != "") exit 0
        
        * If preview, prompt/wait then continue to sync
        di as text "Press any key to continue, or Ctrl+C to cancel..."
        ... or just continue ...
    }
    
    * Execute sync
    if ("`syncforce'" != "") _wbopendata_sync, force
    else _wbopendata_sync
    exit _rc
}
```

---

## Alternative: Automatic Preview on First Sync

Instead of explicit `preview` option, always show preview when:
- Cache doesn't exist (first run)
- Cache is stale (>30 days old)
- Significant changes detected (>5% indicator count difference)

This matches the "informative by default" philosophy.

---

## Questions for Discussion

1. **Naming:** `preview` vs `dryrun` vs `check` vs `status`?
2. **Default behavior:** Should sync always show preview, or only with option?
3. **API query overhead:** Is a quick API count check acceptable (~1-2 seconds)?
4. **Indicator count:** Count from YAML parse vs store count in cache metadata?
5. **Integration with `cacheinfo`:** Merge features or keep separate?

---

## Next Steps

1. Get feedback on design options (A, B, or C)
2. Implement `_wbopendata_sync_preview.ado` skeleton
3. Add `preview`/`dryrun` options to sync pathway
4. Test UX with sample users
5. Update help documentation
