# wbopendata Discovery System: Internal Planning Index

**Date:** January 20, 2026  
**Scope:** Internal research and planning (NOT for public release)  
**Status:** Research & Design Phase  
**Prepared for:** Development Team Review

---

## Quick Start

You are reading the **planning index** for adding Discovery + YAML metadata to wbopendata-dev.

**What's in this folder?**
- **01-DISCOVERY-YAML-VIABILITY.md** - Start here! Executive summary, three pathways (A/B/C), recommendation
- **02-IMPLEMENTATION-PATHWAYS.md** - Deep dive into each pathway with pros/cons, effort estimates
- **03-DESIGN-CHOICES.md** - Technical implementation details (assuming Pathway B)
- **README.md** - This file

**Recommended reading order:**
1. This README (overview)
2. `01-DISCOVERY-YAML-VIABILITY.md` (decision summary)
3. `02-IMPLEMENTATION-PATHWAYS.md` (pathway details)
4. `03-DESIGN-CHOICES.md` (technical design)

---

## Project Context

### Current State
- **wbopendata v17.7** - Mature Stata package for World Bank data access
- **Roadmap:** Discovery feature is P1 (high priority) for v18.0
- **Inspiration:** unicefdata-dev has similar discovery + YAML system
- **Goal:** Add searchable metadata + structured YAML configuration

### Three Implementation Approaches

| Pathway | Approach | Timeline | Complexity | Status |
|---------|----------|----------|-----------|--------|
| **A** | Static DTA cache | 3-4 weeks | Low | Not selected |
| **B** | YAML-Lite | 6-8 weeks | Medium | Foundation |
| **C** | Full automation | 12-14 weeks | High | ⭐ **SELECTED** |

### Selected Approach: **Pathway C (Full Auto-Sync)**

**Why Pathway C?**
- ✅ Complete automation (no manual updates)
- ✅ Always up-to-date metadata
- ✅ Enterprise-grade solution
- ✅ Best long-term ROI
- ✅ Aligns with unicefdata-dev + automation vision
- ✅ Includes all Pathway B benefits + auto-sync

---

## Updated: Pathway C Selected

**User decision:** Implement **Pathway C (Full Auto-Sync)** with YAML and automated updates.

**Additional documents created:**
- **04-PATHWAY-C-IMPLEMENTATION-PLAN.md** - Complete 14-week implementation plan
- **05-PYTHON-AUTOMATION-SPECS.md** - Detailed Python module specifications
- **06-STATA-SYNC-IMPLEMENTATION.md** - Stata caching and sync mechanism guide

---

## Document Overview

### 01-DISCOVERY-YAML-VIABILITY.md

**Executive Summary & Viability Assessment**

**Contents:**
- Current architecture analysis (wbopendata strengths/weaknesses)
- unicefdata-dev discovery pattern reference
- Three pathway overview (A/B/C)
- Comparison matrix
- Recommended approach (Pathway B)
- Implementation roadmap (4 phases)
- Risk assessment
- Success criteria

**Key sections:**
- Executive summary (1 page)
- Current state analysis (2 pages)
- Design approach: three pathways (4 pages)
- Recommended roadmap (3 pages)
- Risk & success criteria (2 pages)

**Length:** ~15 pages | **Read time:** 30-40 minutes

**When to read:**
- Before deciding which pathway to follow
- For stakeholder discussion/sign-off
- Understanding risks and benefits

---

### 02-IMPLEMENTATION-PATHWAYS.md

**Detailed Technical Comparison of Three Pathways**

**Contents:**
- **Pathway A (DTA-based):**
  - Architecture diagram
  - Implementation steps
  - File structure
  - Pros/cons analysis
  - Use cases
  - Effort estimate: 3-4 weeks

- **Pathway B (YAML-Lite):** ← RECOMMENDED
  - Architecture diagram
  - YAML schema structure (3 files)
  - Stata integration approach
  - Return value examples
  - Pros/cons analysis
  - Use cases
  - Deployment checklist
  - Effort estimate: 6-8 weeks

