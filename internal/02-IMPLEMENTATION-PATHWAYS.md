# Discovery System: Detailed Pathways Analysis

**Date:** January 20, 2026  
**Project:** wbopendata-dev  
**Scope:** Three implementation pathways with technical pros/cons

---

## Overview

This document provides deep-dive analysis of three implementation pathways for adding Discovery + YAML to wbopendata. Choose the pathway that best fits resource constraints and strategic vision.

---

## Pathway A: Static DTA-Based Discovery

### "Keep It Simple" Approach

**Concept:** Leverage existing Stata `.dta` infrastructure (what wbopendata already does well) to add search/info subcommands without introducing YAML.

### Architecture

```
┌────────────────────────────────────┐
│  wbopendata.ado (main command)     │
│  ├─ search(keyword)                │
│  ├─ info(code)                     │
│  ├─ sources                        │
│  └─ topics [existing + enhanced]   │
└────────────────────────────────────┘
        ↓
┌────────────────────────────────────┐
│ Discovery Helpers (_*.ado)         │
│ ├─ _wbopendata_search.ado          │
│ ├─ _wbopendata_info.ado            │
│ └─ _wbopendata_sources.ado         │
└────────────────────────────────────┘
        ↓
┌────────────────────────────────────┐
│ Metadata Cache (Stata .dta files)  │
│ ├─ _wbopendata_indicators.dta      │
│ ├─ _wbopendata_sources.dta         │
│ └─ _wbopendata_topics.dta          │
└────────────────────────────────────┘
        ↓
┌────────────────────────────────────┐
│ Existing: API integration unchanged│
│ _api_read.ado (no changes)         │
└────────────────────────────────────┘
```

### Implementation Steps

1. **Build Metadata .DTA Files** (Week 1)
   - Fetch WB API (bulk endpoints)
   - Parse JSON → Stata dataset
   - Standardize field names
   - Save as compressed .dta

2. **Implement `_wbopendata_search.ado`** (Week 1-2)
   ```stata
   program def _wbopendata_search
     use _wbopendata_indicators.dta, clear
     * Keyword matching on name + description
     * Return matches as list or table
   end
   ```

3. **Implement `_wbopendata_info.ado`** (Week 2)
   ```stata
   program def _wbopendata_info
     use _wbopendata_indicators.dta, clear
     keep if code == "`indicator_code'"
     * Display detailed info
   end
   ```

4. **Add Options to Main Command** (Week 2-3)
   - `search(keyword)` 
   - `info(code)`
   - `sources [detail]`

5. **Testing & Documentation** (Week 3-4)

### File Structure

```
src/
├── w/
│   └── wbopendata.ado           (add search/info syntax)
└── _/
    ├── _wbopendata_indicators.dta    (↑ NEW)
    ├── _wbopendata_sources.dta       (↑ NEW)
    ├── _wbopendata_topics.dta        (↑ NEW)
    ├── _wbopendata_search.ado        (↑ NEW)
    ├── _wbopendata_info.ado          (↑ NEW)
    └── _api_read.ado                 (unchanged)
```

### Pros

✅ **Zero external dependencies** - No YAML, no SSC packages  
✅ **Familiar technology** - Stata users know `.dta` format  
✅ **Very fast implementation** - 3-4 weeks  
✅ **Easy to debug** - Can inspect .dta directly  
✅ **Good performance** - In-memory search over .dta  
✅ **Non-breaking** - Existing users unaffected  

### Cons

❌ **Not future-proof** - Doesn't align with unicefdata pattern  
❌ **No multiplatform sync** - Each language needs own .dta  
❌ **Manual updates** - Must rebuild .dta files manually  
❌ **File size** - .dta files can be large (hundreds of MB)  
❌ **No versioning** - Hard to track metadata history  
❌ **Missing YAML vision** - Doesn't advance v18.0 strategic goal  

### Best For

- **Quick wins** if YAML infrastructure not ready
- **Learning phase** before committing to YAML
- **Tight deadline** (must ship discovery in weeks)
- **Teams avoiding new dependencies**

### Dependencies

- **None** - uses standard Stata

### Effort Estimate

- **Development:** 3-4 weeks (1 developer)
- **Testing:** 1 week
- **Maintenance:** 4-6 hours per metadata update
- **Total timeline:** 4-5 weeks to production

---

## Pathway B: YAML-Lite Discovery

### "Structured Foundation" Approach

**Concept:** Introduce YAML as structured metadata format (like unicefdata-dev), implement discovery on YAML, but defer automated sync to later.

### Architecture

```
┌────────────────────────────────────────┐
│ Manual Update Workflow (per release)    │
│ update_metadata.sh or manual process    │
│ ├─ Fetch WB API → normalize → YAML    │
│ └─ git commit + tag                    │
└────────────────────────────────────────┘
        ↓ (checked into repo)
