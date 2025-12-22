# wbopendata Example Output

[← Back to Examples](README.md) | [Examples Gallery](../examples_gallery.md) | [FAQ](../FAQ.md)

---

This document shows actual output from running the example do-files. For the complete logs, see:
- [basic_usage_log.txt](output/basic_usage_log.txt)
- [advanced_usage_log.txt](output/advanced_usage_log.txt)

---

## Basic Examples

### Example 1: Download a Single Indicator

**Command:**
```stata
wbopendata, indicator(NY.GDP.MKTP.CD) clear
```

**Output:**
```
    Metadata for indicator NY.GDP.MKTP.CD
--------------------------------------------------------------------------------
    Name: GDP (current US$)
--------------------------------------------------------------------------------
    Collection: 2 World Development Indicators
--------------------------------------------------------------------------------
    Description: Gross domestic product is the total income earned through 
    the production of goods and services in an economic territory during an 
    accounting period. It can be measured in three different ways: using 
    either the expenditure approach, the income approach, or the production 
    approach. This indicator is expressed in current prices, meaning no 
    adjustment has been made to account for price changes over time. This 
    indicator is expressed in United States dollars.
--------------------------------------------------------------------------------
    Note: Country official statistics, National Statistical Organizations 
    and or Central Banks;
--------------------------------------------------------------------------------
    Topic(s): 3 Economy and Growth
--------------------------------------------------------------------------------
```

**Data Structure (Wide Format):**
```
Contains data
 Observations:           266                  
    Variables:            77                  

Variable      Storage   Display    Variable label
    name         type    format    
--------------------------------------------------------------------------------
countrycode     str3    %9s        Country Code
countryname     str75   %75s       Country Name
region          str3    %9s        Region Code
regionname      str51   %51s       Region Name
incomelevel     str3    %9s        Income Level Code
incomelevelname str19   %19s       Income Level Name
indicatorname   str17   %17s       Indicator Name
indicatorcode   str14   %14s       Indicator Code
yr1960          double  %10.0g     1960
yr1961          double  %10.0g     1961
...
yr2023          double  %10.0g     2023
yr2024          double  %10.0g     2024
--------------------------------------------------------------------------------
```

---

### Example 2: Download Multiple Indicators (Long Format)

**Command:**
```stata
wbopendata, indicator(NY.GDP.MKTP.CD;SP.POP.TOTL;SE.PRM.ENRR) clear long
```

**Data Structure (Long Format):**
```
Contains data
 Observations:        17,290                  
    Variables:            14

Variable        Storage   Variable label
    name           type    
--------------------------------------------------------------------------------
countrycode     str3      Country Code
countryname     str75     Country Name
region          str3      Region Code
regionname      str51     Region Name
adminregion     str3      Administrative Region Code
adminregionname str75     Administrative Region Name
incomelevel     str3      Income Level Code
incomelevelname str19     Income Level Name
lendingtype     str3      Lending Type Code
lendingtypename str14     Lending Type Name
year            int       Year
ny_gdp_mktp_cd  double    NY.GDP.MKTP.CD
sp_pop_totl     double    SP.POP.TOTL
se_prm_enrr     float     SE.PRM.ENRR
--------------------------------------------------------------------------------
Sorted by: countrycode year
```

> **Note:** In long format, each indicator becomes a separate variable with a lowercase name and underscores (e.g., `ny_gdp_mktp_cd` instead of `NY.GDP.MKTP.CD`).

---

### Example 3: Download for Specific Countries

**Command:**
```stata
wbopendata, indicator(NY.GDP.PCAP.CD) country(BRA;RUS;IND;CHN;ZAF) clear long
```

**Graph Output:**

![GDP per capita - BRICS](output/gdp_per_capita_brics.png)

*Graph shows GDP per capita trends for Brazil, China, and India.*

---

## Advanced Examples

### Example 1: Create Panel Dataset

**Command:**
```stata
wbopendata, indicator(NY.GDP.PCAP.CD;SP.DYN.LE00.IN;SE.ADT.LITR.ZS) ///
    country(BRA;CHN;IND;USA;DEU;JPN) year(2000:2022) clear long

* Rename variables
rename ny_gdp_pcap_cd gdp_pcap
rename sp_dyn_le00_in life_exp
rename se_adt_litr_zs literacy

* Panel setup
encode countrycode, gen(country_id)
xtset country_id year

* Panel regression
xtreg life_exp gdp_pcap, fe
```

