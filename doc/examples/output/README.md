# Output Directory

This directory contains all outputs from running the example do-files.

## Directory Structure

```
output/
├── figures/          # PNG graphs (high-resolution, 1200px width)
│   ├── gdp_per_capita_brics.png
│   ├── life_exp_vs_gni.png
│   ├── population_by_region.png
│   ├── inflation_rates.png
│   └── mortality_by_income.png
├── logs/             # Stata log files (text format)
│   ├── basic_usage_log.txt
│   └── advanced_usage_log.txt
├── data/             # Exported datasets
│   ├── gdp_data.csv
│   ├── gdp_data.xlsx
│   ├── gdp_data.dta
│   └── poverty_table.xlsx
└── README.md         # This file
```

## Generated Figures

| File | Description | Example |
|------|-------------|---------|
| `gdp_per_capita_brics.png` | GDP per capita trends | Brazil, China, India |
| `life_exp_vs_gni.png` | Life expectancy vs GNI scatter | Cross-country comparison |
| `population_by_region.png` | Population by region bar chart | 2022 data |
| `inflation_rates.png` | Inflation time series | Argentina, Turkey, Venezuela |
| `mortality_by_income.png` | Under-5 mortality box plot | By income group |

## Log Files

| File | Source | Description |
|------|--------|-------------|
| `basic_usage_log.txt` | `basic_usage.do` | 10 basic examples |
| `advanced_usage_log.txt` | `advanced_usage.do` | 10 advanced examples |

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
