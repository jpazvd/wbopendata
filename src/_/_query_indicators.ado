********************************************************************************
*! v 15.2  	8Mar2019               by Joao Pedro Azevedo   
*	initial commit
/*******************************************************************************

cd "C:\GitHub_myados\wbopendata\src"

! git checkout dev

discard

*****************************************************************

_query_indicators , indicator("2.0.cov.Math.pl_3.prv")
tab indicatorcode
list

_query_indicators , indicator("2.0.cov.Math.pl_3.prv") source
tab indicatorcode
list

_query_indicators , indicator(BX.GSR.TOTL.CD)
tab indicatorcode
list

_query_indicators , indicator(BX.GSR.TOTL.CD) source
tab indicatorcode
list


*****************************************************************
* Multiple indicators per_page does not seem to work
* skip patters are different due to different numbers of topics

_query_indicators , per_page(10) page(1)
tab indicatorcode


_query_indicators , per_page(10) page(2)
tab indicatorcode


_query_indicators , per_page(10) page(100)
tab indicatorcode


_query_indicators , per_page(20) page(1)
tab indicatorcode


_query_indicators, per_page(20) page(1)
tab indicatorcode

_query_indicators, per_page(20) page(2)
tab indicatorcode

_query_indicators, per_page(70) 
tab indicatorcode


_query_indicators, per_page(200) page(1)
tab indicatorcode

_query_indicators, per_page(2000) 
tab indicatorcode
drop if indicatorcode == "."
bysort indicatorcode : gen dups = _n
bysort indicatorcode : gen tot = _N

*************************************************

_query_indicators, per_page(1) cmax(10)
tab indicatorcode

_query_indicators, per_page(1) page(647) cmax(653) noi nopreserve
tab indicatorcode

/* break */
set more off
_query_indicators, per_page(1) page(7687) cmax(16638) nopreserve using(tmp3tmp.csv)
tab indicatorcode

/* break */
_query_indicators, per_page(1) page(7680) cmax(7693) noi nopreserve using(tmp.csv)
tab indicatorcode


_query_indicators, per_page(1) page(1726) cmax(1728) noi nopreserve source
tab indicatorcode

set trace on
_query_indicators, per_page(1) page(1728) cmax(1728) noi nopreserve verbose



_query_indicators, per_page(1) cmax(100) 
tab indicatorcode


clear
set more off
_query_indicators, per_page(1) cmax(16638) using(tmp2tmp)

set more off
_query_indicators, per_page(1) cmax(700)


set trace on
set tracedepth 1



*****************************************************
* Examples of multiple topics in a single indicator

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.TOTL.CD") ///
		parameter( indicator?id name topic?id ) 
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/BX.GSR.TOTL.CD") ///
		parameter( indicator?id name topic?id source?id sourceNote sourceOrganization ) ///
		verbose 
return list

*****************************************************

_api_read, list query("http://api.worldbank.org/v2/indicators/6.1_LEG.CA") ///
		parameter( indicator?id name topic?id ) verbose
return list

_api_read, list query("http://api.worldbank.org/v2/indicators/6.1_LEG.CA") ///
		parameter( indicator?id name topic?id ) 
return list


_query_indicators, indicator("6.1_LEG.CA") nopreserve

_query_indicators, indicator("6.0.GDPpc_constant") nopreserve



_query_indicators, indicator("BX.GSR.TOTL.CD")
tab indicatorcode

_query_indicators, indicator(IN.HLTH.HIVDEATH.EST) nopreserve

_api_read, list query("http://api.worldbank.org/v2/indicators/IN.HLTH.HIVDEATH.EST") ///
		parameter( indicator?id name topic?id source?id sourceNote sourceOrganization ) ///
		verbose 
return list


*******************************************************************************/

program define _query_indicators , rclass

	version 9.0

	 syntax                                	///
                 ,                         	///
							[				///
                        per_page(int -1)	///
						page(int -1) 		///
						indicator(string)	///
						cmax(int 1)			///
						NOIsily				///
						NOPReserve			///
						verbose				///
						using(string)		///
						source 				///
							]
	
	
	
	
	*preserve