**Regression Output:**
```
Fixed-effects (within) regression               Number of obs     =        138
Group variable: country_id                      Number of groups  =          6

R-sq:                                           Obs per group:
     within  = 0.XXXX                                         min =         23
     between = 0.XXXX                                         max =         23
     overall = 0.XXXX                                         avg =       23.0

                                                F(1,131)          =      XX.XX
corr(u_i, Xb)  = X.XXXX                         Prob > F          =     0.0000

------------------------------------------------------------------------------
    life_exp |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    gdp_pcap |   .XXXXXXX   .XXXXXXX    XX.XX   0.000     .XXXXXXX    .XXXXXXX
       _cons |   XX.XXXXX   X.XXXXXX    XX.XX   0.000     XX.XXXXX    XX.XXXXX
-------------+----------------------------------------------------------------
     sigma_u |  X.XXXXXXX
     sigma_e |  X.XXXXXXX
         rho |  .XXXXXXXX   (fraction of variance due to u_i)
------------------------------------------------------------------------------
```

---

### Example 2: Cross-Country Visualization

**Command:**
```stata
wbopendata, indicator(SP.DYN.LE00.IN;SE.XPD.TOTL.GD.ZS;NY.GNP.PCAP.PP.CD) ///
    clear long latest

drop if regionname == "Aggregates"

twoway (scatter sp_dyn_le00_in ny_gnp_pcap_pp_cd, msize(small) mcolor(blue%50)) ///
       (lfit sp_dyn_le00_in ny_gnp_pcap_pp_cd, lcolor(red)), ///
       title("Life Expectancy vs. GNI per capita") ///
       ytitle("Life Expectancy at Birth (years)") ///
       xtitle("GNI per capita, PPP (current international $)")
```

**Graph Output:**

![Life Expectancy vs GNI](output/life_exp_vs_gni.png)

---

### Example 3: Regional Aggregation

**Command:**
```stata
wbopendata, indicator(SP.POP.TOTL) year(2020:2022) clear long
drop if regionname == "Aggregates"
collapse (sum) sp_pop_totl, by(regionname year)

graph bar sp_pop_totl if year==2022, over(regionname, sort(1) descending) ///
    title("World Population by Region (2022)")
```

**Graph Output:**

![Population by Region](output/population_by_region.png)

---

### Example 4: Time Series Analysis

**Command:**
```stata
wbopendata, indicator(FP.CPI.TOTL.ZG) country(ARG;VEN;TUR;ZWE) ///
    year(2000:2023) clear long

twoway (connected fp_cpi_totl_zg year if countrycode=="ARG") ///
       (connected fp_cpi_totl_zg year if countrycode=="TUR") ///
       (connected fp_cpi_totl_zg year if countrycode=="VEN"), ///
       title("Inflation Rates") ///
       legend(label(1 "Argentina") label(2 "Turkey") label(3 "Venezuela"))
```

**Graph Output:**

![Inflation Rates](output/inflation_rates.png)

---

### Example 5: Income Group Comparison

**Command:**
```stata
wbopendata, indicator(SH.DYN.MORT) clear long latest

graph box sh_dyn_mort, over(incomelevelname) ///
    title("Under-5 Mortality Rate by Income Group")
```

**Graph Output:**

![Mortality by Income](output/mortality_by_income.png)

---

## Indicator Metadata Display

When downloading data, wbopendata displays metadata for each indicator:

```
    Metadata for indicator SP.DYN.LE00.IN
--------------------------------------------------------------------------------
    Name: Life expectancy at birth, total (years)
--------------------------------------------------------------------------------
    Collection: 2 World Development Indicators
--------------------------------------------------------------------------------
    Description: Life expectancy at birth indicates the number of years a 
    newborn infant would live if prevailing patterns of mortality at the 
    time of its birth were to stay the same throughout its life.
--------------------------------------------------------------------------------
    Note: World Population Prospects, United Nations (UN)
--------------------------------------------------------------------------------
    Topic(s): 8 Health
--------------------------------------------------------------------------------
```

To suppress this display, use the `nometadata` option:

```stata
wbopendata, indicator(SP.DYN.LE00.IN) clear nometadata
```

---

## Common Variable Names

| Wide Format | Long Format Variable | Description |
|-------------|---------------------|-------------|
| `yr1960`...`yr2024` | `year` | Year of observation |
| `indicatorcode` | (column name) | Indicator code |
| `indicatorname` | (variable label) | Indicator name |
| `countrycode` | `countrycode` | ISO3 country code |
| `countryname` | `countryname` | Country name |
| `regionname` | `regionname` | World Bank region |
| `incomelevelname` | `incomelevelname` | Income classification |

---

## Regenerating This Documentation

To regenerate the logs and graphs:

```stata
cd "C:/GitHub/myados/wbopendata/doc/examples"
do "run_examples.do"
```

---

*Last updated: December 2025 (v17.1)*
