*******************************************************************************
*  _countrymetadata2
*! v 16.0  	27Oct2019               by Joao Pedro Azevedo   
*	self-standing code to create country attribute table
* 	support lower case match variables
*******************************************************************************

program define _countrymetadata , rclass

	version 9.0

	******************************************************

	syntax ,						///
			match(varname) 			///
			[ 						///
				ISO					///
				REGIONS				///
				ADMINR				///
				INCOME				///
				LENDING				///
				CAPITALS			///
				BASIC				///
				FULL				///
				countrycode_iso2 	///
				region 				///
				region_iso2 		///
				regionname 			///
				adminregion 		///
				adminregion_iso2 	///
				adminregionname 	///
				incomelevel 		///
				incomelevel_iso2 	///
				incomelevelname 	///
				lendingtype 		///
				lendingtype_iso2 	///
				lendingtypename 	///
				capital 			///
				latitude 			///
				longitude 			///
				countryname			///
				lower				///
			]
	
	******************************************************

	qui {
	
	******************************************************
	* create lists of metadata by type
		local tmpisolist " countrycode_iso2 region_iso2 adminregion_iso2 incomelevel_iso2 lendingtype_iso2 "
		local tmpregionlist " region region_iso2 regionname  "
		local tmpadminlist " adminregion adminregion_iso2 adminregionname "
		local tmpincomelist " incomelevel incomelevel_iso2 incomelevelname "
		local tmplendinglist " lendingtype lendingtype_iso2 lendingtypename "
		local tmpcapitalist " capital latitude longitude "

	******************************************************
	* asign list variable values if options are selected			
		if ("`iso'" == "iso") {
			local isolist " `tmpisolist' "
		}
		if ("`regions'" == "regions") {
			local regionlist " `tmpregionlist' "
		}
		if ("`adminr'" == "adminr") {
			local adminlist " `tmpadminlist' "
		}
		if ("`income'" == "income") {
			local incomelist " `tmpincomelist' "
		}
		if ("`lending'" == "lending") {
			local lendinglist " `tmplendinglist' "
		}
		if ("`capital'" == "capital") {
			local capitalist " `tmpcapitallist' "
		}	
		if ("`full'" == "full") {
			local full	" countrycode_iso2  countryname  `tmpregionlist' `tmpadminlist' `tmpincomelist' `tmplendinglist' `tmpcapitalist' "
		}

	******************************************************
	* crate default list of variables 
		if (wordcount(" `countryname' `full' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `capitalist' `isolist' `countryname' `region'  `region_iso2' `regionname' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname'  `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude'") == 0)  {
			local basic " region regionname  adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename "
		}

	******************************************************
	* create full list of variables
		else {
			local basic " `full' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `capitalist' "
		}
		
	******************************************************
	* add tmp prefix to all local. this will be used in the option of the subroutines
		
		foreach var in `full' `basic' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `capitalist' `countrycode_iso2' `countryname' `region'  `region_iso2' `regionname' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname'  `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' {
		
			local tmp`var' `var'
		
		}
		
	local tmpcountryname countryname
		
	******************************************************
	* call the subroutines
	
		if (wordcount("`tmpcountrycode_iso2' `tmpcountryname' `tmpregion' `tmpregion_iso2' `tmpregionname' ") >= 1) {
			cap: _wbod_tmpfile1, match(`match') `tmpcountrycode_iso2' `tmpcountryname' `tmpregion' `tmpregion_iso2' `tmpregionname' 

			if (_rc == 0) {
				local order "`order' `tmpcountrycode_iso2' `tmpcountryname' `tmpregion' `tmpregion_iso2' `tmpregionname'  "
			}
			if (_rc != 0) {
				*noi di in r "variable `tmpcountrycode_iso2' `tmpcountryname' `tmpregion' `tmpregion_iso2' `tmpregionname'  already defined"
			}
		}

		if (wordcount("`tmpadminregion' `tmpadminregion_iso2' `tmpadminregionname' `tmpincomelevel' `tmpincomelevel_iso2' `tmpincomelevelname'  ") >= 1) {
			cap: _wbod_tmpfile2, match(`match') `tmpadminregion' `tmpadminregion_iso2' `tmpadminregionname' `tmpincomelevel' `tmpincomelevel_iso2' `tmpincomelevelname' 
			if (_rc == 0) {
				local order "`order' `tmpadminregion' `tmpadminregion_iso2' `tmpadminregionname' `tmpincomelevel' `tmpincomelevel_iso2' `tmpincomelevelname' "
			}
			if (_rc != 0) {
				*noi di in r "variable `tmpadminregion' `tmpadminregion_iso2' `tmpadminregionname' `tmpincomelevel' `tmpincomelevel_iso2' `tmpincomelevelname' "
			}
		}
		
		if (wordcount("`tmplendingtype' `tmplendingtype_iso2' `tmplendingtypename' `tmpcapital' `tmplongitude' `tmplatitude' ") >= 1) {
			cap: _wbod_tmpfile3, match(`match') `tmplendingtype' `tmplendingtype_iso2' `tmplendingtypename' `tmpcapital' `tmplongitude' `tmplatitude' 
				if (_rc == 0) {
				local order "`order' `tmplendingtype' `tmplendingtype_iso2' `tmplendingtypename' `tmpcapital' `tmplongitude' `tmplatitude'  "
			}
			if (_rc != 0) {
				*noi di in r "variable `tmplendingtype' `tmplendingtype_iso2' `tmplendingtypename' `tmpcapital' `tmplongitude' `tmplatitude'  already defined"
			}
		}
		
	******************************************************
	* order variables
		cap: order countrycode countryname `order'
	
	}

end

