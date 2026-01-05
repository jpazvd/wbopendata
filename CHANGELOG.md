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

## [16.2.2] - 2020-06-28

### Fixed
- Package distribution and SSC compatibility updates

## [16.0] - 2019-10-29

### Added
- Multiple indicator download support (semicolon-separated)
- Enhanced metadata display options

## Earlier Versions

For earlier version history, see the [SSC archive](https://ideas.repec.org/c/boc/bocode/s457234.html).

---

## Version History Summary

| Version | Date | Key Changes |
|---------|------|-------------|
| 17.0 | 24Jan2023 | Region metadata, enhanced matching |
| 16.3 | 08Jul2020 | HTTPS migration |
| 16.2.2 | 28Jun2020 | Package fixes |
| 16.0 | 29Oct2019 | Multiple indicators |

