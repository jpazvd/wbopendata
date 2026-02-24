# wbopendata Options Coverage Matrix

Cross-reference of all `.ado` syntax options against documentation in the
help file (`wbopendata.sthlp`) and the Stata Journal paper
(`azevedo-2026-wbopendata.tex`).

Last updated: 2026-02-23 (v18.3.1)

---

## Parameters

| .ado option | sthlp synopsis | sthlp detail | Paper | Category |
|---|---|---|---|---|
| `LANGUAGE(string)` | line 40 | line 193 | sec 3 (line 320) | user-facing |
| `COUNTRY(string)` | line 24 | line 155 | sec 3 (line 300) | user-facing |
| `TOPICS(string)` | line 26 | line 158 | sec 3 (line 303) | user-facing |
| `INDICATORs(string)` | line 28 | line 163 | sec 3 (line 296) | user-facing |
| `YEAR(string)` | line 37 | line 190 | sec 3 (line 308) | user-facing |
| `DATE(string)` | line 38 | line 198 | sec 3 (line 311) | user-facing |
| `SOURCE(string)` | line 39 | line 201 | sec 3 (line 315) | user-facing |

## Core Data Options

| .ado option | sthlp synopsis | sthlp detail | Paper | Category |
|---|---|---|---|---|
| `PROJECTION` | line 68 | line 231 | sec 3 (line 323) | user-facing |
| `LONG` | line 33 | line 173 | sec 3 (line 328) | user-facing |
| `CLEAR` | line 34 | line 177 | sec 3 (line 331) | user-facing |
| `LATEST` | line 35 | line 179 | sec 3 (line 334) | user-facing |
| `NOMETADATA` | line 36 | line 187 | sec 3 (line 340) | user-facing |
| `DESCRIBE` | line 69 | line 67 (synopsis) | sec 3 (line 337) | user-facing |
| `noCHAR` | line 44 | line 204+ | sec 3 (line 343) | user-facing |

## Country Attributes

| .ado option | sthlp synopsis | sthlp detail | Paper | Category |
|---|---|---|---|---|
| `FULL` | line 41 | line 199 | sec 3 (line 356) | user-facing |
| `noBASIC` | line 43 | line 203 | sec 3 (line 353) | user-facing |
| `ISO` | line 45 | — (grouping) | sec 3 (line 359) | user-facing |
| `GEO` | line 46 | — (grouping) | sec 3 (line 363) | user-facing |
| `capital` | line 47 | — (grouping) | sec 3 (line 363) | user-facing |
| `latitude` | line 48 | — (grouping) | sec 3 (line 363) | user-facing |
| `longitude` | line 49 | — (grouping) | sec 3 (line 363) | user-facing |
| `REGIONS` | line 50 | — (grouping) | sec 3 (line 359) | user-facing |
| `ADMINR` | line 51 | — (grouping) | sec 3 (line 359) | user-facing |
| `INCOME` | line 52 | — (grouping) | sec 3 (line 359) | user-facing |
| `LENDING` | line 53 | — (grouping) | sec 3 (line 359) | user-facing |
| `MATCH(string)` | line 67 | line 65 (synopsis) | sec 3 (line 366) | user-facing |

### Individual attribute sub-options (covered by grouping options above)

| .ado option | sthlp | Paper | Category |
|---|---|---|---|
| `COUNTRYCODE_ISO2` | — (`iso`) | — | internal granular |
| `REGION` | — (`regions`) | — | internal granular |
| `REGION_ISO2` | — (`regions`) | — | internal granular |
| `REGIONNAME` | — (`regions`) | — | internal granular |
| `ADMINREGION` | — (`adminr`) | — | internal granular |
| `ADMINREGION_ISO2` | — (`adminr`) | — | internal granular |
| `ADMINREGIONNAME` | — (`adminr`) | — | internal granular |
| `INCOMELEVEL` | — (`income`) | — | internal granular |
| `INCOMELEVEL_ISO2` | — (`income`) | — | internal granular |
| `INCOMELEVELNAME` | — (`income`) | — | internal granular |
| `LENDINGTYPE` | — (`lending`) | — | internal granular |
| `LENDINGTYPE_ISO2` | — (`lending`) | — | internal granular |
| `LENDINGTYPENAME` | — (`lending`) | — | internal granular |
| `countryname` | — (`basic`/`full`) | — | internal granular |

## Sync & Cache

