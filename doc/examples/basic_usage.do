/*******************************************************************************
* wbopendata: Basic Usage Examples
* Version: 17.1
* Date: December 2025
* Author: João Pedro Azevedo
*******************************************************************************/

clear all
set more off

*===============================================================================
* EXAMPLE 1: Download a single indicator for all countries
*===============================================================================

* GDP (current US$) for all countries, wide format
wbopendata, indicator(NY.GDP.MKTP.CD) clear

* View the data
describe
list countrycode countryname yr2020 yr2021 yr2022 in 1/10

*===============================================================================
* EXAMPLE 2: Download multiple indicators
*===============================================================================

* GDP, Population, and Primary enrollment rate
wbopendata, indicator(NY.GDP.MKTP.CD;SP.POP.TOTL;SE.PRM.ENRR) clear long

* View structure
describe
tab indicatorcode

*===============================================================================
* EXAMPLE 3: Download for specific countries
*===============================================================================

* BRICS countries - GDP per capita
wbopendata, indicator(NY.GDP.PCAP.CD) country(BRA;RUS;IND;CHN;ZAF) clear long

* Simple line graph
twoway (line ny_gdp_pcap_cd year if countrycode=="BRA", lcolor(green)) ///
       (line ny_gdp_pcap_cd year if countrycode=="CHN", lcolor(red)) ///
       (line ny_gdp_pcap_cd year if countrycode=="IND", lcolor(orange)), ///
       legend(label(1 "Brazil") label(2 "China") label(3 "India")) ///
       title("GDP per capita") ytitle("USD") xtitle("Year")

*===============================================================================
* EXAMPLE 4: Download by topic
*===============================================================================

* All Education indicators (Topic 4)
wbopendata, topics(4) clear long
tab indicatorcode, sort

*===============================================================================
* EXAMPLE 5: Get latest available value only
*===============================================================================

* Latest poverty headcount ratio
wbopendata, indicator(SI.POV.DDAY) clear long latest

* List countries with data
list countrycode countryname year si_pov_dday if si_pov_dday != .

*===============================================================================
* EXAMPLE 6: Specify year range
*===============================================================================

* Life expectancy 2000-2020
wbopendata, indicator(SP.DYN.LE00.IN) year(2000:2020) clear long

summarize sp_dyn_le00_in
table year, stat(mean sp_dyn_le00_in) stat(sd sp_dyn_le00_in)

*===============================================================================
* EXAMPLE 7: Add country metadata (match option)
*===============================================================================

* First create a dataset with country codes
clear
input str3 countrycode value
"USA" 100
"BRA" 50
"CHN" 75
"IND" 60
end

* Add country attributes
wbopendata, match(countrycode) full

* View added variables
describe
list

*===============================================================================
* EXAMPLE 8: Suppress metadata display
*===============================================================================

* Download without showing metadata in results window
wbopendata, indicator(SP.POP.TOTL) clear nometadata

*===============================================================================
* EXAMPLE 9: Filter countries vs aggregates
*===============================================================================

wbopendata, indicator(SP.POP.TOTL) clear long

* Keep only individual countries (drop regional aggregates)
tab regionname
keep if regionname != "Aggregates"

* Alternative: keep only countries with a non-empty region
* drop if region == ""

*===============================================================================
* EXAMPLE 10: Export to different formats
*===============================================================================

wbopendata, indicator(NY.GDP.MKTP.CD) clear long

* Export to CSV
export delimited using "gdp_data.csv", replace

* Export to Excel
export excel using "gdp_data.xlsx", firstrow(variables) replace

* Save as Stata format
save "gdp_data.dta", replace

*===============================================================================
* End of examples
*===============================================================================

di as text "All examples completed successfully!"
