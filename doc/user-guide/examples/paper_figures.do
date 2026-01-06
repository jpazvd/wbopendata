version 16.0
clear all
set more off

* Figure 1: Poverty vs life expectancy with linewrap metadata
tempfile latest_pov
wbopendata, indicator(SP.DYN.LE00.IN;SI.POV.DDAY) clear long latest linewrap(name note) maxlength(50 80)
local subtitle "`r(latest)'"
local title `"`r(name1_stack)'"'
local source `"Source: `r(sourcecite1)'"'
twoway (scatter si_pov_dday sp_dyn_le00_in), ///
    title(`"`title'"') ///
    subtitle(`"`subtitle'"') ///
    note(`"`source'"') ///
    legend(off)
graph export "../images/wbopendata_10.png", width(2000) replace

drop _all

* Figure 2: Mobile subscriptions map (latest year)
wbopendata, indicator(IT.CEL.SETS.P2) clear long latest
local label "`r(varlabel1)'"
local subtitle "`r(latest)'"
tempfile mobiles
save `mobiles', replace
use "../../src/w/world-d.dta", clear
merge 1:1 countrycode using `mobiles', nogen
spmap it_cel_sets_p2 using "../../src/w/world-c.dta", id(_ID) ///
    title(`"`label'"') ///
    subtitle(`"`subtitle'"') ///
    note("Source: `r(sourcecite1)'") ///
    clnumber(20) fcolor(Reds2) ocolor(none ..)
graph export "../images/wbopendata_8.png", width(2000) replace
