// Quick test to verify CTRY-04 fix
clear all
set more off

// Test CTRY-04: ISO 2-digit codes option
di _n "=== Testing CTRY-04: ISO 2-digit codes option ==="
di "Attempting to download with iso option..."

cap noisily wbopendata, indicator(SP.POP.TOTL) country(BRA) clear long iso nometadata

if _rc != 0 {
	di as error "FAIL: Download with iso option failed"
	di as error "Return code: " _rc
	exit _rc
}

di "Checking for region_iso2 variable..."
cap confirm variable region_iso2

if _rc != 0 {
	di as error "FAIL: region_iso2 variable is missing"
	exit _rc
}

di as result "PASS: CTRY-04 test passed successfully!"
di "region_iso2 variable exists with " _N " observations"
desc region_iso2, short

exit 0
