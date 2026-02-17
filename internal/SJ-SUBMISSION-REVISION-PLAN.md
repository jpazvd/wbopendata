# Revision Plan: SJ Paper Submission

**Paper**: `azevedo-2026-wbopendata.tex`
**Target**: `azevedo-2026-wbopendata-sj-submitted.tex`
**Date**: 2026-02-17

---

## Summary

Cross-reference of initial review findings against the [SJ submission guidelines](../.github/copilot-sj-paper-instructions.md). Items are grouped by severity.

---

## Must Fix (compile errors)

### 1. `hyperref` option clash

- **Source**: Line 17 — `\usepackage[hidelinks]{hyperref}`
- **Problem**: `statapress.cls` already loads `hyperref` internally. Adding it again with options causes `! LaTeX Error: Option clash for package hyperref`.
- **SJ guideline**: The preamble template in the SJ instructions does NOT include `hyperref` — the class handles it.
- **Fix**: Remove line 17 entirely, or replace with `\PassOptionsToPackage{hidelinks}{hyperref}` placed **before** `\documentclass`.

### 2. `\textdollar` undefined in appendix figure captions

- **Source**: Lines 1260, 1280 (Appendix A figures)
- **Problem**: `\textdollar` is not defined in the `statapress` class, causing four `! Missing number, treated as zero` errors.
- **SJ guideline**: Section 12 ("Common Pitfalls") states: use `\$` for dollar signs.
- **Fix**: Replace `\textdollar` with `\$` on both lines.

---

## Should Fix (SJ requirements)

### 3. Author affiliation block incomplete

- **Source**: Lines 34-37
- **Current**: Only `jpazvd.github.io`
- **SJ guideline**: Section 4 requires: Name, Institution, Department, Address, City/State/ZIP, email. Example in the SJ instructions shows full UNICEF affiliation.
- **Fix**: Expand to include UNICEF, DAPM, New York address, and email.

### 4. Keywords format

- **Source**: Line 47
- **Current**: `\keywords{Stata, Open Data, World Bank, APIs, reproducible research, development indicators, metadata}`
- **SJ guideline**: Section 5 states: First keyword = article tag (placeholder `st0001`), second = command name.
- **Fix**: Change to `\keywords{st0001, wbopendata, Open Data, World Bank, APIs, reproducible research, development indicators}`

### 5. Figure placement specifiers: `[H]` vs `[htbp]`

- **Source**: All `\begin{figure}[H]` and `\begin{table}[H]` throughout
- **Problem**: `[H]` requires `\usepackage{float}` and forces exact placement. SJ prefers `[htbp]` for standard float behavior.
- **SJ guideline**: Section 8 states: "Use `[htbp]` placement specifier."
- **Fix**: Replace `[H]` with `[htbp]` and remove `\usepackage{float}` from preamble.

### 6. Figure/table call-out order

- **Source**: Multiple locations
- **SJ guideline**: Section 8 states: "Must reference in text BEFORE figure appears." Section 13 checklist: "Figures... called out before appearance."
- **Audit needed**: Verify every `Figure~\ref{...}` and `Table~\ref{...}` appears in text before the corresponding `\begin{figure}` or `\begin{table}`.
- **Known issues**:
  - Table 1 (`tab:coverage`) at line 258 — first referenced at line 60 via "Table~\ref{tab:coverage}" — OK
  - Table 2 (`tab:stored`) — **never cross-referenced in text** (label exists but no `\ref`)
  - Table 3 (`tab:stored-discovery`) — referenced at line 521 before float at 523 — OK
  - Table 4 (`tab:test-coverage`) — referenced at line 845 before float at 847 — OK
  - Figure 1 (`fig:linewrap`) — referenced at line 621 before float at 626 — OK
  - Appendix figures: `fig:map`, `fig:scatter`, `fig:worldstat_africa`, `fig:worldstat_fertility` — **none referenced in appendix text before the floats**
- **Fix**: Add `\ref` calls before each float, or remove unused labels.

### 7. BibTeX entry issues

