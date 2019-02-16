*! version 15.0.2 			<16Feb2019>		JPAzevedo
*	add update query, update check and update options
* version 15.0.1	 		<11Feb2019>		JPAzevedo
*	add latest check value to default report
* version 15.0.0 			<8Feb2019>		JPAzevedo
*	Original

program define _wbopendata, rclass

version 9

syntax , 								///
			UPDATE 						///
			[ 							///
				NODISPLAY 				///
				QUERY		            ///
				CHECK		            ///
		  ]

	return add

    if  wordcount("`query'   `update'    `check'")>2 {
		noi di  as err "Invalid option: two many parameters."
		exit 198
    }

	_parameters

	local number_indicators = r(number_indicators)
	local datef = c(current_date)
	local time = c(current_time)
	local dt_check  "`datef' `time'"
	local dt_update = r(dt_update)

	
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
			noi di in g in smcl "Possible actions"
			noi di in smcl ""
			noi di in g in smcl 	`" {stata _wbopendata, update check : Check for available updates} "'         "  (or type -_wbopendata, update check-)"
			noi di in g in smcl "	See current {bf:{help wbopendata_indicators##indicators:indicators list}}"
			noi di in smcl ""
			noi di in g in smcl "{hline}"

		}
	}
	
	
	qui if ("`query'" == "") & ("`check'" != "") & ("`update'" != "") {

		_api_read,  parameter(total)
		local newnumber = r(total1) 
		local date r(date)
	
		
		if ("`nodisplay'" == "") {

			noi di in smcl ""
			noi di in g in smcl "{hline}"
			noi di in smcl ""
			noi di in g in smcl "Indicators update status"
			noi di in smcl ""
			noi di in g in smcl "	Existing Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
			noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `dt_check'}"
			noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
			noi di in smcl ""
			noi di in g in smcl "Possible actions"
			noi di in smcl ""
			if (`number_indicators' == `newnumber') {
				noi di in g in smcl "	Do nothing; all files are up to date."
				noi di in g in smcl "	See current {bf:{help wbopendata_indicators##indicators:indicators list}} " 
			}
			if (`number_indicators' != `newnumber') {
				noi di in g in smcl 	`" {stata _wbopendata, update : Download available updates} "'         "  (or type -_wbopendata, update-)"
				noi di in g in smcl "	See current {bf:{help wbopendata_indicators##indicators:indicators list}} " in r "(this list is no longer uptodate)"
			}
			noi di in smcl ""
			noi di in g in smcl "{hline}"

		}
		
		tempfile in out2
		tempname in2 out
			
		findfile _parameters.ado, `path'
			
*		file open `out'    using 	`r(fn)'    		, write text replace
		file open `out'    using 	`out2'   		, write text append 
				
				
		file write `out' `"*! _parameters <`datef' : `time'> "' 					_n
		file write `out' `""' 					_n
		file write `out' `"program define _parameters, rclass"' 					_n
		file write `out' `""' 					_n
		file write `out' `"		return add"' 					_n
		file write `out' `""' 					_n
		file write `out' `"		return local number_indicators = `newnumber'"' 					_n 
		file write `out' `"		return local dt_update "`dt_update'" "' 					_n
		file write `out' `"		return local dt_lastcheck  "`datef' `time'" "' 					_n  
		file write `out' `""' 					_n
		file write `out' `"end"' 					_n	
			
		file close `out'
		findfile _parameters.ado, `path'

		copy `out2'  `r(fn)' , replace

	}
	

	
	
	
	qui if ("`query'" == "") & ("`check'" == "") & ("`update'" != "") {

		_api_read,  parameter(total)
		local newnumber = r(total1) 
		local date r(date)
		
		if (`number_indicators' == `newnumber') {
			noi _wbopendata, update check
		}
		
		if (`number_indicators' != `newnumber') {

			if ("`nodisplay'" == "")  {

				noi di in smcl ""
				noi di in g in smcl "{hline}"
				noi di in smcl ""
				noi di in g in smcl "Indicators update status"
				noi di in smcl ""
				noi di in g in smcl "	Existing Number of Indicators: " in w "{bf: `r(number_indicators)'}"
				noi di in g in smcl "	New Number of Indicators:      " in y "{bf: `newnumber'}"
				noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
				noi di in g in smcl "	New update available:          " in w "{bf: yes}     " in g " (as of `dt_check'}"
				noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
				noi di in smcl ""
				noi di in g in smcl "Possible actions"
				noi di in w in smcl in y "{bf:UPDATE IN PROGRESS...}"
				noi di in smcl ""

			}
		
		
			tempfile in out2
			tempname in2 out
			
			findfile _parameters.ado, `path'
			
	*		file open `out'    using 	`r(fn)'    		, write text replace
			file open `out'    using 	`out2'   		, write text append 
				
				
			file write `out' `"*! _parameters <`datef' : `time'> "' 					_n
			file write `out' `""' 					_n
			file write `out' `"program define _parameters, rclass"' 					_n
			file write `out' `""' 					_n
			file write `out' `"		return add"' 					_n
			file write `out' `""' 					_n
			file write `out' `"		return local number_indicators = `newnumber'"' 					_n 
			file write `out' `"		return local dt_update "`datef' `time'" "' 					_n
			file write `out' `"		return local dt_lastcheck  "`datef' `time'" "' 					_n  
			file write `out' `""' 					_n
			file write `out' `"end"' 					_n	
			

			file close `out'

			findfile _parameters.ado, `path'
			copy `out2'  `r(fn)' , replace
			
			_wbopendata_update, update `preserveout'
			
			noi di in smcl ""
			noi di in w in smcl in g "{bf:...UPDATE COMPLETED}"
			noi di in smcl ""
			noi di in smcl in g "{bf:New indicator list created}"
			noi di in smcl ""
			noi di in smcl in g "{bf:New indicator documentation created.}"
			noi di in smcl ""
			noi di in smcl in g "{bf:See } {bf:{help wbopendata_indicators##indicators:{bf:Indicators List}}}"
			noi di in smcl ""
			noi di in smcl in g "{hline}"
			noi di in smcl ""

			break

		}
		
	}
	
	discard

end
