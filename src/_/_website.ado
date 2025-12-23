*******************************************************************************
* _website                                                                   *
*! v 15.5   22Dec2024				by João Pedro Azevedo
*		fix URL parsing for "http:  domain" patterns (spaces after colon)
*		return r(url1), r(url2), ... r(nurls) extracted from {browse} tags
*		refactored: single source of truth - URLs extracted from final SMCL

/*******************************************************************************/


program define _website, rclass

	version 9
	
    syntax          						///
                 ,                   		///
                         text(string)		///
						[ short(string)	]
	
	* Pre-process: fix URLs that got split (e.g., "http:  pip.worldbank.org" -> "http://pip.worldbank.org")
	* This handles cases where API returns URLs with spaces after the colon
	local text = ustrregexra(`"`text'"', "http:\s+([a-zA-Z0-9])", "http://$1")
	local text = ustrregexra(`"`text'"', "https:\s+([a-zA-Z0-9])", "https://$1")
	
	* Also handle "http: //" pattern (space before slashes)
	local text = ustrregexra(`"`text'"', "http:\s*//", "http://")
	local text = ustrregexra(`"`text'"', "https:\s*//", "https://")
					 
	local cword	= wordcount(`"`text'"')	
	
	if ("`short'" != "") {
		local short ":`short'"
	}
	
	* Store all original words first to avoid parsing issues after substitution
	* Note: Do NOT use compound quotes around `text' here - it treats entire string as one word
	forvalues i = 1/`cword' {
		local origword`i' : word `i' of `text'
	}
		
	local wc = 1
	while `wc' <= `cword' {
	
		local word `"`origword`wc''"'
		
		if strmatch("`word'","http*")==1 {
			
			* Strip ALL trailing punctuation (handles cases like "url.,")
			local urlpart "`word'"
			local trailpunct ""
			local lastchar = substr("`urlpart'", -1, 1)
			while inlist("`lastchar'", ",", ".", ";", ":", ")", "]") & length("`urlpart'") > 10 {
				local trailpunct "`lastchar'`trailpunct'"
				local urlpart = substr("`urlpart'", 1, length("`urlpart'")-1)
				local lastchar = substr("`urlpart'", -1, 1)
			}
			
			if ("`trailpunct'" != "") {
				local replaceword `"{browse "`urlpart'"}"'
				local replaceword `"`replaceword'`trailpunct'"'
			}
			else {
				local replaceword `"{browse "`word'"}"'
			}
			local k 1
		
		}
		if strmatch("`word'","*http*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-2,2)
			
			if "`c1'" == "(" & "`c2'" == ")." {
				* Extract URL from (url).
				local urlpart = substr("`word'", 2, length("`word'")-3)
				local replaceword `"({browse "`urlpart'"})."'
				local k 1
			}
			
		}
		if strmatch("`word'","*http*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-1,1)
			
			if "`c1'" == "(" & "`c2'" == ")" {
				* Extract URL from (url)
				local urlpart = substr("`word'", 2, length("`word'")-2)
				local replaceword `"({browse "`urlpart'"})"'
				local k 1
			}
			
		}
		if strmatch("`word'","www.*")==1 & ("`k'" != "1") {
			
			* Strip ALL trailing punctuation (handles cases like "url.,")
			local urlpart "`word'"
			local trailpunct ""
			local lastchar = substr("`urlpart'", -1, 1)
			while inlist("`lastchar'", ",", ".", ";", ":", ")", "]") & length("`urlpart'") > 5 {
				local trailpunct "`lastchar'`trailpunct'"
				local urlpart = substr("`urlpart'", 1, length("`urlpart'")-1)
				local lastchar = substr("`urlpart'", -1, 1)
			}
			
			if ("`trailpunct'" != "") {
				local replaceword `"{browse "http://`urlpart'"}"'
				local replaceword `"`replaceword'`trailpunct'"'
			}
			else {
				local replaceword `"{browse "http://`word'"}"'
			}
			local k 1
		
		}
		if strmatch("`word'","*www.*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-2,2)
			
			if "`c1'" == "(" & "`c2'" == ")." {
				* Extract URL from (url).
				local urlpart = substr("`word'", 2, length("`word'")-3)
				local replaceword `"({browse "http://`urlpart'"})."'
				local k 1
			}
		}
		if strmatch("`word'","*www.*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-1,1)
			
			if "`c1'" == "(" & "`c2'" == ")" {
				* Extract URL from (url)
				local urlpart = substr("`word'", 2, length("`word'")-2)
				local replaceword `"({browse "http://`urlpart'"})"'
				local k 1
			}
		}
		
		* Apply short option if specified
		if ("`k'"=="1") & ("`short'" != "") {
			* Replace closing with short label
			local replaceword = subinstr(`"`replaceword'"', `""}"', `"" `short'}"', .)
		}
		
		if ("`k'"=="1") {
			local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
			local k = .
		}
		if ("`k'"=="") {
			local k = ""
		}
	
		local wc = `wc' + 1

	}

	cap noi di ""
	cap noi di in smcl `"`text'"'
	cap noi di ""
	
	return local text = `"`text'"'
	
	*---------------------------------------------------------------------------
	* Extract URLs from {browse "url"} tags - SINGLE SOURCE OF TRUTH
	* This ensures returned URLs exactly match what is displayed as clickable
	* Only unique URLs are returned (deduplicated)
	*---------------------------------------------------------------------------
	local nurls = 0
	local urllist ""
	local tmptext `"`text'"'
	
	* Loop while we find {browse "..."} patterns
	while ustrregexm(`"`tmptext'"', `"\{browse "([^"]+)"\}"') {
		local thisurl = ustrregexs(1)
		* Remove the matched {browse} to find next one
		local tmptext = ustrregexrf(`"`tmptext'"', `"\{browse "[^"]+"\}"', "")
		
		* Check if URL already exists (deduplicate)
		local isdupe = 0
		if (`nurls' > 0) {
			forvalues u = 1/`nurls' {
				if ("`url`u''" == "`thisurl'") {
					local isdupe = 1
					continue, break
				}
			}
		}
		
		* Only add if not a duplicate
		if (`isdupe' == 0) {
			local nurls = `nurls' + 1
			local url`nurls' "`thisurl'"
		}
	}
	
	* Return unique URLs found
	return scalar nurls = `nurls'
	if (`nurls' > 0) {
		forvalues u = 1/`nurls' {
			return local url`u' "`url`u''"
		}
	}
	
