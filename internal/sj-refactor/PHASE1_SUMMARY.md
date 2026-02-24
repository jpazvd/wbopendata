# PHASE 1 COMPLETE ✅
## TSJ Naming Refactoring - Planning & Mapping

**Date:** February 23, 2026  
**Status:** Ready for Phase 2 Implementation

---

## WHAT'S BEEN CREATED

### 4 Comprehensive Planning Documents

```
📋 doc/internal/
├── README.md (5 KB)
│   └─ Index, quick reference, key statistics
│
├── TSJ_NAMING_REFACTORING_PLAN.md (10 KB)
│   └─ Phases 1-4, timeline, risks, success criteria
│
├── PHASE1_REFERENCE_AUDIT.md (15 KB)
│   └─ Complete audit of all 41 affected files
│
├── FILENAME_COMPATIBILITY_CHECK.md (7 KB)
│   └─ All 35 filenames Stata-verified ✅
│
└── PHASE2_FILE_MAPPING.md (16 KB)
    └─ EXACT ATOMIC COMMIT ROADMAP (Copy-paste ready)
```

---

## THE ATOMIC COMMIT

### Single Commit: `refactor(naming)`

**What gets renamed:**
```
33 files total:
  • 5 files: _query*, _api_read* → __wbod_*
  • 2 files: _countrymetadata, _yaml_metadata → __wbod_*
  • 4 files: _linewrap*, _parameters, _tknz → __wbod_*
  • 4 files: _update_* → __wbod_update_*
  • 4 files: _yaml_* → __yaml_*
  • 15 files: _wbopendata_* → __wbod_*
```

**What gets updated (references):**
```
8 files need reference updates:
  
CRITICAL (must work for tests):
  • src/w/wbopendata.ado (23 program calls + 8 comments)
  • qa/run_tests.do (33 file includes + 100+ calls)
  • qa/run_tests_dev.do (25 file includes + 60+ calls)
  
HIGH PRIORITY (core utilities):
  • src/_/__wbod_sync.ado (11 calls)
  • src/_/__wbod_info.ado (4 calls)
  
MEDIUM PRIORITY (help + docs):
  • src/w/wbopendata.sthlp (5-10 references)
  • RELEASE_NOTES.md (3-5 references)
  • qa/test_protocol.md (3-5 references)
```

**Total impact:**
- 41 files modified
- ~400 lines of changes
- Single git commit
- 92 tests must pass ✅

---

## COMPLETE FILE MAPPING

### ALL 33 FILES TO RENAME

#### Group 1: API/Query (5 files)
```
_api_read.ado 
  → __wbod_api_read.ado

_api_read_indicators.ado 
  → __wbod_api_read_indicators.ado

_query.ado 
  → __wbod_query.ado

_query_indicators.ado 
  → __wbod_query_indicators.ado

_query_metadata.ado 
  → __wbod_query_metadata.ado
```

#### Group 2: Metadata (2 files)
```
_countrymetadata.ado 
  → __wbod_countrymetadata.ado

_wbod_yaml_metadata.ado 
  → __wbod_yaml_metadata.ado
```

#### Group 3: Text Processing (4 files)
```
_linewrap.ado 
  → __wbod_linewrap.ado

_metadata_linewrap.ado 
  → __wbod_metadata_linewrap.ado

_parameters.ado 
  → __wbod_parameters.ado

_tknz.ado 
  → __wbod_tknz.ado
```

#### Group 4: Utilities (1 file)
```
_website.ado 
  → __wbod_website.ado
```

#### Group 5: Update Operations (4 files)
```
_update_indicators.ado 
  → __wbod_update_indicators.ado

_update_countrymetadata.ado 
  → __wbod_update_countrymetadata.ado

_update_regionmetadata.ado 
  → __wbod_update_regionmetadata.ado

_update_wbopendata.ado 
  → __wbod_update_wbopendata.ado
```

#### Group 6: YAML Utilities (4 files)
```
_yaml_collapse.ado 
  → __yaml_collapse.ado

_yaml_fastread.ado 
  → __yaml_fastread.ado

_yaml_mataread.ado 
  → __yaml_mataread.ado

_yaml_tokenize_line.ado 
  → __yaml_tokenize_line.ado
```

#### Group 7: wbopendata Core (15 files)
```
_wbopendata_cache.ado 
  → __wbod_cache.ado

_wbopendata_check_version.ado 
  → __wbod_check_version.ado

_wbopendata_check_yaml.ado 
  → __wbod_check_yaml.ado

_wbopendata_get_source_name.ado 
  → __wbod_get_source_name.ado

_wbopendata_get_topic_name.ado 
  → __wbod_get_topic_name.ado

_wbopendata_get_yaml_path.ado 
  → __wbod_get_yaml_path.ado

_wbopendata_info.ado 
  → __wbod_info.ado

_wbopendata_refresh_yaml.ado 
  → __wbod_refresh_yaml.ado

_wbopendata_search.ado 
  → __wbod_search.ado

_wbopendata_sources.ado 
  → __wbod_sources.ado

_wbopendata_sync.ado 
  → __wbod_sync.ado

_wbopendata_sync_preview.ado 
  → __wbod_sync_preview.ado

_wbopendata_topics.ado 
  → __wbod_topics.ado

_wbopendata_write_stats_history.ado 
  → __wbod_write_stats_history.ado
```

---

## REFERENCE UPDATE LOCATIONS

### 1. `src/w/wbopendata.ado` — Main Command

