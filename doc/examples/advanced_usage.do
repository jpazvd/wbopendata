/*******************************************************************************
* wbopendata: Advanced Usage Examples
* Version: 17.1
* Date: December 2025
* Author: João Pedro Azevedo
*******************************************************************************/

clear all
set more off

*===============================================================================
* EXAMPLE 1: Create panel dataset with multiple indicators
*===============================================================================

* Download key development indicators
wbopendata, indicator(NY.GDP.PCAP.CD;SP.DYN.LE00.IN;SE.ADT.LITR.ZS) ///
    country(BRA;CHN;IND;USA;DEU;JPN) year(2000:2022) clear long

* Reshape to have one row per country-year with all indicators as columns
reshape wide @, i(countrycode year) j(indicatorcode) string

* Rename for clarity
rename *NY_GDP_PCAP_CD* gdp_pcap
rename *SP_DYN_LE00_IN* life_exp
rename *SE_ADT_LITR_ZS* literacy

* Panel setup
encode countrycode, gen(country_id)
xtset country_id year

* Panel regression
xtreg life_exp gdp_pcap, fe

*===============================================================================
* EXAMPLE 2: Cross-country comparison with visualization
*===============================================================================

* Download HDI-related indicators
wbopendata, indicator(SP.DYN.LE00.IN;SE.XPD.TOTL.GD.ZS;NY.GNP.PCAP.PP.CD) ///
    clear long latest

* Keep only individual countries
drop if regionname == "Aggregates"

* Create scatter plot
twoway (scatter sp_dyn_le00_in ny_gnp_pcap_pp_cd, msize(small) mcolor(blue%50)) ///
       (lfit sp_dyn_le00_in ny_gnp_pcap_pp_cd, lcolor(red)), ///
       title("Life Expectancy vs. GNI per capita") ///
       ytitle("Life Expectancy at Birth (years)") ///
       xtitle("GNI per capita, PPP (current international $)") ///
       legend(off)

*===============================================================================
* EXAMPLE 3: Regional aggregation
*===============================================================================

wbopendata, indicator(SP.POP.TOTL) year(2020:2022) clear long

* Keep only countries (not aggregates)
drop if regionname == "Aggregates"

* Collapse by region
collapse (sum) sp_pop_totl, by(regionname year)

* Create bar chart
graph bar sp_pop_totl if year==2022, over(regionname, sort(1) descending label(angle(45))) ///
    title("World Population by Region (2022)") ///
    ytitle("Population") ///
    blabel(bar, format(%12.0fc))

*===============================================================================
* EXAMPLE 4: Time series analysis
*===============================================================================

wbopendata, indicator(FP.CPI.TOTL.ZG) country(ARG;VEN;TUR;ZWE) ///
    year(2000:2023) clear long

* Time series plot
twoway (connected fp_cpi_totl_zg year if countrycode=="ARG") ///
       (connected fp_cpi_totl_zg year if countrycode=="TUR") ///
       (connected fp_cpi_totl_zg year if countrycode=="VEN"), ///
       title("Inflation Rates") ///
       ytitle("Inflation, consumer prices (annual %)") ///
       legend(label(1 "Argentina") label(2 "Turkey") label(3 "Venezuela"))

*===============================================================================
* EXAMPLE 5: Income group comparison
*===============================================================================

wbopendata, indicator(SH.DYN.MORT) clear long latest

* Add full country metadata
tempfile mortality
save `mortality'
wbopendata, match(countrycode) full
merge 1:m countrycode using `mortality', nogen

* Box plot by income level
graph box sh_dyn_mort, over(incomelevelname) ///
    title("Under-5 Mortality Rate by Income Group") ///
    ytitle("Mortality rate, under-5 (per 1,000 live births)")

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

* Loop through topics of interest
foreach topic in 1 4 8 {
    wbopendata, topics(`topic') clear long latest
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
    country(BRA;CHN;IND;NGA;ETH) clear long latest

* Reshape for table format
reshape wide @, i(countrycode countryname) j(indicatorcode) string

* Format and export
format *SI_POV* %5.1f
export excel countryname *SI_POV* using "poverty_table.xlsx", ///
    firstrow(varlabels) replace

*===============================================================================
* End of advanced examples
*===============================================================================

di as text "All advanced examples completed successfully!"