┌────────────────────────────────────────┐
│ YAML Metadata Files (src/_/)           │
│ ├─ _wbopendata_indicators.yaml         │
│ ├─ _wbopendata_sources.yaml            │
│ └─ _wbopendata_topics.yaml             │
└────────────────────────────────────────┘
        ↓
┌────────────────────────────────────────┐
│ Stata Discovery Layer                  │
│ _wbopendata_search.ado                 │
│ _wbopendata_info.ado                   │
│ ├─ _yaml_read.ado (wrapper)            │
│ └─ yaml.ado (SSC dependency)           │
└────────────────────────────────────────┘
        ↓
┌────────────────────────────────────────┐
│ Main Command (wbopendata.ado)          │
│ ├─ search(keyword)                     │
│ ├─ info(code)                          │
│ └─ sources/topics (read from YAML)     │
└────────────────────────────────────────┘
```

### Implementation Steps

1. **Design YAML Schema** (Week 1)
   - Define structure (metadata block + records)
   - Version field
   - Checksum for integrity
   - Support for future extensions
   - Create `YAML_SCHEMA_DESIGN.md`

2. **Generate YAML Files** (Week 1-2)
   - Write Python script: WB API → YAML
   - Generate 3 files (indicators, sources, topics)
   - Validate schema compliance
   - Add checksums

3. **Implement YAML Helpers** (Week 2-3)
   ```stata
   * _yaml_read.ado - thin wrapper over yaml.ado
   * Handles file paths, error checking
   * Returns parsed structure
   ```

4. **Build Discovery Functions** (Week 3-4)
   ```stata
   * _wbopendata_search.ado
   *   ├─ Read indicators YAML
   *   ├─ Build search index
   *   └─ Return matches
   
   * _wbopendata_info.ado
   *   ├─ Read indicators YAML
   *   ├─ Lookup by code
   *   └─ Display formatted info
   ```

5. **Integrate with Main Command** (Week 4-5)
   - Add syntax options
   - Route to discovery helpers
   - Return structured results

6. **Documentation & Testing** (Week 5-6)
   - Unit tests (search algorithm)
   - Integration tests (YAML parsing)
   - User guide
   - Examples

### File Structure

```
src/
├── w/
│   └── wbopendata.ado             (add search/info options)
└── _/
    ├── _wbopendata_indicators.yaml      (↑ NEW ~500KB)
    ├── _wbopendata_sources.yaml         (↑ NEW ~50KB)
    ├── _wbopendata_topics.yaml          (↑ NEW ~20KB)
    ├── _yaml_read.ado                   (↑ NEW - wrapper)
    ├── _wbopendata_search.ado           (↑ NEW)
    ├── _wbopendata_info.ado             (↑ NEW)
    └── _api_read.ado                    (unchanged)

doc/
├── YAML_SCHEMA_DESIGN.md           (↑ NEW - reference)
└── examples/
    └── discovery_examples.do        (↑ NEW)

internal/
└── UPDATE_METADATA_GUIDE.md         (↑ NEW - manual process)
```

### YAML Schema (Simplified Example)

```yaml
# _wbopendata_indicators.yaml

_metadata:
  version: "2.0.0"
  generated: "2025-12-01T10:00:00Z"
  source: "World Bank Open Data API"
  total_count: 13150
  checksum: "sha256:..."

indicators:
  SP.POP.TOTL:
    code: "SP.POP.TOTL"
    name: "Population, total"
    source_id: "2"
    source_name: "World Development Indicators"
    topic_ids: ["19"]
    topic_names: ["Population dynamics"]
    description: "Total population is based on..."
    latest_year: "2023"
    
  SE.ADT.LITR.ZS:
    code: "SE.ADT.LITR.ZS"
    name: "Literacy rate, adult total"
    source_id: "2"
    ...
