# Tests and parity scripts

This folder holds the Stata and Python helpers used to generate and compare the YAML metadata files.

## Quick parity workflow

1) Generate Stata YAML and run the parity compare:

```
"C:\Program Files\Stata17\StataMP-64.exe" /e do "C:\GitHub\myados\wbopendata-dev\tests\run_yaml_parity.do"
```

This writes Stata outputs to:
- C:/GitHub/myados/wbopendata-dev/tests/parity_out/stata

and runs the Python parity check against:
- C:/GitHub/myados/wbopendata-dev/tests/parity_out/python

2) Run the parity check directly (if both outputs already exist):

```
"C:\GitHub\myados\.venv\Scripts\python.exe" "C:\GitHub\myados\wbopendata-dev\tests\compare_yaml_parity.py" \
  --stata-dir "C:\GitHub\myados\wbopendata-dev\tests\parity_out\stata" \
  --python-dir "C:\GitHub\myados\wbopendata-dev\tests\parity_out\python"
```

3) Compare only specific sections:

```
... --sections indicators
... --sections sources,topics
```

## Key scripts

- run_yaml_parity.do
  - Stata driver: regenerates Stata YAML, fixes topic mojibake, runs the Python parity compare.
- compare_yaml_parity.py
  - Python comparator: loads both YAMLs, normalizes values, strips volatile metadata keys, and reports sample diffs.
- fix_stata_yaml_mojibake.py
  - Post-processing for topics YAML encoding fixes.
- debug_refresh.do, refresh_verbose.do, run_refresh_verbose.do
  - Helpers for tracing and verbose Stata refresh runs.
- compare_indicator_schema.py
  - XML schema audit for the indicators API pages.

## Outputs

- parity_out/stata
  - Stata-generated YAML outputs.
- parity_out/python
  - Python-generated YAML outputs.
- parity_out/parity_run.log
  - Log produced by run_yaml_parity.do.

## Notes

- The Python comparator ignores _metadata.generated_at and _metadata.checksum_sha256 during comparison.
- If a section is missing, the parity script prints a "missing file" error for that side.
- Stata YAML uses `postfile` with `str2045`, so long descriptions are truncated. This can cause parity diffs against Python until a direct `file write` YAML emitter is implemented.

## Troubleshooting

- Stata YAML missing: check parity_out/parity_run.log to confirm refresh completed and the output directory exists.
- Indicators mismatch: re-run compare_yaml_parity.py with --sections indicators to get sample Diff key entries.
- Encoding issues: re-run fix_stata_yaml_mojibake.py on the Stata topics YAML output.
