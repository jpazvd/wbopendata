*! version 15.0 		<8Feb2019>		JPAzevedo

program define _wbopendata, rclass

version 9

syntax , [ NODISPLAY ]

return add

_parameters

local datef = c(current_date)
local time = c(current_time)
local check  "`datef' `time'"
local dt_update = r(dt_update)


	_api_read,  parameter(total)
	local newnumber = r(total1) 
	local date r(date)
	
	qui if (`r(number_indicators)' != `newnumber') {

		if ("`nodisplay'" == "") {

			noi di in g in smcl "{hline}"
			noi di in w in smcl "{title:wbopendata - Indicators check}"
			noi di in smcl ""
			noi di in g in smcl "Existing Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "New Number of Indicators: " in r "{bf: `newnumber'}"
			noi di in g in smcl "Last update: " in y "{bf: `r(dt_update)'}"
			noi di in g in smcl "Latest check: " in y "{bf: `r(dt_lastcheck)'}"
			noi di in g in smcl "Current check: " in y "{bf: `check'}"
			noi di in smcl ""
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
		noi di in w in smcl in y "{bf:...UPDATE COMPLETED}"
		noi di in smcl ""
		noi di in smcl in y "{bf:New indicator list created}"
		noi di in smcl ""
		noi di in smcl in y "{bf:New indicator documentation created.}"
		noi di in smcl ""
		noi di in smcl in y "See {bf:{help wbopendata_indicators##indicators:{bf:Indicators List}}}"
		noi di in smcl in g "{hline}"

		break

	}
	
	qui else {

		if ("`nodisplay'" == "") {

			noi di in g in smcl "{hline}"
			noi di in w in smcl "{title:wbopendata - Indicators check}"
			noi di in smcl ""
			noi di in g in smcl "Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "Last update: " in y "{bf: `r(dt_update)'}"
			noi di in g in smcl "Latest check: " in y "{bf: `r(dt_lastcheck)'}"
			noi di in smcl ""
			noi di in w in smcl "See {bf:{help wbopendata_indicators##indicators:Indicators List}}"
			noi di in g in smcl "{hline}"
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
		file write `out' `"		return local dt_update "`dt_update'" "' 					_n
		file write `out' `"		return local dt_lastcheck  "`datef' `time'" "' 					_n  
		file write `out' `""' 					_n
		file write `out' `"end"' 					_n	
		

		file close `out'

		findfile _parameters.ado, `path'
		copy `out2'  `r(fn)' , replace

	}

	discard

end
