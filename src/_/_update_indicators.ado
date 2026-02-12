*******************************************************************************
* _update_indicators                                                                   
*! v 16.2   04Jan2026				by João Pedro Azevedo
*		fix: new sthlp files now saved to same directory as wbopendata.ado
*		     instead of current working directory
*! v 16.1   12Apr2020				by João Pedro Azevedo
*		increase documentation
*		change the creation of the medata files for SOURCEID and TOPICID
*******************************************************************************


program define _update_indicators, rclass

version 9

   syntax                               ///
            [ ,                         ///
                FILE(string) 			///
				NOINDLIST				///
				NOSTHLP1 				///
				NOSTHLP2 				///	
				CHECK					///
				QUERY					///
				NOIsily					///
				NAME(string)			///
				SAVE					///
				REPLACE					///
			] 			
						 

*******************************************************************************

	tempfile tmp
	
	set checksum off
	
	* Find the directory where wbopendata.ado is installed (for saving new files)
	cap: findfile wbopendata.ado
	if _rc == 0 {
		local wbopendata_dir = reverse(substr(reverse("`r(fn)'"), 15, .))
	}
	else {
		local wbopendata_dir ""
	}

*******************************************************************************
* download and created metadata files in case these are not available 
*******************************************************************************

if ("`file'" == "") {

	tempfile file1 file2

	_api_read_indicators, update preserveout file1(`file1')  file2(`file2') `check' `query'

	local file "`r(file2)'"
	
}

if ("`file'" != "") {

	local file2 "`file'"

}

*******************************************************************************
* Open files and prepare database to auto-update the documentation
*******************************************************************************

quietly {

	insheet using `file2', delimiter("#") clear name

*	noi di "save tmptmp"
*	save tmptmp, replace
	
	* drop cases in which SOURCEID does not stata with a numeric CODE
	drop if real(substr(sourceid,1,1))==. & !missing(sourceid)
	
	gen seq = _n

	replace indicatorcode = indicatorcode[_n-1] if indicatorcode == "" & indicatorcode[_n-1] != ""

	foreach var in indicatorname sourceid sourceorganization sourcenote topicid {
		gsort indicatorcode -`var'
		bysort indicatorcode: replace `var' = `var'[1] if `var'[1] != "" & `var'== "" 
	}

	bysort indicatorcode indicatorname sourceid sourceorganization sourcenote topicid : gen dups = _n

	keep if dups == 1

	drop dups
	
	drop seq

	bysort indicatorcode indicatorname sourceid sourceorganization sourcenote : gen tot = _N

	foreach var in topicid sourceid {
		replace `var' = subinstr(`var',"&amp;","and",.) 
		replace `var' = subinstr(`var',">"," ",.) 
		replace `var' = "0"+`var' if real(substr(`var',1,2))<=9 & real(substr(`var',1,1)) !=.
	}

	* Indentify multiple entries for the same indicator	
	bysort indicatorcode : gen seq = _n

	order indicatorcode indicatorname

	sort sourceid indicatorcode

	label var sourceid "Source"

	label var topicid "Topics"
	
	compress

	* save files with all INDICATORS + SOURCEID + TOPICID
	save `tmp', replace
		
********************************************************************************
* Create Indicator list for dialogue box 
* if noindlist == to missing this section of the code is skipped
* this is a txt file 
********************************************************************************

if ("`noindlist'" == "") {

	noi di in smcl in g "{bf: Processing indicators list...}"

	local indicator indicators.txt
	
	tempfile  tmp1tmp
	
	use `tmp' , clear

	keep indicatorcode indicatorname
	bysort indicatorcode : gen seq = _n
	keep if seq == 1
	drop seq
	sort indicatorcode 
	gen export = indicatorcode + " - " + indicatorname
	keep export
	sort export
	outsheet using `tmp1tmp', replace noquote nolabel nonames
	
	cap: findfile `indicator' , `path'
			
	if _rc == 0 {
		copy `tmp1tmp'  "`r(fn)'" , replace
	}
	else {
		copy `tmp1tmp' "`wbopendata_dir'`indicator'"
	}
	
*noi gen length = length(sourcenote)
*noi sum
	
	noi di in smcl in g "{bf: Processing indicators list...COMPLETED!}"

}

*******************************************************************************
* create sthlp files (sourceid and topicid) using discovery commands
* if NOSTHLP1 == to missing this part of the code is skipped
*  creates a single file for sourceid and topicid (lightweight TOC)
*******************************************************************************

if ("`nosthlp1'" == "") {

	noi di in smcl in g ""
	noi di in smcl in g "{bf: Processing source/topic help (discovery)...}"
	noi di in smcl in g ""

	local date: disp %td date("`c(current_date)'", "DMY")

	*----------------------------------------------
	* SOURCES: use discovery function to fetch list
	*----------------------------------------------
	cap noi _wbopendata_sources, limit(10000)
	if (_rc != 0) {
		local source_codes ""
		local source_names ""
		local n_sources = 0
	}
	else {
		local source_codes "`r(source_codes)'"
		local source_names `"`r(source_names)'"'
		local n_sources = r(n_sources)
	}

	tempfile help_source
	tempname hlp_source
	file open `hlp_source' using `help_source', write text replace
		file write `hlp_source' "{smcl}" _n
		file write `hlp_source' "{right:(as of `date')}" _n
		file write `hlp_source' "" _n
		file write `hlp_source' "{marker indicators}{...}" _n
		file write `hlp_source' "{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}" _n
		file write `hlp_source' "{title:Source}" _n
		file write `hlp_source' "" _n
		file write `hlp_source' "This list is generated from cached metadata. Use " _n
		file write `hlp_source' `"{stata `"wbopendata, sources"':{bf:wbopendata, sources}}"' _n
		file write `hlp_source' "to browse sources and " _n
		file write `hlp_source' `"{stata `"wbopendata, search() source(#)"':{bf:search() source(#)}}"' _n
		file write `hlp_source' "to filter indicators within a source." _n
		file write `hlp_source' "" _n

		file write `hlp_source' "{marker toc}" _n
		file write `hlp_source' "{p 40 20 2}(Go up to {it:{help wbopendata##sourceid:Source}}){p_end}" _n
		file write `hlp_source' "{synoptset 40 tabbed}{...}" _n
		file write `hlp_source' "{synopthdr:Source Code}" _n
		file write `hlp_source' "{synoptline}" _n

		local codes "`source_codes'"
		local names `"`source_names'"'
		while ("`codes'" != "") {
			gettoken code codes : codes
			gettoken name names : names, bind
			local name = subinstr(`"`name'"', `"""', "'", .)
			local browse_cmd "wbopendata, search() source(`code')"
			file write `hlp_source' `"{synopt:{opt `code'}}  `name' {stata `"`browse_cmd'"':[Browse]}{p_end}"' _n
		}
		file write `hlp_source' "{synoptline}" _n
	file close `hlp_source'

	cap: findfile wbopendata_sourceid.sthlp , `path'
	if _rc == 0 {
		copy `help_source'  "`r(fn)'" , replace
	}
	else {
		copy `help_source' "`wbopendata_dir'wbopendata_sourceid.sthlp"
	}
	noi di in g in smcl "\tSee {bf:{help wbopendata##sourceid:Source}}"

	*----------------------------------------------
	* TOPICS: use discovery function to fetch list
	*----------------------------------------------
	cap noi _wbopendata_topics, limit(10000)
	if (_rc != 0) {
		local topic_ids ""
		local topic_names ""
		local n_topics = 0
	}
	else {
		local topic_ids "`r(topic_ids)'"
		local topic_names `"`r(topic_names)'"'
		local n_topics = r(n_topics)
	}

	tempfile help_topic
	tempname hlp_topic
	file open `hlp_topic' using `help_topic', write text replace
		file write `hlp_topic' "{smcl}" _n
		file write `hlp_topic' "{right:(as of `date')}" _n
		file write `hlp_topic' "" _n
		file write `hlp_topic' "{marker indicators}{...}" _n
		file write `hlp_topic' "{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}" _n
		file write `hlp_topic' "{title:Topics}" _n
		file write `hlp_topic' "" _n
		file write `hlp_topic' "This list is generated from cached metadata. Use " _n
		file write `hlp_topic' `"{stata `"wbopendata, topics"':{bf:wbopendata, topics}}"' _n
		file write `hlp_topic' "to browse topics and " _n
		file write `hlp_topic' `"{stata `"wbopendata, search() topic(#)"':{bf:search() topic(#)}}"' _n
		file write `hlp_topic' "to filter indicators within a topic." _n
		file write `hlp_topic' "" _n

		file write `hlp_topic' "{marker toc}" _n
		file write `hlp_topic' "{p 40 20 2}(Go up to {it:{help wbopendata##topicid:Topics}}){p_end}" _n
		file write `hlp_topic' "{synoptset 40 tabbed}{...}" _n
		file write `hlp_topic' "{synopthdr:Topics Code}" _n
		file write `hlp_topic' "{synoptline}" _n

		local ids "`topic_ids'"
		local names `"`topic_names'"'
		while ("`ids'" != "") {
			gettoken code ids : ids
			gettoken name names : names, bind
			local name = subinstr(`"`name'"', `"""', "'", .)
			local browse_cmd "wbopendata, search() topic(`code')"
			file write `hlp_topic' `"{synopt:{opt `code'}}  `name' {stata `"`browse_cmd'"':[Browse]}{p_end}"' _n
		}
		file write `hlp_topic' "{synoptline}" _n
	file close `hlp_topic'

	cap: findfile wbopendata_topicid.sthlp , `path'
	if _rc == 0 {
		copy `help_topic'  "`r(fn)'" , replace
	}
	else {
		copy `help_topic' "`wbopendata_dir'wbopendata_topicid.sthlp"
	}
	noi di in g in smcl "\tSee {bf:{help wbopendata##topicid:Topics}}"

	noi di in smcl in g ""
	noi di in smcl in g "{bf: Processing source/topic help (discovery)...COMPLETED!}"
	noi di in smcl in g ""

}
		
*******************************************************************************
* create sthlp files (sourceid_indicators and topicid_indicators)
* if NOSTHLP2 == to missing this part of the code is skipped
* multiple files for sourcid
* multiple fiels for topicid
*******************************************************************************

if ("`nosthlp2'" == "") {
		
	noi di in smcl in g ""
	noi di in smcl in g "{bf: Processing indicators metadata by source and topic...}"
	noi di in smcl in g ""

	local date: disp %td date("`c(current_date)'", "DMY")
		
	* loop through sourcid and topicid	
	qui foreach variable in sourceid topicid  {
	
		* created tempfiles
		tempfile help`variable' tmp2`variable'
		* create temp variable names
		tempname hlp`variable'  dups`variable'  seq2`variable' seq3`variable' code`variable' tot`variable'

		use `tmp', clear
		
		keep if `variable' != ""
		sort `type' indicatorcode topicid
		bysort `variable' indicatorcode : gen `dups`variable'' = _n
		keep if `dups`variable'' == 1
		sort `dups`variable'' `variable' indicatorcode
		bysort `dups`variable'' `variable' indicatorcode : gen `seq2`variable'' = _n
		keep if  `seq2`variable'' == 1
		sort `variable' indicatorcode
		bysort `variable' : gen `seq3`variable'' = _n
		bysort `variable' : gen `tot`variable'' = _N
		gen `code`variable''  = trim(word(`variable',1))

		local title : variable label `variable' 
		local title = subinstr("`title'","Code","",.)

	
	/**************** header ********************/
	
		levelsof `variable'
		local levelsof2 `"`r(levels)'"'
		`noi' di `"`levelsof2'"'
				
		compress
		
		save `tmp2`variable'' , replace

		* loop toics l
		qui foreach topic1 in `levelsof2'  {	
				
			use `tmp2`variable'', clear
				
			keep if `variable' == "`topic1'" 
				
			`noi' sum `seq3`variable'' if `variable' == "`topic1'"
			local min = r(min)
			local max = r(max)
		
			local tc0	= `code`variable''		in `min'
			
			`noi' di " `variable'  : `topic1' : `tc0' " 
		
			tempname hlp`variable'`tc0'
			tempfile help`variable'`tc0'

			
			file open `hlp`variable'`tc0''		using 	`help`variable'`tc0'' , write text replace

				********************************************
				*** Header of Help file

				file write `hlp`variable'`tc0'' "{smcl}" 					_n
				file write `hlp`variable'`tc0'' "{right:(as of `date')}" 							_n
				file write `hlp`variable'`tc0'' "" 							_n
				file write `hlp`variable'`tc0'' "{marker indicators}{...}" 	_n
				file write `hlp`variable'`tc0'' "{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}" 	_n
				file write `hlp`variable'`tc0'' "{title:`title'}" 		_n
				file write `hlp`variable'`tc0'' "" 							_n

				********************************************
				*** Help file ToC

				file write `hlp`variable'`tc0'' "{marker toc}" 	_n
				file write `hlp`variable'`tc0'' "{p 40 20 2}(Go up to {it:{help wbopendata##`variable':`title'}}){p_end}" 	_n
				file write `hlp`variable'`tc0'' "{synoptset 25 tabbed}{...}" 	_n
				file write `hlp`variable'`tc0'' "{synopthdr:`title' Code}" _n
				file write `hlp`variable'`tc0'' "{synoptline}" 				_n

				********************************************
				/* begin TOC */
				foreach topic2 in `levelsof2'   {
					
					local var1code 	= trim(word("`topic2'",1))
					local var1name 	= trim(subinstr("`topic2'","`var1code'","",.))
						
					file write `hlp`variable'`tc0''  `"{synopt:{opt `var1code'}}  {help wbopendata_`variable'_indicators`var1code'##`variable'_`var1code':`var1name'}{p_end}"' _n
				}
				/* end TOC */
				********************************************
				
				file write `hlp`variable'`tc0'' "" 				_n
				file write `hlp`variable'`tc0'' "" 				_n

				********************************************
				*** begin Footer of ToC
					
					sum `seq3`variable'' if `variable' == "`topic1'"
					local min = r(min)
					local max = r(max)

					local topicode0	= `code`variable''		in `min'
					local topicode1	= `variable'			in `min'
					local topicode2 "`variable'_`topicode0'"

					file write `hlp`variable'`tc0'' "{marker `topicode2'}" 	_n
					file write `hlp`variable'`tc0'' "{p 40 20 2}(Go up to {it:{help wbopendata##`variable':`title'}} or {it:{help wbopendata_`variable'_indicators`tc0'##`toc':TOC}}){p_end}" 	_n
					file write `hlp`variable'`tc0''  "" _n
					file write `hlp`variable'`tc0'' "{synoptset 25 tabbed}{...}" 	_n
					file write `hlp`variable'`tc0'' "{syntab:{title:{bf:`topicode1'}}}" _n
					*file write `hlp`variable'`tc0'' "{synoptline}" 				_n

				*** end Footer of ToC
				********************************************
		
				********************************************
				*** begin Indicator loop
					levelsof indicatorcode if `variable' == "`topic1'"
					
					foreach indicator in `r(levels)' {
					
						`noi' di "`variable' : `topic1' :  `indicator'"

					*** Indicator metadata
						local indicatorcode 		"`indicator'"
						levelsof indicatorname if indicatorcode == "`indicator'"
						local indicatorname 	`r(levels)'
						levelsof sourceid if indicatorcode == "`indicator'"
						local sourceid 				`r(levels)'
						levelsof sourceorganization if indicatorcode == "`indicator'"
						local sourceorganization	"`r(levels)'"
						levelsof sourcenote if indicatorcode == "`indicator'"
						local sourcenote			"`r(levels)'"
						
					*** Adjust websites
						cap: _website, text(`sourceorganization')
						if _rc == 0 {
							local sourceorganization = r(text)
						}

						cap: _website, text(`sourcenote')
						if _rc == 0 {
							local sourcenote = r(text)
						}
						
					*** Header of indicator metadata
						file write `hlp`variable'`tc0''  "{synoptline}" _n
						file write `hlp`variable'`tc0''  `"{marker `variable'_`indicatorcode'}"' _n
						file write `hlp`variable'`tc0''  `"{synopt:{bf:{help wbopendata_`variable'##`indicatorcode':`indicatorcode'} - `indicatorname'}}"' _n 
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  `"{synopt:{opt Source}}`sourceid'{p_end}"'  _n
						file write `hlp`variable'`tc0''  "" _n

					*** Loop to add multiple topics in single indicator documentation
						local ccc = 1
						levelsof topicid 		if indicatorcode == "`indicator'"
						foreach topic4 in `r(levels)' {
							if (`ccc' == 1) {
								file write `hlp`variable'`tc0''  `"{synopt:{opt Topics}}`topic4'{p_end}"'  _n
								local ccc = `ccc'+1
							}
							else {
								file write `hlp`variable'`tc0''  `"{synopt:    }`topic4'{p_end}"'  _n
							}
						}
						local ccc = 0
					
					*** Source Notes
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  `"{synopt:{opt Source Notes}}`sourcenote'{p_end}"'  _n
						file write `hlp`variable'`tc0''  "" _n

					*** Source Organization
						file write `hlp`variable'`tc0''  `"{synopt:{opt Source Organization}}`sourceorganization'{p_end}"'  _n
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  "" _n
						
					}
				
				*** end Indicator loop
				********************************************

					file write `hlp`variable'`tc0''  `""' _n
					file write `hlp`variable'`tc0'' "{right:(as of `date')}" 							_n

				*** generation date
				********************************************

			file close `hlp`variable'`tc0''

			*** close file
			********************************************
				
			********************************************
			*** move file
			cap: findfile wbopendata_`variable'_indicators`tc0'.sthlp , `path'
			
			if _rc == 0 {
				copy `help`variable'`tc0''  "`r(fn)'" , replace
			}
			else {
				copy `help`variable'`tc0'' "`wbopendata_dir'wbopendata_`variable'_indicators`tc0'.sthlp"
			}
					
			********************************************
			*** display file
			noi di in g in smcl "	See {bf:{help wbopendata_`variable'_indicators`tc0'##`toc':`title' `tc0'}}"
			
		}
			
	}		
	
	noi di in smcl in g ""
	noi di in smcl in g "{bf: Processing indicators metadata by source and topic...COMPLETED!}"
	noi di in smcl in g ""
		
}

