<<dd_version: 2>>
<<dd_include: header.txt>>

# wbopendata Example Output

[← Back to Examples](README.md) | [Examples Gallery](../examples_gallery.md) | [FAQ](../FAQ.md)

---

*This document was automatically generated using Stata's `dyndoc` command.*  
*Generated on: <<dd_display: c(current_date)>> at <<dd_display: c(current_time)>>*

---

## Basic Examples

### Example 1: Download a Single Indicator

Download GDP (current US$) for all countries in wide format:

~~~~
<<dd_do>>
wbopendata, indicator(NY.GDP.MKTP.CD) clear
<</dd_do>>
~~~~

**Data Structure:**

~~~~
<<dd_do>>
describe, short
<</dd_do>>
~~~~

**Sample Data:**

~~~~
<<dd_do>>
list countrycode countryname yr2022 yr2023 in 1/5, clean
<</dd_do>>
~~~~

---

### Example 2: Download Multiple Indicators (Long Format)

Download GDP, Population, and Primary enrollment rate in long format:

~~~~
<<dd_do>>
wbopendata, indicator(NY.GDP.MKTP.CD;SP.POP.TOTL) clear long nometadata
<</dd_do>>
~~~~

**Data Structure:**

~~~~
<<dd_do>>
describe, short
<</dd_do>>
~~~~

> **Note:** In long format, each indicator becomes a separate variable with a lowercase name 
> and underscores (e.g., `ny_gdp_mktp_cd` instead of `NY.GDP.MKTP.CD`).

---

### Example 3: Download for Specific Countries with Graph

Download GDP per capita for BRICS countries:

~~~~
<<dd_do>>
wbopendata, indicator(NY.GDP.PCAP.CD) country(BRA;CHN;IND) clear long nometadata
<</dd_do>>
~~~~

**GDP per Capita Trends:**

<<dd_do: quietly>>
twoway (line ny_gdp_pcap_cd year if countrycode=="BRA", lcolor(green) lwidth(medium)) ///
       (line ny_gdp_pcap_cd year if countrycode=="CHN", lcolor(red) lwidth(medium)) ///
       (line ny_gdp_pcap_cd year if countrycode=="IND", lcolor(orange) lwidth(medium)), ///
       legend(label(1 "Brazil") label(2 "China") label(3 "India") rows(1)) ///
       title("GDP per Capita") subtitle("Selected Countries") ///
       ytitle("USD") xtitle("Year") ///
       scheme(s2color)
<</dd_do>>

<<dd_graph: saving("output/figures/gdp_per_capita.png") width(800) replace>>

![GDP per Capita](output/figures/gdp_per_capita.png)

---

### Example 4: Get Latest Available Value

Download the latest poverty headcount ratio:

~~~~
<<dd_do>>
wbopendata, indicator(SI.POV.DDAY) clear long latest nometadata
<</dd_do>>
~~~~

**Countries with Poverty Data:**

~~~~
<<dd_do>>
count if si_pov_dday != .
list countrycode countryname year si_pov_dday if si_pov_dday != . in 1/10, clean
<</dd_do>>
~~~~

---

## Advanced Examples

### Example 5: Cross-Country Comparison with Scatter Plot

Download life expectancy and GNI per capita:

~~~~
<<dd_do>>
wbopendata, indicator(SP.DYN.LE00.IN;NY.GNP.PCAP.PP.CD) clear long latest nometadata
drop if regionname == "Aggregates"
<</dd_do>>
~~~~

**Life Expectancy vs. GNI per Capita:**

<<dd_do: quietly>>
twoway (scatter sp_dyn_le00_in ny_gnp_pcap_pp_cd if ny_gnp_pcap_pp_cd < 100000, ///
        msize(small) mcolor(blue%50)) ///
       (lfit sp_dyn_le00_in ny_gnp_pcap_pp_cd if ny_gnp_pcap_pp_cd < 100000, ///
        lcolor(red) lwidth(medium)), ///
       title("Life Expectancy vs. GNI per Capita") ///
       ytitle("Life Expectancy at Birth (years)") ///
       xtitle("GNI per capita, PPP (current international $)") ///
       legend(off) scheme(s2color)
