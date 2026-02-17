# wbopendata Paper

Stata Journal manuscript documenting the `wbopendata` command: fifteen years of programmatic access to World Bank Open Data.

## Files

| File | Description |
|------|-------------|
| `azevedo-2026-wbopendata.tex` | Working draft (v18.1, uses `sj_clean.sty`) |
| `wbopendata.bib` | BibTeX bibliography database |
| `jpazvd_wbopendata_v3.tex` | Previous version (v18.0 draft) |
| `jpazvd_wbopendata_v2.tex` | Earlier version (v17.x era) |
| `jpazvd_wbopendata-v1.tex` | Initial version (archive) |

## Folders

| Folder | Contents |
|--------|----------|
| `wbopendata_sj_submission/` | Self-contained SJ submission package (tex, bib, sjlogs, figs, software, cover letter) |
| `figs/` | PDF figures referenced in the paper (5 figures) |
| `sjlogs/` | Stata log snippets for LaTeX inclusion (20 `.log.tex` files) |
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

Compile the working draft with pdflatex:

```powershell
pdflatex azevedo-2026-wbopendata.tex
bibtex azevedo-2026-wbopendata
pdflatex azevedo-2026-wbopendata.tex
pdflatex azevedo-2026-wbopendata.tex
```

The submission copy is in `wbopendata_sj_submission/` and uses `sj.sty` (official SJ formatting):

```powershell
cd wbopendata_sj_submission
pdflatex azevedo-2026-wbopendata-sj-submitted.tex
bibtex azevedo-2026-wbopendata-sj-submitted
pdflatex azevedo-2026-wbopendata-sj-submitted.tex
pdflatex azevedo-2026-wbopendata-sj-submitted.tex
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
