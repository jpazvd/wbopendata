# Paper Alignment Plan — v18.5.0

**Target document:** `paper/azevedo-2026-wbopendata.tex` (working draft, 1755 lines)
**Codebase version:** v18.5.0 (2026-04-21)
**Prepared:** 2026-04-21

Mapping each section of the Stata Journal submission against the current codebase.

**Legend:** 🟢 no change · 🟡 minor (1–2 lines) · 🟠 moderate (paragraph/table row) · 🔴 substantive (new content)

---

## Current state

The working draft is **two versions behind** the code:

| Area | Paper says | Reality |
|---|---|---|
| Abstract headline | "as of version~18.0" | v18.5.0 (today) |
| Version roadmap (L.277) | stops at v18.3 | v18.4 & v18.5 missing |
| Architecture (L.784) | "34 ado files, `_wbopendata_` prefix" | 40+ ado files, `__wbod_` namespace |
| Search option list (L.448–492) | ends at `info()` | missing `page(#)` + pagination nav |
| Stored results (L.572–578) | search returns 5 `r()` | missing `r(page)`, `r(n_pages)` |
| Search log snippet | "Showing 10 of 145 results. Use limit(#) to see more." | new v18.5 output has `[Prev] Page X of Y [Next]` nav |

The v18.4.0 submission copy already contains the v18.4 updates — those need to be **back-ported** into the working draft, plus new v18.5.0 content added on top.

---

## 1. Front matter (L.1–48)

| Element | Lines | Status | Edit |
|---|---|---|---|
| Title block | 32–37 | 🟢 | unchanged |
| Abstract phrasing "as of version~18.0" | 45 | 🟡 | decision point: leave as-is (thesis is v18.0-centric), or append ", with paginated search added in v18.5" |
| Keywords | 47 | 🟢 | unchanged |

---

## 2. §1 Introduction (L.52–103)

| Element | Status | Edit |
|---|---|---|
| Entire section | 🟢 | **no change**. Thesis about data-provenance-as-code is stable; pagination is downstream UX. |

---

## 3. §2 Design principles and scope (L.105–251)

| Element | Lines | Status | Edit |
|---|---|---|---|
| 2.1 Data acquisition as code | 114–142 | 🟢 | — |
| 2.2 Backward compatibility | 143–162 | 🟢 | `page()` is additive; default behavior preserved (≤30 still single-page) |
| 2.3 Domain-specific syntax | 163–179 | 🟢 | "pagination logic" at L.166 refers to **API-level** pagination — unchanged, don't confuse with new UI pagination |
| 2.4 Scope, boundaries, diffusion | 180–251 | 🟢 | — |

---

## 4. §3 The `wbopendata` command (L.253–591)

### 4.1 Preamble paragraph (L.253–278)

| Element | Lines | Status | Edit |
|---|---|---|---|
| Coverage table `tab:coverage` | 258–275 | 🟢 | counts unchanged (29k indicators, 71 sources, 21 topics) |
| **Version roadmap paragraph** | **277** | 🔴 | **append two clauses**: v18.4 (namespace refactor per TSJ feedback) + v18.5 (paginated discovery results). Text for v18.4 already exists in the v18.4.0 submission copy; add a new v18.5 clause. |

### 4.2 Syntax subsection (L.279–447)

| Element | Lines | Status | Edit |
|---|---|---|---|
| Data selection | 291–303 | 🟢 | — |
| Time/language | 305–323 | 🟢 | — |
| Output format | 325–367 | 🟢 | — |
| Metadata management (v18.0+) | 368–410 | 🟢 | — |
| Data response cache (v18.2+) | 411–446 | 🟢 | — |

### 4.3 Discovery commands (v18.0) (L.448–492) — **primary editing target**

| Element | Lines | Status | Edit |
|---|---|---|---|
| Intro paragraph | 450–452 | 🟢 | — |
| `sources` / `allsources` / `alltopics` | 454–462 | 🟢 | — |
| `search()` / `searchsource()` / `searchtopic()` / `searchfield()` / `exact` / `detail` | 465–483 | 🟢 | — |
| **`limit(#)` description** | **486** | 🟡 | reword: "sets the maximum number of results to display (default 20)" → "**per-page record count (default 20)**" |
| **New `page(#)` `\hangpara`** | **insert after 486** | 🔴 | add 2–3 line paragraph: integer default 1; clickable `[Prev]`/`[Next]`/page-number links render below the table when matches exceed one page; result sets ≤30 matches stay on a single page |
| `info()` | 489 | 🟢 | — |
| Closing thesis paragraph | 491–492 | 🟡 | optionally add one sentence: "Pagination makes deep catalog browsing tractable without abandoning the auditable, scripted selection model." |

### 4.4 Stored results (L.493–591)

| Element | Lines | Status | Edit |
|---|---|---|---|
| `tab:stored` (core command) | 509–547 | 🟢 | — |
| **`tab:stored-discovery`** | **553–591** | 🟠 | under the `search(pattern)` block (L.572–578), add two rows: `r(page)` (scalar, current page) and `r(n_pages)` (scalar, total pages) |

---

## 5. §4 Reproducible analytical workflows (L.595–736)

