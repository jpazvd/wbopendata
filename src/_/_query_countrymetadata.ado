*******************************************************************************
*! v 15.1  	3Mar2019               by Joao Pedro Azevedo   
*	initial commit
*******************************************************************************

program define _query_countrymetadata , rclass

	version 9.0

	preserve

	************************************************************************
					
		local maxp = 304

		qui _api_read , query("http://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			parameter(page pages total)

		************************************************************************


		tempfile tmpcountrylist

		tempname out

		file open `out' using `tmpcountrylist' , text write replace

		file write `out' " countrycode#countrycode_iso2#countryname#regioncode#regioncode_iso2#regionname#adminregion#adminregion_iso2#adminregionname#incomelevel#incomelevel_iso2#incomelevelname#lendingtype#lendingtype_iso2#lendingtypename#capital#longitude#latitude " _n


		qui _api_read , query("http://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			per_page(`maxp') ///
			parameter(page pages total)

		local pages = r(pages1)

		local maxk = `maxp'-1
			
		forvalues p = 1(1)`pages' {

			_api_read , query("http://api.worldbank.org/v2/countries/") ///
				per_page(`maxp') ///
				page(`p') list ///
				nopreserve ///
				parameter( country?id iso2Code name region?id adminregion?id incomeLevel?id lendingType?id iso2code capitalCity latitude longitude )

			forvalues pp = 0(1)`maxk' {
			
				qui foreach jj in 2 3 4 5 6 7 8 9 10 11 {
						
					
					local kk = `jj'+(11*`pp')
					
					local `jj' `kk'
					
				}
				
				local ctrycode 			= r(country_id`2')
				local ctrycode_iso2 	= r(iso2Code`3')
				local ctryname 			= r(name`4')
				local region 			= r(region_id`5')
				local regname 			= r(iso2code`5')
				local adminregion 		= r(adminregion_id`6')
				local adminregion_iso 	= r(iso2code`6')
				local incomelevel 		= r(incomeLevel_id`7')
				local incomelevel_iso 	= r(iso2code`7')
				local lendingtype 		= r(lendingType_id`8')
				local lendingtype_iso 	= r(iso2code`8')
				local capital 			= r(capitalCity`9')
				local longitude 		= r(longitude`10')
				local latitude 			= r(latitude`11')

					
				foreach var in	 ctrycode 	 ctrycode_iso2 	 ctryname 	 region  regname	 adminregion 	 adminregion_iso 	 incomelevel 	 incomelevel_iso 	 lendingtype 	 lendingtype_iso 	 capital  {

					local `var' = trim("``var''")
					local `var' = subinstr("``var''","&amp;","and",.)
					local `var' = subinstr("``var''","< wb:lendingType","",.)
					local `var' = subinstr("``var''","< wb:adminregion","",.)
					local `var' = subinstr("``var''",".","",.)
					
				}
				
				local region_iso2        	= word("`regname'",1)
				local adminregion_iso2		= word("`adminregion_iso'", 1) 
				local incomelevel_iso2		= word("`incomelevel_iso'",1)
				local lendingtype_iso2 		= word("`lendingtype_iso'",1)
				
				if length("`region_iso2'")==2 {
					local regionname 			= subinstr("`regname'","`region_iso2'","",.) 				
				}
				if length("`adminregion_iso2'")==2 {
					local adminname				= subinstr("`adminregion_iso'","`adminregion_iso2'","",.) 			
				}
				if length("`incomelevel_iso2'")==2 {
					local incomelevelname		= subinstr("`incomelevel_iso'","`incomelevel_iso2'","",.)	
				}
				if length("`lendingtype_iso2'")==2 {
					local lendingname			= subinstr("`lendingtype_iso'","`lendingtype_iso2'","",.)		
				}

				
				if ("`regname'" != "NA Aggregates") { 
					file write `out' " `ctrycode'#`ctrycode_iso2'#`ctryname'#`region'#`region_iso2'#`regionname'#`adminregion'#`adminregion_iso2'#`adminname'#`incomelevel'#`incomelevel_iso2'# `incomelevelname'#`lendingtype'#`lendingtype_iso2'#`lendingname'#`capital' 	# `longitude' 	# `latitude' 	" _n
				}
				if ("`regname'" == "NA Aggregates") { 
					file write `out' " `ctrycode'#`ctrycode_iso2'#`ctryname'#`region'#`region_iso2'#`regionname'#`adminregion'#`adminregion_iso2'#`adminname'#`incomelevel'#`incomelevel_iso2'# `incomelevelname'#`lendingtype'#`lendingtype_iso2'#`lendingname'# 			#  				#  				" _n
				}	

				local ctrycode 			""
				local ctrycode_iso2 	""
				local ctryname 			""
				local region 			""
				local regname 			""
				local adminregion 		""
				local adminregion_iso 	""
				local incomelevel 		""
				local incomelevel_iso 	""
				local lendingtype 		""
				local lendingtype_iso 	""
				local capital 			""
				local longitude 		""
				local latitude 			""
				local regionname 		""
				local adminname			""
				local incomelevelname	""
				local lendingname		""
				local region_iso2        	""
				local adminregion_iso2		"" 
				local incomelevel_iso2		""
				local lendingtype_iso2 		""
				
			}

		}

		*******************************************************************************

		insheet using `tmpcountrylist' , delimiter("#") names clear 

		rename (countrycode_iso2 - latitude) values_=

		reshape long values_ , i(countrycode) j(variable) string

		drop if values_ == ""

		sort variable countrycode

		gen seq = _n

		levelsof variable

		local datef = c(current_date)
		local time = c(current_time)

		levelsof variable

		qui foreach variable in `r(levels)' {


			tempfile tmp`variable'

			tempname out_`variable'

			file open `out_`variable'' using `tmp`variable'' , text write replace


			di "`variable'"

			file write `out_`variable'' `"*! _`variable' <`datef' : `time'>			by João Pedro Azevedo"' 	_n
			file write `out_`variable''  "	" _n

			
			file write `out_`variable''  "	program define _`variable' " _n

			if (strmatch("latitude longitude","*`variable'*") == 0)  {
			
				
				file write `out_`variable''  "	" _n
				file write `out_`variable''  "	" _n
				file write `out_`variable''  `"		gen `variable' = ""  "' _n

				sum seq if variable == "`variable'"
				local min = r(min)
				local max = r(max)
				
				forvalues ctry = `min'(1)`max'  {

					local value = values_  			in `ctry'
					local ctrycode = countrycode 	in `ctry'
				
					file write `out_`variable''  `"		replace `variable' = "`value'"	if countrycode == "`ctrycode'"  "' _n
					
				}

			}
			
			if (strmatch("latitude longitude","*`variable'*") == 1)   {
			
				
				file write `out_`variable''  "	" _n
				file write `out_`variable''  "	" _n
				file write `out_`variable''  `"		gen  double `variable' = .  "' _n
				
				sum seq if variable == "`variable'"
				local min = r(min)
				local max = r(max)
				
				forvalues ctry = `min'(1)`max'  {
				
					local value = values_  			in `ctry'
					local ctrycode = countrycode 	in `ctry'
				
					file write `out_`variable''  `"		replace `variable' = real("`value'")	if countrycode == "`ctrycode'"  "' _n
					
				}

			}

			file write `out_`variable''  "	" _n
			file write `out_`variable''  "	" _n
			file write `out_`variable''  "	end " _n

			file close `out_`variable''

			******************************************************
			
			findfile _`variable'.ado, `path'
			copy  `tmp`variable''  `r(fn)' , replace

		}

		*******************************************************************************

	restore

end


*******************************************************************************
*! v 15.2  	3Mar2019               by Joao Pedro Azevedo   
*
*	query to country attributes using API (requires _api_read.ado)
*	generate country attributes tables
*	update country attribute tables
*	atrributes currently supported:
*		adminregion
*		adminregion_iso2
*		adminregionname
*		countrycode_iso2
*		countryname
*		incomelevel
*		incomelevel_iso2
*		incomelevelname
*		lendingtype
*		lendingtype_iso2
*		lendingtypename
*		regioncode
*		regioncode_iso2
*		regionname
*		capital
*		latitude
*		longitude
*******************************************************************************
