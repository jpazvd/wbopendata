*******************************************************************************
* _query
*! v 16.8  	23Feb2026               by Joao Pedro Azevedo
*   16.8: Document manifest format and cache key assumptions
*   16.7: Add verbose option, targeted error handling for cache operations
*   16.6: Fix cache lookup (targeted capture), add cachedays() TTL option
*   16.5: Data response cache (7-day TTL, on by default, nocache to bypass)
* 	16.3: change API end point to HTTPS
*******************************************************************************

program def _query, rclass

version 9.0

    syntax                                          ///
                 [,                                 ///
                         LANGUAGE(string)           ///
                         COUNTRY(string)            ///
                         TOPICS(string)             ///
                         INDICATOR(string)          ///
                         YEAR(string)               ///
						 DATE(string)				///
                         LONG                       ///
                         CLEAR                      ///
                         LATEST                     ///
                         NOMETADATA                 ///
						 PROJECTION					///
						 SOURCE(string)				///
						 noCHAR					///
						 OFFLINE(string)		///
						 NOCACHE				///
						 CACHEDAYS(integer 7)	///
						 VERBOSE				///
                 ]

if ("`verbose'" == "") {
    local noi ""
}
else {
    local noi "noi "
}

quietly {

    if ("`language'" == "") {
        local language "en"
    }

    if ("`language'" != "") {
        local language = word("`language'",1)
    }

    if ("`country'" != "") {

        local country1 = word("`country'",1)
        local t = substr("`country1'",-1,1    )
        if ("`t'" == ";") {
            local l = length("`country1'")
            local l = `l'-1
            local country1 = substr("`country'",1,`l')
        }
        local q = subinstr("`country1'",";"," ",.)
        local q = wordcount("`q'")
        if (`q'>1) & ("`indicator'" == "") {
            noi di as err "Users can not select multiple countries without specifying the indicator of interest. Please try again."
            exit 198
        }
        local parameter "Countries/`country1'"
        local id "indicatorname indicatorcode "
    }

    if ("`topics'" != "") {
        local topics1 = word("`topics'",1)
        local parameter "Topics/`topics1'"
        local id " countryname countrycode indicatorname indicatorcode "
    }

    if ("`indicator'" != "") {
        local indicator1 = word("`indicator'",1)
        local indicator2 = subinstr("`indicator'","`indicator1'","",.)
        local indicator2 = trim(subinstr("`indicator2'","-","",.))
        if ("`indicator2'" == "") {
            local indicator2 "`indicator1'"
        }
        if ("`projection'" != "") {
			local source "source=40&"
		}
		if ("`date'" != "") {
			local date1 "&date=`date'"
		}
		else {
			local date1 ""
		}
		if ("`year'" != "") {
			local year1	"&date=`year'"
		}
		else {
			local year1 	""
		}
		
        local parameter "Indicators/`indicator1'?`source'downloadformat=CSV&HREQ=N&filetype=data`year1'`date1'"
        local id " countryname countrycode "
    }


    if  ("`country'" == "") & ("`topics'" == "") & ("`indicator'" == "") {
        di  as err "Users need to select either a country, a topic, or an indicator. Please try again."
        exit 198
    }
    if  ("`country'" != "") & ("`topics'" != "") & ("`indicator'" == "") {
        di  as err "Users can not select a country and a topic at the same time. Please try again."
        exit 198
    }
    if  ("`country'" == "") & ("`topics'" != "") & ("`indicator'" != "") {
        di  as err "Users can not select an indicator and a topic at the same time. Please try again."
        exit 198
    }
    if  ("`indicator'" == "") & ("`year'" != "") {
        di  as err "year option can only be used for the selection of specific indicators. Please try again."
        exit 198
    }
    if  ("`indicator'" == "") & ("`latest'" != "") {
        di  as err "latest option can only be used for the selection of specific indicators in the long format. Please try again."
        exit 198
    }
    if  ("`indicator'" != "") & ("`latest'" != "") & ("`long'" == "") {
        di  as err "latest option can only be used for the selection of specific indicators in the long format. Please try again."
        exit 198
    }
	if ("`year'" != "") & ("`date'" != "") {
		di  as err "only YEAR or DATE can be specified at once. Please try again."
		exit 198
	}
    if ("`country'" == "") & ("`indicator'" != "") {
        local country2 "all"
    }
    if ("`country'" != "") & ("`indicator'" != "") {
        local country2 "`country1'"
    }

    tempfile temp

    * --- Build data cache key (used by both cache lookup and cache save) ---
    * Cache key format: ind_CODE_CTRY_LANG[_DATE][_srcID].csv or topic_ID_LANG.csv or country_CODE_LANG.csv
    * NOTE: Cache key filenames must not contain pipe (|) characters, as pipes are used
    *       as delimiters in the manifest file. This is enforced by converting special chars
    *       to underscores in the key construction below.
    local _cache_hit = 0
    local _cache_key ""
    local _dc_dir ""
    local _cache_file ""
    local _manifest ""

    if ("`offline'" == "" & "`nocache'" == "") {
        local _dc_dir "`c(sysdir_plus)'_/_wbopendata_datacache/"
        local _dc_dir : subinstr local _dc_dir "\" "/" , all
        capture mkdir "`_dc_dir'"

        * Build cache key filename from query parameters
        if ("`indicator'" != "") {
            local _ck_ind : subinstr local indicator1 "." "_", all
            local _ck_ind = lower("`_ck_ind'")
            local _ck_cty : subinstr local country2 ";" "_", all
            local _ck_cty = lower("`_ck_cty'")
            local _ck_date ""
            if ("`year1'" != "") {
                local _ck_date : subinstr local year1 "&date=" ""
                local _ck_date : subinstr local _ck_date ":" "_", all
                local _ck_date "_`_ck_date'"
            }
            if ("`date1'" != "") {
                local _ck_date : subinstr local date1 "&date=" ""
                local _ck_date : subinstr local _ck_date ":" "_", all
                local _ck_date "_`_ck_date'"
            }
            local _ck_src ""
            if ("`source'" != "") local _ck_src "_src40"
            local _cache_key "ind_`_ck_ind'_`_ck_cty'_`language'`_ck_date'`_ck_src'"
        }
        else if ("`topics'" != "") {
            local _cache_key "topic_`topics1'_`language'"
        }
        else {
            local _cache_key "country_`country1'_`language'"
        }
        local _cache_file "`_dc_dir'`_cache_key'.csv"
        local _manifest "`_dc_dir'_manifest.txt"
        `noi' di as text "(datacache: key=`_cache_key')"

        * Check manifest for TTL — only file I/O is protected by capture
        * Manifest format: pipe-delimited text file with lines: FILENAME|DATE
        *   Example: "ind_sp_pop_totl_usa_en.csv|23 Feb 2026"
        *   TTL is checked by comparing current_date with stored date (requires Stata date format)
        if (fileexists("`_cache_file'") & fileexists("`_manifest'")) {
            local _ttl_days = `cachedays'
            capture {
                tempname _mfh
                file open `_mfh' using "`_manifest'", read
                file read `_mfh' _mline
                while (r(eof) == 0) {
                    local _ppos = strpos(`"`_mline'"', "|")
                    if (`_ppos' > 0) {
                        local _mfile = trim(substr(`"`_mline'"', 1, `_ppos' - 1))
                        local _mlen = length(`"`_mline'"')
                        local _mdate = trim(substr(`"`_mline'"', `_ppos' + 1, `_mlen' - `_ppos'))
                    }
                    else {
                        local _mfile ""
                        local _mdate ""
                    }
                    if ("`_mfile'" == "`_cache_key'.csv") {
                        local _cached_dt = date("`_mdate'", "DMY")
                        local _today_dt = date("`c(current_date)'", "DMY")
                        if (!missing(`_cached_dt') & !missing(`_today_dt')) {
                            if (`_today_dt' - `_cached_dt' <= `_ttl_days') {
                                local _cache_hit = 1
                            }
                        }
                    }
                    file read `_mfh' _mline
                }
                file close `_mfh'
            }
            if (_rc != 0) {
                local _cache_hit = 0
                capture file close `_mfh'
                `noi' di as text "(datacache: manifest read failed, rc=" _rc ")"
            }
        }
        `noi' di as text "(datacache: `_cache_key' " cond(`_cache_hit', "HIT", "MISS") ")"
    }

    * --- Offline fixture injection ---
    * When offline() option is set to a directory path, data is read from
    * local CSV fixture files instead of the World Bank API.
    if ("`offline'" != "") {
        if ("`indicator'" != "") {
            local _ind_name = subinstr("`indicator1'", ".", "_", .)
            local _cty_name = subinstr("`country2'", ";", "_", .)
            local _fixture_file "`offline'/`_ind_name'_`_cty_name'.csv"
        }
        else if ("`topics'" != "") {
            local _fixture_file "`offline'/topic_`topics1'.csv"
        }
        else {
            local _fixture_file "`offline'/country_`country1'.csv"
        }
        cap confirm file "`_fixture_file'"
        if _rc != 0 {
            noi di as err "Offline fixture not found: `_fixture_file'"
            exit 601
        }
        noi di as text "(offline mode: reading from `_fixture_file')"
        copy "`_fixture_file'" `temp', replace
        if ("`indicator'" != "") {
            local queryspec2 "indicator `indicator1'"
        }
        else {
            local queryspec2 "topic `topics1'"
        }
    }
    * --- Data cache hit ---
    else if (`_cache_hit') {
        noi di as text "(using cached data: `_cache_key'.csv, TTL `cachedays'd)"
        copy "`_cache_file'" `temp', replace
        if ("`indicator'" != "") {
            local queryspec2 "indicator `indicator1'"
        }
        else if ("`topics'" != "") {
            local queryspec2 "topic `topics1'"
        }
        else {
            local queryspec2 "country `country1'"
        }
    }
    * --- Online download from World Bank API ---
    else {

	loc servername "https://api.worldbank.org/v2"  /* Query server v2 */


/* country selection */
    if  (("`country'" != "") | ("`topics'" != "")) &  ("`indicator'" == "") {
        local queryspec "`servername'/`language'/`parameter'/?downloadformat=CSV&HREQ=N&filetype=data"
        local queryspec2 "topic `topics1'"
        capture : copy "`queryspec'" `temp' , public
        local rc1 = _rc
        if (`rc1' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "https://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "https://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please consider setting Stata checksum off. {help set checksum}{p_end}"'
            noi dis as text `"{p 4 4 2} (5) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc1'
            break
        }
    }
/* Indicator selection */
    if  ("`indicator'" != "") {
        local queryspec "`servername'/`language'/countries/`country2'/`parameter'"
        local queryspec2 "indicator `indicator1'"
        capture : copy "`queryspec'" `temp' , public
        local rc2 = _rc
        if (`rc2' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "https://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "https://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please consider setting Stata checksum off. {help set checksum}{p_end}"'
            noi dis as text `"{p 4 4 2} (5) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc2'
            break
        }
    }

    * Save successful download to data cache
    if ("`nocache'" == "" & "`_cache_file'" != "") {
        cap : copy `temp' "`_cache_file'", replace
        if (_rc == 0) {
            cap _wbod_dc_manifest_update "`_manifest'" "`_cache_key'.csv"
            if (_rc != 0) {
                `noi' di as text "(datacache: manifest update failed, rc=" _rc ")"
            }
            else {
                `noi' di as text "(datacache: saved `_cache_key'.csv)"
            }
        }
        else {
            `noi' di as text "(datacache: save failed, rc=" _rc ")"
        }
    }

    } /* end of offline/cache/online branch */

    cap : insheet using `temp', `clear' name
    local rc3 = _rc
    if (`rc3' != 0) {
        noi di ""
        di  as err "you must start with an empty dataset; or enable the clear option."
        noi di ""
        exit `rc3'
        noi di ""
        break
    }


***************************************************

    qui foreach var of varlist _all {

        local varname : variable label `var'
        if (real("`varname'") != .) {
            rename `var' yr`varname'
            local l1    "yr"
            local l2    "year"
            local l3    ""
            local l4    "lab var year Year"
            local t1  "year"
        }
        else {
            if match("`varname'","*Q*") == 1 {
                local tmp0 = subinstr("`varname'","Q","-",.)
                local tmp1 = tq(`tmp0')
                rename `var' q`tmp1'
                local l1    "q"
                local l2    "quarter"
                local l3    "format quarter %tq"
                local l4    "lab var quarter Quarter"
                local t1  "quarter"
            }
        }
    }

    return local period = "`l2'"

    if ("`l2'" == "") {		
	
		local indicator = trim(subinstr("`queryspec2'","indicator","",.))

		cap : _api_read , query("https://api.worldbank.org/v2/Indicators/`indicator'") ///
			nopreserve ///
			list ///
			parameter(indicator?id name source?id) ///
			offline("`offline'")
			
			
			
		if (strmatch("`r(line1)'","*error*") == 0) & (_rc == 0) {
		
			noi di ""
			noi di in g "{p 4 4 2} Sorry... but indicator " as result "`r(indicator_id2)'" in g " has been moved to " as result "`r(source_id5)'. {p_end}"
			noi di ""
			noi dis as text `"{p 4 4 2} Please send us an email to obtain more information {browse "mailto:data@worldbank.org, ?subject= wbopendata query error 23 at `c(current_date)' `c(current_time)': https://api.worldbank.org/v2/Indicators/`indicator' "  :clicking here} or writing to:  {p_end}"'
			noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
			noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error 23 [`r(indicator_id2)' - `r(name3)'] at `c(current_date)' `c(current_time)': https://api.worldbank.org/v2/Indicators/`indicator'  {p_end}"'
			noi di ""
			noi di ""
			break
			exit 23
		
		}

		if strmatch("`r(line1)'","*error*") == 1 | (_rc != 0) {

			noi di ""
			noi di as err "{p 4 4 2} Sorry... No data was downloaded for " as result "`queryspec2'. {p_end}"
			noi di ""
			noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "https://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
			noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "https://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support, otherwise...  {p_end}"'
			noi dis as text `"{p 4 4 2} (3) Please check the availability of your indicator or topic by {browse "`queryspec'" :clicking here}. If the paramater value is not valid...  {p_end}"'
			noi dis as text `"{p 4 4 2} (4) Please check the list of available indictator(s) or topic(s) in the help {help wbopendata} or by visiting the {browse "https://data.worldbank.org/querybuilder" :API query builder}, if all the above seems fine...  {p_end}"'
			noi dis as text `"{p 4 4 2} (5) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
			noi dis as text `"{p 4 4 2} (6) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
			noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
			noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
			noi di ""
			noi di ""
			break
			exit 20
			
		}
    }

    cap: drop v*
    cap: drop r*
    cap: drop tg*

***************************************************

    if (("`long'" == "") & ("`country'" != "")) &  ("`indicator'" == "") {
        order countryname countrycode
        lab var countryname "Country Name"
        lab var countrycode "Country Code"
    }

    if ("`long'" == "") & ("`indicator'" != "") {
        order countryname countrycode indicatorname indicatorcode
        lab var indicatorname "Indicator Name"
        lab var indicatorcode "Indicator Code"
    }

***************************************************

    if (("`long'" != "") & ("`country'" != "")) &  ("`indicator'" == "") {

        tempvar dups
        bysort  `id'  indicatorname indicatorcode : gen `dups' = _n
        sum `dups'

        if  (`r(mean)' > 1) {
            noi di as text `""'
            noi di as text `"{p 4 4 2}  WARNING: country/indicator duplicates found in the country `country' were eliminated. Please report this issue by {browse "mailto: data@worldbank.org ?subject=wbopendata helpdesk: duplicate indicators in country (`country') fount at at `c(current_date)' `c(current_time)'" : clicking here}.  {p_end}"'
            noi di as text `""'
            noi di as text `""'
            drop if `dups' == 2
            drop `dups'
        }

        order countryname countrycode
        lab var countryname "Country Name"
        lab var countrycode "Country Code"

        reshape long `l1' , i( countryname countrycode  `id') j(`l2')
        `l3'
        `l4'
        rename `l1' value
        replace indicatorname = indicatorcode + " " + indicatorname
        encode  indicatorname, gen(indic)
        drop indicatorname  indicatorcode
        _pecats2 indic
        loc cat "`r(catvals)'"
        foreach i in  `cat' {
            local t`i' : label indic `i'
            local k`i' = word("`t`i''", 1)
            local j`i' = trim(subinstr("`t`i''","`k`i''","",.))
            local n`i' = trim(lower(subinstr(word("`t`i''", 1),".","_",.)))
        }
        reshape wide value , i( countryname countrycode `l2') j(  indic)
        foreach i in `cat' {
            rename value`i'  `n`i''
            lab var `n`i'' "`j`i''"
        }
        `l3'
        `l4'
    }

    if ("`long'" != "") & ("`indicator'" != "") {
        order countryname countrycode indicatorname indicatorcode
        lab var indicatorname "Indicator Name"
        lab var indicatorcode "Indicator Code"

        reshape long `l1' , i( `id') j(`l2')
        local name = trim(lower(subinstr(word("`indicator'",1),".","_",.)))

        local number1 = real(substr("`name'",1,1))
        if (`number1' != .) {
            local name "v`name'"
        }

        local length_name = length("`name'")
        if (`length_name' > 20) {
            local name = substr("`name'",1,20)
            return local name "`name'"
            noi di as err ""
            noi di as err "ATTENTION: Original variable name was above 20 characters. WBOPENDATA shorten it to comply with Stata specifications. Variable label preserved."
            noi di as err ""
        }

        rename `l1' `name'
        label var `name' "`indicator'"

        * --- variable-level char metadata (default-on, suppressed by nochar) ---
        if ("`char'" != "nochar") {
            local _ind_code = word("`indicator'",1)
            char `name'[indicator] "`_ind_code'"
        }

        `l3'
        `l4'
        if ("`latest'" != "") {
            keep if `name' != .
            sort countryname countrycode `l2'
            bysort countryname countrycode : keep if _n==_N
        }
        drop  indicatorname indicatorcode
    }

    if ("`long'" != "") & ("`topics'" != "") {

        tempvar dups
        bysort  `id'  indicatorname indicatorcode : gen `dups' = _n
        sum `dups'

        if  (`r(mean)' > 1) {
            noi di as text `""'
            noi di as text `"{p 4 4 2}  WARNING: country/indicator duplicates found in the topic `topics' were eliminated. Please report this isse by {browse "mailto: data@worldbank.org ?subject=wbopendata helpdesk: duplicate indicators in topic (`topics') found at at `c(current_date)' `c(current_time)'" : clicking here}.  {p_end}"'
            noi di as text `""'
            noi di as text `""'
            drop if `dups' == 2
            drop `dups'
        }

        reshape long `l1' , i( `id') j(`l2')
        `l3'
        `l4'
        rename `l1' value
        replace indicatorname = indicatorcode + " " + indicatorname
        encode  indicatorname, gen(indic)
        drop indicatorname  indicatorcode
        _pecats2 indic
        loc cat "`r(catvals)'"
        foreach i in  `cat' {
            local t`i' : label indic `i'
            local k`i' = word("`t`i''", 1)
            local j`i' = trim(subinstr("`t`i''","`k`i''","",.))
            local n`i' = trim(lower(subinstr(word("`t`i''", 1),".","_",.)))
        }
        reshape wide value , i( countryname countrycode `l2') j(  indic)
        foreach i in `cat' {
            rename value`i'  `n`i''
            lab var `n`i'' "`j`i''"
        }
        `l3'
        `l4'
    }

}

    return local time       "`t1'"
    return local _from_cache "`_cache_hit'"