```

### Stata Usage Examples

```stata
* Search for education indicators
wbopendata, search("education") limit(20)

* Get details about specific indicator
wbopendata, info("SE.ADT.LITR.ZS")

* List all sources
wbopendata, sources detail

* Search within specific source
wbopendata, search("school") source(2)
```

### Return Values

```stata
* After search
r(n_results)           = 15
r(indicator1)          = "SE.ADT.LITR.ZS"
r(name1)               = "Literacy rate, adult total"
r(indicator2)          = ...

* After info
r(code)                = "SE.ADT.LITR.ZS"
r(name)                = "Literacy rate, adult total"
r(source_id)           = "2"
r(source_name)         = "World Development Indicators"
r(topic_ids)           = "4 5 6"
r(description)         = "..."
```

### Pros

✅ **Structured metadata** - YAML is version-controllable  
✅ **Multiplatform foundation** - Can sync YAML across languages  
✅ **Future-proof** - Aligns with unicefdata pattern  
✅ **Moderate complexity** - Not too heavy, not too light  
✅ **One-time effort** - After YAML setup, search code is stable  
✅ **Meets v18.0 roadmap** - Delivers discovery + YAML goal  
✅ **Good performance** - YAML parsing is fast in Stata  
✅ **Non-breaking** - Existing functionality unchanged  

### Cons

⚠️ **Dependency on yaml.ado** - Need to manage SSC package  
⚠️ **Larger code footprint** - ~500KB YAML files  
⚠️ **Manual update process** - Still requires manual YAML generation  
⚠️ **Metadata drift risk** - Can get out of sync with API  
❌ **Not auto-sync** - No scheduled updates (v18.1 feature)  

### Best For

- **Balanced approach** - Features + maintainability
- **Strategic alignment** - Matches unicefdata pattern
- **Medium-term vision** - Foundation for automation later
- **Teams comfortable with YAML** - But not Python infrastructure yet

### Dependencies

- **yaml.ado** (from SSC) - Required for YAML parsing
- **Python** (optional, for manual YAML generation)

### Effort Estimate

- **Development:** 6-8 weeks (1 developer)
- **Testing:** 1-2 weeks
- **Metadata generation:** 1 week (initial)
- **Maintenance:** 4-8 hours per update (quarterly)
- **Total timeline:** 7-9 weeks to production

### Deployment Checklist

- [ ] YAML schema finalized
- [ ] YAML files generated and validated
- [ ] `yaml.ado` dependency documented in STATA_ADO_BEST_PRACTICES.md
- [ ] Search algorithm tested on 13K indicators
- [ ] Return values match existing patterns
- [ ] Help file updated
- [ ] Examples added to gallery
- [ ] User guide written
- [ ] Regression tests pass (existing commands)

---

## Pathway C: Full YAML + Auto-Sync

### "Enterprise-Grade" Approach

**Concept:** Complete automation pipeline. Python script fetches WB API, generates YAML, commits to repo, triggers SSC publish. Stata users get fresh metadata automatically.

### Architecture

```
┌──────────────────────────────────────────┐
│ Scheduled Metadata Update Pipeline       │
│ (GitHub Actions or manual cron)          │
├──────────────────────────────────────────┤
│ 1. Fetch WB API (bulk endpoints)         │
│ 2. Normalize & validate                  │
│ 3. Generate YAML files                   │
│ 4. Run test suite                        │
│ 5. Git commit + tag (v2.0.0-metadata-*)  │
│ 6. SSC package update                    │
│ 7. Notify users (GitHub releases)        │
└──────────────────────────────────────────┘
         ↓ (versioned YAML)
┌──────────────────────────────────────────┐
│ Stata Runtime: Discovery + Caching       │
│ _wbopendata_search.ado                   │
│ _wbopendata_info.ado                     │
│ _wbopendata_cache.ado  (↑ NEW)           │
│ _wbopendata_sync.ado   (↑ NEW)           │
└──────────────────────────────────────────┘
         ↓
