# Phase 1: Complete File Reference Audit

**Date Generated:** February 23, 2026  
**Scope:** wbopendata-dev repository  
**Status:** COMPLETE

---

## 1. EXECUTIVE SUMMARY

### Total Files Requiring Updates
- **Caller files (need reference updates):** 8
- **Total files to rename:** 33
- **Lines of code to change:** ~200-300 (estimate)

### Quick Stats
| Category | Count |
|----------|-------|
| Single-underscore files to rename | 33 |
| Already double-underscore (compliant) | 3 |
| Calling files to update | 8 |
| Estimated implementation time | 2-3 hours |

---

## 2. DETAILED REFERENCE MAP

### 2.1 File `src/w/wbopendata.ado` (Main Command)

**Status:** PRIMARY CALLER - Extensive references  
**Lines affected:** ~100+ lines  
**References found:** 23 distinct utility calls

#### Direct Program Calls (must update):
```
_wbopendata_sources     →  __wbod_sources
_wbopendata_topics      →  __wbod_topics
_wbopendata_search      →  __wbod_search
_wbopendata_info        →  __wbod_info
_wbopendata_cache       →  __wbod_cache
_wbopendata_sync_preview → __wbod_sync_preview
_wbopendata_sync        →  __wbod_sync
_wbopendata_write_stats_history → __wbod_write_stats_history
_query_metadata         →  __wbod_query_metadata
_query                  →  __wbod_query
_wbod_yaml_metadata     →  __wbod_yaml_metadata
_tknz                   →  __wbod_tknz
_linewrap               →  (used in linewrap processing, internal)
_parameters             →  __wbod_parameters
```

#### Comment References (need updating):
```
Line 931: "*       rewrote query metadata. It now uses _api_read.ado"
Line 937: "*    add flow check before runing _query.ado /_query.ado should not run if"
Line 953: "*  _api_read_indicators.ado : download indicator list from API"
Line 955: "*  _update_indicators.ado: calls _api_read_indicators.ado"
Line 962: "* _website.ado : screens a text file..."
Line 964: "* _parameters.ado: now include detailed count..."
Line 993: "*              _wbopendata_update.ado revised"
Line 997: "*              update _wbopendata_update.ado"
```

