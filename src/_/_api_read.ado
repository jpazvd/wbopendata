*******************************************************************************
* _api_read                                                                     *
*! v 15.0  	8Feb2019               by Joao Pedro Azevedo                     *
*******************************************************************************


program define _api_read, rclass

	*====================================================================================

	version 9
	
    syntax                                 	///
                 ,                         	///
							[				///
                        per_page(int 1)		///
						page(int 1) 		///
						qline(int 1) 		///
						skinumber(int 1) 	///
						trimnumber(int 1)	///
						single				///
						list				///
						parameter(string)	///
							]

							
		quietly {
	*======================== 		set up     	===========================================*/
			
		set checksum off
		
		return add
		
		tempfile in out source out3 source3 hlp1 hlp2 indicator help indicator1 
		tempname in2 in3 out2 in_tmp saving source1 source2 hlp hlp01 hlp02
			   
		if ("`single'"  == "") {
			local single "single"
		}
		
	*========================		api			 ===========================================*/

		local query1 "http://api.worldbank.org/v2/indicators?per_page=`per_page'&page=`page'"

		cap: copy "`query1'" "`indicator1'", text replace		

	*========================begin conversion ===========================================*/
	
	   
		file open `in2'     using 	`indicator1'		, read

		if ("`preserveout'" == "") {
			file open `out2'    using 	`out'     		, write text replace
		}
		else {
			file open `out2'    using 	out.txt    		, write text replace
		}
		file open `source2' using 	`indicator'  		, write text replace
		file open `hlp01'	using 	`hlp1', write text replace
		
		
			file read `in2' line
			
			local l = 0
				 
				qui while !r(eof) {
					
				   local ++l
				   file read `in2' line
					
				   if ("`single'" != "") {
				   
						if(`l' == `qline') {
							local line`l'' = subinstr(`"`line'"', `"""', "", .)
							return local line`l' "`line`l''"
						}
					
						if ("`parameter'" != "") {
						
							foreach name in `parameter' {
						
								local tmp = word(substr(`"`line`l''"',strpos(`"`line`l''"',`"`name'="'),50),1)

								local tmp = subinstr(`"`tmp'"',`"`name'="',"",.)
								
								return local `name'`l' `tmp'

							}
						}
					}
					
					
				   if ("`list'" != "") {
						
						if((`l'>`qline')) {
							local line`l' = subinstr(`"`line'"', `"""', "", .)
							return local line`l'  "`line`l''"
						}
				   		
						if ("`parameter'" != "") {
						
							foreach name in `parameter' {
						
								local tmp = word(substr(`"`line`l''"',strpos(`"`line`l''"',`"`name'="'),50),1)

								local tmp = subinstr(`"`tmp'"',`"`name'="',"",.)
								
								return local `name'`l' `tmp'

							}
						}
					}
					
				}
				

		file close `in2'
		
		return local date = c(current_date)
		return local time = c(current_time)

	}
	
	end
