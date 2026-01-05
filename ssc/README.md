# SSC Package Distribution

This folder contains files for SSC (Statistical Software Components) package submission.

## Contents

- **ssc_wbopendata.171.zip** - Ready-to-submit package for SSC
- **build_ssc_package.ps1** - PowerShell script to regenerate the package
- **submission_email.md** - Template email for Kit Baum

## Package Details

**Version:** 17.7.1  
**Distribution Date:** January 4, 2026  
**Total Files:** 40  
**Package Size:** ~XXX KB

## Files Included in Package

### Package Metadata (2 files)
- `stata.toc` - Table of contents
- `wbopendata.pkg` - Package description and file list

### Main ADO Files (3 files)
- `wbopendata.ado` - Main program
- `wbopendata_populate_list.ado` - List population utility
- `wbopendata_examples.ado` - Example commands

### Help Files (8 files)
- `wbopendata.sthlp` - Main help file
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
- `country.txt` - Country codes (plain text - must be parsed correctly)
- `indicators.txt` - Indicator metadata (plain text - must be parsed correctly)

### Internal Functions (18 files)
- `_api_read.ado` - API reading functions
- `_api_read_indicators.ado` - Indicator API reading
- `_countrymetadata.ado` - Country metadata functions
- `_linewrap.ado` - **NEW v17.6** - Text wrapping for graphs
- `_metadata_linewrap.ado` - **NEW v17.6** - Metadata linewrap wrapper
- `_parameters.ado` - Parameter handling
- `_query.ado` - Query functions
- `_query_indicators.ado` - Indicator queries
- `_query_metadata.ado` - Metadata queries
- `_tknz.ado` - Tokenization utilities
- `_update_countrymetadata.ado` - Country metadata updates
- `_update_indicators.ado` - Indicator updates
- `_update_regionmetadata.ado` - **NEW v17.x** - Region metadata updates
- `_update_wbopendata.ado` - Package updates
- `_wbod_tmpfile1.ado` - Temporary file 1
- `_wbod_tmpfile2.ado` - Temporary file 2
- `_wbod_tmpfile3.ado` - Temporary file 3
- `_website.ado` - Website utilities

## Key Changes in v17.7.1

### v17.7 Features (Jan 2026)
- **Basic country metadata by default**: All downloads now include region, income level, lending type, admin region (8 variables)
- **New `nobasic` option**: Suppress default country context variables

### v17.6 Features (Dec 2025)
- **Graph metadata features**: `linewrap()`, `maxlength()`, `linewrapformat()` options
- **Dynamic subtitles**: `r(latest)` return value for graph annotations
- **New files**: `_linewrap.ado`, `_metadata_linewrap.ado`

### v17.7.1 Quality (Jan 2026)
- **Expanded test suite**: 44 automated tests across 9 categories
- **Comprehensive documentation**: Cross-referenced guides and examples

## Rebuilding the Package

To regenerate the package after making changes:

```powershell
cd ssc
.\build_ssc_package.ps1
```

This will:
1. Create a temporary directory with all package files
2. Copy files from `src/w/`, `src/_/`, `src/c/`, `src/i/`
3. Create `ssc_wbopendata.zip` in the `ssc/` folder
4. Clean up temporary files

## Important Notes

### Text File Parsing
The package includes two **plain text files** that must be parsed correctly by SSC:
- `country.txt` - Contains country codes and metadata
- `indicators.txt` - Contains indicator definitions

These are critical for package functionality.

### Auto-Generated Files NOT Included
The following files are **generated locally** and should NOT be distributed:
- `wbopendata_sourceid_indicators*.sthlp` (75+ files)
- `wbopendata_topicid_indicators*.sthlp` (23+ files)

Users generate these with `wbopendata, update` command.

## SSC Submission

Contact: **Kit Baum** (baum@bc.edu)

See `submission_email.md` for email template.

## Links

- **GitHub Repository**: https://github.com/jpazvd/wbopendata
- **SSC Archive**: https://ideas.repec.org/c/boc/bocode/s457234.html
- **Author**: João Pedro Azevedo (jpazvd.github.io)
