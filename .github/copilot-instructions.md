# wbopendata-dev Repository - AI Agent Instructions

> See also:
> - Main Stata coding patterns: [../.github/copilot-stata-instructions.md](../../.github/copilot-stata-instructions.md)
> - Stata Journal paper guidelines: [../.github/copilot-sj-paper-instructions.md](../../.github/copilot-sj-paper-instructions.md)
> - Repository management SOP: [../.github/github-repo-sop.md](../../.github/github-repo-sop.md)

## Repository Overview

- **Package**: wbopendata - Stata module for accessing World Bank Open Data API
- **Type**: Stata ADO package (single language)
- **License**: MIT
- **Author**: João Pedro Azevedo ([World Bank](https://www.worldbank.org) | [UNICEF](https://www.unicef.org))
- **Contact**: https://jpazvd.github.io

## Repository Architecture

This is a **private development repository** (`wbopendata-dev`) that automatically syncs to the public repository (`jpazvd/wbopendata`). See [github-repo-sop.md](../../.github/github-repo-sop.md) for details.

### Folder Structure

```
wbopendata-dev/
├── src/                     → SYNC to public (ADO source code)
│   ├── w/                   # Main commands (wbopendata.ado, wbopendata.sthlp)
│   └── _/                   # Helper programs (_query_metadata.ado, _website.ado, etc.)
├── doc/                     → SYNC to public (User documentation)
│   ├── examples/            # Example do-files
│   └── images/              # Screenshots and diagrams
├── qa/                      → SYNC to public (Test protocols)
│   └── logs/                ✗ PRIVATE (Test execution logs)
├── ssc/                     → SYNC to public (SSC distribution package)
├── scripts/                 → SYNC to public (Build and deployment scripts)
├── paper/                   ✗ PRIVATE (Stata Journal manuscript)
├── .github/
│   ├── copilot-instructions.md  ✗ PRIVATE (This file)
│   └── workflows/
│       └── sync-to-public.yml   ✗ PRIVATE (Sync automation)
├── CHANGELOG.md             → SYNC to public
├── README.md                → SYNC to public
└── LICENSE                  → SYNC to public
```

## Key Features

- **Data Access**: Download 20,000+ World Bank indicators from 51 databases
- **Metadata**: Fetch indicator metadata with automatic URL formatting
- **Language Support**: Multi-language metadata (English, Spanish, French, etc.)
- **Graphics**: Publication-ready graphs with automatic metadata line-wrapping
- **SSC Distribution**: Packaged for easy installation via `ssc install wbopendata`

## Development Environment

### Stata 17 (Local Installation)

| Property | Value |
|----------|-------|
| **Path** | `C:\Program Files\Stata17\StataMP-64.exe` |
| **Version** | Stata 17 MP (64-bit) |
| **User ADO path** | `$env:USERPROFILE\ado\plus\` |

### Running Stata from PowerShell

```powershell
# Execute a do-file
& "C:\Program Files\Stata17\StataMP-64.exe" /e do "path\to\script.do"

# From project root
cd C:\GitHub\myados\wbopendata-dev
& "C:\Program Files\Stata17\StataMP-64.exe" /e do "qa\run_examples.do"
```

### Copying Files to User ADO Path

After editing source files in `src/`, copy to user ADO path for testing:

```powershell
# Copy main command
Copy-Item -Path "src\w\wbopendata.ado" -Destination "$env:USERPROFILE\ado\plus\w\wbopendata.ado" -Force
Copy-Item -Path "src\w\wbopendata.sthlp" -Destination "$env:USERPROFILE\ado\plus\w\wbopendata.sthlp" -Force

# Copy helper programs
Copy-Item -Path "src\_\_query_metadata.ado" -Destination "$env:USERPROFILE\ado\plus\_\_query_metadata.ado" -Force
Copy-Item -Path "src\_\_website.ado" -Destination "$env:USERPROFILE\ado\plus\_\_website.ado" -Force

# In Stata: Clear cached programs
discard
```

## Coding Standards

### Stata 11 Compatibility

**CRITICAL**: All code must be compatible with Stata 11 or higher.

- Use `version 11` in all ado-files
- Avoid Mata features added after Stata 11
- Test on Stata 11 if possible (legacy users)

### Quoting Rules

See [copilot-stata-instructions.md](../../.github/copilot-stata-instructions.md) for detailed quoting patterns.

**Quick Reference**:
- Simple quotes `` `"..."` `` for plain macros
- Compound quotes `` `" "' `` for text with embedded quotes or SMCL
- **Never use compound quotes in extended macro functions** (`: word # of`)

### Graph Footnotes

All figures must include metadata footnotes with source and variable code:

```stata
graph twoway (...), title("Title") ///
    note("Source: World Bank. Variable: NY.GDP.MKTP.CD")
graph export "output/figure.png", width(1200) replace
```

### Line Wrapping

Use the `linewrap()` option for long metadata:

```stata
wbopendata, indicator(NY.GDP.MKTP.CD) clear long ///
    linewrap(70) linewrapformat("    ")
```

## Testing

### Test Protocol

```stata
* Run all examples
do qa\run_examples.do

* Test specific indicator
wbopendata, indicator(SP.POP.TOTL) clear
assert _N > 0
```

### Test Logs

**IMPORTANT**: Test logs (`*.log`) are PRIVATE and must be .gitignored.

- Test code (`qa/*.do`) → Public (shows methodology)
- Test logs (`qa/logs/*.log`) → Private (execution artifacts)

## Versioning

**All releases use Semantic Versioning (SemVer)**:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking change | MAJOR | `17.6.0` → `18.0.0` |
| New feature | MINOR | `17.6.0` → `17.7.0` |
| Bug fix | PATCH | `17.6.0` → `17.6.1` |

### Version Header Format

```stata
*! v 17.6.3  04Jan2026  by João Pedro Azevedo
```

## Release Workflow

1. Update version in all `.ado` files
2. Update `CHANGELOG.md`
3. Update `wbopendata.pkg` and `stata.toc`
4. Commit and push to `wbopendata-dev`
5. Create annotated tag: `git tag -a v17.7.0 -m "Release v17.7.0"`
6. Push tag: `git push origin v17.7.0`
7. GitHub Action automatically syncs to public repo

## SSC Distribution

The `ssc/` folder contains the SSC distribution package:

```
ssc/
├── wbopendata.pkg      # Package file
├── stata.toc           # Repository index
├── *.ado               # ADO files
├── *.sthlp             # Help files
└── package.zip         # Distribution archive
```

**Update on each release**: Run `scripts/package_for_ssc.ps1`

## Paper (Stata Journal)

The `paper/` folder contains the Stata Journal manuscript (PRIVATE).

See [copilot-sj-paper-instructions.md](../../.github/copilot-sj-paper-instructions.md) for LaTeX formatting guidelines.

**Key Files**:
- `paper/jpazvd_wbopendata.tex` - Main manuscript
- `paper/sjlogs/` - Generated Stata output
- `paper/figs/` - Figures for paper

## Common Tasks

### Add New Indicator

1. Update metadata cache if needed
2. Test indicator: `wbopendata, indicator(NEW.CODE) clear`
3. Update documentation
4. Add to examples

### Update Metadata Handling

1. Edit `src/_/_query_metadata.ado`
2. Edit `src/_/_website.ado` for URL formatting
3. Copy to user ADO path
4. Run `discard` in Stata
5. Test with `wbopendata, indicator(XYZ) clear metadata`

### Fix Bug

1. Create feature branch: `git checkout -b fix/issue-description`
2. Make changes in `src/`
3. Copy to user ADO path for testing
4. Test with `qa/run_examples.do`
5. Update CHANGELOG.md (Patch version)
6. Commit and push to `wbopendata-dev`
7. Merge to main
8. Tag patch release: `v17.6.4`

## Dependencies

- **Stata**: Version 11 or higher
- **Internet**: Required for API access

## Contact

For questions or contributions, contact João Pedro Azevedo: https://jpazvd.github.io

---

*Last updated: January 14, 2026*
