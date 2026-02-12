# Structured Discussion: Drukker (2006) and Gould (2001) as References for wbopendata

**Purpose**: Identify what elements of these two Stata Journal papers should (a) be cited
in the wbopendata working paper, and (b) be incorporated into the actual code.

---

## Part I: Drukker (2006) — "Importing Federal Reserve economic data"

### Summary

A 3-page note introducing `freduse`, a command to import time-series data from the
Federal Reserve Economic Data (FRED) repository directly into Stata. The key
contribution is not the code itself but the pattern it established: data acquisition
as a one-line Stata command (`freduse GDPC96`) that downloads, parses, labels, and
annotates data in memory.

### What makes freduse relevant to wbopendata

`freduse` is the closest direct precedent in the Stata Journal literature for what
wbopendata does. Both commands:
- retrieve data from an institutional REST/HTTP endpoint
- produce a ready-to-use Stata dataset in memory
- handle single-series and multiple-series workflows
- attach metadata to the downloaded variables
- support both remote and local-file modes

The key architectural difference is how each command stores metadata:

| Mechanism | freduse | wbopendata |
|-----------|---------|------------|
| Variable labels | Series title | Indicator code |
| Variable characteristics (`char`) | Full header (title, units, frequency, source, dates, notes) | Not used |
| Return values (`r()`) | Not used | Rich metadata (source, description, topic, note, sourcecite) |
| Dataset characteristics (`_dta[]`) | Not used | Not used |

This difference has practical consequences. In `freduse`, metadata is **persistent** —
it survives `save`/`use` cycles and remains attached to the variable:

```stata
freduse GDPC96
save mydata, replace
use mydata, clear
char list GDPC96[]    // all metadata still present
```

In `wbopendata`, metadata is **ephemeral** — `r()` values disappear after the next
r-class command:

```stata
wbopendata, indicator(NY.GDP.MKTP.CD) clear
return list             // metadata available
summarize ny_gdp_mktp_cd  // r() overwritten — metadata gone
```

### Why `char` is not a substantive change for wbopendata

This difference is architecturally interesting but **not a gap that needs filling**.
The reason lies in wbopendata's own design principle.

The paper (Section 2.1) argues that "a command line documents what data were requested,
from which source, and under what constraints." If the do-file IS the provenance
record, then embedding metadata in the `.dta` file via `char` is **redundant** — the
command that generated the data already documents everything a researcher needs to
reproduce the download.

`freduse` needed `char` because FRED series have rich per-variable header metadata
(units, frequency, seasonal adjustment) that Stata's variable labels alone cannot
capture, and because FRED series names are short opaque codes (`GDPC96`) that carry
no intrinsic meaning. wbopendata's indicator codes are similarly opaque, but the
command's `r()` return values already make that metadata available in the program flow,
and the do-file command line itself constitutes a complete provenance record.

The only scenario where `char` becomes more than a convenience is when `.dta` files
circulate **without** the generating do-file — a researcher inherits `mydata.dta` with
no code. But that is precisely the workflow the paper argues against. If the user
follows the data-acquisition-as-code principle, the do-file exists and is the
authoritative record.

**Conclusion:** The architectural contrast between freduse (persistent metadata via
`char`) and wbopendata (ephemeral metadata via `r()` plus the do-file as provenance)
is worth **mentioning in the paper** as a deliberate design choice, not as a deficiency.
It actually strengthens the argument: wbopendata prioritizes the do-file as the single
source of truth, which is the more principled position for reproducibility.

`char` support (dataset-level stamps for version/timestamp, variable-level metadata as
opt-in) remains a reasonable v19 convenience feature, but it should be framed as
incremental — not architectural.

### For the paper: citation points

1. **Section 2.1 (Data acquisition as code)** — Cite Drukker as establishing the
   pattern that wbopendata builds on. freduse demonstrated in 2006 that scripted
   data acquisition from institutional APIs is both feasible and natural in Stata.

2. **Section 2.4 (Scope and diffusion)** — freduse positioned alongside wbopendata,
   worldstat, and unicefdata as a family of Stata commands that bridge institutional
   data repositories and the Stata analytical environment.

3. **Section 5.2 (Architecture)** — Drukker's use of `char` for persistent metadata
   vs. wbopendata's `r()` plus do-file provenance: a deliberate design contrast, not a
   gap. freduse stores metadata in the data; wbopendata stores it in the code. Both are
   valid, but wbopendata's approach is more aligned with reproducibility principles.

