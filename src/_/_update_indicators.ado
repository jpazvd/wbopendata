*******************************************************************************
* _indicators                                                                   
*! v 15.2   10Mar2019				by João Pedro Azevedo
*		initial commit
/*******************************************************************************

cd "C:\GitHub_myados\wbopendata\src"

! git checkout dev

discard

_api_read_indicators, update preserveout


*******************************************************************************/

program define _update_indicators, rclass

version 9

   syntax                               ///
            [ ,                         ///
                FILE(string) 			///
				NOINDLIST				///
				NOSTHLP1 				///
				NOSTHLP2 				///				
			] 			
						 

*******************************************************************************

	tempfile tmp
	
	set checksum off

*******************************************************************************

if ("`file'" == "") {

	tempfile file1 file2

	_api_read_indicators, update preserveout file1(`file1')  file2(`file2')

	local file "`r(file2)'"
	
}

if ("`file'" != "") {

	local file2 "`file'"

}

*******************************************************************************
quietly {

	insheet using `file2', delimiter("#") clear name

	bysort indicatorcode topicid : gen double dups = _n
	bysort indicatorcode  : gen double tot = _N

	foreach var in topicid sourceid {
		replace `var' = subinstr(`var',"&amp;","and",.) 
		replace `var' = subinstr(`var',">"," ",.) 
		replace `var' = string(0)+`var' if length(word(`var',1))==1
	}

	bysort indicatorcode : gen seq = _n

	order indicatorcode indicatorname

	sort sourceid indicatorcode

	label var sourceid "Source"

	label var topicid "Topics"

	save `tmp', replace
		
********************************************
/* Create Indicator list for dialogue box */
********************************************

if ("`noindlist'" == "") {


	noi di in smcl in g ""
	noi di in smcl in g "{bf: Processing indicators list...}"
	noi di in smcl in g ""

	local indicator indicators.txt
	
	tempfile  tmp1tmp
	
	use `tmp' , clear

	keep indicatorcode indicatorname
	bysort indicatorcode : gen seq = _n
	keep if seq == 1
	sort indicatorcode
	outsheet using `tmp1tmp', replace noquote nolabel nonames
	
	cap: findfile `indicator' , `path'
			
	if _rc == 0 {
		copy `tmp1tmp'  `r(fn)' , replace
	}
	else {
		copy `tmp1tmp' `indicator'
	}
	
}

*******************************************************************************
* create sthlp files (sourceid and topicid)
*******************************************************************************

if ("`nosthlp1'" == "") {

	local date: disp %td date("`c(current_date)'", "DMY")
			
	qui foreach variable in sourceid topicid  {
			
		tempfile help`variable'
		tempname hlp`variable'  dups`variable'  seq2`variable' seq3`variable' code`variable'

		use `tmp', clear
		keep if `variable' != ""
				
		sort `type' indicatorcode
		bysort `variable' indicatorcode : gen `dups`variable'' = _n
		keep if `dups`variable'' == 1
		sort `dups`variable'' `variable' indicatorcode
		bysort `dups`variable'' `variable' indicatorcode : gen `seq2`variable'' = _n
		keep if  `seq2`variable'' == 1
		sort `variable' `countryname'
		gen `seq3`variable'' = _n
		gen `code`variable''  = trim(word(`variable',1))
		
		local title : variable label `variable' 
		local title = subinstr("`title'","Code","",.)
				
	**************** header ********************
				
		file open `hlp`variable''		using 	`help`variable'' , write text replace

				
				file write `hlp`variable'' "{smcl}" 					_n
				file write `hlp`variable'`tc0'' "{right:(as of `date')}" 							_n
				file write `hlp`variable'' "" 							_n
				file write `hlp`variable'' "{marker indicators}{...}" 	_n
				file write `hlp`variable'' "{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}" 	_n
				file write `hlp`variable'' "{title:`title'}" 		_n
				file write `hlp`variable'' "" 							_n

				********************************************
				levelsof `variable'

				file write `hlp`variable'' "{marker toc}" 	_n
				file write `hlp`variable'' "{p 40 20 2}(Go up to {it:{help wbopendata##`variable':`title'}}){p_end}" 	_n
				file write `hlp`variable'' "{synoptset 40 tabbed}{...}" 	_n
				file write `hlp`variable'' "{synopthdr:`title' Code}" _n
				file write `hlp`variable'' "{synoptline}" 				_n

				foreach topic in `r(levels)' {
					
					local var1code 	= trim(word("`topic'",1))
					local var1name 	= trim(subinstr("`topic'","`var1code'","",.))
						
					file write `hlp`variable''  "{synopt:{opt `var1code'}}  {help wbopendata_`variable'##`variable'_`var1code':`var1name'}{p_end}" _n
				}

				file write `hlp`variable'' "{synoptline}" 				_n
				file write `hlp`variable'' "" 				_n
				file write `hlp`variable'' "" 				_n
				
				levelsof `variable'
				
				foreach topic in `r(levels)' {
				
					sum `seq3`variable'' if `variable' == "`topic'"
					local min = r(min)
					local max = r(max)

					local topicode0	= `code`variable''		in `min'
					local topicode1	= `variable'		in `min'
					local topicode2 "`variable'_`topicode0'"

					file write `hlp`variable'' "{marker `topicode2'}" 	_n
					file write `hlp`variable'' "{p 40 20 2}(Go up to {it:{help wbopendata_`variable'##`variable'_`topicode0':`title'}} or {it:{help wbopendata_`variable'_indicators`topicode0'##`toc':TOC}}){p_end}" 	_n
					file write `hlp`variable'' "{synoptset 40 tabbed}{...}" 	_n
					file write `hlp`variable'' "{synopthdr:`topicode1'}" _n
					file write `hlp`variable'' "{synoptline}" 				_n
		
					forvalues line = `min'(1)`max'  {

						local indicatorname 	= indicatorname 	in `line'
						local indicatorcode 	= indicatorcode   	in `line'
						
						file write `hlp`variable''  ""  _n
						file write `hlp`variable''  "{synopt:{help wbopendata_`variable'_indicators`topicode0'##`variable'_`indicatorcode':`indicatorcode'{marker `indicatorcode'}}}`indicatorname'{p_end}" _n
						
					}
				
					file write `hlp`variable'' "{synoptline}" 				_n
					file write `hlp`variable''  `""' _n
					
				}
					
				file write `hlp`variable'`tc0'' "{right:(as of `date')}" 							_n

		file close `hlp`variable''
				
				
		cap: findfile wbopendata_`variable'.sthlp , `path'
		
		if _rc == 0 {
			copy `help`variable''  `r(fn)' , replace
		}
		else {
			copy `help`variable'' wbopendata_`variable'.sthlp
		}
				
		noi di in g in smcl "	See {bf:{help wbopendata_`variable'##`variable':`title'}}"
				
	}		
		
		noi di in smcl in g ""
		noi di in smcl in g "{bf: Processing indicators list... COMPLETED!}"
		noi di in smcl in g ""

		
		noi di in smcl in g ""
		noi di in smcl in g "{bf: Processing indicators metadata...}"
		noi di in smcl in g ""

}
		
	*******************************************************************************
	* create sthlp files (sourceid_indicators and topicid_indicators)
	*******************************************************************************

