# wbopendata YAML build paths (Python + Stata fallback)

**Purpose**
Document the two supported workflows to generate the metadata YAML files used by wbopendata. Both outputs must be equivalent.

## Files produced
- `_wbopendata_indicators.yaml`
- `_wbopendata_sources.yaml`
- `_wbopendata_topics.yaml`

## Primary path (Python)
**Script:** `wbopendata-dev/src/py/update_metadata.py`

**What it does**
- Calls World Bank API
- Builds normalized metadata
- Writes YAML files to `src/_/` (configurable via `--output-dir`)
- Optional schema validation

**Typical usage**
From repo root:
```
python wbopendata-dev/src/py/update_metadata.py --output-dir wbopendata-dev/src/_ --verbose
```

**Notes**
- Uses YAMLGenerator + SchemaValidator
- Preferred path for routine refreshes
- `--output-dir` lets you write to a custom path for parity checks

## Fallback path (Stata-only)
**Program:** `wbopendata-dev/src/_/_wbopendata_refresh_yaml.ado`

**What it does**
- Downloads XML via WB API
- Parses/normalizes in Stata
- Emits YAML via `yaml write`

**Typical usage**
```
_wbopendata_refresh_yaml, outdir("C:/GitHub/myados/wbopendata-dev/src/_") replace verbose
```

**Notes**
- No Python dependency
- Used as a fallback if Python stack is unavailable
- `outdir()` lets you write to a custom path for parity checks

## Parity requirement
Both methods must generate the same logical content. Minimal acceptable checks:
- Same number of entries per file
- Same keys per entry
- Same indicator/source/topic IDs

Recommended check (manual):
1. Generate YAML via Python
2. Generate YAML via Stata (to a temp dir)
3. Compare after removing headers and timestamps

Recommended check (scripted):
```
python wbopendata-dev/tests/compare_yaml_parity.py --stata-dir <stata_out> --python-dir <python_out>
```

## Packaging rule
In `wbopendata.pkg`, YAML files must use **uppercase `F`** so Stata installs them to system directories regardless of extension:
```
F _/_wbopendata_indicators.yaml
F _/_wbopendata_sources.yaml
F _/_wbopendata_topics.yaml
F _/_wbopendata_parameters.yaml
```

This ensures `net install` places YAML files in `PLUS/_/`.
