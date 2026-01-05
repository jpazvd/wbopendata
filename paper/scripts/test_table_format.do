* Test table formatting options for country attributes
* Exploring Ben Jann's routines and other options

clear all
set more off

* Load data with full option
wbopendata, indicator(NY.GDP.MKTP.CD) country(BRA) clear full nometadata

* Keep first observation for display
keep in 1

* Option 1: list with table option
di _n "=== Option 1: list, table ==="
list countrycode countryname region regionname, table

* Option 2: list with abbreviate and clean
di _n "=== Option 2: list with subvarname ==="
list countrycode countryname region regionname incomelevel incomelevelname, ///
    noobs subvarname

* Option 3: Transpose and list (manual approach)
di _n "=== Option 3: Manual transpose ==="
preserve
    keep region regionname incomelevel incomelevelname adminregion adminregionname ///
         lendingtype lendingtypename capital latitude longitude
    gen id = 1
    reshape long region incomelevel adminregion lendingtype, i(id) j(var) string
    list, clean noobs
restore

* Option 4: Check for estout
cap which estout
if _rc == 0 {
    di _n "=== Option 4: estout available ==="
    * estpost tabstat could work for summary stats
}
else {
    di _n "estout not installed - try: ssc install estout"
}

* Option 5: Check for dataout
cap which dataout
if _rc == 0 {
    di _n "=== Option 5: dataout available ==="
}
else {
    di _n "dataout not installed"
}

* Option 6: listtab (if available)
cap which listtab
if _rc == 0 {
    di _n "=== Option 6: listtab (Roger Newson) ==="
    listtab countrycode countryname region regionname, type
}
else {
    di _n "listtab not installed - try: ssc install listtab"
}

* Option 7: list, separator(0) for compact display
di _n "=== Option 7: list separator(0) abbreviate ==="
list countrycode region* incomelevel* in 1, separator(0) abbreviate(12)

* Option 8: Display as matrix-style
di _n "=== Option 8: Custom matrix display ==="
local vars "region regionname incomelevel incomelevelname"
foreach v of local vars {
    local val = `v'[1]
    di as text %20s "`v'" " : " as result "`val'"
}

di _n "Done!"
