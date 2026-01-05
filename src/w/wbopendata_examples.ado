*! -wbopendata_examples-: Auxiliary program for -wbopendata-
*! Version 1.3.0 - 04 January 2026
*! Version 1.2.0 - 28  March 2010
*! Version 1.0.0 - 24 January 2010
*! Author: Joao Pedro Azevedo
*! World Bank

*  ----------------------------------------------------------------------------
*  1. Main program
*  ----------------------------------------------------------------------------

capture program drop wbopendata_examples
program wbopendata_examples
version 9.2
args EXAMPLE
set more off
`EXAMPLE'
end


*  ----------------------------------------------------------------------------
*  2. Choropleth maps
*  ----------------------------------------------------------------------------

capture program drop example01
program example01
    * Get shapefile paths from ado/plus/w
    local world_d "`c(sysdir_plus)'w/world-d.dta"
    local world_c "`c(sysdir_plus)'w/world-c.dta"
    
    qui tempfile tmp
    wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest
    local labelvar "`r(varlabel1)'"
    sort countrycode
    save `tmp', replace
    qui use "`world_d'", clear
    qui merge countrycode using `tmp'
    qui sum year
    local avg = string(`r(mean)',"%16.1f")
    spmap  it_cel_sets_p2 using "`world_c'", id(_ID)                                   ///
            clnumber(20) fcolor(Reds2) ocolor(none ..)                                  ///
            title("`labelvar'", size(*1.2))                                            ///
            legstyle(3) legend(ring(1) position(3))                                     ///
            note("Source: World Development Indicators (latest available year: `avg') using  Azevedo, J.P. (2026) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.")
end

*  ----------------------------------------------------------------------------
*  3. alorenz
*  ----------------------------------------------------------------------------

