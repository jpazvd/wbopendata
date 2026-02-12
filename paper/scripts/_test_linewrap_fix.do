* Test: verify linewrap fix
clear all
set more off

cap noi net install wbopendata, from("C:/GitHub/myados/wbopendata-dev/src") replace
which wbopendata

* Test 1: indicator without linewrap (the failing case)
di _n "=== Test 1: indicator without linewrap ==="
cap noi wbopendata, indicator(SP.POP.TOTL) clear long
di "rc = " _rc

* Test 2: indicator with linewrap (should still work)
di _n "=== Test 2: indicator with linewrap ==="
cap noi wbopendata, indicator(SP.POP.TOTL) linewrap(name) clear long
di "rc = " _rc

* Test 3: indicator with capital (from user's error report)
di _n "=== Test 3: indicator with capital ==="
cap noi wbopendata, indicator(SP.POP.TOTL) capital clear
di "rc = " _rc

di _n "=== All tests done ==="
exit