- **Pathway C (Full auto-sync):**
  - Automation pipeline architecture
  - Python update script outline
  - GitHub Actions workflow
  - Caching mechanism
  - Versioning strategy
  - Pros/cons analysis
  - Use cases
  - Effort estimate: 11-15 weeks

- **Comparison summary table**
- **Decision matrix** (which pathway for which scenario)
- **Next steps** (how to proceed)

**Key sections:**
- Pathway A detailed walkthrough (6 pages)
- Pathway B detailed walkthrough (8 pages)
- Pathway C detailed walkthrough (7 pages)
- Comparison & decision matrix (3 pages)

**Length:** ~24 pages | **Read time:** 45-60 minutes

**When to read:**
- Comparing technical approaches
- Estimating effort/timeline for each option
- Understanding dependencies
- Choosing between pathways

---

### 03-DESIGN-CHOICES.md

**Technical Architecture & Implementation Decisions**

**Contents (assuming Pathway B is chosen):**

1. **Core Design Decisions** (5 decisions with rationale):
   - Why YAML over JSON/.dta
   - Why split files (not single mega-file)
   - Caching strategy (in-memory vs persistent)
   - Search algorithm (weighted keyword match)
   - Return values format

2. **YAML Schema Design**:
   - Three-file model structure
   - `_wbopendata_indicators.yaml` (13K+ indicators)
   - `_wbopendata_sources.yaml` (51 sources)
   - `_wbopendata_topics.yaml` (21 topics)
   - Schema versioning strategy
   - Complete YAML examples

3. **Stata Implementation**:
   - File organization
   - `_yaml_read.ado` (wrapper helper)
   - `_wbopendata_search.ado` (discovery search)
   - `_wbopendata_info.ado` (detail lookup)
   - Complete code snippets

4. **Integration Points**:
   - Option parsing in main command
   - Routing logic
   - Help file updates
   - Command examples

5. **Testing & Validation**:
   - Test suite outline
   - Validation checklist
   - Unit test examples

6. **Performance Considerations**:
   - Benchmark targets
   - Optimization strategies
   - Lazy loading, caching, indexing

7. **Future Extensibility**:
   - v18.1+ enhancements (sync, persistent cache)
   - Extension points (plugins, exports)
   - Architecture diagram

**Key sections:**
- Design decisions (6 pages)
- YAML schema examples (5 pages)
- Stata code snippets (6 pages)
- Testing & performance (4 pages)
- Future roadmap (2 pages)

**Length:** ~23 pages | **Read time:** 50-70 minutes

**When to read:**
- After choosing Pathway B
- As reference during implementation
- For technical architecture review
- Performance tuning

---

### 04-PATHWAY-C-IMPLEMENTATION-PLAN.md

**Comprehensive Plan for Full Auto-Sync Implementation**

**Contents:**
- Executive summary (Pathway C overview)
- Complete architecture (Python pipeline + Stata sync)
- Phase breakdown (6 phases, 12-14 weeks)
  - Phase 1: Pathway B foundation (weeks 1-8)
  - Phase 2: Python automation (weeks 9-10)
  - Phase 3: GitHub Actions CI/CD (week 11)
  - Phase 4: Caching & sync in Stata (week 12)
  - Phase 5: User commands & features (week 13)
  - Phase 6: Testing & validation (week 14)
- Automated update pipeline design
- Caching & sync mechanism
- Version management strategy
- Testing strategy
- Deployment & rollout plan

**Key sections:**
- Architecture overview (3 pages)
- Phase-by-phase plan (15 pages)
- Automated pipeline specs (4 pages)
- Testing & deployment (3 pages)

**Length:** ~25 pages | **Read time:** 60-75 minutes

**When to read:**
- SELECTED PATHWAY - start here for implementation
- Understanding automation pipeline
- Planning Python development
- GitHub Actions setup

---

### 05-PYTHON-AUTOMATION-SPECS.md

