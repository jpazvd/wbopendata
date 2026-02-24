*******************************************************************************
* __wbod_api_read_indicators                                                                     *
*! v 16.3  	8Jul2020               by Joao Pedro Azevedo
* 	change API end point to HTTPS
/*******************************************************************************/

program define __wbod_api_read_indicators, rclass

	version 9
	
    syntax                                         	///
                 ,                                 	///
                         UPDATE		               	///
							[						/// 
							PRESERVEOUT 			///
							FILE1(string)			///
							FILE2(string)			///
							FILE3(string)			///
							CHECK					///
							QUERY					///
							OFFLINE(string)			///
							]			   
                 

	
	quietly {
	
		set checksum off

		************************************
		/* Overall Parameters			  */
		************************************

		if ("`check'" == "") {
			local what "update `query'"
		}
		if ("`check'" != "") {
			local what "check"
		}
		
		local date: disp %td date("`c(current_date)'", "DMY")
	
		tempfile indicator1 indicator2 indicator3

		local query1 "https://api.worldbank.org/v2/indicators?per_page=10000&page=1"
		local query2 "https://api.worldbank.org/v2/indicators?per_page=10000&page=2"
		local query3 "https://api.worldbank.org/v2/indicators?per_page=10000&page=3"

		****************************************
		/* Download Indicator list using API  */
		****************************************

		* Offline fixture injection (Phase 6, Gould 2001)
		* When offline() option is set to a directory path, XML indicator
		* lists are read from local fixture files instead of the World Bank API.
		if ("`offline'" != "") {
			noi di as text "(offline mode: reading indicator list fixtures)"
			forvalues _p = 1/3 {
				local _fixture "`offline'/api/indicators_page`_p'.xml"
				cap confirm file "`_fixture'"
				if _rc != 0 {
					noi di as err "Offline fixture not found: `_fixture'"
					exit 601
				}
				cap: copy "`_fixture'" "`indicator`_p''", text replace
			}
			noi di as text "(offline mode: all 3 indicator pages loaded)"
		}
		else {
			noi di in smcl in g ""
			noi di in smcl in g "{bf: Downloading indicators list 1/3...}"

			cap: copy "`query1'" "`indicator1'", text replace

*			noi di in smcl in g ""
			noi di in smcl in g "{bf: Downloading indicators list 1/3...COMPLETED!}"

			noi di in smcl in g ""
			noi di in smcl in g "{bf: Downloading indicators list 2/3...}"

			cap: copy "`query2'" "`indicator2'", text replace

*			noi di in smcl in g ""
			noi di in smcl in g "{bf: Downloading indicators list 2/3...COMPLETED!}"

			noi di in smcl in g ""
			noi di in smcl in g "{bf: Downloading indicators list 3/3...}"

			cap: copy "`query3'" "`indicator3'", text replace

*			noi di in smcl in g ""
			noi di in smcl in g "{bf: Downloading indicators list 3/3...COMPLETED!}"
		}

		noi di in smcl in g ""
		noi di in smcl in g "{bf: Preparing indicator data for `what'...}"

		
		************************************
		/* Preapre Indicator list (TXT)	  */
		************************************
	
		tempfile in out source out3 hlp1 hlp2 indicator help file1tmp file2tmp file3tmp
		tempname in2 in3 in4 out2 in_tmp saving source1 source2 source3 source4 source5 hlp hlp01 hlp02
			   
		local skipnumber = 1
		local trimnumber = 1
	   
		file open `in2'     using 	`indicator1'		, read
		file open `in3'     using 	`indicator2'   		, read 
		file open `in4'     using 	`indicator3'   		, read 

		if ("`preserveout'" == "") {
			file open `out2'    using 	`out'     		, write text replace
			file open `source3' using 	`file1tmp' 		, write text replace
			file open `source4' using 	`file2tmp' 		, write text replace
		}
		else {

			if ("`file1'"=="") {
				local file1 "file1.txt"
			}
			if ("`file2'"=="") {
				local file2 "file2.txt"
			}

			file open `source3' using 	`file1tmp' 		, write text replace
			
			file open `source4' using 	`file2tmp'  	, write text replace

		}
		
		file write `source3' "indicatorcode#type#valuelabel# " _n
		
		file write `source4' "indicatorcode#indicatorname#sourceID #sourceOrganization #sourceNote #type # topicID " _n

		local curr_code ""
		local curr_name ""
		local curr_sourceid ""
		local curr_sourceorg ""
		local curr_sourcenote ""
		local curr_has_topic 0
		local in_sourcenote 0
		local in_indicator 0

		foreach inputfile in in2 in3 in4 {
			file read ``inputfile'' line
			local l = 0
			while !r(eof) {
				local ++l
				if (`l' > `skipnumber') {
					local line = subinstr(`"`line'"', "&quot;", "'", .)
					local line = subinstr(`"`line'"', char(34), "'", .)
					local line = subinstr(`"`line'"', `"""', "", .)
					if ("`line'" != "") {
						local line = subinstr(`"`line'"', `"""', "", .)

						if (strpos("`line'", "<wb:indicator") > 0) {
							if ("`curr_code'" != "" & `curr_has_topic' == 0) {
								file write `source4' "`curr_code' # `curr_name' # `curr_sourceid' # `curr_sourceorg' # `curr_sourcenote' # topicID #   " _n
							}
							local in_indicator 1
							local in_sourcenote 0
							local curr_code ""
							if (regexm("`line'", "id='([^']+)'")) local curr_code = regexs(1)
							else if (regexm("`line'", "id=([^ >]+)")) local curr_code = regexs(1)
							local curr_code = subinstr("`curr_code'", "'", "", .)
							local curr_name ""
							local curr_sourceid ""
							local curr_sourceorg ""
							local curr_sourcenote ""
							local curr_has_topic 0
						}

						if (`in_indicator' == 1) {
							if (strpos("`line'", "<wb:name>") > 0) {
								local curr_name = trim(subinstr("`line'","<wb:name>","",.))
								local curr_name = subinstr("`curr_name'","</wb:name>","",.)
								local curr_name = trim(substr("`curr_name'",1,200))
								_wbopendata_clean_text_local "`curr_name'"
								local curr_name = r(text)
								local curr_name = subinstr("`curr_name'", char(34), "'", .)
								if ("`curr_code'" != "") {
									file write `source3' "`curr_code' # indicatorname # `curr_name' # " _n
								}
							}

							if (strpos("`line'", "<wb:source id=") > 0) {
								local curr_sourceid ""
								if (regexm("`line'", "id='([0-9]+)'")) local curr_sourceid = regexs(1)
								else if (regexm("`line'", "id=([0-9]+)")) local curr_sourceid = regexs(1)
								if ("`curr_code'" != "") {
									file write `source3' "`curr_code' # sourceID # `curr_sourceid' # " _n
								}
							}

							if (strpos("`line'", "<wb:sourceOrganization>") > 0) {
								local curr_sourceorg = trim(subinstr("`line'","<wb:sourceOrganization>","",.))
								local curr_sourceorg = subinstr("`curr_sourceorg'","</wb:sourceOrganization>","",.)
								_wbopendata_clean_text_local "`curr_sourceorg'"
								local curr_sourceorg = r(text)
								local curr_sourceorg = subinstr("`curr_sourceorg'", char(34), "'", .)
								if ("`curr_code'" != "") {
									file write `source3' "`curr_code' # sourceOrganization # `curr_sourceorg' #" _n
								}
							}

							if (strpos("`line'", "<wb:sourceNote>") > 0) {
								local curr_sourcenote = trim(subinstr("`line'","<wb:sourceNote>","",.))
								if (strpos("`line'", "</wb:sourceNote>") == 0) {
									local in_sourcenote 1
								}
								else {
									local curr_sourcenote = subinstr("`curr_sourcenote'","</wb:sourceNote>","",.)
									local in_sourcenote 0
								}
								_wbopendata_clean_text_local "`curr_sourcenote'"
								local curr_sourcenote = r(text)
								local curr_sourcenote = subinstr("`curr_sourcenote'", char(34), "'", .)
								if ("`curr_code'" != "" & `in_sourcenote' == 0) {
									file write `source3' "`curr_code' # sourceNote # `curr_sourcenote' #" _n
								}
							}
							else if (`in_sourcenote' == 1) {
								local chunk = subinstr("`line'","</wb:sourceNote>","",.)
								local chunk = subinstr("`chunk'", `"""', "", .)
								local curr_sourcenote = trim(`"`curr_sourcenote' `chunk'"')
								if (strpos("`line'", "</wb:sourceNote>") > 0) {
									local in_sourcenote 0
									_wbopendata_clean_text_local "`curr_sourcenote'"
									local curr_sourcenote = r(text)
									local curr_sourcenote = subinstr("`curr_sourcenote'", char(34), "'", .)
									if ("`curr_code'" != "") {
										file write `source3' "`curr_code' # sourceNote # `curr_sourcenote' #" _n
									}
								}
							}

							if (strpos("`line'", "<wb:topic id=") > 0) {
								local topicID ""
								if (regexm("`line'", "id='([0-9]+)'")) local topicID = regexs(1)
								else if (regexm("`line'", "id=([0-9]+)")) local topicID = regexs(1)
								if ("`curr_code'" != "") {
									file write `source3' "`curr_code' # topicID # `topicID'" _n
									file write `source4' "`curr_code' # `curr_name' # `curr_sourceid' # `curr_sourceorg' # `curr_sourcenote' # topicID # `topicID'" _n
									local curr_has_topic 1
								}
							}

							if (strpos("`line'", "</wb:indicator>") > 0) {
								if ("`curr_code'" != "" & `curr_has_topic' == 0) {
									file write `source4' "`curr_code' # `curr_name' # `curr_sourceid' # `curr_sourceorg' # `curr_sourcenote' # topicID #   " _n
								}
								local curr_code ""
								local curr_name ""
								local curr_sourceid ""
								local curr_sourceorg ""
								local curr_sourcenote ""
								local curr_has_topic 0
								local in_indicator 0
								local in_sourcenote 0
							}
						}
					}
				}
				file read ``inputfile'' line
			}
		}


		
		file close `in2'
		file close `in3'
		file close `in4'

		file close `source3'
		file close `source4'
	
	*====================================================================================
	
	cap: findfile `file1' , `path'
			
	if _rc == 0 {
		copy `file1tmp'  "`r(fn)'" , replace
	}
	else {
		copy `file1tmp' "`file1'"
	}
	
	cap: findfile `file2' , `path'
			
	if _rc == 0 {
		copy `file2tmp'  "`r(fn)'" , replace
	}
	else {
		copy `file2tmp' "`file2'"
	}

	return local file1 "`file1'"
	return local file2 "`file2'"
	
	}