********************************************
/* Create return locals */
********************************************

	use `tmp' , clear

	sum tot if seq == 1
	return local total = r(N)
	
	* Loop to create SOURCEID locals
	preserve
	
		keep sourceid indicatorcode
		drop if sourceid == ""
		bysort sourceid indicatorcode : gen dups = _n
		keep if dups == 1
		tab sourceid, m
		
		levelsof sourceid
		return local sourceid  `"`r(levels)'"' 
		
		foreach varvalue in `r(levels)' {
			di `"`varvalue'"'
			sum if sourceid == "`varvalue'" & sourceid != ""
			local obs = r(N)
			local code = word("`varvalue'",1)
			local name = lower("`varvalue'")
			local name = subinstr("`name'"," ","_",.)
			return local sourceid`code' `obs'
			local sourcereturn "`sourcereturn' sourceid`code'"
		}
		
		return local sourcereturn = "`sourcereturn'"

	restore
	
	
	* Loop to create TOPICID locals
	preserve
	
		keep topicid indicatorcode
		drop if topicid == ""
		bysort topicid indicatorcode : gen dups = _n
		keep if dups == 1
		tab topicid, m
	
		levelsof topicid
		return local topicid `"`r(levels)'"'
		
		foreach varvalue in `r(levels)' {
			di `"`varvalue'"'
			sum if topicid == "`varvalue'" & topicid != ""
			local obs = r(N)
			local code = word("`varvalue'",1)
			local name = lower("`varvalue'")
			local name = subinstr("`name'"," ","_",.)
			return local topicid`code' `obs'
			local topicreturn "`topicreturn' topicid`code'"
		}

		return local topicreturn = "`topicreturn'"
		
	restore
	
	
	*******************************************************************************
	*******************************************************************************
				
		*restore

		local ctrytime 			= c(current_time)
		local ctrydatef 		= c(current_date)
		local dt_ctryupdate 		"`ctrydatef' `ctrytime'"

		return local dt_ctryupdate    = "`dt_ctryupdate'"  					
		return local dt_ctrylastcheck = "`dt_ctryupdate'" 
		*return local ctrymeta = `ctrymeta'
	}
	
end


*******************************************************************************
* v 16.0   27Oct2019				by João Pedro Azevedo
*		fix macros
*******************************************************************************
* v 15.1   10Mar2019				by João Pedro Azevedo
*******************************************************************************
