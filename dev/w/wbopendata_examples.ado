*! -wbopendata_examples-: Auxiliary program for -wbopendata-
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
    qui tempfile tmp
    wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest
    local labelvar "`r(varlabel1)'"
    sort countrycode
    save `tmp', replace
    qui sysuse world-d, clear
    qui merge countrycode using `tmp'
    qui sum year
    local avg = string(`r(mean)',"%16.1f")
    spmap  it_cel_sets_p2 using "world-c.dta", id(_ID)                                  ///
            clnumber(20) fcolor(Reds2) ocolor(none ..)                                  ///
            title("`labelvar'", size(*1.2))         ///
            legstyle(3) legend(ring(1) position(3))                                     ///
            note("Source: World Development Indicators (latest available year: `avg') using  Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.")
end

*  ----------------------------------------------------------------------------
*  3. alorenz
*  ----------------------------------------------------------------------------

capture program drop example02
program example02
    wbopendata, indicator(si.pov.2day ) clear long
    drop if  si_pov_2day == .
    sort  countryname year
    bysort  countryname : gen diff_pov = (si_pov_2day-si_pov_2day[_n-1])/(year-year[_n-1])
    encode regioncode, gen(reg)
    encode countryname, gen(reg2)
    keep if region == "Aggregates"
    alorenz diff_pov, gp points(20) fullview  xdecrease markvar(reg2)                                           ///
        ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional episodes of poverty reduction (%)")   ///
        legend(off) title("Poverty Reduction")                                                                  ///
        legend(off) note("Source: World Development Indicators using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
end

*  ----------------------------------------------------------------------------
*  3. mdg
*  ----------------------------------------------------------------------------

capture program drop example03
program example03
    wbopendata, indicator(si.pov.2day ) clear long
    drop if  si_pov_2day == .
    sort  countryname year
    keep if region == "Aggregates"
    bysort  countryname : gen diff_pov = (si_pov_2day-si_pov_2day[_n-1])/(year-year[_n-1])
    gen baseline = si_pov_2day if year == 1990
    sort countryname baseline
    bysort countryname : replace baseline = baseline[1] if baseline == .
    gen mdg1 = baseline/2
    gen present = si_pov_2day if year == 2008
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
            title("MDG 1b - 2 USD")                                         ///
            note("Source: World Development Indicators (latest available year: 2008) using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
end




*  ----------------------------------------------------------------------------
*  4. poverty and gdp per capita
*  ----------------------------------------------------------------------------

capture program drop example04
program example04

wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

local time "$S_FNDATE"

graph twoway ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.6)) ///
    (scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8) mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
    (lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
        xtitle("`r(varlabel2)'") ///
        ytitle("`r(varlabel1)'") ///
        legend(off) ///
        note("Source: World Development Indicators (latest available year as off `time') using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))

end
