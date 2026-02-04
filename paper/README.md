# wbopendata Paper

Stata Journal manuscript documenting the `wbopendata` command: fifteen years of programmatic access to World Bank Open Data.

## Files

| File | Description |
|------|-------------|
| `jpazvd_wbopendata_v3.tex` | Main manuscript (current version) |
| `jpazvd_wbopendata_v2.tex` | Previous version (with bibliography) |
| `jpazvd_wbopendata-v1.tex` | Initial version (archive) |
| `wbopendata.bib` | BibTeX bibliography database |

## Folders

| Folder | Contents |
|--------|----------|
| `figs/` | PDF figures referenced in the paper (5 figures) |
| `sjlogs/` | Stata log snippets for LaTeX inclusion (38 files: `.tex` raw + `.log.tex` processed) |
| `scripts/` | Stata do-files and Python utilities for log generation |
| `docs/` | Supporting documentation |

## Style Files

The manuscript uses the Stata Journal document class:

- `statapress.cls` — Main document class
- `sj_clean.sty` — SJ formatting for drafts (no StataCorp branding)
- `sj.sty` — Official SJ formatting (for final submission)
- `stata.sty` — Stata code formatting
- `pagedims.sty` — Page dimensions and crop marks

## Building

Compile the current version with pdflatex:

```powershell
pdflatex jpazvd_wbopendata_v3.tex
bibtex jpazvd_wbopendata_v3
pdflatex jpazvd_wbopendata_v3.tex
pdflatex jpazvd_wbopendata_v3.tex
```

Or use latexmk for automatic rebuilds:

```bash
latexmk -pdf jpazvd_wbopendata_v3.tex
```

## Regenerating Log Snippets

To regenerate Stata log snippets from source:

1. Run the main generation script to produce raw `.tex` output in `sjlogs/`:

```stata
do scripts/generate_logs_sjlog.do
```

2. (Optional) Clean and post-process logs using Python utilities:

```bash
cd scripts
python clean_logs.py
```

The workflow produces:
- `sjlogs/*.tex` — Raw Stata output
- `sjlogs/*.log.tex` — Processed files ready for LaTeX `\input{}`

## Figures

| Figure | File | Description |
|--------|------|-------------|
| 1 | `wbopendata_linewrap_example.pdf` | Poverty/mortality scatter with metadata |
| 2 | `wbopendata_example01.pdf` | Choropleth map (mobile subscriptions) |
| 3 | `wbopendata_example04.pdf` | Poverty vs GDP scatter |
| 4 | `wbopendata_worldstat_africa_gdp.pdf` | Africa GDP map (worldstat) |
| 5 | `wbopendata_worldstat_world_fertility.pdf` | World fertility map (worldstat) |

## Author

João Pedro Azevedo  
https://jpazvd.github.io
