# TSJ File Naming Compliance Refactoring Plan

**Document Date:** February 23, 2026  
**Status:** Planning Phase  
**Priority:** High (blocking Stata Journal submission resubmission)  
**Scope:** Complete rename of 33 single-underscore `.ado` files to double-underscore naming convention

---

## 1. BACKGROUND & RATIONALE

### TSJ Editorial Feedback
The Stata Journal peer review team flagged potential naming conflicts with official Stata routines due to underscore-prefixed filenames (e.g., `_query.ado`, `_website.ado`, `_api_read.ado`).

**Risk:** File lookup collisions with reserved Stata paths and official packages.

**Solution:** Adopt double-underscore prefix convention (`__wbod_*`, `__yaml_*`) already in use by 3 existing files (`__wbod_parse_yaml_ind.ado`, `__wbopendata_search.ado`, etc.).

### Current State
- **Files with single underscore:** 33 total
- **Files with double underscore:** 3 (already compliant)
- **Generic names (highest concern):** `_query.ado`, `_website.ado`, `_api_read.ado` (collision risk)

---

## 2. PHASE 1: INVENTORY & MAPPING (This Phase)

### 2.1 File Categories

#### **Critical/Generic Names (TSJ Primary Concern)**
These are common names with high collision risk:

| Current Name | New Name | Type | Rationale |
|---|---|---|---|
| `_query.ado` | `__wbod_query.ado` | Core API | Generic query name |
| `_website.ado` | `__wbod_website.ado` | Utility | Generic web term |
| `_api_read.ado` | `__wbod_api_read.ado` | API | Generic API name |
| `_api_read_indicators.ado` | `__wbod_api_read_indicators.ado` | API | Generic API variant |
| `_countrymetadata.ado` | `__wbod_countrymetadata.ado` | Metadata | Could conflict with user code |

#### **Query/Metadata Utilities**

| Current Name | New Name | Type |
|---|---|---|
| `_query_indicators.ado` | `__wbod_query_indicators.ado` | Query variant |
| `_query_metadata.ado` | `__wbod_query_metadata.ado` | Query variant |
| `_tknz.ado` | `__wbod_tknz.ado` | Tokenizer |
| `_update_countrymetadata.ado` | `__wbod_update_countrymetadata.ado` | Updater |
| `_update_indicators.ado` | `__wbod_update_indicators.ado` | Updater |
| `_update_regionmetadata.ado` | `__wbod_update_regionmetadata.ado` | Updater |
| `_update_wbopendata.ado` | `__wbod_update_wbopendata.ado` | Updater |

#### **Text Processing Utilities**

| Current Name | New Name | Type |
|---|---|---|
| `_linewrap.ado` | `__wbod_linewrap.ado` | Text wrap |
| `_metadata_linewrap.ado` | `__wbod_metadata_linewrap.ado` | Text wrap variant |
| `_parameters.ado` | `__wbod_parameters.ado` | Parameter handling |

#### **YAML Processing Suite**

| Current Name | New Name | Type | Rationale |
|---|---|---|---|
| `_yaml_collapse.ado` | `__yaml_collapse.ado` | YAML utility | Use `__yaml_` prefix for clarity |
| `_yaml_fastread.ado` | `__yaml_fastread.ado` | YAML reader | Generic name, use `__yaml_` |
| `_yaml_mataread.ado` | `__yaml_mataread.ado` | YAML Mata reader | Use `__yaml_` |
| `_yaml_tokenize_line.ado` | `__yaml_tokenize_line.ado` | YAML tokenizer | Use `__yaml_` |

#### **wbopendata Core Suite (Already Prefixed)**

| Current Name | New Name | Reason for Change |
|---|---|---|
| `_wbod_yaml_metadata.ado` | `__wbod_yaml_metadata.ado` | Standardize double-underscore |
| `_wbopendata_cache.ado` | `__wbod_cache.ado` | Simplify prefix (optional) |
| `_wbopendata_check_version.ado` | `__wbod_check_version.ado` | Simplify prefix |
| `_wbopendata_check_yaml.ado` | `__wbod_check_yaml.ado` | Simplify prefix |
| `_wbopendata_get_source_name.ado` | `__wbod_get_source_name.ado` | Simplify prefix |
| `_wbopendata_get_topic_name.ado` | `__wbod_get_topic_name.ado` | Simplify prefix |
| `_wbopendata_get_yaml_path.ado` | `__wbod_get_yaml_path.ado` | Simplify prefix |
| `_wbopendata_info.ado` | `__wbod_info.ado` | Simplify prefix |
| `_wbopendata_refresh_yaml.ado` | `__wbod_refresh_yaml.ado` | Simplify prefix |
| `_wbopendata_search.ado` | `__wbod_search.ado` | Simplify prefix |
| `_wbopendata_sources.ado` | `__wbod_sources.ado` | Simplify prefix |
| `_wbopendata_sync.ado` | `__wbod_sync.ado` | Simplify prefix |
| `_wbopendata_sync_preview.ado` | `__wbod_sync_preview.ado` | Simplify prefix |
| `_wbopendata_topics.ado` | `__wbod_topics.ado` | Simplify prefix |
| `_wbopendata_write_stats_history.ado` | `__wbod_write_stats_history.ado` | Simplify prefix |
| `_website.ado` | (see Critical section) | Already listed |

**Total renames: 33 files**

---

### 2.2 File Reference Audit

#### **Files Requiring Update (Calling References)**

**Primary callers:**
1. `src/w/wbopendata.ado` — Main command file; calls most internal utilities
2. `src/_/_wbopendata_sync.ado` — Calls cache/sync utilities (note: will be renamed)
3. `src/_/_wbopendata_info.ado` — Calls metadata utilities (note: will be renamed)