if ("`nosthlp2'" == "") {
	
	local date: disp %td date("`c(current_date)'", "DMY")
			
	qui foreach variable in sourceid topicid  {
			
		tempfile help`variable' tmp2
		tempname hlp`variable'  dups`variable'  seq2`variable' seq3`variable' code`variable' tot`variable'

		use `tmp', clear
		
		keep if `variable' != ""
		sort `type' indicatorcode
		bysort `variable' indicatorcode : gen `dups`variable'' = _n
		*keep if `dups`variable'' == 1
		sort `dups`variable'' `variable' indicatorcode
		bysort `dups`variable'' `variable' indicatorcode : gen `seq2`variable'' = _n
		*keep if  `seq2`variable'' == 1
		sort `variable' indicatorcode
		bysort `variable' : gen `seq3`variable'' = _n
		bysort `variable' : gen `tot`variable'' = _N
		gen `code`variable''  = trim(word(`variable',1))

		local title : variable label `variable' 
		local title = subinstr("`title'","Code","",.)
				
	/**************** header ********************
		
		levelsof sourceid
		local levelsof `"`r(levels)'"'

		foreach topic in `r(levels)' {
			di `""`topic'""'
		}
		
		foreach topic in `levelsof' {
			di `""`topic'""'
			sum seq if sourceid == "`topic'"
		} 
		
	*/

		levelsof `variable'
		local levelsof2 `"`r(levels)'"'
		di "`levelsof'"
				
		save `tmp2' , replace

		qui foreach topic in `levelsof2'  {	
				
			use `tmp2', clear
				
			keep if `variable' == "`topic'"
				
			sum `seq3`variable'' if `variable' == "`topic'"
			local min = r(min)
			local max = r(max)

			local tc0	= `code`variable''		in `min'
			
			tempname hlp`variable'`tc0'
			tempfile help`variable'`tc0'
				
			file open `hlp`variable'`tc0''		using 	`help`variable'`tc0'' , write text replace

				
				file write `hlp`variable'`tc0'' "{smcl}" 					_n
				file write `hlp`variable'`tc0'' "{right:(as of `date')}" 							_n
				file write `hlp`variable'`tc0'' "" 							_n
				file write `hlp`variable'`tc0'' "{marker indicators}{...}" 	_n
				file write `hlp`variable'`tc0'' "{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}" 	_n
				file write `hlp`variable'`tc0'' "{title:`title'}" 		_n
				file write `hlp`variable'`tc0'' "" 							_n

				********************************************

				file write `hlp`variable'`tc0'' "{marker toc}" 	_n
				file write `hlp`variable'`tc0'' "{p 40 20 2}(Go up to {it:{help wbopendata##`variable':`title'}}){p_end}" 	_n
				file write `hlp`variable'`tc0'' "{synoptset 25 tabbed}{...}" 	_n
				file write `hlp`variable'`tc0'' "{synopthdr:`title' Code}" _n
				file write `hlp`variable'`tc0'' "{synoptline}" 				_n

				foreach topic2 in `levelsof2'   {
					
					local var1code 	= trim(word("`topic2'",1))
					local var1name 	= trim(subinstr("`topic2'","`var1code'","",.))
						
					file write `hlp`variable'`tc0''  `"{synopt:{opt `var1code'}}  {help wbopendata_`variable'_indicators`var1code'##`variable'_`var1code':`var1name'}{p_end}"' _n
				}

				file write `hlp`variable'`tc0'' "" 				_n
				file write `hlp`variable'`tc0'' "" 				_n
				
					sum `seq3`variable'' if `variable' == "`topic'"
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
		
		
					levelsof indicatorcode
					foreach indicator in `r(levels)' {

						local indicatorcode 		`indicator'
						levelsof indicatorname if indicatorcode == "`indicator'"
						local indicatorname 		`r(levels)'
						levelsof sourceid if indicatorcode == "`indicator'"
						local sourceid 				`r(levels)'
						levelsof sourceorganization if indicatorcode == "`indicator'"
						local sourceorganization	`r(levels)'
						levelsof sourcenote if indicatorcode == "`indicator'"
						local sourcenote			`r(levels)'
						
						cap: _website, text("`sourceorganization'")
						if _rc == 0 {
							local sourceorganization = r(text)
						}

						cap: _website, text("`sourcenote'")
						if _rc == 0 {
							local sourcenote = r(text)
						}
						
						file write `hlp`variable'`tc0''  "{synoptline}" _n
						file write `hlp`variable'`tc0''  `"{marker `variable'_`indicatorcode'}"' _n
						file write `hlp`variable'`tc0''  `"{synopt:{bf:{help wbopendata_`variable'##`indicatorcode':`indicatorcode'} - `indicatorname'}}"' _n 
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  `"{synopt:{opt Source}}`sourceid'{p_end}"'  _n
						file write `hlp`variable'`tc0''  "" _n
						levelsof topicid 		if indicatorcode == "`indicator'"
						local ccc = 1
						foreach topic in `r(levels)' {
							if (`ccc' == 1) {
								file write `hlp`variable'`tc0''  `"{synopt:{opt Topics}}`topic'{p_end}"'  _n
								local ccc = `ccc'+1
							}
							else {
								file write `hlp`variable'`tc0''  `"{synopt:    }`topic'{p_end}"'  _n
							}
						}
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  `"{synopt:{opt Source Notes}}`sourcenote'{p_end}"'  _n
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  `"{synopt:{opt Source Organization}}`sourceorganization'{p_end}"'  _n
						file write `hlp`variable'`tc0''  "" _n
						file write `hlp`variable'`tc0''  "" _n
						
					}
				
					file write `hlp`variable'`tc0''  `""' _n
					file write `hlp`variable'`tc0'' "{right:(as of `date')}" 							_n

			file close `hlp`variable'`tc0''
				
					
			cap: findfile wbopendata_`variable'_indicators`tc0'.sthlp , `path'
			
			if _rc == 0 {
				copy `help`variable'`tc0''  `r(fn)' , replace
			}
			else {
				copy `help`variable'`tc0'' wbopendata_`variable'_indicators`tc0'.sthlp
			}
					
			noi di in g in smcl "	See {bf:{help wbopendata_`variable'_indicators`tc0'##`toc':`title' `tc0'}}"
			
		}
			
	}		
		
}

********************************************
/* Create return locals */
********************************************

	use `tmp' , clear

	sum if seq == 1
	return local total = r(N)
	
	
	preserve
	
		keep sourceid indicatorcode
		drop if sourceid == ""
		bysort sourceid indicatorcode : gen dups = _n
		keep if dups == 1
		tab sourceid, m
		
		levelsof sourceid
		return local sourceid = r(levels)
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
	
	
	preserve
	
		keep topicid indicatorcode
		drop if topicid == ""
		bysort topicid indicatorcode : gen dups = _n
		keep if dups == 1
		tab topicid, m
	
		levelsof topicid
		return local topicid = r(levels)
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

		noi di in smcl in g ""
		noi di in smcl in g "{bf: Processing indicators metadata... COMPLETED!}"
		noi di in smcl in g ""
		noi di in smcl in g ""

				
		*restore

		local ctrytime 			= c(current_time)
		local ctrydatef 		= c(current_date)
		local dt_ctryupdate 		"`ctrydatef' `ctrytime'"

		return local dt_ctryupdate    = "`dt_ctryupdate'"  					
		return local dt_ctrylastcheck = "`dt_ctryupdate'" 
		*return local ctrymeta = `ctrymeta'
	}
	
end