4. **Section 3.3 (Stored results)** — Note that `r()` values are ephemeral by design;
   the do-file serves as the durable metadata record.

### BibTeX entry

```bibtex
@article{drukker2006freduse,
  author  = {David M. Drukker},
  title   = {Importing {Federal Reserve} economic data},
  journal = {The Stata Journal},
  year    = {2006},
  volume  = {6},
  number  = {3},
  pages   = {384--386}
}
```

---

## Part II: Gould (2001) — "Statistical software certification"

### Summary

A 22-page article documenting how StataCorp certifies Stata prior to release using
automated do-file scripts built around the `assert` command. The first part describes
StataCorp's internal process (1,064 do-files, 38 million commands, nested test
directories). The second part shows how the same techniques can be adopted by
user-written ado-file authors, with a worked example testing `xttest3`.

### What makes Gould relevant to wbopendata

The wbopendata paper (v4) has an extensive Appendix C on quality assurance and testing,
but it currently cites no prior literature on Stata software certification. Gould's
paper provides the authoritative foundation for every testing practice the paper
describes.

### For the paper: citation points

1. **Appendix C.1 (Testing philosophy: operational validation)**

   Gould establishes the paradigm: "The scripts not only set up problems and run them,
   but also include code to verify that the results are as expected. If a result deviates
   from what is expected, the test script produces error messages and stops."

   wbopendata's test suite follows this pattern exactly. Citing Gould anchors the
   approach in StataCorp's own methodology rather than presenting it as ad hoc.

   Key quote for citation: "Stata is instead tested using an automated procedure [...]
   The primary way Stata is certified involves the construction of the test scripts
   themselves: The scripts not only set up problems and run them, but also include code
   to verify that the results are as expected."

2. **Appendix C.3 (Regression testing and cumulative reliability)**

   Gould: "Every time a new feature is added to Stata, or a bug reported and fixed, or a
   change made to the code, additions are made to the test scripts."

   This is exactly what wbopendata's REG-33, REG-45, REG-46, REG-51 tests implement.
   The paper says "Once a bug is resolved, the corresponding test remains in the suite
   and must pass in all subsequent runs" — cite Gould as the source of this principle.

   Gould also states the "never delete, always add" rule: "An important rule of
   test-script writing is never to delete. Instead, you should add. The more you test
   a command, the better."

3. **Appendix C.2 (Test harness structure)**

   Gould's `testall.do` → subdirectory `test.do` → individual `xyz.do` pattern is a
   precursor to wbopendata's `run_tests.do` with named test IDs. Worth citing to show
   that the organizational principle has precedent.

4. **Appendix C.5 (Diagnostics and failure modes)**

   Gould on testing for expected errors using `rcof`: "rcof runs a command and verifies
   that the return code is as stated." wbopendata tests deprecated indicators and
   invalid syntax — cite Gould's framework for negative testing.

5. **Appendix C.7 (Continuous validation under ecosystem constraints)**

   The paper argues that "rigorous quality assurance is achievable even in environments
   without formal automation pipelines." Gould demonstrates that StataCorp itself
   certifies without CI/CD — just reproducible do-files. This legitimizes wbopendata's
   approach as following the standard set by Stata's own creators.

6. **Section 5.4 (Testing and error handling)**

   Gould's discussion of extreme-case testing ("R² = 1 regressions; xt estimators run
   on a single panel") maps to wbopendata's edge cases: deprecated indicators, empty
   API responses, single-country queries, topics with parenthetical names.

7. **Simultaneous authoring** — Gould advocates writing tests alongside code: "three
   windows open at once: the command, the test script, and Stata." This describes
   exactly the development pattern used for wbopendata v18.0.

### BibTeX entry

```bibtex
@article{gould2001certification,
  author  = {William Gould},
  title   = {Statistical software certification},
  journal = {The Stata Journal},
  year    = {2001},
  volume  = {1},
  number  = {1},
  pages   = {29--50}
}
```

---

## Part III: `char` metadata implementation (v18.1 — branch `feat/char-metadata`)

### Design decision

Following the freduse precedent (Drukker 2006), wbopendata will attach persistent
metadata to downloaded datasets using Stata's `char` (variable characteristics)
mechanism. Both dataset-level and variable-level characteristics are set by default.
A `nochar` option suppresses this behavior for users who want minimal overhead.

