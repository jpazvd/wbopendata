# wbopendata Test Protocol

[← Back to README](../README.md) | [FAQ](../doc/FAQ.md) | [Examples](../doc/examples/) | [Testing Guide](TESTING_GUIDE.md)

---

## Overview

This document outlines the testing protocol for validating `wbopendata` functionality before releases.

**Version**: 17.7.1  
**Last Updated**: January 2026

---

## Test Environment Requirements

- Stata 14+ (preferably Stata 17+)
- Active internet connection
- Clean Stata session (no data in memory)

---

## Pre-Test Setup

```stata
clear all
set more off
cap log close
log using "wbopendata_test_log.txt", replace text
```

---

## Test Categories

### 1. Installation Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| INST-01 | Fresh SSC install | `ssc install wbopendata, replace` | Successful installation |
| INST-02 | GitHub install | `net install wbopendata, from(...) replace` | Successful installation |
| INST-03 | Help file loads | `help wbopendata` | Help displays correctly |
| INST-04 | Dialog opens | `db wbopendata` | Dialog box appears |

### 2. Basic Download Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| DL-01 | Single indicator, all countries | `wbopendata, indicator(SP.POP.TOTL) clear` | Data loads, ~260 countries |
| DL-02 | Single indicator, single country | `wbopendata, indicator(SP.POP.TOTL) country(USA) clear` | 1 country, 60+ years |
| DL-03 | Single indicator, multiple countries | `wbopendata, indicator(SP.POP.TOTL) country(USA;BRA;CHN) clear` | 3 countries |
| DL-04 | Multiple indicators | `wbopendata, indicator(SP.POP.TOTL;NY.GDP.MKTP.CD) clear` | 2 indicators |
| DL-05 | Topic download | `wbopendata, topics(4) clear` | Education indicators |

### 3. Format Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| FMT-01 | Wide format (default) | `wbopendata, indicator(SP.POP.TOTL) clear` | Year columns (yr1960...) |
| FMT-02 | Long format | `wbopendata, indicator(SP.POP.TOTL) clear long` | Year as variable |
| FMT-03 | Year range | `wbopendata, indicator(SP.POP.TOTL) year(2010:2020) clear` | Only 2010-2020 |
| FMT-04 | Latest only | `wbopendata, indicator(SP.POP.TOTL) clear long latest` | Single year per country |

### 4. Metadata Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| META-01 | Metadata displayed | `wbopendata, indicator(SP.POP.TOTL) clear` | Metadata in results |
| META-02 | No metadata option | `wbopendata, indicator(SP.POP.TOTL) clear nometadata` | No metadata display |
| META-03 | URL in metadata | `wbopendata, indicator(SL.UEM.TOTL.ZS) clear` | No parsing error |

### 5. Country Metadata Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| CTRY-01 | Match basic | See test code below | Country attrs added |
| CTRY-02 | Match with full | See test code below | All attributes added |
| CTRY-03 | Match with iso | See test code below | ISO2 codes added |

**Test code for CTRY-01/02/03:**
```stata
* Create test data
clear
input str3 countrycode
"USA"
"BRA"
"CHN"
end

* CTRY-01: Basic match
wbopendata, match(countrycode)
assert regionname != ""

* CTRY-02: Full attributes
clear
input str3 countrycode
"USA"
"BRA"
"CHN"
end
wbopendata, match(countrycode) full
describe

* CTRY-03: ISO codes
clear
input str3 countrycode
"USA"
"BRA"
"CHN"
end
wbopendata, match(countrycode) iso
assert countrycode_iso2 != ""
```

### 6. Update Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| UPD-01 | Query update | `clear` then `wbopendata, update query` | Shows current vintage |
| UPD-02 | Check update | `clear` then `wbopendata, update check` | Compares vintages |

### 7. Error Handling Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| ERR-01 | Invalid indicator | `wbopendata, indicator(INVALID.CODE) clear` | Graceful error |
| ERR-02 | Invalid country | `wbopendata, indicator(SP.POP.TOTL) country(XXX) clear` | Graceful error or empty |
| ERR-03 | Match with indicator (incompatible) | See code | Error message |

**Test code for ERR-03:**
```stata
* Should produce error about incompatibility
cap wbopendata, indicator(SP.POP.TOTL) match(countrycode) clear
assert _rc != 0
```

### 8. Return Values Tests

| Test ID | Description | Command | Expected Result |
|---------|-------------|---------|-----------------|
| RET-01 | Check return list | `wbopendata, indicator(SP.POP.TOTL) clear` then `return list` | r() values populated |
| RET-02 | Multiple indicators | `wbopendata, indicator(SP.POP.TOTL;NY.GDP.MKTP.CD) clear` then `return list` | Multiple indicator info |

---

## Regression Tests (for fixed issues)

| Issue | Test | Command | Expected Result |
|-------|------|---------|-----------------|
| #33 | Latest with long names | `wbopendata, indicator(DT.DOD.DECT.CD) clear long latest` | No error |
| #35 | Country sub-options | Test CTRY-02 above | Works correctly |
| #45 | URL in metadata | Test META-03 above | No parsing error |
| #46 | Varlist update | `clear` then `wbopendata, update check` | No error |
| #51 | Match documentation | Test ERR-03 above | Clear error message |

---

## Performance Benchmarks

| Test | Command | Target Time |
|------|---------|-------------|
| Single indicator, all countries | `wbopendata, indicator(SP.POP.TOTL) clear` | < 30 seconds |
| Topic download | `wbopendata, topics(4) clear` | < 60 seconds |
| Multiple indicators (3) | `wbopendata, indicator(A;B;C) clear` | < 60 seconds |

---

## Test Execution Checklist

- [ ] All INST tests pass
- [ ] All DL tests pass
- [ ] All FMT tests pass
- [ ] All META tests pass
- [ ] All CTRY tests pass
- [ ] All UPD tests pass
- [ ] All ERR tests pass
- [ ] All RET tests pass
- [ ] All regression tests pass
- [ ] Performance within targets

---

## Reporting

After testing, document:

1. **Date and time** of test
2. **Stata version** used
3. **wbopendata version** tested
4. **Pass/Fail** for each category
5. **Any errors or anomalies**
6. **Log file** saved

```stata
log close
* Save log as: wbopendata_test_YYYYMMDD.log
```

---

## Automated Test Script

See `qa/run_tests.do` for automated test execution.
