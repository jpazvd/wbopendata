*******************************************************************************
*! v 13.4  01jul2014               by Joao Pedro Azevedo                        *
*******************************************************************************

program def _query_metadata, rclass

version 9.0

    syntax , INDICATOR(string)

    quietly {

        if ("`indicator'" != "") {
            local indicator1 = word("`indicator'",1)
            local indicator2 = subinstr("`indicator'","`indicator1'","",.)
            local indicator2 = trim(subinstr("`indicator2'","-","",.))
            if ("`indicator2'" == "") {
                local indicator2 "`indicator1'"
            }
        }


        local skipnumber = 2
        local trimnumber = 4

        tempfile in out source
        tempfile out3 source3
        tempname in2 out2 saving source1 source2

        capture : copy "http://api.worldbank.org/indicators/`indicator1'" `in', text replace
        local rc4 = _rc
        if (`rc4' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "http://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "http://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please consider setting Stata checksum off. {help set checksum}{p_end}"'
            noi dis as text `"{p 4 4 2} (5) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc4'
            break
        }

    *========================begin trim do file===========================================

        file open `in2'     using `in'      , read
        file open `out2'    using `out'     , write text replace
        file open `source2' using `source'  , write text replace

        file read `in2' line
        local l = 0
             while !r(eof) {
                  local ++l
                  file read `in2' line
                  if(`l'>`skipnumber') {
                    file write `out2' `"`line'"' _n
                    if ("`line'" != "") {
                        local line = subinstr(`"`line'"', `"""', "", .)
                        if (strmatch("`line'", "*<wb:name>*")==1) {
                            local labvar = "`line'"
                            local labvar = trim(subinstr("`labvar'","<wb:name>","",.))
                            local labvar = subinstr("`labvar'","</wb:name>","",.)
                        }
                        if (strmatch("`line'", "*<wb:source id=*")==1) {
							local line = substr("`line'",(strpos("`line'",">")+1),.)
                            file write `source2' `"`line'"' _n
                        }
                    }
                  }
            }
        file close `in2'
        file close `out2'
        file close `source2'

        file open `in2'  using `out' , read
        file open `out2' using `in', write text replace


        local i = 0
            while `i' < `l'- `trimnumber'-`skipnumber' {
             local ++i
             file read `in2' line
             file write `out2' `"`line'"' _n
           }
        file close `out2'
        file close `in2'

    *========================end trim do file===========================================

      	file open `in2'  using `in' , read
        file open `out2' using "`out'", write replace
    	file read `in2' line

        file write `out2' "{smcl}"  _n
        file write `out2' "{txt}"   _n
        file write `out2' "{hline}" _n

        local l = 0
      	while !r(eof) {
            local l = `l'+1
      	   	file write `out2' `"`macval(line)'"' _n
        	file read `in2' line
       	}

        file close `out2'

        filefilter `out' `out3' , from("<wb:name>")                  to("{p 4 4 2}{cmd:Name:} ")
        filefilter `out3' `out' , from("</wb:name>")                 to("{p_end} \r  {hline}")                         replace
        filefilter `out' `out3'  , from("<wb:source id=\Q1\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q2\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q3\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q4\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q5\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q6\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q7\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q8\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q9\Q>")      to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q10\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q11\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q12\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q13\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q14\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q15\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q16\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q17\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q18\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q19\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q20\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q21\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q22\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q23\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q24\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q25\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q26\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q27\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q28\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q29\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q30\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace

        filefilter `out' `out3'  , from("<wb:source id=\Q31\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q32\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q33\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q34\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q35\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q36\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q37\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out3' `out'  , from("<wb:source id=\Q38\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace
        filefilter `out' `out3'  , from("<wb:source id=\Q39\Q>")     to("{p 4 4 2}{cmd:Source:} ")                  replace

        filefilter `out3' `out'   , from("</wb:source>")              to("{p_end} \r {hline}")                           replace
        filefilter `out' `out3'   , from("<wb:sourceNote>")           to("{p 4 4 2}{cmd:Source Note:} ")                 replace
        filefilter `out3' `out'   , from("</wb:sourceNote>")          to("{p_end} \r {hline}")                           replace
        filefilter `out' `out3'   , from("<wb:sourceNote />")         to("")                                                 replace
        filefilter `out3' `out'   , from("<wb:sourceOrganization />") to("")                                                 replace
        filefilter `out' `out3'   , from("<wb:sourceOrganization>")   to("{p 4 4 2}{cmd:Source Organization:} ")             replace
        filefilter `out3' `out'   , from("</wb:sourceOrganization>")  to("{p_end} \r {hline}")                               replace
        filefilter `out' `out3'   , from("<wb:topics>")               to("")                                                 replace
        filefilter `out3' `out'   , from("</wb:topic>")               to("{p_end} \r {hline}")                               replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q1\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q2\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q3\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q4\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q5\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q6\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q7\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q8\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q9\Q>")       to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q10\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q11\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q12\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q13\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q14\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q15\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q16\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q17\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q18\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q19\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out3' `out'   , from("<wb:topic id=\Q20\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace
        filefilter `out' `out3'   , from("<wb:topic id=\Q21\Q>")      to("{p 4 4 2}{cmd:Topics:} ")                         replace

        filefilter `out3' `out'   , from("&amp;")                     to("&")                                               replace
        filefilter `out' `out3'   , from("http://")                   to("{browse \Qhttp://")                            replace
        filefilter `out' `out3'   , from(").")                        to("\Q}).")                                          replace
        filefilter `out3' `out'   , from(".htm")                      to(".htm\Q}")                                          replace


        filefilter `source' `source3'  , from("<wb:source id=\Q1\Q>")      to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q2\Q>")      to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q3\Q>")      to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q4\Q>")      to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q5\Q>")      to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q6\Q>")      to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q7\Q>")      to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q8\Q>")      to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q9\Q>")      to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q10\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q11\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q12\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q13\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q14\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q15\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q16\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q17\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q18\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q19\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q20\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q21\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q22\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q23\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q24\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q25\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q26\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q27\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q28\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q29\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q30\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q31\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q32\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q33\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q34\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q35\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q36\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q37\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("<wb:source id=\Q38\Q>")     to("")                  replace
        filefilter `source' `source3'  , from("<wb:source id=\Q39\Q>")     to("")                  replace
        filefilter `source3' `source'  , from("</wb:source>")              to("")                  replace
    }

        noi di ""
        noi di ""
        noi di ""
        noi di as text "Metadata: " as res "`indicator1'"
        noi type `out', smcl
        noi di ""
        noi di ""

        file open `source2'  using `source' , read
        file read `source2' line
        file close `source2'

        local line = trim("`line'")

        return local source         "`line'"
        return local varlabel       "`labvar'"
        return local indicator      "`indicator1'"

end
