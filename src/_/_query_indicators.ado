/*******************************************************************************
*! v 15.2  	8Mar2019               by Joao Pedro Azevedo   
*	initial commit



_query_indicators , indicator(2.0.cov.Math.pl_3.prv)



_query_indicators , maxp(10) page(1)


_query_indicators, maxp(200) page(1)



_query_indicators, maxp(2000) page(1)
tab indicatorcode


*******************************************************************************/

program define _query_indicators , rclass

	version 9.0

	 syntax                                	///
                 ,                         	///
							[				///
                        per_page(int 1)		///
						page(int 1) 		///
						indicator(string)	///
						maxp(int -1) 		///
						pages(int -1)		///
							]
	
	
	
	if ("`indicator'" != "") {
		local query1 "http://api.worldbank.org/v2/indicators/`indicator'"
		local pages = 1
		local maxp = 1
		local linequery "  query("`query1'")  "
	}
	else {
		local linep `" page(\`p')  "'
	}
		
	
	
	*preserve

	************************************************************************/
	/* Identify the total number of indicators	(default value all)        */				
	
	if (`maxp' == -1) & ("`indicator'" == "") {
	
		qui _api_read ,  ///
			nopreserve ///
			single ///
			parameter(page pages total) ///

		local maxp = real("`r(total1)'")
		
		local linemaxp " per_page(`maxp') /// "

	}

	************************************************************************/
	/* Identify the total number of pages as per the total number of indicators	*/				
	/* default value : single page extraction 	*/

	if (`pages' == -1) & ("`indicator'" == "")  {
	
		local maxp 2000
	
		qui _api_read ,  ///
			nopreserve ///
			single ///
			per_page(`maxp') ///
			parameter(page pages total)

		local pages = r(pages1)

	}
		
	local maxk = `maxp'-1

	************************************************************************

	noi di "`maxp'"
	noi di "`pages'"

	************************************************************************


		tempfile tmpindicatorlist

		tempname out

		file open `out' using `tmpindicatorlist' , text write replace

		file write `out' " indicatorcode#indicatorname#topiccode#topicname" _n
			
		forvalues p = 1(1)`pages' {

			_api_read ,  ///
				`linep' `linequery' ///
				list ///
				nopreserve ///
				parameter( indicator?id name topic?id ) ///
				`linemaxp' 
				

				

			forvalues pp = 0(1)`maxk' {
			
				qui foreach jj in 2 3 9 {
						
					
					local kk = `jj'+(10*`pp')
					
					local `jj' `kk'
					
				}
				
				local indicator 		= r(indicator_id`2')
				local name 				= r(name`3')
				local topic 			= r(topic_id`9')

					
				foreach var in	 indicator name topic {

					local `var' = trim("``var''")
					
				}
				
				local topiccode        	= word("`topic'",1)
				
				if length("`topiccode'")==2 {
					local topicname 			= subinstr("`topic'","`topiccode'","",.) 				
				}

				di "`p' - `pp'"
				
				file write `out' " `indicator'#`name'#`topiccode'#`topicname' " _n
				
				local indicator 		""
				local name 				""
				local topic_id 			""
				local topiccode 		""
				local topicname 		""
				
			}

		}
		
		file close `out'

		*******************************************************************************

		insheet using `tmpindicatorlist' , delimiter("#") names clear 

		list
		
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
