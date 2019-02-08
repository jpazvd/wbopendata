*! version 14.3 		<5Feb2019>		JPAzevedo

program define _wbopendata, rclass

version 9

syntax , [ NODISPLAY ]

return add

local number = 1546
local update "1 Feb 2019"
local lastcheck = c(current_date)
local check  = c(current_date)


if (td(`update')<td(`check')) { 
	noi di "Update < Check" 
}

local date 
local time = c(current_time)

return local number_indicators = `number' 
return local dt_update "`update'"
return local dt_check  "`check'"  


if ("`nodisplay'" == "") {

	noi di in g in smcl "{hline}"
	noi di in w in smcl "{title:wbopendata - Indicators check}"
	noi di in smcl ""
	noi di in g in smcl "Number of Indicators: " in y "{bf: `number'}"
	noi di in g in smcl "Last update: " in y "{bf: `update'}"
	noi di in g in smcl "Latest check: " in y "{bf: `check'}"
	noi di in smcl ""
	noi di in w in smcl "{bf:{help wbopendata_indicators##indicators:Indicators List}}"
	noi di in g in smcl "{hline}"
	noi di in smcl ""

}

end
