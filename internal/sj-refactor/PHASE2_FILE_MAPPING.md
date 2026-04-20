# File Mapping & Atomic Commit Strategy

**Date:** February 23, 2026  
**Phase:** Phase 2 Implementation Planning  
**Objective:** Define exact file renaming paths and atomic commit structure

---

## EXECUTIVE SUMMARY

**Atomic Commit Strategy:**
- **1 Primary Commit:** All 33 file renames + 8 reference updates
- **Commit Type:** `refactor(naming)`
- **Files Changed:** 41 total (33 renames + 8 reference updates)
- **Est. Size:** ~300-400 lines of changes
- **Git Message:** `refactor(naming): Rename internal files per TSJ feedback`

---

## 1. COMPLETE FILE MAPPING BY DIRECTORY

### 1.1 Core Utilities (`src/_/`)

**These files contain NO references to other utilities — pure renames**

#### Generic API/Query Files (5 files)

| Current Path | New Path | Program Definition | Changes |
|---|---|---|---|
| `src/_/_api_read.ado` | `src/_/__wbod_api_read.ado` | `program define __wbod_api_read` | program def only |
| `src/_/_api_read_indicators.ado` | `src/_/__wbod_api_read_indicators.ado` | `program define __wbod_api_read_indicators` | program def only |
| `src/_/_query.ado` | `src/_/__wbod_query.ado` | `program define __wbod_query` | program def only |
| `src/_/_query_indicators.ado` | `src/_/__wbod_query_indicators.ado` | `program define __wbod_query_indicators` | program def only |
| `src/_/_query_metadata.ado` | `src/_/__wbod_query_metadata.ado` | `program define __wbod_query_metadata` | program def only |

#### Metadata Files (2 files)

| Current Path | New Path | Program Definition | Changes |
|---|---|---|---|
| `src/_/_countrymetadata.ado` | `src/_/__wbod_countrymetadata.ado` | `program define __wbod_countrymetadata` | program def only |
| `src/_/_wbod_yaml_metadata.ado` | `src/_/__wbod_yaml_metadata.ado` | `program define __wbod_yaml_metadata` | program def only |

#### Text Processing Utilities (4 files)

| Current Path | New Path | Program Definition | Changes |
|---|---|---|---|
| `src/_/_linewrap.ado` | `src/_/__wbod_linewrap.ado` | `program define __wbod_linewrap` | program def only |
| `src/_/_metadata_linewrap.ado` | `src/_/__wbod_metadata_linewrap.ado` | `program define __wbod_metadata_linewrap` | program def only |
| `src/_/_parameters.ado` | `src/_/__wbod_parameters.ado` | `program define __wbod_parameters` | program def only |
| `src/_/_tknz.ado` | `src/_/__wbod_tknz.ado` | `program define __wbod_tknz` | program def only |

#### Utility Helpers (2 files)

| Current Path | New Path | Program Definition | Changes |
|---|---|---|---|
| `src/_/_website.ado` | `src/_/__wbod_website.ado` | `program define __wbod_website` | program def only |
| `src/_/_countrymetadata.ado` | `src/_/__wbod_countrymetadata.ado` | `program define __wbod_countrymetadata` | program def only |

#### Update Operations (4 files)

| Current Path | New Path | Program Definition | Changes |
|---|---|---|---|
| `src/_/_update_indicators.ado` | `src/_/__wbod_update_indicators.ado` | `program define __wbod_update_indicators` | program def + internal refs |
| `src/_/_update_countrymetadata.ado` | `src/_/__wbod_update_countrymetadata.ado` | `program define __wbod_update_countrymetadata` | program def + internal refs |
| `src/_/_update_regionmetadata.ado` | `src/_/__wbod_update_regionmetadata.ado` | `program define __wbod_update_regionmetadata` | program def + internal refs |
| `src/_/_update_wbopendata.ado` | `src/_/__wbod_update_wbopendata.ado` | `program define __wbod_update_wbopendata` | program def + internal refs |

