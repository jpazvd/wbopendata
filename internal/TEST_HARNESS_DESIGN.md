# Test Harness Design: Protocol → Runner → Results

**Status:** Draft
**Date:** 23 Feb 2026
**Author:** Joao Pedro Azevedo + Claude

## Problem

`test_help_examples.do` mixes test documentation, framework plumbing, and
execution logic in one file. Adding a test requires writing 6 lines of
boilerplate (`run_test`, `cap noi { }`, `if _rc`, `test_pass`, `else`,
`test_fail`). There is no per-test timing, no structured output, and
post-hoc analysis requires a Python script to parse the raw log.

## Proposed Architecture

```
Protocol (.do file)  →  Runner (_test_harness.ado)  →  Results (frame + CSV)
 "what to test"          "how to run"                   "what happened"
```

Three concerns, three artifacts. The protocol is documentation that
happens to be executable. The runner is generic — it works with any
protocol file. The results are structured data, not log scraping.

---

## 1. Protocol File Format

A protocol file is a standard `.do` file. Test blocks live inside
`/* TEST */` comments, so the file has two modes:

- **Direct mode** (`do protocol.do`): test blocks are comments (skipped),
  only setup code runs.
- **Runner mode** (`_test_harness run "protocol.do"`): runner parses
  comment blocks, extracts test code, executes each, captures results.

### Example

```stata
*! Test Protocol: WBOPENDATA HELP FILE EXAMPLES
*! Version: 18.3.1

* --- Setup (runs in both modes) ---
clear all
set more off
local src_path "C:/GitHub/myados/wbopendata-dev/src"
adopath ++ "`src_path'/w"
adopath ++ "`src_path'/_"
cap noi wbopendata, sync
cap noi wbopendata, cleardatacache


/* TIER: TIER 1: DISCOVERY COMMANDS */

/* TEST: HELP-01 | sources | sthlp line 266 */
    qui wbopendata, sources
    assert r(n_sources) > 0
    assert r(n_indicators) > 0
/* /TEST */

/* TEST: HELP-02 | alltopics | sthlp line 277 */
    qui wbopendata, alltopics
    assert r(n_results) > 0
/* /TEST */


/* TIER: TIER 12: DATA RESPONSE CACHE WORKFLOW */

/* GROUP: EX-12 | Data cache workflow | sthlp line 1141 */

/* TEST: EX-12a | cleardatacache */
    wbopendata, cleardatacache
/* /TEST */

/* TEST: EX-12b | first download (API) */
    wbopendata, indicator(SP.POP.TOTL) clear
    assert _N > 0
    local n1 = _N
/* /TEST */

/* TEST: EX-12c | cached download */
    wbopendata, indicator(SP.POP.TOTL) clear
    assert _N == `n1'
/* /TEST */

/* /GROUP */
```

### Markers

| Marker | Purpose |
|--------|---------|
| `/* TIER: name */` | Sets current tier for subsequent tests |
| `/* TEST: ID \| label [\| description] */` | Opens a test block |
| `/* /TEST */` | Closes a test block |
| `/* GROUP: ID \| label [\| description] */` | Opens a multi-step group (shared state) |
| `/* GROUP: ID \| label \| continue */` | Opens a group in continue-on-failure mode |
| `/* /GROUP */` | Closes a group |

Fields are `|`-separated. ID is required, label is required, description
is optional.

### Adding a test

Before (current framework — 6 lines):

```stata
run_test "HELP-03" "search(GDP) (sthlp line 290)"
cap noi {
    qui wbopendata, search(GDP)
    assert r(n_results) > 0
}
if _rc == 0 test_pass
else test_fail "wbopendata, search(GDP)"
```

After (protocol format — 4 lines):

```stata
/* TEST: HELP-03 | search(GDP) | sthlp line 290 */
    qui wbopendata, search(GDP)
    assert r(n_results) > 0
/* /TEST */
```

---

## 2. Runner: `_test_harness.ado`

Location: `tests/_test_harness.ado`

### Public interface

```stata
_test_harness run "protocol.do" [, save(path) only(idlist) trace title(string)]
_test_harness report [, detail]
_test_harness close
```

