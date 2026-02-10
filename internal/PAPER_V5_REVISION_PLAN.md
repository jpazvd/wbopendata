# Paper v5 Revision Plan: Updating for wbopendata v18.0.0

**Source:** `paper/jpazvd_wbopendata_v4.tex`
**Target:** `paper/jpazvd_wbopendata_v5.tex`
**Date:** February 9, 2026
**Status:** Planning

---

## Executive Summary

Paper v4 documents wbopendata through v17.7.1. Version 18.0.0 introduces three major features absent from the paper: **discovery commands**, **YAML metadata architecture**, and **sync system**. The test suite has grown from 44 tests / 7 categories to **65 tests / 15 categories**. This plan identifies every required change, organized by priority and section.

---

## Priority 1: New Sections Required

These are entirely new content blocks that must be written.

### P1-A. Discovery Commands Subsection (Section 3)

**Location:** New `\subsection{Discovery commands (v18.0)}` after "Graph metadata (v17.7.1+)" (after line 349)

**Content to cover:**
- `sources` — list all 51 data sources with indicator counts and clickable navigation
- `alltopics` — list all 21 topic categories with indicator counts
- `search(pattern)` — keyword, wildcard, multi-keyword (`+`), and regex (`~`) search
- `searchsource(#)` / `searchtopic(#)` — filter search by source or topic
- `searchfield(fields)` — restrict search to specific metadata fields (code, name, description, source, topic, note, all)
- `exact` — require exact match
- `detail` — wrapped block format display
- `limit(#)` — maximum results (default 20)
- `info(code)` — detailed indicator metadata display

**Design note:** Credit `unicefdata` (Azevedo, 2026) as the model for the discovery architecture (YAML-backed offline catalog, clickable SMCL navigation). Already documented in sthlp lines 267–270.

**Syntax block to add:**
```latex
\hangpara
\texttt{sources} lists all World Bank data sources with indicator counts and clickable navigation links.

\hangpara
\texttt{alltopics} lists all 21 topic categories with indicator counts and clickable navigation.

\hangpara
\texttt{search(\ststring)} searches indicators by keyword, wildcard pattern, or regex. Multiple keywords joined with \texttt{+} require all to match. Prefix with \texttt{\~} for full regex syntax.

\hangpara
\texttt{searchsource(\num)} filters search results to a specific source ID.

\hangpara
\texttt{searchtopic(\num)} filters search results to a specific topic ID.

\hangpara
\texttt{searchfield(\ststring)} restricts search to specified fields: \texttt{code}, \texttt{name}, \texttt{description}, \texttt{source}, \texttt{topic}, \texttt{note}, or \texttt{all} (default).

\hangpara
\texttt{exact} requires exact code match (no partial matching).

\hangpara
\texttt{detail} shows results in wrapped block format with full labels.

\hangpara
\texttt{limit(\num)} sets maximum results to display (default 20).

\hangpara
\texttt{info(\ststring)} displays detailed metadata for a specific indicator, including name, source, topics, description, methodology notes, and clickable download links.
```

### P1-B. Discovery Stored Results (Section 3.2, Table 3)

**Location:** Extend Table 3 (`tab:stored`) with discovery command returns

**New rows to add (after linewrap section):**

| Result | Type | Description |
|--------|------|-------------|
| **wbopendata, sources** | | |
| `r(n_sources)` | scalar | Total number of data sources |
| `r(n_indicators)` | scalar | Total indicator count across all sources |
| `r(source_codes)` | local | Space-separated list of source IDs |
| `r(source_names)` | local | Compound-quoted list of source names |
| **wbopendata, alltopics** | | |
| `r(n_topics)` | scalar | Total number of topics |
| `r(topic_ids)` | local | Space-separated list of topic IDs |
| `r(topic_names)` | local | Compound-quoted list of topic names |
| **wbopendata, search(pattern)** | | |
| `r(n_results)` | scalar | Total matches found |
| `r(n_displayed)` | scalar | Matches displayed after limit |
| `r(first_code)` | local | First matching indicator code |
| `r(codes)` | local | Space-separated list of indicator codes |
| `r(names)` | local | Compound-quoted list of indicator names |
| `r(keyword)` | local | Search keyword used |
| **wbopendata, info(code)** | | |
| `r(indicator)` | local | Indicator code |
| `r(name)` | local | Indicator name |
| `r(source_id)` | local | Source database ID |
| `r(source_name)` | local | Source database name |
| `r(description)` | local | Full indicator description |
| `r(note)` | local | Methodology note |
| `r(cmd)` | local | Reproducible command string |

