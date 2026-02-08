# Quick Reference: Discovery + YAML Planning

**Print this page or save it for rapid reference during planning meetings**

---

## Executive Summary (30 seconds)

**Question:** Should wbopendata add Discovery + YAML?  
**Answer:** YES, via Pathway B (YAML-Lite) in 6-8 weeks

**Why?** Balanced effort, aligns with unicefdata, foundation for future automation

---

## Three Pathways at a Glance

```
PATHWAY A: Static DTA          PATHWAY B: YAML-Lite            PATHWAY C: Full Auto-Sync
┌──────────────────────┐      ┌──────────────────────┐        ┌──────────────────────┐
│ Timeline: 3-4 weeks  │      │ Timeline: 6-8 weeks  │        │ Timeline: 10-14 wks  │
│ Effort: Low          │      │ Effort: Medium       │        │ Effort: High         │
│ Complexity: Simple   │      │ Complexity: Medium   │        │ Complexity: High     │
│ YAML: NO             │      │ YAML: YES ✓          │        │ YAML: YES ✓          │
│ Auto-update: NO      │      │ Auto-update: NO      │        │ Auto-update: YES ✓   │
│ Maintenance: High    │      │ Maintenance: Low     │        │ Maintenance: Low     │
│ Roadmap: Partial ⚠️  │      │ Roadmap: Full ✅     │        │ Roadmap: Full ✅     │
└──────────────────────┘      └──────────────────────┘        └──────────────────────┘
                                       ↑
                                 RECOMMENDED
```

---

## Pathway B: Recommended Approach

### What Gets Built?

1. **YAML Files** (src/_/)
   - `_wbopendata_indicators.yaml` (500 KB, 13K+ indicators)
   - `_wbopendata_sources.yaml` (50 KB)
   - `_wbopendata_topics.yaml` (20 KB)

2. **Stata Functions** (src/_/)
   - `_yaml_read.ado` (helper to parse YAML)
   - `_wbopendata_search.ado` (search indicators)
   - `_wbopendata_info.ado` (detail lookup)

3. **Main Command Updates** (src/w/wbopendata.ado)
   - Add `search()` option
   - Add `info()` option
   - Add `sources`, `topics` subcommands

### User Commands

```stata
// AFTER implementation:

* Search for education indicators
wbopendata, search("education") limit(20)

* Get detailed info about indicator
wbopendata, info("SE.ADT.LITR.ZS")

* List all sources
wbopendata, sources detail

* Search within specific source
wbopendata, search("GDP") source(2)
```

### Return Values Example

```stata
* After: wbopendata, search("education") limit(3)

r(n_results)      = "3"
r(indicator1)     = "SE.ADT.LITR.ZS"
r(name1)          = "Literacy rate, adult total"
r(indicator2)     = "SE.PRY.CMPL.ZS"
r(name2)          = "School completion rate"
r(indicator3)     = "SE.EDU.TRNL"
r(name3)          = "Education transition rate"
```

---

## Implementation Timeline

```
WEEK 1-2: Schema & Files
  ├─ Design YAML schema
  ├─ Generate 3 YAML files from WB API
  └─ Validate & add checksums

WEEK 3-4: Stata Infrastructure
  ├─ Implement _yaml_read.ado helper
  ├─ Implement _wbopendata_search.ado
  └─ Implement _wbopendata_info.ado

WEEK 5-6: Integration
  ├─ Add options to wbopendata.ado
  ├─ Update help file
  └─ Integration testing

WEEK 7-8: Testing & Docs
  ├─ Comprehensive test suite
  ├─ User guide + examples
  └─ Performance benchmarking

DELIVERY: v18.0 with Discovery + YAML
```

---

## Key Design Decisions

| Decision | Choice | Why? |
|----------|--------|------|
| Format | YAML | Multiplatform, human-readable, parsed via SSC yaml.ado |
| Files | 3 split | Fast parsing, selective updates, modularity |
| Cache | In-memory | Balance performance + simplicity |
| Search | Weighted keyword | Name hits (2x) weighted higher than description (1x) |
| Returns | Structured r() | Matches existing wbopendata pattern |

---

## File Structure Added

```
wbopendata-dev/
├── src/_/
│   ├── _wbopendata_indicators.yaml    (NEW, 500 KB)
│   ├── _wbopendata_sources.yaml       (NEW, 50 KB)
│   ├── _wbopendata_topics.yaml        (NEW, 20 KB)
│   ├── _yaml_read.ado                 (NEW, 30 lines)
│   ├── _wbopendata_search.ado         (NEW, 80 lines)
│   ├── _wbopendata_info.ado           (NEW, 60 lines)
│   └── [other helpers]
│
├── doc/examples/
│   └── discovery_examples.do          (NEW)
│
├── tests/
│   └── test_discovery.do              (NEW)
│
└── internal/
    ├── 01-DISCOVERY-YAML-VIABILITY.md
    ├── 02-IMPLEMENTATION-PATHWAYS.md
    ├── 03-DESIGN-CHOICES.md
    └── README.md
```

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Search 13K indicators | < 1 second |
| Info lookup | < 100 ms |
| Test coverage | 100% |
| Existing commands | No regression |
| Performance | < 5% overhead |

