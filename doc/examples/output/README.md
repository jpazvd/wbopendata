# Output Directory

This directory contains log files and graphs from running the example do-files.

## Log Files

| File | Description |
|------|-------------|
| `basic_usage_log.txt` | Output from `basic_usage.do` |
| `advanced_usage_log.txt` | Output from `advanced_usage.do` |

## Generated Graphs

| File | Description |
|------|-------------|
| `gdp_per_capita_brics.png` | GDP per capita - Brazil, China, India |
| `life_exp_vs_gni.png` | Life expectancy vs GNI scatter plot |
| `population_by_region.png` | World population by region bar chart |
| `inflation_rates.png` | Inflation rates time series |
| `mortality_by_income.png` | Under-5 mortality by income group |

## Regenerating Outputs

To regenerate these files, run in Stata:

```stata
cd "C:/GitHub/myados/wbopendata/doc/examples"
do "run_examples.do"
```

Or manually run each example:

```stata
cd "C:/GitHub/myados/wbopendata/doc/examples"
log using "output/basic_usage_log.txt", text replace
do "basic_usage.do"
log close

log using "output/advanced_usage_log.txt", text replace
do "advanced_usage.do"
log close
```

## Note

These outputs are generated from live API calls to the World Bank data servers. Results may vary slightly depending on when the scripts are run due to data updates.

Last generated: December 2025
