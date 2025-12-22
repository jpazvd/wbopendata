* Options A and D with maxlength 180
clear all

wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 180 180)

* Store all returns with compound quotes
local name1 `"`r(name1_stack)'"'
local name2 `"`r(name2_stack)'"'
local desc1 `"`r(description1_stack)'"'
local desc2 `"`r(description2_stack)'"'
local src1 "`r(sourcecite1)'"
local src2 "`r(sourcecite2)'"
local subtitle "`r(latest_subtitle)'"

* Option A: Using caption for descriptions and note for sources
di _n "=== Option A: caption + note ==="
twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Indicator Descriptions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2', size(vsmall) span) ///
    note("Sources: `src1'; `src2'", size(vsmall))

graph export "test_optionA_140.png", replace

* Option D: Use sourcecite for clean source attribution
* Note: Full notes contain SMCL {browse ...} tags that don't render in graphs
* Using sourcecite returns which are plain text

* Option D: subtitle for short info, caption for descriptions, note for separate sources
di _n "=== Option D: subtitle + caption + note (separate sources) ==="
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

graph export "test_optionD_140.png", replace

* Option E: Sources labeled on separate lines in note
di _n "=== Option E: separate source lines in note ==="

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
         "{bf:Y (Mortality):} `src2'", size(vsmall) span)

graph export "test_optionE_140.png", replace

* Option F: Short sourcecite on one line
di _n "=== Option F: short sourcecite on one line ==="

twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Definitions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2', size(vsmall) span) ///
    note("{bf:Data Sources:}  X: `src1';  Y: `src2'", size(vsmall) span)

graph export "test_optionF_140.png", replace





* Option G: Sources in caption (separate lines)
di _n "=== Option G: sources in caption (separate lines) ==="

twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Definitions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2' "" ///
            "{bf:Data Sources:}" ///
            "{bf:X (Poverty):} `src1'" ///
            "{bf:Y (Mortality):} `src2'", size(vsmall) span)

graph export "test_optionG_140.png", replace



* Option H: Short sourcecite in caption
wbopendata, indicator(SI.POV.DDAY; SH.DYN.MORT) clear long latest ///
    linewrap(name description note) maxlength(40 180 180)

local name1 `"`r(name1_stack)'"'
local name2 `"`r(name2_stack)'"'
local desc1 `"`r(description1_stack)'"'
local desc2 `"`r(description2_stack)'"'
local src1 "`r(sourcecite1)'"
local src2 "`r(sourcecite2)'"
local subtitle "`r(latest_subtitle)'"

di _n "=== Option H: short sourcecite in caption ==="

* Option H: Definitions + short sourcecite all in caption
twoway (scatter sh_dyn_mort si_pov_dday, msize(small) mcolor(blue%50)), ///
    xtitle(`name1', size(small)) ///
    ytitle(`name2', size(small)) ///
    title("Poverty and Child Mortality", size(medium)) ///
    subtitle("`subtitle'", size(small)) ///
    caption("{bf:Definitions:}" ///
            "{bf:X-axis:} " `desc1' ///
            "{bf:Y-axis:} " `desc2' ///
            "{bf:Data Sources:}  X: `src1';  Y: `src2'", size(vsmall) span)

graph export "test_optionH_140.png", replace

di _n "=== All options exported ==="