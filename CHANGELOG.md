# Changelog

All notable changes to `wbopendata` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

