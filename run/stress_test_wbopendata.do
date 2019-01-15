*********************************************************************

cd "C:\Users\wb255520\Documents\myados\wbopendata\src"
shell git checkout qa
discard

which wbopendata
which _query
which wbopendata.sthlp

*********************************************************************

local skipnumber = 1
local trimnumber = 1
local indicator1 "i/indicators.txt"
local out "test_protocol_v14.txt"

*********************************************************************


*********************************************************************


tempfile in2 out2
tempname in2 in3 out2 in_tmp saving source1 source2 hlp hlp01 hlp02
		   
   
file open `in2'     using 	`indicator1'		, read
file open `out2'    using 	`out'     		, write text replace



cap: wbopendata, country(chn - China) clear
file write `out2' "3, `l' , chn, all , all, `_rc'" _n


forvalues t = 1(1)12 {
	cap: wbopendata, language(en - English) topics(`t') clear
	file write `out2' "3, `l' , all, all , `t',  `_rc'" _n
}
	
file read `in2' line
	local l = 0
        qui while !r(eof) {
			local ++l
            file read `in2' line
            if(`l'>`skipnumber') {
			
				noi di "`l'"
			
                local line = subinstr(`"`line'"', `"""', "", .)
				
				local indicator = word("`line'",1)
					
				cap: wbopendata, indicator(`indicator') clear
					
                file write `out2' "3, `l' , all, `indicator' , all, `_rc'" _n
					
				}
			}
			
             
file close `out2'
			
			
			

