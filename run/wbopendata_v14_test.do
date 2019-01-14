*cd "C:\Users\wb255520\OneDrive - WBG\000.general\02.ado_files_\14.wbopendata\versions\v14"

cd "C:\Users\wb255520\data"

cd "C:\Users\wb255520\Documents\myados\wbopendata\src"

set checksum off, perm

*** wbopendata, country(chn - China) clear

set trace off

wbopendata, country(chn - China) clear
des

wbopendata2, country(chn - China) clear
des

wbopendata2, country(chn - China) clear qa
des

set trace on
set tracedepth 6


set trace off
local ctry chi 

wbopendata2, country(`ctry') clear
codebook indicatorcode

wbopendata2, country(`ctry') clear qa
codebook indicatorcode


*** wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear

set trace off

wbopendata2, language(en - English) topics(2 - Aid Effectiveness) clear
codebook indicatorcode

wbopendata2, language(en - English) topics(2 - Aid Effectiveness) clear qa
codebook indicatorcode


*** wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear

set trace off

wbopendata2, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear nometadata
codebook indicatorcode

wbopendata2, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear nometadata qa 
codebook indicatorcode

*** wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear

set trace off

wbopendata2, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear

wbopendata2, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear qa

*** wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear

set trace off

wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear
tab countrycode

wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear qa
tab countrycode

**** wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long

set trace off
		
wbopendata2, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long
 
wbopendata2, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long qa


*** Other languages

wbopendata2, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long qa language(ar)

wbopendata2, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long qa language(zh)


*** Date Range (SP.POP.TOTL?date=2000:2001)

set trace off

wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(SP.POP.TOTL) date(2000:2010) clear 
tab countrycode

wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(SP.POP.TOTL) date(2000:2010) clear qa 
tab countrycode

*********************************************************

wbopendata2, indicator(SP.POP.TOTL) date(2000:2010) clear 
tab countrycode

wbopendata2, indicator(SP.POP.TOTL) date(2000:2010) clear qa 
tab countrycode


wbopendata2, indicator(SP.POP.TOTL; SP.POP.0713.TO.UN ; SP.POP.1317.TO.UN ) clear long 
keep if year == 2015
sum if year == 2015
browse if year == 2015
gen sp_pop_0717_to_un  = sp_pop_0713_to_un+ sp_pop_1317_to_un




wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(SP.POP.TOTL) year(2000:2010) clear 
tab countrycode

wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(SP.POP.TOTL) year(2000:2010) clear qa 
tab countrycode



wbopendata2, country(ago;bdi;chi;dnk;esp) indicator(LO.PISA.SCI.6.MA) year(2000:2010) clear qa 