### `run` behavior

1. **Initialize**: create frame `_test_results`, zero counters, record
   suite start clock.

2. **Parse protocol** line by line (`file read`):
   - Lines outside markers → accumulate as setup code.
   - `/* TIER: name */` → set current tier.
   - `/* TEST: ... */` ... `/* /TEST */` → collect as standalone test.
   - `/* GROUP: ... */` ... `/* /GROUP */` → collect group with nested
     TEST blocks.

3. **Execute setup**: write setup lines to a temp `.do`, execute it.

4. **Execute tests** in protocol order:
   - **Standalone TEST**: write code to temp `.do` →
     `cap noi do _temp` → record PASS/FAIL + timing.
   - **GROUP (fail-fast)**: assemble all steps into one temp `.do` with
     `cap noi { }` per step and step markers → first failure stops
     group, remaining steps recorded as SKIP.
   - **GROUP (continue)**: same but all steps execute regardless of
     prior failures.

5. **Failure diagnostics**: on any FAIL, save the temp `.do` as
   `_fail/<test_id>.do`. With `trace` option, re-run with
   `set trace on` and save `_fail/<test_id>.log`.

6. **Report + save**: produce formatted summary, optionally export
   frame to CSV (append mode) and `.dta`.

### Frame schema: `_test_results`

| Column | Type | Description |
|--------|------|-------------|
| `seq` | int | Insertion order |
| `test_id` | str32 | "HELP-01", "EX-12b" |
| `group_id` | str32 | Parent group (blank for standalone) |
| `tier` | str80 | "TIER 1: DISCOVERY COMMANDS" |
| `label` | str120 | "sources" |
| `description` | str244 | "sthlp line 266" |
| `status` | str10 | "PASS", "FAIL", "SKIP" |
| `message` | str244 | Failure reason (blank for PASS) |
| `duration` | double | Seconds |
| `start_time` | str8 | "HH:MM:SS" |
| `end_time` | str8 | "HH:MM:SS" |

### CSV persistence

On `save(path)`:
- Add `run_id` column (ISO timestamp).
- If `path.csv` exists → append rows. If new → write header + rows.
- Save `path.dta` (overwrite, latest run only).

Git-friendly: CSV is text-based, diffable, readable on GitHub.

### Report output

```
==============================================================================
TEST REPORT: WBOPENDATA HELP FILE EXAMPLES         23 Feb 2026  14:52:41
==============================================================================

TIER 1: DISCOVERY COMMANDS                        24 tests | 24 pass | 4.2s
------------------------------------------------------------------------------
  #  ID          Status   Time  Label
  1  HELP-01     PASS     0.4s  sources
  2  HELP-02     PASS     0.3s  alltopics

TIER 12: DATA RESPONSE CACHE                       7 tests |  7 pass | 28.1s
------------------------------------------------------------------------------
  #  ID          Status   Time  Label
 65  EX-12a      PASS     0.1s  cleardatacache          [GROUP: EX-12]
 66  EX-12b      PASS     8.2s  first download (API)    [GROUP: EX-12]

==============================================================================
SUMMARY
==============================================================================
  Tests Run:     71
  Passed:        71  (100.0%)
  Failed:         0
  Skipped:        0
  Duration:       3m 42s

  Slowest:
    1. HELP-29   18.2s  country(chn)
    2. HELP-30   15.8s  topics(2)

  ALL TESTS PASSED
==============================================================================
```

### Internal structure

```stata
program define _test_harness, rclass
    version 16.0
    gettoken subcmd 0 : 0
    if      "`subcmd'" == "run"    _th_run `0'
    else if "`subcmd'" == "report" _th_report `0'
    else if "`subcmd'" == "close"  _th_close
    else error 198
end

