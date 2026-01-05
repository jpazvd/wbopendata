# wbopendata Paper

Stata Journal manuscript documenting the `wbopendata` command: fifteen years of programmatic access to World Bank Open Data.

## Files

| File | Description |
|------|-------------|
| `jpazvd_wbopendata_restructured.tex` | Main manuscript (active) |
| `jpazvd_wbopendata.tex` | Earlier version (archive) |

## Folders

| Folder | Contents |
|--------|----------|
| `figs/` | PDF figures referenced in the paper (5 files) |
| `sjlogs/` | Stata log snippets for inclusion via `\input{}` |
| `scripts/` | Stata do-files and Python utilities |
| `docs/` | Supporting documentation |

## Style Files

The manuscript uses the Stata Journal document class:

- `statapress.cls` — Main document class
- `sj_clean.sty` — SJ formatting for drafts (no StataCorp branding)
- `sj.sty` — Official SJ formatting (for final submission)
- `stata.sty` — Stata code formatting
- `pagedims.sty` — Page dimensions and crop marks

## Building

Compile with pdflatex:

```bash
pdflatex jpazvd_wbopendata_restructured.tex
```

Or with latexmk for automatic rebuilds:

```bash
latexmk -pdf jpazvd_wbopendata_restructured.tex
```

## Regenerating Log Snippets

1. Run the Stata do-files in `scripts/` to generate raw `.tex` files in `sjlogs/`
2. Run the Python cleaner to produce `.log.tex` files:

```bash
cd scripts
python clean_logs.py
```

The cleaner reads `sjlogs/*.tex` (raw) and writes `sjlogs/*.log.tex` (cleaned for LaTeX inclusion).

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
