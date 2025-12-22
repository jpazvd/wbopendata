/*******************************************************************************
* wbopendata: Advanced Usage Examples
* Version: 17.1
* Date: December 2025
* Author: João Pedro Azevedo
*
* Documentation: https://github.com/jpazvd/wbopendata
* See also: basic_usage.do, ../FAQ.md
*
* Output: Graphs saved to output/figures/, logs to output/logs/
*******************************************************************************/

clear all
set more off

* Set graph scheme for consistent styling
set scheme s2color

*===============================================================================
* EXAMPLE 1: Create panel dataset with multiple indicators
*===============================================================================

* Download key development indicators (long format creates separate columns)
wbopendata, indicator(NY.GDP.PCAP.CD;SP.DYN.LE00.IN;SE.ADT.LITR.ZS) ///
    country(BRA;CHN;IND;USA;DEU;JPN) year(2000:2022) clear long

* Variables are already in columns with lowercase names
describe
rename ny_gdp_pcap_cd gdp_pcap
rename sp_dyn_le00_in life_exp
rename se_adt_litr_zs literacy

* Panel setup
encode countrycode, gen(country_id)
xtset country_id year

* Panel regression
xtreg life_exp gdp_pcap, fe

*===============================================================================
* EXAMPLE 2: Cross-country comparison with visualization
*===============================================================================

* Download HDI-related indicators for specific year (not latest) to ensure consistent naming
wbopendata, indicator(SP.DYN.LE00.IN;NY.GNP.PCAP.PP.CD) ///
    year(2022) clear long

* Keep only individual countries
drop if regionname == "Aggregates"

* Create scatter plot with high-resolution export
twoway (scatter sp_dyn_le00_in ny_gnp_pcap_pp_cd if ny_gnp_pcap_pp_cd < 150000, msize(small) mcolor(blue%50)) ///
       (lfit sp_dyn_le00_in ny_gnp_pcap_pp_cd if ny_gnp_pcap_pp_cd < 150000, lcolor(red) lwidth(medium)), ///
       title("Life Expectancy vs. GNI per capita (2022)") ///
       ytitle("Life Expectancy at Birth (years)") ///
       xtitle("GNI per capita, PPP (current international $)") ///
       legend(off) \
       note("Source: World Bank Open Data (wbopendata Stata package). Data: World Bank, UN, UNESCO. Variable codes: SP.DYN.LE00.IN, NY.GNP.PCAP.PP.CD")
graph export "output/figures/life_exp_vs_gni.png", width(1200) replace

*===============================================================================
* EXAMPLE 3: Regional aggregation
*===============================================================================

wbopendata, indicator(SP.POP.TOTL) year(2020:2022) clear long

* Keep only countries (not aggregates)
drop if regionname == "Aggregates"

* Collapse by region
collapse (sum) sp_pop_totl, by(regionname year)

* Create bar chart with high-resolution export
graph bar sp_pop_totl if year==2022, over(regionname, sort(1) descending label(angle(45) labsize(small))) ///
    title("World Population by Region (2022)") ///
    ytitle("Population") ///
    blabel(bar, format(%12.0fc) size(vsmall)) \
    note("Source: World Bank Open Data (wbopendata Stata package). Data: World Bank. Variable code: SP.POP.TOTL")
graph export "output/figures/population_by_region.png", width(1200) replace

*===============================================================================
* EXAMPLE 4: Time series analysis
*===============================================================================

wbopendata, indicator(FP.CPI.TOTL.ZG) country(ARG;VEN;TUR;ZWE) ///
    year(2000:2023) clear long

* Time series plot with high-resolution export
twoway (connected fp_cpi_totl_zg year if countrycode=="ARG", lcolor(blue) mcolor(blue)) ///
       (connected fp_cpi_totl_zg year if countrycode=="TUR", lcolor(red) mcolor(red)) ///
       (connected fp_cpi_totl_zg year if countrycode=="VEN", lcolor(green) mcolor(green)), ///
       title("Inflation Rates") ///
       ytitle("Inflation, consumer prices (annual %)") xtitle("Year") ///
       legend(label(1 "Argentina") label(2 "Turkey") label(3 "Venezuela") rows(1)) \
       note("Source: World Bank Open Data (wbopendata Stata package). Data: IMF, World Bank. Variable code: FP.CPI.TOTL.ZG")
