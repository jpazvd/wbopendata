*******************************************************************************
*  _countrymetadata2
*! v 16.0  	26Oct2019               by Joao Pedro Azevedo   
*	self-standing code to create country attribute table
* 	support lower case match variables
*******************************************************************************

program define _countrymetadata2 , rclass

	version 9.0

	******************************************************

	syntax ,						///
			match(varname) 			///
			[ 						///
				ISO					///
				REGION				///
				ADMINREGION			///
				INCOMELEVEL			///
				LENDINGTYPE			///
				CAPITAL				///
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

	local tmpisolist " countrycode_iso2 region_iso2 adminregion_iso2 incomelevel_iso2 lendingtype_iso2 "
	local tmpregionlist " region region_iso2 regionname  "
	local tmpadminlist " adminregion adminregion_iso2 adminregionname "
	local tmpincomelist " incomelevel incomelevel_iso2 incomelevelname "
	local tmplendinglist " lendingtype lendingtype_iso2 lendingtypename "
	local tmpcapitalist " capital latitude longitude "

			
	if ("`iso'" == "iso") {
		local isolist " `tmpisolist' "
	}
	if ("`region'" == "region") {
		local regionlist " `tmpregionlist' "
	}
	if ("`adminregion'" == "adminregion") {
		local adminlist " `tmpadminlist' "
	}
	if ("`incomelevel'" == "incomelevel") {
		local incomelist " `tmpincomelist' "
	}
	if ("`incomelevel'" == "incomelevel") {
		local lendinglist " `tmplendinglist' "
	}
	if ("`incomelevel'" == "incomelevel") {
		local capitalist " `tmpcapitallist' "
	}	
	if ("`full'" == "full") {
		local full	" `tmpregionlist' `tmpadminlist' `tmpincomelist' `tmplendinglist' `tmpcapitalist' "
	}

	******************************************************
	
	if (wordcount(" `countryname' `full' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `capitalist' `isolist' ") == 0) {
		local basic " region regionname  adminregion adminregionname incomelevel incomelevelname lendingtype lendingtypename "
	}
	else {
		local basic " `full' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `capitalist' "
	}
	
	******************************************************
	
	if (wordcount("`countrycode_iso2' `countryname' `region' `region_iso2' `regionname' ") >= 1) {
		cap: _wbod_tmpfile1, match(`match') `countrycode_iso2' `countryname' `region' `region_iso2' `regionname' 

		if (_rc == 0) {
			local order "`order' `countrycode_iso2' `countryname' `region' `region_iso2' `regionname' "
		}
		if (_rc != 0) {
			noi di in r "variable `countrycode_iso2' `countryname' `region' `region_iso2' `regionname' already defined"
		}
	}

	if (wordcount("`adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname'  ") >= 1) {
		cap: _wbod_tmpfile2, match(`match') `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname' 
		if (_rc == 0) {
			local order "`order' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname'  "
		}
		if (_rc != 0) {
			noi di in r "variable `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname' "
		}
	}
	
	if (wordcount("`lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' ") >= 1) {
		cap: _wbod_tmpfile3, match(`match') `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' 
			if (_rc == 0) {
			local order "`order' `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' "
		}
		if (_rc != 0) {
			noi di in r "variable `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' already defined"
		}
	}
	
	******************************************************

	cap: order countrycode countryname `order'
	if (_rc != 0) {
		noi di in g "variable " in y "countryname" in g " not found."
		qui _countryname, match(`match')
		order countrycode countryname `order'
	}

end

