# Frequently Asked Questions (FAQ)

This FAQ is compiled from [GitHub Issues](https://github.com/jpazvd/wbopendata/issues) and common user questions.

---

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [Data Download Issues](#data-download-issues)
3. [Country & Region Selection](#country--region-selection)
4. [Indicator Selection](#indicator-selection)
5. [Data Formats & Options](#data-formats--options)
6. [Metadata & Updates](#metadata--updates)
7. [Error Messages](#error-messages)

---

## Installation & Setup

### Q: How do I install wbopendata?

**From SSC (Recommended):**
```stata
ssc install wbopendata, replace
```

**From GitHub (Development Version):**
```stata
net install wbopendata, from("https://raw.githubusercontent.com/jpazvd/wbopendata/main/src/") replace
```

### Q: I get "_countrymetadata command is unrecognized" error

This usually means you have an incomplete installation. Reinstall with:
```stata
ssc install wbopendata, replace all
```

Make sure all auxiliary files are installed. See [Issue #4](https://github.com/jpazvd/wbopendata/issues/4).

---

## Data Download Issues

### Q: I get "Failed to access data" or connection errors

**Possible causes:**
1. **Network issues**: Check your internet connection
2. **Firewall/Proxy**: Some institutional networks block API access
3. **World Bank API downtime**: Check [World Bank API status](https://data.worldbank.org/)

**Solutions:**
```stata
* Try with a simple indicator first
wbopendata, indicator(SP.POP.TOTL) clear

* If behind proxy, configure Stata's proxy settings
set httpproxy on
set httpproxyhost "your.proxy.host"
set httpproxyport 8080
```

See [Issue #37](https://github.com/jpazvd/wbopendata/issues/37).

### Q: How do I specify a particular version of the WDI dataset?

The World Bank API does not support version-specific queries. The API always returns the latest available data. For reproducibility:

1. **Document the download date** in your code
2. **Save a local copy** of the downloaded data
3. **Use the World Bank Databank** for archived versions

See [Issue #49](https://github.com/jpazvd/wbopendata/issues/49).

---

## Country & Region Selection

### Q: How do I download data for specific countries only?

Use 3-letter ISO country codes separated by semicolons:
```stata
* Single country
wbopendata, indicator(NY.GDP.MKTP.CD) country(USA) clear

* Multiple countries
wbopendata, indicator(NY.GDP.MKTP.CD) country(USA;BRA;CHN;IND) clear
```

### Q: How do I filter out aggregates and get only individual countries?

After download, filter using the `region` variable:
```stata
wbopendata, indicator(SP.POP.TOTL) clear long

* Keep only individual countries (exclude aggregates)
drop if region == ""
* OR
keep if regionname != "Aggregates"
```

See [Issue #54](https://github.com/jpazvd/wbopendata/issues/54).

### Q: AFE (Africa Eastern) and AFW (Africa Western) are not marked as aggregates

This is a known issue with World Bank's regional classification. These are regional aggregates but may be classified differently. Use caution when filtering.

See [Issue #47](https://github.com/jpazvd/wbopendata/issues/47).

---

## Indicator Selection

### Q: How do I find indicator codes?

**Option 1: Browse the help files**
```stata
help wbopendata_sourceid
help wbopendata_topicid
```

**Option 2: Use the World Bank website**
Visit [data.worldbank.org/indicator](https://data.worldbank.org/indicator) and look for the indicator code in the URL.

**Option 3: Download by topic first**
```stata
* Download all Education indicators (topic 4)
wbopendata, topics(4) clear
```

### Q: How do I download multiple indicators?

Separate indicator codes with semicolons (no spaces):
```stata
wbopendata, indicator(NY.GDP.MKTP.CD;SP.POP.TOTL;SE.PRM.ENRR) clear long
```

---

## Data Formats & Options

### Q: What's the difference between wide and long format?

**Wide format (default):** Each year is a separate variable (yr1990, yr1991, ...)
```stata
wbopendata, indicator(SP.POP.TOTL) clear
```

**Long format:** Year is a single variable with one row per country-year
```stata
wbopendata, indicator(SP.POP.TOTL) clear long
```

### Q: How do I get only the latest available value?

Use the `latest` option:
```stata
wbopendata, indicator(SP.POP.TOTL) clear long latest
```

### Q: How do I specify a year range?

Use the `year()` option:
```stata
* Years 2000-2020
wbopendata, indicator(SP.POP.TOTL) year(2000:2020) clear long
```

---

## Metadata & Updates

### Q: How do I update the indicator list?

```stata
* Check for updates
wbopendata, update check

* Download new indicator metadata
wbopendata, update all
```

### Q: I get "varlist not allowed" when running update

Make sure you have a clean Stata session:
```stata
clear all
wbopendata, update check
```

See [Issue #46](https://github.com/jpazvd/wbopendata/issues/46) - fixed in v17.1.

### Q: How do I suppress the metadata display?

Use the `nometadata` option:
```stata
wbopendata, indicator(SP.POP.TOTL) clear nometadata
```

---

## Error Messages

### Q: "Error when displaying metadata that contain a url link"

This was a parsing error with URLs in metadata. Fixed in v17.1.

See [Issue #45](https://github.com/jpazvd/wbopendata/issues/45).

### Q: "Option -latest- breaks when indicator names are too long"

Fixed in v17.1. Update to the latest version:
```stata
ssc install wbopendata, replace
```

See [Issue #33](https://github.com/jpazvd/wbopendata/issues/33).

### Q: match() option doesn't work as documented

The `match()` option cannot be combined with indicator download options. Use it separately:

```stata
* WRONG: This won't work
wbopendata, indicator(SP.POP.TOTL) match(countrycode) clear

* CORRECT: Use match separately on existing data
use mydata, clear
wbopendata, match(countrycode) full
```

See [Issue #51](https://github.com/jpazvd/wbopendata/issues/51) - fixed in v17.1.

---

## Still Have Questions?

- **Search existing issues**: [GitHub Issues](https://github.com/jpazvd/wbopendata/issues)
- **Open a new issue**: [New Issue](https://github.com/jpazvd/wbopendata/issues/new)
- **Check the help file**: `help wbopendata`

---

*Last updated: December 2025 (v17.1)*
