*********************************************************************

cd C:\Users\wb255520\data
discard

which wbopendata
which _query
which wbopendata.sthlp

qui {
	cap: wbopendata, country(chn - China) clear
	if _rc==0 { 
		noi di "OK" 
	}
	else {
		noi di "Fail"
	}

	cap: wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear
	if _rc==0 { 
		noi di "OK" 
	}
	else {
		noi di "Fail"
	}

	cap: wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear
	if _rc==0 { 
		noi di "OK" 
	}
	else {
		noi di "Fail"
	}

	cap: wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear
	if _rc==0 { 
		noi di "OK" 
	}
	else {
		noi di "Fail"
	}

	cap: wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear
	if _rc==0 { 
		noi di "OK" 
	}
	else {
		noi di "Fail"
	}

	cap: wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long
	if _rc==0 { 
		noi di "OK" 
	}
	else {
		noi di "Fail"
	}

}

*********************************************************************

cd "C:\Users\wb255520\Documents\myados\wbopendata\src"
shell git checkout master
discard

which wbopendata
which _query 
which wbopendata.sthlp

wbopendata, country(chn - China) clear
wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear
wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear
wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear
wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long

*********************************************************************

cd "C:\Users\wb255520\Documents\myados\wbopendata\src"
shell git checkout dev
discard

which wbopendata
which _query
which wbopendata.sthlp

wbopendata, country(chn - China) clear
wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear
wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear
wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear
wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear
wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) year(2000:2010) clear 
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) year(2000:2010) clear long

*********************************************************************