**All discovery commands also return `r(cmd)`** — reproducible command string.

### P1-C. Discovery Workflow (Section 4)

**Location:** New `\subsection{Discovery workflow}` — fourth canonical workflow (after line 507)

**Content:** Document the browse→search→info→download pipeline:
```
1. wbopendata, sources                          % browse available sources
2. wbopendata, searchsource(2) limit(30)        % explore WDI indicators
3. wbopendata, search(poverty) searchtopic(11)  % search within topic
4. wbopendata, info(SI.POV.DDAY)                % detailed indicator info
5. wbopendata, indicator(SI.POV.DDAY) clear long % download data
```

**Key argument:** Discovery commands support the paper's central thesis (data acquisition as code) by making indicator selection itself a scripted, auditable process rather than manual browsing of web portals.

### P1-D. Sync and YAML Metadata Subsection (Section 5.5)

**Location:** Replace or significantly expand "Metadata management" subsection (lines 638–663)

**Content to cover:**

1. **YAML metadata architecture** — two files:
   - `_wbopendata_indicators.yaml` (17 MB, ~29,323 indicators, ~100K+ lines)
   - `_wbopendata_parameters.yaml` (country metadata, source/topic lists)
   - Stored in cache directory with version tracking

2. **Sync system (Design B):**
   - `sync` — dry-run preview of metadata changes (safe default)
   - `sync detail` — per-source and per-topic indicator breakdown
   - `sync force` — force-refresh preview (re-query API); still dry run
   - `sync replace` — apply metadata sync (download latest from GitHub)
   - `sync replace force` — force re-download regardless of local version
   - Key design: `replace` is an explicit safety gate

3. **Cache management commands:**
   - `checkupdate` — check if newer YAML is available without downloading
   - `clearcache` — remove local metadata cache
   - `cacheinfo` — display cache location, version, timestamp

4. **Performance characteristics:**
   - First search call: ~9s (parse + frame cache build)
   - Subsequent calls: <0.5s (frame cache hit, Stata 16+)

**Keep existing `update query/check/all` documentation** — these still work and are backward-compatible.

---

## Priority 2: Version Number and Count Updates

Precise text changes required at specific locations.

### P2-A. Abstract (line 44–47)

| Current | Required |
|---------|----------|
| "44-scenario test suite" | "65-scenario test suite" |
| No mention of discovery | Add: "offline indicator discovery through YAML-backed metadata" |
| No mention of sync | Add: "version-controlled metadata synchronization" |

**Proposed abstract addition** (insert after "publication-ready graph formatting"):
> Version 18.0 adds offline indicator discovery—keyword search, source browsing, and detailed metadata inspection—through a YAML-backed metadata architecture modeled on `unicefdata` (Azevedo, 2026), together with a version-controlled metadata synchronization system.

### P2-B. Section 3 intro (line 257)

| Current | Required |
|---------|----------|
| "v17.7.1 adds basic country context...by default" | Keep, but add sentence about v18.0.0 features |

**Add after existing sentence:**
> Version 18.0 introduces discovery commands for offline catalog browsing, a YAML-backed metadata architecture with over 29,000 indicator records, and a sync system for version-controlled metadata updates.

### P2-C. Section 5.4 — Test suite (lines 606–607)

| Current | Required |
|---------|----------|
| "44 integrated tests...13 categories" | "65 integrated tests...15 categories" |

### P2-D. Table 5 caption (line 611)

| Current | Required |
|---------|----------|
| "44 tests across 7 categories" | "65 tests across 15 categories" |

### P2-E. Table 5 body (lines 614–627)

**Current (7 categories, 44 tests):**

| Abbr | Category | Tests |
|------|----------|:-----:|
| ENV | Environment | 2 |
| DL | Download modes | 8 |
| FMT | Output format | 5 |
| CTRY | Country options | 4 |
| LW | Linewrap | 6 |
| REG | Regression | 7 |
| ADV | Advanced | 12 |

**Required (15 categories, 65 tests):**