| Element | Lines | Status | Edit |
|---|---|---|---|
| 4.1–4.3 (scripted acquisition, visualization, pipelines) | 607–698 | 🟢 | — |
| 4.4 Indicator discovery as auditable selection | 699–736 | 🟢 | — (narrative is version-agnostic; don't force `page()` into an already-crowded section) |

---

## 6. §5 Technical implementation and reliability (L.738–1047)

| Element | Lines | Status | Edit |
|---|---|---|---|
| 5.1 Installation | 746–768 | 🟢 | — |
| **5.2 Architecture** | **784–787** | 🔴 | **back-port from v18.4.0 submission**: "34 ado files, prefixed `_wbopendata_`" → "40 ado files … `__wbod_` namespace (v18.4 refactor per SJ naming conventions)". File count may have ticked to 41 with the new `__wbod_search_pagenav.ado` — verify. |
| 5.3 Country attributes | 822–854 | 🟢 | v18.4.1 restored these — now works as documented |
| 5.4 Testing and error handling | 855–936 | 🟡 | — |
| **`tab:test-coverage`** | **897–932** | 🟡 | if test count has drifted from **163**, refresh the L1/L2 totals. Requires running `tests/_run_tests.do` to confirm. |
| 5.5–5.8 Metadata / YAML / sync / cache subsections | 939–1046 | 🟢 | — |

---

## 7. §6 Discussion (L.1049–1140)

| Element | Status | Edit |
|---|---|---|
| All four subsections | 🟢 | **no change**. Pagination does not affect reproducibility/AI arguments. |

---

## 8. §7 Conclusion (L.1142–1217)

| Status | Edit |
|---|---|
| 🟢 | **no change** |

---

## 9. Appendix A — Extended examples (L.1219–1381)

| Status | Edit |
|---|---|
| 🟢 | **no change**. All examples cover data retrieval and plotting, not discovery. |

---

## 10. Appendix B — Diagnostics and verbatim outputs (L.1383–1429)

| Element | Lines | Log file | Status | Edit |
|---|---|---|---|---|
| B.1–B.3 missing / deprecated / sync preview | 1385–1397 | 3 files | 🟢 | — |
| **B.4 Discovery: Available sources** | 1400–1403 | `ex_discovery_sources.log.tex` | 🟡 | verify the SMCL output still matches v18.5 |
| **B.5 Discovery: Indicator search** | **1405–1408** | `ex_discovery_search.log.tex` | 🔴 | **regenerate** — current snippet shows the old footer "Showing 10 of 145 results. Use limit(#) to see more." New v18.5 output has `(page 1 of 15 — showing 1-10 of 145)` header and `[Prev] Page X of Y [Next]` nav |
| B.6 Discovery: Indicator metadata | 1410–1413 | `ex_discovery_info.log.tex` | 🟢 | — |
| B.7 Discovery: Topic categories | 1415–1418 | `ex_discovery_alltopics.log.tex` | 🟢 | — |
| B.8–B.9 Sync detail / checkupdate | 1420–1427 | 2 files | 🟢 | — |

**Optional new entry:** B.5b (after B.5) showing `wbopendata, searchtopic(11) limit(10) page(2)` to showcase a second page. Genuinely new content — defer decision.

---

## 11. Appendix C — QA, testing, operational validation (L.1431–1755)

| Status | Edit |
|---|---|
| 🟢 | **no change** unless test count drifts (see §5 above). |

---

## 12. Files outside the `.tex` main body

| File | Status | Edit |
|---|---|---|
| `paper/README.md` | 🟡 | line 9 describes working draft as "v18.1 draft" → update to "v18.5 draft" |
| `paper/wbopendata.bib` | 🟢 | no change |
| `paper/sjlogs/ex_discovery_search.log.tex` | 🔴 | regenerate against v18.5.0 (requires Stata) |
| `paper/scripts/generate_v18_logs.do` | 🟡 | the `search(poverty) searchtopic(11) limit(10)` example is fine; consider adding a `page(2)` variant if we want a second snippet |
| `paper/wbopendata_sj_submission-v18.4.0/` | 🟢 | **leave frozen** — archival submission artifact |

---

## 13. Volume of change

- **Substantive new content (🔴)**: 3 spots — roadmap paragraph L.277, new `page()` hangpara after L.486, architecture back-port L.784–787
- **Moderate (🟠)**: 1 spot — `tab:stored-discovery` new rows
- **Minor (🟡)**: 5–6 spots — `limit()` rewording, abstract nudge (optional), `paper/README.md`, test-count verification, log-snippet regeneration trigger
- **No change (🟢)**: Introduction, Design principles, Workflows, Discussion, Conclusion, Appendix A, Appendix C, plus most of Appendix B

Roughly **~30 lines of net-new LaTeX** across the whole draft. No structural reorganization.

---

## 14. Commit decomposition (if approved)

1. `docs(paper): back-port v18.4 namespace refactor from submission copy` — L.277, L.784–787
2. `docs(paper): document v18.5.0 page() option and pagination` — L.486, insert after 486, L.572–578 (table rows)
3. `docs(paper): refresh README and stated version` — `paper/README.md`
4. *(Gated on Stata)* `docs(paper): regenerate ex_discovery_search.log.tex for v18.5 output`

---

## 15. Open questions

1. **Abstract (L.45):** leave as "as of v18.0", or append an acknowledgement of v18.5?
2. **Architecture paragraph (L.784):** file count — 40 non-helper files + the new `__wbod_search_pagenav.ado` = 41. Report 40 or re-audit?
3. **Test count (163):** run `tests/_run_tests.do` to confirm it still stands? (Requires Stata; not possible in this environment.)
4. **Log snippet regeneration:** regenerate locally yourself, or hand-craft an updated `.log.tex` deterministically from the display code?
5. **New appendix B.5b showing `page(2)`:** include or skip?
6. **Framing:** should the working draft be labeled "v18.5 working draft" throughout, or remain a "v18.0 discovery era" paper with v18.5 only as a footnote?

---

## Related documents

- `CHANGELOG.md` — already contains v18.5.0 entry
- `RELEASE_NOTES.md` — already contains v18.5.0 section
- `src/w/wbopendata_whatsnew.sthlp` — already contains v18.5.0 marker
- `paper/wbopendata_sj_submission-v18.4.0/` — frozen submission reference