While the do-file remains the authoritative provenance record, `char` adds a
complementary layer: the `.dta` file itself carries machine-readable metadata that
survives `save`/`use` cycles. This is useful when datasets are shared, archived, or
revisited long after the original download.

### Syntax

```
wbopendata, indicator(code) [nochar] ...
```

- **Default**: `char` metadata is always written (both `_dta` and variable-level)
- **`nochar`**: suppresses all `char` writes; behavior identical to v18.0

The `nochar` option follows the same noBASIC pattern already used in wbopendata
(the `no` prefix convention: `noBASIC`, `noMETADATA`, `noCHAR`).

### Dataset-level characteristics (`_dta`)

Set once per download session in `wbopendata.ado`, after the download completes
and before `return add` (around line 768). These capture the session context:

```stata
wbopendata, indicator(NY.GDP.MKTP.CD; SP.POP.TOTL) country(BRA;ARG) clear

char list _dta[]
  _dta[wbopendata_version]:     18.0.0
  _dta[wbopendata_timestamp]:   10 Feb 2026 14:32:05
  _dta[wbopendata_user]:        jpazevedo
  _dta[wbopendata_syntax]:      wbopendata, indicator(NY.GDP.MKTP.CD; SP.POP.TOTL) country(BRA;ARG) clear
  _dta[wbopendata_indicator]:   NY.GDP.MKTP.CD; SP.POP.TOTL
  _dta[wbopendata_country]:     BRA;ARG
  _dta[wbopendata_language]:    en
  _dta[wbopendata_source_id]:   2
```

**Fields:**

| Char name | Source | Description |
|-----------|--------|-------------|
| `wbopendata_version` | hardcoded | Package version (e.g., `18.0.0`) |
| `wbopendata_timestamp` | `c(current_date)` + `c(current_time)` | When the download was executed |
| `wbopendata_user` | `c(username)` | Stata username at time of download |
| `wbopendata_syntax` | `0` (full command line) | Exact syntax used — the executable provenance record |
| `wbopendata_indicator` | `indicator` local | Indicator code(s) requested |
| `wbopendata_country` | `country` local | Country filter (if any) |
| `wbopendata_language` | `language` local | Language (en/es/fr) |
| `wbopendata_source_id` | `source` local | Source database filter (if any) |

**Implementation in `wbopendata.ado`** (insert after line 762, before `return add`):

```stata
* --- char metadata (default on, suppressed by nochar) ---
if ("`char'" != "nochar") {
    char _dta[wbopendata_version]   "18.0.0"
    char _dta[wbopendata_timestamp] "`c(current_date)' `c(current_time)'"
    char _dta[wbopendata_user]      "`c(username)'"
    char _dta[wbopendata_syntax]    `"wbopendata, `0'"'
    char _dta[wbopendata_indicator] "`indicator'"
    if ("`country'" != "")  char _dta[wbopendata_country]   "`country'"
    if ("`language'" != "") char _dta[wbopendata_language]   "`language'"
    if ("`source'" != "")   char _dta[wbopendata_source_id] "`source'"
}
```

### Variable-level characteristics (per indicator)

Set in `_query.ado` immediately after the variable is renamed and labeled
(around line 347). Each indicator variable carries its own metadata:

```stata
wbopendata, indicator(NY.GDP.MKTP.CD) clear

char list ny_gdp_mktp_cd[]
  ny_gdp_mktp_cd[indicator]:    NY.GDP.MKTP.CD
  ny_gdp_mktp_cd[source]:       World Development Indicators
  ny_gdp_mktp_cd[description]:  GDP (current US$)
  ny_gdp_mktp_cd[topic]:        Economy & Growth
  ny_gdp_mktp_cd[note]:         GDP at purchaser's prices is the sum of gross value
                                added by all resident producers in the economy...
  ny_gdp_mktp_cd[sourcecite]:   World Bank national accounts data, and OECD National
                                Accounts data files.
