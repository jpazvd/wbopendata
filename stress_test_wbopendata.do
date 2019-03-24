global root "C:\GitHub_myados"
*global root "C:\Users\wb255520\Documents\myados"

*********************************************************************

set more off

*cd "$root\wbopendata\src"
*shell git checkout qa
*discard

which wbopendata
which _query
which wbopendata.sthlp

*********************************************************************

local skipnumber = 1
local trimnumber = 1
local indicator1 "i/indicators.txt"
local out "test_protocol_v15.txt"

*********************************************************************

*********************************************************************


tempfile in2 out2
tempname in2 in3 out2 in_tmp saving source1 source2 hlp hlp01 hlp02
		   
   
file open `in2'     using 	`indicator1'		, read
file open `out2'    using 	`out'     		, write text append


file write `out2' "type, seq , ctry, indicator, topic, rc, date, time" _n


cap: wbopendata, country(chn - China) clear
local rc = _rc
local date = c(current_date)
local time = c(current_time)
file write `out2' "1, -9 , chn, wdi , all, `_rc', `date', `time'" _n


forvalues t = 1(1)12 {
	cap: wbopendata, language(en - English) topics(`t') clear
	local rc = _rc
	local date = c(current_date)
	local time = c(current_time)
	file write `out2' "2, -9 , all , all , `t', `_rc', `date', `time' " _n
}
	


file read `in2' line

	local l = 0

		while !r(eof) {
		
			local ++l
        
			file read `in2' line
        
			if(`l'>`skipnumber') {
						
                local line = subinstr(`"`line'"', `"""', "", .)
				
				local indicator`l' = word("`line'",1)
					
				noi di "`l' - `indicator`l''"
				
							
			}
			
		}
		

di "`l'"
		
local l = `l'-1
		
forvalues i = 1(1)`l' {

	noi di "`i'"

	cap: wbopendata, indicator(`indicator`i'') clear
			
	local rc = _rc
	
	local date = c(current_date)
	
	local time = c(current_time)
					
	file write `out2' "3, `i' , all, `indicator`i'' , all, `rc' , `date', `time'" _n

}
	


cap: wbopendata, update
local rc = _rc
local date = c(current_date)
local time = c(current_time)
file write `out2' "4, -9 , -9, update , all, `rc' , `date', `time'" _n

	
	
file close `out2'


/*	
						
			/*

	