capture program drop example02
program example02
    wbopendata, indicator(si.pov.dday ) clear long
    drop if  si_pov_dday == .
    sort  countryname year
    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
    encode region, gen(reg)
    encode countryname, gen(reg2)
    keep if regionname == "Aggregates"
    alorenz diff_pov, gp points(100) fullview  xdecrease markvar(reg2)                                           ///
        ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional episodes of poverty reduction (%)")   ///
        legend(off) title("Poverty Reduction")     ///
        mlabangle(45) ///                                                 ///
        legend(off) note("Source: World Development Indicators using Azevedo, J.P. (2026) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
end

*  ----------------------------------------------------------------------------
*  4. mdg
*  ----------------------------------------------------------------------------

capture program drop example03
program example03
    wbopendata, indicator(si.pov.dday ) clear long
    drop if  si_pov_dday == .
    sort  countryname year
    keep if regionname == "Aggregates"
    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
    gen baseline = si_pov_dday if year == 1990
    sort countryname baseline
    bysort countryname : replace baseline = baseline[1] if baseline == .
    gen mdg1 = baseline/2
    gen present = si_pov_dday if year == 2008
    sort countryname present
    bysort countryname : replace present = present[1] if present == .
    gen target = ((baseline-mdg1)/(2008-1990))*(2015-1990)
    sort countryname year
    gen angel45x = .
    gen angle45y = .
    replace angel45x = 0 in 1
    replace angle45y = 0 in 1
    replace angel45x = 80 in 2
    replace angle45y = 80 in 2
    graph twoway ///
        (scatter present  target  if year == 2008, mlabel( countrycode))    ///
        (line  angle45y angel45x ),                                         ///
            legend(off) xtitle("Target for 2008")  ytitle(Present)          ///
            title("MDG 1b - 1.9 USD")                                         ///
            note("Source: World Development Indicators (latest available year: 2008) using Azevedo, J.P. (2026) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
end




*  ----------------------------------------------------------------------------
*  5. poverty and gdp per capita
*  ----------------------------------------------------------------------------

capture program drop example04
program example04

	wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

	* Save returned values immediately before linewrap overwrites r()
	local varlabel1 "`r(varlabel1)'"
	local varlabel2 "`r(varlabel2)'"
	local time "$S_FNDATE"

	linewrap , longstring("`varlabel1'") maxlength(52) name(ylabel)
	linewrap , longstring("`varlabel2'") maxlength(52) name(xlabel)
	
	graph twoway ///
		(scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
		(scatter si_pov_dday ny_gdp_pcap_pp_kd if regionname == "Aggregates", msize(*.8) mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
		(lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
			legend(off) ///
			xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
			ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///		
			note("Source: World Development Indicators (latest available year as of `time') using Azevedo, J.P. (2026) wbopendata: Stata" "module to access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7)) 
			
end

*  ----------------------------------------------------------------------------
*  6. match option
*  ----------------------------------------------------------------------------

capture program drop example05
program define example05
    * Get shapefile path from ado/plus/w
    local world_d "`c(sysdir_plus)'w/world-d.dta"
    use "`world_d'", clear
    wbopendata, match(countrycode) 
    keep countrycode countryname adminregion incomelevel area perimeter 
    list in 1/5

end

*  ----------------------------------------------------------------------------
*  7. geographic metadata example (geo, capital, latitude, longitude)
*  ----------------------------------------------------------------------------

capture program drop example_geo
program define example_geo
    di as text "=== Example: Geographic Metadata Options ===" _n
    
    * Basic indicator download
    wbopendata, indicator(SP.POP.TOTL) clear 
    di as text "After wbopendata with no options:"
    describe 
    
    * With geo option (adds capital, latitude, longitude)
    wbopendata, indicator(SP.POP.TOTL) geo clear 
    di _n as text "After wbopendata with geo option:"
    describe capital latitude longitude
    
    * Show sample data
    list countrycode countryname capital latitude longitude in 1/5
end

*  ----------------------------------------------------------------------------
*  8. linewrap example for graph titles
*  ----------------------------------------------------------------------------

capture program drop example_linewrap
program define example_linewrap
    di as text "=== Example: Linewrap for Graph Titles ===" _n
        
    * Download multiple indicators with linewrap option for graph-ready titles
    * The linewrap() option wraps metadata text at specified character width
    * Returns r(name1_stack), r(description1_stack), etc. for use in graph titles
    wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
        linewrap(name description note) maxlength(40 160)

    * View wrapped metadata in return list
    di as text "Returned values for linewrap:"
    return list

    * Create scatter plot using wrapped indicator names as axis titles
    * Use description_stack for note and note_stack for source attribution
    * NOTE: Use compound quotes to preserve the stacked format when assigning to locals
    local name1 `"`r(name1_stack)'"'
    local name2 `"`r(name2_stack)'"'
    local desc1 `"`r(description1_stack)'"'
    local desc2 `"`r(description2_stack)'"'
    local src1 "`r(sourcecite1)'"
    local src2 "`r(sourcecite2)'"
    local subtitle "`r(latest)'"


    * Basic: caption for descriptions, note for separate sources per indicator
    twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
        title("Poverty and Child Mortality (Latest Available Year)") ///
            "Source: wbopendata (2026)" , size(vsmall)) name(tmp0, replace)

    * Basic: caption for descriptions, note for separate sources per indicator
    twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
        xtitle(`name1', size(small)) ///
        ytitle(`name2', size(small)) ///
        title("Poverty and Child Mortality (Latest Available Year)") ///
        note("Description:" `desc1' `desc2' "" ///
            "Source:" `note1' `note2', size(vsmall)) name(tmp1, replace)
    
    * Advanced: caption for descriptions, note for separate sources per indicator
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
            "{bf:Y (Mortality):} `src2'", size(vsmall)) name(tmp2, replace)


    di _n as text "Use r(name1_stack) in your graph title for auto-wrapped text"
end

*  ----------------------------------------------------------------------------
*  9. basic/nobasic example (default country context variables)
*  ----------------------------------------------------------------------------

capture program drop example_basic
program define example_basic
    di as text "=== Example: Default Basic Country Context Variables (v17.7) ===" _n
    
    * Default behavior - includes 8 basic context variables
    wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long clear
    di as text "Default (with basic variables):"
    describe, short
    
    * With nobasic - only core variables
    wbopendata, indicator(NY.GDP.MKTP.CD) year(2020) long nobasic clear
    di _n as text "With nobasic option:"
    describe, short
end