```

**Fields:**

| Char name | Source (`_query_metadata` return) | Description |
|-----------|----------------------------------|-------------|
| `indicator` | `r(indicator)` | Original indicator code (with dots) |
| `source` | `r(source)` / `r(collection)` | Source database name |
| `description` | `r(description)` | Indicator description text |
| `topic` | `r(topic1)` [+ `r(topic2)`, `r(topic3)`] | Topic classification(s) |
| `note` | `r(note)` | Methodological notes (can be long) |
| `sourcecite` | `r(sourcecite)` | Source organization citation |

**Implementation in `_query.ado`** (insert after line 347 `label var`):

```stata
* --- variable-level char metadata ---
if ("`char'" != "nochar") {
    char `name'[indicator]   "`indicator'"
    char `name'[source]      "`r(source)'"
    char `name'[description] `"`r(description)'"'
    local _topic1 "`r(topic1)'"
    local _topic2 "`r(topic2)'"
    local _topic3 "`r(topic3)'"
    local _topics "`_topic1'"
    if ("`_topic2'" != "") local _topics "`_topics'; `_topic2'"
    if ("`_topic3'" != "") local _topics "`_topics'; `_topic3'"
    char `name'[topic]       "`_topics'"
    char `name'[note]        `"`r(note)'"'
    char `name'[sourcecite]  `"`r(sourcecite)'"'
}
```

**Note:** The `nochar` local must be passed from `wbopendata.ado` to `_query.ado`.
This requires adding `nochar` to the `_query` call arguments. The same applies to
the topics-mode reshape path (around line 391 in `_query.ado`).

### Multi-indicator example

```stata
wbopendata, indicator(NY.GDP.MKTP.CD; SP.POP.TOTL) long clear

* Dataset-level: session provenance
char list _dta[]
  _dta[wbopendata_version]:     18.0.0
  _dta[wbopendata_timestamp]:   10 Feb 2026 14:32:05
  _dta[wbopendata_user]:        jpazevedo
  _dta[wbopendata_syntax]:      wbopendata, indicator(NY.GDP.MKTP.CD; SP.POP.TOTL) long clear
  _dta[wbopendata_indicator]:   NY.GDP.MKTP.CD; SP.POP.TOTL
  _dta[wbopendata_language]:    en

* Variable-level: per-indicator metadata
char list ny_gdp_mktp_cd[]
  ny_gdp_mktp_cd[indicator]:    NY.GDP.MKTP.CD
  ny_gdp_mktp_cd[source]:       World Development Indicators
  ny_gdp_mktp_cd[description]:  GDP (current US$)
  ny_gdp_mktp_cd[topic]:        Economy & Growth
  ny_gdp_mktp_cd[note]:         ...
  ny_gdp_mktp_cd[sourcecite]:   ...

char list sp_pop_totl[]
  sp_pop_totl[indicator]:       SP.POP.TOTL
  sp_pop_totl[source]:          World Development Indicators
  sp_pop_totl[description]:     Population, total
  sp_pop_totl[topic]:           Health
  sp_pop_totl[note]:            ...
  sp_pop_totl[sourcecite]:      ...
