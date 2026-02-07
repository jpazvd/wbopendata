*******************************************************************************
*! _wbopendata_refresh_yaml v1.0.0  07Feb2026
*  Stata-only YAML refresh (API calls + YAML emit)
*  Author: João Pedro Azevedo (World Bank | UNICEF)
*  Contact: https://jpazvd.github.io
*  License: MIT
*******************************************************************************

program define _wbopendata_refresh_yaml, rclass
	version 9

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
	local out_src "`outdir'_wbopendata_sources.yaml"
	local out_top "`outdir'_wbopendata_topics.yaml"

	* Respect replace option
	if ("`replace'" == "") {
		cap confirm file "`out_ind'"
		if _rc == 0 {
			di as err "YAML file exists: `out_ind' (use replace)"
			exit 602
		}
		cap confirm file "`out_src'"
		if _rc == 0 {
			di as err "YAML file exists: `out_src' (use replace)"
			exit 602
		}
		cap confirm file "`out_top'"
		if _rc == 0 {
			di as err "YAML file exists: `out_top' (use replace)"
			exit 602
		}
	}

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

	file read `src_in' line
	while r(eof) == 0 {
		local line = subinstr(`"`line'"', char(13), " ", .)
		local line = subinstr(`"`line'"', char(10), " ", .)
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
			local src_avail ""
			local src_meta ""
		}
		if (strmatch("`line'", "*<wb:name>*") == 1) {
			local src_name = trim(subinstr("`line'", "<wb:name>", "", .))
			local src_name = subinstr("`src_name'", "</wb:name>", "", .)
			local src_name = subinstr("`src_name'", `"""', "", .)
		}
		if (strmatch("`line'", "*<wb:description>*") == 1) {
			local src_desc = trim(subinstr("`line'", "<wb:description>", "", .))
			local src_desc = subinstr("`src_desc'", "</wb:description>", "", .)
			local src_desc = subinstr("`src_desc'", `"""', "", .)
		}
		if (strmatch("`line'", "*<wb:description */>*") == 1) local src_desc ""
		if (strmatch("`line'", "*<wb:url>*") == 1) {
			local src_url_val = trim(subinstr("`line'", "<wb:url>", "", .))
			local src_url_val = subinstr("`src_url_val'", "</wb:url>", "", .)
			local src_url_val = subinstr("`src_url_val'", `"""', "", .)
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

	file read `top_in' line
	while r(eof) == 0 {
		local line = subinstr(`"`line'"', char(13), " ", .)
		local line = subinstr(`"`line'"', char(10), " ", .)
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
		}
		if (strmatch("`line'", "*<wb:sourceNote>*") == 1) {
			local top_desc = trim(subinstr("`line'", "<wb:sourceNote>", "", .))
			local top_desc = subinstr("`top_desc'", "</wb:sourceNote>", "", .)
			local top_desc = subinstr("`top_desc'", `"""', "", .)
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
	_api_read_indicators, update preserveout file1(`ind_file1') file2(`ind_file2')
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
	insheet using `src_txt', delimiter("#") clear name
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

	insheet using `top_txt', delimiter("#") clear name
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

	* Remove empty indicator rows
	drop if indicatorcode == ""

	*--------------------------------------------------------------------------
	* STEP 4: Write sources YAML
	*--------------------------------------------------------------------------
	use `sources_dta', clear
	gen double src_num = real(sourceid)
	sort src_num

	tempname outsrc
	file open `outsrc' using "`out_src'", write text replace
	file write `outsrc' "# Generated by _wbopendata_refresh_yaml (Stata-only)" _n
	file write `outsrc' "_metadata:" _n
	file write `outsrc' "  version: 2.0.0" _n
	file write `outsrc' "  generated_at: '`c(current_date)' `c(current_time)'" _n
	file write `outsrc' "  total_sources: `=_N'" _n
	file write `outsrc' "sources:" _n

	forvalues i = 1/`=_N' {
		local sid = sourceid[`i']
		local sname = source_name[`i']
		local sdesc = source_desc[`i']
		local surl = source_url[`i']
		local savail = data_availability[`i']
		local smeta = metadata_availability[`i']

		local sname = subinstr("`sname'", char(10), " ", .)
		local sname = subinstr("`sname'", char(13), " ", .)
		local sname = subinstr("`sname'", "'", "''", .)
		local sdesc = subinstr("`sdesc'", char(10), " ", .)
		local sdesc = subinstr("`sdesc'", char(13), " ", .)
		local sdesc = subinstr("`sdesc'", "'", "''", .)
		local surl = subinstr("`surl'", "'", "''", .)

		file write `outsrc' "  '`sid'':" _n
		file write `outsrc' "    code: '`sid'" _n
		file write `outsrc' "    name: '`sname'" _n
		file write `outsrc' "    description: '`sdesc'" _n
		file write `outsrc' "    url: '`surl'" _n
		file write `outsrc' "    data_availability: '`savail'" _n
		file write `outsrc' "    metadata_availability: '`smeta'" _n
	}

	file close `outsrc'

	*--------------------------------------------------------------------------
	* STEP 5: Write topics YAML
	*--------------------------------------------------------------------------
	use `topics_dta', clear
	gen double top_num = real(topicid)
	sort top_num

	tempname outtop
	file open `outtop' using "`out_top'", write text replace
	file write `outtop' "# Generated by _wbopendata_refresh_yaml (Stata-only)" _n
	file write `outtop' "_metadata:" _n
	file write `outtop' "  version: 2.0.0" _n
	file write `outtop' "  generated_at: '`c(current_date)' `c(current_time)'" _n
	file write `outtop' "  total_topics: `=_N'" _n
	file write `outtop' "topics:" _n

	forvalues i = 1/`=_N' {
		local tid = topicid[`i']
		local tname = topic_name[`i']
		local tdesc = topic_desc[`i']

		local tname = subinstr("`tname'", char(10), " ", .)
		local tname = subinstr("`tname'", char(13), " ", .)
		local tname = subinstr("`tname'", "'", "''", .)
		local tdesc = subinstr("`tdesc'", char(10), " ", .)
		local tdesc = subinstr("`tdesc'", char(13), " ", .)
		local tdesc = subinstr("`tdesc'", "'", "''", .)

		file write `outtop' "  '`tid'':" _n
		file write `outtop' "    code: '`tid'" _n
		file write `outtop' "    name: '`tname'" _n
		file write `outtop' "    description: '`tdesc'" _n
	}

	file close `outtop'

	*--------------------------------------------------------------------------
	* STEP 6: Write indicators YAML
	*--------------------------------------------------------------------------
	use `ind_dta', clear
	cap rename sourceID sourceid
	cap rename sourceOrganization sourceorganization
	cap rename sourceNote sourcenote
	cap rename topicID topicid
	merge m:1 sourceid using `sources_dta', keepusing(source_name) nogenerate
	merge m:1 topicid using `topics_dta', keepusing(topic_name) nogenerate

	sort indicatorcode topicid

	tempname outind
	file open `outind' using "`out_ind'", write text replace
	file write `outind' "# Generated by _wbopendata_refresh_yaml (Stata-only)" _n
	file write `outind' "_metadata:" _n
	file write `outind' "  version: 2.0.0" _n
	file write `outind' "  generated_at: '`c(current_date)' `c(current_time)'" _n
	file write `outind' "  source: 'World Bank Open Data API'" _n
	file write `outind' "  total_indicators: `=_N'" _n
	file write `outind' "  compression: none" _n
	file write `outind' "  encoding: UTF-8" _n
	file write `outind' "indicators:" _n

	local i = 1
	local n = _N
	while (`i' <= `n') {
		local code = indicatorcode[`i']
		local name = indicatorname[`i']
		local src_id = sourceid[`i']
		local src_org = sourceorganization[`i']
		local src_name = source_name[`i']
		local desc = sourcenote[`i']

		local name = subinstr("`name'", char(10), " ", .)
		local name = subinstr("`name'", char(13), " ", .)
		local name = subinstr("`name'", "'", "''", .)
		local name = subinstr("`name'", `"""', "", .)
		local src_org = subinstr("`src_org'", char(10), " ", .)
		local src_org = subinstr("`src_org'", char(13), " ", .)
		local src_org = subinstr("`src_org'", "'", "''", .)
		local src_org = subinstr("`src_org'", `"""', "", .)
		local src_name = subinstr("`src_name'", "'", "''", .)
		local src_name = subinstr("`src_name'", `"""', "", .)
		local desc = subinstr("`desc'", char(10), " ", .)
		local desc = subinstr("`desc'", char(13), " ", .)
		local desc = subinstr("`desc'", "'", "''", .)
		local desc = subinstr("`desc'", `"""', "", .)

		local topic_ids ""
		local topic_names ""
		local j = `i'
		while (`j' <= `n' & indicatorcode[`j'] == "`code'" ) {
			local tid = topicid[`j']
			local tname = topic_name[`j']
			if ("`tid'" != "") {
				local topic_ids "`topic_ids' `tid'"
			}
			if ("`tname'" != "") {
				local tname = subinstr("`tname'", "'", "''", .)
				local tname = subinstr("`tname'", `"""', "", .)
				local topic_names `"`topic_names' "`tname'""'
			}
			local j = `j' + 1
		}

		file write `outind' "  `code':" _n
		file write `outind' "    code: '`code'" _n
		file write `outind' "    name: '`name'" _n
		file write `outind' "    source_id: '`src_id'" _n
		file write `outind' "    source_name: '`src_name'" _n
		file write `outind' "    topic_ids:" _n
		if ("`topic_ids'" == "") {
			file write `outind' "      - ''" _n
		}
		else {
			local tids "`topic_ids'"
			while ("`tids'" != "") {
				gettoken tid tids : tids
				file write `outind' "      - '`tid'" _n
			}
		}
		file write `outind' "    topic_names:" _n
		if ("`topic_names'" == "") {
			file write `outind' "      - ''" _n
		}
		else {
			local tnames `"`topic_names'"'
			while (`"`tnames'"' != "") {
				gettoken tname tnames : tnames, bind
				file write `outind' "      - `tname'" _n
			}
		}
		file write `outind' "    description: '`desc'" _n
		file write `outind' "    unit: ''" _n
		file write `outind' "    source_org: '`src_org'" _n
		file write `outind' "    note: ''" _n
		file write `outind' "    limited_data: false" _n

		local i = `j'
	}

	file close `outind'

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