**Detailed Python Module Specifications**

**Contents:**
- Complete module architecture
- Core modules (5 detailed implementations):
  1. WB API Client (`wb_api_client.py`)
  2. YAML Generator (`yaml_generator.py`)
  3. Schema Validator (`schema_validator.py`)
  4. Git Manager (`git_manager.py`)
  5. Diff Analyzer (`diff_analyzer.py`)
- Configuration management
- Error handling & exceptions
- Logging strategy
- Testing framework
- Deployment setup

**Key sections:**
- Module specifications with full code (18 pages)
- Configuration files (2 pages)
- Error handling (2 pages)
- Testing examples (3 pages)

**Length:** ~25 pages | **Read time:** 60-75 minutes

**When to read:**
- Before starting Python development
- As reference during coding
- Setting up automation pipeline
- Debugging Python modules

---

### 06-STATA-SYNC-IMPLEMENTATION.md

**Stata Caching & Sync Mechanism Guide**

**Contents:**
- Stata file architecture
- Cache management system
- 4 core helpers (complete code):
  1. `_wbopendata_cache.ado` (cache manager)
  2. `_wbopendata_check_version.ado` (version checker)
  3. `_wbopendata_download_yaml.ado` (downloader)
  4. `_wbopendata_get_yaml_path.ado` (path resolver)
- Integration with discovery commands
- User command examples
- Complete testing suite
- Performance benchmarking

**Key sections:**
- Cache architecture (3 pages)
- Helper implementations with full code (12 pages)
- User command examples (3 pages)
- Testing suite (4 pages)

**Length:** ~22 pages | **Read time:** 50-65 minutes

**When to read:**
- Before implementing Stata sync features
- As reference during Stata coding
- Testing cache mechanism
- Debugging sync issues

---

### 07-PATHWAY-C-EXECUTIVE-SUMMARY.md

⭐ **FINAL IMPLEMENTATION GUIDE - START HERE** ⭐

**Contents:**
- Decision confirmation (Pathway C selected)
- Complete document index (all 9 planning docs)
- 14-week implementation roadmap
- Resource requirements (team, infrastructure, dependencies)
- Success metrics & ROI analysis
- Risk assessment & mitigations
- Reading guide by role (PM/Python/Stata/QA)
- Week 1 action checklist
- Final implementation checklist

**Key sections:**
- What gets built (Python + Stata components) (3 pages)
- User experience after implementation (2 pages)
- Resource requirements (team, infrastructure, dependencies) (2 pages)
- Success metrics & ROI (2 pages)
- Next actions & reading guide (3 pages)

**Length:** ~15 pages | **Read time:** 30-40 minutes

**When to read:**
- ⭐ **START HERE** before beginning implementation
- Project kickoff meeting
- Stakeholder approval process
- Team onboarding
- Weekly progress reviews

---

## Key Decisions Summary

### Decision Tree

```
START: Should wbopendata have Discovery?
  ↓
YES → How much effort available?
  ├─ < 5 weeks → Pathway A (DTA-based)
  ├─ 6-8 weeks → Pathway B (YAML-Lite) ← RECOMMENDED
  └─ 10+ weeks → Pathway C (Full auto-sync)
  
If Pathway B chosen:
  ├─ Phase 1: YAML schema design
  ├─ Phase 2: Stata helpers implementation
  ├─ Phase 3: Main command integration
  └─ Phase 4: Testing & documentation
```

### Recommendation Analysis

**Why Pathway B is recommended over A or C:**

| Criterion | A | B | C |
|-----------|---|---|---|
| Aligns with unicefdata | ❌ | ✅ | ✅ |
| Realistic timeline | ✅ | ✅ | ❌ |
| Team skill fit | ✅ | ✅ | ⚠️ |
| Future-proof | ❌ | ✅ | ✅ |
| Meets v18.0 goals | ⚠️ | ✅ | ✅ |
| Sustainable | ❌ | ✅ | ✅ |
| **Overall** | **Quick win** | **Optimal** | **Overkill** |

