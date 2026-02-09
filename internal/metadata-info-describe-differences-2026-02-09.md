# wbopendata describe vs info differences (2026-02-09)

## Observed timestamps (from user log)
- wbopendata, indicator(DP.DOD.DECD.CR.NF.Z1) describe: r; t=0.95 at 3:31:49
- return list (after describe): r; t=0.00 at 3:31:52
- wbopendata, info(DP.DOD.DECD.CR.NF.Z1): r; t=23.44 at 3:32:24
- return list (after info): r; t=0.00 at 3:32:31

## Observed performance difference
- In this run, describe completed in under 1 second, while info took about 23 seconds.
- This indicates local YAML parsing for info was slower than the single API request used by describe in this environment.

## Output differences (screen display)
- describe shows API metadata and uses sourceNote as Description, sourceOrganization as Note.
- info shows YAML metadata; Description is the YAML block scalar marker (">-") and Note is N/A.
- info shows Source with ID and a Browse link; describe shows Collection only.
- describe Topic(s) is empty; info Topics is N/A (no topic list in YAML for this indicator).

## Return list comparison

### describe (from return list)
- Scalars:
  - r(nurls) = 0
- Macros:
  - r(collection) = "20 Quarterly Public Sector Debt"
  - r(name) = "Gross PSD, Nonfinancial Public Corp., All maturities, All instruments, Domestic creditors, Nominal Value, % of GDP"
  - r(sourcecite) = "<wb:sourceOrganization"
  - r(note) = "<wb:sourceOrganization"
  - r(description) = "The source of non-seasonally adjusted Gross Domestic Product (GDP) data in national currency, at current prices, is the International Finance St.."
  - r(indicator) = "DP.DOD.DECD.CR.NF.Z1"
  - r(varlabel) = "Gross PSD, Nonfinancial Public Corp., All maturities, All instruments, Domestic creditors, Nominal Value, % of GDP"
  - r(source) = "20 Quarterly Public Sector Debt"

### info (from return list)
- Macros:
  - r(cmd) = "wbopendata, info(DP.DOD.DECD.CR.NF.Z1)"
  - r(yaml_path) = "C:\Users\jpazevedo\ado\plus/_/_wbopendata_indicators.yaml"
  - r(note) = "N/A"
  - r(description) = ">-"
  - r(topics) = "N/A"
  - r(source_id) = "20"
  - r(source_org) = "Quarterly Public Sector Debt"
  - r(source_name) = "Quarterly Public Sector Debt"
  - r(name) = "Gross PSD, Nonfinancial Public Corp., All maturities, All instruments, Domestic creditors, Nominal Value, % of GDP"
  - r(indicator) = "DP.DOD.DECD.CR.NF.Z1"

## Summary of differences
- describe returns API metadata fields and a sourcecite; info returns YAML fields and a yaml_path.
- describe description/note are populated from API; info description is the block-scalar marker and note is N/A.
- info includes source_id/source_org/source_name; describe includes collection/source/varlabel.
