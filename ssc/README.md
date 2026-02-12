# SSC Package Distribution

This folder contains files for SSC (Statistical Software Components) package submission.

## Two-Package Architecture

This repo maintains **two separate `wbopendata.pkg` files**:

| File | Purpose | File Paths |
|------|---------|------------|
| `wbopendata.pkg` (root) | GitHub `net install` | Uses `src/` paths (e.g., `f src/w/wbopendata.ado`) |
| `ssc/wbopendata.pkg` | SSC submission & zip | Flat paths (e.g., `f wbopendata.ado`) |

**Why two files?**
- GitHub repo organizes source in `src/w/`, `src/_/`, `src/y/`, `src/c/`, `src/i/` subdirectories
- SSC requires flat structure (all files in same directory)
- The build script flattens the structure when creating the zip

## Contents

- **stata.toc** - SSC table of contents
- **wbopendata.pkg** - SSC package definition (flat paths)
- **ssc_wbopendata.1800.zip** - Ready-to-submit package for SSC
- **build_ssc_package.ps1** - PowerShell script to regenerate the package

## Package Details

**Version:** 18.0.0
**Distribution Date:** February 10, 2026
**Requires:** Stata version 14
**Total Files:** 59 (2 metadata + 57 distributable)
**License:** MIT

## Files Included in Package (57 distributable files)

### Main ADO Files (3 files)
- `wbopendata.ado` - Main program
- `wbopendata_populate_list.ado` - List population utility
- `wbopendata_examples.ado` - Example commands

### Help Files (9 files)
- `wbopendata.sthlp` - Main help file
- `wbopendata_whatsnew.sthlp` - **NEW v18.0** - What's new documentation
- `wbopendata_indicators.sthlp` - Indicators reference
- `wbopendata_adminregion.sthlp` - Admin regions help
- `wbopendata_incomelevel.sthlp` - Income levels help
- `wbopendata_lendingtype.sthlp` - Lending types help
- `wbopendata_region.sthlp` - Regions help
- `wbopendata_sourceid.sthlp` - Data sources help
- `wbopendata_topicid.sthlp` - Topics help

### Dialog File (1 file)
- `wbopendata.dlg` - GUI dialog

### Data Files (4 files)
- `world-c.dta` - World country data
- `world-d.dta` - World detail data
- `country.txt` - Country codes (plain text)
- `indicators.txt` - Indicator metadata (plain text)

### Internal Functions - Core (15 files)
- `_api_read.ado` - API reading functions
- `_api_read_indicators.ado` - Indicator API reading
- `_countrymetadata.ado` - Country metadata functions
- `_linewrap.ado` - Text wrapping for graphs
- `_metadata_linewrap.ado` - Metadata linewrap wrapper
- `_parameters.ado` - Parameter handling
- `_query.ado` - Query functions
- `_query_indicators.ado` - Indicator queries
- `_query_metadata.ado` - Metadata queries
- `_tknz.ado` - Tokenization utilities
- `_update_countrymetadata.ado` - Country metadata updates
- `_update_indicators.ado` - Indicator updates
- `_update_regionmetadata.ado` - Region metadata updates
- `_update_wbopendata.ado` - Package updates
- `_website.ado` - Website utilities

### Internal Functions - NEW v18.0 (19 files)
- `_wbopendata_cache.ado` - Cache management
- `_wbopendata_cache_clear.ado` - Cache clearing
- `_wbopendata_cache_info.ado` - Cache information
- `_wbopendata_check_version.ado` - Version checking
- `_wbopendata_download_yaml.ado` - Download YAML metadata
- `_wbopendata_get_yaml_path.ado` - YAML path resolution
- `_wbopendata_refresh_yaml.ado` - YAML metadata refresh
- `_wbopendata_get_source_name.ado` - Source name lookup
- `_wbopendata_get_topic_name.ado` - Topic name lookup
- `_wbopendata_info.ado` - Discovery: indicator info
- `_wbopendata_search.ado` - Discovery: search indicators
- `_wbopendata_sources.ado` - Discovery: list data sources
- `_wbopendata_topics.ado` - Discovery: list topics
- `_wbopendata_sync.ado` - Sync YAML metadata
- `_wbopendata_sync_preview.ado` - Sync preview/dryrun
- `_wbopendata_write_stats_history.ado` - Statistics history tracking
- `__wbod_parse_yaml_ind.ado` - Internal YAML indicator parsing
- `__wbopendata_search.ado` - Internal search engine
- `__wbopendata_search_cache.ado` - Internal search cache

### YAML Metadata Files - NEW v18.0 (4 files)
- `_wbopendata_parameters.yaml` - Parameters configuration (~5 KB)
- `_wbopendata_indicators.yaml` - Indicators metadata (~18 MB, ~29,323 indicators)
- `_wbopendata_sources.yaml` - Data sources metadata (~11 KB)
- `_wbopendata_topics.yaml` - Topics metadata (~15 KB)

### YAML Library - NEW v18.0 (2 files)
- `yaml.ado` - YAML parser for Stata
- `yaml.sthlp` - YAML parser help file

## Key Changes from v17.7.1 to v18.0.0

### New Features
- **Discovery commands**: `sources`, `alltopics`, `search`, `info` replace 89 per-indicator sthlp files
- **YAML-based architecture**: Parameters, indicators, sources, topics stored as YAML
- **Cache system**: Frame-based caching for search performance (Stata 16+)
- **Sync system**: `sync` and `syncpreview` for updating YAML metadata
- **YAML parser**: Bundled `yaml.ado` library for Stata

### Files Added (24 new files)
- 1 help file: `wbopendata_whatsnew.sthlp`
- 19 sub-routine ADOs (cache, discovery, sync, YAML support)
- 4 YAML metadata files

### Files Removed (3 files)
- `_wbod_tmpfile1.ado` (no longer needed)
- `_wbod_tmpfile2.ado` (no longer needed)
- `_wbod_tmpfile3.ado` (no longer needed)

### Files NOT Included in SSC
- Python files (`src/py/`) - Developer tools for metadata updates; require Python and specific directory structure incompatible with SSC flat install

## Rebuilding the Package

To regenerate the package after making changes:

```powershell
cd ssc
.\build_ssc_package.ps1
```

This will:
1. Create a temporary directory with all package files
2. Copy files from `src/w/`, `src/_/`, `src/y/`, `src/c/`, `src/i/`
3. Flatten everything into a single directory
4. Create `ssc_wbopendata.1800.zip` in the `ssc/` folder
5. Clean up temporary files

## Important Notes

### Large YAML File
The `_wbopendata_indicators.yaml` file is ~18 MB (29,323 indicators). This is the largest file in the package and is essential for the discovery commands (search, info).

### Stata Version Requirement
v18.0.0 requires Stata 14+ (up from Stata 12 in previous versions). The frame-based search cache requires Stata 16+ but gracefully degrades on older versions.

### Auto-Generated Files NOT Included
The following files are **generated locally** and should NOT be distributed:
- `wbopendata_sourceid_indicators*.sthlp` (75+ files)
- `wbopendata_topicid_indicators*.sthlp` (23+ files)

Users generate these with `wbopendata, update` command.

## SSC Submission

Contact: **Kit Baum** (baum@bc.edu)

## Links

- **GitHub Repository**: https://github.com/jpazvd/wbopendata
- **SSC Archive**: https://ideas.repec.org/c/boc/bocode/s457234.html
- **Author**: Joao Pedro Azevedo (jpazvd.github.io)