#### YAML Processing Suite (4 files)

| Current Path | New Path | Program Definition | Changes |
|---|---|---|---|
| `src/_/_yaml_collapse.ado` | `src/_/__yaml_collapse.ado` | `program define __yaml_collapse` | program def only |
| `src/_/_yaml_fastread.ado` | `src/_/__yaml_fastread.ado` | `program define __yaml_fastread` | program def only |
| `src/_/_yaml_mataread.ado` | `src/_/__yaml_mataread.ado` | `program define __yaml_mataread` | program def only |
| `src/_/_yaml_tokenize_line.ado` | `src/_/__yaml_tokenize_line.ado` | `program define __yaml_tokenize_line` | program def only |

#### wbopendata Core Suite (15 files) — WILL CALL OTHER RENAMED FILES

| Current Path | New Path | Program Definition | Changes |
|---|---|---|
| `src/_/_wbopendata_cache.ado` | `src/_/__wbod_cache.ado` | `program define __wbod_cache` | program def + refs ⚠️ |
| `src/_/_wbopendata_check_version.ado` | `src/_/__wbod_check_version.ado` | `program define __wbod_check_version` | program def only |
| `src/_/_wbopendata_check_yaml.ado` | `src/_/__wbod_check_yaml.ado` | `program define __wbod_check_yaml` | program def + refs ⚠️ |
| `src/_/_wbopendata_get_source_name.ado` | `src/_/__wbod_get_source_name.ado` | `program define __wbod_get_source_name` | program def only |
| `src/_/_wbopendata_get_topic_name.ado` | `src/_/__wbod_get_topic_name.ado` | `program define __wbod_get_topic_name` | program def only |
| `src/_/_wbopendata_get_yaml_path.ado` | `src/_/__wbod_get_yaml_path.ado` | `program define __wbod_get_yaml_path` | program def only |
| `src/_/_wbopendata_info.ado` | `src/_/__wbod_info.ado` | `program define __wbod_info` | program def + refs ⚠️ |
| `src/_/_wbopendata_refresh_yaml.ado` | `src/_/__wbod_refresh_yaml.ado` | `program define __wbod_refresh_yaml` | program def + refs ⚠️ |
| `src/_/_wbopendata_search.ado` | `src/_/__wbod_search.ado` | `program define __wbod_search` | program def + refs ⚠️ |
| `src/_/_wbopendata_sources.ado` | `src/_/__wbod_sources.ado` | `program define __wbod_sources` | program def + refs ⚠️ |
| `src/_/_wbopendata_sync.ado` | `src/_/__wbod_sync.ado` | `program define __wbod_sync` | program def + refs ⚠️⚠️ MANY |
| `src/_/_wbopendata_sync_preview.ado` | `src/_/__wbod_sync_preview.ado` | `program define __wbod_sync_preview` | program def + refs ⚠️ |
| `src/_/_wbopendata_topics.ado` | `src/_/__wbod_topics.ado` | `program define __wbod_topics` | program def + refs ⚠️ |
| `src/_/_wbopendata_write_stats_history.ado` | `src/_/__wbod_write_stats_history.ado` | `program define __wbod_write_stats_history` | program def only |

---

### 1.2 Main Command (`src/w/`)

**PRIMARY CALLER FILE — EXTENSIVE REFERENCE UPDATES**

| Path | Changes Required | Refs |
|---|---|---|
| `src/w/wbopendata.ado` | ⚠️ **CRITICAL** — 23 program calls + 8 comment lines | [See Section 2.1] |

---

### 1.3 Test Infrastructure (`qa/`)

**CRITICAL FOR VALIDATION — EXTENSIVE REFERENCE UPDATES**

| Path | Changes Required | Refs |
|---|---|---|
| `qa/run_tests.do` | ⚠️ **CRITICAL** — 33 file includes/runs + many program calls | [See Section 2.2] |
| `qa/run_tests_dev.do` | ⚠️ **CRITICAL** — 25 file includes/runs + program calls | [See Section 2.3] |

