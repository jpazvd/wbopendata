*global gitroot "C:\Users\wb255520\Documents\myados"
global gitroot "C:\GitHub_myados"

*********************************************************************
/*
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
*/
*********************************************************************

cd "$gitroot\wbopendata\src"
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

cd "$gitroot\wbopendata\src"
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
/* 	Test update functions */

wbopendata, update query

wbopendata, update check

wbopendata, update

wbopendata, update all

_wbopendata, update force