**Pathway B balances:**
- ✅ Reasonable 6-8 week timeline
- ✅ Structured metadata (YAML)
- ✅ Discovery functionality
- ✅ Foundation for future v18.1 automation
- ✅ Non-breaking changes
- ✅ Minimal new dependencies

---

## Implementation Plan (Pathway B)

### Phase 1: Schema & Files (Weeks 1-2)

**Deliverables:**
- YAML schema document
- 3 YAML files (indicators, sources, topics)
- Sample test YAML

**Owner:** 1 developer (Stata + some Python)  
**Skill needed:** Stata, basic YAML, Python (optional)

### Phase 2: Stata Infrastructure (Weeks 3-4)

**Deliverables:**
- `_yaml_read.ado` (wrapper)
- `_wbopendata_search.ado` (search function)
- `_wbopendata_info.ado` (info function)

**Owner:** 1 developer (Stata specialist)  
**Skill needed:** Advanced Stata, familiar with wbopendata codebase

### Phase 3: Integration & Options (Weeks 5-6)

**Deliverables:**
- Updated `wbopendata.ado` with discovery options
- Subcommands: search(), info(), sources, topics
- Updated help file

**Owner:** 1 developer (Stata + command design)  
**Skill needed:** Stata, wbopendata architecture

### Phase 4: Testing & Documentation (Weeks 7-8)

**Deliverables:**
- Comprehensive test suite
- User guide & examples
- Performance benchmarks

**Owner:** 1-2 developers (testing + docs)  
**Skill needed:** Testing methodology, technical writing

**Total effort:** 6-8 weeks (1 FTE) or 3-4 weeks (2 FTE)

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| **YAML files too large** | Medium | Medium | Lazy loading, split files |
| **yaml.ado dependency issues** | Low | High | Vendor yaml.ado, fallback parser |
| **Performance degradation** | Low | Medium | Pre-build index, caching |
| **Metadata drift** | Medium | Medium | Version control, validation |
| **Backward compatibility break** | Low | High | All new options only, existing API untouched |

---

## Success Criteria

### Development Phase
- [ ] All YAML files validated (schema compliance)
- [ ] All Stata code passes strict linter
- [ ] 100% unit test coverage (search/info)
- [ ] No regression in existing commands
- [ ] Performance benchmarks met (< 1 sec searches)

### User Acceptance
- [ ] Search finds 100+ indicators by keyword
- [ ] Info command returns all necessary fields
- [ ] Source/topic browsing works smoothly
- [ ] Discovery + download workflow seamless
- [ ] Documentation is clear and complete

### Release Readiness
- [ ] All edge cases handled (missing fields, typos, etc.)
- [ ] Help file complete with examples
- [ ] Roadmap updated for v18.1
- [ ] Contributors acknowledged
- [ ] Version tagged and released

---

## Stakeholder Review Checklist

Before starting implementation, confirm with stakeholders:

- [ ] Pathway B is selected choice
- [ ] Timeline 6-8 weeks is acceptable
- [ ] 1 FTE developer allocated
- [ ] yaml.ado dependency approved
- [ ] Metadata update process documented
- [ ] Success criteria signed off
- [ ] Risk mitigation strategies endorsed
- [ ] Budget and resources confirmed

---

## File Structure After Implementation

```
wbopendata-dev/
├── src/
│   ├── w/
│   │   └── wbopendata.ado           (updated: +search/info options)
│   └── _/
│       ├── _wbopendata_indicators.yaml    (NEW ~500KB)
│       ├── _wbopendata_sources.yaml       (NEW ~50KB)
│       ├── _wbopendata_topics.yaml        (NEW ~20KB)
│       ├── _yaml_read.ado                 (NEW)
│       ├── _wbopendata_search.ado         (NEW)
│       ├── _wbopendata_info.ado           (NEW)
│       ├── _wbopendata_sources.ado        (NEW)
│       └── _api_read.ado                  (unchanged)
│
├── doc/
│   ├── README.md                   (updated: add Discovery section)
│   ├── wbopendata.md              (updated: add Discovery reference)
│   └── examples/
│       └── discovery_examples.do   (NEW)
│
├── internal/                       (THIS FOLDER)
│   ├── README.md                   (this file)
│   ├── 01-DISCOVERY-YAML-VIABILITY.md
│   ├── 02-IMPLEMENTATION-PATHWAYS.md
│   └── 03-DESIGN-CHOICES.md
│
├── tests/
│   └── test_discovery.do           (NEW)
│
└── stata.toc
    └── Update version & addition list
```