```

### Suppressing chars

```stata
* Suppress all char metadata
wbopendata, indicator(NY.GDP.MKTP.CD) nochar clear
char list _dta[]        // empty
char list ny_gdp_mktp_cd[]  // empty
```

### Files to modify

| File | Change | Lines |
|------|--------|-------|
| `wbopendata.ado` | Add `noCHAR` to syntax block | ~line 55 |
| `wbopendata.ado` | Add `_dta` char writes after country metadata, before `return add` | ~line 763 |
| `wbopendata.ado` | Pass `nochar` to `_query` calls (two locations: multi-indicator ~line 378, single-indicator ~line 538) | |
| `_query.ado` | Accept `char` option in syntax | ~line 1 |
| `_query.ado` | Add variable-level char writes after `label var` | ~line 347 |
| `_query.ado` | Add variable-level char writes in topics reshape path | ~line 391 |
| `wbopendata.sthlp` | Document `nochar` option | |
| `run_tests.do` | Add CHAR tests verifying `_dta` and variable chars | |

### Interaction with existing features

- **`nometadata`**: When `nometadata` is specified, `_query_metadata` is not called,
  so variable-level chars that depend on metadata returns (description, note, topic,
  sourcecite) will be empty. The `indicator` and `source` chars can still be set
  from `_query` returns. `_dta` chars are always set regardless of `nometadata`.
- **`nobasic`**: No interaction — `char` and country metadata are independent.
- **`latest`**: No interaction — chars are set before the latest filter is applied.
- **Topics mode**: The topics reshape path creates multiple indicator variables via
  `encode`/`reshape wide`. Variable-level chars must be set after the reshape,
  iterating over the reshaped variables. This is the most complex code path.

---

## Part IV: Recommendation

### For the paper

Add both references to the bibliography and cite them at these insertion points:

| Citation | Where in paper | Purpose |
|----------|---------------|---------|
| Drukker (2006) | Section 2.1 | Precedent for data-acquisition-as-code in Stata |
| Drukker (2006) | Section 2.4 | Part of the Stata data-access ecosystem |
| Drukker (2006) | Section 5.2 | Architectural complement: `char` + `r()` + do-file as layered metadata |
| Gould (2001)   | Section 5.4 | Foundation for assert-based testing |
| Gould (2001)   | Appendix C.1 | Authority for operational validation approach |
| Gould (2001)   | Appendix C.3 | Source of "never delete" and cumulative testing |
| Gould (2001)   | Appendix C.7 | Legitimizes CI/CD-without-CI/CD argument |

### For the code

**`char` support: implemented in v18.1 (branch `feat/char-metadata`) as default-on.**

wbopendata adopts the freduse `char` pattern (Drukker 2006) with a layered metadata
design:

1. **Do-file** = authoritative provenance record (unchanged from v18.0)
2. **`r()` returns** = ephemeral session metadata for programmatic use (unchanged)
3. **`char` characteristics** = persistent metadata embedded in the `.dta` file (new)

The three layers serve different lifecycles: the do-file is durable and human-readable,
`r()` is immediate and machine-readable, and `char` travels with the data. This
intentional redundancy makes the `.dta` file self-documenting — anyone who receives it
can inspect indicator metadata without the generating do-file.

**Design:** default-on, with `nochar` opt-out. Both `_dta`-level (session provenance)
and variable-level (per-indicator metadata) chars are set automatically.

### For testing

Adopt two patterns from Gould (2001) into the test suite:

1. Use `cscript "wbopendata test suite"` at the top of `run_tests.do`
2. Use `rcof` for tests that verify expected failures (deprecated indicators, syntax
   errors)
3. Add `char` verification tests: confirm `_dta` and variable chars are set by default
   and suppressed by `nochar`

---

## Part V: Cross-references between the papers and wbopendata

### Conceptual lineage

```
Gould (2001)               Drukker (2006)            wbopendata (2011-2026)
assert-based               freduse: data             wbopendata: data
certification              from FRED API             from WB API
    |                           |                          |
    v                           v                          v
test scripts               char metadata             layered metadata:
nested do-files            persistent on vars          do-file (provenance)
cscript/rcof               save/use survives           r() (ephemeral session)
    |                           |                        char (persistent in .dta)
    |   wbopendata draws from   |                          |
    |   Gould's testing model   |   wbopendata adopts      |
    |   (cite in paper)         |   freduse char pattern   |
    |                           |   as complementary layer |
    v                           v                          v
PAPER: cite Gould          PAPER: cite Drukker       CODE: adopt cscript/rcof
for QA/testing framework   as precedent; discuss      implement char (v18.1)
                           layered metadata design    default-on + nochar opt-out
```

### Three-layer metadata architecture

```
Layer              Lifecycle         Purpose                    Introduced
─────────────────  ────────────────  ─────────────────────────  ──────────
Do-file            Permanent         Provenance & reproduction  v1.0
r() returns        Session-ephemeral Programmatic metadata      v14.0
char (new)         Persistent in .dta Self-documenting dataset  v18.1
```

The layers are intentionally redundant. Each serves a different audience:
- The **do-file** serves the original researcher (reproduction)
- **`r()` returns** serve the running program (automation)
- **`char`** serves anyone who receives the `.dta` file (documentation)

### What each paper teaches wbopendata

| Lesson | Source | Current state | Action |
|--------|--------|--------------|--------|
| Data acquisition as one-line Stata command | Drukker | Already the core pattern | Cite Drukker as precedent |
| Persistent metadata via char[] | Drukker | Adopted as default-on in v18.1 | Implement; cite Drukker as precedent |
| assert-based automated testing | Gould | Already implemented | Cite Gould |
| Never delete tests, always add | Gould | Already followed (REG tests) | Cite Gould |
| Test expected errors with rcof | Gould | Uses cap noi + _rc check | Adopt rcof |
| cscript for clean test state | Gould | Uses clear all | Adopt cscript |
| Simultaneous code + test authoring | Gould | Already practiced | Cite Gould |
| Extreme-case testing | Gould | Partial (deprecated indicators) | Extend |
| Seed-based deterministic test data | Gould | Not applicable (live API) | N/A |