| Abbr | Category | Tests | Focus |
|------|----------|:-----:|-------|
| ENV | Environment | 5 | Network, API, YAML file presence |
| DL | Download modes | 5 | Indicator, country, multi-indicator |
| FMT | Output format | 4 | Wide, long, latest, nobasic |
| CTRY | Country options | 10 | Basic, full, geo, ISO, regions, income, lending |
| REG | Regression | 4 | Historical bug fixes (#33, #45, #46, #51) |
| LW | Linewrap | 4 | Metadata wrapping, formats, latest scalars |
| UPD | Update commands | 6 | Query, check, describe, update all |
| TOPIC | Topic queries | 1 | Topic download |
| LANG | Language | 1 | Spanish metadata |
| DESC | Describe | 0* | (verify; may be under UPD-02) |
| PROJ | Projection | 1 | Population projection data |
| CACHE | Cache management | 8 | Init, path resolution, clear, persist, version, timestamp, search |
| SYNC | Sync system | 5 | Check, download, force, up-to-date, discovery integration |
| DISC | Discovery | 7 | Sources, topics, search, filter, info, allsources, alltopics |

*Note: Exact counts should be verified against `run_tests.do` before final edit. The test_protocol.md shows 65 total.*

### P2-F. Conclusion (line 773)

| Current | Required |
|---------|----------|
| "Version~17.7.1 extends this approach with publication-ready metadata handling, default country-context attributes, and strengthened support for multi-indicator workflows." | "Version~18.0 extends this approach with offline discovery commands for catalog browsing and indicator search, a YAML-backed metadata architecture, version-controlled metadata synchronization, publication-ready metadata handling, and a 65-test QA suite across 15 categories." |

---

## Priority 3: Bibliography Updates

### P3-A. Update `unicefdata2024` entry

**Current (wbopendata.bib, line 96–103):**
```bibtex
@misc{unicefdata2024,
  author = {Azevedo, Jo{\~a}o Pedro},
  title  = {unicefData: {P}rogrammatic access to {UNICEF} {SDMX} data warehouse},
  year   = {2024},
  ...
}
```

**Required:**
```bibtex
@misc{unicefdata2026,
  author = {Azevedo, Jo{\~a}o Pedro},
  title  = {unicefdata: {U}nified access to {UNICEF} indicators across {R}, {Python}, and {Stata}},
  year   = {2026},
  howpublished = {Mimeo, UNICEF Chief Statistician Office},
  url    = {https://github.com/unicef-drp/unicefData},
  note   = {Interfaces for R, Python, and Stata}
}
```

**Impact:** Update all `\citep{unicefdata2024}` → `\citep{unicefdata2026}` (line 219).

### P3-B. Add self-citation for the mimeo

```bibtex
@misc{azevedo2026wbopendata,
  author = {Azevedo, Jo{\~a}o Pedro},
  title  = {Data Provenance in the Age of Automation: Lessons from Fifteen Years of Programmatic Access to World Bank Open Data},
  year   = {2026},
  howpublished = {Mimeo},
  url    = {https://github.com/jpazvd/wbopendata}
}
```

### P3-C. Update API documentation year

`worldbank2024api` → consider updating year to 2026 if the URL content has changed.

---

## Priority 4: Section-Specific Content Refinements

### P4-A. Section 2.4 — Diffusion (line 218–222)

**Current text (line 218–222):**
> "the same design logic has been extended to multi-language data access through `unicefData` \citep{unicefdata2024}, which provides a triangulated suite..."

**Required changes:**
1. Update cite key: `\citep{unicefdata2024}` → `\citep{unicefdata2026}`
2. Add note about bidirectional influence: wbopendata's discovery architecture was modeled on unicefdata's pioneering implementation
3. Consider adding: "The discovery architecture introduced by `unicefdata`—offline catalog browsing with YAML-backed metadata and clickable SMCL navigation—was subsequently adopted by `wbopendata` (v18.0), demonstrating the portability of these design patterns across data ecosystems."

### P4-B. Section 3.1 — Syntax: `describe` option

**Missing from paper.** The `describe` option (display indicator metadata without downloading data) is documented in the sthlp but absent from the syntax section. Add:

```latex
\hangpara
\texttt{\underbar{desc}ribe} displays indicator metadata without downloading data. Requires \texttt{indicator()}. Useful for exploring indicator definitions and sources before committing to a full download.
```

*(Note: line 306–307 has a brief mention but it's under "Output format" rather than as a formal syntax entry. Verify if it needs expansion.)*

### P4-C. Section 5.2 — Architecture (line 541–560)

**Add modular architecture note:**
> Version 18.0 refactors the implementation into a modular architecture of 34 ado files, with sub-routines (prefixed `_wbopendata_`) handling YAML parsing, search, sync, cache management, and discovery commands. This modular design improves maintainability and enables independent testing of components.

### P4-D. Section 5.4 — Test categories text (line 604–607)

Update "Because Stata lacks the mature continuous integration..." paragraph to reflect expanded scope:
> The test suite comprises 65 integrated tests distributed across 15 categories, covering environment validation, data download modes, output formatting, country metadata, linewrap graph annotation, regression protection, update commands, topic queries, language options, describe functionality, population projections, cache management, metadata synchronization, and discovery commands.

---

## Priority 5: Appendix and Supplementary Material

### P5-A. Regenerate sjlogs

The following sjlog files need regeneration against v18.0.0:

| File | Reason |
|------|--------|
| `run_tests_excerpt.log.tex` | Will show 65 tests, 15 categories |
| `run_tests_summary_excerpt.log.tex` | Will show expanded summary |
| `ex_update.log.tex` | May show different output with sync system |

### P5-B. New sjlogs to create

| File | Content |
|------|---------|
| `ex_discovery_sources.log.tex` | Output of `wbopendata, sources` |
| `ex_discovery_search.log.tex` | Output of `wbopendata, search(GDP) limit(5)` |
| `ex_discovery_info.log.tex` | Output of `wbopendata, info(SI.POV.DDAY)` |
| `ex_sync_preview.log.tex` | Output of `wbopendata, sync` |
| `ex_sync_detail.log.tex` | Output of `wbopendata, sync detail` |

### P5-C. New appendix subsections

**Appendix A — add discovery examples:**
- `A.x Discovery workflow (verbatim output)` — sources → search → info → download

**Appendix B — add sync diagnostics:**
- `B.x Sync preview output` — what users see with `wbopendata, sync`
- `B.x Cache info output` — what users see with `wbopendata, cacheinfo`

---

## Priority 6: Consistency and Polish

### P6-A. Sections menu in intro (lines 91–96)

Verify section references still match after adding new subsections. The intro currently lists:
- Section 2: Design principles
- Section 3: Command syntax
- Section 4: Workflows
- Section 5: Technical implementation
- Section 6: Discussion
- Section 7: Conclusion

These section numbers remain correct if new content is added as subsections rather than new top-level sections.

### P6-B. Country attributes table (Table 4)

**Current:** 17 attributes listed (line 321). Verify against v18.0.0 sthlp (lines 417–434) — appears complete.

### P6-C. Cross-references

After all edits, verify all `\ref{}` and `\label{}` cross-references compile correctly.

---

## Implementation Checklist

- [ ] **P1-A** Write discovery commands subsection (Section 3)
- [ ] **P1-B** Extend stored results table with discovery returns
- [ ] **P1-C** Write discovery workflow subsection (Section 4)
- [ ] **P1-D** Write/expand sync and YAML metadata subsection (Section 5.5)
- [ ] **P2-A** Update abstract (test count, discovery mention)
- [ ] **P2-B** Update Section 3 intro (v18.0 features)
- [ ] **P2-C** Update test suite count in Section 5.4
- [ ] **P2-D** Update Table 5 caption
- [ ] **P2-E** Rewrite Table 5 body (15 categories, 65 tests)
- [ ] **P2-F** Update conclusion (v18.0, test count)
- [ ] **P3-A** Update unicefdata bib entry (year, title)
- [ ] **P3-B** Add self-citation bib entry
- [ ] **P3-C** Update API documentation year
- [ ] **P4-A** Update diffusion subsection (unicefdata cite + bidirectional note)
- [ ] **P4-B** Add `describe` option to syntax
- [ ] **P4-C** Add modular architecture note
- [ ] **P4-D** Update test categories description text
- [ ] **P5-A** Regenerate affected sjlogs
- [ ] **P5-B** Create new discovery/sync sjlogs
- [ ] **P5-C** Add appendix subsections for discovery and sync
- [ ] **P6-A** Verify section cross-references
- [ ] **P6-B** Verify country attributes table
- [ ] **P6-C** Verify all LaTeX cross-references compile

---

## Files Affected

| File | Changes |
|------|---------|
| `paper/jpazvd_wbopendata_v4.tex` → `v5.tex` | All P1–P6 edits |
| `paper/wbopendata.bib` | P3-A, P3-B, P3-C |
| `paper/sjlogs/*.log.tex` | P5-A, P5-B (regeneration) |
| `paper/sjlogs/*.tex` | P5-B (new .do scripts to generate logs) |

---

## Estimated Effort

| Priority | Items | Effort |
|----------|:-----:|--------|
| P1 (new sections) | 4 | Major — new prose + LaTeX |
| P2 (version updates) | 6 | Moderate — precise text edits |
| P3 (bibliography) | 3 | Minor — bib entry edits |
| P4 (refinements) | 4 | Moderate — paragraph-level edits |
| P5 (appendix/logs) | 3 | Major — requires running Stata |
| P6 (polish) | 3 | Minor — verification |
