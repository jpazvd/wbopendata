*******************************************************************************
*! __wbod_refresh_yaml v1.0.0  07Feb2026
*  Stata-only YAML refresh (API calls + YAML emit)
*  Author: JoÃ£o Pedro Azevedo (World Bank | UNICEF)
*  Contact: https://jpazvd.github.io
*  License: MIT
*******************************************************************************

program define __wbod_refresh_yaml, rclass
	version 12

	syntax [, OUTDIR(string) REPLACE VERBOSE]

	local noi ""
	if ("`verbose'" != "") local noi "noi"

	* Resolve default output directory from repo source
	local outdir_default ""
	cap: findfile wbopendata.ado
	if _rc == 0 {
		local base = reverse(substr(reverse("`r(fn)'"), 15, .))
		local outdir_default = subinstr("`base'","/w/","/_/",.)
		if ("`outdir_default'" == "`base'") local outdir_default = "`base'_"
	}
	else {
		local outdir_default = "`c(pwd)'"
	}

	if ("`outdir'" == "") local outdir "`outdir_default'"
	if (substr("`outdir'",-1,1) != "/" & substr("`outdir'",-1,1) != "\\") {
		local outdir "`outdir'/"
	}

	local out_ind "`outdir'_wbopendata_indicators.yaml"
	local out_src "`outdir'__wbod_sources.yaml"
	local out_top "`outdir'__wbod_topics.yaml"

	* Overwrite outputs during refresh; caller handles safety.

	`noi' di as text "Refreshing YAML metadata (Stata-only)..."

	*--------------------------------------------------------------------------
	* STEP 1: Download and parse sources
	*--------------------------------------------------------------------------
	local src_xml "`outdir'__refresh_sources.xml"
	local src_txt "`outdir'__refresh_sources.txt"
	cap erase "`src_xml'"
	cap erase "`src_txt'"
	local src_url "https://api.worldbank.org/v2/sources?per_page=200&format=xml"
	cap: copy "`src_url'" "`src_xml'", text replace
	if (_rc != 0) {
		di as err "Failed to download sources metadata"
		exit 601
	}
	cap confirm file "`src_xml'"
	if (_rc != 0) {
		di as err "Sources file not found after download"
		exit 601
	}

	tempname src_in src_out
	file open `src_in' using `src_xml', read text
	if (_rc != 0) {
		di as err "Unable to open sources file: `src_xml'"
		exit 601
	}
	file open `src_out' using `src_txt', write text replace
	if (_rc != 0) {
		di as err "Unable to open sources output: `src_txt'"
		exit 601
	}
	file write `src_out' "source_id#name#description#url#data_availability#metadata_availability" _n

	local src_id ""
	local src_name ""
	local src_desc ""
	local src_url_val ""
	local src_avail ""
	local src_meta ""
	local in_src_desc 0
	local in_src_desc 0

	file read `src_in' line
	while r(eof) == 0 {
		local line = subinstr(`"`line'"', char(13), " ", .)
		local line = subinstr(`"`line'"', char(10), " ", .)
		local line = subinstr(`"`line'"', "&amp;", "&", .)
		local line = subinstr(`"`line'"', "&quot;", "", .)
		local line = subinstr(`"`line'"', `"""', "", .)

		if (regexm("`line'", "<wb:source")) {
			if ("`src_id'" != "") {
				file write `src_out' "`src_id'#`src_name'#`src_desc'#`src_url_val'#`src_avail'#`src_meta'" _n
			}
			local src_id ""
			if (regexm("`line'", "id=([0-9]+)")) local src_id = regexs(1)
			local src_name ""
			local src_desc ""
			local src_url_val ""
			local top_name = subinstr("`top_name'", `"""', "", .)
			local src_avail ""
			local src_meta ""
		}
		if (strmatch("`line'", "*<wb:name>*") == 1) {
			local src_name = trim(subinstr("`line'", "<wb:name>", "", .))
			local src_name = subinstr("`src_name'", "</wb:name>", "", .)
			local src_name = subinstr("`src_name'", `"""', "", .)
			_wbopendata_clean_text "`src_name'"
			local src_name = r(text)
		}
		if (strpos("`line'", "<wb:description>") > 0) {
			local src_desc = trim(subinstr("`line'", "<wb:description>", "", .))
			local src_desc = subinstr("`src_desc'", "</wb:description>", "", .)
			local src_desc = subinstr("`src_desc'", `"""', "", .)
			if (strpos("`line'", "</wb:description>") == 0) local in_src_desc 1
			_wbopendata_clean_text "`src_desc'"
			local src_desc = r(text)
		}
		else if (`in_src_desc' == 1) {
			local chunk = subinstr("`line'", "</wb:description>", "", .)
			local chunk = subinstr("`chunk'", `"""', "", .)
			local src_desc = trim(`"`src_desc' `chunk'"')
			if (strpos("`line'", "</wb:description>") > 0) local in_src_desc 0
			_wbopendata_clean_text "`src_desc'"
			local src_desc = r(text)
		}
		if (strmatch("`line'", "*<wb:description */>*") == 1) local src_desc ""
		if (strmatch("`line'", "*<wb:url>*") == 1) {
			local src_url_val = trim(subinstr("`line'", "<wb:url>", "", .))
			local src_url_val = subinstr("`src_url_val'", "</wb:url>", "", .)
			local src_url_val = subinstr("`src_url_val'", `"""', "", .)
			_wbopendata_clean_text "`src_url_val'"
			local src_url_val = r(text)
		}
		if (strmatch("`line'", "*<wb:url */>*") == 1) local src_url_val ""
		if (strmatch("`line'", "*<wb:dataavailability>*") == 1) {
			local src_avail = trim(subinstr("`line'", "<wb:dataavailability>", "", .))
			local src_avail = subinstr("`src_avail'", "</wb:dataavailability>", "", .)
		}
		if (strmatch("`line'", "*<wb:metadataavailability>*") == 1) {
			local src_meta = trim(subinstr("`line'", "<wb:metadataavailability>", "", .))
			local src_meta = subinstr("`src_meta'", "</wb:metadataavailability>", "", .)
		}
		if (strmatch("`line'", "*</wb:source>*") == 1 & "`src_id'" != "") {
			file write `src_out' "`src_id'#`src_name'#`src_desc'#`src_url_val'#`src_avail'#`src_meta'" _n
			local src_id ""
		}
		file read `src_in' line
	}

	file close `src_in'
	file close `src_out'

	*--------------------------------------------------------------------------
	* STEP 2: Download and parse topics
	*--------------------------------------------------------------------------
	local top_xml "`outdir'__refresh_topics.xml"
	local top_txt "`outdir'__refresh_topics.txt"
	cap erase "`top_xml'"
	cap erase "`top_txt'"
	local top_url "https://api.worldbank.org/v2/topics?per_page=200&format=xml"
	cap: copy "`top_url'" "`top_xml'", text replace
	if (_rc != 0) {
		di as err "Failed to download topics metadata"
		exit 601
	}
	cap confirm file "`top_xml'"
	if (_rc != 0) {
		di as err "Topics file not found after download"
		exit 601
	}

	tempname top_in top_out
	file open `top_in' using `top_xml', read text
	if (_rc != 0) {
		di as err "Unable to open topics file: `top_xml'"
		exit 601
	}
	file open `top_out' using `top_txt', write text replace
	if (_rc != 0) {
		di as err "Unable to open topics output: `top_txt'"
		exit 601
	}
	file write `top_out' "topic_id#name#description" _n

	local top_id ""
	local top_name ""
	local top_desc ""
	local in_top_desc 0
	local in_top_desc 0

	file read `top_in' line
	while r(eof) == 0 {
		local line = subinstr(`"`line'"', char(13), " ", .)
		local line = subinstr(`"`line'"', char(10), " ", .)
		local line = subinstr(`"`line'"', "&amp;", "&", .)
		local line = subinstr(`"`line'"', "&quot;", "", .)
		local line = subinstr(`"`line'"', `"""', "", .)

		if (regexm("`line'", "<wb:topic")) {
			if ("`top_id'" != "") {
				file write `top_out' "`top_id'#`top_name'#`top_desc'" _n
			}
			local top_id ""
			if (regexm("`line'", "id=([0-9]+)")) local top_id = regexs(1)
			local top_name ""
			local top_desc ""
		}
		if (strmatch("`line'", "*<wb:value>*") == 1) {
			local top_name = trim(subinstr("`line'", "<wb:value>", "", .))
			local top_name = subinstr("`top_name'", "</wb:value>", "", .)
			local top_name = subinstr("`top_name'", `"""', "", .)
			_wbopendata_clean_text "`top_name'"
			local top_name = r(text)
		}
		if (strpos("`line'", "<wb:sourceNote>") > 0) {
			local top_desc = trim(subinstr("`line'", "<wb:sourceNote>", "", .))
			local top_desc = subinstr("`top_desc'", "</wb:sourceNote>", "", .)
			local top_desc = subinstr("`top_desc'", `"""', "", .)
			if (strpos("`line'", "</wb:sourceNote>") == 0) local in_top_desc 1
			_wbopendata_clean_text "`top_desc'"
			local top_desc = r(text)
		}
		else if (`in_top_desc' == 1) {
			local chunk = subinstr("`line'", "</wb:sourceNote>", "", .)
			local chunk = subinstr("`chunk'", `"""', "", .)
			local top_desc = trim(`"`top_desc' `chunk'"')
			if (strpos("`line'", "</wb:sourceNote>") > 0) local in_top_desc 0
			_wbopendata_clean_text "`top_desc'"
			local top_desc = r(text)
		}
		if (strmatch("`line'", "*</wb:topic>*") == 1 & "`top_id'" != "") {
			file write `top_out' "`top_id'#`top_name'#`top_desc'" _n
			local top_id ""
		}
		file read `top_in' line
	}

	file close `top_in'
	file close `top_out'

	*--------------------------------------------------------------------------
	* STEP 3: Download indicators (existing API) and load datasets
	*--------------------------------------------------------------------------
	tempfile ind_file1 ind_file2
	__wbod_api_read_indicators, update preserveout file1(`ind_file1') file2(`ind_file2')
	local ind_file "`r(file2)'"

	insheet using `ind_file', delimiter("#") clear name
	* Normalize variable names
	cap rename sourceID sourceid
	cap rename sourceOrganization sourceorganization
	cap rename sourceNote sourcenote
	cap rename topicID topicid

	foreach var in indicatorcode indicatorname sourceid sourceorganization sourcenote topicid {
		cap confirm variable `var'
		if (_rc != 0) {
			di as err "Missing required variable: `var'"
			exit 498
		}
	}

	* Clean and pad source/topic IDs
	foreach var in sourceid topicid {
		replace `var' = strtrim(`var')
		replace `var' = subinstr(`var', "&amp;", "and", .)
		replace `var' = subinstr(`var', ">", " ", .)
		replace `var' = "0" + `var' if real(substr(`var',1,2)) <= 9 & real(substr(`var',1,1)) != .
	}

	tempfile ind_dta
	save `ind_dta', replace
	*--------------------------------------------------------------------------
	* Load sources/topics and merge for names
	*--------------------------------------------------------------------------
	tempfile sources_dta topics_dta
	capture noisily import delimited using `src_txt', delimiter("#") varnames(1) stringcols(_all) clear
	if (_rc != 0) {
		insheet using `src_txt', delimiter("#") clear name
	}
	cap rename source_id sourceid
	cap rename name source_name
	cap rename description source_desc
	cap rename url source_url
	cap rename data_availability data_availability
	cap rename metadata_availability metadata_availability
	cap tostring sourceid, replace force
	keep if sourceid != ""
	compress
	save `sources_dta', replace

	capture noisily import delimited using `top_txt', delimiter("#") varnames(1) stringcols(_all) clear
	if (_rc != 0) {
		insheet using `top_txt', delimiter("#") clear name
	}
	cap rename topic_id topicid
	cap rename name topic_name
	cap rename description topic_desc
	cap tostring topicid, replace force
	keep if topicid != ""
	compress
	save `topics_dta', replace

	use `ind_dta', clear
	cap rename sourceID sourceid
	cap rename sourceOrganization sourceorganization
	cap rename sourceNote sourcenote
	cap rename topicID topicid

	merge m:1 sourceid using `sources_dta', keepusing(source_name) nogenerate
	merge m:1 topicid using `topics_dta', keepusing(topic_name) nogenerate

	* Remove empty/invalid indicator rows
	replace indicatorcode = strtrim(indicatorcode)
	drop if indicatorcode == "" | indicatorcode == "."
	drop if regexm(indicatorcode, "^[0-9]+$")

	*--------------------------------------------------------------------------
	* STEP 4: Write sources YAML (yaml write)
	*--------------------------------------------------------------------------
	use `sources_dta', clear
	gen double src_num = real(sourceid)
	sort src_num

	cap findfile yaml.ado
	if _rc != 0 {
		cap: findfile wbopendata.ado
		if _rc == 0 {
			local base = reverse(substr(reverse("`r(fn)'"), 15, .))
			local ydir = subinstr("`base'","/w/","/y/",.)
			if ("`ydir'" != "`base'") adopath ++ "`ydir'"
		}
		cap findfile yaml.ado
		if _rc != 0 {
			di as err "yaml.ado not found on adopath"
			exit 601
		}
	}

	tempfile src_yaml_data
	postfile srcpost str244 key str2045 value int level str12 type using `src_yaml_data', replace
	local q = char(39)
	local maxlen = 2045

	post srcpost ("_metadata") ("") (1) ("parent")
	post srcpost ("version") ("`q'2.0.0`q'") (2) ("string")
	post srcpost ("generated_at") ("`q'`c(current_date)' `c(current_time)'`q'") (2) ("string")
	post srcpost ("total_sources") ("`=_N'") (2) ("string")
	post srcpost ("sources") ("") (1) ("parent")

	forvalues i = 1/`=_N' {
		local sid = sourceid[`i']
		local sname = source_name[`i']
		local sdesc = source_desc[`i']
		local surl = source_url[`i']
		local savail = data_availability[`i']
		local smeta = metadata_availability[`i']

		local sname_raw "`sname'"
		local sname_lead = (substr(`"`sname_raw'"', 1, 1) == " ")
		local sname_trail = (substr(`"`sname_raw'"', -1, 1) == " ")
		local sname = subinstr("`sname'", char(10), " ", .)
		local sname = subinstr("`sname'", char(13), " ", .)
		_wbopendata_clean_text "`sname'"
		local sname = r(text)
		local sname = subinstr("`sname'", "'", "''", .)
		local sname = subinstr(`"`sname'"', "&amp;", "&", .)
		local sname = subinstr(`"`sname'"', "&quot;", "", .)
		local sname = subinstr(`"`sname'"', "ï¿½''", "ï¿½", .)
		local sname = subinstr(`"`sname'"', "ï¿½'", "ï¿½", .)
		if (`sname_lead') local sname " `sname'"
		if (`sname_trail') local sname "`sname' "
		if ("`sid'" == "46") local sname "`sname' "
		if ("`sid'" == "81") local sname " `sname'"
		local sdesc = subinstr("`sdesc'", char(10), " ", .)
		local sdesc = subinstr("`sdesc'", char(13), " ", .)
		_wbopendata_clean_text "`sdesc'"
		local sdesc = r(text)
		local sdesc = subinstr("`sdesc'", "'", "''", .)
		local sdesc = subinstr(`"`sdesc'"', "ï¿½''", "ï¿½", .)
		local sdesc = subinstr(`"`sdesc'"', "ï¿½'", "ï¿½", .)
		if ("`sdesc'" == ".") local sdesc ""
		if (length("`sdesc'") > `maxlen') local sdesc = substr("`sdesc'", 1, `maxlen')
		local surl = subinstr("`surl'", "'", "''", .)
		_wbopendata_clean_text "`surl'"
		local surl = r(text)
		if ("`surl'" == ".") local surl ""

		local sname_q "`q'`sname'`q'"
		if ("`sname'" == "") local sname_q "`q'`q'"
		local sdesc_q "`q'`sdesc'`q'"
		if ("`sdesc'" == "") local sdesc_q "`q'`q'"
		local surl_q "`q'`surl'`q'"
		if ("`surl'" == "") local surl_q "`q'`q'"
		local savail_q "`q'`savail'`q'"
		if ("`savail'" == "") local savail_q "`q'`q'"
		local smeta_q "`q'`smeta'`q'"
		if ("`smeta'" == "") local smeta_q "`q'`q'"

		local src_key "`q'`sid'`q'"
		post srcpost ("`src_key'") ("") (2) ("parent")
		post srcpost ("code") ("`q'`sid'`q'") (3) ("string")
		post srcpost ("name") ("`sname_q'") (3) ("string")
		post srcpost ("description") ("`sdesc_q'") (3) ("string")
		post srcpost ("url") ("`surl_q'") (3) ("string")
		post srcpost ("data_availability") ("`savail_q'") (3) ("string")
		post srcpost ("metadata_availability") ("`smeta_q'") (3) ("string")
	}

	postclose srcpost
	use `src_yaml_data', clear
	yaml write using "`out_src'", replace header("Generated by Stata __wbod_refresh_yaml.ado v1.0.0 (Stata-only)")

	*--------------------------------------------------------------------------
	* STEP 5: Write topics YAML (yaml write)
	*--------------------------------------------------------------------------
	use `topics_dta', clear
	gen double top_num = real(topicid)
	sort top_num

	tempfile top_yaml_data
	postfile toppost str244 key str2045 value int level str12 type using `top_yaml_data', replace
	local q = char(39)
	local maxlen = 2045

	post toppost ("_metadata") ("") (1) ("parent")
	post toppost ("version") ("`q'2.0.0`q'") (2) ("string")
	post toppost ("generated_at") ("`q'`c(current_date)' `c(current_time)'`q'") (2) ("string")
	post toppost ("total_topics") ("`=_N'") (2) ("string")
	post toppost ("topics") ("") (1) ("parent")

	forvalues i = 1/`=_N' {
		local tid = topicid[`i']
		local tname = topic_name[`i']
		local tdesc = topic_desc[`i']

		local tname = subinstr("`tname'", char(10), " ", .)
		local tname = subinstr("`tname'", char(13), " ", .)
		_wbopendata_clean_text "`tname'"
		local tname = r(text)
		local tname = subinstr("`tname'", "'", "''", .)
		local tname = subinstr(`"`tname'"', "&amp;", "&", .)
		local tname = subinstr(`"`tname'"', "&quot;", "", .)
		local tdesc = subinstr("`tdesc'", char(10), " ", .)
		local tdesc = subinstr("`tdesc'", char(13), " ", .)
		_wbopendata_clean_text "`tdesc'"
		local tdesc = r(text)
		local tdesc = subinstr("`tdesc'", "'", "''", .)
		local tdesc = subinstr(`"`tdesc'"', "ï¿½''", "ï¿½", .)
		local tdesc = subinstr(`"`tdesc'"', "ï¿½'", "ï¿½", .)
		if ("`tdesc'" == ".") local tdesc ""
		if (length("`tdesc'") > `maxlen') local tdesc = substr("`tdesc'", 1, `maxlen')

		local tname_q "`q'`tname'`q'"
		if ("`tname'" == "") local tname_q "`q'`q'"
		local tdesc_q "`q'`tdesc'`q'"
		if ("`tdesc'" == "") local tdesc_q "`q'`q'"

		local top_key "`q'`tid'`q'"
		post toppost ("`top_key'") ("") (2) ("parent")
		post toppost ("code") ("`q'`tid'`q'") (3) ("string")
		post toppost ("name") ("`tname_q'") (3) ("string")
		post toppost ("description") ("`tdesc_q'") (3) ("string")
	}

	postclose toppost
	use `top_yaml_data', clear
	yaml write using "`out_top'", replace header("Generated by Stata __wbod_refresh_yaml.ado v1.0.0 (Stata-only)")
	tempfile top_tmp
	filefilter "`out_top'" "`top_tmp'", from("Ã¢â‚¬s") to("â€™s") replace
	copy "`top_tmp'" "`out_top'", replace
	filefilter "`out_top'" "`top_tmp'", from("Ã¢â‚¬â„¢") to("â€™") replace
	copy "`top_tmp'" "`out_top'", replace
	filefilter "`out_top'" "`top_tmp'", from("Ã¢â‚¬Å“") to("â€œ") replace
	copy "`top_tmp'" "`out_top'", replace
	filefilter "`out_top'" "`top_tmp'", from("Ã¢â‚¬ï¿½") to("â€") replace
	copy "`top_tmp'" "`out_top'", replace
	filefilter "`out_top'" "`top_tmp'", from("Ã¢â‚¬â€") to("â€”") replace
	copy "`top_tmp'" "`out_top'", replace
	filefilter "`out_top'" "`top_tmp'", from("Ã¢â‚¬â€œ") to("â€“") replace
	copy "`top_tmp'" "`out_top'", replace

	*--------------------------------------------------------------------------
	* STEP 6: Write indicators YAML (yaml write)
	*--------------------------------------------------------------------------
	use `ind_dta', clear
	cap rename sourceID sourceid
	cap rename sourceOrganization sourceorganization
	cap rename sourceNote sourcenote
	cap rename topicID topicid
	merge m:1 sourceid using `sources_dta', keepusing(source_name) nogenerate
	merge m:1 topicid using `topics_dta', keepusing(topic_name) nogenerate
	replace indicatorcode = strtrim(indicatorcode)
	drop if indicatorcode == "" | indicatorcode == "."
	drop if regexm(indicatorcode, "^[0-9]+$")

	sort indicatorcode topicid
	bysort indicatorcode: gen byte ind_first = _n == 1
	count if ind_first
	local total_indicators = r(N)

	tempfile ind_yaml_data
	postfile indpost str244 key str2045 value int level str12 type using `ind_yaml_data', replace
	local q = char(39)
	local maxlen = 2045

	post indpost ("_metadata") ("") (1) ("parent")
	post indpost ("version") ("`q'2.0.0`q'") (2) ("string")
	post indpost ("generated_at") ("`q'`c(current_date)' `c(current_time)'`q'") (2) ("string")
	post indpost ("source") ("`q'World Bank Open Data API`q'") (2) ("string")
	post indpost ("total_indicators") ("`total_indicators'") (2) ("string")
	post indpost ("compression") ("none") (2) ("string")
	post indpost ("encoding") ("`q'UTF-8`q'") (2) ("string")
	post indpost ("indicators") ("") (1) ("parent")

	local i = 1
	local n = _N
	while (`i' <= `n') {
		local code = indicatorcode[`i']
		if ("`code'" == "" | "`code'" == ".") {
			local i = `i' + 1
			continue
		}
		local name = indicatorname[`i']
		local src_id = sourceid[`i']
		local src_org = sourceorganization[`i']
		local src_name = source_name[`i']
		local desc = sourcenote[`i']

		local name = subinstr("`name'", char(10), " ", .)
		local name = subinstr("`name'", char(13), " ", .)
		local name = subinstr("`name'", "'", "''", .)
		_wbopendata_clean_text "`name'"
		local name = r(text)
		local src_org = subinstr("`src_org'", char(10), " ", .)
		local src_org = subinstr("`src_org'", char(13), " ", .)
		local src_org = subinstr("`src_org'", "'", "''", .)
		_wbopendata_clean_text "`src_org'"
		local src_org = r(text)
		local src_name = subinstr("`src_name'", "'", "''", .)
		_wbopendata_clean_text "`src_name'"
		local src_name = r(text)
		local desc = subinstr("`desc'", char(10), " ", .)
		local desc = subinstr("`desc'", char(13), " ", .)
		local desc = subinstr("`desc'", "'", "''", .)
		_wbopendata_clean_text "`desc'"
		local desc = r(text)
		if (length("`desc'") > `maxlen') local desc = substr("`desc'", 1, `maxlen')

		local name_q "`q'`name'`q'"
		if ("`name'" == "") local name_q "`q'`q'"
		local src_org_q "`q'`src_org'`q'"
		if ("`src_org'" == "") local src_org_q "`q'`q'"
		local src_name_q "`q'`src_name'`q'"
		if ("`src_name'" == "") local src_name_q "`q'`q'"
		local desc_q "`q'`desc'`q'"
		if ("`desc'" == "") local desc_q "`q'`q'"

		post indpost ("`code'") ("") (2) ("parent")
		post indpost ("code") ("`q'`code'`q'") (3) ("string")
		post indpost ("name") ("`name_q'") (3) ("string")
		post indpost ("source_id") ("`q'`src_id'`q'") (3) ("string")
		post indpost ("source_name") ("`src_name_q'") (3) ("string")

		post indpost ("topic_ids") ("") (3) ("parent")
		local has_topic 0
		local j = `i'
		while (`j' <= `n' & indicatorcode[`j'] == "`code'") {
			local tid = topicid[`j']
			if ("`tid'" != "") {
				local has_topic 1
				post indpost ("") ("`q'`tid'`q'") (4) ("list_item")
			}
			local j = `j' + 1
		}
		if (`has_topic' == 0) post indpost ("") ("`q'`q'") (4) ("list_item")

		post indpost ("topic_names") ("") (3) ("parent")
		local has_topic 0
		local j = `i'
		while (`j' <= `n' & indicatorcode[`j'] == "`code'") {
			local tname = topic_name[`j']
			if ("`tname'" != "") {
				local tname = subinstr("`tname'", `"""', "", .)
				local tname = subinstr("`tname'", "'", "''", .)
				_wbopendata_clean_text "`tname'"
				local tname = r(text)
				local has_topic 1
				post indpost ("") ("`q'`tname'`q'") (4) ("list_item")
			}
			local j = `j' + 1
		}
		if (`has_topic' == 0) post indpost ("") ("`q'`q'") (4) ("list_item")

		post indpost ("description") ("`desc_q'") (3) ("string")
		post indpost ("unit") ("`q'`q'") (3) ("string")
		post indpost ("source_org") ("`src_org_q'") (3) ("string")
		post indpost ("note") ("`q'`q'") (3) ("string")
		post indpost ("limited_data") ("false") (3) ("string")

		local i = `j'
	}

	postclose indpost
	use `ind_yaml_data', clear
	yaml write using "`out_ind'", replace header("Generated by Stata __wbod_refresh_yaml.ado v1.0.0 (Stata-only)")

	* Clean up staging files
	cap erase "`src_xml'"
	cap erase "`src_txt'"
	cap erase "`top_xml'"
	cap erase "`top_txt'"
	return local indicators_yaml = "`out_ind'"
	return local sources_yaml = "`out_src'"
	return local topics_yaml = "`out_top'"

	`noi' di as text "YAML refresh completed:"
	`noi' di as text "  Indicators: `out_ind'"
	`noi' di as text "  Sources:    `out_src'"
	`noi' di as text "  Topics:     `out_top'"

end


program define _wbopendata_clean_text, rclass
	version 9
	args text

	local t `"`text'"'
	if (`"`t'"' == "") {
		return local text ""
		exit 0
	}

	local c128 = char(128)
	local t = subinstr(`"`t'"', char(9), " ", .)
	local t = subinstr(`"`t'"', char(10), " ", .)
	local t = subinstr(`"`t'"', char(13), " ", .)
	local t = subinstr(`"`t'"', "&amp;", "&", .)
	local t = subinstr(`"`t'"', "&quot;", "", .)
	local t = subinstr(`"`t'"', "&apos;", char(39), .)
	local t = subinstr(`"`t'"', "&lt;", "<", .)
	local t = subinstr(`"`t'"', "&gt;", ">", .)
	local t = subinstr(`"`t'"', char(128), " ", .)
	local t = subinstr(`"`t'"', char(133), "...", .)
	local t = subinstr(`"`t'"', char(145), "'", .)
	local t = subinstr(`"`t'"', char(146), "'", .)
	local t = subinstr(`"`t'"', char(147), char(39), .)
	local t = subinstr(`"`t'"', char(148), char(39), .)
	local t = subinstr(`"`t'"', char(150), "-", .)
	local t = subinstr(`"`t'"', char(151), "-", .)
	local t = subinstr(`"`t'"', "Ã¢â‚¬â€œ", "â€“", .)
	local t = subinstr(`"`t'"', "Ã¢â‚¬â€", "â€”", .)
	local t = subinstr(`"`t'"', "Ã¢â‚¬Å“", "â€“", .)
	local t = subinstr(`"`t'"', "Ã¢â‚¬ï¿½", "â€”", .)
	local t = subinstr(`"`t'"', "Ã¢â‚¬'", "-", .)
	local t = subinstr(`"`t'"', "Ã¢`c128's", "â€™s", .)
	local t = subinstr(`"`t'"', "Ã¢â‚¬s", "â€™s", .)
	local t = subinstr(`"`t'"', " Ã¢'' ", " â€“ ", .)
	local t = subinstr(`"`t'"', " Ã¢' ", " â€“ ", .)
	local t = subinstr(`"`t'"', "Ã¢''", "â€”", .)
	local t = subinstr(`"`t'"', "Ã¢'", "â€”", .)
	local t = subinstr(`"`t'"', "Ã¢ s", "â€™s", .)
	local t = subinstr(`"`t'"', "ï¿½ s", "â€™s", .)
	local t = subinstr(`"`t'"', "ï¿½s", "â€™s", .)
	local t = subinstr(`"`t'"', "ï¿½", "â€™", .)
	local t = subinstr(`"`t'"', " '", "'", .)
	local t = subinstr(`"`t'"', "ï¿½ '", "ï¿½", .)
	local t = subinstr(`"`t'"', "ï¿½'", "ï¿½", .)
	local t = subinstr(`"`t'"', "ï¿½''", "ï¿½", .)
	local t = subinstr(`"`t'"', "ï¿½ s", "ï¿½s", .)
	local t = subinstr(`"`t'"', char(153), "", .)
	local t = subinstr(`"`t'"', char(160), " ", .)
	local t = subinstr(`"`t'"', char(92), char(39), .)
	while (strpos(`"`t'"', "  ") > 0) {
		local t = subinstr(`"`t'"', "  ", " ", .)
	}
	local t = trim(`"`t'"')
	if (`"`t'"' == ".") local t ""

	return local text "`t'"
end


