*******************************************************************************
* _api_read                                                                   
*! v 15.2  	8Mar2019               by Joao Pedro Azevedo
*	flexible API address
* 	fix API query when option query was not selected
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
						query(string)		///
						nopreserve			///
						verbose 			///
							]

		if ("`verbose'" == "") {
			local noi ""
		}
		else {
			local noi "noi "
		}
							
							
		quietly {
	*======================== 		set up     	===========================================*/
			
		set checksum off
		
		if ("`nopreserve'" == "") {
			return add
		}
		
		tempfile in out source out3 source3 hlp1 hlp2 indicator help indicator1 
		tempname in2 in3 out2 in_tmp saving source1 source2 hlp hlp01 hlp02
			   
		if ("`single'"  == "") {
			local single "single"
		}
		
	*========================		api			 ===========================================*/
	
		if ("`query'" == "") {
			local query1 "http://api.worldbank.org/v2/indicators/?per_page=`per_page'&page=`page'"
		}
		else {
			local query1 "`query'?per_page=`per_page'&page=`page'"
		}
		
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
							local line`l' = subinstr(`"`line'"', `"""', "", .)
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
*							noi di ""
*							noi di `"`line'"'
*							noi di ""
*							noi di "`line`l''"
							return local line`l'  "`line`l''"
						}
				   		
						if ("`parameter'" != "") {
						
							local new_parameter ""					/* clear list */
							local multiparametersinsingleline ""	/* clear list */

							/* Replace '?' by "_" in all parameter names */
							
							foreach name in `parameter' {

								if (strmatch("`name'","*?*") == 1) {
									local parorg = subinstr("`name'","?"," ",.)
									local name = subinstr("`name'","?","_",.)
									local line`l' = subinstr(`"`line`l''"',"`parorg'","`name'",.)

								}
								
								local new_parameter "`new_parameter' `name' "
							
							}
							
							/* Screen how many (and which) parameters per line */

							local c = 0

							foreach name in `new_parameter' {
							
								if (strmatch(`"`line`l''"',"*`name'*") == 1) {
									local c = 1 + `c'
									local multiparametersinsingleline "`multiparametersinsingleline' `name'"
								}
								
							}

							if (`c'== 1) {
								`noi' di "--------------------------"
								`noi' di "`c': single: `multiparametersinsingleline' : `stub'"
								`noi' di "`line`l''"
							}
							if (`c' >= 2) {
								`noi' di "--------------------------"
								`noi' di "`c': multi: `multiparametersinsingleline' : `stub'"
								`noi' di "`line`l''"
							}
							
							/* Extract only relevant parameters as determined by previous loop */
							
							local k = 0
							
							foreach name in `multiparametersinsingleline' {
								
								local k = 1 + `k'

								if (`k'==1) {
									local stub = word(subinstr("`name'","_"," ",.),1)
									`noi' di "stub: `stub'"
								}
								
								if (strmatch(`"`line`l''"',"*`name'*") == 1) {
						
									if (strmatch(`"`line`l''"',"*=*") == 1) {
									
										local line`l' = subinstr(`"`line`l''"',"</wb:`name'>","",.)
										
										local line`l' = subinstr(`"`line`l''"',"<wb:","",.)
									
										if (`k'<`c') {
										
											local nextparameter = word("`multiparametersinsingleline'",(`k'+1))
									
											local str =strpos(`"`line`l''"',`"`name'="')
											
											local end =strpos(`"`line`l''"',"`nextparameter'")
										
											`noi' di "`k' `c' : `nextparameter' : stub: `stub'"
											`noi' di "--------------------------"
											`noi' di ""

										
										}
										if (`k'==`c')  {
										
											local str =strpos(`"`line`l''"',`"`name'="')
											
											local end =strpos(`"`line`l''"',`"</wb:`stub'>"')
											*local end =length(`"`line`l''"')

										}
										
										
										if (`end' == 0) {
											local end = 50
										}
										
										local len = `end'-`str'
									
*										noi di ""
*										noi di "`name' : `stub' : local len = `end'-`str'"

										local tmp = substr(`"`line`l''"',`str',(`end'-1))
										local tmp = subinstr(`"`tmp'"',`"`name'="',"",.)
										local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)
										local tmp = trim("`tmp'")
									}
									
									if (strmatch(`"`line`l''"',"*=*") != 1) {
									
										local tmp = subinstr(`"`line`l''"',"<wb:`name'>","",.)
										local tmp = subinstr(`"`line`l''"',"<wb:`name'","",.)
										local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)
*										noi di `"local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)"'
										local tmp = trim("`tmp'")
									}
									
									local tmp = subinstr(`"`tmp'"',"/"," ",.)
									local tmp = subinstr(`"`tmp'"',">"," ",.)
									local tmp = trim("`tmp'")
																		
									return local `name'`l' `tmp'

									`noi' di "`name'`l': `tmp'"
									
								}
								
								`noi' di "--------------------------"
								`noi' di ""

								
							}
							
							local stub ""
						}
					}
					
				}
				

		file close `in2'
		
		return local date = c(current_date)
		return local time = c(current_time)

	}
	
	end
