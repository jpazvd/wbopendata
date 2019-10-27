*******************************************************************************
* wbopendata                                                                  *
*!  v 16.0	    27Oct2019               by Joao Pedro Azevedo 
* created and tested new functions, namely:
  * _api_read_indicators.ado : download indicator list from API, for formats output in a Stata readable form
  * _update_indicators.ado: calls _api_read_indicators.ado, and uses its output to generate several documentation outputs for wbopendata:
    * dialogue indicator list
    * sthlp indicator list by Source and Topic
    * sthlp indicator metadata by Source and Topic
 * match option supported in wbopendata (add countrymetadata matching on MATCH var) 
 * _website.ado : screens a text file and converts and http or www "word" to a SMCL web compatible code.
 * _parameters.ado: now include detailed count of indicators by SOURCE and TOPIC
 * _wbopendata.ado: renamned _update_wbopendata
 * _indicator: renamed _update_indicators
 * _update_wbopendata.ado: now checks for changes at the SOURCE or TOPIC level
 * updated help file to allow for the search of indicators by Source and Topics
*******************************************************************************

program def wbopendata, rclass

version 9.0

    syntax                                          ///
                 [,                                 ///
                         LANGUAGE(string)           ///
                         COUNTRY(string)            ///
                         TOPICS(string)             ///
                         INDICATOR(string)          ///
                         YEAR(string)               ///
                         LONG                       ///
                         CLEAR                      ///
                         LATEST                     ///
                         NOMETADATA                 ///
						 UPDATE						///
						 QUERY						///
						 CHECK						///
						 NOPRESERVE					///
						 PRESERVEOUT				///
						 FULL						///
						 ISO						///
						 COUNTRYMETADATA			///
						 ALL						///
						 BREAKNOMETADATA			///
						 FORCE						///
						 SHORT						///
						 DETAIL						///
						 MATCH(string)				///
							ISO					///
							REGIONS				///
							ADMINR				///
							INCOME				///
							LENDING				///
							CAPITALS			///
							BASIC				///
							FULL				///
							countrycode_iso2 	///
							region 				///
							region_iso2 		///
							regionname 			///
							adminregion 		///
							adminregion_iso2 	///
							adminregionname 	///
							incomelevel 		///
							incomelevel_iso2 	///
							incomelevelname 	///
							lendingtype 		///
							lendingtype_iso2 	///
							lendingtypename 	///
							capital 			///
							latitude 			///
							longitude 			///
							countryname			///
                 ]


	quietly {
	
	
**********************************************************************************

		if ("`query'" != "") & ("`check'" != "") {
			noi di  as err "update query and update check options cannot be selected at the same time."
			exit 198
		}
	
		set checksum off
	
		if ("`update'" != "") & wordcount("`query' `check' `countrymetadata' `all'")==0 {
		
			noi wbopendata, update query
			break
		}
		
			
		if ("`update'" != "") & wordcount("`query' `check' `countrymetadata' `all'")== 1 {

			noi _update_wbopendata, update `query' `check'	`countrymetadata' `all' `force' `short' `detail' 
			break
					
		}

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

				   noi _query ,       language("`language'")       ///
										 country("`country'")         ///
										 topics("`topics'")           ///
										 indicator("``i''")             ///
										 year("`year'")               ///
										 `long'                       ///
										 `clear'                      ///
										 `nometadata'
					local time  "`r(time)'"
					local namek "`r(name)'"


					if ("`nometadata'" == "") & ("`indicator'" != "") {
						cap: noi _query_metadata  , indicator("``i''")                  /*  Metadata   */
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
					}

					local w1 = word("``i''",1)
					return local varname`f'     = trim(lower(subinstr(word("`w1'",1),".","_",.)))
					if ("`name'" != "") {
						return local varname`f' "`name'"
					}
					return local indicator`f'  "`w1'"
					return local topics`f'     "`topics'"
					return local year`f'       "`year'"
					return local source`f'     "`r(source)'"
					return local varlabel`f'   "`r(varlabel)'"
					return local time`f'       "`time'"

					local namek = trim(lower(subinstr(word("`w1'",1),".","_",.)))

					if ("`long'" != "") {
						sort countrycode `time'
					}

					save `file`f''

					local f = `f'+1

				}

				local name "`name' `namek'"

			}

		}

		 else {

			if ("`update'" == "") & ("`match'" == "") {
			 
				noi _query , language("`language'")       ///
								  country("`country'")         ///
								  topics("`topics'")           ///
								  indicator("``i''")             ///
								  year("`year'")               ///
								  `long'                       ///
								  `clear'                      ///
								  `latest'                     ///
								  `nometadata'
				local time  "`r(time)'"
				local name "`r(name)'"


				if ("`nometadata'" == "") & ("`indicator'" != "") {
					cap: noi _query_metadata  , indicator("``i''")                  /*  Metadata   */
					local qm2rc = _rc
					if ("`qm2rc'" == "") {
						noi di ""
						noi di as err "{p 4 4 2} Sorry... No metadata available for " as result "`indicator'. {p_end}"
						noi di ""
						if ("`breaknometadata'" != "") {
							break
							exit 22
						}
					}
				}
				
			}

			local w1 = word("`indicator'",1)
			return local varname1     = trim(lower(subinstr(word("`w1'",1),".","_",.)))
			if ("`name'" != "") {
				return local varname1 "`name'"
			}
			return local indicator1  "`w1'"
			return local country1    "`country'"
			return local topics1     "`topics'"
			return local year1       "`year'"
			return local source1     "`r(source)'"
			return local varlabel1   "`r(varlabel)'"
			return local time1       "`time'"

			local name = trim(lower(subinstr(word("`w1'",1),".","_",.)))

		}

		return local indicator  "`indicator'"
		local f = `f'-1

		if (`f' != 0) {

			if ("`long'" != "") {
				use `file1'
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

		if ("`latest'" != "") &  ("`long'" != "") {
			tempvar tmp
			egen `tmp' = rowmiss(`name')
			keep if `tmp' == 0
			sort countryname countrycode `time'
			bysort countryname countrycode : keep if _n==_N
		}

	}
	
	