#### Sample Lines (wbopendata.ado):
```stata
Line 146:    noisily _wbopendata_sources, limit(`limit_val')
Line 152:    noisily _wbopendata_sources, limit(`limit_val')
Line 155:    noisily _wbopendata_sources
Line 163:    noisily _wbopendata_topics, limit(`limit_val')
Line 173:    noisily _wbopendata_search "`search'", limit(`limit_val') ///
Line 181:    capture noisily _wbopendata_info, indicator("`info'")
Line 210:    _wbopendata_cache, cleardatacache
Line 215:    _wbopendata_cache, resetdatacache
Line 221:    _wbopendata_cache, clear
Line 225:    _wbopendata_cache, info
Line 229:    _wbopendata_cache, checkversion
Line 241:    noi _wbopendata_sync_preview, `detail'
Line 258:    if ("`force'" != "") _wbopendata_sync, force
Line 259:    else _wbopendata_sync
Line 263:    quietly _wbopendata_sync_preview
Line 273:    capture quietly _wbopendata_write_stats_history,
Line 293:    noi _query_metadata , indicator("`indicator'") `_lw_opts'
Line 413:    _tknz "`indicator'" , parse(;)
Line 421:    noi _query , language("`language'")
Line 451:    cap noi _wbod_yaml_metadata, indicator("``i''") frame(_wbod_indicators)
Line 458:    cap: noi _query_metadata , indicator("``i''") `_lw_opts'
Line 625:    noi _query , language("`language'")
Line 656:    cap noi _wbod_yaml_metadata, indicator("``i''") frame(_wbod_indicators)
Line 663:    cap: noi _query_metadata , indicator("``i''") `_lw_opts'
```

---

### 2.2 File `src/_/_wbopendata_sync.ado` (Sync Provider)

**Status:** SECONDARY CALLER - Moderate references  
**References found:** 8+ utility calls  
**Will be renamed to:** `__wbod_sync.ado`

#### Direct Calls to Update:
```
_wbopendata_cache           →  __wbod_cache
_wbopendata_check_yaml      →  __wbod_check_yaml
_wbopendata_get_yaml_path   →  __wbod_get_yaml_path
_query_indicators           →  __wbod_query_indicators
_api_read_indicators        →  __wbod_api_read_indicators
_update_indicators          →  __wbod_update_indicators
_update_countrymetadata     →  __wbod_update_countrymetadata
_update_regionmetadata      →  __wbod_update_regionmetadata
_query_metadata             →  __wbod_query_metadata
_tknz                       →  __wbod_tknz
_countrymetadata            →  __wbod_countrymetadata
```

---

### 2.3 File `src/_/_wbopendata_info.ado` (Info Command)

**Status:** SECONDARY CALLER - Moderate references  
**References found:** 4+ utility calls

#### Direct Calls to Update:
```
_query_metadata             →  __wbod_query_metadata
_wbod_yaml_metadata         →  __wbod_yaml_metadata
_wbopendata_get_source_name → __wbod_get_source_name
_wbopendata_get_topic_name  → __wbod_get_topic_name
```

---

### 2.4 File `qa/run_tests.do` (Test Driver)

**Status:** CRITICAL FOR TESTING - Extensive program calls  
**References found:** All 33 utility files referenced in test setup/execution

#### Pattern 1: Setup phase includes/runs
```
run _/_api_read.ado              →  run _/__wbod_api_read.ado
run _/_query.ado                 →  run _/__wbod_query.ado
run _/_wbod_yaml_metadata.ado    →  run _/__wbod_yaml_metadata.ado
... (31 more files)
```

#### Pattern 2: Program calls throughout tests
```
_api_read , ...                 →  __wbod_api_read , ...
_query , ...                    →  __wbod_query , ...
_wbopendata_cache , ...         →  __wbod_cache , ...
... (many more)
```

---

### 2.5 File `qa/run_tests_dev.do` (Development Tests)

**Status:** SECONDARY TEST DRIVER  
**References:** Similar to run_tests.do + development-specific utilities

#### Changes Required:
- Same utility file references as run_tests.do
- ~50-70 lines affected

---

### 2.6 Help Files

#### `src/w/wbopendata.sthlp` (Main Help)
**Status:** MODERATE UPDATES  
**Content:** May contain command documentation referencing internal structure  
**Action needed:** Search for specific file names in help text

#### `src/w/wbopendata_whatsnew.sthlp` (What's New)
**Status:** MODERATE UPDATES  
**Content:** Release notes may mention specific file names  
**Action needed:** Update version history references

---

### 2.7 Documentation Files

#### `README.md`
**Status:** Low priority  
**References:** High-level architecture overview (may mention file structure)

#### `RELEASE_NOTES.md`
**Status:** Moderate  
**References:** Version history mentions of specific features/files

#### `CHANGELOG.md`
**Status:** Low (historical)  
**References:** Old version entries may reference deprecated files

#### `qa/test_protocol.md`
**Status:** Moderate  
**References:** Test documentation may specify file names in test setup

#### `qa/test_history.txt`
**Status:** Low (informational)  
**References:** Historical test run records (no functional impact)

---

### 2.8 Article/External Files

#### Stata Journal Submission Files
**Status:** HIGH PRIORITY  
**Path:** `paper/` directory  
**Content:** Code examples, architecture sections mentioning file names

#### Action Required:
- Search PDF/LaTeX for `_query`, `_website`, `_api_read` references
- Update any code snippets showing internal file structure
- Update figure captions or article text referencing file organization

---

## 3. REFERENCE COUNT BY FILE

### Complete Caller File Breakdown

| Source File | File Type | Refs | Priority | Est. Changes |
|---|---|---|---|---|
| `src/w/wbopendata.ado` | .ado | 23 | HIGH | 40-50 lines |
| `src/_/_wbopendata_sync.ado` | .ado | 11 | HIGH | 20-30 lines |
| `src/_/_wbopendata_info.ado` | .ado | 4 | HIGH | 8-12 lines |
| `qa/run_tests.do` | .do | 33 | CRITICAL | 80-100 lines |
| `qa/run_tests_dev.do` | .do | 25 | CRITICAL | 60-80 lines |
| `src/w/wbopendata.sthlp` | .sthlp | 2-5 | MEDIUM | 5-10 lines |
| `results/RELEASE_NOTES.md` | .md | 3-5 | MEDIUM | 5-10 lines |
| `paper/` (article) | .tex/.pdf | 5-10 | HIGH | 10-20 lines |
| **TOTAL** | | **100-110** | | **230-310 lines** |

---

## 4. CRITICAL FINDINGS

### 4.1 Program Definition Changes Required (33 files)

Each `.ado` file contains: `program define _filename , ...`

**Must change to:** `program define __wbod_filename , ...`  
**Or:** `program define __yaml_filename , ...` (for YAML utilities)

**Example:**
```stata
--- BEFORE ---
program define _query, rclass
...
end

--- AFTER ---
program define __wbod_query, rclass
...
end
```

### 4.2 Include/Run Statements

Inside `.ado` and `.do` files (if present):
```stata
--- BEFORE ---
run "_/query.ado"
include "_/_query.ado"
`" run _/_api_read.ado "'

--- AFTER ---
run "_/__wbod_query.ado"
include "_/__wbod_query.ado"
`" run _/__wbod_api_read.ado "'
```

### 4.3 sysdir_plus References

Some files may reference cache paths:
```stata
--- BEFORE ---
findfile _query.ado
global qpath = r(fn)

--- AFTER ---
findfile __wbod_query.ado
global qpath = r(fn)
```

### 4.4 mata: blocks

If any Mata code references Stata programs by name, update:
```mata
--- BEFORE ---
stata("_query ,...")

--- AFTER ---
stata("__wbod_query ,...")
```

---

## 5. VALIDATION STRATEGY

### Pre-Rename Checks
- [ ] Create git branch: `feat/tsj-naming-compliance`
- [ ] Backup current version
- [ ] Count exact references (before): `grep -r "_query\|_website\|_api_read" src/ qa/`

### During Rename
- [ ] Rename all 33 files (copy + delete)
- [ ] Update program definitions
- [ ] Update caller references (8 files)
- [ ] Check for includes/runs inside .ado files
- [ ] Search for string literals containing old names

### Post-Rename Validation
- [ ] Count references (after) should = 0
- [ ] Run full test suite: `do qa/run_tests.do`
  - [ ] All 92 tests passing
  - [ ] All 71 help examples passing
- [ ] No error logs in stderr

### Git Validation
- [ ] Single atomic commit with all changes
- [ ] Commit message: `refactor(naming): Rename internal files per TSJ feedback`
- [ ] No loose files left behind

---

## 6. DISCOVERED CALL CHAIN

```
wbopendata.ado (main entry)
├─ OPTIONS PARSING
│  └─ _tknz (tokenize indicators)              [Line 413]
│
├─ SOURCES/TOPICS DISCOVERY
│  ├─ _wbopendata_sources (discovery)          [Line 146-155]
│  ├─ _wbopendata_topics (discovery)           [Line 163-166]
│  └─ _wbopendata_search (text search)         [Line 173]
│
├─ INFO COMMAND
│  └─ _wbopendata_info (indicator metadata)    [Line 181]
│
├─ CACHE MANAGEMENT
│  ├─ _wbopendata_cache:clear
│  ├─ _wbopendata_cache:info
│  ├─ _wbopendata_cache:checkversion
│  ├─ _wbopendata_cache:cleardatacache
│  └─ _wbopendata_cache:resetdatacache
│
├─ SYNC OPERATIONS
│  ├─ _wbopendata_sync_preview                 [Line 241]
│  └─ _wbopendata_sync                         [Lines 258-259]
│      └─ (calls many utilities internally)
│
├─ DATA QUERY (main path)
│  ├─ _query_metadata (download + linewrap metadata)  [Line 293, 458, 663]
│  │  └─ _linewrap (internal text wrap)
│  │
│  ├─ _query (API query + download)            [Line 421, 625]
│  │  └─ (calls other utilities internally)
│  │
│  ├─ _wbod_yaml_metadata (YAML lookup)        [Line 451, 656]
│  │  └─ (accesses cached YAML frame)
│  │
│  └─ _parameters (option parsing)             [Line 964, comment]
│
└─ POST-PROCESSING
   └─ _wbopendata_write_stats_history          [Line 273]
```

---

## 7. MAPPING TABLE: OLD → NEW (All 33 Files)

### Single-underscore → Double-underscore Mapping

| Group | Old Name | New Name | Program Def Must Change |
|-------|----------|----------|--------------------------|
| **Critical** | _api_read.ado | __wbod_api_read.ado | YES |
| | _api_read_indicators.ado | __wbod_api_read_indicators.ado | YES |
| | _countrymetadata.ado | __wbod_countrymetadata.ado | YES |
| | _query.ado | __wbod_query.ado | YES |
| | _query_indicators.ado | __wbod_query_indicators.ado | YES |
| | _query_metadata.ado | __wbod_query_metadata.ado | YES |
| | _website.ado | __wbod_website.ado | YES |
| **Text Utils** | _linewrap.ado | __wbod_linewrap.ado | YES |
| | _metadata_linewrap.ado | __wbod_metadata_linewrap.ado | YES |
| | _parameters.ado | __wbod_parameters.ado | YES |
| | _tknz.ado | __wbod_tknz.ado | YES |
| **Update Ops** | _update_countrymetadata.ado | __wbod_update_countrymetadata.ado | YES |
| | _update_indicators.ado | __wbod_update_indicators.ado | YES |
| | _update_regionmetadata.ado | __wbod_update_regionmetadata.ado | YES |
| | _update_wbopendata.ado | __wbod_update_wbopendata.ado | YES |
| **YAML Utils** | _yaml_collapse.ado | __yaml_collapse.ado | YES |
| | _yaml_fastread.ado | __yaml_fastread.ado | YES |
| | _yaml_mataread.ado | __yaml_mataread.ado | YES |
| | _yaml_tokenize_line.ado | __yaml_tokenize_line.ado | YES |
| **wbopendata Core** | _wbod_yaml_metadata.ado | __wbod_yaml_metadata.ado | YES |
| | _wbopendata_cache.ado | __wbod_cache.ado | YES |
| | _wbopendata_check_version.ado | __wbod_check_version.ado | YES |
| | _wbopendata_check_yaml.ado | __wbod_check_yaml.ado | YES |
| | _wbopendata_get_source_name.ado | __wbod_get_source_name.ado | YES |
| | _wbopendata_get_topic_name.ado | __wbod_get_topic_name.ado | YES |
| | _wbopendata_get_yaml_path.ado | __wbod_get_yaml_path.ado | YES |
| | _wbopendata_info.ado | __wbod_info.ado | YES |
| | _wbopendata_refresh_yaml.ado | __wbod_refresh_yaml.ado | YES |
| | _wbopendata_search.ado | __wbod_search.ado | YES |
| | _wbopendata_sources.ado | __wbod_sources.ado | YES |
| | _wbopendata_sync.ado | __wbod_sync.ado | YES |
| | _wbopendata_sync_preview.ado | __wbod_sync_preview.ado | YES |
| | _wbopendata_topics.ado | __wbod_topics.ado | YES |
| | _wbopendata_write_stats_history.ado | __wbod_write_stats_history.ado | YES |

---

## 8. NEXT STEPS (Phase 2)

See `TSJ_NAMING_REFACTORING_PLAN.md` for implementation sequence.

**Immediate actions:**
1. Create feature branch
2. Copy all 33 files with new names
3. Update program definitions in each file
4. Update caller references in 8 files
5. Run test suite
6. Validate all 92 + 71 tests pass
7. Single atomic commit
8. Resubmit to Stata Journal

---

## Appendix: Shell Commands for Validation

### Count references (before rename)
```bash
grep -r "_query\|_website\|_api_read\|_wbopendata_\|_yaml_" \
  src/ qa/ --include="*.ado" --include="*.do" | wc -l
```

### Find specific file callers
```bash
grep -r "_query\.ado\|run _/_query" src/ qa/ --include="*.ado" --include="*.do"
```

### Verify all renames complete
```bash
find src -name "_*.ado" -type f | wc -l  # Should be 0 after rename
```

### Test suite run
```stata
do qa/run_tests.do
```

---

**Document End**  
*Generated by Phase 1 Audit - Feb 23, 2026*
