# Output Directory

This directory contains log files from running the example do-files.

## Files

| File | Description |
|------|-------------|
| `basic_usage_log.txt` | Output from `basic_usage.do` |
| `advanced_usage_log.txt` | Output from `advanced_usage.do` |

## Regenerating Logs

To regenerate these log files, run in Stata:

```stata
do "C:/GitHub/myados/wbopendata/doc/examples/run_examples.do"
```

Or manually run each example:

```stata
log using "output/basic_usage_log.txt", text replace
do "basic_usage.do"
log close

log using "output/advanced_usage_log.txt", text replace
do "advanced_usage.do"
log close
```

## Note

These logs are generated from live API calls to the World Bank data servers. Results may vary slightly depending on when the scripts are run due to data updates.

Last generated: December 2025