| .ado option | sthlp synopsis | sthlp detail | Paper | Category |
|---|---|---|---|---|
| `SYNC` | line 54 | line 275+ | sec 3 (line 373) | user-facing |
| `REPLACE` | line 57 (as `sync replace`) | line 283 | sec 3 (line 388) | user-facing (modifier) |
| `FORCE` | line 56 (as `sync force`) | line 279 | sec 3 (line 382/393) | user-facing (modifier) |
| `DETAIL` | line 55 (as `sync detail`) | line 275 | sec 3 (line 378) | user-facing (modifier) |
| `CHECKUPDATE` | line 59 | line 298 | sec 3 (line 399) | user-facing |
| `CLEARCACHE` | line 62 | line 302 | sec 3 (line 408) | user-facing |
| `CACHEINFO` | line 66 | line 300 | sec 3 (line 404) | user-facing |
| `NOCACHE` | line 60 | line 322 | sec 3 (line ~414) | user-facing |
| `CACHEDAYS(integer 7)` | line 61 | line 326 | sec 3 (line ~419) | user-facing |
| `CLEARDATACACHE` | line 63 | line 305 | sec 3 (line ~424) | user-facing |
| `RESETDATACACHE` | line 64 | line 331 | sec 3 (line ~428) | user-facing |
| `VERBOSE` | line 65 | line 338 | sec 3 (line ~433) | user-facing |

## Discovery Commands

| .ado option | sthlp synopsis | sthlp detail | Paper | Category |
|---|---|---|---|---|
| `SOURCES` | line 77 | line 372 | sec 3.2 (line 429) | user-facing |
| `ALLSOURCES` | line 78 | line 377 | sec 3.2 (line ~458) | user-facing |
| `ALLTOPICS` | line 79 | line 383 | sec 3.2 (line 432) | user-facing |
| `SEARCH(string)` | line 80 | line 394 | sec 3.2 (line 435) | user-facing |
| `LIMIT(string)` | line 86 | line 469 | sec 3.2 (line 456) | user-facing |
| `SEARCHSOURCE(string)` | line 81 | line 451 | sec 3.2 (line 438) | user-facing |
| `SEARCHTOPIC(string)` | line 82 | line 454 | sec 3.2 (line 441) | user-facing |
| `SEARCHFIELD(string)` | line 83 | line 457 | sec 3.2 (line 444) | user-facing |
| `EXACT` | line 84 | line 463 | sec 3.2 (line 450) | user-facing |
| `INFO(string)` | line 87 | line 472 | sec 3.2 (line 459) | user-facing |

## Graph Metadata

| .ado option | sthlp synopsis | sthlp detail | Paper | Category |
|---|---|---|---|---|
| `LINEWRAP(string)` | line 70 | line 236+ | sec 3 (line 414) | user-facing |
| `MAXLENGTH(string)` | line 71 | line 236+ | sec 3 (line 417) | user-facing |
| `LINEWRAPFORMAT(string)` | line 72 | line 236+ | sec 3 (line 420) | user-facing |

## Deprecated Options

| .ado option | sthlp synopsis | sthlp deprecated | Paper | Category |
|---|---|---|---|---|
| `UPDATE` | — | line 899 | — | deprecated |
| `QUERY` | — | line 899 | — | deprecated |
| `CHECK` | — | line 901 | — | deprecated |
| `METADATAOFFLINE` | — | line 904 | sec 5 (line 960) | deprecated |
| `SYNCFORCE` | — | line 908 | sec 5 (line 959) | deprecated |
| `SYNCPREVIEW` | — | line 909 | sec 5 (line 959) | deprecated |
| `SYNCDRYRUN` | — | line 910 | sec 5 (line 959) | deprecated |

## Internal / Advanced Options (intentionally undocumented)

| .ado option | sthlp | Paper | Notes |
|---|---|---|---|
| `NOPRESERVE` | — | — | Suppresses preserve/restore |
| `PRESERVEOUT` | — | — | Preserves output dataset |
| `COUNTRYMETADATA` | — | — | Internal country metadata refresh |
| `ALL` | — | — | Part of deprecated `update all` |
| `BREAKNOMETADATA` | — | — | Internal: break on missing metadata |
| `SHORT` | — | — | Internal: short output format |
| `CTRYLIST` | — | — | Internal: country list generation |
| `OFFLINE(string)` | — | — | Testing: load CSV fixtures instead of API |

---

## Summary

| Category | Options | In sthlp | In paper |
|---|---|---|---|
| User-facing parameters | 7 | 7/7 | 7/7 |
| Core data options | 7 | 7/7 | 7/7 |
| Country attributes | 12 | 12/12 | 12/12 |
| Individual sub-options | 14 | — (grouped) | — |
| Sync & cache | 12 | 12/12 | 12/12 |
| Discovery commands | 10 | 10/10 | 10/10 |
| Graph metadata | 3 | 3/3 | 3/3 |
| Deprecated | 7 | 7/7 | 4/7 |
| Internal | 8 | — | — |

All user-facing options are now documented in both the sthlp and the paper.
The v18.2+/v18.3+ cache options (`nocache`, `cachedays`, `cleardatacache`,
`resetdatacache`, `verbose`) and `allsources` were added to the paper in
the February 2026 update.
