# Changelog

All notable changes to `wbopendata` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## Related Documentation

| Document | Description |
|----------|-------------|
| [README](README.md) | Overview, installation, quick start |
| [FAQ](doc/FAQ.md) | Troubleshooting and common questions |
| [Examples Gallery](doc/examples_gallery.md) | Visual code examples |
| [Test Protocol](qa/test_protocol.md) | Testing checklist |
| [Testing Guide](qa/TESTING_GUIDE.md) | Testing best practices |
| [Release Notes](RELEASE_NOTES.md) | Detailed release notes |

---

## [Unreleased]

### Added
- **Sync Preview feature** (`syncpreview`, `syncdryrun` options)
  - Pre-sync diagnostic display showing cache status, API comparison, and sync pathway
  - `detail` option for per-source and per-topic indicator breakdown
  - Country metadata count (296 countries/territories/aggregates) in preview display
  - Helper programs: `_wbopendata_get_source_name`, `_wbopendata_get_topic_name`
  - Clickable SMCL actions for common sync operations
- **Stats History Tracking** (`_wbopendata_cache_stats_history.yaml`)
  - Automatic recording of sync statistics after each successful sync
  - Tracks: timestamp, method, indicator/source/topic/country counts
  - Per-source and per-topic breakdown for trend analysis
  - History file appends entries over time for release notes generation
  - New program: `_wbopendata_write_stats_history.ado`

### Changed
- Sync system now shows detailed metadata status before sync execution
- `_wbopendata_sync_preview.ado` updated to v1.2.0 with country count
- Package updated with new helper ado files

---

## [17.7.1] - 2026-01-04

### Added
- **Test Suite Expansion**: 44 tests across 9 categories (previously 36 tests)
- New test categories: TOPIC, LANG, PROJ, DESC, META, DATE for advanced features
- Testing philosophy documentation comparing wbopendata vs CRAN/PyPI approaches
- Comprehensive documentation cross-references

### Fixed
- DESC-01 test now correctly checks `r(indicator1)` and `r(name1)` return locals
- TOPIC-01 test now handles both `indicatorcode` and `indicator` variable names

### Documentation
- Added testing philosophy section to TESTING_GUIDE.md
- Updated test category documentation
- Cross-referenced all critical documentation files

## [17.7] - 2026-01-02

### Added
- **Basic country context variables included by default** in all downloads
- New variables: `region`, `regionname`, `adminregion`, `adminregionname`, `incomelevel`, `incomelevelname`, `lendingtype`, `lendingtypename`
- New `nobasic` option to suppress default country context variables
- FMT-04 test for nobasic option validation

### Changed
- Default download behavior now includes 8 basic metadata variables
- Documentation updated with new default behavior examples

## [17.6.3] - 2026-01-01

### Fixed
- Resolved macro length errors (r(920)) in CTRY tests
- Fixed match() option with auto-generated metadata files
- Improved test robustness by using real datasets instead of manual input

## [17.6] - 2025-12-28

### Added
- `linewrap()` option for graph-ready text formatting
- `maxlength()` option to control line wrap width (default: 50)
- `linewrapformat()` option for output format control (`stack`, `newline`, `lines`, `all`)
- Support for multiple `maxlength()` values per field
- New return values: `r(name1_stack)`, `r(description1_newline)`, etc.
- LW-01 through LW-04 tests for linewrap functionality

### Changed
- Metadata display enhanced with line-wrapped output for graphs

## [17.5] - 2025-12-25

### Added
- Enhanced error handling for API responses
- Improved timeout handling for large downloads

### Fixed
- Various stability improvements

## [17.4] - 2025-12-22

### Added
- New return values for `latest` option: `r(latest)`, `r(latest_ncountries)`, `r(latest_avgyear)`
- Dynamic subtitle string for graphs (e.g., "Latest Available Year, 186 Countries (avg year 2019.6)")
- `r(sourcecite#)` returns with clean organization names for graph source attribution
- Example 15 in advanced_usage.do demonstrating linewrap with dynamic subtitle

### Changed
- Documentation updated with new return values and examples

## [17.3] - 2025-12-22

### Added
- Support for multiple `maxlength()` values: `maxlength(40 100 80) linewrap(name description note)`
- Each field can have its own character limit for line wrapping

## [17.2] - 2025-12-22

### Added
- `linewrap()` option for graph-ready text formatting
- `maxlength()` option to control line wrap width
- `linewrapformat()` option for output format control (stack/all)

## [17.1] - 2025-12-21

### Fixed
- Issue #33: `latest` option now correctly handles multiple indicators
- Issue #35: Country metadata matching improvements
- Issue #45: URL parsing errors in metadata
- Issue #46: Variable list handling
- Issue #51: Documentation for `match()` option

## [17.0] - 2023-01-24

### Added
- Region metadata creation support
- Enhanced country metadata matching with `match()` option

### Changed
- Main entry point updated to v17.0

## [16.3] - 2020-07-08

### Changed
- API endpoint changed from HTTP to HTTPS for security
- Updated `_query.ado` and `_api_read.ado` to use secure connections

## [16.2.3] - 2020-06-29

### Changed
- Rewrote metadata query to use `_api_read.ado`

## [16.2.2] - 2020-06-28

### Changed
- Switched metadata server used for queries

## [16.2.1] - 2020-04-14

