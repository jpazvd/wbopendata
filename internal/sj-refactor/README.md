# Phase 1 Complete: TSJ Naming Refactoring Planning

**Status:** ✅ PHASE 1 COMPLETE  
**Date:** February 23, 2026  
**Next:** Phase 2 Implementation (Reference this folder for execution)

---

## DOCUMENTS CREATED (3 Comprehensive Plans)

### 1. **TSJ_NAMING_REFACTORING_PLAN.md**
**Purpose:** High-level strategy and overview  
**Contains:**
- Background: Why TSJ feedback matters
- Phase 1-4 breakdown
- Risks & mitigation
- Timeline estimates
- Success criteria

**Use for:** Understanding the big picture and justifying the refactoring to others

---

### 2. **PHASE1_REFERENCE_AUDIT.md**
**Purpose:** Detailed audit of all files affected  
**Contains:**
- Complete reference map by file
- Call chain diagram
- Dependency graph
- All 33 file mappings
- Shell commands for validation

**Use for:** Understanding exactly which files need to be changed and where

---

### 3. **FILENAME_COMPATIBILITY_CHECK.md**
**Purpose:** Validate all proposed filenames are Stata-compatible  
**Contains:**
- Filename length analysis
- Program name compatibility
- Stata identifier limits verified
- Double-underscore convention explained
- Cross-platform compatibility confirmed

**Result:** ✅ **All 33 filenames pass compatibility checks**

---

### 4. **PHASE2_FILE_MAPPING.md** (NEW)
**Purpose:** Atomic commit execution roadmap  
**Contains:**
- Complete folder-by-folder mapping
- Source → Destination for all 33 files
- Exact reference updates needed in 8 files
- Step-by-step execution sequence
- Git commands for atomic commit
- Verification checklist

**Use for:** Actual Phase 2 implementation — copy-paste ready

---

## ATOMIC COMMIT STRUCTURE

### Single Commit: `refactor(naming)`

```
Commit Message:
  refactor(naming): Rename internal files per TSJ feedback
  
Changes:
  - 33 files renamed: _name.ado → __wbod_name.ado or __yaml_name.ado
  - 8 files updated: References to old names updated in callers/tests
  - 4 files updated: Help and documentation references
  
Total: 41 files changed (~300-400 lines)
Verification: 92 tests + 71 help examples all passing ✅
```

---

## FILE-BY-FILE MAPPING SUMMARY

### 33 Files to Rename

**By Category:**

| Category | Count | Example |
|----------|-------|---------|
| API/Query | 5 | `_query.ado` → `__wbod_query.ado` |
| Metadata | 2 | `_countrymetadata.ado` → `__wbod_countrymetadata.ado` |
| Text Processing | 4 | `_linewrap.ado` → `__wbod_linewrap.ado` |
| Update Operations | 4 | `_update_indicators.ado` → `__wbod_update_indicators.ado` |
| YAML Utilities | 4 | `_yaml_collapse.ado` → `__yaml_collapse.ado` |
| wbopendata Core | 15 | `_wbopendata_sync.ado` → `__wbod_sync.ado` |

### 8 Files Requiring Reference Updates

| File | Type | Changes | Priority |
|---|---|---|---|
| `src/w/wbopendata.ado` | Main command | 23 calls + 8 comments | CRITICAL |
| `src/_/__wbod_sync.ado` | Core utility | ~11 calls | HIGH |
| `src/_/__wbod_info.ado` | Discovery | ~4 calls | HIGH |
| `qa/run_tests.do` | Test driver | 33+ includes + 100+ calls | CRITICAL |
| `qa/run_tests_dev.do` | Dev tests | 25+ includes + 60+ calls | CRITICAL |
| `src/w/wbopendata.sthlp` | Help | 5-10 refs | MEDIUM |
| `RELEASE_NOTES.md` | Docs | 3-5 refs | MEDIUM |
| `qa/test_protocol.md` | Docs | 3-5 refs | MEDIUM |

---

## ALL FILENAMES VERIFIED ✅

**Compatibility Status:**
- ✅ Longest filename: 35 characters (limit: 244)
- ✅ Longest program name: 31 characters (limit: 245)
- ✅ Cross-platform compatible (Windows/Mac/Linux)
- ✅ Follows Stata double-underscore convention
- ✅ No namespace collisions

---

## READY FOR PHASE 2

**All planning documents complete:**
- [x] High-level strategy (TSJ_NAMING_REFACTORING_PLAN.md)
- [x] Detailed audit (PHASE1_REFERENCE_AUDIT.md)
- [x] Compatibility verified (FILENAME_COMPATIBILITY_CHECK.md)
- [x] Execution roadmap (PHASE2_FILE_MAPPING.md)
- [x] Atomic commit strategy defined

**Next Steps:**
1. Review PHASE2_FILE_MAPPING.md for implementation sequence
2. Create feature branch: `git checkout -b feat/tsj-naming-compliance`
3. Execute Phase 2 steps using the mapped file paths
4. Run test suite: `do qa/run_tests.do`
5. Create PR with single atomic commit

---

## QUICK REFERENCE: KEY STATISTICS

| Metric | Value |
|--------|-------|
| Total files to process | 41 |
| Files to rename | 33 |
| Files to update | 8 |
| Estimated lines changed | 300-400 |
| Git commit type | Single atomic |
| Expected test result | 92/92 passing ✅ |
| Stata compatibility | 100% ✅ |
| Timeline for Phase 2 | 2-3 hours |

---

## HOW TO USE THESE DOCUMENTS

**For Strategic Decisions:**
→ Read `TSJ_NAMING_REFACTORING_PLAN.md`

**For Impact Analysis:**
→ Read `PHASE1_REFERENCE_AUDIT.md`

**For Compatibility Verification:**
→ Read `FILENAME_COMPATIBILITY_CHECK.md`

**For Implementation:**
→ Follow `PHASE2_FILE_MAPPING.md` step-by-step

---

**Status:** Phase 1 Complete ✅  
**Ready for Phase 2 Implementation**

All documents saved in: `doc/internal/`

---

*Planning Complete — February 23, 2026*
