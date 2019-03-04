**********************************************************
*! version 15.1 			<3Mar2019>		JPAzevedo
*	include countrymetadata option
*	include force option
* version 15.0.2 			<16Feb2019>		JPAzevedo
*	add update query, update check and update options
* version 15.0.1	 		<11Feb2019>		JPAzevedo
*	add latest check value to default report
* version 15.0   			<8Feb2019>		JPAzevedo
*	original commit
**********************************************************

program define _wbopendata, rclass

version 9

syntax , 								///
			[ 							///
				NODISPLAY 				///
				UPDATE					///
				QUERY		            ///
				CHECK		            ///
				COUNTRYMETADATA			///
				FORCE					///
				ALL						///
		  ]

	return add

*    if  wordcount("`query'   `update'    `check'")>2 {
*		noi di  as err "Invalid option: two many parameters."
*		exit 198
*    }

	_parameters

	local number_indicators = r(number_indicators)
	local datef 			= c(current_date)
	local time 				= c(current_time)
	local dt_check  		"`datef' `time'"
	local dt_update 		= r(dt_update)
	local ctrymetadata		= r(ctrymetadata)
	local ctrytime 			= c(current_time)
	local ctrydatef 		= c(current_date)
	local dt_ctrycheck 		"`ctrydatef' `ctrytime'"
	local dt_ctryupdate 	= r(dt_ctryupdate)
	local dt_ctrylastcheck 	= r(dt_ctrycheck)

	
	qui if ("`query'" != "") & ("`check'" == "") & ("`update'" != "") {
	
		if ("`nodisplay'" == "")  {

			noi di in smcl ""
			noi di in g in smcl "{hline}"
			noi di in smcl ""
			noi di in g in smcl "Indicators update status"
			noi di in smcl ""
			noi di in g in smcl "	Existing Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
			noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `r(dt_lastcheck)'}"
			noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
			noi di in smcl ""
			noi di in g in smcl "	Country metadata:		" in y "{bf:`r(ctrymetadata)'}"
			noi di in g in smcl "	Last country check:   		" in w "{bf:`r(dt_ctrylastcheck)'}"  
			noi di in g in smcl "	Current country update level:   " in w "{bf:`r(dt_ctryupdate)'}"
			noi di in smcl ""
			noi di in g in smcl "Possible actions"
			noi di in smcl ""
			noi di in g in smcl 	`" {stata wbopendata, update check : {bf: Check for available updates}} "'         "  (or type -wbopendata, update check-)"
			noi di in smcl ""
			noi di in g in smcl "	See current documentation on {bf:{help wbopendata_indicators##indicators:indicators list}}, {bf:{help wbopendata##region:Regions}}, " 
			noi di in g in smcl "	{bf:{help wbopendata##adminregion:Administrative Regions}}, {bf:{help wbopendata##incomelevel:Income Levels}}, and {bf:{help wbopendata##lendingtype:Lending Types}}"" 
			noi di in smcl ""
			noi di in g in smcl "{hline}"

		}
	}
	
	
	qui if ("`query'" == "") & ("`check'" != "") & ("`update'" != "") {

		_api_read,  parameter(total)
		local newnumber = r(total1) 
		local date r(date)
	
		_api_read , query("http://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			parameter(page pages total)
		local newctrymetadata =  r(total1)
		
		if ("`nodisplay'" == "") {

			noi di in smcl ""
			noi di in g in smcl "{hline}"
			noi di in smcl ""
			noi di in g in smcl "Indicators update status"
			noi di in smcl ""
			noi di in g in smcl "	Existing Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
			if (`number_indicators' == `newnumber') {
				noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `dt_check'}"
			}
			if (`number_indicators' != `newnumber') {
				noi di in g in smcl "	New update available:          " in r "{bf: yes}     " in g " (as of `dt_check'}"
			}
			noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
			noi di in smcl ""
			noi di in g in smcl "	Country metadata:		" in y "{bf:`r(ctrymetadata)'}"
			if (`ctrymetadata'==`newctrymetadata') {
				noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `dt_check'}"
			}
			if (`ctrymetadata'!=`newctrymetadata') {
				noi di in g in smcl "	New update available:          " in r "{bf: yes}     " in g " (as of `dt_check'}"
			}
			noi di in g in smcl "	Last country check:   		" in w "{bf:`r(dt_ctrylastcheck)'}"  
			noi di in g in smcl "	Current country update level:   " in w "{bf:`r(dt_ctryupdate)'}"
			noi di in smcl ""
			noi di in g in smcl "Possible actions"
			noi di in smcl ""
			if (`number_indicators' == `newnumber') & (`ctrymetadata'==`newctrymetadata') {
				noi di in g in smcl "	Do nothing; all files are up to date."
				noi di in smcl ""
				noi di in g in smcl "	See current documentation on {bf:{help wbopendata_indicators##indicators:indicators list}}, {bf:{help wbopendata##region:Regions}}, " 
				noi di in g in smcl "	{bf:{help wbopendata##adminregion:Administrative Regions}}, {bf:{help wbopendata##incomelevel:Income Levels}}, and {bf:{help wbopendata##lendingtype:Lending Types}}"" 
			}
			if (`number_indicators' != `newnumber') | (`ctrymetadata'!=`newctrymetadata')  {
				noi di in g in smcl 	`" {stata wbopendata, update all : {bf: Download available updates}} "'          "  (or type -wbopendata, update all-)"        
				noi di in smcl ""
				noi di in g in smcl "	See current documentation on {bf:{help wbopendata_indicators##indicators:indicators list}}, {bf:{help wbopendata##region:Regions}}, " 
				noi di in g in smcl "	{bf:{help wbopendata##adminregion:Administrative Regions}}, {bf:{help wbopendata##incomelevel:Income Levels}}, and {bf:{help wbopendata##lendingtype:Lending Types}}"" 
			}
			noi di in smcl ""
			noi di in g in smcl "{hline}"

		}
		
		tempfile in out2
		tempname in2 out
			
		findfile _parameters.ado, `path'
			
*		file open `out'    using 	`r(fn)'    		, write text replace
		file open `out'    using 	`out2'   		, write text append 
				
				
		file write `out' `"*! _parameters <`datef' : `tie'> 			João Pedro Azevedo "' 					_n
		file write `out' `""' 					_n
		file write `out' `"program define _parameters, rclass"' 					_n
		file write `out' `""' 					_n
		file write `out' `"		return add"' 					_n
		file write `out' `""' 					_n
		file write `out' `"		return local number_indicators = `number_indicators'"' 					_n 
		file write `out' `"		return local dt_update "`dt_update'" "' 					_n
		file write `out' `"		return local dt_lastcheck  "`dt_check'" "' 					_n  
		file write `out' `""' 					_n
		file write `out' `"		return local ctrymetadata = `ctrymetadata'"' 					_n 
		file write `out' `"		return local dt_ctrylastcheck 	"`dt_ctrycheck'" "' 					_n
		file write `out' `"		return local dt_ctryupdate  "`dt_ctryupdate'" "' 					_n  
		file write `out' `""' 					_n
		file write `out' `"end"' 					_n	
			
		file close `out'
		findfile _parameters.ado, `path'

		copy `out2'  `r(fn)' , replace

	}
	

	
	
	
	qui if ("`query'" == "") & ("`check'" == "") & ("`update'" != "") & ("`all'" != "") | ("`force'" != "") {

		_api_read,  parameter(total)
		local newnumber = r(total1) 
		local date r(date)
		
		_api_read , query("http://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			parameter(page pages total)
		local newctrymetadata =  r(total1)
		
		
		if ((`number_indicators' == `newnumber') & (`ctrymetadata'==`newctrymetadata')) & ("`force'" == "") {
			noi _wbopendata, update check
		}
		
		if ((`number_indicators' != `newnumber') | (`ctrymetadata'!=`newctrymetadata')) | ("`force'" != "") {

			if ((`number_indicators' != `newnumber') | (`ctrymetadata'!=`newctrymetadata')) {
				local status "yes"
			}
			if ((`number_indicators' == `newnumber') & (`ctrymetadata'==`newctrymetadata')) {
				local status "no (force)"
			}
		
			if ("`nodisplay'" == "")  {

				noi di in smcl ""
				noi di in g in smcl "{hline}"
				noi di in smcl ""
				noi di in g in smcl "Indicators update status"
				noi di in smcl ""
				noi di in g in smcl "	Existing Number of Indicators: " in w "{bf: `r(number_indicators)'}"
				noi di in g in smcl "	New Number of Indicators:      " in y "{bf: `newnumber'}"
				noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
				noi di in g in smcl "	New update available:          " in w "{bf: `status'}     " in g " (as of `dt_check'}"
				noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
				noi di in smcl ""
				noi di in g in smcl "	Country metadata:		" in w "{bf:`r(ctrymetadata)'}"
				noi di in g in smcl "	New country metadata:		" in y "{bf:`newctrymetadata'}"
				noi di in g in smcl "	Last country check:   		" in w "{bf:`r(dt_ctrylastcheck)'}"  
				noi di in g in smcl "	Current country update level:   " in w "{bf:`r(dt_ctryupdate)'}"
				noi di in smcl ""
				noi di in g in smcl "Possible actions"
				noi di in smcl ""
				noi di in w in smcl in y "{bf:UPDATE IN PROGRESS...}"
				noi di in smcl ""

			}
		
		
			tempfile in out2
			tempname in2 out
			
			findfile _parameters.ado, `path'
			
			file open `out'    using 	`out2'   		, write text append 

			
			noi _update_indicators, update `preserveout'
					
			noi di in smcl ""
			noi di in smcl in g "{bf:New indicator list created}"
			noi di in smcl ""
			noi di in smcl in g "{bf:New indicator documentation created.}"
			noi di in smcl ""
			noi di in smcl in g "	See {bf:{help wbopendata_indicators##indicators:{bf:Indicators List}}}"
			noi di in smcl ""
				
			noi _update_countrymetadata 
			local newctrymeta 		= r(ctrymeta)
			local newctrylastcheck	= r(dt_ctrylastcheck)
			local newctryupdate		= r(dt_ctryupdate)
			
			
			file write `out' `"*! _parameters <`datef' : `time'> 			João Pedro Azevedo "' 					_n
			file write `out' `""' 					_n
			file write `out' `"program define _parameters, rclass"' 					_n
			file write `out' `""' 					_n
			file write `out' `"		return add"' 					_n
			file write `out' `""' 					_n
			file write `out' `"		return local number_indicators = `newnumber'"' 					_n 
			file write `out' `"		return local dt_update "`datef' `time'" "' 					_n
			file write `out' `"		return local dt_lastcheck  "`datef' `time'" "' 					_n  
			file write `out' `""' 					_n
			file write `out' `"		return local ctrymetadata = `newctrymetadata'"' 					_n 
			file write `out' `"		return local dt_ctrylastupdate  "`dt_ctryupdate'" "' 					_n 
			file write `out' `"		return local dt_ctrylastcheck 	"`dt_ctrycheck'" "' 					_n
			file write `out' `"		return local dt_ctryupdate  "`newctryupdate'" "' 					_n  
			file write `out' `""' 					_n
			file write `out' `"end"' 					_n	

			file close `out'

			findfile _parameters.ado, `path'
			copy `out2'  `r(fn)' , replace

			
			noi di in smcl ""
			noi di in w in smcl in y "{bf:FULL UPDATE COMPLETED.}"
			noi di in smcl ""
			noi di in smcl in g "{hline}"
			noi di in smcl ""

			break

		}
		
	}
	
	discard

end