- **`overazevedo2000linewrap`** (line 96 of .bib):
  - Author field: `Jo\~{a}o` renders as "J.~a.~P." in .bbl — BibTeX misparses the tilde.
  - Fix: Use `Jo{\~a}o Pedro` in the author field.
  - Title field: Includes "Version 2.1 4Jun2023" which duplicates the `note` field.
  - Fix: Remove version info from title.
  - Missing journal field: triggers BibTeX warning.
  - Fix: Change to `@misc` type.

- **`clarke2012worldstat`, `elliott2002tknz`, `pisati2007spmap`**:
  - These are SSC components, not journal articles, but use `@article` type with `number` but no `volume`.
  - Fix: Change to `@misc` type.

### 8. Unused bib entries (7)

| Key | Status |
|-----|--------|
| `azevedo2026wbopendata` | Keep (self-reference) |
| `baum2009introduction` | Remove (not cited) |
| `camerer2016evaluating` | Remove (not cited) |
| `iso2013sdmx` | Consider citing (SDMX mentioned in v2 but dropped) or remove |
| `jann2016texdoc` | Remove (not cited) |
| `pisati2007shp2dta` | Remove (not cited; `pisati2007spmap` IS cited via `\nocite`) |
| `semver2024` | Remove (not cited) |

---

## Nice to Have (polish)

### 9. Unused labels (15)

Labels defined but never `\ref`'d: `app:diagnostics:info`, `app:diagnostics:search`, `app:examples:data`, `app:examples:extensions`, `fig:map`, `fig:scatter`, `fig:worldstat_africa`, `fig:worldstat_fertility`, `sec:intro`, `sec:metadata`, `sec:sync`, `sec:workflow-discovery`, `sec:workflow-pipeline`, `sec:yaml`, `tab:stored`.

- **Decision**: Add cross-references where natural, remove orphan labels otherwise.

### 10. `\floatnote` custom command

- **Source**: Line 20-26 — defines `\floatnote` macro
- **Risk**: Custom macros may conflict with SJ editorial processing.
- **Fix**: Keep for now; SJ copy editors will adjust if needed.

### 11. Abstract length

- **Current**: ~250 words (right at the upper boundary of the 150-250 word guideline)
- **Fix**: Consider trimming slightly for safety.

### 12. `\keywords` placement

- **Current**: Inside `\begin{abstract}...\end{abstract}` block
- **SJ template**: Shows `\keywords` after `\end{abstract}`
- **Fix**: Move `\keywords` outside the abstract environment.

---

## Checklist: SJ Submission Requirements

Based on Section 13 of the SJ instructions:

| Requirement | Status | Notes |
|-------------|--------|-------|
| Short title provided | OK | "Data Provenance in the Age of Automation" (42 chars) |
| Author affiliations complete | **FIX** | Missing institution, address, email |
| Abstract stands alone | OK | No undefined acronyms |
| Keywords include command name | **FIX** | Missing `st0001` tag and `wbopendata` |
| Figures PDF/EPS | OK | All 5 figures are PDF |
| Figures grayscale | VERIFY | Need to check if color-only |
| Figures called out before appearance | **FIX** | Appendix figures not cross-referenced |
| Tables in main text | OK | |
| Tables called out before appearance | **FIX** | `tab:stored` never referenced |
| Code 80-char linesize | OK | sjlog outputs appear well-formatted |
| Conclusions section | OK | Section 7 |
| Acknowledgments separate section | OK | `\section*{Acknowledgments}` |
| About the author(s) | OK | `\begin{aboutauthors}` |
| References Chicago style | OK | Uses `sj.bst` |
| No issue numbers in refs | OK | |
| `sj_clean.sty` for initial submission | OK | Correct for draft/initial |
| Cover letter | NEEDED | Separate file required |
| Software package | SEPARATE | SSC zip already prepared |

---

## File Plan

| Current | New |
|---------|-----|
| `azevedo-2026-wbopendata.tex` | Keep as working draft |
| — | `azevedo-2026-wbopendata-sj-submitted.tex` (clean submission copy) |
| `wbopendata.bib` | Update in place (fixes apply to all versions) |