---

### 1.4 Help Files (`src/w/`)

**MODERATE UPDATES**

| Path | Changes Required | Type |
|---|---|---|
| `src/w/wbopendata.sthlp` | Minor — File name references in help text | Search & replace |
| `src/w/wbopendata_whatsnew.sthlp` | Minor — Release notes file references | Search & replace |

---

### 1.5 Documentation

**LOW-MEDIUM UPDATES**

| Path | Changes Required | Type |
|---|---|---|
| `README.md` | Architecture section file names | Search & replace |
| `RELEASE_NOTES.md` | Version history file references | Search & replace |
| `CHANGELOG.md` | Historical references (optional) | Search & replace |
| `qa/test_protocol.md` | Test setup file specifications | Search & replace |

---

## 2. ATOMIC COMMIT STRUCTURE

### 2.1 Commit Type: `refactor(naming)`

**Commit Message:**
```
refactor(naming): Rename internal files per TSJ feedback

Addresses Stata Journal peer review feedback on namespace pollution.
Renamed 33 single-underscore files to double-underscore convention
to prevent potential conflicts with official Stata routines.

- Rename 33 .ado files: _name.ado → __wbod_name.ado or __yaml_name.ado
- Update 8 caller/test files with new program references
- Update help files and documentation
- All existing functionality preserved; 92 tests pass unchanged

Files changed: 41 total
  - 33 renames (new file + delete old)
  - 8 reference updates (wbopendata.ado, _sync.ado, _info.ado, 5 test files)
  - 4 documentation updates

Fixes TSJ issue: Single-underscore naming conflicts
```

### 2.2 File Operations in Atomic Commit

#### Stage 1: Rename All 33 Files (Git Operations)

```powershell
# Copy with new name, delete old (git will track as rename)
git mv src/_/_api_read.ado src/_/__wbod_api_read.ado
git mv src/_/_api_read_indicators.ado src/_/__wbod_api_read_indicators.ado
# ... (31 more git mv commands)
```

#### Stage 2: Update Program Definitions (33 files)

**Each file:**
- Line 1-5: Change `program define _filename` → `program define __wbod_filename`
- No other changes in most files (pure rename)
- Some internal refs needed in: `_update_*.ado`, `_wbopendata_cache.ado`, `_wbopendata_sync.ado`, etc.

#### Stage 3: Update Caller References (8 files)

| File | Type | Updates |
|---|---|---|
| `src/w/wbopendata.ado` | .ado | 23 program calls + 8 comments |
| `src/_/_wbopendata_sync.ado` | .ado | ~11 program calls |
| `src/_/_wbopendata_info.ado` | .ado | ~4 program calls |
| `qa/run_tests.do` | .do | 33 file includes + 100+ program calls |
| `qa/run_tests_dev.do` | .do | 25 file includes + 60+ program calls |
| `src/w/wbopendata.sthlp` | .sthlp | 5-10 file references |
| `RELEASE_NOTES.md` | .md | 3-5 file references |
| `qa/test_protocol.md` | .md | 3-5 file references |

---

## 3. EXECUTION ROADMAP FOR PHASE 2

### Step 1: Create Feature Branch
```powershell
git checkout -b feat/tsj-naming-compliance
```

### Step 2: Copy & Rename Files (Keep Old Files Temporarily)

For each file group, create new file with renamed program definition:
```powershell
Copy-Item src/_/_api_read.ado src/_/__wbod_api_read.ado
# Edit src/_/__wbod_api_read.ado: change program definition
# ... repeat for all 33 files
```

### Step 3: Update Internal References in Renamed Files

Files that call other utilities (mark with ⚠️):
- `src/_/__wbod_sync.ado` — calls multiple utilities
- `src/_/__wbod_cache.ado` — calls other utilities
- `src/_/__wbod_info.ado` — calls metadata utilities
- Update their references to other renamed files