*	noi di in smcl in g ""
	noi di in smcl in g "{bf: Preparing indicator data for `what'...COMPLETED!}"
	noi di in smcl in g ""

	
	
end


program define _wbopendata_clean_text_local, rclass
	version 9
	args text

	local t "`text'"
	if ("`t'" == "") {
		return local text ""
		exit 0
	}

	local t = subinstr("`t'", char(9), " ", .)
	local t = subinstr("`t'", char(10), " ", .)
	local t = subinstr("`t'", char(13), " ", .)
	local t = subinstr("`t'", "&amp;", "&", .)
	local t = subinstr("`t'", "&quot;", "'", .)
	local t = subinstr("`t'", char(34), "'", .)
	local t = subinstr("`t'", "&apos;", char(39), .)
	local t = subinstr("`t'", "&lt;", "<", .)
	local t = subinstr("`t'", "&gt;", ">", .)
	local t = subinstr("`t'", char(133), "...", .)
	local t = subinstr("`t'", char(145), "'", .)
	local t = subinstr("`t'", char(146), "'", .)
	local t = subinstr("`t'", char(147), char(39), .)
	local t = subinstr("`t'", char(148), char(39), .)
	local t = subinstr("`t'", char(150), "-", .)
	local t = subinstr("`t'", char(151), "-", .)
	local t = subinstr("`t'", char(160), " ", .)
	local t = trim("`t'")
	if ("`t'" == ".") local t ""

	return local text "`t'"
end


*******************************************************************************
* v 16.0	28Oct2019				by JoÃ£o Pedro Azevedo
*       support to HPP population projections
*******************************************************************************
* v 15.2   10Mar2019				by JoÃ£o Pedro Azevedo
*		rename ado : _wbopendata_update.ado  to __wbod_update_indicators.ado
*******************************************************************************
* v 14.3  	2Feb2019               	by Joao Pedro Azevedo                     
*       initial commit
*******************************************************************************


