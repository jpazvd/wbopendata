/*******************************************************************************
* wbopendata: Advanced Usage Examples
* Version: 17.2
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
_linewrap, maxlength(90) longstring("Source: World Bank Open Data (wbopendata Stata package). Data: World Bank, UN, UNESCO. Variable codes: SP.DYN.LE00.IN, NY.GNP.PCAP.PP.CD")
local note1 `r(line1)'
local note2 `r(line2)'
twoway (scatter sp_dyn_le00_in ny_gnp_pcap_pp_cd if ny_gnp_pcap_pp_cd < 150000, msize(small) mcolor(blue%50)) ///
       (lfit sp_dyn_le00_in ny_gnp_pcap_pp_cd if ny_gnp_pcap_pp_cd < 150000, lcolor(red) lwidth(medium)), ///
       title("Life Expectancy vs. GNI per capita (2022)") ///
       ytitle("Life Expectancy at Birth (years)") ///
       xtitle("GNI per capita, PPP (current international $)") ///
       legend(off) ///
       note("`note1'" "`note2'")
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
_linewrap, maxlength(90) longstring("Source: World Bank Open Data (wbopendata Stata package). Data: World Bank. Variable code: SP.POP.TOTL")
local note1 `r(line1)'
local note2 `r(line2)'
graph bar sp_pop_totl if year==2022, over(regionname, sort(1) descending label(angle(45) labsize(small))) ///
    title("World Population by Region (2022)") ///
    ytitle("Population") ///
    blabel(bar, format(%12.0fc) size(vsmall)) ///
    note("`note1'" "`note2'")
graph export "output/figures/population_by_region.png", width(1200) replace

*===============================================================================
* EXAMPLE 4: Time series analysis
*===============================================================================

wbopendata, indicator(FP.CPI.TOTL.ZG) country(ARG;VEN;TUR;ZWE) ///
    year(2000:2023) clear long

* Time series plot with high-resolution export
_linewrap, maxlength(90) longstring("Source: World Bank Open Data (wbopendata Stata package). Data: IMF, World Bank. Variable code: FP.CPI.TOTL.ZG")
local note1 `r(line1)'
local note2 `r(line2)'
twoway (connected fp_cpi_totl_zg year if countrycode=="ARG", lcolor(blue) mcolor(blue)) ///
       (connected fp_cpi_totl_zg year if countrycode=="TUR", lcolor(red) mcolor(red)) ///
       (connected fp_cpi_totl_zg year if countrycode=="VEN", lcolor(green) mcolor(green)), ///
       title("Inflation Rates") ///
       ytitle("Inflation, consumer prices (annual %)") xtitle("Year") ///
       legend(label(1 "Argentina") label(2 "Turkey") label(3 "Venezuela") rows(1)) ///
       note("`note1'" "`note2'")
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
gen income_order = .
replace income_order = 1 if incomelevelname == "Low income"
replace income_order = 2 if incomelevelname == "Lower middle income"
replace income_order = 3 if incomelevelname == "Upper middle income"
replace income_order = 4 if incomelevelname == "High income"
label define incomeorder 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
label values income_order incomeorder

_linewrap, maxlength(90) longstring("Source: World Bank Open Data (wbopendata Stata package). Data: UNICEF, World Bank, UN IGME. Variable code: SH.DYN.MORT")
local note1 `r(line1)'
local note2 `r(line2)'
graph box sh_dyn_mort, over(income_order, label(angle(15) labsize(small))) ///
    title("Under-5 Mortality Rate by Income Group") ///
    ytitle("Mortality rate, under-5 (per 1,000 live births)") ///
    note("`note1'" "`note2'")
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
* EXAMPLE 11: Using linewrap for graph-ready metadata titles
*===============================================================================

* Download multiple indicators with linewrap option for graph-ready titles
* The linewrap() option wraps metadata text at specified character width
* Returns r(name1_stack), r(description1_stack), etc. for use in graph titles
wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 160)

* View wrapped metadata in return list
return list

* Create scatter plot using wrapped indicator names as axis titles
* Use description_stack for note and note_stack for source attribution
* NOTE: Use compound quotes to preserve the stacked format when assigning to locals
local xtit `"`r(name1_stack)'"'
local ytit `"`r(name2_stack)'"'
local desc1 `"`r(description1_stack)'"'
local desc2 `"`r(description2_stack)'"'
local note1 `"`r(note1_stack)'"'
local note2 `"`r(note2_stack)'"'

twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`xtit', size(small)) ///
    ytitle(`ytit', size(small)) ///
    title("Poverty and Child Mortality (Latest Available Year)") ///
    note("Description:" `desc1' `desc2' "" ///
         "Source:" `note1' `note2', size(vsmall))
capture mkdir "output/figures"
graph export "output/figures/poverty_mortality_scatter.png", width(1200) replace


*===============================================================================
* EXAMPLE 12: Multiple maxlength values for different field widths
*===============================================================================

* Download multiple indicators
wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest linewrap(name) maxlength(40)

* Get wrapped titles and clean source citations
local xtit `"`r(name1_stack)'"'
local ytit `"`r(name2_stack)'"'

* sourcecite gives clean org names:
* r(sourcecite1) = "World Bank"
* r(sourcecite2) = "UN Inter-agency Group for Child Mortality Estimation"

twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`xtit', size(small)) ///
    ytitle(`ytit', size(small)) ///
    title("Poverty and Child Mortality (Latest Available Year)") ///
    note("Sources: `r(sourcecite1)'; `r(sourcecite2)'", size(vsmall))

capture mkdir "output/figures"
graph export "output/figures/poverty_mortality_scatter-v2.png", width(1200) replace


*===============================================================================
* EXAMPLE 12: Multiple maxlength values for different field widths
*===============================================================================

* Use different character widths for different fields
* maxlength(40 100 80) with linewrap(name description note) means:
*   - name: 40 characters per line (short for axis titles)
*   - description: 100 characters per line (longer for notes)
*   - note: 80 characters per line (medium for footnotes)

wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 100 80)

return list


local K : word count `r(name)'

forvalues k = 1/`K' {

    di as txt "{hline 110}"
    di as res "Indicator: " as txt "`r(indicator`k')'"
    di as txt "{hline 110}"

    di as txt "Name:"
    local nlines : word count `r(name`k'_stack)'
    forvalues i = 1/`nlines' {
        local line : word `i' of `r(name`k'_stack)'
        di as res `"`line'"'
    }
    di as txt ""

    di as txt "Description:"
    local dlines : word count `r(description`k'_stack)'
    forvalues i = 1/`dlines' {
        local line : word `i' of `r(description`k'_stack)'
        di as res `"`line'"'
    }
    di as txt ""

    di as txt "Note:"
    * Wrapped (as you have now):
    local llines : word count `r(note`k'_stack)'
    forvalues i = 1/`llines' {
        local line : word `i' of `r(note`k'_stack)'
        di as res `"`line'"'
    }

    * OR clickable (uncomment instead of wrapped):
    * di in smcl `"`r(note`k')'"'
}

di as txt "{hline 110}"



* The name wraps at 40 chars (good for graph titles)
di as text "Name (40 chars):"
di `"`r(name1_stack)'"'

* The description wraps at 100 chars (good for subtitles/notes)
di as text "Description (100 chars):"
di `"`r(description1_stack)'"'

* The note wraps at 80 chars (medium width)
di as text "Note (80 chars):"
di `"`r(note1_stack)'"'

*===============================================================================
* EXAMPLE 13: Multiple maxlength values for different field widths
*===============================================================================

* If fewer maxlength values than fields, last value is used for remaining fields
wbopendata, indicator(SP.POP.TOTL) clear long latest ///
    linewrap(name description note source) maxlength(45 90)
*   - name: 45 characters
*   - description: 90 characters
*   - note: 90 characters (uses last value)
*   - source: 90 characters (uses last value)

return list


*===============================================================================
* EXAMPLE 14: Multiple maxlength values for different field widths
*===============================================================================

wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description) maxlength(40 80)

local xtit `r(name1_stack)'
local ytit `r(name2_stack)'
local d1   `r(description1_stack)'
local d2   `r(description2_stack)'
local src1 "`r(sourcecite1)'"
local src2 "`r(sourcecite2)'"

 
* Grab the stacked description lists
local d1 `r(description1_stack)'
local d2 `r(description2_stack)'

* Short sources (single line)
local src1 "World Bank (PIP)"
local src2 "UN IGME (childmortality.org)"

* Start note stringlist
local note_lines `"Definitions:" "X (SI.POV.DDAY):"'

* Append X description lines (clean)
foreach s of local d1 {
    local t : subinstr local s `"""' "", all
    local note_lines `"`note_lines' "`t'""'
}

* Add Y header
local note_lines `"`note_lines' "Y (SH.DYN.MORT):""'

* Append Y description lines (clean)
foreach s of local d2 {
    local t : subinstr local s `"""' "", all
    local note_lines `"`note_lines' "`t'""'
}

* Blank line + sources (kept as ONE element)
local note_lines `"`note_lines' " " "Sources: `src1'; `src2'""'

twoway ///
 (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
 xtitle("`r(name1)'", size(small)) ///
 ytitle("`r(name2)'", size(small)) ///
 title("Poverty and Child Mortality (Latest Available Year)") ///
 note(`note_lines')


capture mkdir "output/figures"
graph export "output/figures/poverty_mortality_scatter-v3.png", width(1200) replace


*===============================================================================
* EXAMPLE 15: Graph metadata with linewrap and dynamic subtitle
*===============================================================================
* Demonstrates using linewrap for wrapped metadata and r(latest_subtitle) for
* dynamic subtitle showing country count and average year

wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 180 180)

* Store all returns with compound quotes for multi-line text
local name1 `"`r(name1_stack)'"'
local name2 `"`r(name2_stack)'"'
local desc1 `"`r(description1_stack)'"'
local desc2 `"`r(description2_stack)'"'
local src1 "`r(sourcecite1)'"
local src2 "`r(sourcecite2)'"
local subtitle "`r(latest)'"

* Option A: caption for descriptions, note for sources (one line)
twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Indicator Descriptions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2', size(vsmall) span) ///
    note("Sources: `src1'; `src2'", size(vsmall))

graph export "output/figures/poverty_mortality_optionA.png", width(1200) replace

* Option D: caption for descriptions, note for separate sources per indicator
twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Definitions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2', size(vsmall) span) ///
    note("{bf:Data Sources:}" ///
         "{bf:X (Poverty):} `src1'" ///
         "{bf:Y (Mortality):} `src2'", size(vsmall))

graph export "output/figures/poverty_mortality_optionD.png", width(1200) replace


*===============================================================================
* End of advanced examples
*===============================================================================

di as text "All advanced examples completed successfully!"
