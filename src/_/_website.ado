*******************************************************************************
* _website                                                                   *
*! v 15.2   24Mar2019				by João Pedro Azevedo
*		initial commit

/*******************************************************************************/


program define _website, rclass

	version 9
	
    syntax          						///
                 ,                   		///
                         text(string)		///
						[ short(string)	]
						 
			
	local cword	= wordcount(`"`text'"')	
	
	if ("`short'" != "") {
		local short ":`short'"
	}

		
	local wc = 1
	while `wc' <= `cword' {
	
		local word = word(`"`text'"',`wc')
		
		if strmatch("`word'","http*")==1 {
		
			local replaceword = subinstr("`word'","http",`"{browse "http"',.)
			
			local replaceword  `"`replaceword'"}"'

			local k 1
		
*			local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
		
		}
		if strmatch("`word'","*http*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-2,2)
			
			if "`c1'" == "(" & "`c2'" == ")." {
	
				local replaceword = subinstr("`word'","(http",`"({browse "http"',.)
				
				local replaceword  = subinstr(`"`replaceword'"',`")."',`""})."',.)

				local k 1

*				local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
			
			}
			
		}
		if strmatch("`word'","*http*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-1,1)
			
			if "`c1'" == "(" & "`c2'" == ")" {
	
				local replaceword = subinstr("`word'","(http",`"({browse "http"',.)
				
				local replaceword  = subinstr(`"`replaceword'"',`")"',`""})"',.)

				local k 1

*				local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
			
			}
			
		}
		if strmatch("`word'","www.*")==1 & ("`k'" != "1") {
		
			local replaceword = subinstr("`word'","www.",`"{browse "www."',.)
			
			local replaceword  `"`replaceword'"}"'

			local k 1

*			local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
		
		}
		if strmatch("`word'","*www.*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-2,2)
			
			if "`c1'" == "(" & "`c2'" == ")." {
	
				local replaceword = subinstr("`word'","(www.",`"({browse "www."',.)
				
				local replaceword  = subinstr(`"`replaceword'"',`")."',`""})."',.)
				
				local k 1

*				local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
			
			}
		}
		if strmatch("`word'","*www.*")==1 & ("`k'" != "1") {
		
			local c1 = substr("`word'",1,1)
			local c2 = substr("`word'",-1,1)
			
			if "`c1'" == "(" & "`c2'" == ")" {
	
				local replaceword = subinstr("`word'","(www.",`"({browse "www."',.)
				
				local replaceword  = subinstr(`"`replaceword'"',`")"',`""})"',.)
				
				local k 1

*				local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
			
			}
		}
		
		if (substr(`"`replaceword'"',-3,3)== `"."}"' ) & ("`k'"=="1") {
			local replaceword  = subinstr(`"`replaceword'"',`"."}"',`""}."',.)
		}
		
		if ("`k'"=="1") {
			local replaceword  = subinstr(`"`replaceword'"',`""}"',`""`short'}"',.)
			local text = subinstr(`"`text'"',`"`word'"',`"`replaceword'"',.)
			local wc = `wc' + 1
			local k = .
		}
		if ("`k'"=="") {
			local k = ""
		}
	
		local wc = `wc' + 1

	}

	di ""
	di in smcl `"`text'"'
	di ""
	
	return local text = `"`text'"'
	
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
		
		
		