**Test infrastructure:**
4. `qa/run_tests.do` — Master test driver; calls all internal commands
5. `qa/run_tests_dev.do` — Development test variant

**Help files:**
6. `src/w/wbopendata.sthlp` — Main help; may document internal structure
7. `src/w/wbopendata_whatsnew.sthlp` — Release notes reference changes

**Documentation:**
8. `RELEASE_NOTES.md` — References specific files/features
9. `CHANGELOG.md` — Historic references
10. `README.md` — File structure overview
11. `qa/test_protocol.md` — Test file specifications

**Article & External:**
12. `paper/*.tex` / `paper/*.pdf` — Stata Journal submission (if mentions structure)
13. `doc/internal/*.md` — Any internal documentation

---

### 2.3 Dependency Graph (Key Call Chains)

```
wbopendata.ado (main command)
├─ _query.ado               → convert to __wbod_query.ado
├─ _website.ado             → convert to __wbod_website.ado
├─ _wbopendata_sync.ado     → convert to __wbod_sync.ado
│   ├─ _wbopendata_cache.ado     → convert to __wbod_cache.ado
│   ├─ _wbopendata_check_yaml.ado → convert to __wbod_check_yaml.ado
│   └─ ...
├─ _wbopendata_info.ado      → convert to __wbod_info.ado
│   ├─ _query_metadata.ado    → convert to __wbod_query_metadata.ado
│   └─ ...
└─ [Other utilities...]

qa/run_tests.do
├─ run __wbod_*.ado (all internal files)
└─ run __yaml_*.ado (all YAML utilities)
```

---

## 3. PHASE 2: FILE RENAMING (Next Phase)

### 3.1 Renaming Steps

1. **Copy phase:** Duplicate all 33 files with new names
2. **Update program definitions:** Change `program define _name` → `program define __wbod_name`
3. **Update mata blocks:** Update any `mata: ...` blocks referencing old names
4. **Update includes:** Any `include` statements referencing old files
5. **Test:** Ensure new files are callable
6. **Verification:** Run test suite to confirm functionality
7. **Delete phase:** Remove old single-underscore files
8. **Commit:** Single atomic commit with all changes

### 3.2 Files to Update (References)

See section 2.2 — approximately 11 files require reference updates.

---

## 4. PHASE 3: DOCUMENTATION UPDATES

- Article: Update code structure sections if necessary
- Help files: Update any internal file references
- RELEASE_NOTES.md: Add v18.3.3 entry documenting naming refactoring
- README.md: Update file structure/architecture diagrams
- Test protocol: Update expected file listings

---

## 5. VALIDATION CHECKLIST

- [ ] All 33 files renamed
- [ ] All `program define` statements match new names
- [ ] All calling references in 11 files updated
- [ ] 92 tests passing
- [ ] 71 help examples passing
- [ ] No residual references to old file names
- [ ] Git log shows single atomic commit
- [ ] Article updated for resubmission
- [ ] Version bumped to 18.3.3

---

## 6. TIMELINE

| Phase | Task | Estimated Time |
|-------|------|-----------------|
| Phase 1 | Audit & mapping (THIS) | 30 min |
| Phase 2 | Rename files & update refs | 2-3 hours |
| Phase 2b | Run full test suite | 30-45 min |
| Phase 3 | Documentation & article | 1-2 hours |
| Phase 4 | Validation & commit | 30 min |
| **Total** | | **4.5-6.5 hours** |

---

## 7. RISKS & MITIGATION

| Risk | Mitigation |
|------|-----------|
| Missed file references | Search codebase for old names before deletion |
| Test failures | Run full suite (92 + 71) after renaming |
| Article re-review | Ensure article reflects new structure accurately |
| Commit size | Keep as single atomic commit (≤400 lines diff) |

---

## 8. SUCCESS CRITERIA

✅ **Project complete when:**
1. All 33 files renamed across wbopendata-dev
2. All references updated (11 files)
3. 92 tests + 71 help examples passing
4. Article updated and ready for resubmission
5. v18.3.3 release tag created
6. Push to GitHub with clean commit history

---

## Appendix: Complete File Listing

### Single-Underscore Files (33 total)

**By Directory:**

**`src/_/` (Generic utilities - 13 files):**
```
_api_read.ado
_api_read_indicators.ado
_countrymetadata.ado
_linewrap.ado
_metadata_linewrap.ado
_parameters.ado
_query.ado
_query_indicators.ado
_query_metadata.ado
_tknz.ado
_update_countrymetadata.ado
_update_indicators.ado
_update_regionmetadata.ado
_update_wbopendata.ado
_website.ado
_yaml_collapse.ado
_yaml_fastread.ado
_yaml_mataread.ado
_yaml_tokenize_line.ado
```

**`src/_/` (wbopendata prefixed - 16 files):**
```
_wbod_yaml_metadata.ado
_wbopendata_cache.ado
_wbopendata_check_version.ado
_wbopendata_check_yaml.ado
_wbopendata_get_source_name.ado
_wbopendata_get_topic_name.ado
_wbopendata_get_yaml_path.ado
_wbopendata_info.ado
_wbopendata_refresh_yaml.ado
_wbopendata_search.ado
_wbopendata_sources.ado
_wbopendata_sync.ado
_wbopendata_sync_preview.ado
_wbopendata_topics.ado
_wbopendata_write_stats_history.ado
```

**Already with double underscore (compliant - 3 files):**
```
__wbod_parse_yaml_ind.ado
__wbod_parse_yaml_ind_v2.ado
__wbopendata_search_cache.ado
```