┌──────────────────────────────────────────┐
│ Metadata Delivery                        │
│ ├─ Local YAML cache (version A)          │
│ ├─ Remote API check (version B)          │
│ └─ Auto-update if newer available        │
└──────────────────────────────────────────┘
```

### Implementation Steps

#### Phase 1: Metadata Automation (Pathway B first, then add:)

1. **Python Update Pipeline** (Week 1-3)
   ```python
   # update_metadata.py
   def fetch_wb_api():
       # Bulk endpoints for all indicators/sources/topics
       
   def normalize_to_yaml():
       # Convert JSON → YAML schema
       
   def validate_yaml():
       # Check all required fields, data types
       
   def generate_checksums():
       # SHA256 for integrity verification
       
   def git_commit_and_tag():
       # Commit YAML, create version tag
   ```

2. **GitHub Actions Workflow** (Week 1-2)
   ```yaml
   # .github/workflows/update-metadata.yml
   schedule:
     - cron: '0 0 1 * *'  # Monthly
   jobs:
     - run: python update_metadata.py
     - run: pytest test_metadata.py
     - commit and push
   ```

3. **Versioning Strategy** (Week 1)
   - Metadata version separate from package version
   - Tag format: `metadata-2025-12-01` or `v2.0.0-m1`
   - Keep 2-3 versions in repo (rollback capability)

#### Phase 2: Caching Layer (Week 4-5)

```stata
* _wbopendata_cache.ado - NEW
program def _wbopendata_cache
  * Detect local vs remote versions
  * Download if remote is newer
  * Cache to user's directory
  * Return path to cached YAML
end
```

#### Phase 3: Sync Command (Week 5-6)

```stata
* wbopendata, sync(force|check)
wbopendata, sync              // Check if update available
wbopendata, sync(force)       // Force remote fetch
wbopendata, clearcache        // Clear local cache

* Returns:
r(local_version)  = "2.0.0"
r(remote_version) = "2.0.1"
r(cache_path)     = "C:\Users\...\AppData\..."
```

### File Structure

```
/
├── update_metadata.py             (↑ NEW - automation)
├── .github/workflows/
│   └── update-metadata.yml        (↑ NEW - GitHub Actions)
├── tests/
│   └── test_metadata.py           (↑ NEW - validation)
│
src/
├── w/
│   └── wbopendata.ado             (add sync option)
└── _/
    ├── _wbopendata_indicators.yaml     (versioned)
    ├── _wbopendata_sources.yaml        (versioned)
    ├── _wbopendata_topics.yaml         (versioned)
    ├── _yaml_read.ado
    ├── _wbopendata_search.ado
    ├── _wbopendata_info.ado
    ├── _wbopendata_cache.ado           (↑ NEW)
    ├── _wbopendata_sync.ado            (↑ NEW)
    └── _api_read.ado

doc/
└── METADATA_SYNC_GUIDE.md          (↑ NEW - how sync works)

internal/
└── METADATA_VERSIONING_STRATEGY.md (↑ NEW)
```

### Automation Files

```python
# update_metadata.py
import requests
import yaml
import hashlib
from datetime import datetime

def fetch_indicators():
    """Bulk fetch all indicators from WB API"""
    # Use parallel requests or batch endpoint
    
def normalize():
    """Convert to YAML schema"""
    
def validate():
    """Check completeness"""
    
def commit():
    """Git commit + tag"""
    # git add _wbopendata_*.yaml
    # git commit -m "Update metadata: 2025-12-15"
    # git tag metadata-2025-12-15
    # git push origin metadata-2025-12-15