program define _th_run       /* parse + execute protocol */
program define _th_parse     /* file read → structured test list */
program define _th_exec_test /* run one standalone test */
program define _th_exec_grp  /* run one group */
program define _th_record    /* frame post one result row */
program define _th_report    /* formatted output from frame */
program define _th_save      /* CSV append + dta save */
program define _th_close     /* drop frame, clear globals */
```

---

## 3. Devil's Advocate: Risks and Weaknesses

### 3.1 Code-as-text is the single biggest risk

The runner reads Stata code from comment blocks via `file read`, writes
it to temp files, and executes with `do`. This pipeline will break on:

- **Compound quotes**: `` `"`macro'"' `` — the file-read/file-write
  cycle can corrupt compound quoting if any line contains unbalanced
  backticks or quotes. Stata's macro expansion is notoriously fragile
  when code passes through string intermediaries.

- **Line continuations**: `///` at the end of a line means "continue on
  next line" in Stata. The parser must preserve these correctly or the
  temp `.do` file will have broken commands.

- **Dollar-sign globals**: `$varname` in test code will expand during
  the `file write` step unless carefully escaped. The runner must use
  compound quotes for all `file write` calls.

- **Special characters**: `"`, `'`, `` ` ``, `$`, `\` all have special
  meaning in Stata macros. Test code containing these (common in
  assertions, string comparisons, file paths) may corrupt during the
  text pipeline.

**Mitigation**: Use `strL` (long string) variables or `fileread()`/
`filewrite()` to handle raw text without macro expansion. Test the
pipeline with deliberately pathological test code during development.

**Honest assessment**: This will require careful implementation and will
likely produce subtle bugs that only surface with specific test content.
Budget time for debugging the text pipeline itself.

### 3.2 Debugging is genuinely harder

When a test fails, the stack trace points to `_tmp_test_HELP01.do:3`,
not `protocol.do:47`. The developer must manually map back to the
protocol file.

The mini-log mitigation (saving `_fail/<id>.do` and `_fail/<id>.log`)
helps but adds complexity. And re-running a failed test with `set trace on`
means running it twice — the second run may not reproduce the failure
if it was state-dependent.

**Honest assessment**: This is a real usability regression compared to
the current inline approach where errors point directly to the source.
Acceptable for a CI-style runner where you rarely debug interactively,
but annoying for development-time testing.

### 3.3 The "dual mode" provides limited value

In direct mode, `do protocol.do` runs setup and skips test blocks
(they're comments). What does this give you?

- Setup verification? You can do that with a 3-line script.
- Reading the protocol? You can read it in any editor.
- Running a quick sanity check? The tests ARE the sanity check, and
  they don't run in direct mode.

The dual mode is architecturally elegant but practically useless.
Nobody will `do protocol.do` for its own sake. The value is entirely
in runner mode.

**Counter-argument**: The value is that the protocol file IS valid Stata.
It won't crash if someone runs it by accident. It's a safe no-op. This
matters for discoverability — someone browsing the repo can `do` the
file without knowing about the runner, and nothing bad happens.

### 3.4 GROUP mechanics add significant complexity

The fail-fast vs. continue distinction, step-result injection, parsing
`_TH_STEP_RESULT` markers from temp logs — this is essentially building
a mini IPC protocol within Stata. Estimated: 100-150 lines of code
just for GROUP handling, with multiple edge cases:

- What if a step produces output that looks like a step marker?
- What if a step calls `exit` explicitly?
- What if a step modifies globals that the runner relies on?

**Alternative**: Keep groups as single tests (no per-step breakdown).
EX-12 is one test with 7 internal steps. If it fails, the mini-log
shows which step. Simpler, fewer edge cases, 90% of the value.

### 3.5 Over-engineering for one test suite (YAGNI)

The user has ONE test suite today. The "generic reusable" goal assumes
future test suites that may never materialize. A simpler approach
that works for wbopendata now is more valuable than a generic framework
that works for hypothetical future projects.

**Estimated implementation effort**:

| Component | Lines of Stata | Difficulty |
|-----------|---------------|------------|
| Protocol parser (`_th_parse`) | ~120 | High (text handling) |
| Test executor (`_th_exec_test`) | ~40 | Medium |
| Group executor (`_th_exec_grp`) | ~120 | High (step injection) |
| Frame + CSV (`_th_record`, `_th_save`) | ~60 | Low |
| Report (`_th_report`) | ~80 | Medium |
| Failure diagnostics | ~40 | Medium |
| Subcommand dispatch + globals | ~30 | Low |
| **Total** | **~490** | |

490 lines of Stata to replace 40 lines of inline programs.

### 3.6 The 80/20 alternative

A simpler approach that captures 80% of the value with 20% the effort:

1. Keep the current harness-call approach (`begin`/`pass`/`fail`/`skip`)
2. Add `frame post` for structured capture + per-test `clock()` timing
3. Add `report` subcommand for formatted output
4. Add `save` for CSV export

Estimated: ~150 lines. No text parsing, no temp file generation, no
code-as-text fragility. Same frame, same CSV, same report. The only
thing you lose is the protocol/runner separation — tests still have
6 lines of boilerplate each instead of 4.

**The 2-line savings per test × 71 tests = 142 lines saved in the
protocol file, at the cost of 340 additional lines of framework code
and a fragile text pipeline.** The math doesn't favor the protocol
approach for a single test suite.

---

## 4. Recommendation

### If building for one project: use the 80/20 approach (Section 3.6)

The harness-call pattern with frame capture is simpler, more debuggable,
and sufficient for wbopendata. It can always be upgraded to the full
protocol/runner architecture later if a second test suite demands it.

### If building a reusable tool (StataCI): use the full architecture

The protocol/runner separation pays off when you have 3+ test suites
across different projects. The investment in the text pipeline is
justified by the reduced per-test boilerplate and the clean separation
of documentation from execution.

### Suggested phased approach

**Phase 1** (now): Build the 80/20 harness — `begin`/`pass`/`fail` +
frame + CSV + report. Wire into `test_help_examples.do`. Ship it.

**Phase 2** (when second test suite needed): Extract the protocol parser.
Convert `test_help_examples.do` to protocol format. The harness
internals (frame, CSV, report) carry over unchanged.

**Phase 3** (if GROUP complexity justified): Add GROUP support.
Until then, multi-step tests stay as single test blocks.

This way each phase delivers value immediately, and the full
architecture emerges from real need rather than speculation.

---

## 5. Decision Required

Which path to take:

- **A. Full protocol/runner now** — higher upfront cost, future-proof
- **B. 80/20 harness now, protocol later** — lower risk, ships faster
- **C. Something else** — user's call

---

## 6. Review Through Gould (2001)

**Reference:** Gould, W. 2001. "Statistical software certification."
*The Stata Journal* 1(1): 29–50.

This section evaluates the proposed test harness design against the
principles and practices described in Gould's foundational paper on how
StataCorp certifies Stata itself. The paper is not a style guide — it is
a report on what actually works at scale (thousands of test scripts,
decades of accumulation). Where the proposed design aligns with Gould,
that's encouraging. Where it diverges, we need to understand why and
whether the divergence is justified.

### 6.1 Gould's Key Principles

**P1. Test scripts are plain do-files with `assert`.**

> "The do-file is the test script. It contains Stata commands — the same
> commands a user would type — followed by assert statements that verify
> the results." (p. 29–30)

No special syntax. No markers. No comment conventions. The test IS the
code. The assertion IS the verification. If the do-file runs to
completion without `r(9)` ("assertion is false"), every test passed.

**P2. The framework is intentionally minimal.**

`cscript` — StataCorp's test preamble — does almost nothing: clears
memory, resets settings, prints a banner. Gould explicitly notes it is
"not much of a program" (p. 37). The value is in the test scripts
themselves, not in the machinery around them.

**P3. Hierarchical organization is just nested `do` calls.**

`testall.do` calls subdirectory `test.do` files, which call individual
test scripts. No test registry, no discovery, no configuration files.
The hierarchy is plain do-file calls all the way down (p. 31).

**P4. Never delete, always add.**

> "We never remove a test from the certification suite... once a test
> enters the suite, it stays forever." (p. 38)

Tests accumulate. The suite grows monotonically. Old tests catch
regressions that new tests wouldn't think to check.

**P5. Inelegance is acceptable.**

> "It is not important that a test script look pretty... What is
> important is that the test be there." (p. 38)

Boilerplate, repetition, and copy-paste are fine. Tests are not
production code. Readability matters less than coverage.

**P6. Log comparison is secondary.**

StataCorp compares logs between versions (`compare_logs.do`), but Gould
notes: "problems are seldom uncovered at this step" (p. 34). The real
work is done by `assert` during execution. Log comparison catches
cosmetic changes and unexpected output, not logical errors.

**P7. Simultaneous authoring.**

> "I always have three windows open: the editor with the code, Stata
> running the code, and the editor with the test." (p. 44–45)

Tests are written alongside the code, not after. The test is part of the
development workflow, not a separate QA phase.

**P8. Test extreme cases and error cases.**

Gould introduces `rcof` to assert that a command FAILS with a specific
return code (p. 41–43). Testing that invalid inputs produce correct
errors is as important as testing that valid inputs produce correct
results.

**P9. The suite evolves organically.**

> "The overall design simply evolves." (p. 32)

There is no grand architecture session. Tests are added one at a time,
as bugs are found or features are written. The structure emerges from
practice.

**P10. False precision is a trap.**

Use `reldif()` with appropriate tolerances rather than exact equality
for numerical results (p. 39–41). Floating-point results vary across
platforms; tests must account for this.

### 6.2 How Our Current Framework Aligns with Gould

The existing `test_help_examples.do` is **remarkably close** to Gould's
model:

| Gould Principle | Current Framework | Status |
|----------------|-------------------|--------|
| P1. Plain do-file + assert | `cap noi { ... assert ... }` | ✓ Aligned |
| P2. Minimal framework | 40 lines: `run_test`, `pass`, `fail`, `skip` | ✓ Aligned |
| P3. Nested do-file hierarchy | Single file (flat) | Partial — could split by tier |
| P4. Never delete | Tests accumulate, never removed | ✓ Aligned |
| P5. Inelegance OK | 6-line boilerplate per test | ✓ Aligned (even if annoying) |
| P6. Log comparison secondary | Python `analyze_test_log.py` exists | ✓ Aligned |
| P7. Simultaneous authoring | Tests written alongside sthlp examples | ✓ Aligned |
| P8. Error cases | Not yet — only success-path tests | ✗ Gap |
| P9. Organic evolution | Suite grew from 0 → 71 incrementally | ✓ Aligned |
| P10. False precision | Not applicable (no numerical assertions) | N/A |

The current framework scores 7/9 on alignment. The main gap is error-case
testing (P8) — we test that valid commands succeed but don't test that
invalid commands fail with the expected return code.

### 6.3 Where the Proposed Design Diverges from Gould

**Divergence 1: Framework complexity (vs. P2)**

The proposed `_test_harness.ado` is ~490 lines with 8 internal programs,
frame management, CSV persistence, formatted reporting, failure
diagnostics, and GROUP mechanics. This is the opposite of `cscript`'s
intentional minimalism.

Gould's implicit argument: the framework should be so simple that it
never itself becomes a source of bugs. At 490 lines with text parsing,
temp file generation, and IPC-style step markers, the harness becomes a
system that needs its own test suite.

**Divergence 2: Protocol/runner separation (vs. P1)**

Gould says the test IS the do-file. The proposed design puts tests
inside `/* */` comments and requires a runner to extract and execute
them. This breaks the most fundamental principle: a test script should
be runnable by `do filename.do`.

In Gould's model, you type `do test_regress.do` and it either runs
clean or hits `r(9)`. In our proposed model, `do protocol.do` runs
setup and skips all tests — you need to know about `_test_harness run`
to actually execute anything.

**Divergence 3: Structured reporting (vs. P6)**

The proposed frame + CSV + formatted report solves a problem Gould
considers secondary. In his model: if the script runs to completion,
everything passed. If it stops, the error message tells you what failed.
You don't need a summary table, per-test timing, or a "slowest tests"
ranking.

The counter-argument is that Gould's context (StataCorp with thousands
of scripts, automated comparison infrastructure) differs from ours
(one test suite, no CI pipeline, no log comparison tooling). Structured
reporting may provide value that StataCorp gets from other mechanisms.

**Divergence 4: Converting existing tests (vs. P4)**

Migrating `test_help_examples.do` to protocol format means rewriting
71 test blocks. This is a mass edit that risks introducing bugs in
working test code. Gould would say: the current tests work. Leave them.
Add new tests in whatever format you like, but don't touch what's
passing.

**Divergence 5: Grand architecture up front (vs. P9)**

This design document itself — with its three-layer architecture, marker
syntax, GROUP semantics, failure modes, and phased implementation
plan — is the kind of upfront design that Gould's approach doesn't do.
The StataCorp suite evolved organically over years. Nobody sat down and
designed `cscript` on paper first.

### 6.4 What Gould Would Likely Recommend

Based on the paper, Gould's advice for our situation would probably be:

1. **Keep `test_help_examples.do` as-is.** It works. It follows the
   model. Don't rewrite working tests.

2. **Add `rcof`-style error testing.** The biggest gap isn't reporting
   — it's that we only test the happy path. Add tests that verify
   invalid indicator codes return errors, that conflicting options are
   caught, etc.

3. **Split by tier into separate files.** Instead of one 1500-line file,
   have `test_tier01_discovery.do`, `test_tier02_deprecated.do`, etc.
   A top-level `test_all.do` calls them sequentially. This follows P3
   (hierarchical organization) without introducing any framework.

4. **If you want structured results, add them to the existing pattern.**
   A 30-line `frame post` addition inside `test_pass`/`test_fail` gives
   you the results frame. A 40-line `report` program reads it. No
   parser, no protocol, no runner. Total cost: ~70 lines. This is the
   80/20 approach from Section 3.6.

5. **Save the protocol/runner idea for later.** If you build 5+ test
   suites and the boilerplate genuinely hurts, extract the pattern then.
   "You ain't gonna need it" is validated by Gould's observation that
   StataCorp's framework stayed minimal for 15+ years.

### 6.5 The Honest Tension

Gould's model assumes a context where:

- Tests run locally in a developer's Stata session
- Developers inspect failures interactively
- The certification suite is run periodically, not on every commit
- "The script ran clean" is a sufficient success signal
- Log comparison provides a secondary safety net

Our context differs in some ways:

- We want CI-style automation (run tests, get a report, move on)
- We want historical tracking (did test X get slower over time?)
- We have one developer, not a team, so structured results help
  compensate for less institutional memory
- We don't have StataCorp's `compare_logs.do` infrastructure

These differences may justify SOME additional reporting. But they don't
justify a 490-line framework with a text parser. The question is how
much reporting infrastructure is proportional to our actual needs.

### 6.6 Revised Recommendation (Gould-Informed)

The phased recommendation from Section 4 is strengthened by Gould:

**Phase 1** becomes even simpler — don't build a separate harness at
all. Enhance `test_pass`/`test_fail` with `frame post` (30 lines).
Add a `test_report` program (40 lines). Add `test_save` for CSV
(30 lines). Total: ~100 lines added to the existing 40-line framework.
This is Gould-compatible: the test file is still a plain do-file with
assert statements, plus a thin results layer.

**Phase 2** (split by tier) replaces the protocol/runner separation.
Extract tier blocks into separate .do files. Write `test_all.do` that
calls them. This follows Gould's P3 directly and gives you modularity
without a parser.

**Phase 3** (protocol/runner) is deferred indefinitely unless a second
project with 50+ tests materializes. If it does, the protocol format
and runner design in Sections 1–2 of this document remain available as
a blueprint.

**The most Gould-aligned next step:** add error-case testing (P8).
This has higher marginal value than any reporting improvement.

---

## 7. Decision Required (Revised)

In light of both the devil's advocate analysis (Section 3) and the
Gould review (Section 6):

- **A. Full protocol/runner now** — diverges significantly from Gould;
  high risk of over-engineering
- **B. 80/20 frame capture (enhanced)** — add `frame post` + report +
  CSV to existing framework (~100 lines); Gould-compatible
- **C. Gould-minimal** — split by tier, add error tests, no reporting
  infrastructure beyond what `assert` already provides
- **D. Something else** — user's call
