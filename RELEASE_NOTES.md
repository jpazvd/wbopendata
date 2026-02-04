# Release Notes

[← Back to README](README.md) | [Changelog](CHANGELOG.md) | [FAQ](doc/FAQ.md) | [Examples](doc/examples_gallery.md)

---

## wbopendata v17.7.1 — Test Suite Expansion & Documentation Overhaul

**Release Date:** January 4, 2026

---

### 🎉 Highlights

This release significantly expands the test suite to 44 tests across 9 categories and adds comprehensive documentation cross-references. The testing guide now includes a detailed philosophy section comparing wbopendata's integration testing approach with CRAN/PyPI offline testing patterns.

### 🧪 Test Suite Expansion

| Metric | v17.7 | v17.7.1 |
|--------|-------|---------|
| **Total Tests** | 36 | 44 |
| **Test Categories** | 7 | 9 |
| **New Categories** | - | TOPIC, LANG, Advanced |

**New Tests Added:**
- TOPIC-01: Topics API download validation
- LANG-01: Language option (Spanish metadata)
- PROJ-01: Projection data (source=40)
- FMT-04: nobasic option verification
- DESC-01: Describe-only mode
- META-01: nometadata verification
- CTRY-11: Admin regions (adminr option)
- DATE-01: Date range option

### 📚 Documentation Improvements

- Added testing philosophy section to TESTING_GUIDE.md
- Cross-referenced all critical documentation files
- Updated version references across all docs
- Enhanced changelog with v17.5–v17.7.1 entries

---

## wbopendata v17.7 — Basic Metadata by Default

**Release Date:** January 2, 2026

---

### 🎉 Highlights

This release adds **basic country context variables by default** to all downloads, providing immediate access to region, income level, and lending type information without requiring the `match()` option.

### 📊 New Default Variables

Every download now includes these 8 variables automatically:

| Variable | Description |
|----------|-------------|
| `region` | Region code (e.g., "ECS", "LCN") |
| `regionname` | Region name (e.g., "Europe & Central Asia") |
| `adminregion` | Admin region code |
| `adminregionname` | Admin region name |
| `incomelevel` | Income level code (e.g., "HIC", "LMC") |
| `incomelevelname` | Income level name |
| `lendingtype` | Lending type code |
| `lendingtypename` | Lending type name |

### 🆕 New Options

- **`nobasic`**: Suppress default country context variables for minimal downloads

### Usage Examples

```stata
* Default: includes basic metadata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long
desc  // Shows 12 variables including 8 basic metadata

* Minimal: suppress basic metadata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long nobasic
desc  // Shows only 4 core variables
```

---

## wbopendata v17.6 — Graph Metadata Features

**Release Date:** December 28, 2025

---

### 🎉 Highlights

This release adds powerful **graph metadata features** for creating publication-ready visualizations with automatic text formatting and dynamic subtitles.

### 🆕 New Options

| Option | Description |
|--------|-------------|
| `linewrap()` | Wrap metadata text (name, description, note) |
| `maxlength()` | Set maximum characters per line (default: 50) |
| `linewrapformat()` | Output format: stack, newline, lines, all |

### 📈 New Return Values

| Return | Description |
|--------|-------------|
| `r(name#_stack)` | Wrapped indicator name for titles |
| `r(description#_newline)` | Wrapped description with `\n` |
| `r(latest)` | Dynamic subtitle string |
| `r(latest_ncountries)` | Number of countries |
| `r(latest_avgyear)` | Average year of data |
| `r(sourcecite#)` | Clean organization name |

### Usage Examples

```stata
* Graph with wrapped title and dynamic subtitle
wbopendata, indicator(SP.DYN.LE00.IN) clear linewrap(name description) maxlength(50)
twoway scatter ..., title("`r(name1_stack)'") subtitle("`r(latest)'")

