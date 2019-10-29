*******************************************************************************
*! v 16.0  	27Oct2019					by Joao Pedro Azevedo  
* 	generate only three files
*	change dataflow
*******************************************************************************

program define _update_countrymetadata , rclass

	version 9.0

	******************************************************

	syntax ,					///
			[ 					///
				NAME(string) 	///
				SAVE			///
				REPLACE			///
				NOCTRYREFRESH	///
				CTRYLIST		///
		  ]
	

	
	preserve

	tempfile tmpcountrylist

	tempname out

	local date: disp %td date("`c(current_date)'", "DMY")
	
quietly {
	
	************************************************************************
		/*			
		
		_api_read , query("http://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			parameter(page pages total)

		local maxp =  r(total1)
		
		di "`maxp'"

		*/

		noi di in smcl in g ""
		noi di in smcl in g "{bf: Downloading country metadata...}"
		
		local maxp =  310
			
		************************************************************************

		file open `out' using `tmpcountrylist' , text write replace

		file write `out' " countrycode#countrycode_iso2#countryname#region#region_iso2#regionname#adminregion#adminregion_iso2#adminregionname#incomelevel#incomelevel_iso2#incomelevelname#lendingtype#lendingtype_iso2#lendingtypename#capital#longitude#latitude " _n


		_api_read , query("http://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			per_page(`maxp') ///
			parameter(page pages total)
			
		local ctrymeta = r(total1)

		local pages = r(pages1)

		local maxk = `maxp'-1
			
		forvalues p = 1(1)`pages' {

			_api_read , query("http://api.worldbank.org/v2/countries/") ///
				per_page(`maxp') ///
				page(`p') list ///
				nopreserve ///
				parameter( country?id iso2Code name region?id adminregion?id incomeLevel?id lendingType?id iso2code capitalCity latitude longitude )

				noi di in smcl in g "{bf: Downloading country metadata... COMPLETED!}"
				noi di in smcl in g ""
				noi di in smcl in g "{bf: Processing country metadata...}"
	
				
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

		tempfile tmpCTRYtmp_dta
		
		*******************************************************************************
		* create countrymetadata ado files
		*******************************************************************************
		
		insheet using `tmpcountrylist' , delimiter("#") names clear 

		bysort countrycode : gen dups = _n
		keep if dups == 1
		drop dups
		drop if countrycode == ""

		save `tmpCTRYtmp_dta'
		
		replace adminregionname = regionname + " (excluding high income)" if adminregionname != "" & incomelevel != "HIC"
		
		compress
		
		sort countrycode 

		if ("`save'" != "") {
		
			if ("`name'" == "") {
				local name "countrylist"
			}
		
			save `name'.dta, `replace'
			noi di in y "`name'.dta saved `replace'"
			noi di ""
		}
		
		if ("`noctryrefresh'" == "") {
		
			foreach varname of varlist countrycode_iso2 - latitude {
				rename `varname' values_`varname'
			}
						
			reshape long values_ , i(countrycode) j(variable) string

			drop if values_ == ""

			sort variable countrycode

			gen seq = _n

			local datef = c(current_date)
			local time = c(current_time)

			
		**********************************************************************	
			
			local list1 " countrycode_iso2 countryname region region_iso2 regionname "
			local list2 " adminregion adminregion_iso2 adminregionname incomelevel incomelevel_iso2 incomelevelname "
			local list3 " lendingtype lendingtype_iso2 lendingtypename capital longitude latitude "

						
		******************************  Header for ******************************  
		
		forvalues l = 1(1)3 {
			
				local variable wbod_tmpfile`l'
				
				tempfile tmp`variable'
				tempname out_`variable'
				file open `out_`variable'' using `tmp`variable'' , text write replace

				di "`variable'"

				file write `out_`variable'' `"*! _`variable' <`datef' : `time'>			by João Pedro Azevedo"' 	_n
				file write `out_`variable'' `"*			auto generated and updated using _update_countrymetadata.ado "' _n
				file write `out_`variable''  "	" _n

				file write `out_`variable''  " program define _`variable' " _n
				file write `out_`variable''  "	" _n
				file write `out_`variable''  "	   syntax , match(varname) [ `list`l'' ] " _n
				file write `out_`variable''  "	" _n
				
		******************************  

				foreach varname2 in `list`l'' {

					if (strmatch("latitude longitude","*`varname2'*") == 0)  {
					
						
						file write `out_`variable''  " ******************  Values: `varname2' ****************** " _n
						file write `out_`variable''  "	" _n
						file write `out_`variable''  `" qui if ("\``varname2''" == "`varname2'") {	"' _n
						file write `out_`variable''  "	" _n
						file write `out_`variable''  `"		cap: gen `varname2' = ""  "' _n

						sum seq if variable == "`varname2'"
						local min = r(min)
						local max = r(max)
						
						forvalues ctry = `min'(1)`max'  {

							local value = values_  			in `ctry'
							local ctrycode = countrycode 	in `ctry'
						
							file write `out_`variable''  `"		cap: replace `varname2' = "`value'"	if \`match' == "`ctrycode'"  "' _n
							
						}

					}
					
					if (strmatch("latitude longitude","*`varname2'*") == 1)   {
					
						
						file write `out_`variable''  " ******************  Values: `varname2' ****************** " _n
						file write `out_`variable''  "	" _n
						file write `out_`variable''  `" qui if ("\``varname2''" == "`varname2'") {	"' _n
						file write `out_`variable''  "	" _n
						file write `out_`variable''  `"		cap: gen  double `varname2' = .  "' _n
						
						sum seq if variable == "`varname2'"
						local min = r(min)
						local max = r(max)
						
						forvalues ctry = `min'(1)`max'  {
						
							local value = values_  			in `ctry'
							local ctrycode = countrycode 	in `ctry'
						
							file write `out_`variable''  `"		cap: replace `varname2' = real("`value'")	if \`match' == "`ctrycode'"  "' _n
							
						}

					}

					file write `out_`variable''  "	" _n
					file write `out_`variable''  "******************  Lable: `varname2' ******************" _n
					file write `out_`variable''  "	" _n

					******************************************************
					if ("`varname2'" == "countryname") {
						file write `out_`variable''  `"	    lab var countryname			"Country Name" "' _n
					}
					if ("`varname2'" == "countrycode_iso2") {
						file write `out_`variable''  `"	    lab var countrycode_iso2    "Country Code (ISO 2 digits)" "' _n
					}
					if ("`varname2'" == "region") {
						file write `out_`variable''  `"	    lab var region  			"Region Code" "' _n
					}
					if ("`varname2'" == "region_iso2") {
						file write `out_`variable''  `"	    lab var region_iso2			"Region Code (ISO 2 digits)" "' _n
					}
					if ("`varname2'" == "regionname") {
						file write `out_`variable''  `"	    lab var regionname      	"Region Name" "' _n
					}
					if ("`varname2'" == "adminregion") {
						file write `out_`variable''  `"	    lab var adminregion  		"Administrative Region Code" "' _n
					}
					if ("`varname2'" == "adminregion_iso2") {
						file write `out_`variable''  `"	    lab var adminregion_iso2	"Administrative Region Code (ISO 2 digits)" "' _n
					}
					if ("`varname2'" == "adminregionname") {
						file write `out_`variable''  `"	    lab var adminregionname	    "Administrative Region Name" "' _n
					}
					if ("`varname2'" == "incomelevel") {
						file write `out_`variable''  `"	    lab var incomelevel  		"Income Level Code" "' _n
					}
					if ("`varname2'" == "incomelevel_iso2") {
						file write `out_`variable''  `"	    lab var incomelevel_iso2	"Income Level Code (ISO 2 digits)" "' _n
					}
					if ("`varname2'" == "incomelevelname") {
						file write `out_`variable''  `"	    lab var incomelevelname    	"Income Level Name" "' _n
					}
					if ("`varname2'" == "lendingtype") {
						file write `out_`variable''  `"	    lab var lendingtype  		"Lending Type Code" "' _n
					}
					if ("`varname2'" == "lendingtype_iso2") {
						file write `out_`variable''  `"	    lab var lendingtype_iso2	"Lending Type Code (ISO 2 digits)" "' _n
					}
					if ("`varname2'" == "lendingtypename") {
						file write `out_`variable''  `"	    lab var lendingtypename    	"Lending Type Name" "' _n
					}
					if ("`varname2'" == "capital") {
						file write `out_`variable''  `"	    lab var capital		  		"Capital Name" "' _n
					}
					if ("`varname2'" == "latitude") {
						file write `out_`variable''  `"	    lab var latitude			"Capital Latitude" "' _n
					}
					if ("`varname2'" == "longitude") {
						file write `out_`variable''  `"	    lab var longitude	      	"Capital Longitude" "' _n
					}
					
					******************************************************
					
					file write `out_`variable''  " }	" _n
					file write `out_`variable''  "	" _n
					file write `out_`variable''  " ****************************************************** " _n
					file write `out_`variable''  "	" _n

			}

		

			
			******************************************************
				
			file write `out_`variable''  " end " _n

			file close `out_`variable''

			******************************************************
					
			cap: findfile _`variable'.ado, `path'
			if _rc == 0 {
				copy  `tmp`variable''  `r(fn)' , replace
			}
			else {
				copy `tmp`variable'' _`variable'.ado
			}
			
		}

	}
			
		noi di in smcl in g "{bf: Processing country metadata... COMPLETED!}"
		noi di in smcl in g ""
		tempfile tmp
		
		save `tmp'
			
		******************************************************************************
		* udpate country txt files
		*******************************************************************************

				

		if ("`ctrylist'" == "ctrylist") {

			noi di in smcl in g "{bf: Processing country list...}"

			local country country.txt
			
			tempfile  tmpCTRYtmp
			
			use `tmpCTRYtmp_dta'

			bysort countrycode : gen dups = _n
			keep if dups == 1
			drop dups
			drop if countrycode == ""
			
			sort countrycode
			gen export = countrycode + " - " + countryname
			keep export
			sort export
			outsheet using `tmpCTRYtmp', replace noquote nolabel nonames
			
			cap: findfile `country' , `path'
					
			if _rc == 0 {
				copy `tmpCTRYtmp'  `r(fn)' , replace
			}
			else {
				copy `tmpCTRYtmp' `indicator'
			}
			
			noi di in smcl in g "{bf: Processing country list... COMPLETED!}"
			noi di in smcl in g ""

		}

		
		*******************************************************************************
		* create country sthlp files
		*******************************************************************************
		
		noi di in smcl in g "{bf: Processing country documentation...}"
		noi di in smcl in g ""

		use `tmp', clear
		
		foreach variable in region adminregion incomelevel lendingtype {
		
			tempfile help`variable'
			
			tempname hlp`variable' dups`variable' seq2`variable' seq3`variable'

			use `tmp', clear
			
			_countrymetadata, match(countrycode) countryname full 
			
			keep if `variable' != ""
			
			sort `variable' countryname 
			
			bysort `variable' countryname : gen `dups`variable'' = _n
			
			keep if `dups`variable'' == 1
			
			sort `dups`variable'' `variable' countryname 
			
			bysort `dups`variable'' `variable' countryname : gen `seq2`variable'' = _n
			
			keep if  `seq2`variable'' == 1
			
			sort `variable' `countryname'
			
			gen `seq3`variable'' = _n
	
			local title : variable label `variable' 
			
			local title = subinstr("`title'","Code","",.)
			
			**************** header ********************
			
			file open `hlp`variable''		using 	`help`variable'' , write text replace

			
			file write `hlp`variable'' "{smcl}" 					_n
			file write `hlp`variable'' "" 							_n
			file write `hlp`variable'' "{marker indicators}{...}" 	_n
			file write `hlp`variable'' "{p 20 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}" 	_n
			file write `hlp`variable'' "{title:`title' (as of `date')}" 		_n
			file write `hlp`variable'' "" 							_n

			********************************************
			levelsof `variable'
			
			foreach topic in `r(levels)' {
			
				sum `seq3`variable'' if `variable' == "`topic'"
				local min = r(min)
				local max = r(max)

				local topicode1	= `variable'		in `min'
				local topicode2	= `variable'name	in `min'

				file write `hlp`variable'' "{marker `topicode1'}" 	_n
				file write `hlp`variable'' "{p 20 20 2}(Go up to {it:{help wbopendata##`variable':`title'}}){p_end}" 	_n
				file write `hlp`variable'' "{synoptset 33 tabbed}{...}" 	_n
				file write `hlp`variable'' "{synopthdr:`topicode2' (`topicode1')}" _n
				file write `hlp`variable'' "{synoptline}" 				_n
	
				forvalues line = `min'(1)`max'  {

					local ctryname 	= countryname  		in `line'
					local ctrycode 	= countrycode 		in `line'
					
					file write `hlp`variable''  `"{synopt:{opt `ctrycode'}}  `ctryname' {p_end}"' _n
							
				}
			
				file write `hlp`variable''  `""' _n
				
			}
				

			file close `hlp`variable''
			
			
			cap: findfile wbopendata_`variable'.sthlp , `path'
			if _rc == 0 {
				copy `help`variable''  `r(fn)' , replace
			}
			else {
				copy `help`variable'' wbopendata_`variable'.sthlp
			}
			
			noi di in g in smcl "	See {bf:{help wbopendata##`variable':`title'}}"
			
			
		}		
		
		*******************************************************************************

		noi di in smcl in g "{bf: Processing country documentation... COMPLETED!}"

		
	restore

	local ctrytime 			= c(current_time)
	local ctrydatef 		= c(current_date)
	local dt_ctryupdate 		"`ctrydatef' `ctrytime'"

	return local dt_ctryupdate    = "`dt_ctryupdate'"  					
	return local dt_ctrylastcheck = "`dt_ctryupdate'" 
	return local ctrymeta = `ctrymeta'
}

end


*******************************************************************************
* v 15.3  	28Sept2019					by Joao Pedro Azevedo   
* 	add countrycode 
*******************************************************************************
* v 15.2  	3Mar2019               by Joao Pedro Azevedo   
* _update_countrymetadata 
*******************************************************************************
* v 15.1  	3Mar2019               by Joao Pedro Azevedo   
*	initial commit
*******************************************************************************