---

## References & Related Documents

### Internal References
- **Roadmap:** `doc/roadmap/ROADMAP.md` (Discovery = P1 v18.0)
- **Standards:** `.github/STATA_ADO_BEST_PRACTICES.md`
- **Examples:** `doc/user-guide/examples_gallery.md`

### External References
- **unicefdata-dev:** Similar discovery implementation
  - `config/indicators.yaml` (reference schema)
  - `stata/src/u/_unicef_*.ado` (reference implementation)
  - `stata/src/g/get_unicef_data.ado` (reference entry point)

- **yaml.ado:** SSC documentation
  - Command: `ssc install yaml`
  - Help: `help yaml`

- **World Bank API:** Open Data documentation
  - https://data.worldbank.org/developers/api-overview
  - Indicator endpoints: `http://api.worldbank.org/v2/indicators`

---

## Quick Reference: Decision Summary

### Single-Paragraph Summary

**wbopendata should add Discovery functionality using YAML-Lite (Pathway B)** because it balances reasonable effort (6-8 weeks) with high user value (searchable metadata), aligns with the unicefdata-dev pattern for future multiplatform sync, and provides a foundation for automated updates in v18.1. This is superior to quick-fix DTA caching (misses YAML benefits) but more practical than enterprise automation (deferred to later phase).

### One-Sentence Recommendation

**Implement Pathway B (YAML-Lite Discovery) to ship v18.0 with searchable metadata using a structured, version-controllable foundation.**

---

## Next Steps (If Approved)

1. **Review & Approval** (1-2 days)
   - Stakeholders review all three documents
   - Confirm Pathway B is selected
   - Approve timeline & resource allocation

2. **Schema Design Kickoff** (1 week)
   - Create detailed YAML schema document
   - Generate sample YAML files
   - Test parsing with yaml.ado

3. **Prototype Phase** (1 week)
   - Build proof-of-concept search function
   - Verify performance on 13K indicators
   - Get user feedback on UX

4. **Full Implementation** (5-7 weeks)
   - Phases 2-4 as outlined above
   - Weekly check-ins
   - Continuous integration testing

5. **Release** (Week 8)
   - v18.0 release with Discovery
   - Announcement & user guide
   - Plan v18.1 automation enhancements

---

## Questions & Contact

**Who to contact for:**
- **Strategic decisions:** Project lead / roadmap owner
- **Technical architecture:** Lead developer / Stata expert
- **Timeline & resources:** Project manager / resource planning
- **Documentation:** Technical writer / docs maintainer

---

## Document Versioning

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-01-20 | Initial draft - three pathways analyzed |

---

## Appendix: Glossary

**YAML:** Yet Another Markup Language - human-readable data format  
**Pathway:** Alternative implementation approach with tradeoffs  
**Metadata:** Data about data - indicator descriptions, sources, etc.  
**DTA:** Stata native binary data format  
**SSC:** Statistical Software Components - Stata package repository  
**v18.0:** Major release of wbopendata (planned future version)  
**Discovery:** Functionality to search and explore available indicators  

---

*This index and all related documents are for INTERNAL planning only.*  
*These materials should NOT be transferred to the public wbopendata repository.*  
*Intended audience: wbopendata development team and stakeholders.*

**Last updated:** January 20, 2026  
**Next review:** After stakeholder decision on pathway selection
