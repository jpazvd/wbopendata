*******************************************************************************
*! v 16.3  	 8Jul2020        	   by Joao Pedro Azevedo                      *  
*		change API end point to HTTPS
*******************************************************************************

program def _query_metadata, rclass

version 9.0

    syntax , INDICATOR(string)

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
		
	qui _website, text("`source'")
    local source = r(text) 
	qui _website, text("`note'")
    local note = r(text)

	*---------------------------------------------------------------------------
	*** Display results
	noi di ""
	noi di as result "{p 4 4 4}{opt Metadata for indicator} `indicator'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Name}: `name'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Collection}: `collection'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Description}: `source'{p_end}"
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Note}: `note'{p_end}"

    *noi _website, text(`"`note'"')  short(link)
	noi di in smcl  "{hline}"
	noi di in smcl  "{p 4 4 4}{opt Topic(s)}: `topic1' `topic2' `topic3'{p_end}"
	noi di in smcl  "{hline}"
	noi di ""
	noi di ""
	
	*---------------------------------------------------------------------------
	*** return list
	return local source         "`collection'"
    return local varlabel       "`name'"
    return local indicator      "`indicator'"
	
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