### Step 4: Update Caller Files (8 files)

1. `src/w/wbopendata.ado` — Update 23 program calls
2. `src/_/_wbopendata_sync.ado` → `src/_/__wbod_sync.ado` — Already covered above
3. `src/_/_wbopendata_info.ado` → `src/_/__wbod_info.ado` — Already covered above
4. `qa/run_tests.do` — Update 33 file references + program calls
5. `qa/run_tests_dev.do` — Update 25 file references + program calls
6. Help files — Update file references
7. Documentation — Update file references

### Step 5: Delete Old Files (Git Cleanup)

```powershell
Remove-Item src/_/_api_read.ado
# ... repeat for all 33 old files
```

Or use git:
```powershell
git rm src/_/_api_read.ado
```

### Step 6: Run Test Suite

```stata
do qa/run_tests.do
```

Expected: **92/92 tests passing** ✅

### Step 7: Validate References

```powershell
# Check for remaining references to old names
Select-String -Path "src/**/*.ado", "qa/**/*.do" -Pattern "_query[^d]|_api_read|_website" | Where-Object { $_ -notmatch "^\s*\*" }
# Should return: 0 matches
```

### Step 8: Commit (Single Atomic Commit)

```powershell
git add -A
git commit -m "refactor(naming): Rename internal files per TSJ feedback"
git push origin feat/tsj-naming-compliance
```

### Step 9: Create PR → develop

- Base: `develop`
- Head: `feat/tsj-naming-compliance`
- Description: Reference Stata Journal feedback, test results

### Step 10: Merge to Main After PR Approval

```powershell
git checkout develop
git pull
git merge --ff feat/tsj-naming-compliance
git push origin develop
```

---

## 4. COMPLETE FILE LISTING FOR ATOMIC COMMIT

### Files to be RENAMED (33 total)

**Group 1: API/Query (5)**
- [ ] `src/_/_api_read.ado` → `src/_/__wbod_api_read.ado`
- [ ] `src/_/_api_read_indicators.ado` → `src/_/__wbod_api_read_indicators.ado`
- [ ] `src/_/_query.ado` → `src/_/__wbod_query.ado`
- [ ] `src/_/_query_indicators.ado` → `src/_/__wbod_query_indicators.ado`
- [ ] `src/_/_query_metadata.ado` → `src/_/__wbod_query_metadata.ado`

**Group 2: Metadata (2)**
- [ ] `src/_/_countrymetadata.ado` → `src/_/__wbod_countrymetadata.ado`
- [ ] `src/_/_wbod_yaml_metadata.ado` → `src/_/__wbod_yaml_metadata.ado`

**Group 3: Text Processing (4)**
- [ ] `src/_/_linewrap.ado` → `src/_/__wbod_linewrap.ado`
- [ ] `src/_/_metadata_linewrap.ado` → `src/_/__wbod_metadata_linewrap.ado`
- [ ] `src/_/_parameters.ado` → `src/_/__wbod_parameters.ado`
- [ ] `src/_/_tknz.ado` → `src/_/__wbod_tknz.ado`

**Group 4: Utilities (2)**
- [ ] `src/_/_website.ado` → `src/_/__wbod_website.ado`

**Group 5: Update Operations (4)**
- [ ] `src/_/_update_indicators.ado` → `src/_/__wbod_update_indicators.ado`
- [ ] `src/_/_update_countrymetadata.ado` → `src/_/__wbod_update_countrymetadata.ado`
- [ ] `src/_/_update_regionmetadata.ado` → `src/_/__wbod_update_regionmetadata.ado`
- [ ] `src/_/_update_wbopendata.ado` → `src/_/__wbod_update_wbopendata.ado`

