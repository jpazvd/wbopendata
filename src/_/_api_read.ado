*******************************************************************************
* _api_read                                                                   
*! v 15.2  	8Mar2019               by Joao Pedro Azevedo
*	flexible API address
* 	fix API query when option query was not selected
/*******************************************************************************


cd "C:\GitHub_myados\wbopendata\src"

! git checkout dev

discard

/* Coutries */

_api_read , query("http://api.worldbank.org/v2/countries/") ///
		nopreserve single parameter(page pages total)
return list

_api_read , query("http://api.worldbank.org/v2/countries/") ///
		per_page(5) page(1) list nopreserve ///
		parameter( country?id iso2Code name region?id adminregion?id incomeLevel?id lendingType?id iso2code capitalCity latitude longitude )
return list


			
/* Indicators */

_api_read, single parameter(pages per_page total)
return list

_api_read, per_page(50) single parameter(pages per_page total)
return list

_api_read, per_page(200) single parameter(pages per_page total)
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.NFSV.CD")
return list

cls
clear
_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.OSRV.CD") ///
		nopreserve
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.TOTL.CD") ///
		nopreserve parameter( indicator?id name topic?id ) 
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.TOTL.CD") ///
		nopreserve parameter( indicator?id name topic?id ) verbose
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/6.1_LEG.CA") ///
		parameter( indicator?id name topic?id ) verbose
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/6.1_LEG.CA") ///
		parameter( indicator?id name topic?id ) 
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/IN.HLTH.HIVDEATH.EST") ///
		parameter( indicator?id name topic?id source?id sourceNote sourceOrganization ) ///
		verbose 
return list

set trace on
_api_read , page(1728) per_page(1) list parameter( indicator?id name topic?id ///
		source?id sourceNote sourceOrganization) verbose
return list

local sourceNote "Control of Corruption captures perceptions of the extent to which public power is exercised for private gain, including both petty and grand forms of corruption, as well as capture of the state by elites and private interests. Estimate gives the country's score on the aggregate indicator, in units of a standard normal distribution, i.e. ranging from approximately -2.5 to 2.5."
di "`sourceNote'"
local pchar = length("`sourceNote'")
di `pchar'


*******************************************************************************/


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
								
								local pchar = length(`"`line`l''"')
								
								local tmp = word(substr(`"`line`l''"',strpos(`"`line`l''"',`"`name'="'),`pchar'),1)

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

							/* BEGIN: Replace '?' by "_" in all parameter names */
							
							local new_parameter ""					/* clear list */
							local multiparametersinsingleline ""	/* clear list */

							foreach name in `parameter' {

								if (strmatch("`name'","*?*") == 1) {
									local parorg = subinstr("`name'","?"," ",.)
									local name = subinstr("`name'","?","_",.)
									local line`l' = subinstr(`"`line`l''"',"`parorg'","`name'",.)

								}
								
								local new_parameter "`new_parameter' `name' "
							
							}
							
							/* END: Replace '?' by "_" in all parameter names */
							
							
							/* BEGIN: Screen and Report how many (and which) parameters per line */

							local c = 0

							foreach name in `new_parameter' {
							
								if (strmatch(`"`line`l''"',"*`name'*") == 1) {
									local c = 1 + `c'
									local multiparametersinsingleline "`multiparametersinsingleline' `name'"
								}
								
							}

							if (`c'== 1) {
								`noi' di in g ""
								`noi' di in g  "Original Parameters: `parameter'"
								`noi' di in g  "New Parameters: `new_parameter'"
								`noi' di in g  ""
								`noi' di in y "--------------------------"
								`noi' di in y "SINGLE START VAR: "
								`noi' di in y "BEFORE LOOP"
								`noi' di in y "--------------------------"
								`noi' di in g "`c': single: `multiparametersinsingleline' "
								`noi' di "`line`l''"
							}
							if (`c' >= 2) {
								`noi' di in g ""
								`noi' di in g  "Original Parameters: `parameter'"
								`noi' di in g  "New Parameters: `new_parameter'"
								`noi' di in g  ""
								`noi' di in y "--------------------------"
								`noi' di in y "MULTI START VAR: "
								`noi' di in y "BEFORE LOOP"
								`noi' di in y "--------------------------"
								`noi' di in g "`c': multi: `multiparametersinsingleline' "
								`noi' di "`line`l''"
							}
							/* END: Screen and Report how many (and which) parameters per line */
							
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
										
*										local line`l' = subinstr(`"`line`l''"',"<wb:`name'>","",.)

										local line`l' = subinstr(`"`line`l''"',"<wb:","",.)
									
										if (`k'<`c') {
										
											local nextparameter = word("`multiparametersinsingleline'",(`k'+1))
									
											local str =strpos(`"`line`l''"',`"`name'="')
											
											local end =strpos(`"`line`l''"',"`nextparameter'")
										
											`noi' di  ""
											`noi' di in g "start: 	`str'"
											`noi' di in g "end:	`end'"
											`noi' di  in g "`k'<`c' " in g ": `nextparameter' : stub: `stub'"
											`noi' di  in y "--------------------------"
											`noi' di  in y "INSIDE THE LOOP (K<C)"
											`noi' di  in y "--------------------------"
											`noi' di  in g ""
											`noi' di `"`line`l''"'
											`noi' di  in g ""

										
										}
										if (`k'==`c')  {
										
											local str =strpos(`"`line`l''"',`"`name'="')
											if (`str'==0) {
												local str =strpos(`"`line`l''"',`"`name'>"')
												local adj = length(`"`name'>"')
												local str = `str'+`adj'
											}
											local end =strpos(`"`line`l''"',`"</wb:`stub'>"')
											if (`end'==0) {	
												local end =length(`"`line`l''"')
											}

											`noi' di in g "start: 	`str'"
											`noi' di in g "end:	`end'"
											`noi' di in g "`k'=`c' " in g ": `nextparameter' : stub: `stub'"
											`noi' di  in y "--------------------------"
											`noi' di  in y "INSIDE THE LOOP (K=C)"
											`noi' di  in y "--------------------------"
											`noi' di  in g ""
											`noi' di `"`line`l''"'
											`noi' di  in g ""

										}
										
										
										if (`end' == 0) {
											local end = 50
										}
										
										local len = `end'-`str'
									
										`noi' di `"`line`l''"'

									
										local tmp = substr(`"`line`l''"',`str',(`end'-1))
										local tmp = subinstr(`"`tmp'"',`"`name'="',"",.)
										local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)
*										local tmp = subinstr(`"`line`l''"',"&amp;","and",.)
										local tmp = trim("`tmp'")

										`noi' di "`tmp'"

									}
									
									if (strmatch(`"`line`l''"',"*=*") != 1) {
									
										local tmp = subinstr(`"`line`l''"',"<wb:`name'>","",.)
										local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)
*										noi di `"local tmp = subinstr(`"`tmp'"',`"</wb:`stub'>"',"",.)"'
*										local tmp = subinstr(`"`line`l''"',"&amp;","and",.)
										local tmp = trim("`tmp'")
									}
									
									local tmp = subinstr(`"`tmp'"',"/"," ",.)
									local tmp = subinstr(`"`tmp'"',">"," ",.)
									local tmp = subinstr(`"`tmp'"',"&amp;","and",.)
									local tmp = trim("`tmp'")
																		
									return local `name'`l' "`tmp'"

									`noi' di "`name'`l': `tmp'"
									
								}
								
								`noi' di in y "--------------------------"
								`noi' di in y " END VAR: `name'			 "
								`noi' di in y "--------------------------"
								`noi' di in g ""

								
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