graph export "output/figures/inflation_rates.png", width(1200) replace

*===============================================================================
* EXAMPLE 5: Income group comparison
*===============================================================================

wbopendata, indicator(SH.DYN.MORT) clear long latest

* Add full country metadata
tempfile mortality
save `mortality'
wbopendata, match(countrycode) full
merge 1:m countrycode using `mortality', nogen

* Box plot by income level with high-resolution export
* Order income groups for sensible display
label define incomeorder 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
gen income_order = .
replace income_order = 1 if incomelevelname == "Low income"
replace income_order = 2 if incomelevelname == "Lower middle income"
replace income_order = 3 if incomelevelname == "Upper middle income"
replace income_order = 4 if incomelevelname == "High income"

graph box sh_dyn_mort, over(income_order, label(valuelabel angle(15) labsize(small))) ///
    title("Under-5 Mortality Rate by Income Group") ///
    ytitle("Mortality rate, under-5 (per 1,000 live births)") ///
    note("Source: World Bank Open Data (wbopendata Stata package). Data: UNICEF, World Bank, UN IGME. Variable code: SH.DYN.MORT")
graph export "output/figures/mortality_by_income.png", width(1200) replace


*===============================================================================
* EXAMPLE 6: Using return values
*===============================================================================

wbopendata, indicator(NY.GDP.MKTP.CD) clear nometadata

* Access return values
return list
di "Indicator: `r(indicator1)'"
di "Label: `r(varlabel1)'"
di "Countries: `r(N_country)'"

*===============================================================================
* EXAMPLE 7: Batch download multiple topics
*===============================================================================

* Create empty dataset to append results
clear
tempfile master
save `master', emptyok

* Loop through topics of interest (using year instead of latest - topics doesn't support latest)
foreach topic in 1 4 8 {
    wbopendata, topics(`topic') year(2022) clear long
    gen topic_id = `topic'
    append using `master'
    save `master', replace
}

* View combined dataset
use `master', clear
tab topic_id

*===============================================================================
* EXAMPLE 8: Creating maps (requires spmap)
*===============================================================================

/* Uncomment if you have spmap installed

* Download CO2 emissions
wbopendata, indicator(EN.ATM.CO2E.PC) clear long latest

* Merge with world shapefile (requires world-d.dta and world-c.dta)
tempfile emissions
save `emissions'
sysuse world-d, clear
merge m:1 countrycode using `emissions', nogen

* Create choropleth map
spmap en_atm_co2e_pc using "world-c.dta", id(_ID) ///
    clnumber(7) fcolor(Reds) ocolor(none ..) ///
    title("CO2 Emissions per Capita") ///
    legend(ring(1) position(3))
*/

*===============================================================================
* EXAMPLE 9: Programmatic indicator selection
*===============================================================================

* Define indicators in a local macro
local indicators "NY.GDP.MKTP.CD SP.POP.TOTL SP.DYN.LE00.IN"
local indicator_list ""
foreach ind of local indicators {
    local indicator_list "`indicator_list'`ind';"
}
* Remove trailing semicolon
local indicator_list = substr("`indicator_list'", 1, length("`indicator_list'")-1)

* Download
wbopendata, indicator(`indicator_list') clear long

*===============================================================================
* EXAMPLE 10: Export formatted tables
*===============================================================================

wbopendata, indicator(SI.POV.DDAY;SI.POV.LMIC;SI.POV.UMIC) ///
    country(BRA;CHN;IND;NGA;ETH) year(2015:2022) clear long

* Reshape for table format
reshape wide @, i(countrycode countryname) j(indicatorcode) string

* Format and export to output/data/
capture mkdir "output/data"
format *SI_POV* %5.1f
export excel countryname *SI_POV* using "output/data/poverty_table.xlsx", ///
    firstrow(varlabels) replace

*===============================================================================
* End of advanced examples
*===============================================================================

di as text "All advanced examples completed successfully!"
