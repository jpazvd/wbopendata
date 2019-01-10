*********************************************************************

cd C:\Users\wb255520\data
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
wbopendata, indicator(ny.gdp.pcap.pp.kd) clear 


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
wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long

*********************************************************************