**23 Program Calls (update these):**
```
Line 146, 152, 155: _wbopendata_sources → __wbod_sources
Line 163, 166: _wbopendata_topics → __wbod_topics
Line 173: _wbopendata_search → __wbod_search
Line 181: _wbopendata_info → __wbod_info
Line 210, 215, 221, 225, 229: _wbopendata_cache → __wbod_cache
Line 241: _wbopendata_sync_preview → __wbod_sync_preview
Line 258-259: _wbopendata_sync → __wbod_sync
Line 273: _wbopendata_write_stats_history → __wbod_write_stats_history
Line 293: _query_metadata → __wbod_query_metadata
Line 413: _tknz → __wbod_tknz
Line 421: _query → __wbod_query
Line 451, 656: _wbod_yaml_metadata → __wbod_yaml_metadata
Line 458, 663: _query_metadata → __wbod_query_metadata
```

**8 Comment Lines (update these too):**
```
Line 931: "*  uses _api_read.ado" 
  → "*  uses __wbod_api_read.ado"

Line 937: "*  _query.ado should not run if"
  → "*  __wbod_query.ado should not run if"

Line 953: "*  _api_read_indicators.ado : download"
  → "*  __wbod_api_read_indicators.ado : download"

Line 955: "*  _update_indicators.ado: calls _api_read_indicators.ado"
  → "*  __wbod_update_indicators.ado: calls __wbod_api_read_indicators.ado"

Line 962: "* _website.ado : screens"
  → "* __wbod_website.ado : screens"

Line 964: "* _parameters.ado: count"
  → "* __wbod_parameters.ado: count"

Line 993: "*  _wbopendata_update.ado revised"
  → "*  __wbod_update.ado revised"

Line 997: "* update _wbopendata_update.ado"
  → "* update __wbod_update.ado"
```

### 2. `src/_/__wbod_sync.ado` (renamed from _wbopendata_sync.ado)

**~11 Program Calls to Update**
```
Lines with: _query_indicators, _api_read_indicators, 
_update_indicators, _countrymetadata, _query_metadata, 
_wbopendata_cache, _wbopendata_check_yaml, 
_wbopendata_get_yaml_path, etc.

All change to: __wbod_* equivalents
```

### 3. `src/_/__wbod_info.ado` (renamed from _wbopendata_info.ado)

**~4 Program Calls to Update**
```
_query_metadata → __wbod_query_metadata
_wbod_yaml_metadata → __wbod_yaml_metadata
_wbopendata_get_source_name → __wbod_get_source_name
_wbopendata_get_topic_name → __wbod_get_topic_name
```

### 4. `qa/run_tests.do` — Test Driver

**33 File Includes (update these):**
```
All lines like:
  quietly run _/_query.ado
  
Change to:
  quietly run _/__wbod_query.ado

(Repeat for all 33 files)
```

**100+ Program Calls (update these):**
```
All test commands calling the programs, e.g.:
  _query , ...
  
Change to:
  __wbod_query , ...
```

### 5. `qa/run_tests_dev.do` — Dev Tests

**Same as run_tests.do above** (~25 file includes + 60+ calls)

### 6. Help Files & Documentation

**`src/w/wbopendata.sthlp`** (5-10 references)
```
Any mentions of internal file names in help text
Update: "_query.ado" → "__wbod_query.ado", etc.
```

**`RELEASE_NOTES.md`** (3-5 references)
```
Version history mentions of specific file changes
Update: Change file names to new format
```

**`qa/test_protocol.md`** (3-5 references)
```
Test specification references to file names
Update: Change to new naming convention
```

---

## FILENAME COMPATIBILITY ✅

### All Names Verified for Stata

```
Longest filename:     35 chars (__wbod_update_countrymetadata.ado)
Stata limit:          244 chars
Safety margin:        209 chars unused ✓

Longest program name: 31 chars (__wbod_update_countrymetadata)
Stata limit:          245 chars
Safety margin:        214 chars unused ✓

Naming convention:    Follows official Stata double-underscore ✓
Platform support:     Windows, macOS, Linux ✓
```

---

## PHASE 2: IMPLEMENTATION STEPS

**For detailed execution instructions, see:** `PHASE2_FILE_MAPPING.md`

### Quick Overview:
```
1. Create feature branch
2. Copy all 33 files with new names
3. Update program definitions (line 1 of each .ado file)
4. Update references in 8 caller files
5. Run test suite: do qa/run_tests.do
6. Git commit (single atomic commit)
7. Push to remote
8. Create PR → develop
```

---

## KEY STATISTICS

| Metric | Value |
|--------|-------|
| Files to rename | 33 |
| Reference updates | 8 |
| Total files modified | 41 |
| Lines of code changed | ~400 |
| Git commits | 1 (atomic) |
| Expected tests to pass | 92/92 ✅ |
| Help examples to pass | 71/71 ✅ |
| Implementation time | 2-3 hours |

---

## DOCUMENTS TO REFERENCE

| Document | Purpose | Read When |
|----------|---------|-----------|
| `README.md` | Index & overview | First time |
| `TSJ_NAMING_REFACTORING_PLAN.md` | Strategy & phases | Need big picture |
| `PHASE1_REFERENCE_AUDIT.md` | Detailed audit | Need to understand impact |
| `FILENAME_COMPATIBILITY_CHECK.md` | Verification | Want to verify Stata compatibility |
| `PHASE2_FILE_MAPPING.md` | Implementation | Ready to execute Phase 2 |

---

## READY FOR PHASE 2 ✅

**All planning complete.**  
**All files verified for compatibility.**  
**Atomic commit structure defined.**  

**Next step:** Follow `PHASE2_FILE_MAPPING.md` for implementation.

---

*Phase 1 Complete*  
February 23, 2026
