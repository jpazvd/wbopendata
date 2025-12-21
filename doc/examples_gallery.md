# wbopendata Examples Gallery

[← Back to README](../README.md) | [FAQ](FAQ.md) | [Do Files](examples/)

---

This gallery showcases `wbopendata` capabilities with the exact code used to generate the output figures.

**Version**: 17.1 | **Last Updated**: December 2025

> **Note**: Some examples require user-written commands (`spmap`, `alorenz`, `linewrap`). Install them with:
> ```stata
> ssc install spmap
> ssc install alorenz
> ```

---

## Table of Contents

1. [Example 7: World Map - Mobile Phone Coverage](#example-7-world-map---mobile-phone-coverage)
2. [Example 8: Poverty vs. Income (Single Country Highlight)](#example-8-poverty-vs-income-single-country-highlight)
3. [Example 9: Regional Poverty Reduction Episodes](#example-9-regional-poverty-reduction-episodes)
4. [Example 10: MDG Progress Tracking](#example-10-mdg-progress-tracking)
5. [Example 11: Poverty vs. Income (Regional Aggregates)](#example-11-poverty-vs-income-regional-aggregates)

---

## Example 7: World Map - Mobile Phone Coverage

Create a choropleth map of mobile cellular subscriptions per 100 people.

### Code

```stata
* Download latest mobile subscription data
qui tempfile tmp
wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest

* Store label and save data
local labelvar "`r(varlabel1)'"
sort countrycode
save `tmp', replace

* Merge with world shapefile
qui sysuse world-d, clear
qui merge countrycode using `tmp'

* Get average year for note
qui sum year
local avg = string(`r(mean)',"%16.1f")

* Create choropleth map
spmap it_cel_sets_p2 using "world-c.dta", id(_ID) ///
    clnumber(20) fcolor(Reds2) ocolor(none ..) ///
    title("`labelvar'", size(*1.2)) ///
    legstyle(3) legend(ring(1) position(3)) ///
    note("Source: World Development Indicators (latest available year: `avg') using Azevedo, J.P. (2011) wbopendata: Stata module to " ///
         "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.")
```

### Output

![Mobile Cellular Subscriptions Map](images/wbopendata_8.png)

*Figure 7: Mobile cellular subscriptions per 100 people (latest available year)*

---

## Example 8: Poverty vs. Income (Single Country Highlight)

Benchmark poverty levels against GDP per capita, highlighting a specific country.

### Code

```stata
* Download poverty and GDP per capita data
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

* Prepare axis labels using linewrap (user-written command)
linewrap, longstring("`r(varlabel1)'") maxlength(52) name(ylabel)
linewrap, longstring("`r(varlabel2)'") maxlength(52) name(xlabel)

* Create scatter plot with single country highlight and lowess fit
twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.2)) ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd if string(si_pov_dday) == "35.8", ///
        msize(*.8) mlabel(countryname)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd) ///
    if region != "NA", ///
    legend(off) ///
    xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
    ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///
    note("Source: `r(source1)' using WBOPENDATA")
```

### Output

![Poverty vs Income - Single Country](images/wbopendata_9.png)

*Figure 8: Poverty headcount ratio vs. GDP per capita with single country highlighted*

---

## Example 9: Regional Poverty Reduction Episodes

Analyze episodes of poverty reduction by region using Lorenz curves.

### Code

```stata
* Download poverty data
wbopendata, indicator(si.pov.dday) clear long

* Clean and prepare data
drop if si_pov_dday == .
sort countryname year

* Calculate annualized change in poverty
bysort countryname: gen diff_pov = (si_pov_dday - si_pov_dday[_n-1]) / (year - year[_n-1])

* Create encoded variables for labeling
encode region, gen(reg)
encode countryname, gen(reg2)

* Keep only regional aggregates
keep if regionname == "Aggregates"

* Create Lorenz curve of poverty reduction episodes
alorenz diff_pov, gp points(20) xdecrease markvar(reg2) ///
    ytitle("Change in Poverty (p.p.)") ///
    xtitle("Proportion of regional episodes of poverty reduction (%)") ///
    legend(off) ///
    title("Poverty Reduction") ///
    note("Source: World Development Indicators using Azevedo, J.P. (2011) wbopendata: Stata module to " ///
         "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
```

### Output

![Poverty Reduction Episodes](images/wbopendata_10.png)

*Figure 9: Distribution of poverty reduction episodes across regional aggregates*

---

## Example 10: MDG Progress Tracking

Benchmark Millennium Development Goal progress using 2008 as cutoff value.

### Code

```stata
* Download poverty data
wbopendata, indicator(si.pov.dday) clear long

* Clean data
drop if si_pov_dday == .
sort countryname year

* Keep only regional aggregates
keep if regionname == "Aggregates"

* Calculate change in poverty
bysort countryname: gen diff_pov = (si_pov_dday - si_pov_dday[_n-1]) / (year - year[_n-1])

* Set 1990 baseline
gen baseline = si_pov_dday if year == 1990
sort countryname baseline
bysort countryname: replace baseline = baseline[1] if baseline == .

* Calculate MDG target (halve 1990 poverty by 2015)
gen mdg1 = baseline / 2

* Get 2008 values
gen present = si_pov_dday if year == 2008
sort countryname present
bysort countryname: replace present = present[1] if present == .

* Calculate 2008 target based on linear path
gen target = ((baseline - mdg1) / (2008 - 1990)) * (2015 - 1990)

* Create 45-degree reference line
sort countryname year
gen angel45x = .
gen angle45y = .
replace angel45x = 0 in 1
replace angle45y = 0 in 1
replace angel45x = 80 in 2
replace angle45y = 80 in 2

* Create scatter plot with 45-degree line
graph twoway ///
    (scatter present target if year == 2008, mlabel(countrycode)) ///
    (line angle45y angel45x), ///
    legend(off) ///
    xtitle("Target for 2008") ///
    ytitle("Present") ///
    title("MDG 1 - 1.9 USD") ///
    note("Source: World Development Indicators (latest available year: 2008) using Azevedo, J.P. (2011) wbopendata: Stata module to " ///
         "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
```

### Output

![MDG Progress](images/wbopendata_11.png)

*Figure 10: MDG1 poverty reduction progress - countries above the 45° line are behind target*

---

## Example 11: Poverty vs. Income (Regional Aggregates)

Benchmark poverty levels against GDP per capita, highlighting regional averages.

### Code

```stata
* Download poverty and GDP data
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

* Store timestamp
local time "$S_FNDATE"

* Prepare axis labels
linewrap, longstring("`r(varlabel1)'") maxlength(52) name(ylabel)
linewrap, longstring("`r(varlabel2)'") maxlength(52) name(xlabel)

* Create scatter plot with regional aggregates labeled
graph twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd if regionname == "Aggregates", ///
        msize(*.8) mlabel(countryname) mlabsize(*.8) mlabangle(25)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd), ///
    legend(off) ///
    xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
    ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///
    note("Source: World Development Indicators (latest available year as off `time') using Azevedo, J.P. (2011) wbopendata: Stata" ///
         "module to access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
```

### Output

![Poverty vs Income - Regional](images/wbopendata_12.png)

*Figure 11: Poverty headcount ratio vs. GDP per capita with regional aggregates labeled*

---

## Additional Examples

For more examples including:
- Downloading by topic
- Downloading for specific countries
- Using the `match()` option for country metadata
- Year range selection
- Wide vs. long format

See the complete [wbopendata.md](wbopendata.md) documentation or the runnable [do files](examples/).

---

## Running These Examples

### Prerequisites

```stata
* Install required user-written commands
ssc install spmap      // for choropleth maps
ssc install alorenz    // for Lorenz curves
* linewrap may need to be obtained separately

* Ensure world shapefiles are available
* world-c.dta and world-d.dta are included with wbopendata
```

### From Command Line

```stata
* Run all examples
do "doc/examples/basic_usage.do"
do "doc/examples/advanced_usage.do"
```

---

## See Also

- [FAQ](FAQ.md) - Troubleshooting common issues
- [Do File Examples](examples/) - Runnable Stata code
- [Full Documentation](wbopendata.md) - Complete code output log
- [README](../README.md) - Main documentation

---

*Need more examples? [Open an issue](https://github.com/jpazvd/wbopendata/issues) with your use case!*
