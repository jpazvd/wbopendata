# wbopendata Examples Gallery

[← Back to README](../../README.md) | [FAQ](../FAQ.md) | [Do Files](../examples/)

---

This gallery showcases `wbopendata` capabilities with code snippets and output visualizations.

**Version**: 17.1 | **Last Updated**: December 2025

---

## Table of Contents

1. [Quick Start Examples](#quick-start-examples)
2. [Data Visualization](#data-visualization)
3. [Working with Multiple Indicators](#working-with-multiple-indicators)
4. [Country Metadata](#country-metadata)
5. [Advanced Analysis](#advanced-analysis)

---

## Quick Start Examples

### Example 1: Download a Single Indicator

Download GDP data for all countries:

```stata
wbopendata, indicator(NY.GDP.MKTP.CD) clear
```

**Output:**
```
Metadata: NY.GDP.MKTP.CD
---------------------------------------------------------------------------------------
    Name: GDP (current US$)
    Source: World Development Indicators
    Topics: Economy & Growth
---------------------------------------------------------------------------------------
```

| countrycode | countryname | yr2020 | yr2021 | yr2022 |
|-------------|-------------|--------|--------|--------|
| USA | United States | 21.06T | 23.32T | 25.46T |
| CHN | China | 14.72T | 17.73T | 17.96T |
| JPN | Japan | 5.04T | 4.94T | 4.23T |

---

### Example 2: Multiple Countries, Long Format

Download population data for BRICS countries in long format:

```stata
wbopendata, indicator(SP.POP.TOTL) country(BRA;RUS;IND;CHN;ZAF) clear long
```

**Output Structure:**
```
    Variable |  Type   | Description
-------------+---------+--------------------------------
 countrycode |  str3   | Country code (ISO 3166-1 alpha-3)
 countryname |  str50  | Country name
        year |  int    | Year
 sp_pop_totl |  double | Population, total
```

---

### Example 3: Specific Year Range

Download life expectancy for 2010-2020:

```stata
wbopendata, indicator(SP.DYN.LE00.IN) year(2010:2020) clear long
```

---

### Example 4: Latest Available Value

Get only the most recent data point for each country:

```stata
wbopendata, indicator(SI.POV.DDAY) clear long latest
```

This is useful for cross-sectional analysis where you want the most recent observation per country.

---

## Data Visualization

### Example 5: World Map - Mobile Phone Coverage

Create a choropleth map of mobile cellular subscriptions:

```stata
* Download latest data
wbopendata, indicator(IT.CEL.SETS.P2) long clear latest
local labelvar "`r(varlabel1)'"

* Merge with world shapefile
tempfile tmp
save `tmp', replace
sysuse world-d, clear
merge m:1 countrycode using `tmp', nogen

* Create map
spmap it_cel_sets_p2 using "world-c.dta", id(_ID) ///
    clnumber(20) fcolor(Reds2) ocolor(none ..) ///
    title("`labelvar'", size(*1.2)) ///
    legstyle(3) legend(ring(1) position(3))
```

**Output:**

![Mobile Cellular Subscriptions Map](../images/wbopendata_8.png)

*Figure 1: Mobile cellular subscriptions per 100 people (latest available year)*

---

### Example 6: Scatter Plot - Poverty vs. Income

Benchmark poverty levels against GDP per capita:

```stata
* Download poverty and GDP data
wbopendata, indicator(SI.POV.DDAY;NY.GDP.PCAP.PP.KD) clear long latest

* Create scatter plot with lowess fit
twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd, lcolor(red)) ///
    if region != "NA", ///
    legend(off) ///
    ytitle("Poverty headcount ratio at $1.90/day (%)") ///
    xtitle("GDP per capita, PPP (constant 2017 int'l $)") ///
    title("Poverty vs. Income Relationship")
```

**Output:**

![Poverty vs Income](../images/wbopendata_9.png)

*Figure 2: Poverty headcount ratio vs. GDP per capita across countries*

---

### Example 7: Regional Poverty Trends

Analyze episodes of poverty reduction by region:

```stata
wbopendata, indicator(SI.POV.DDAY) clear long

* Calculate poverty change
drop if si_pov_dday == .
bysort countryname (year): gen diff_pov = (si_pov_dday - si_pov_dday[_n-1]) / (year - year[_n-1])

* Keep regional aggregates
keep if regionname == "Aggregates"

* Visualize distribution of poverty reduction episodes
alorenz diff_pov, points(100) fullview xdecrease ///
    ytitle("Change in Poverty (p.p.)") ///
    xtitle("Proportion of regional episodes (%)") ///
    title("Poverty Reduction Episodes")
```

**Output:**

![Poverty Reduction Episodes](../images/wbopendata_10.png)

*Figure 3: Distribution of poverty reduction episodes across regions*

---

## Working with Multiple Indicators

### Example 8: Download Multiple Indicators

Download GDP, population, and CO2 emissions in one call:

```stata
wbopendata, indicator(NY.GDP.MKTP.CD;SP.POP.TOTL;EN.ATM.CO2E.KT) clear long
```

**Output:**
```
. tab indicatorcode

     Indicator Code |      Freq.     Percent        Cum.
--------------------+-----------------------------------
    EN.ATM.CO2E.KT  |     16,320       33.33       33.33
    NY.GDP.MKTP.CD  |     16,320       33.33       66.67
       SP.POP.TOTL  |     16,320       33.33      100.00
--------------------+-----------------------------------
              Total |     48,960      100.00
```

### Example 9: Reshape Multiple Indicators

Convert from long to wide for panel analysis:

```stata
* Download multiple indicators
wbopendata, indicator(NY.GDP.PCAP.CD;SP.DYN.LE00.IN;SE.ADT.LITR.ZS) ///
    country(BRA;CHN;IND;USA) year(2000:2020) clear long

* Reshape to have indicators as columns
reshape wide @, i(countrycode year) j(indicatorcode) string

* Panel setup
encode countrycode, gen(country_id)
xtset country_id year

* Now ready for panel regression
xtreg *LE00* *PCAP*, fe
```

---

## Country Metadata

### Example 10: Add Country Attributes

Merge country metadata into an existing dataset:

```stata
* Create sample dataset with country codes
clear
input str3 countrycode value
"USA" 100
"BRA" 50
"CHN" 75
"IND" 60
"NGA" 30
end

* Add country attributes
wbopendata, match(countrycode) full

* View added variables
list countrycode regionname incomelevelname value
```

**Output:**
```
     +--------------------------------------------------------+
     | country~e   regionname          incomelevelname   value |
     |--------------------------------------------------------|
  1. |      USA   North America        High income         100 |
  2. |      BRA   Latin America & C..  Upper middle in..    50 |
  3. |      CHN   East Asia & Pacific  Upper middle in..    75 |
  4. |      IND   South Asia           Lower middle in..    60 |
  5. |      NGA   Sub-Saharan Africa   Lower middle in..    30 |
     +--------------------------------------------------------+
```

---

## Advanced Analysis

### Example 11: MDG Tracking

Track Millennium Development Goal progress:

```stata
wbopendata, indicator(SI.POV.DDAY) clear long

* Keep regional aggregates
keep if regionname == "Aggregates"

* Calculate MDG baseline and target
gen baseline = si_pov_dday if year == 1990
bysort countryname (baseline): replace baseline = baseline[1]
gen mdg_target = baseline / 2

* Check progress
gen current = si_pov_dday if year == 2015
gen achieved = (current <= mdg_target)
```

**Output:**

![MDG Progress](../images/wbopendata_11.png)

*Figure 4: MDG1 poverty reduction progress by region*

---

### Example 12: Time Series Visualization

Create time series plots of regional trends:

```stata
wbopendata, indicator(SP.DYN.LE00.IN) clear long

* Keep regional aggregates
keep if regionname == "Aggregates"

* Plot life expectancy trends
twoway (connected sp_dyn_le00_in year if countryname == "East Asia & Pacific") ///
       (connected sp_dyn_le00_in year if countryname == "Sub-Saharan Africa") ///
       (connected sp_dyn_le00_in year if countryname == "World"), ///
       legend(label(1 "East Asia") label(2 "Sub-Saharan Africa") label(3 "World")) ///
       title("Life Expectancy at Birth") ytitle("Years")
```

**Output:**

![Life Expectancy Trends](../images/wbopendata_12.png)

*Figure 5: Life expectancy trends by region*

---

## Running the Examples

### From Do Files

```stata
* Basic examples
do "doc/examples/basic_usage.do"

* Advanced examples
do "doc/examples/advanced_usage.do"
```

### From Stata Command Line

```stata
* Type help for built-in examples
help wbopendata
```

---

## See Also

- [Do File Examples](../examples/) - Runnable Stata code
- [FAQ](../FAQ.md) - Troubleshooting
- [Full Documentation](../wbopendata.md) - Complete code output log

---

*Need more examples? [Open an issue](https://github.com/jpazvd/wbopendata/issues) with your use case!*