---

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|-----------|
| YAML files too large | Medium | Lazy loading, split by category |
| yaml.ado dependency fails | Low | Vendor yaml.ado, fallback parser |
| Performance issues | Low | Pre-build index, in-memory cache |
| Backward compatibility break | Low | All new options, existing API untouched |
| Metadata drift | Medium | Version control, automated validation |

---

## YAML Schema Preview

```yaml
# _wbopendata_indicators.yaml (500 KB)

_metadata:
  version: "2.0.0"
  generated: "2025-12-01T10:00:00Z"
  total_indicators: 13150

indicators:
  SP.POP.TOTL:
    code: "SP.POP.TOTL"
    name: "Population, total"
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["19"]
    topic_names: ["Population dynamics"]
    description: "Total population..."
    latest_year: "2023"

  SE.ADT.LITR.ZS:
    code: "SE.ADT.LITR.ZS"
    name: "Literacy rate, adult total (%)"
    ...
```

---

## Dependencies

**Stata Package (SSC):**
- `yaml.ado` - YAML parser (must be installed)

**Python (optional, for manual metadata generation):**
- requests, pyyaml (if updating YAML manually)

**New .ado files:**
- All self-contained, no complex dependencies

---

## Approval Checklist

Before starting implementation:

- [ ] Pathway B selected (vs A or C)
- [ ] Timeline 6-8 weeks approved
- [ ] 1 FTE developer allocated
- [ ] yaml.ado dependency approved
- [ ] Budget confirmed
- [ ] Success metrics agreed
- [ ] Risk mitigation endorsed

---

## Cost/Benefit Analysis

### Pathway B Costs
- **Development effort:** 240 hours (6 weeks @ 40 hrs/week)
- **SSC dependency:** yaml.ado (maintained by others)
- **Ongoing maintenance:** ~1-2 hours/week (metadata updates)

### Pathway B Benefits
- **User value:** Search 13K indicators by keyword ✓
- **Code quality:** Structured metadata (YAML) ✓
- **Future roadmap:** Foundation for v18.1+ automation ✓
- **Competitive:** Matches unicefdata-dev capability ✓
- **Non-breaking:** Existing users unaffected ✓

### ROI
- **Effort-to-value ratio:** 240 hours → eliminates metadata navigation pain for thousands of users
- **Strategic alignment:** Delivers core v18.0 roadmap goal
- **Technical debt:** Reduces (structured metadata > scattered .sthlp files)

---

## Alternative: Why Not Pathway A?

**Pathway A (DTA-based) is faster but misses:**
- ❌ YAML foundation (limits future multiplatform sync)
- ❌ Structured metadata (harder to maintain)
- ❌ Version control (no history)
- ❌ Roadmap alignment (incomplete v18.0 vision)

**Better for:** Proof-of-concept only, not production

---

## Alternative: Why Not Pathway C?

**Pathway C (Auto-sync) is better long-term but:**
- ❌ Adds 6+ weeks to timeline (needs Python infrastructure)
- ❌ Requires Python expertise (team may lack)
- ❌ Higher maintenance burden (automation failures)
- ❌ Overkill for v18.0 (defer to v18.1)

**Better for:** Future phase after Pathway B stabilizes

---

## Next Actions

### If Pathway B is Approved:

1. **Day 1:** Create feature branch `feature/discovery-yaml`
2. **Week 1:** Schema design + YAML generation
3. **Week 2:** Prototype search function
4. **Week 3:** Full implementation begins
5. **Week 8:** v18.0 ready for testing

### If Decision Pending:

1. Review `01-DISCOVERY-YAML-VIABILITY.md` (exec summary)
2. Discuss trade-offs with team
3. Confirm pathway choice
4. Allocate developer(s)
5. Set start date

---

## Contact for Questions

- **Strategic:** Project roadmap owner
- **Technical:** Lead Stata developer
- **Timeline:** Project manager
- **Details:** See full planning documents in `internal/` folder

---

## Reading Guide

| Document | Read Time | Use Case |
|----------|-----------|----------|
| This page | 5 min | Quick overview, reference |
| 01-VIABILITY | 30-40 min | Executive decision-making |
| 02-PATHWAYS | 45-60 min | Technical comparison |
| 03-DESIGN | 50-70 min | Implementation reference |

---

## Key Takeaway

**wbopendata should adopt Pathway B (YAML-Lite Discovery) because it delivers the v18.0 roadmap goal with reasonable effort (6-8 weeks) while establishing a structured foundation for future enhancement.**

---

*Internal Planning Document - NOT for public release*  
*Updated: January 20, 2026*
