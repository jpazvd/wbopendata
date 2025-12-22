*******************************************************************************
* wbopendata             
*! v 17.4  	 22Dec2025               by Joao Pedro Azevedo
*   Add sourcecite return for clean graph source attribution
*******************************************************************************
*! v 17.3  	 22Dec2025               by Joao Pedro Azevedo
*   Support multiple maxlength values: maxlength(40 100 80) linewrap(name description note)
*******************************************************************************
*! v 17.2  	 22Dec2025               by Joao Pedro Azevedo
*   Add linewrap(), maxlength(), linewrapformat() options for graph-ready text
*******************************************************************************
*! v 17.1  	 21Dec2025               by Joao Pedro Azevedo
* 	Bug fixes: #33 (latest option), #35 (country metadata), #45 (URL errors), 
*   #46 (varlist), #51 (match documentation). Contributors acknowledged.
*******************************************************************************

program def wbopendata, rclass

version 9.0

    syntax                                          ///
                 [,                                 ///
                         LANGUAGE(string)           ///
                         COUNTRY(string)            ///
                         TOPICS(string)             ///
                         INDICATORs(string)         ///
                         YEAR(string)               ///
						 DATE(string)				///
						 SOURCE(string)				///
 					 PROJECTION					///					 
                         LONG                       ///
                         CLEAR                      ///
                         LATEST                     ///
                         NOMETADATA                 ///
						 UPDATE						///
						 QUERY						///
						 CHECK						///
						 NOPRESERVE					///
						 PRESERVEOUT				///
						 COUNTRYMETADATA			///
						 ALL						///
						 BREAKNOMETADATA			///
						 METADATAOFFLINE			///
						 FORCE						///
						 SHORT						///
						 DETAIL						///
						 CTRYLIST					///
						 MATCH(string)				///
						 VERBOSE					///
						 LINEWrap(string)			///
						 MAXLength(string)			///
						 LINEWRAPFormat(string)		///
		                 ]

	* Handle plural option name - syntax creates `indicators' but code uses `indicator'
	local indicator "`indicators'"