end


*******************************************************************************
* Helper: update data cache manifest (append/replace entry with current date)
*******************************************************************************
program define _wbod_dc_manifest_update
    version 14.0
    args manifest_file cache_entry

    local ts "`c(current_date)'"
    tempfile _tmp_mf

    * Write updated manifest to temp file
    tempname wfh
    file open `wfh' using "`_tmp_mf'", write

    * Copy existing entries (except the one we're replacing)
    if (fileexists("`manifest_file'")) {
        capture {
            tempname rfh
            file open `rfh' using "`manifest_file'", read
            file read `rfh' _line
            while (r(eof) == 0) {
                local _ppos = strpos(`"`_line'"', "|")
                if (`_ppos' > 0) {
                    local _ef = trim(substr(`"`_line'"', 1, `_ppos' - 1))
                }
                else {
                    local _ef `"`_line'"'
                }
                if (`"`_ef'"' != "`cache_entry'") {
                    file write `wfh' `"`_line'"' _n
                }
                file read `rfh' _line
            }
            file close `rfh'
        }
        if (_rc != 0) {
            capture file close `rfh'
        }
    }

    * Append new entry
    file write `wfh' "`cache_entry'|`ts'" _n
    file close `wfh'

    * Replace manifest
    copy "`_tmp_mf'" "`manifest_file'", replace
end


*******************************************************************************
* v 16.0   29Oct2019				by Joao Pedro Azevedo
*	support to HPP population projections
*******************************************************************************
* _query                                                                      *
* v 15.1  	04Mar2019               by Joao Pedro Azevedo                     
*	_countrydata.ado
*	error 21, 22 no longer break if no metadata is found
*	error 23 added to diferentiate from regular error 20: data not found, moved to archive
*******************************************************************************
*  v 14.1  	18Jan2019               by Joao Pedro Azevedo                     
*******************************************************************************
*  v 14  	07/01/2014               by Joao Pedro Azevedo                        *
*		API update version 2
*******************************************************************************
*  v 13.4  01jul2014               by Joao Pedro Azevedo                        *
*       long reshape
*******************************************************************************
*  v 13.3  30june2014               by Joao Pedro Azevedo                        *
*       new error control (clear option)
*******************************************************************************
*  v 13.2  24june2014               by Joao Pedro Azevedo                        *
*       new error control
*******************************************************************************
* v 13.1  23june2014               by Joao Pedro Azevedo                        *
*       regional code, name and iso2code
*******************************************************************************
* v 13  20june2014               by Joao Pedro Azevedo                        *
* 		fix the dups problem                                                    *
*       improve the error messages                                              *
*       update the list of indicators to 9960                                 *
*******************************************************************************
* v 12  03jan2013               by Joao Pedro Azevedo                         *
*   update to 7349 indicators
*   return list include variable name and label
*******************************************************************************
* v 11  24jul2012               by Joao Pedro Azevedo                       *
*   multiple indicators
*******************************************************************************
* v 10  22jan2012               by Joao Pedro Azevedo                       *
*   changes on the dialogue box
*   changes to incorporate API update from December 15th 2011
*   list of indicators updated to 5383
*   incorporates Metadata
*   hyperlinks from metadata are not valid within Stata
*   terms of use of the data are now referenced in the hlp file
*******************************************************************************
* v 9.2  30aug2011               by Joao Pedro Azevedo                       *
*   changes to incorporate API update from July 28th 2011
*******************************************************************************
* v 9.1  07jul2011               by Joao Pedro Azevedo                       *
*   year option on indicators query fixed
*******************************************************************************
* v 9.0  27jun2011               by Joao Pedro Azevedo                       *
*   list of indicators updated 4073
*******************************************************************************
* v 8.0   22fev2011               by Joao Pedro Azevedo                       *
*   new server and query structure for indicators search                        *
*   latest; year(year1:year2) options included                                  *
*******************************************************************************
* v 7.0   08fev2011               by Joao Pedro Azevedo                       *
*   change ado file name                                                        *
*******************************************************************************
* v 6.5   04fev2011               by Joao Pedro Azevedo                      *
*   replace _pecats.ado by _pecats2.ado
*******************************************************************************
* v 6.4   03fev2011               by Joao Pedro Azevedo                      *
*   change error codes
*******************************************************************************
* v 6.3   01fev2011               by Joao Pedro Azevedo                      *
*   region, regioinname, country iso2code now included
*******************************************************************************
* v 6.0   31jan2011               by Joao Pedro Azevedo                      *
*   api server open to the Stata community
*******************************************************************************
* v 5.0   12jan2011                 by Joao Pedro Azevedo                     *
*   change variable name in long format
*******************************************************************************
* v 4.0   20dez2010                 by Joao Pedro Azevedo                     *
*   full list of countries and indicators
*******************************************************************************
* v 3.0   15dez2010                 by Joao Pedro Azevedo                     *
*   rename wdi to wbopendata
*******************************************************************************
* v 2.2   14dez2010                 by Joao Pedro Azevedo                     *
*   dialogue
*******************************************************************************
* v 2.1   10dez2010                 by Joao Pedro Azevedo                     *
*   long option
*******************************************************************************
* v 2.0   09dez2010                 by Joao Pedro Azevedo                     *
*******************************************************************************
* v 1.0   02nov2010                 by Joao Pedro Azevedo                     *
*******************************************************************************
