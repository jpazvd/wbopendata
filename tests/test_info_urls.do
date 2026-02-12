* Test wbopendata info() v2.4.0 - clickable URLs in Note
* Tests that _website is called to convert URLs to {browse} links

clear all
set more off

* Set adopath to use dev version
adopath ++ "C:\GitHub\myados\wbopendata-dev\src\_"
adopath ++ "C:\GitHub\myados\wbopendata-dev\src\w"

* Clear any cached frames to force reparse
capture frame drop _wbod_indicators

di as text "===== TEST: Indicator with URLs in Note ====="
di as text "(Should show clickable http links)"
di as text ""

* SP.POP.TOTL has URLs in Note field
wbopendata, info(SP.POP.TOTL)

di as text ""
di as text "===== Return list (should have plain text, no SMCL) ====="
return list

di as text ""
di as text "===== TEST COMPLETE ====="