end

/*

{browse "http://ideas.repec.org/c/boc/bocode/s457234.html"}


local ex1 "World Bank, Enterprise Surveys http://www.enterprisesurveys.org/"
_website, text("`ex1'")
_website, text("`ex1'") short(link)


local ex2 "World Bank, Enterprise Surveys (http://www.enterprisesurveys.org/)."
_website, text("`ex2'")
_website, text("`ex2'") short(link)


local ex3 "World Bank, Doing Business project (http://www.doingbusiness.org/)."
_website, text("`ex3'")
_website, text("`ex3'") short(link)


local ex4 "Robert J. Barro and Jong-Wha Lee: http://www.barrolee.com/"
_website, text("`ex4'")
_website, text("`ex4'") short(link)


local ex5 "Expenditure on education by level of education, expressed as a percentage of total general government expenditure on education. Divide government expenditure on a given level of education (ex. primary, secondary) by tot nment expenditure on education (all levels combined), and multiply by 100. A high percentage of government expenditure on education spent on a given level denotes a high priority given to that level compared to others. When interpreting this indi ne should take into account enrolment at that level, and the relative costs per student between different levels of education. For more information, consult the UNESCO Institute of Statistics website: http://www.uis.unesco.org/Education/"
_website, text("`ex5'")
_website, text("`ex5'") short(link)


local ex6 "Share of female students scoring at least 40 percent on the PASEC French language exam. The Knowledge Base Rate is the minimum learning goal based on the programs of the level selected and appropriate to the scale of th used. Data reflects country performance in the stated year according to PASEC. 2004-2005 PASEC data is only comparable with other country data from 2004-2005. 2006-2010 data is not comparable with data from 2004-2005. Consult the PASEC website fo etailed information: http://www.confemen.org/le-pasec/"
_website, text("`ex6'")
_website, text("`ex6'") short(link)


local ex7 "Development Assistance Committee of the Organisation for Economic Co-operation and Development, Geographical Distribution of Financial Flows to Developing Countries, Development Co-operation Report, and Internati elopment Statistics database. Data are available online at: www.oecd.org/dac/stats/idsonline."
_website, text("`ex7'")
_website, text("`ex7'") short(link)


local ex8 "World Health Organization, Global Database on Child Growth and Malnutrition. Country-level data are unadjusted data from national surveys, and thus may not be comparable across countries. Adjusted, comparable data are available at http://www.who.int/nutgrowthdb/en. Aggregation is based on UNICEF, WHO, and the World Bank harmonized dataset (adjusted, comparable data) and methodology."
_website, text("`ex8'")
_website, text("`ex8'") short(link)




		if (substr(`"`replaceword'"',-2,2)==".}") {
			local replaceword  = subinstr(`"`replaceword'"',`".}"',`"}."',.)
		}

		local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
		
		
		