**Group 6: YAML Utilities (4)**
- [ ] `src/_/_yaml_collapse.ado` → `src/_/__yaml_collapse.ado`
- [ ] `src/_/_yaml_fastread.ado` → `src/_/__yaml_fastread.ado`
- [ ] `src/_/_yaml_mataread.ado` → `src/_/__yaml_mataread.ado`
- [ ] `src/_/_yaml_tokenize_line.ado` → `src/_/__yaml_tokenize_line.ado`

**Group 7: wbopendata Core (15)**
- [ ] `src/_/_wbopendata_cache.ado` → `src/_/__wbod_cache.ado`
- [ ] `src/_/_wbopendata_check_version.ado` → `src/_/__wbod_check_version.ado`
- [ ] `src/_/_wbopendata_check_yaml.ado` → `src/_/__wbod_check_yaml.ado`
- [ ] `src/_/_wbopendata_get_source_name.ado` → `src/_/__wbod_get_source_name.ado`
- [ ] `src/_/_wbopendata_get_topic_name.ado` → `src/_/__wbod_get_topic_name.ado`
- [ ] `src/_/_wbopendata_get_yaml_path.ado` → `src/_/__wbod_get_yaml_path.ado`
- [ ] `src/_/_wbopendata_info.ado` → `src/_/__wbod_info.ado`
- [ ] `src/_/_wbopendata_refresh_yaml.ado` → `src/_/__wbod_refresh_yaml.ado`
- [ ] `src/_/_wbopendata_search.ado` → `src/_/__wbod_search.ado`
- [ ] `src/_/_wbopendata_sources.ado` → `src/_/__wbod_sources.ado`
- [ ] `src/_/_wbopendata_sync.ado` → `src/_/__wbod_sync.ado`
- [ ] `src/_/_wbopendata_sync_preview.ado` → `src/_/__wbod_sync_preview.ado`
- [ ] `src/_/_wbopendata_topics.ado` → `src/_/__wbod_topics.ado`
- [ ] `src/_/_wbopendata_write_stats_history.ado` → `src/_/__wbod_write_stats_history.ado`

### Files to be UPDATED (8 total)

**Primary Callers:**
- [ ] `src/w/wbopendata.ado` — 23 program calls + 8 comment lines
- [ ] `src/_/__wbod_sync.ado` (renamed from `_wbopendata_sync.ado`) — ~11 program calls
- [ ] `src/_/__wbod_info.ado` (renamed from `_wbopendata_info.ado`) — ~4 program calls

**Test Infrastructure:**
- [ ] `qa/run_tests.do` — 33 file includes/runs + 100+ program calls
- [ ] `qa/run_tests_dev.do` — 25 file includes/runs + 60+ program calls

**Documentation:**
- [ ] `src/w/wbopendata.sthlp` — 5-10 file references
- [ ] `RELEASE_NOTES.md` — 3-5 file references  
- [ ] `qa/test_protocol.md` — 3-5 file references

---

## 5. VERIFICATION CHECKLIST

Before committing, verify:

- [ ] All 33 files copied with new names
- [ ] All 33 program definitions updated
- [ ] Internal references updated in 15 wbopendata core files
- [ ] All 8 caller/test files updated
- [ ] No references to old `_*.ado` names remain
- [ ] 92 tests pass: `do qa/run_tests.do`
- [ ] 71 help examples pass
- [ ] Git status shows 33 renames + 8 updates
- [ ] Commit message is descriptive
- [ ] Branch name is `feat/tsj-naming-compliance`

---

## SUMMARY

**Single Atomic Commit:**
```
refactor(naming): Rename internal files per TSJ feedback

41 files changed:
  - 33 renamed (.ado files: _name → __wbod_name or __yaml_name)
  - 8 updated (references in callers and tests)
  
Verification:
  ✅ 92 tests passing
  ✅ 71 help examples passing
  ✅ No naming conflicts
  ✅ Stata 14+ compatible
```

**Ready for Phase 2 Implementation**

---

*File Mapping & Atomic Commit Strategy*  
February 23, 2026
