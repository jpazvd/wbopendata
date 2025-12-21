# Issue Resolution Plan

[← Back to README](../../README.md) | [FAQ](../FAQ.md) | [Improvement Plan](IMPROVEMENT_PLAN.md)

---

## Overview

This document tracks the resolution of open GitHub issues for `wbopendata`.

**Branch:** `fix/issues-and-docs`  
**Created:** December 21, 2025

---

## Issues Fixed in v17.1 (Ready to Close)

The following issues were fixed in the recent merge to `main`:

| Issue | Title | Reporter | Fix Commit | Status |
|-------|-------|----------|------------|--------|
| [#33](https://github.com/jpazvd/wbopendata/issues/33) | Option -latest- breaks when indicator names are too long | @dianagold | `afa1eef` | ✅ Close |
| [#35](https://github.com/jpazvd/wbopendata/issues/35) | Country metadata sub-options are not working | @jpazvd | `a67eb51` | ✅ Close |
| [#45](https://github.com/jpazvd/wbopendata/issues/45) | Error when displaying metadata that contain a url link | @SylWeber | `b967d2d` | ✅ Close |
| [#46](https://github.com/jpazvd/wbopendata/issues/46) | Can't run update check/all, returns "varlist not allowed" | @cuannzy | `ca63aa6` | ✅ Close |
| [#51](https://github.com/jpazvd/wbopendata/issues/51) | Documentation for "match" option not up to date | @claradaia | `1e770b8` | ✅ Close |

---

## Open Issues - Triage

### 🔴 HIGH Priority (Blocking functionality)

| Issue | Title | Reporter | Category | Plan |
|-------|-------|----------|----------|------|
| [#54](https://github.com/jpazvd/wbopendata/issues/54) | Issue from importing number of countries | @Koko-Clovis | Bug | Investigate API response parsing |
| [#39](https://github.com/jpazvd/wbopendata/issues/39) | Source doesn't appear in metadata | @ckrf | Bug | Check `_query_metadata.ado` |

### 🟡 MEDIUM Priority (User experience)

| Issue | Title | Reporter | Category | Plan |
|-------|-------|----------|----------|------|
| [#48](https://github.com/jpazvd/wbopendata/issues/48) | Unemployment rates indicators shows red text | @flxflks | Display | Review SMCL formatting |
| [#47](https://github.com/jpazvd/wbopendata/issues/47) | AFE and AFW should be marked as Aggregates | @JavierParada | Metadata | Update country classification |
| [#49](https://github.com/jpazvd/wbopendata/issues/49) | How do we specify the version of the WDI dataset? | @yukinko-iwasaki | Feature/Doc | Document API versioning |

### 🟢 LOW Priority (Enhancement / Historical)

| Issue | Title | Reporter | Category | Plan |
|-------|-------|----------|----------|------|
| [#38](https://github.com/jpazvd/wbopendata/issues/38) | Problem updating indicators | @tenaciouslyantediluvian | Historical | May be resolved - verify |
| [#37](https://github.com/jpazvd/wbopendata/issues/37) | Failed to access data with wbopendata | @KarstenKohler | Historical | May be resolved - verify |
| [#7](https://github.com/jpazvd/wbopendata/issues/7) | Improved navigation system through indicators | @jpazvd | Enhancement | Part of IMPROVEMENT_PLAN.md |

---

## Action Plan

### Phase 1: Close Resolved Issues
1. Close issues #33, #35, #45, #46, #51 with commit references
2. Thank reporters for their contributions

### Phase 2: Investigate Remaining Bugs
1. Reproduce #54 (country import issue)
2. Reproduce #39 (missing source in metadata)
3. Check if #37, #38 are still relevant

### Phase 3: Documentation Update
1. Update README.md with:
   - Current version info
   - Contributors section
   - Clearer installation instructions
   - Known issues section
2. Review and update help files

### Phase 4: Enhancement Tracking
- Link #7 and #49 to IMPROVEMENT_PLAN.md
- Consider closing as "wontfix" or "enhancement-tracked"

---

## Contributors to Acknowledge

### Bug Reports & Fixes
- **@dianagold** - Issue #33 (latest option fix)
- **@claradaia** - Issue #51 (match documentation)
- **@SylWeber** - Issue #45 (URL error handling)
- **@cuannzy** - Issue #46 (varlist error)
- **@oliverfiala** - Issue #34 (detailed match function feedback)

### Feature Requests & Suggestions
- **@santoshceft** - Issues #2, #8 (income category, countryname)
- **@Shijie-Shi** - Issue #9 (series name labels)
- **@JavierParada** - Issue #47 (aggregate classification)
- **@yukinko-iwasaki** - Issue #49 (WDI versioning)

### Bug Reports (Pending Investigation)
- **@Koko-Clovis** - Issue #54 (country import)
- **@ckrf** - Issue #39 (metadata source)
- **@flxflks** - Issue #48 (red text display)
- **@KarstenKohler** - Issue #37 (access failure)
- **@tenaciouslyantediluvian** - Issue #38 (update problem)

---

## Closing Message Template

```markdown
This issue has been fixed in commit `XXXXXX` and will be included in the next release (v17.1).

Thank you @USERNAME for reporting this issue and helping improve wbopendata!

If you encounter any other issues, please don't hesitate to open a new issue.
```
