*******************************************************************************
*! v 16.7  	 22Dec2024        	   by Joao Pedro Azevedo                      *  
*		add sourcecite return for clean graph source attribution
*******************************************************************************
*! v 16.6  	 22Dec2024        	   by Joao Pedro Azevedo                      *  
*		support multiple maxlength values for different fields
*******************************************************************************
*! v 16.5  	 22Dec2024        	   by Joao Pedro Azevedo                      *  
*		implement linewrap() option for graph-ready text wrapping
*******************************************************************************
*! v 16.4  	 22Dec2024        	   by Joao Pedro Azevedo                      *  
*		add linewrap() option for graph-ready text
*******************************************************************************
*! v 16.3  	 8Jul2020        	   by Joao Pedro Azevedo                      *  
*		change API end point to HTTPS
*******************************************************************************

program def _query_metadata, rclass

version 9.0

    syntax , INDICATOR(string) [LINEWrap(string) MAXLength(string) LINEWRAPFormat(string)]
	
	* linewrap() accepts: name description note source topic all
	* maxlength() specifies character width(s) for wrapping
	*   - Single value (e.g., maxlength(50)): applies to all fields
	*   - Multiple values (e.g., maxlength(40 100 80)): applies in order to linewrap fields
	*   - Default: 50
	* linewrapformat() accepts: stack (default) | all | lines | newline
	*   stack = only return _stack format ("line1" "line2") for title()
	*   all = return all formats (_stack, _newline, _nlines, _line1, etc.)

    quietly {

	*---------------------------------------------------------------------------
	** parepare indicator name
	
        if ("`indicator'" != "") {
            local indicator1 = word("`indicator'",1)
            local indicator2 = subinstr("`indicator'","`indicator1'","",.)
            local indicator2 = trim(subinstr("`indicator2'","-","",.))
            if ("`indicator2'" == "") {
                local indicator2 "`indicator1'"
            }
        }

	*---------------------------------------------------------------------------
	** pull metadata using _api_read.ado 		
	_api_read, list query("https://api.worldbank.org/v2/indicators/`indicator'") ///
		parameter( indicator?id name topic?id source?id sourceNote sourceOrganization)
		
	*---------------------------------------------------------------------------
	*** prepare outputs from API for display
	*noi return list
	local collection =  r(source_id5) 
	local source 	= r(sourceNote6)
	local note   	= r(sourceOrganization7)
	local name 		= r(name3)
	local indicator = r(indicator_id2)
	local topic1 	= r(topic_id9)
	local topic2 	= r(topic_id10)
	local topic3 	= r(topic_id11)

	*---------------------------------------------------------------------------
    ** clean output
	*** clean topic 1
	if ("`topic1'" != ".") {
	    local topic1 "`topic1'"
	}
	else {
		local topic1 ""
		local sc     ";"
	}
		
	*** clean topic 2
	if ("`topic2'" != ".") {
		local sc     ";"
	    local topic2 "`sc' `topic2'"
	}
	else {
		local topic2 ""
		local sc     ";"
	}
		
	*** clean topic 3
	if ("`topic3'" != ".") {
		local sc     ";"
		local topic3 "`sc' `topic3'"
	}
	else {
		local topic3 ""
	}
		
	* Initialize URL collection
	local nurls = 0
	
	cap qui _website, text(`"`source'"')
	if (_rc == 0) {
		local source = r(text)
		* Collect URLs from source/description
		if (r(nurls) > 0) {
			forvalues u = 1/`=r(nurls)' {
				local nurls = `nurls' + 1
				local url`nurls' "`r(url`u')'"
			}
		}
	}
	cap qui _website, text(`"`note'"')
	if (_rc == 0) {
		local note = r(text)
		* Collect URLs from note (with deduplication against existing URLs)
		if (r(nurls) > 0) {
			forvalues u = 1/`=r(nurls)' {
				local thisurl "`r(url`u')'"
				local isdupe = 0
				* Check against already collected URLs
				if (`nurls' > 0) {
					forvalues v = 1/`nurls' {
						if ("`url`v''" == "`thisurl'") {
							local isdupe = 1
							continue, break
						}
					}
				}
				* Only add if not duplicate
				if (`isdupe' == 0) {
					local nurls = `nurls' + 1
					local url`nurls' "`thisurl'"
				}
			}
		}
	}
	
	*---------------------------------------------------------------------------
	*** Extract clean source citation for graph attribution
	* The note field typically contains: "Organization Name, details..." or "Organization Name (abbrev), ..."
	* We extract just the organization name (up to first comma, semicolon, or opening paren with abbrev)
	local sourcecite ""
	if (`"`note'"' != "" & `"`note'"' != ".") {
		local sourcecite `"`note'"'
		* Find position of first delimiter (comma, semicolon, or " uri:")
		local pos_comma = strpos(`"`sourcecite'"', ",")
		local pos_semi = strpos(`"`sourcecite'"', ";")
		local pos_uri = strpos(`"`sourcecite'"', " uri:")
		local pos_note = strpos(`"`sourcecite'"', " note:")
		
		* Find the earliest delimiter
		local cutpos = 0
		foreach p in pos_comma pos_semi pos_uri pos_note {
			if (``p'' > 0) {
				if (`cutpos' == 0 | ``p'' < `cutpos') {
					local cutpos = ``p''
				}
			}
		}
		
		* Extract up to the delimiter, or take first 80 chars if no delimiter found
		if (`cutpos' > 1) {
			local sourcecite = substr(`"`sourcecite'"', 1, `cutpos' - 1)
		}
		else if (strlen(`"`sourcecite'"') > 80) {
			local sourcecite = substr(`"`sourcecite'"', 1, 80)
		}
		* Trim whitespace
		local sourcecite = trim(`"`sourcecite'"')
	}

	*---------------------------------------------------------------------------
	*** Display results
	noi di ""
	noi di as result "{p 4 4 4}{opt Metadata for indicator} `indicator'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Name}: `name'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Collection}: `collection'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  `"{p 4 4 4}{opt Description}: `source'{p_end}"'
	noi di in smcl  "{hline}"
	noi di in smcl  `"{p 4 4 4}{opt Note}: `note'{p_end}"'

    *noi _website, text(`"`note'"')  short(link)
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Topic(s)}: `topic1' `topic2' `topic3'{p_end}"
	noi di in smcl  "{hline}"
	
	noi di ""
	noi di ""
	
	*---------------------------------------------------------------------------
	*** Linewrap processing for graph-ready text
	if ("`linewrap'" != "") {
		* Parse linewrap option - accepts: name description note source topic all
		local wrap_name = 0
		local wrap_description = 0
		local wrap_note = 0
		local wrap_source = 0
		local wrap_topic = 0
		
		* Build ordered list of fields to wrap (for maxlength matching)
		local wrap_fields ""
		local wrap_count = 0
		
		* Check for "all" or specific fields
		if (strpos(lower("`linewrap'"), "all") > 0) {
			local wrap_name = 1
			local wrap_description = 1
			local wrap_note = 1
			local wrap_source = 1
			local wrap_topic = 1
			local wrap_fields "name description note source topic"
			local wrap_count = 5
		}
		else {
			* Parse in order they appear in linewrap()
			foreach fld in name description note source topic {
				if (strpos(lower("`linewrap'"), "`fld'") > 0) {
					local wrap_`fld' = 1
					local wrap_fields "`wrap_fields' `fld'"
					local wrap_count = `wrap_count' + 1
				}
			}
			local wrap_fields = trim("`wrap_fields'")
		}
		
		* Parse maxlength values (can be single or multiple)
		* Default to 50 if not specified
		if ("`maxlength'" == "") local maxlength "50"
		local maxlen_count : word count `maxlength'
		
		* Assign maxlength to each field
		local fld_idx = 0
		foreach fld in `wrap_fields' {
			local fld_idx = `fld_idx' + 1
			if (`fld_idx' <= `maxlen_count') {
				local maxlen_`fld' = word("`maxlength'", `fld_idx')
			}
			else {
				* Use last specified value for remaining fields
				local maxlen_`fld' = word("`maxlength'", `maxlen_count')
			}
		}
		
		* Default linewrapformat to "stack" if not specified
		if ("`linewrapformat'" == "") local linewrapformat "stack"
		local lwf_all = (strpos(lower("`linewrapformat'"), "all") > 0)
		
		* Wrap name
		if (`wrap_name' == 1) {
			local ml = cond("`maxlen_name'" != "", `maxlen_name', 50)
			cap _metadata_linewrap, text(`"`name'"') maxlength(`ml') prefix(name)
			if (_rc == 0) {
				return local name_stack `"`r(name_stack)'"'
				if (`lwf_all' == 1) {
					return scalar name_nlines = r(name_nlines)
					return local name_newline `"`r(name_newline)'"'
					forvalues i = 1/`=r(name_nlines)' {
						return local name_line`i' `"`r(name_line`i')'"'
					}
				}
			}
		}
		
		* Wrap description
		if (`wrap_description' == 1) {
			local ml = cond("`maxlen_description'" != "", `maxlen_description', 50)
			cap _metadata_linewrap, text(`"`source'"') maxlength(`ml') prefix(description)
			if (_rc == 0) {
				return local description_stack `"`r(description_stack)'"'
				if (`lwf_all' == 1) {
					return scalar description_nlines = r(description_nlines)
					return local description_newline `"`r(description_newline)'"'
					forvalues i = 1/`=r(description_nlines)' {
						return local description_line`i' `"`r(description_line`i')'"'
					}
				}
			}
		}
		
		* Wrap note
		if (`wrap_note' == 1) {
			local ml = cond("`maxlen_note'" != "", `maxlen_note', 50)
			cap _metadata_linewrap, text(`"`note'"') maxlength(`ml') prefix(note)
			if (_rc == 0) {
				return local note_stack `"`r(note_stack)'"'
				if (`lwf_all' == 1) {
					return scalar note_nlines = r(note_nlines)
					return local note_newline `"`r(note_newline)'"'
					forvalues i = 1/`=r(note_nlines)' {
						return local note_line`i' `"`r(note_line`i')'"'
					}
				}
			}
		}
		
		* Wrap source
		if (`wrap_source' == 1) {
			local ml = cond("`maxlen_source'" != "", `maxlen_source', 50)
			cap _metadata_linewrap, text(`"`source'"') maxlength(`ml') prefix(source)
			if (_rc == 0) {
				return local source_stack `"`r(source_stack)'"'
				if (`lwf_all' == 1) {
					return scalar source_nlines = r(source_nlines)
					return local source_newline `"`r(source_newline)'"'
					forvalues i = 1/`=r(source_nlines)' {
						return local source_line`i' `"`r(source_line`i')'"'
					}
				}
			}
		}
		
		* Wrap topics
		if (`wrap_topic' == 1) {
			local ml = cond("`maxlen_topic'" != "", `maxlen_topic', 50)
			local topictext "`topic1'`topic2'`topic3'"
			cap _metadata_linewrap, text(`"`topictext'"') maxlength(`ml') prefix(topic)
			if (_rc == 0) {
				return local topic_stack `"`r(topic_stack)'"'
				if (`lwf_all' == 1) {
					return scalar topic_nlines = r(topic_nlines)
					return local topic_newline `"`r(topic_newline)'"'
					forvalues i = 1/`=r(topic_nlines)' {
						return local topic_line`i' `"`r(topic_line`i')'"'
					}
				}
			}
		}
	}
	
	*---------------------------------------------------------------------------
	*** return list
	return local source         "`collection'"
    return local varlabel       "`name'"
    return local indicator      "`indicator'"
	return local description    "`source'"
	return local note           "`note'"
	return local sourcecite     `"`sourcecite'"'
	return local topic1         "`topic1'"
	return local topic2         "`topic2'"
	return local topic3         "`topic3'"
	return local name           "`name'"
	return local collection     "`collection'"
	
	* Return URLs
	return scalar nurls = `nurls'
	if (`nurls' > 0) {
		forvalues u = 1/`nurls' {
			return local url`u' "`url`u''"
		}
	}
	
}

end

/********************************************************************************
* v 16.2.3  29jun2020        	   by Joao Pedro Azevedo                      *  
*   move to _api_read.ado
*   change layout
/********************************************************************************
* v 16.2.2  28jun2020        	   by Joao Pedro Azevedo                      *  
*   replace server used to query metadata

/********************************************************************************
* v 13.4  01jul2014               by Joao Pedro Azevedo                      
/********************************************************************************

_query_metadata2, indicator(si.pov.dday)
_query_metadata2, indicator(ny.gdp.pcap.pp.kd)

foreach var in si.pov.dday ny.gdp.pcap.pp.kd {
	_query_metadata2, indicator(`var')
}