quietly {

	if ("`source'" == "") {
		local sourceHeader 	""
		local sourceVar 	""
		local sourcePar 	""
		local sl			""
	}
	if ("`source'" != "") {
		local sourceHeader 		"#SourceID#SourceNote#SourceOrganization"
		local sourceVar 		"\`source'#\`sourceNote'#\`sourceOrg'#"
		local sourcePar			"source?id sourceNote sourceOrganization"
		local sl				" 5 6 7 "
	}
	
	************************************************************************/
	/* if specific indicator is provided						           */				

	if ("`indicator'" != "") {
		local query1 `"http://api.worldbank.org/v2/indicators/`indicator'"'
		local pages = 1
		local maxpp = 1
		local min = 1
		local max = 1
		local linequery "  query(`"`query1'"')  "
	}
	else {
		local linepp	" per_page(\`maxpp')  "
		local linep 	" page(\`p')  "
	}
		
	*****************************************************************************/
	/* Identify the total number of indicators available (default value all)	*/
	
	if (`per_page' == -1) & ("`indicator'" == "") {
	
		_api_read ,  ///
			single ///
			parameter(page pages total) nopreserve 

		local maxpp = real("`r(total1)'")
		local page	= 1
		local min = 1
		local max = 1
		
		`noi' di "Total Number: `maxpp'"

	}

	************************************************************************/
	/* Identify the total number of pages as per the total number of indicators	*/				
	/* default value : single page extraction 	*/

	if (`per_page' == -1) & ("`indicator'" == "")  {
	
		`noisily' _api_read ,  ///
			single ///
			per_page(`maxpp') ///
			parameter(page pages total) nopreserve

		local pages = r(pages1)
		local maxpp = `per_page' 

	}
		
	if (`per_page' != -1) & ("`indicator'" == "")  {
	
		`noisily' _api_read ,  ///
			single ///
			per_page(`per_page') ///
			parameter(page pages total) nopreserve

		local pages = r(pages1)
		local maxpp	= `per_page' 

	}
	
	
	************************************************************************

	local maxk = `maxpp'-1

	************************************************************************

	if (`page' == -1) & ("`indicator'" == "")  {
		local min = 1
		local pages = `pages'
	}
	if (`page' != -1) & ("`indicator'" == "")  {
		local min = `page'
		local pages = `page'
	}
	
	************************************************************************

	if (`cmax' != .) {
		local pages = `cmax'
	}	
	
	if ("`using'" == "") {
		tempfile tmpindicatorlist
		local file `tmpindicatorlist'
	}
	if ("`using'" != "") {
		local file `using'
	}
	

	tempname out

	file open `out' using `file' , text write replace

	file write `out'  `"indicatorcode#indicatorname#topiccode1#topicname1#topiccode2#topicname2#topiccode3#topicname3#topiccode4#topicname4#topiccode5#topicname5`sourceHeader'"' _n
			
	forvalues p = `min'(1)`pages' {
	
		noi di "`p'"

		`noisily' _api_read ,  ///
			`linep' `linepp'  `linequery' ///
			list nopreserve ///
			parameter( indicator?id name topic?id `sourcePar' ) `verbose' 
	    
		local commandline `" _api_read ,  `linep' `linepp'  `linequery' list parameter( indicator?id name topic?id `sourcePar') `verbose' "'
		
		`noisily' di ""
		`noisily' di in smcl `"{p 6 16 2} `commandline' {p_end}"' 
		`noisily' di ""
	
		forvalues pp = 0(1)`maxk' {
			
			qui foreach jj in 2 3 `sl' 9 10 11 12 13 {
						
				local kk = `jj'+(10*`pp')
					
				local `jj' `kk'
					
			}
				
			local indicator 		= trim(r(indicator_id`2'))
			local name 				= trim(r(name`3'))
			
			if ("`source'" != "") {
				local source			= trim(r(source_id`5'))
				local sourceNote		= trim(r(sourceNote`6'))
				local sourceOrg			= trim(r(sourceOrganization`7'))
			}
			
			cap: local topic1 			= trim(r(topic_id`9'))
			if _rc==0 { 
				local kk = 1 
			}
			cap: local topic2 			= trim(r(topic_id`10'))
			if _rc==0 { 
				local kk = 1 + `kk' 
			}
			cap: local topic3 			= trim(r(topic_id`11'))
			if _rc==0 { 
				local kk = 1 + `kk' 
			}
			cap: local topic4 			= trim(r(topic_id`12'))
			if _rc==0 { 
				local kk = 1 + `kk' 
			}
			cap: local topic5 			= trim(r(topic_id`13'))
			if _rc==0 { 
				local kk = 1 + `kk' 
			}

			forvalues t = 1(1)`kk' {
				
				local topiccode`t'        	= trim(word("`topic`t''",1))
					
				if length("`topiccode`t''")<=2 {
					local topicname`t' 			= subinstr("`topic`t''","`topiccode`t''","",.) 				
				}
				
				foreach var in	 topiccode`t' topicname`t' {

					local `var' = trim("``var''")
						
				}
					
			}
			

			file write `out' `"`indicator'#`name'#"' 

			forvalues t = 1(1)5 {
				file write `out' `"`topiccode`t''#`topicname`t''#"' 
			}
			
			file write `out' `"`sourceVar'`p'#`pp'#`commandline' "' _n 

			
			local indicator 			""
			local name 					""
			if ("`source'" != "") {
				cap: local source		""
				cap: local sourceNote	""
				cap: local sourceOrg	""
			}
			local topic_id 				""
			forvalues t = 1(1)5 {
				local topic`t'			""
				local topicname`t' 		""
				local topiccode`t'		""
			}

		}

	}
		
	file close `out'

	*******************************************************************************

	insheet using `file' , delimiter("#") names clear 

	*list
		
		/*
		
		
		rename (countrycode_iso2 - latitude) values_=

		reshape long values_ , i(countrycode) j(variable) string

		drop if values_ == ""

		sort variable countrycode

		gen seq = _n

		levelsof variable

		local datef = c(current_date)
		local time = c(current_time)

		levelsof variable

		qui foreach variable in `r(levels)' {


			tempfile tmp`variable'

			tempname out_`variable'

			file open `out_`variable'' using `tmp`variable'' , text write replace


			di "`variable'"

			file write `out_`variable'' `"*! _`variable' <`datef' : `time'>			by João Pedro Azevedo"' 	_n
			file write `out_`variable''  "	" _n

			
			file write `out_`variable''  "	program define _`variable' " _n

			if (strmatch("latitude longitude","*`variable'*") == 0)  {
			
				
				file write `out_`variable''  "	" _n
				file write `out_`variable''  "	" _n
				file write `out_`variable''  `"		gen `variable' = ""  "' _n

				sum seq if variable == "`variable'"
				local min = r(min)
				local max = r(max)
				
				forvalues ctry = `min'(1)`max'  {

					local value = values_  			in `ctry'
					local ctrycode = countrycode 	in `ctry'
				
					file write `out_`variable''  `"		replace `variable' = "`value'"	if countrycode == "`ctrycode'"  "' _n
					
				}

			}
			
			if (strmatch("latitude longitude","*`variable'*") == 1)   {
			
				
				file write `out_`variable''  "	" _n
				file write `out_`variable''  "	" _n
				file write `out_`variable''  `"		gen  double `variable' = .  "' _n
				
				sum seq if variable == "`variable'"
				local min = r(min)
				local max = r(max)
				
				forvalues ctry = `min'(1)`max'  {
				
					local value = values_  			in `ctry'
					local ctrycode = countrycode 	in `ctry'
				
					file write `out_`variable''  `"		replace `variable' = real("`value'")	if countrycode == "`ctrycode'"  "' _n
					
				}

			}

			file write `out_`variable''  "	" _n
			file write `out_`variable''  "	" _n
			file write `out_`variable''  "	end " _n

			file close `out_`variable''

			******************************************************
			
			findfile _`variable'.ado, `path'
			copy  `tmp`variable''  `r(fn)' , replace

		}
		*/
		*******************************************************************************

*	restore

	if ("`nopreserve'" == "") {
		return add
	}
	

}
	
end


*******************************************************************************
* v 15.2  	8Mar2019               by Joao Pedro Azevedo   
*
*	query to country attributes using API (requires _api_read.ado)
*	generate country attributes tables
*	update country attribute tables
*	atrributes currently supported:
*		indicatorcode
*		indicatorname
*		topiccode
*		topicname
*
*******************************************************************************