### Fixed
- Added flow check so `_query.ado` does not run when `metadataoffline` is selected

## [16.2] - 2020-04-13

### Added
- `metadataoffline` option to generate SOURCEID/TOPICID metadata locally
- Generates 71 sthlp files and ~15MB of documentation

## [16.1] - 2020-04-12

### Changed
- Removed SOURCEID/TOPICSID metadata from the main dissemination package

## [16.0.1] - 2019-10-31

### Changed
- Minor functionality improvements (per ado history)

## [16.0] - 2019-10-27

### Added
- `_api_read_indicators.ado`: Download indicator list from API in Stata-readable form
- `_update_indicators.ado`: Generates documentation from API output
- `match()` option: Add country metadata matching on specified variable
- `_website.ado`: Converts HTTP/WWW text to SMCL web-compatible code
- `_parameters.ado`: Detailed count of indicators by SOURCE and TOPIC
- Help file search for indicators by Source and Topics
- Dialogue indicator list
- sthlp indicator list and metadata by Source and Topic

### Changed
- Renamed `_wbopendata.ado` to `_update_wbopendata.ado`
- Renamed `_indicator` to `_update_indicators`
- `_update_wbopendata.ado` now checks for changes at SOURCE/TOPIC level
- Fixed return list when multiple indicators are selected

---

## [15.1] - 2019-03-04

### Added
- New error category 23: Series moved to archive
- Country attribute table fully revised and linked to API
- `update check`, `update query`, and `update` options
- Auto-refresh indicators functionality
- `update countrymetadata` option
- Country metadata documentation in help file

### Changed
- Revised `_wbopendata.ado`
- Country attributes fully revised
- Break on missing metadata is now optional

### Fixed
- Over 16,000 indicators now supported

---

## [15.0.1] - 2019-02-08

### Changed
- Maintenance release (per ado history)

---

## [15.0] - 2019-02-02

### Changed
- Major version bump with internal improvements

---

## [14.3] - 2019-02-02

### Fixed
- `_wbopendata_update.ado` revised
- `out.txt` file no longer created

---

## [14.2] - 2019-01-31

### Fixed
- Updated `_wbopendata_update.ado`
- Added `set checksum off`

---

## [14.1] - 2019-01-19

### Added
- Indicator update function
- `nopreserve` option (return list can be preserved)

### Fixed
- `latest` option behavior
- `_query_metadata.ado` source ID return list

### Changed
- Updated examples
- Updated help file
- Updated list of indicators

---

## [14.0] - 2019-01-14

### Changed
- Migrated to new API server
- Revised indicator list

---

## [13.5] - 2016-02-09

### Changed
- Indicator list update (February 2016)

> **Note:** This was the last SSC release before major API and architecture changes.

---

## [13.4] - 2014-07-01

### Added
- Long reshape functionality

---

## [13.3] - 2014-06-30

### Added
- New error control for `clear` option

---

## [13.2] - 2014-06-24

### Added
- New error control mechanisms

---

## [13.1] - 2014-06-23

### Added
- Regional code, name, and iso2code support

---

## [13.0] - 2014-06-20

### Fixed
- Duplicate records problem resolved

### Changed
- Improved error messages
- Updated indicator list to 9,960 indicators

---

## [12.0] - 2013-01-31

### Changed
- Updated to 7,349 indicators
- Return list now includes variable name and label

---

## Version History Summary

| Version | Date | Key Changes |
|---------|------|-------------|
| **17.7.1** | 2026-01-04 | Test suite expansion, bug fixes |
| **17.7** | 2026-01-02 | Basic country context by default |
| **17.6** | 2025-12-28 | Graph metadata (linewrap) features |
| **17.1** | 2025-12-21 | Community bug fixes, documentation overhaul |
| **17.0** | 2023-01-24 | Region metadata, enhanced matching |
| **16.3** | 2020-07-08 | HTTPS API migration |
| **16.2.3** | 2020-06-29 | Metadata query rewrite (uses `_api_read.ado`) |
| **16.2.2** | 2020-06-28 | Metadata server update |
| **16.2.1** | 2020-04-14 | Flow check for `metadataoffline` |
| **16.2** | 2020-04-13 | Offline metadata option |
| **16.1** | 2020-04-12 | Removed SOURCEID/TOPICSID metadata from package |
| **16.0.1** | 2019-10-31 | Minor improvements |
| **16.0** | 2019-10-27 | Multiple indicators, modular architecture |
| **15.1** | 2019-03-04 | Update options, 16,000+ indicators |
| **15.0.1** | 2019-02-08 | Maintenance release |
| **14.0** | 2019-01-14 | New API server |
| **13.5** | 2016-02-09 | **Last SSC release before major overhaul** |
| **13.0** | 2014-06-20 | Duplicate fix, 9,960 indicators |
| **12.0** | 2013-01-31 | 7,349 indicators |

---

## SSC Release History

The SSC (Statistical Software Components) archive at Boston College maintains the official Stata package distribution:

| SSC Version | Date | Notes |
|-------------|------|-------|
| v13.5 | Feb 2016 | Last pre-API-modernization release |
| v16.3 | Jul 2020 | HTTPS migration |
| v17.x | 2023+ | Current development |

For the SSC archive, see: [RePEc:boc:bocode:s457234](https://ideas.repec.org/c/boc/bocode/s457234.html)