```

### Pros

✅ **Fully automated** - Always up-to-date metadata  
✅ **No manual intervention** - Set and forget  
✅ **Version control** - Full history of metadata changes  
✅ **Rollback capability** - Can revert to older metadata  
✅ **Transparency** - Users can see what changed  
✅ **Multiplatform sync** - YAML shared across Python/R/Stata  
✅ **Cache strategy** - Works offline after first download  
✅ **Enterprise-ready** - Aligns with mature data workflows  

### Cons

❌ **High complexity** - Multiple systems integration  
❌ **Requires Python** - Separate language/toolchain  
❌ **CI/CD complexity** - GitHub Actions setup, testing  
❌ **Dependency management** - Python version, packages  
❌ **More maintenance** - Automation itself needs monitoring  
❌ **API throttling risk** - Bulk fetches can hit rate limits  
⚠️ **Harder to debug** - Automation failures harder to diagnose  
⚠️ **Long initial timeline** - Won't ship quickly  

### Best For

- **Large organizations** - Multiple teams using wbopendata
- **Mission-critical deployments** - Need reliable updates
- **Open-source maturity** - Want best-in-class infrastructure
- **Long-term sustainability** - Can invest in automation
- **Teams with Python expertise** - Can maintain automation

### Dependencies

- **yaml.ado** (from SSC)
- **Python 3.8+** (for update script)
- **requests**, **pyyaml** (Python packages)
- **GitHub Actions** (or alternative CI/CD)

### Effort Estimate

- **Pathway B foundation:** 6-8 weeks
- **Python automation:** 3-4 weeks
- **CI/CD setup & testing:** 2-3 weeks
- **Total development:** 11-15 weeks
- **Maintenance:** 4-6 hours per release cycle

### Deployment Checklist

- [ ] Pathway B complete and stable
- [ ] Python update script written and tested
- [ ] GitHub Actions workflow defined
- [ ] Versioning strategy documented
- [ ] Metadata validation tests pass
- [ ] Caching mechanism works correctly
- [ ] Sync command returns correct versions
- [ ] Rollback procedure tested
- [ ] User documentation updated
- [ ] Release notes include metadata version

---

## Comparison Summary Table

| Aspect | Pathway A (DTA) | Pathway B (YAML-Lite) | Pathway C (Auto-Sync) |
|--------|---|---|---|
| **Timeline** | 3-4 wks | 6-8 wks | 11-15 wks |
| **Complexity** | Low | Medium | High |
| **External deps** | 0 | 1 (yaml.ado) | 2+ (yaml.ado + Python) |
| **Automation** | ❌ | ⚠️ Manual | ✅ Full |
| **Metadata freshness** | Stale | Updated per release | Always fresh |
| **File size** | ~600MB .dta | ~600KB YAML | ~600KB YAML |
| **Multiplatform** | ❌ | ✅ | ✅ |
| **Performance** | ⚡ Fast | ⚡ Fast | ⚡ Fast |
| **Maintenance load** | Medium | Low-Medium | Low (automated) |
| **User impact** | Medium | High | High |
| **Roadmap alignment** | Partial (v18.0) | Full (v18.0) | Full (v18.0+) |
| **Recommended** | ❌ | ✅ RECOMMENDED | ✅ Future |

---

## Decision Matrix: Which Pathway?

### Choose Pathway A if:
- Timeline constraint: Must ship in < 5 weeks
- Resource constraint: Only 1 junior developer available
- Team skill: Limited Stata experience
- Context: Proof-of-concept/learning phase
- Trade-off acceptable: Manual metadata updates OK

### Choose Pathway B if:
- Timeline realistic: 6-8 weeks available
- Resource available: 1 experienced developer
- Team skill: Comfortable with Stata + YAML concepts
- Vision: Want foundation for future automation
- Strategy: Align with unicefdata-dev pattern
- **⭐ RECOMMENDED: Balanced risk/reward**

### Choose Pathway C if:
- Timeline flexible: Can invest 3-4 months
- Resources: Multiple developers (Stata + Python)
- Team skill: Advanced Stata + Python expertise
- Vision: Enterprise-grade metadata automation
- Strategy: Mission-critical production system
- Maintenance: Team can support automation

---

## Next Steps

1. **Review this document** with team
2. **Assess resources** (timeline, skill level, budget)
3. **Select pathway** (A/B/C or hybrid)
4. **Create detailed implementation plan** for selected pathway
5. **Establish success criteria** and testing strategy
6. **Begin Phase 1** (schema design or prototype)

---

## References

**Related Documents:**
- `01-DISCOVERY-YAML-VIABILITY.md` - Executive viability summary
- `DESIGN_CHOICES.md` - Technical implementation details
- `roadmap/ROADMAP.md` - Strategic roadmap context

**External References:**
- unicefdata-dev: `config/` and `stata/src/u/_unicef_*.ado`
- yaml.ado SSC package documentation

---

*Document Status: DRAFT - For Internal Team Review*  
*Last Updated: January 20, 2026*