**********************************************************************************
* option to match	


					qui if ("`match'" != "") {

						_countrymetadata, match(`match') `full' `iso' `isolist' `regionlist' `adminlist' `incomelist' `lendinglist' `capitalist' `isolist' `countryname' `region'  `region_iso2' `regionname' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname'  `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude'

					}

				**********************************************************************************


			local f = 1

			if ("`indicator'" != "") & ("`update'" == "") & ("`match'" == "") {

				_tknz "`indicator'" , parse(;)

				forvalues i = 1(1)`s(items)'  {

				   if ("``i''" != ";") &  ("``i''" != "") {

				   	tempfile file`f'

				   	noi _query ,       language("`language'")      		///
								 country("`country'")         	///
								 topics("`topics'")           	///
								 indicator("``i''")             ///
								 year("`year'")               	///
								 date("`date'")				///
								 source("`source'")				///
								`projection'					///
								 `long'                       	///
								 `clear'                      	///
								 `nometadata'
						local time  "`r(time)'"
						local namek "`r(name)'"

						* default empty metadata locals
						local meta_name ""
						local meta_description ""
						local meta_note ""
						local meta_sourcecite ""
						local meta_topic1 ""
						local meta_topic2 ""
						local meta_topic3 ""
						local meta_collection ""
						local meta_source ""
						local meta_varlabel ""
						local meta_nurls 0

						if ("`nometadata'" == "") & ("`indicator'" != "") {
							local lw_opts ""
							if ("`linewrap'" != "") {
								local ml_opt = cond("`maxlength'" != "", `"maxlength(`maxlength')"', "maxlength(50)")
								local lw_opts `"linewrap(`linewrap') `ml_opt'"'
							}
							if ("`linewrapformat'" != "") local lw_opts `"`lw_opts' linewrapformat(`linewrapformat')"'
							cap: noi _query_metadata  , indicator("``i''") `lw_opts'                  /*  Metadata   */
							local qm1rc = _rc
							if (`qm1rc' != 0) {
								noi di ""
								noi di as err "{p 4 4 2} Sorry... No metadata available for " as result "`indicator'. {p_end}"
								noi di ""
								if ("`breaknometadata'" != "") {
									break
									exit 21
								}
							}
							else {
								* Capture metadata returns before they get overwritten
								local meta_name        "`r(name)'"
								local meta_description "`r(description)'"
								local meta_note        "`r(note)'"
								local meta_sourcecite  `"`r(sourcecite)'"'
								local meta_topic1      "`r(topic1)'"
								local meta_topic2      "`r(topic2)'"
								local meta_topic3      "`r(topic3)'"
								local meta_collection  "`r(collection)'"
								local meta_source      "`r(source)'"
								local meta_varlabel    "`r(varlabel)'"
								* Capture URLs
								local meta_nurls = r(nurls)
								if (`meta_nurls' > 0) {
									forvalues u = 1/`meta_nurls' {
										local meta_url`u' "`r(url`u')'"
									}
								}
								* Capture linewrap returns
								if ("`linewrap'" != "") {
									local meta_name_stack `"`r(name_stack)'"'
									local meta_description_stack `"`r(description_stack)'"'
									local meta_note_stack `"`r(note_stack)'"'
									local meta_source_stack `"`r(source_stack)'"'
									local meta_topic_stack `"`r(topic_stack)'"'
								}
							}
						}

						local w1 = word("``i''",1)
						return local varname`f'     = trim(lower(subinstr(word("`w1'",1),".","_",.)))
						return local indicator`f'  "`w1'"
						return local topics`f'     "`topics'"
						return local year`f'       "`year'"
						return local source`f'     "`meta_source'"
						return local varlabel`f'   "`meta_varlabel'"
						return local time`f'       "`time'"
						return local name`f'       "`meta_name'"
						return local description`f' "`meta_description'"
						return local note`f'       "`meta_note'"
						return local sourcecite`f' `"`meta_sourcecite'"'
						return local topic1_`f'    "`meta_topic1'"
						return local topic2_`f'    "`meta_topic2'"
						return local topic3_`f'    "`meta_topic3'"
						return local collection`f' "`meta_collection'"
						* Return URLs for this indicator
						return scalar nurls`f' = `meta_nurls'
						if (`meta_nurls' > 0) {
							forvalues u = 1/`meta_nurls' {
								return local url`u'_`f' "`meta_url`u''"
							}
						}
						* Return linewrap results for this indicator
						if ("`linewrap'" != "") {
							if (`"`meta_name_stack'"' != "") {
								return local name`f'_stack `"`meta_name_stack'"'
							}
							if (`"`meta_description_stack'"' != "") {
								return local description`f'_stack `"`meta_description_stack'"'
							}
							if (`"`meta_note_stack'"' != "") {
								return local note`f'_stack `"`meta_note_stack'"'
							}
							if (`"`meta_source_stack'"' != "") {
								return local source`f'_stack `"`meta_source_stack'"'
							}
							if (`"`meta_topic_stack'"' != "") {
								return local topic`f'_stack `"`meta_topic_stack'"'
							}
						}
					
						sort countrycode year
						if ("`verbose'" != "") {
							noi di as txt "  Saving indicator `f': ``i'' to tempfile"
							save `file`f''
						}
						else {
							qui save `file`f''
						}
						local f = `f'+1
						local name "`name' `namek'"

					}

				}

			}

			 else {

				if ("`update'" == "") & ("`match'" == "") {
			 
					noi _query , language("`language'")       	///
								country("`country'")        ///
								topics("`topics'")         ///
								indicator("`indicator'")   ///
								year("`year'")            ///
								date("`date'")			///
								source("`source'")			///
								`projection'				///
								`long'					///
								`clear'					///
								`latest'				///
								`nometadata'
					local time  "`r(time)'"
					local name "`r(name)'"

					* default empty metadata locals
					local meta_name ""
					local meta_description ""
					local meta_note ""
					local meta_sourcecite ""
					local meta_topic1 ""
					local meta_topic2 ""
					local meta_topic3 ""
					local meta_collection ""
					local meta_source ""
					local meta_varlabel ""
					local meta_nurls 0


					if ("`nometadata'" == "") & ("`indicator'" != "") {
						local lw_opts ""
						if ("`linewrap'" != "") {
							local ml_opt = cond("`maxlength'" != "", `"maxlength(`maxlength')"', "maxlength(50)")
							local lw_opts `"linewrap(`linewrap') `ml_opt'"'
						}
						if ("`linewrapformat'" != "") local lw_opts `"`lw_opts' linewrapformat(`linewrapformat')"'
						cap: noi _query_metadata  , indicator("`indicator'") `lw_opts'                  /*  Metadata   */
						local qm2rc = _rc
						if (`qm2rc' != 0) {
							noi di ""
							noi di as err "{p 4 4 2} Sorry... No metadata available for " as result "`indicator'. {p_end}"
							noi di ""
							if ("`breaknometadata'" != "") {
								exit 22
							}
						}
						else {
							* Capture metadata returns before they get overwritten
							local meta_name        "`r(name)'"
							local meta_description "`r(description)'"
							local meta_note        "`r(note)'"
							local meta_sourcecite  `"`r(sourcecite)'"'
							local meta_topic1      "`r(topic1)'"
							local meta_topic2      "`r(topic2)'"
							local meta_topic3      "`r(topic3)'"
							local meta_collection  "`r(collection)'"
							local meta_source      "`r(source)'"
							local meta_varlabel    "`r(varlabel)'"
							* Capture URLs
							local meta_nurls = r(nurls)
							if (`meta_nurls' > 0) {
								forvalues u = 1/`meta_nurls' {
									local meta_url`u' "`r(url`u')'"
								}
							}
							* Capture linewrap returns
							if ("`linewrap'" != "") {
								local meta_name_stack `"`r(name_stack)'"'
								local meta_description_stack `"`r(description_stack)'"'
								local meta_note_stack `"`r(note_stack)'"'
								local meta_source_stack `"`r(source_stack)'"'
								local meta_topic_stack `"`r(topic_stack)'"'
							}
						}
					}

				}

				local w1 = word("`indicator'",1)
				return local varname1     = trim(lower(subinstr(word("`w1'",1),".","_",.)))
				return local indicator1  "`w1'"
				return local country1    "`country'"
				return local topics1     "`topics'"
				return local year1       "`year'"
				return local source1     "`meta_source'"
				return local varlabel1   "`meta_varlabel'"
				return local time1       "`time'"
				return local name1       "`meta_name'"
				return local description1 "`meta_description'"
				return local note1       "`meta_note'"
				return local sourcecite1 `"`meta_sourcecite'"'
				return local topic1_1    "`meta_topic1'"
				return local topic2_1    "`meta_topic2'"
				return local topic3_1    "`meta_topic3'"
				return local collection1 "`meta_collection'"
				return scalar nurls1 = `meta_nurls'
				if (`meta_nurls' > 0) {
					forvalues u = 1/`meta_nurls' {
						return local url`u'_1 "`meta_url`u''"
					}
				}
				* Return linewrap results
				if ("`linewrap'" != "") {
					if (`"`meta_name_stack'"' != "") {
						return local name1_stack `"`meta_name_stack'"'
					}
					if (`"`meta_description_stack'"' != "") {
						return local description1_stack `"`meta_description_stack'"'
					}
					if (`"`meta_note_stack'"' != "") {
						return local note1_stack `"`meta_note_stack'"'
					}
					if (`"`meta_source_stack'"' != "") {
						return local source1_stack `"`meta_source_stack'"'
					}
					if (`"`meta_topic_stack'"' != "") {
						return local topic1_stack `"`meta_topic_stack'"'
					}
				}

				local name = trim(lower(subinstr(word("`w1'",1),".","_",.)))

			}

		return local indicator  "`indicator'"
		local f = `f'-1

		if (`f' != 0) {

			if ("`long'" != "") {
				use `file1'
				sort countrycode year
				forvalues i = 2(1)`f'  {
					merge countrycode year using `file`i''
					drop _merge
					sort countrycode `time'
				}
			}

			if ("`long'" == "") {
				use `file1'
				forvalues i = 2(1)`f'  {
					append using `file`i''
				}
			}
		}

		* Build variable name list from indicator codes (e.g., "sh_dyn_mort si_pov_dday")
		local varlist  = "`indicator'"
		local varlist = lower("`varlist'")
		local varlist = subinstr("`varlist'",";"," ",.)	
		local varlist = subinstr("`varlist'",".","_",.)
		local varlist = trim(itrim("`varlist'"))
		return local name "`varlist'"

		if ("`latest'" != "") &  ("`long'" != "") {
		    
			* For multiple indicators: keep latest year where ALL indicators are non-missing
			* Count number of indicators
			local nind : word count `varlist'
			
			if (`nind' > 1) {
				* Multiple indicators: keep only observations where all are non-missing
				tempvar nmiss
				egen `nmiss' = rowmiss(`varlist')
				qui count if `nmiss' == 0
				local n_complete = r(N)
				local n_before = _N
				
				if (`n_complete' == 0) {
					noi di as err "{p 4 4 2}Warning: No observations found where all indicators have non-missing values.{p_end}"
					noi di as txt "{p 4 4 2}Keeping latest available year per country instead.{p_end}"
					* Fall back to simple latest
					sort countrycode year
					qui bysort countrycode : keep if _n==_N
				}
				else {
					* Keep only complete cases, then latest year per country
					if ("`verbose'" != "") {
						noi di as txt "  Filtering: keeping observations with all `nind' indicators non-missing"
						keep if `nmiss' == 0
						local n_after_miss = _N
						noi di as txt "  Filtering: selecting latest year per country"
					}
					else {
						qui keep if `nmiss' == 0
					}
					sort countrycode year
					qui bysort countrycode : keep if _n==_N
					local n_final = _N
					noi di as txt "{p 4 4 2}Note: Kept `n_final' countries with latest year where all `nind' indicators are non-missing.{p_end}"
				}
			}
			else {
					* Single indicator: simple latest per country
					sort countrycode year
					qui bysort countrycode : keep if _n==_N
				}
			}
			
			* Compute macro when latest option is selected
			qui count
			local _latest_ncountries = r(N)
			qui sum year, meanonly
			local _latest_avgyear = string(r(mean), "%9.1f")
			local _latest "Latest Available Year, `_latest_ncountries' Countries (avg year `_latest_avgyear')"
			return local latest "`_latest'"
			return local latest_ncountries "`_latest_ncountries'"
			return local latest_avgyear "`_latest_avgyear'"
	
**********************************************************************************
	

	qui if ("`update'" == "") {

		tostring  countryname countrycode, replace

		_countrymetadata, match(countrycode) `full' `iso' `regions' `adminr' `income' `lending' `capitals' `basic' `countrycode_iso2' `region' `region_iso2' `regionname' `adminregion' `adminregion_iso2' `adminregionname' `incomelevel' `incomelevel_iso2' `incomelevelname' `lendingtype' `lendingtype_iso2' `lendingtypename' `capital' `longitude' `latitude' `countryname'

	}
	
**********************************************************************************
	
	
	if ("`nopreserve'" == "") {
		return add
	}
	
end


*******************************************************************************
*  v 16.3  	8Jul2020               by Joao Pedro Azevedo
* 	change API end point to HTTPS
*******************************************************************************
**********************************************************************************
*  v 16.2.3    29Jun2020 				by Joao Pedro Azevedo
*	 rewrote query metadata. It now uses _api_read.ado
**********************************************************************************
*  v 16.2.2    28Jun2020 				by Joao Pedro Azevedo
*	 changed server used to query metadata
***********************************************************************************
