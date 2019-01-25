cd "C:\Users\wb255520\Documents\myados\wbopendata\src"
shell git checkout qa
discard

*	wbopendata example
*   --- example1.do ---
        webdoc init wbopendata, md replace logall plain 
        

		which wbopendata
		which _query
		which wbopendata.sthlp

		
		/***
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

        ***/
		
		wbopendata, country(chn - China) clear
		sum
		
        /***
        # Example 2

       Download all WDI indicators of particular topic
		
        ***/
		
		wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear
		sum
		
		/***
        # Example 3

        Download specific indicator [ag.agr.trac.no]

        ***/
		
		wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear
		sum
		
		/***
        # Example 4

        Download specific indicator and report in long format [ag.agr.trac.no]

        ***/
		
		wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear
		sum
		
		/***
        # Example 5

        Download specific indicator for specific countries, and report in long 
		format [ag.agr.trac.no]

        ***/
		
		wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear
		tab countryname 
		
		/***
        # Example 6

        Download specific indicator, for specific countries and year, and report 
		in long format [ag.agr.trac.no]

        ***/
		
		wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) ///
					year(2000:2010) clear  long
		tab  year countryname 
		tab  year countryname if sp_pop_0610_fe_un != .
		
		/***
        # Example 7

        Map latest values of global mobile phone coverage

        ***/
		
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
        webdoc graph

		
		/***
        # Example 8

        Bencharmk latest poverty levels by percapital income, highlighting single 
		country

        ***/
		
		wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest
		linewrap , longstring("`r(varlabel1)'") maxlength(52) name(ylabel)
		linewrap , longstring("`r(varlabel2)'") maxlength(52) name(xlabel)
		twoway ///
			(scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.2)) ///
			(scatter si_pov_dday ny_gdp_pcap_pp_kd if string(si_pov_dday) == "35.8", ///
				msize(*.8) mlabel(countryname)) ///
			(lowess si_pov_dday ny_gdp_pcap_pp_kd) ///
				if regioncode != "NA" ///
				, legend(off) ///
				xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
				ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///
				note("Source: `r(source1)' using WBOPENDATA")
        webdoc graph
        
		/***

        # Exercise 9

        Benchmark epsiodes of poveryt reduction by Region

        ***/

	wbopendata, indicator(si.pov.dday ) clear long
    drop if  si_pov_dday == .
    sort  countryname year
    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
    encode regioncode, gen(reg)
    encode countryname, gen(reg2)
    keep if region == "Aggregates"
    alorenz diff_pov, gp points(20) xdecrease markvar(reg2)                    ///
        ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional episodes of poverty reduction (%)")   ///
        legend(off) title("Poverty Reduction")                                            ///
        legend(off) note("Source: World Development Indicators using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
    webdoc graph

		/***

        # Exercise 10

        Benchmark MDG progress using 2008 as cutoff value

        ***/
	
	
	wbopendata, indicator(si.pov.dday ) clear long
    drop if  si_pov_dday == .
    sort  countryname year
    keep if region == "Aggregates"
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
            title("MDG 1 - 1.9 USD")                                         ///
            note("Source: World Development Indicators (latest available year: 2008) using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
	webdoc graph

	
		/***

        # Exercise 11

        Bencharmk latest poverty levels by percapital income, highlighting regional 
		averages

        ***/
	
	
	wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

	local time "$S_FNDATE"

	linewrap , longstring("`r(varlabel1)'") maxlength(52) name(ylabel)
	linewrap , longstring("`r(varlabel2)'") maxlength(52) name(xlabel)
	
	graph twoway ///
		(scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
		(scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8) mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
		(lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
			legend(off) ///
			xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
			ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///		
			note("Source: World Development Indicators (latest available year as off `time') using Azevedo, J.P. (2011) wbopendata: Stata" "module to access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", size(*.7))
	webdoc graph