<</dd_do>>

<<dd_graph: saving("output/figures/life_exp_vs_gni.png") width(800) replace>>

![Life Expectancy vs GNI](output/figures/life_exp_vs_gni.png)

---

### Example 6: Regional Population

Download population and aggregate by region:

~~~~
<<dd_do>>
wbopendata, indicator(SP.POP.TOTL) year(2022:2022) clear long nometadata
drop if regionname == "Aggregates"
collapse (sum) sp_pop_totl, by(regionname)
format sp_pop_totl %15.0fc
list, clean
<</dd_do>>
~~~~

**Population by Region:**

<<dd_do: quietly>>
graph bar sp_pop_totl, over(regionname, sort(1) descending label(angle(45) labsize(small))) ///
    title("World Population by Region (2022)") ///
    ytitle("Population") ///
    blabel(bar, format(%12.0fc) size(vsmall)) ///
    scheme(s2color)
<</dd_do>>

<<dd_graph: saving("output/figures/population_by_region.png") width(900) replace>>

![Population by Region](output/figures/population_by_region.png)

---

### Example 7: Inflation Time Series

Download inflation rates for high-inflation countries:

~~~~
<<dd_do>>
wbopendata, indicator(FP.CPI.TOTL.ZG) country(ARG;TUR;BRA) ///
    year(2010:2023) clear long nometadata
<</dd_do>>
~~~~

**Inflation Trends:**

<<dd_do: quietly>>
twoway (connected fp_cpi_totl_zg year if countrycode=="ARG", lcolor(blue) mcolor(blue)) ///
       (connected fp_cpi_totl_zg year if countrycode=="TUR", lcolor(red) mcolor(red)) ///
       (connected fp_cpi_totl_zg year if countrycode=="BRA", lcolor(green) mcolor(green)), ///
       title("Inflation Rates") ///
       ytitle("Inflation, consumer prices (annual %)") xtitle("Year") ///
       legend(label(1 "Argentina") label(2 "Turkey") label(3 "Brazil") rows(1)) ///
       scheme(s2color)
<</dd_do>>

<<dd_graph: saving("output/figures/inflation_rates.png") width(800) replace>>

![Inflation Rates](output/figures/inflation_rates.png)

---

### Example 8: Income Group Box Plot

Download under-5 mortality and compare by income group:

~~~~
<<dd_do>>
wbopendata, indicator(SH.DYN.MORT) clear long latest nometadata
drop if regionname == "Aggregates"
drop if incomelevelname == ""
<</dd_do>>
~~~~

**Mortality by Income Group:**

<<dd_do: quietly>>
graph box sh_dyn_mort, over(incomelevelname, label(angle(15) labsize(small))) ///
    title("Under-5 Mortality Rate by Income Group") ///
    ytitle("Mortality rate, under-5 (per 1,000 live births)") ///
    scheme(s2color)
<</dd_do>>

<<dd_graph: saving("output/figures/mortality_by_income.png") width(800) replace>>

![Mortality by Income](output/figures/mortality_by_income.png)

---

## Variable Reference

### Wide Format Variables

| Variable | Description |
|----------|-------------|
| `countrycode` | ISO3 country code |
| `countryname` | Full country name |
| `regionname` | World Bank region |
| `incomelevelname` | Income classification |
| `indicatorcode` | Indicator code |
| `indicatorname` | Indicator name |
| `yr1960`...`yr2024` | Values by year |

### Long Format Variables

| Variable | Description |
|----------|-------------|
| `countrycode` | ISO3 country code |
| `countryname` | Full country name |
| `year` | Year of observation |
| `{indicator}` | Indicator value (lowercase, underscores) |

---

## Regenerating This Document

To regenerate this document with fresh data:

```stata
cd "C:/GitHub/myados/wbopendata/doc/examples"
dyndoc "examples_dyndoc.do", saving("examples_output.md") replace
```

---

*Last updated: <<dd_display: c(current_date)>> (v17.1)*