* Get text with newline characters for notes
wbopendata, indicator(SP.DYN.LE00.IN) clear linewrap(description) linewrapformat(newline)
local desc = r(description1_newline)
```

---

## wbopendata v17.1 — Documentation Overhaul & Community Bug Fixes

**Release Date:** December 21, 2025

---

### 🎉 Highlights

This release focuses on community-driven bug fixes, comprehensive documentation improvements, and repository professionalization. Special thanks to our community contributors who reported issues and helped improve the package.

### 📊 Updated Metadata (December 2025)

| Metric | Value |
|--------|-------|
| **Total Indicators** | 20,147 |
| **Data Sources** | 51 |
| **Topic Categories** | 21 |
| **Countries & Regions** | 296 |
| **Time Coverage** | 1960–present |

**New Data Sources Added:**
- Source 92: Disability Data Hub (DDH) — 1,333 indicators
- Source 93: FPN Datahub Archive — 42 indicators

---

### 🐛 Bug Fixes

| Issue | Description | Contributor |
|-------|-------------|-------------|
| [#33](https://github.com/jpazvd/wbopendata/issues/33) | Fixed `latest` option functionality | @lucaslindoso |
| [#35](https://github.com/jpazvd/wbopendata/issues/35) | Fixed country metadata retrieval | @lucaslindoso |
| [#45](https://github.com/jpazvd/wbopendata/issues/45) | Resolved URL construction errors | @lucaslindoso |
| [#46](https://github.com/jpazvd/wbopendata/issues/46) | Fixed varlist option handling | @lucaslindoso |
| [#51](https://github.com/jpazvd/wbopendata/issues/51) | Updated documentation to match API behavior | @daniel-klein |

---

### 📚 New Documentation

- **[FAQ](doc/FAQ.md)** — Common questions compiled from GitHub issues
- **[Examples Gallery](doc/examples_gallery.md)** — Visual showcase with example figures and ready-to-run Stata code
- **Example Do-Files:**
  - [`basic_usage.do`](doc/examples/basic_usage.do) — 10 introductory examples
  - [`advanced_usage.do`](doc/examples/advanced_usage.do) — 10 advanced use cases
- **Enhanced [README](README.md)** — Installation instructions, quick start guide, documentation table, and contributing guidelines
- **Updated Help File** — Added Community Contributors section acknowledging bug reporters

---

### 🧪 Quality Assurance

- **[Test Protocol](qa/test_protocol.md)** — Comprehensive testing checklist for releases
- **[Automated Test Suite](qa/run_tests.do)** — 257-line test script covering all major functionality

---

### 📁 Repository Organization

Reorganized documentation into structured subdirectories:

```
doc/
├── plans/      # Future improvement plans
├── logs/       # Development logs  
├── images/     # Example figures
└── examples/   # Example do-files

qa/             # Quality assurance materials
```

---

### 👥 Community Contributors

We thank the following contributors for their bug reports and suggestions:

- **@ckrf** — Country metadata fixes ([PR #44](https://github.com/jpazvd/wbopendata/pull/44)) 🆕
- **@lucaslindoso** — Issues #33, #35, #45, #46
- **@daniel-klein** — Issue #51
- **@randrescastaneda** — Extensive testing and feedback
- **@zhaowill** — Early adoption and testing

---

### 📦 Installation

```stata
* Install from SSC (recommended)
ssc install wbopendata, replace

* Install from GitHub (latest version)
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main") replace
```

---

### 🔗 Resources

| Resource | Description |
|----------|-------------|
| [Full Documentation](doc/wbopendata.md) | Complete command reference |
| [Examples Gallery](doc/examples_gallery.md) | Visual examples with code |
| [FAQ](doc/FAQ.md) | Frequently asked questions |
| [Report Issues](https://github.com/jpazvd/wbopendata/issues) | Bug reports and feature requests |

---

### 🔀 Merged Pull Requests

- Country metadata fixes by @ckrf in [#44](https://github.com/jpazvd/wbopendata/pull/44)
- v17 by @jpazvd in [#50](https://github.com/jpazvd/wbopendata/pull/50)
- update 20240702 by @jpazvd in [#52](https://github.com/jpazvd/wbopendata/pull/52)
- Develop by @jpazvd in [#53](https://github.com/jpazvd/wbopendata/pull/53)

### 🌟 New Contributors

- **@ckrf** made their first contribution in [#44](https://github.com/jpazvd/wbopendata/pull/44)

---

### Full Changelog

**Compare:** [v16.3...v17.1](https://github.com/jpazvd/wbopendata/compare/v16.3...v17.1)

---

## Previous Releases

For complete version history including all releases from v12.0 (2013) to present, see the **[Changelog](CHANGELOG.md)**.

### Version Timeline

```
2026 ─┬─ v17.7.1  Test suite expansion, documentation
      ├─ v17.7    Basic country context by default
      └─ v17.6    Graph metadata (linewrap) features

2025 ─── v17.1    Community bug fixes, documentation overhaul

2023 ─── v17.0    Region metadata, enhanced matching

2020 ─┬─ v16.3    HTTPS API migration
      └─ v16.0    Multiple indicators, modular architecture

2019 ─┬─ v15.1    Update options, 16,000+ indicators
      └─ v14.0    New API server

2016 ─── v13.5    Last SSC release before major overhaul ◄──

2014 ─── v13.0    Duplicate fix, 9,960 indicators

2013 ─── v12.0    7,349 indicators, return list enhancements
```

### SSC vs GitHub Versions

| Channel | Current | Notes |
|---------|---------|-------|
| **SSC** | v13.5 | Stable, install via `ssc install wbopendata` |
| **GitHub** | v17.7.1 | Latest features, install via `net install` |

> **Note:** The SSC version (v13.5) predates the 2019 API modernization. For full functionality including `match()`, `linewrap()`, and 29,000+ indicators, install from GitHub.

---

*For questions or support, visit [jpazvd.github.io](https://jpazvd.github.io) or open an [issue](https://github.com/jpazvd/wbopendata/issues).*
