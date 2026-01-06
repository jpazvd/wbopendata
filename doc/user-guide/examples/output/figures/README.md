# Figures Directory

High-resolution PNG graphs generated from example do-files.

## Files

| File | Resolution | Description |
|------|------------|-------------|
| `gdp_per_capita_brics.png` | 1200×800 | GDP per capita trends (Brazil, China, India) |
| `life_exp_vs_gni.png` | 1200×800 | Life expectancy vs GNI per capita scatter |
| `population_by_region.png` | 1200×800 | World population by region (2022) |
| `inflation_rates.png` | 1200×800 | Inflation time series (ARG, TUR, VEN) |
| `mortality_by_income.png` | 1200×800 | Under-5 mortality by income group |

## Regenerating

```stata
cd "C:/GitHub/myados/wbopendata/doc/user-guide/examples"
do "run_examples.do"
```

## Format

All figures are exported as PNG with:
- Width: 1200 pixels
- Scheme: s2color (Stata default)
- Format: PNG (web-friendly, GitHub-compatible)