**********************************************************************************
	

	qui if ("`update'" == "") {

		tostring  countryname countrycode, replace

		_countrymetadata, match(countrycode) `full' `iso'

	}
	
**********************************************************************************
	
	
	if ("`nopreserve'" == "") {
		return add
	}
	
end


**********************************************************************************
*  v 15.1	    04Mar2019               by Joao Pedro Azevedo 
*	New Features
*		new error categories to faciliate debuging
*		error 23: series no longer supported moved to archive
*		country attribute table fully revised and linked to api
*		update check, update query, and update
*		auto refresh indicators
*		revised _wbopendata.ado 		
*		update query; update check; and update options are included
* 		country attributes revised
*		update countrymetadata option created
*		country metadata documentation in help file revised
*		break code when no metadata is available is now an option
*   Revisions
*       over 16,000 indicators
*  v 15.0.1		8Fev2019				by Joao Pedro Azevedo
*  v 15.0	    2Fev2019               	by Joao Pedro Azevedo 
*  v 14.3 	2Feb2019               by Joao Pedro Azevedo 
* 	Bug Fixed
*		_wbopendata_update.ado revised; out.txt file no longer created
*  v 14.2 	31Jan2019               by Joao Pedro Azevedo 
* Bug Fixed
	* update _wbopendata_update.ado
	* set checksum off
*  v 14.1 	19Jan2019               by Joao Pedro Azevedo 
* 	New options: 
     * indicator update function
     * nopreserve option (return list is can be preserved)
* 	Bugs fixed
    * latest option
    * _query_metadata.ado (source id return list) fixed
* 	Revisions
     * examples
     * update help file
     * list of indicators
*  v 14.0  14Jan2019               by Joao Pedro Azevedo 
*		revised indicator list
*		change to new API server 
*  v 13.4  01jul2014               by Joao Pedro Azevedo                        *
*       long reshape
*  v 13.3  30june2014               by Joao Pedro Azevedo                        *
*       new error control (clear option)
*  v 13.2  24june2014               by Joao Pedro Azevedo                        *
*       new error control
*  v 13.1  23june2014               by Joao Pedro Azevedo                        *
*       regional code, name and iso2code
*  v 13  20june2014               by Joao Pedro Azevedo                        *
* 		fix the dups problem                                                    *
*       improve the error messages                                              *
*       update the list of indicators to 9960                                 *
*  v 12  31jan2013               by Joao Pedro Azevedo                        *
*       update to 7349 indicators
*       return list include variable name and label
**********************************************************************************
