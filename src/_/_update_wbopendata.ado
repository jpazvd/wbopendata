**********************************************************
*! v 16.3  	8Jul2020               by Joao Pedro Azevedo
* 	change API end point to HTTPS
**********************************************************

program define _update_wbopendata, rclass

version 9

syntax , 								///
			[ 							///
				NODISPLAY 				///
				UPDATE					///
				QUERY		            ///
				CHECK		            ///
				COUNTRYMETADATA			///
				INDICATORS				///
				FORCE					///
				ALL						///
				SHORT					///
				DETAIL					///
				NOHLP					///
				CTRYLIST				///
		  ]

	return add

*    if  wordcount("`query'   `update'    `check'")>2 {
*		noi di  as err "Invalid option: two many parameters."
*		exit 198
*    }

	if ("`nohlp'" != "") {
		local nohlp2 " nosthlp1 nosthlp2 "
	}

	**********************************************
	* LOAD previoius PARAMETERS
	**********************************************

	
	_parameters

	
	* basic parameters
	local total 			= r(total)
	local number_indicators = r(number_indicators)
	local datef 			= c(current_date)
	local time 				= c(current_time)
	local dt_check  		"`datef' `time'"
	local dt_update 		= r(dt_update)
	local ctrymetadata		= r(ctrymetadata)
	local ctrytime 			= c(current_time)
	local ctrydatef 		= c(current_date)
	local dt_ctrycheck 		"`ctrydatef' `ctrytime'"
	local dt_ctryupdate 	= r(dt_ctryupdate)
	local dt_ctrylastcheck 	= r(dt_ctrylastcheck)
	local dt_ctrylastupdate "`r(dt_ctrylastupdate)'"


	local	oldsourcereturn `"`r(sourcereturn)'"'
	local	oldtopicreturn  `"`r(topicreturn)'"'
	local	oldsourceid	 	`"`r(sourceid)'"'
	local	oldtopicid		`"`r(topicid)'"'
	
	*** OLD TOPIC and SOURCE values ****
	foreach returnname in `oldsourcereturn' `oldtopicreturn' {
		local old`returnname'  = r(`returnname')
	}
	
	*** Generate TOPIC and SOURCE Labels ******
	* OLD Source IDs
	* Extract Labels for SourceIDs
	* Use gettoken loop instead of foreach to handle names with parentheses
	local srclist `"`oldsourceid'"'
	while `"`srclist'"' != "" {
		gettoken name srclist : srclist, bind
		local t1 = substr(`"`name'"',1,2)
		local name = subinstr(`"`name'"',"(","[",.)
		local name = subinstr(`"`name'"',")","]",.)
		local name = subinstr(`"`name'"',":"," -",.)
		local lgt = length(`"`name'"')
		if (`lgt'>38) {
			local name = substr(`"`name'"',1,38)
			local name `"`name'..."'
		}
		local oldlabel_sourceid`t1' `"`name'"'
	}

	* OLD Topic IDs
	* Extract Labels for Topic IDs
	* Use gettoken loop instead of foreach to handle names with parentheses (e.g., ESG)
	local toplist `"`oldtopicid'"'
	while `"`toplist'"' != "" {
		gettoken name toplist : toplist, bind
		local t1 = substr(`"`name'"',1,2)
		local name = subinstr(`"`name'"',"(","[",.)
		local name = subinstr(`"`name'"',")","]",.)
		local name = subinstr(`"`name'"',":"," -",.)
		local lgt = length(`"`name'"')
		if (`lgt'>38) {
			local name = substr(`"`name'"',1,38)
			local name `"`name'..."'
		}
		local oldlabel_topicid`t1' `"`name'"'
	}
		
	
	**********************************************/
	* QUERY DETAIL
	**********************************************

	
	qui if ("`query'" != "") & ("`check'" == "") & (("`all'" == "") | ("`force'" == "")) {
	
		if ("`nodisplay'" == "")  {

			noi di in smcl ""
			noi di in g in smcl "{hline}"
			noi di in smcl ""
			noi di in g in smcl "Indicators update status"
			noi di in smcl ""
			noi di in g in smcl "	Existing Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
			noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `r(dt_lastcheck)')"
			noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
			noi di in smcl ""
			noi di in g in smcl "	Country metadata:		" in y "{bf:`r(ctrymetadata)'}"
			noi di in g in smcl "	Last country check:   		" in w "{bf:`r(dt_ctrylastcheck)'}"  
			noi di in g in smcl "	Current country update level:   " in w "{bf:`r(dt_ctryupdate)'}"
			noi di in smcl ""

			qui if ("`detail'" != "") {
				
				* Display OLD SOURCE results on screen
				/* Source */
				
				noi di in g in smcl "{synoptset 45 tabbed} "
				noi di in g in smcl "{synoptline}"
				noi di in g in smcl "{synopt:{opt Source}}  Number of indicators {p_end}"
				noi di in g in smcl "{synoptline}"
				
				qui foreach name in `oldsourcereturn' {
				
					local checkvalue `""  in y  "		(NOCHECK) {p_end}""'

					noi di in g in smcl "{synopt:{opt `oldlabel_`name''}}`r(`name')'`checkvalue'"
				}
				
				noi di in g in smcl "{synoptline}"
				noi di in smcl ""
				noi di in smcl ""
				noi di in smcl ""
			
				* Display OLD TOPIC results on screen
				/* Topic */
				
				noi di in g in smcl "{synoptset 45 tabbed} "
				noi di in g in smcl "{synoptline}"
				noi di in g in smcl "{synopt:{opt Topics}}  Number of indicators {p_end}"
				noi di in g in smcl "{synoptline}"
				
				qui foreach name in `oldtopicreturn' {
				
					local checkvalue `""  in y  "		(NOCHECK) {p_end}""'

					noi di in g in smcl "{synopt:{opt `oldlabel_`name''}}`r(`name')'`checkvalue'"
				}
				
				noi di in g in smcl "{synoptline}"
				noi di in smcl ""
			
			}
			
			noi di in g in smcl "Possible actions"
			noi di in smcl ""
			noi di in g in smcl 	`" {stata wbopendata, update check detail: {bf: Check for available updates}} "'         "  (or type -wbopendata, update check detail -)"
			noi di in smcl ""
			noi di in g in smcl "	See current documentation on {bf:{help wbopendata_indicators##indicators:indicators list}}, {bf:{help wbopendata##region:Regions}}, " 
			noi di in g in smcl "	{bf:{help wbopendata##adminregion:Administrative Regions}}, {bf:{help wbopendata##incomelevel:Income Levels}}, and {bf:{help wbopendata##lendingtype:Lending Types}}"" 
			noi di in smcl ""
			noi di in g in smcl "{hline}"

		}
	}
	
	**********************************************
	* QUERY DETAIL with CHECK and UPDATE
	**********************************************

	qui if ("`query'" == "") & ("`check'" != "") & ("`update'" != "") & (("`all'" == "") | ("`force'" == ""))  {

		_api_read,  parameter(total)
		local newnumber = r(total1) 
		local date r(date)
	
		_api_read , query("https://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			parameter(page pages total)
		local newctrymetadata =  r(total1)
		
		if ("`nodisplay'" == "") {

			noi di in smcl ""
			noi di in g in smcl "{hline}"
			noi di in smcl ""
			noi di in g in smcl "Indicators update status"
			noi di in smcl ""
			noi di in g in smcl "	Existing Number of Indicators: " in y "{bf: `r(number_indicators)'}"
			noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
			if (`number_indicators' == `newnumber') {
				noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `dt_check'}"
			}
			if (`number_indicators' != `newnumber') {
				noi di in g in smcl "	New update available:          " in r "{bf: yes}     " in g " (as of `dt_check'}"
			}
			noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
			noi di in smcl ""
			noi di in g in smcl "	Country metadata:		" in y "{bf:`r(ctrymetadata)'}"
			if (`ctrymetadata'==`newctrymetadata') {
				noi di in g in smcl "	New update available:          " in w "{bf: none}     " in g " (as of `dt_check'}"
			}
			if (`ctrymetadata'!=`newctrymetadata') {
				noi di in g in smcl "	New update available:          " in r "{bf: yes}     " in g " (as of `dt_check'}"
			}
			noi di in g in smcl "	Last country check:   		" in w "{bf:`r(dt_ctrylastcheck)'}"  
			noi di in g in smcl "	Current country update level:   " in w "{bf:`r(dt_ctryupdate)'}"
			noi di in smcl ""
			
			qui if ("`detail'" != "") {
				
				noi _update_indicators, noindlist nosthlp1 nosthlp2 `query' `check'
				local newsourceid = r(sourceid)
				local newtopicid = r(topicid)
				local newsourcereturn = r(sourcereturn)
				local newtopicreturn  = r(topicreturn)
				local newtotal = r(total)

			*** NEW TOPIC and SOURCE values ****
				noi foreach returnname in `newsourcereturn' `newtopicreturn' {
					local `returnname' = `r(`returnname')'  	
				}
				
			*** Update TOPIC and SOURCE Labels ******
				* NEW Source IDs
				* Extract Labels for SourceIDs (use gettoken for names with parentheses)
				local srclist `"`newsourceid'"'
				while `"`srclist'"' != "" {
					gettoken name srclist : srclist, bind
					local t1 = substr(`"`name'"',1,2)
					local name = subinstr(`"`name'"',"(","[",.)
					local name = subinstr(`"`name'"',")","]",.)
					local name = subinstr(`"`name'"',":"," -",.)
					local lgt = length(`"`name'"')
					if (`lgt'>38) {
						local name = substr(`"`name'"',1,38)
						local name `"`name'..."'
					}
					local newlabel_sourceid`t1' `"`name'"'
				}

				* NEW Topic IDs
				* Extract Labels for Topic IDs (use gettoken for names with parentheses)
				local toplist `"`newtopicid'"'
				while `"`toplist'"' != "" {
					gettoken name toplist : toplist, bind
					local t1 = substr(`"`name'"',1,2)
					local name = subinstr(`"`name'"',"(","[",.)
					local name = subinstr(`"`name'"',")","]",.)
					local name = subinstr(`"`name'"',":"," -",.)
					local lgt = length(`"`name'"')
					if (`lgt'>38) {
						local name = substr(`"`name'"',1,38)
						local name `"`name'..."'
					}
					local newlabel_topicid`t1' `"`name'"'
				}

			*************************************

				
				/* Source */
				
				noi di in g in smcl "{synoptset 45 tabbed} "
				noi di in g in smcl "{synoptline}"
				noi di in g in smcl "{synopt:{opt Source}}  Number of indicators {p_end}"
				noi di in g in smcl "{synoptline}"
				
				qui foreach name in `newsourcereturn' {

					*check if sourceID alreayd existed
					if strmatch("`oldsourcereturn'","*`name'*") == 1 {
						* SOURCEID alreayd existed 
						* No need to do anything
					}
					else {
						* SOURCEID is new
						local old`name' = 0
					}
				
					* check new and old values 				
					if (`r(`name')' == `old`name'') {
						local checkvalue `""  in y  "		(SAME) {p_end}" "'
					}
					if (`r(`name')' != `old`name'') {
						local checkvalue `""  in r  "		(CHANGED)	old value: `old`name'' {p_end}" "'
					}

					noi di in g in smcl "{synopt:{opt `newlabel_`name''}}`r(`name')' `checkvalue' "
				}
				
				noi di in g in smcl "{synoptline}"
				noi di in smcl ""
			
				/* Topic */
				
				noi di in g in smcl "{synoptset 45 tabbed} "
				noi di in g in smcl "{synoptline}"
				noi di in g in smcl "{synopt:{opt Topics}}  Number of indicators {p_end}"
				noi di in g in smcl "{synoptline}"
				
				qui foreach name in `newtopicreturn' {
				
					*check if topicID alreayd existed
					if strmatch("`oldtopicreturn'","*`name'*") == 1 {
						* topicID  alreayd existed 
						* No need to do anything
					}
					else {
						* topicID  is new
						local old`name' = 0
					}
				
					* check new and old values 				
					if (`r(`name')' == `old`name'') {
						local checkvalue `""  in y  "		(SAME) {p_end}" "'
					}
					if (`r(`name')' != `old`name'') {
						local checkvalue `""  in r  "		(CHANGED)	old value: `old`name'' {p_end}" "'
					}

					noi di in g in smcl "{synopt:{opt `newlabel_`name''}}`r(`name')' `checkvalue' "
				}
				
				noi di in g in smcl "{synoptline}"
				noi di in smcl ""
			
			}
			
			noi di in g in smcl "Possible actions"
			noi di in smcl ""
			if (`number_indicators' == `newnumber') & (`ctrymetadata'==`newctrymetadata') {
				noi di in g in smcl "	Do nothing; all files are up to date."
				noi di in smcl ""
				noi di in g in smcl "	See current documentation on {bf:{help wbopendata_indicators##indicators:indicators list}}, {bf:{help wbopendata##region:Regions}}, " 
				noi di in g in smcl "	{bf:{help wbopendata##adminregion:Administrative Regions}}, {bf:{help wbopendata##incomelevel:Income Levels}}, and {bf:{help wbopendata##lendingtype:Lending Types}}"" 
			}
			if (`number_indicators' != `newnumber') | (`ctrymetadata'!=`newctrymetadata')  {
				noi di in g in smcl 	`" {stata wbopendata, update all : {bf: Download available updates}} "'          "  (or type -wbopendata, update all-)"        
				noi di in smcl ""
				noi di in g in smcl "	See current documentation on {bf:{help wbopendata_indicators##indicators:indicators list}}, {bf:{help wbopendata##region:Regions}}, " 
				noi di in g in smcl "	{bf:{help wbopendata##adminregion:Administrative Regions}}, {bf:{help wbopendata##incomelevel:Income Levels}}, and {bf:{help wbopendata##lendingtype:Lending Types}}"" 
			}
			noi di in smcl ""
			noi di in g in smcl "{hline}"

		}

		* Write YAML parameters file
		/* Does not change _parameter values (only changes time stamps) */

		tempfile out2
		tempname out

		file open `out' using `out2', write text replace

		file write `out' "# wbopendata parameters" _n
		file write `out' `"# Auto-generated by _update_wbopendata.ado on `datef' `time'"' _n
		file write `out' "" _n
		file write `out' "_metadata:" _n
		file write `out' "  version: 1.0.0" _n
		file write `out' `"  generated_at: '`datef' `time''"' _n
		file write `out' "" _n
		file write `out' "total: `total'" _n
		file write `out' "number_indicators: `number_indicators'" _n
		file write `out' "" _n
		file write `out' `"dt_update: '`dt_update''"' _n
		file write `out' `"dt_lastcheck: '`dt_check''"' _n
		file write `out' "" _n
		file write `out' "ctrymetadata: `ctrymetadata'" _n
		file write `out' `"dt_ctrylastupdate: '`dt_ctrylastupdate''"' _n
		file write `out' `"dt_ctrylastcheck: '`dt_ctrycheck''"' _n
		file write `out' `"dt_ctryupdate: '`dt_ctryupdate''"' _n
		file write `out' "" _n

		file write `out' "sources:" _n
		local srclist `"`oldsourceid'"'
		while `"`srclist'"' != "" {
			gettoken item srclist : srclist, bind
			local scode = substr(`"`item'"', 1, 2)
			local sname = strtrim(substr(`"`item'"', 3, .))
			local scount `oldsourceid`scode''
			if ("`scount'" == "." | "`scount'" == "") local scount 0
			file write `out' `"  '`scode'':"' _n
			file write `out' `"    count: `scount'"' _n
			file write `out' `"    name: '`sname''"' _n
		}
		file write `out' "" _n

		file write `out' "topics:" _n
		local toplist `"`oldtopicid'"'
		while `"`toplist'"' != "" {
			gettoken item toplist : toplist, bind
			local tcode = word(`"`item'"', 1)
			local tname = strtrim(substr(`"`item'"', strlen("`tcode'") + 1, .))
			local tcount `oldtopicid`tcode''
			if ("`tcount'" == "." | "`tcount'" == "") local tcount 0
			file write `out' `"  '`tcode'':"' _n
			file write `out' `"    count: `tcount'"' _n
			file write `out' `"    name: '`tname''"' _n
		}

		file close `out'

		_wbopendata_get_yaml_path, type(parameters)
		copy `out2' "`r(path)'", replace
	
	}
	

	
	**********************************************
	* QUERY DETAIL with UPDATE + ALL or FORCE
	**********************************************

	qui if ("`query'" == "") & ("`update'" != "") & (("`all'" != "") | ("`force'" != "")) {

		_api_read,  parameter(total)
		local newnumber = r(total1) 
		local date r(date)
		
		_api_read , query("https://api.worldbank.org/v2/countries/") ///
			nopreserve ///
			single ///
			parameter(page pages total)
		local newctrymetadata =  r(total1)
		
		
		if ((`number_indicators' == `newnumber') & (`ctrymetadata'==`newctrymetadata')) & ("`force'" == "") {
			noi _update_wbopendata, update check
		}
		
		if ((`number_indicators' != `newnumber') | (`ctrymetadata'!=`newctrymetadata')) | ("`force'" != "") {

			if ((`number_indicators' != `newnumber') | (`ctrymetadata'!=`newctrymetadata')) {
				local status "yes"
			}
			if ((`number_indicators' == `newnumber') & (`ctrymetadata'==`newctrymetadata')) {
				local status "no (force)"
			}
		
			if ("`nodisplay'" == "")  {

				noi di in smcl ""
				noi di in g in smcl "{hline}"
				noi di in smcl ""
				noi di in g in smcl "Indicators update status"
				noi di in smcl ""
				noi di in g in smcl "	Existing Number of Indicators: " in w "{bf: `r(number_indicators)'}"
				noi di in g in smcl "	New Number of Indicators:      " in y "{bf: `newnumber'}"
				noi di in g in smcl "	Last check for updates:        " in w "{bf: `r(dt_lastcheck)'}"
				noi di in g in smcl "	New update available:          " in w "{bf: `status'}     " in g " (as of `dt_check'}"
				noi di in g in smcl "	Current update level:          " in w "{bf: `r(dt_update)'}"
				noi di in smcl ""
				noi di in g in smcl "	Country metadata:		" in w "{bf:`r(ctrymetadata)'}"
				noi di in g in smcl "	New country metadata:		" in y "{bf:`newctrymetadata'}"
				noi di in g in smcl "	Last country check:   		" in w "{bf:`r(dt_ctrylastcheck)'}"  
				noi di in g in smcl "	Current country update level:   " in w "{bf:`r(dt_ctryupdate)'}"
				noi di in smcl ""
			
				noi di in smcl ""
				noi di in w in smcl in y "{bf:UPDATE IN PROGRESS...}"
			
				* Refresh YAML first (Stata-only) when forcing full update
				if ("`force'" != "") {
					cap noi _wbopendata_refresh_yaml, replace
					if (_rc != 0) {
						noi di as error "Warning: YAML refresh failed; continuing with API-based update"
					}
				}
			
				qui if ("`detail'" != "") | ("`force'" != "") {
					
					* call _update_indicators.ado
					noi _update_indicators, `query' `check' `nohlp2'
					local newsourceid = r(sourceid)
					local newtopicid = r(topicid)
					local newsourcereturn = r(sourcereturn)
					local newtopicreturn  = r(topicreturn)
					local newtotal = r(total)

				*** NEW TOPIC and SOURCE values ****
					noi foreach returnname in `newsourcereturn' `newtopicreturn' {
						local `returnname' = `r(`returnname')'  	
					}
					
				*** Update TOPIC and SOURCE Labels ******
					* NEW Source IDs
					* Extract Labels for SourceIDs (use gettoken for names with parentheses)
					local srclist `"`newsourceid'"'
					while `"`srclist'"' != "" {
						gettoken name srclist : srclist, bind
						local t1 = substr(`"`name'"',1,2)
						local name = subinstr(`"`name'"',"(","[",.)
						local name = subinstr(`"`name'"',")","]",.)
						local name = subinstr(`"`name'"',":"," -",.)
						local lgt = length(`"`name'"')
						if (`lgt'>38) {
							local name = substr(`"`name'"',1,38)
							local name `"`name'..."'
						}
						local newlabel_sourceid`t1' `"`name'"'
					}

					* NEW Topic IDs
					* Extract Labels for Topic IDs (use gettoken for names with parentheses)
					local toplist `"`newtopicid'"'
					while `"`toplist'"' != "" {
						gettoken name toplist : toplist, bind
						local t1 = substr(`"`name'"',1,2)
						local name = subinstr(`"`name'"',"(","[",.)
						local name = subinstr(`"`name'"',")","]",.)
						local name = subinstr(`"`name'"',":"," -",.)
						local lgt = length(`"`name'"')
						if (`lgt'>38) {
							local name = substr(`"`name'"',1,38)
							local name `"`name'..."'
						}
						local newlabel_topicid`t1' `"`name'"'
					}
					
					*************************************
						
					/* Source */
					
					noi di in g in smcl "{synoptset 45 tabbed} "
					noi di in g in smcl "{synoptline}"
					noi di in g in smcl "{synopt:{opt Source}}  Number of indicators {p_end}"
					noi di in g in smcl "{synoptline}"
					
					qui foreach name in `newsourcereturn' {
					
						*check if sourceID alreayd existed
						if strmatch("`oldsourcereturn'","*`name'*") == 1 {
							* SOURCEID alreayd existed 
							* No need to do anything
						}
						else {
							* SOURCEID is new
							local old`name' = 0
						}
					
						if (`r(`name')' == `old`name'') {
							local checkvalue `""  in y  "		(SAME) {p_end}""'
						}
						if (`r(`name')' != `old`name'') {
							local checkvalue `""  in r  "		(CHANGED)	old value: `old`name'' {p_end}""'
						}

						noi di in g in smcl "{synopt:{opt `newlabel_`name''}}`r(`name')'`checkvalue'"
					}
					
					noi di in g in smcl "{synoptline}"
					noi di in smcl ""
				
					/* Topic */
					
					noi di in g in smcl "{synoptset 45 tabbed} "
					noi di in g in smcl "{synoptline}"
					noi di in g in smcl "{synopt:{opt Topics}}  Number of indicators {p_end}"
					noi di in g in smcl "{synoptline}"
					
					qui foreach name in `newtopicreturn' {
						
						*check if topicID alreayd existed
						if strmatch("`oldtopicreturn'","*`name'*") == 1 {
							* topicID  alreayd existed 
							* No need to do anything
						}
						else {
							* topicID  is new
							local old`name' = 0
						}
					
						* check new and old values 				

						if (`r(`name')' == `old`name'') {
							local checkvalue `""  in y  "		(SAME) {p_end}""'
						}
						if (`r(`name')' != `old`name'') {
							local checkvalue `""  in r  "		(CHANGED)	old value: `old`name'' {p_end}""'
						}

						noi di in g in smcl "{synopt:{opt `newlabel_`name''}}`r(`name')'`checkvalue'"
					}
					
					noi di in g in smcl "{synoptline}"
					noi di in smcl ""
				
				}

			}
		
		
			* Write YAML parameters file
			/* Full update: new indicator and country metadata values */

			noi di in smcl ""

			noi _update_countrymetadata , `ctrylist'
			local newctrymeta 		= r(ctrymeta)
			local newctrylastcheck	= r(dt_ctrylastcheck)
			local newctryupdate		= r(dt_ctryupdate)

			* Determine which values to use for sources/topics
			if ("`newsourcereturn'" != "") {
				local _yaml_srclist `"`newsourceid'"'
				local _yaml_toplist `"`newtopicid'"'
				local _yaml_total `newtotal'
				local _yaml_pfx ""
			}
			else {
				local _yaml_srclist `"`oldsourceid'"'
				local _yaml_toplist `"`oldtopicid'"'
				local _yaml_total `total'
				local _yaml_pfx "old"
			}

			tempfile out2
			tempname out

			file open `out' using `out2', write text replace

			file write `out' "# wbopendata parameters" _n
			file write `out' `"# Auto-generated by _update_wbopendata.ado on `datef' `time'"' _n
			file write `out' "" _n
			file write `out' "_metadata:" _n
			file write `out' "  version: 1.0.0" _n
			file write `out' `"  generated_at: '`datef' `time''"' _n
			file write `out' "" _n
			file write `out' "total: `_yaml_total'" _n
			file write `out' "number_indicators: `newnumber'" _n
			file write `out' "" _n
			file write `out' `"dt_update: '`datef' `time''"' _n
			file write `out' `"dt_lastcheck: '`datef' `time''"' _n
			file write `out' "" _n
			file write `out' "ctrymetadata: `newctrymetadata'" _n
			file write `out' `"dt_ctrylastupdate: '`dt_ctryupdate''"' _n
			file write `out' `"dt_ctrylastcheck: '`dt_ctrycheck''"' _n
			file write `out' `"dt_ctryupdate: '`newctryupdate''"' _n
			file write `out' "" _n

			file write `out' "sources:" _n
			local srclist `"`_yaml_srclist'"'
			while `"`srclist'"' != "" {
				gettoken item srclist : srclist, bind
				local scode = substr(`"`item'"', 1, 2)
				local sname = strtrim(substr(`"`item'"', 3, .))
				local scount ``_yaml_pfx'sourceid`scode''
				if ("`scount'" == "." | "`scount'" == "") local scount 0
				file write `out' `"  '`scode'':"' _n
				file write `out' `"    count: `scount'"' _n
				file write `out' `"    name: '`sname''"' _n
			}
			file write `out' "" _n

			file write `out' "topics:" _n
			local toplist `"`_yaml_toplist'"'
			while `"`toplist'"' != "" {
				gettoken item toplist : toplist, bind
				local tcode = word(`"`item'"', 1)
				local tname = strtrim(substr(`"`item'"', strlen("`tcode'") + 1, .))
				local tcount ``_yaml_pfx'topicid`tcode''
				if ("`tcount'" == "." | "`tcount'" == "") local tcount 0
				file write `out' `"  '`tcode'':"' _n
				file write `out' `"    count: `tcount'"' _n
				file write `out' `"    name: '`tname''"' _n
			}

			file close `out'

			_wbopendata_get_yaml_path, type(parameters)
			copy `out2' "`r(path)'", replace

			
			noi di in smcl ""
			noi di in w in smcl in y "{bf:FULL UPDATE COMPLETED.}"
			noi di in smcl ""
			noi di in smcl in g "{hline}"
			noi di in smcl ""

			break

		}
		
	}
	
	discard

end


**********************************************************
* version 16.0 			<28Oct2019>		JPAzevedo
*	change indicators update; function _update_indicators.ado replace  
*   _indicators.ado increase the return list stored under parameter 
*	add report tables with SOURCE adn TOPIC labels
*   add the update of the CTRYLIST
**********************************************************
* version 15.1 			<3Mar2019>		JPAzevedo
*	include countrymetadata option
*	include force option
**********************************************************
* version 15.0.2 			<16Feb2019>		JPAzevedo
*	add update query, update check and update options
**********************************************************
* version 15.0.1	 		<11Feb2019>		JPAzevedo
*	add latest check value to default report
**********************************************************
* version 15.0   			<8Feb2019>		JPAzevedo
*	original commit
**********************************************************
