# Logs Directory

Stata log files (text format) from running the example do-files.

## Files

| File | Source | Lines | Description |
|------|--------|-------|-------------|
| `basic_usage_log.txt` | `basic_usage.do` | ~300 | 10 basic examples |
| `advanced_usage_log.txt` | `advanced_usage.do` | ~400 | 10 advanced examples |

## Regenerating

```stata
cd "C:/GitHub/myados/wbopendata/doc/examples"
do "run_examples.do"
```

## Format

Logs are saved as plain text (`.txt`) for maximum compatibility:
- Easy to view on GitHub
- Can be included in Markdown documents
- Version-control friendly
