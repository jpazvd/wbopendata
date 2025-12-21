/*******************************************************************************
* update_metadata.do
* 
* Purpose: Download and update all wbopendata metadata files in the development
*          repository (C:\GitHub\myados\wbopendata\src)
*
* Usage:   Run this script from Stata. It will:
*          1. Set adopath to use the development version of wbopendata
*          2. Verify that Stata is using the correct wbopendata.ado
*          3. Update all metadata files (indicators, sources, topics, countries)
*
* Author:  João Pedro Azevedo
* Date:    21Dec2025
* Version: 1.0
*******************************************************************************/

clear all
set more off

/*******************************************************************************
* STEP 1: Define paths and set adopath
*******************************************************************************/

* Define the development source directory
local srcpath "C:/GitHub/myados/wbopendata/src"

* Display current directory
display as text _n "Current working directory: " as result c(pwd) _n

* Change to source directory
cd "`srcpath'"
display as text "Changed to: " as result c(pwd) _n

* Add the source directories to adopath (at the beginning, so they take priority)
* The underscore folder contains helper programs
adopath ++ "`srcpath'/_"
adopath ++ "`srcpath'/w"

* Show the current adopath
display as text _n "Current adopath (first 5 entries):" _n "{hline 60}"
adopath

/*******************************************************************************
* STEP 2: Verify we are using the development version of wbopendata
*******************************************************************************/

display as text _n "{hline 70}"
display as text "VERIFICATION: Checking which wbopendata.ado Stata is using"
display as text "{hline 70}" _n

* Find where wbopendata.ado is located
which wbopendata

* Expected path
local expected_ado "`srcpath'/w/wbopendata.ado"
display as text _n "Expected path: " as result "`expected_ado'"

* Check the version
display as text _n "Checking wbopendata version..." _n
help wbopendata

* Pause to let user verify
display as text _n "{hline 70}"
display as result "Please verify that 'which wbopendata' shows:"
display as result "`expected_ado'"
display as text "{hline 70}"
display as text _n "If the path is INCORRECT, press Ctrl+Break to abort."
display as text "If the path is CORRECT, the script will continue in 5 seconds..." _n
sleep 5000

/*******************************************************************************
* STEP 3: Update all metadata files
*******************************************************************************/

display as text _n "{hline 70}"
display as text "STARTING METADATA UPDATE"
display as text "{hline 70}" _n

* Timestamp before update
display as text "Update started: " as result c(current_date) " " c(current_time) _n

/*-----------------------------------------------------------------------------
* Option A: Update ALL metadata with FORCE (recommended for full refresh)
*           This updates: indicators, sources, topics, country metadata
*           And regenerates all help files
*-----------------------------------------------------------------------------*/

display as text "Running: wbopendata, update all force" _n
display as text "This will update:" _n
display as text "  - All indicator metadata" _n
display as text "  - All source metadata" _n
display as text "  - All topic metadata" _n
display as text "  - All country metadata" _n
display as text "  - All .sthlp help files" _n
display as text "{hline 70}" _n

* Run the full update
wbopendata, update all force

/*-----------------------------------------------------------------------------
* Alternative update commands (commented out):
*
* Update query only (check what's available without downloading):
*   wbopendata, update query
*
* Update and check changes:
*   wbopendata, update check
*
* Update country metadata only:
*   wbopendata, update countrymetadata
*
* Offline metadata refresh (same as update all force):
*   wbopendata, metadataoffline
*
*-----------------------------------------------------------------------------*/

/*******************************************************************************
* STEP 4: Verify update results
*******************************************************************************/

display as text _n "{hline 70}"
display as text "UPDATE COMPLETE"
display as text "{hline 70}" _n

* Timestamp after update
display as text "Update completed: " as result c(current_date) " " c(current_time) _n

* List updated files in the w directory
display as text _n "Updated files in `srcpath'/w/:" _n
local wfiles : dir "`srcpath'/w" files "*.sthlp"
local count = 0
foreach f of local wfiles {
    local count = `count' + 1
}
display as result "`count' help files found" _n

* Check the _parameters.ado for update timestamps
display as text _n "Checking _parameters.ado for update timestamps..." _n
type "`srcpath'/_/_parameters.ado", lines(50)

display as text _n "{hline 70}"
display as result "METADATA UPDATE COMPLETED SUCCESSFULLY"
display as text "{hline 70}" _n

/*******************************************************************************
* STEP 5: Optional - Verify specific files were updated
*******************************************************************************/

* Check modification dates of key files
display as text _n "Checking modification times of key metadata files:" _n

* List some key files
local keyfiles "wbopendata_sourceid.sthlp wbopendata_topicid.sthlp wbopendata_indicators.sthlp"
foreach f of local keyfiles {
    capture confirm file "`srcpath'/w/`f'"
    if _rc == 0 {
        display as text "  ✓ `f'" as result " exists"
    }
    else {
        display as error "  ✗ `f' NOT FOUND"
    }
}

display as text _n "Check the .dta files:" _n
foreach f in "world-c.dta" "world-d.dta" {
    capture confirm file "`srcpath'/w/`f'"
    if _rc == 0 {
        display as text "  ✓ `f'" as result " exists"
    }
    else {
        display as error "  ✗ `f' NOT FOUND"
    }
}

display as text _n "Script completed. Review the output above for any errors." _n

/*******************************************************************************
* END OF SCRIPT
*******************************************************************************/
