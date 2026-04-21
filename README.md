# WBOPENDATA: Stata module to access World Bank databases

[![GitHub tag](https://img.shields.io/github/v/tag/jpazvd/wbopendata)](https://github.com/jpazvd/wbopendata/releases)
[![SSC install](https://img.shields.io/badge/SSC-install-blue)](https://ideas.repec.org/c/boc/bocode/s457234.html)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/jpazvd/wbopendata)](https://github.com/jpazvd/wbopendata/issues)

> 📚 **[Complete Documentation](doc/README.md)** | [Examples](doc/user-guide/examples_gallery.md) | [FAQ](doc/user-guide/FAQ.md) | `help wbopendata` in Stata

## Description

### 📊 At a Glance

| | |
|---|---|
| **29,000+** | Indicators available |
| **71** | Data sources |
| **21** | Topic categories |
| **296** | Countries & regions |
| **17** | Country attributes |
| **1960–present** | Time coverage |
| **3** | Languages (EN, ES, FR) |

---

`wbopendata` provides Stata users with programmatic access to the World Bank's Open Data API, enabling scripted, reproducible downloads of over **29,000 indicators** from **71 databases** covering **296 countries and regions** from **1960 to present**.

The accessible databases include: World Development Indicators (WDI), Doing Business, Worldwide Governance Indicators, International Debt Statistics, Africa Development Indicators, Education Statistics, Enterprise Surveys, Gender Statistics, Health Nutrition and Population Statistics, Global Financial Inclusion (Findex), Poverty and Equity, Human Capital Index, Climate Change (CCDR), Sustainable Development Goals, and many more.

**Five download modes** are supported:

- **country**: All WDI indicators for a single country across selected years
- **topics**: All indicators within a thematic category (e.g., Education, Health) for all countries
- **indicator**: A single indicator for all countries and years
- **indicator + country**: A single indicator for selected countries
- **multiple indicators**: Multiple indicators (separated by `;`) for all or selected countries

**Output formats:**
- **Wide format** (default): Year-specific columns (`yr1960`, `yr1961`, etc.)
- **Long format**: One row per country-year observation

**Key features:**
- **Multilingual metadata**: English, Spanish, or French
- **Country attributes**: 17 fields including region, income level, lending type, geographic coordinates
- **Latest data**: `latest` option returns most recent non-missing values per country
- **Graph-ready metadata**: `linewrap()` option formats long text for publication-quality graphs
- **Reproducibility**: Every query is scripted, parameterized, and version-controlled
- **Persistent provenance** (v18.1): Dataset and variable characteristics (`char`) embed query parameters, timestamps, and indicator codes directly in `.dta` files

Data are retrieved directly from the World Bank API (JSON over HTTP), ensuring transparency and provenance. All data reflect officially-recognized international sources compiled by the World Bank.

The access to these databases is made possible by the World Bank's [Open Data Initiative](http://data.worldbank.org/).

## Installation

**Minimum requirement:** Stata 14 or later.

### From GitHub (Recommended)

```stata
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main/src/") replace
```

### From SSC (Stable but older)

```stata
ssc install wbopendata, replace
```

> The [SSC version](https://ideas.repec.org/c/boc/bocode/s457234.html) (v17.7.1) is one release behind GitHub. For discovery commands, sync redesign, and YAML metadata, install from GitHub.

### From GitHub (Specific Release)

```stata
* Install v18.1.1 specifically
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/v18.1.1") replace
```

### From Local Clone
```stata
* Windows - install from repo root (pkg references src/ paths)
net install wbopendata, from("C:/GitHub/myados/wbopendata") replace

* Mac/Linux
net install wbopendata, from("/Users/username/GitHub/wbopendata") replace
```

> **Note:** The **wbopendata project** maintains three `wbopendata.pkg` files:
> - `wbopendata.pkg` (root): For GitHub/local `net install` — uses `src/` paths
> - `src/wbopendata.pkg`: For direct `src/`-level installs — uses relative paths
> - `ssc/wbopendata.pkg` *(in private `wbopendata-dev` only, not in this public repo)*: For SSC submission — uses flat paths (included in zip)

### SSC vs GitHub Versions

| Channel    | Version        | Indicators | Notes                               |
|------------|----------------|------------|-------------------------------------|
| **SSC**    | v17.7.1 (2025) | ~20,000    | Stable, one release behind GitHub   |
| **GitHub** | v18.1.1 (2026) | 29,000+    | Latest features, active development |

> **Recommendation:** Install from GitHub for full functionality including `match()`, `linewrap()`, multiple indicators, and 29,000+ indicators.

<details>
<summary><b>📅 Version History</b> (click to expand)</summary>

| Year | Version | Milestone |
|------|---------|-----------|
| 2026 | v18.1 | **Characteristic metadata**: persistent `char` provenance on every `.dta`; `nochar` opt-out |
| 2026 | v18.0 | **Discovery commands**: sources, alltopics, search, info; clickable URLs in metadata |
| 2026 | v17.7 | Basic country context by default, graph metadata |
| 2025 | v17.1 | Community bug fixes, documentation overhaul |
| 2023 | v17.0 | Region metadata, enhanced country matching |
| 2020 | v16.3 | HTTPS API migration |
| 2019 | v16.0 | Multiple indicators, modular architecture |
| 2019 | v14.0 | New API server, 16,000+ indicators |
| 2016 | v13.5 | **Last SSC release before major overhaul** |
| 2014 | v13.0 | 9,960 indicators |
| 2013 | v12.0 | Initial SSC release |

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

</details>

## Quick Start

```stata
* Download GDP for all countries
wbopendata, indicator(NY.GDP.MKTP.CD) clear

* Download multiple indicators for specific countries
wbopendata, indicator(NY.GDP.MKTP.CD;SP.POP.TOTL) country(USA;BRA;CHN) clear long

* Download by topic (e.g., Education)
wbopendata, topics(4) clear

* Get country metadata
wbopendata, match(countrycode) full

* NEW in v17.6: Graph-ready metadata with linewrap
wbopendata, indicator(SP.DYN.LE00.IN) clear linewrap(name description note) maxlength(50)

* Get text with newline characters for graph notes
wbopendata, indicator(SP.DYN.LE00.IN) clear linewrap(description) linewrapformat(newline)
local desc_newline = r(description1_newline)

* Latest available data per country
wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long latest
* With multiple indicators: keeps only observations where ALL indicators are non-missing
* in the SAME year, ensuring comparability (different countries may have different years)

* NEW in v17.7: Basic country context variables are now included by default
* Every download now includes: region, regionname, adminregion, adminregionname,
* incomelevel, incomelevelname, lendingtype, lendingtypename
wbopendata, indicator(NY.GDP.MKTP.CD) clear long
desc  // Shows 12 variables including the 8 basic metadata variables

* Use nobasic to suppress default country context variables
wbopendata, indicator(NY.GDP.MKTP.CD) clear long nobasic
desc  // Shows only 4 core variables

* NEW in v18.1: Persistent provenance via char metadata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long
char list  // Shows _dta[] and variable-level characteristics

* Use nochar to suppress characteristic metadata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long nochar

* NEW: Discovery features - search for indicators
wbopendata, search(GDP)                    // Search indicators by keyword
wbopendata, search(education) limit(50)    // Limit results
wbopendata, searchtopic(11) page(2)        // Navigate paginated results

* NEW: Get detailed info about a specific indicator
wbopendata, info(NY.GDP.MKTP.CD)

* NEW: Sync and cache management
wbopendata, checkupdate    // Check if metadata updates are available
wbopendata, sync           // Sync metadata from GitHub
wbopendata, cacheinfo      // Display cache status
```

---

## 📚 Documentation

**→ [Browse Complete Documentation](doc/README.md)** — Start here for guides, examples, and reference materials

### Quick Links

| Document | Description |
|----------|-------------|
| **[Documentation Hub](doc/README.md)** | 🏠 Central navigation for all documentation |
| **[FAQ](doc/user-guide/FAQ.md)** | ❓ Frequently asked questions and troubleshooting |
| **[Examples Gallery](doc/user-guide/examples_gallery.md)** | 📊 Code snippets with embedded figures |
| **[Do File Examples](doc/user-guide/examples/)** | 💻 Runnable Stata code files |
| **[Help File](doc/wbopendata.md)** | 📖 Full documentation with code output |
| **[Roadmap](doc/roadmap/ROADMAP.md)** | 🗺️ Future development plans and priorities |

### For Contributors

| Document | Description |
|----------|-------------|
| **[Test Protocol](qa/test_protocol.md)** | ✓ Testing checklist for contributors |
| **[Testing Guide](qa/TESTING_GUIDE.md)** | 📋 Testing best practices and philosophy |
| **[Changelog](CHANGELOG.md)** | 📝 Version history and changes |
| **[Release Notes](RELEASE_NOTES.md)** | 🎉 Detailed release notes |

> 💡 **Tip:** In Stata, type `help wbopendata` for built-in documentation.

## Parameters

- **country(string)**: Countries and Regions Abbreviations and acronyms. If solely specified, this option will return all the WDI indicators (1,076 series) for a single country or region (no multiple country selection allowed in this case). If this option is selected jointly with a specific indicator, the output is a series for a specific country or region, or multiple countries or region. When selecting multiple countries please use the three letters code, separated by a semicolon (;), with no spaces.


- **topics(numlist)**: Topic List. 21 topic lists are currently supported and include Agriculture & Rural Development; Aid Effectiveness; Economy & Growth; Education; Energy & Mining; Environment; Financial Sector; Health; Infrastructure; Social Protection & Labor; Poverty; Private Sector; Public Sector; Science & Technology; Social Development; Urban Development; Gender; Millennium development goals; Climate Change; External Debt; and Trade (only one topic collection can be requested at a time).


- **indicator(string)**: Indicators List. List of indicator codes (all series). When selecting multiple indicators, use semicolon (;) to separate different indicators.

### Output Options

- **long**: Reshape data to long format (one row per country-year)
- **latest**: Keep only the most recent non-missing observation per country
- **clear**: Clear existing data before loading
- **nobasic**: Suppress default country context variables (region, income level, etc.)
- **nochar**: Suppress characteristic metadata (dataset and variable `char` provenance)

### Discovery & Search

**NEW in v18.0:** Interactive discovery commands with clickable SMCL navigation.

#### Browsing Commands

- **sources**: List all 71 World Bank data sources with indicator counts and clickable `[Browse]` links
- **alltopics**: List all 21 topic categories with indicator counts and clickable `[Browse]` links

#### Search Commands

- **search(string)**: Search indicators by keyword (supports multiple words, wildcards `*`, regex patterns)
- **searchsource(integer)**: Filter search results to a specific source (e.g., `searchsource(2)` for WDI)
- **searchtopic(integer)**: Filter search results to a specific topic (e.g., `searchtopic(4)` for Education)
- **searchfield(string)**: Search in specific fields: `code`, `name`, `description`, `all` (default: `all`)
- **exact**: Require exact word match (no partial matching)
- **detail**: Show full indicator details with wrapped text instead of truncated table
- **limit(integer)**: Per-page record count (default: 20)
- **page(integer)**: Page of results to display (default: 1). When total matches exceed `limit`, clickable `[Prev]` / `[Next]` / page-number links appear below the table. Small result sets (≤30 matches) always render on a single page, so pagination only kicks in when it's useful.

#### Indicator Info

- **info(string)**: Get detailed metadata for a specific indicator code

The `info()` command displays comprehensive indicator metadata in a structured layout:
- **Indicator/Name**: Code and full name
- **Unit**: Measurement unit (when available)
- **Source ID/Name**: Database identifier and name on separate lines
- **Topic ID(s)/Topic(s)**: All topic IDs and names (semicolon-separated for multi-topic indicators)
- **Description**: Full description with clickable URLs
- **Note**: Methodology note with clickable hyperlinks
- **Limited data warning**: Displayed when data availability is limited
- **Filters**: Clickable `searchsource()` and `searchtopic()` commands
- **Download**: Clickable commands for Wide/Long/Specific countries formats

```stata
* NEW in v18.0: Discovery commands

* List all data sources with clickable navigation
wbopendata, sources

* List all topic categories
wbopendata, alltopics

* Search for indicators
wbopendata, search(GDP)                           // Basic keyword search
wbopendata, search(GDP growth)                    // Multi-keyword search
wbopendata, search(GDP*) searchsource(2)          // Wildcard + filter by source
wbopendata, search(education) searchtopic(4)      // Filter by topic
wbopendata, search(~^NY\.GDP) searchfield(code)   // Regex search in code field
wbopendata, search(poverty) detail                // Full details with wrapped text

* Paginate large result sets
wbopendata, searchtopic(11) limit(20) page(2)     // Records 21-40 in topic 11
wbopendata, search(poverty) limit(10) page(3)     // Third page of 10 per page

* Get detailed info about a specific indicator
wbopendata, info(NY.GDP.MKTP.CD)
```

### Metadata & Sync

- **sync**: Sync metadata cache from GitHub
- **checkupdate**: Check if metadata updates are available
- **cacheinfo**: Display cache status
- **clearcache**: Clear local metadata cache

### Graph Formatting

- **linewrap(string)**: Wrap metadata text for graphs (name, description, note)
- **maxlength(integer)**: Maximum characters per line (default: 50)
- **linewrapformat(string)**: Output format (stack, newline, lines, all)

### Deprecated Options

The following options are deprecated as of v18.1. They continue to work with a warning but will be removed in a future release.

| Deprecated option | Replacement | Version deprecated | Notes |
| --- | --- | --- | --- |
| `update query` | `sync` | v18.1 | Preview metadata changes (dry run) |
| `update check` | `checkupdate` | v18.1 | Compare local vs remote metadata version |
| `update all` | `sync replace` | v18.1 | Download latest YAML metadata from GitHub |
| `metadataoffline` | `sync replace` + `sources`/`search()`/`info()` | v18.1 | Generated 71 per-indicator `.sthlp` files (~15 MB); replaced by YAML metadata + discovery commands |
| `syncforce` | `sync replace force` | v18.0 | Alias |
| `syncpreview` | `sync replace` | v18.0 | Alias |
| `syncdryrun` | `sync` | v18.0 | Alias (dry run is now the default) |

**Removed files (v18.0):** 89 per-indicator `.sthlp` files (`wbopendata_sourceid_indicators*.sthlp`, `wbopendata_topicid_indicators*.sthlp`) replaced by 2 YAML metadata files serving ~29,000 indicators.

## Disclaimer

   Users should not use wbopendata without checking first for more detailed information on the definitions of each [indicator](http://data.worldbank.org/indicator/)
    and [data-catalogues](http://data.worldbank.org/data-catalog/). The indicators names and codes used by wbopendata are precisely the same used in the World Bank data
    catalogue in order to facilitate such cross reference.

   When downloading specific series, through the indicator options, wbopendata will by default display in the Stata results
    window the metadata available for this particular series, including information on the name of the series, the source, a
    detailed description of the indicator, and the organization responsible for compiling this indicator.

## Terms of use World Bank Data
   
The use of World Bank datasets listed in the Data Catalog is governed by a specific [Terms of Use for World Bank Data](http://data.worldbank.org/summary-terms-of-use/).
            
The terms of use of the APIs is governed by the [World Bank Terms and Conditions](http://go.worldbank.org/C09SUA7BK0/).


## Blog Posts & Tutorials

### Official Blog Posts

* **[New release of WBOPENDATA Stata module (Apr 24, 2020)](https://blogs.worldbank.org/en/opendata/new-release-wbopendata-stata-module)**
* **[WBOPENDATA Stata Module Upgrade (Jul 08, 2014)](https://blogs.worldbank.org/en/opendata/wbopendata-stata-module-upgrade)**
* **[New Stata module released (Feb 06, 2013)](https://blogs.worldbank.org/en/opendata/new-stata-module-released)**
* **[Accessing World Bank Open Data in Stata (Mar 15, 2012)](https://blogs.worldbank.org/en/opendata/accessing-world-bank-open-data-stata)**
* **[World Bank Development Data in Stata (Feb 17, 2011)](http://rlab-data.blogspot.com/2011/02/world-bank-development-data-in-stata.html)**
* **[World Bank’s open data policy and -wbopendata- (Feb 10, 2011)](http://statadaily.com/tag/wbopendata/)**

### Official Documentation & Reference

* **[WBOPENDATA Helpdesk — World Bank Knowledge Base](https://datahelpdesk.worldbank.org/knowledgebase/articles/889464-wbopendata-stata-module-to-access-world-bank-data)**
* **[WBOPENDATA GitHub Repository](https://github.com/jpazvd/wbopendata)**

### Community Tutorials

* **[Extracting World Bank data in Stata (Medium)](https://infoart.medium.com/extracting-world-bank-data-in-stata-27b7d82bf0d2)**
* **[Using World Bank data — Bates College LibGuide](https://libguides.bates.edu/c.php?g=1424953&p=10608125)**
* **[World Bank indicators in Stata — GetErika](https://geterika.com/stats/world-bank-indicators-in-stata)**
* **[Visualizing World Bank Data in Stata — Simon Fink blog](https://simonfink.wordpress.com/2013/08/14/visualizing-world-bank-data-in-stata/)**


## 🤝 Invitation to Contribute

If you’ve authored or found **other blog posts, tutorials, videos, code examples, or classroom materials** that explore the *wbopendata* module (especially recent ones), please **share them with the community**!
You can contribute by **opening an issue or submitting a pull request** on this repository with your addition.


## Examples

**[📊 Examples Gallery](doc/user-guide/examples_gallery.md)** - Visual guide with code snippets and output figures

**[Basic Usage Examples](doc/user-guide/examples/basic_usage.do)** - Getting started with wbopendata

**[Advanced Usage Examples](doc/user-guide/examples/advanced_usage.do)** - Panel data, visualizations, and more

**[Examples of code and output](doc/wbopendata.md)**

## Suggested Citation

[Joao Pedro Azevedo, 2011. "WBOPENDATA: Stata module to access World Bank databases," Statistical Software Components S457234, Boston College Department of Economics, revised 10 Feb 2016.](https://ideas.repec.org/c/boc/bocode/s457234.html)

#### Handle: RePEc:boc:bocode:s457234 

#### Note: 
This module should be installed from within Stata by typing "ssc install wbopendata". Windows users should not attempt to download these files with a web browser.

#### Keywords:
Indicators; WDI; API; Open Data

## Contributing

Contributions, bug reports, and feature requests are welcome! Please feel free to:
- Open an [issue](https://github.com/jpazvd/wbopendata/issues) for bug reports or suggestions
- Submit a pull request with improvements

## Acknowledgments

Special thanks to all contributors who have helped improve wbopendata through bug reports, feature suggestions, and feedback:

**Bug Reports & Fixes:**
[@dianagold](https://github.com/dianagold),
[@claradaia](https://github.com/claradaia),
[@SylWeber](https://github.com/SylWeber),
[@cuannzy](https://github.com/cuannzy),
[@oliverfiala](https://github.com/oliverfiala),
[@KarstenKohler](https://github.com/KarstenKohler),
[@ckrf](https://github.com/ckrf),
[@flxflks](https://github.com/flxflks),
[@Koko-Clovis](https://github.com/Koko-Clovis)

**Feature Requests & Suggestions:**
[@santoshceft](https://github.com/santoshceft),
[@Shijie-Shi](https://github.com/Shijie-Shi),
[@JavierParada](https://github.com/JavierParada),
[@yukinko-iwasaki](https://github.com/yukinko-iwasaki),
[@tenaciouslyantediluvian](https://github.com/tenaciouslyantediluvian)

## Author

**João Pedro Azevedo**  
[World Bank](https://www.worldbank.org/) | [UNICEF](https://www.unicef.org/)  
[jpazvd.github.io](https://jpazvd.github.io/)  
[Twitter](https://twitter.com/jpazvd)  

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.




