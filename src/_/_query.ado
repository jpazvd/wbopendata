*******************************************************************************
* _query                                                                      *
*! v 14.0  	09Jan2019               by Joao Pedro Azevedo                     *
*******************************************************************************

program def _query, rclass

version 9.0

    syntax                                          ///
                 [,                                 ///
                         LANGUAGE(string)           ///
                         COUNTRY(string)            ///
                         TOPICS(string)             ///
                         INDICATOR(string)          ///
                         DATE(string)               ///
                         LONG                       ///
                         CLEAR                      ///
                         LATEST                     ///
                         NOMETADATA                 ///
                 ]


quietly {

	local year = `date'

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
        local year1     "date=`year'&"
        local parameter "Indicators/`indicator1'?`year1'"
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

    if ("`country'" == "") & ("`indicator'" != "") {
        local country2 "all"
    }
    if ("`country'" != "") & ("`indicator'" != "") {
        local country2 "`country1'"
    }

    tempfile temp


	loc servername "http://api.worldbank.org/v2/"  /* Query server v2 */


/* country selection */
    if  (("`country'" != "") | ("`topics'" != "")) &  ("`indicator'" == "") {
        capture : copy "`servername'/`language'/`parameter'/?downloadformat=CSV&HREQ=N&filetype=data" `temp'
        local rc1 = _rc
        local queryspec "`servername'/`language'/`parameter'"
        local queryspec2 "topic `topics1'"
        if (`rc1' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "http://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "http://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc1'
            break
        }
    }
    if  ("`indicator'" != "") {
        capture : copy "`servername'/`language'/countries/`country2'/`parameter'?downloadformat=CSV&HREQ=N&filetype=data" `temp'
        local rc2 = _rc
        local queryspec "`servername'/`language'/countries/`country2'/`parameter'"
        local queryspec2 "indicator `indicator1'"
        if (`rc2' != 0) {
            noi di ""
            noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "http://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
            noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "http://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support.  {p_end}"'
            noi dis as text `"{p 4 4 2} (3) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
            noi dis as text `"{p 4 4 2} (4) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
            noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
            noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
            noi di ""
            exit `rc2'
            break
        }
    }

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
        noi di ""
        noi di as err "{p 4 4 2} Sorry... No data was downloaded for " as result "`queryspec2'. {p_end}"
        noi di ""
        noi dis as text `"{p 4 4 2} (1) Please check your internet connection by {browse "http://data.worldbank.org/" :clicking here}, if does not work please check with your internet provider or IT support, otherwise... {p_end}"'
        noi dis as text `"{p 4 4 2} (2) Please check your access to the World Bank API by {browse "http://api.worldbank.org/indicator" :clicking here}, if does not work please check with your firewall settings or internet provider or IT support, otherwise...  {p_end}"'
        noi dis as text `"{p 4 4 2} (3) Please check the availability of your indicator or topic by {browse "`queryspec'" :clicking here}. If the paramater value is not valid...  {p_end}"'
        noi dis as text `"{p 4 4 2} (4) Please check the list of available indictator(s) or topic(s) in the help {help wbopendata} or by visiting the {browse "http://data.worldbank.org/querybuilder" :API query builder}, if all the above seems fine...  {p_end}"'
        noi dis as text `"{p 4 4 2} (5) Please consider ajusting your Stata timeout parameters. For more details see {help netio}. {p_end}
        noi dis as text `"{p 4 4 2} (6) Please send us an email to report this error by {browse "mailto:data@worldbank.org, ?subject= wbopendata query error at `c(current_date)' `c(current_time)': `queryspec' "  :clicking here} or writing to:  {p_end}"'
        noi dis as result "{p 12 4 2} email: " as input "data@worldbank.org  {p_end}"
        noi dis as result "{p 12 4 2} subject: " as input `"wbopendata query error at `c(current_date)' `c(current_time)': `queryspec'  {p_end}"'
        noi di ""
        noi di ""
        break
        exit 20
    }

    cap: drop v*
    cap: drop r*
    cap: drop tg*

***************************************************

    if (("`long'" == "") & ("`country'" != "")) &  ("`indicator'" == "") {
        local w1 = word("`country'",1)
        local w2 = trim(subinstr("`country'","`w1' - ","",.))
        gen str5 countrycode  = upper("`w1'")
        gen str80 countryname = "`w2'"
        order countryname countrycode
        lab var countryname "Country Name"
        lab var countrycode "Country Code"
    }

    if ("`long'" == "") & ("`indicator'" != "") {
        local w1 = word("`indicator'",1)
        local w2 = trim(subinstr("`indicator' ","`w1' - ","",.))
        gen indicatorcode = "`w1'"
        gen indicatorname = "`w2'"
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



        local w1 = word("`country'",1)
        local w2 = trim(subinstr("`country'","`w1' - ","",.))
        gen str5 countrycode  = upper("`w1'")
        gen str80 countryname = "`w2'"
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
        local w1 = word("`indicator'",1)
        local w2 = trim(subinstr("`indicator' ","`w1' - ","",.))
        gen indicatorcode = "`w1'"
        gen indicatorname = "`w2'"
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

quietly tostring  countryname countrycode, replace

quietly {

    gen region = ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "ABW" & region == ""
    replace region =  "South Asia" if countrycode == "AFG" & region == ""
    replace region =  "Aggregates" if countrycode == "AFR" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "AGO" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "ALB" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "AND" & region == ""
    replace region =  "Aggregates" if countrycode == "ANR" & region == ""
    replace region =  "Aggregates" if countrycode == "ARB" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "ARE" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "ARG" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "ARM" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "ASM" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "ATG" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "AUS" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "AUT" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "AZE" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "BDI" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "BEL" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "BEN" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "BFA" & region == ""
    replace region =  "South Asia" if countrycode == "BGD" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "BGR" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "BHR" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "BHS" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "BIH" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "BLR" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "BLZ" & region == ""
    replace region =  "North America" if countrycode == "BMU" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "BOL" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "BRA" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "BRB" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "BRN" & region == ""
    replace region =  "South Asia" if countrycode == "BTN" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "BWA" & region == ""
    replace region =  "Aggregates" if countrycode == "CAA" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "CAF" & region == ""
    replace region =  "North America" if countrycode == "CAN" & region == ""
    replace region =  "Aggregates" if countrycode == "CEA" & region == ""
    replace region =  "Aggregates" if countrycode == "CEU" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "CHE" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "CHI" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "CHL" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "CHN" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "CIV" & region == ""
    replace region =  "Aggregates" if countrycode == "CLA" & region == ""
    replace region =  "Aggregates" if countrycode == "CME" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "CMR" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "COD" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "COG" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "COL" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "COM" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "CPV" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "CRI" & region == ""
    replace region =  "Aggregates" if countrycode == "CSA" & region == ""
    replace region =  "Aggregates" if countrycode == "CSS" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "CUB" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "CUW" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "CYM" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "CYP" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "CZE" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "DEU" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "DJI" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "DMA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "DNK" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "DOM" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "DZA" & region == ""
    replace region =  "Aggregates" if countrycode == "EAP" & region == ""
    replace region =  "Aggregates" if countrycode == "EAS" & region == ""
    replace region =  "Aggregates" if countrycode == "ECA" & region == ""
    replace region =  "Aggregates" if countrycode == "ECS" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "ECU" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "EGY" & region == ""
    replace region =  "Aggregates" if countrycode == "EMU" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "ERI" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "ESP" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "EST" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "ETH" & region == ""
    replace region =  "Aggregates" if countrycode == "EUU" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "FIN" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "FJI" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "FRA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "FRO" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "FSM" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "GAB" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "GBR" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "GEO" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "GHA" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "GIN" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "GMB" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "GNB" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "GNQ" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "GRC" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "GRD" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "GRL" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "GTM" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "GUM" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "GUY" & region == ""
    replace region =  "Aggregates" if countrycode == "HIC" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "HKG" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "HND" & region == ""
    replace region =  "Aggregates" if countrycode == "HPC" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "HRV" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "HTI" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "HUN" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "IDN" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "IMN" & region == ""
    replace region =  "South Asia" if countrycode == "IND" & region == ""
    replace region =  "Aggregates" if countrycode == "INX" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "IRL" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "IRN" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "IRQ" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "ISL" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "ISR" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "ITA" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "JAM" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "JOR" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "JPN" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "KAZ" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "KEN" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "KGZ" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "KHM" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "KIR" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "KNA" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "KOR" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "KSV" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "KWT" & region == ""
    replace region =  "Aggregates" if countrycode == "LAC" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "LAO" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "LBN" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "LBR" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "LBY" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "LCA" & region == ""
    replace region =  "Aggregates" if countrycode == "LCN" & region == ""
    replace region =  "Aggregates" if countrycode == "LCR" & region == ""
    replace region =  "Aggregates" if countrycode == "LDC" & region == ""
    replace region =  "Aggregates" if countrycode == "LIC" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "LIE" & region == ""
    replace region =  "South Asia" if countrycode == "LKA" & region == ""
    replace region =  "Aggregates" if countrycode == "LMC" & region == ""
    replace region =  "Aggregates" if countrycode == "LMY" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "LSO" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "LTU" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "LUX" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "LVA" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "MAC" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "MAF" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "MAR" & region == ""
    replace region =  "Aggregates" if countrycode == "MCA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "MCO" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "MDA" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "MDG" & region == ""
    replace region =  "South Asia" if countrycode == "MDV" & region == ""
    replace region =  "Aggregates" if countrycode == "MEA" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "MEX" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "MHL" & region == ""
    replace region =  "Aggregates" if countrycode == "MIC" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "MKD" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "MLI" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "MLT" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "MMR" & region == ""
    replace region =  "Aggregates" if countrycode == "MNA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "MNE" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "MNG" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "MNP" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "MOZ" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "MRT" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "MUS" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "MWI" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "MYS" & region == ""
    replace region =  "Aggregates" if countrycode == "NAC" & region == ""
    replace region =  "Aggregates" if countrycode == "NAF" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "NAM" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "NCL" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "NER" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "NGA" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "NIC" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "NLD" & region == ""
    replace region =  "Aggregates" if countrycode == "NOC" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "NOR" & region == ""
    replace region =  "South Asia" if countrycode == "NPL" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "NZL" & region == ""
    replace region =  "Aggregates" if countrycode == "OEC" & region == ""
    replace region =  "Aggregates" if countrycode == "OED" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "OMN" & region == ""
    replace region =  "Aggregates" if countrycode == "OSS" & region == ""
    replace region =  "South Asia" if countrycode == "PAK" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "PAN" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "PER" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "PHL" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "PLW" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "PNG" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "POL" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "PRI" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "PRK" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "PRT" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "PRY" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "PSE" & region == ""
    replace region =  "Aggregates" if countrycode == "PSS" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "PYF" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "QAT" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "ROU" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "RUS" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "RWA" & region == ""
    replace region =  "Aggregates" if countrycode == "SAS" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "SAU" & region == ""
    replace region =  "Aggregates" if countrycode == "SCE" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SDN" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SEN" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "SGP" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "SLB" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SLE" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "SLV" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "SMR" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SOM" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "SRB" & region == ""
    replace region =  "Aggregates" if countrycode == "SSA" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SSD" & region == ""
    replace region =  "Aggregates" if countrycode == "SSF" & region == ""
    replace region =  "Aggregates" if countrycode == "SST" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "STP" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "SUR" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "SVK" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "SVN" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "SWE" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SWZ" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "SXM" & region == ""
    replace region =  "Aggregates" if countrycode == "SXZ" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "SYC" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "SYR" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "TCA" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "TCD" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "TGO" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "THA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "TJK" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "TKM" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "TLS" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "TON" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "TTO" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "TUN" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "TUR" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "TUV" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "TZA" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "UGA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "UKR" & region == ""
    replace region =  "Aggregates" if countrycode == "UMC" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "URY" & region == ""
    replace region =  "North America" if countrycode == "USA" & region == ""
    replace region =  "Europe & Central Asia (all income levels)" if countrycode == "UZB" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "VCT" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "VEN" & region == ""
    replace region =  "Latin America & Caribbean (all income levels)" if countrycode == "VIR" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "VNM" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "VUT" & region == ""
    replace region =  "Aggregates" if countrycode == "WLD" & region == ""
    replace region =  "East Asia & Pacific (all income levels)" if countrycode == "WSM" & region == ""
    replace region =  "Aggregates" if countrycode == "XZN" & region == ""
    replace region =  "Middle East & North Africa (all income levels)" if countrycode == "YEM" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "ZAF" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "ZMB" & region == ""
    replace region =  "Sub-Saharan Africa (all income levels)" if countrycode == "ZWE" & region == ""


    gen regioncode = ""
    replace regioncode =  "LCN" if countrycode == "ABW" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "AFG" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "AFR" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "AGO" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "ALB" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "AND" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "ANR" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "ARB" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "ARE" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "ARG" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "ARM" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "ASM" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "ATG" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "AUS" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "AUT" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "AZE" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "BDI" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "BEL" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "BEN" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "BFA" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "BGD" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "BGR" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "BHR" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "BHS" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "BIH" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "BLR" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "BLZ" & regioncode == ""
    replace regioncode =  "NAC" if countrycode == "BMU" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "BOL" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "BRA" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "BRB" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "BRN" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "BTN" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "BWA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CAA" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "CAF" & regioncode == ""
    replace regioncode =  "NAC" if countrycode == "CAN" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CEA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CEU" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "CHE" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "CHI" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "CHL" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "CHN" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "CIV" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CLA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CME" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "CMR" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "COD" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "COG" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "COL" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "COM" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "CPV" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "CRI" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CSA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "CSS" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "CUB" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "CUW" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "CYM" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "CYP" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "CZE" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "DEU" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "DJI" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "DMA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "DNK" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "DOM" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "DZA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "EAP" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "EAS" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "ECA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "ECS" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "ECU" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "EGY" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "EMU" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "ERI" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "ESP" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "EST" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "ETH" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "EUU" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "FIN" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "FJI" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "FRA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "FRO" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "FSM" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "GAB" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "GBR" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "GEO" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "GHA" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "GIN" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "GMB" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "GNB" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "GNQ" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "GRC" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "GRD" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "GRL" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "GTM" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "GUM" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "GUY" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "HIC" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "HKG" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "HND" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "HPC" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "HRV" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "HTI" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "HUN" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "IDN" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "IMN" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "IND" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "INX" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "IRL" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "IRN" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "IRQ" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "ISL" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "ISR" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "ITA" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "JAM" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "JOR" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "JPN" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "KAZ" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "KEN" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "KGZ" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "KHM" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "KIR" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "KNA" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "KOR" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "KSV" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "KWT" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LAC" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "LAO" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "LBN" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "LBR" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "LBY" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "LCA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LCN" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LCR" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LDC" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LIC" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "LIE" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "LKA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LMC" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "LMY" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "LSO" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "LTU" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "LUX" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "LVA" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "MAC" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "MAF" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "MAR" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "MCA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "MCO" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "MDA" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "MDG" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "MDV" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "MEA" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "MEX" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "MHL" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "MIC" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "MKD" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "MLI" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "MLT" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "MMR" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "MNA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "MNE" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "MNG" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "MNP" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "MOZ" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "MRT" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "MUS" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "MWI" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "MYS" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "NAC" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "NAF" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "NAM" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "NCL" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "NER" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "NGA" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "NIC" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "NLD" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "NOC" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "NOR" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "NPL" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "NZL" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "OEC" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "OED" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "OMN" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "OSS" & regioncode == ""
    replace regioncode =  "SAS" if countrycode == "PAK" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "PAN" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "PER" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "PHL" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "PLW" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "PNG" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "POL" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "PRI" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "PRK" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "PRT" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "PRY" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "PSE" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "PSS" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "PYF" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "QAT" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "ROU" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "RUS" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "RWA" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "SAS" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "SAU" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "SCE" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SDN" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SEN" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "SGP" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "SLB" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SLE" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "SLV" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "SMR" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SOM" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "SRB" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "SSA" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SSD" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "SSF" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "SST" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "STP" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "SUR" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "SVK" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "SVN" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "SWE" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SWZ" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "SXM" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "SXZ" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "SYC" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "SYR" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "TCA" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "TCD" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "TGO" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "THA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "TJK" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "TKM" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "TLS" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "TON" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "TTO" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "TUN" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "TUR" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "TUV" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "TZA" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "UGA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "UKR" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "UMC" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "URY" & regioncode == ""
    replace regioncode =  "NAC" if countrycode == "USA" & regioncode == ""
    replace regioncode =  "ECS" if countrycode == "UZB" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "VCT" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "VEN" & regioncode == ""
    replace regioncode =  "LCN" if countrycode == "VIR" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "VNM" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "VUT" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "WLD" & regioncode == ""
    replace regioncode =  "EAS" if countrycode == "WSM" & regioncode == ""
    replace regioncode =  "NA" if countrycode == "XZN" & regioncode == ""
    replace regioncode =  "MEA" if countrycode == "YEM" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "ZAF" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "ZMB" & regioncode == ""
    replace regioncode =  "SSF" if countrycode == "ZWE" & regioncode == ""



    gen iso2code = ""
    replace iso2code =  "AW" if countrycode == "ABW" & iso2code == ""
    replace iso2code =  "AF" if countrycode == "AFG" & iso2code == ""
    replace iso2code =  "A9" if countrycode == "AFR" & iso2code == ""
    replace iso2code =  "AO" if countrycode == "AGO" & iso2code == ""
    replace iso2code =  "AL" if countrycode == "ALB" & iso2code == ""
    replace iso2code =  "AD" if countrycode == "AND" & iso2code == ""
    replace iso2code =  "L5" if countrycode == "ANR" & iso2code == ""
    replace iso2code =  "1A" if countrycode == "ARB" & iso2code == ""
    replace iso2code =  "AE" if countrycode == "ARE" & iso2code == ""
    replace iso2code =  "AR" if countrycode == "ARG" & iso2code == ""
    replace iso2code =  "AM" if countrycode == "ARM" & iso2code == ""
    replace iso2code =  "AS" if countrycode == "ASM" & iso2code == ""
    replace iso2code =  "AG" if countrycode == "ATG" & iso2code == ""
    replace iso2code =  "AU" if countrycode == "AUS" & iso2code == ""
    replace iso2code =  "AT" if countrycode == "AUT" & iso2code == ""
    replace iso2code =  "AZ" if countrycode == "AZE" & iso2code == ""
    replace iso2code =  "BI" if countrycode == "BDI" & iso2code == ""
    replace iso2code =  "BE" if countrycode == "BEL" & iso2code == ""
    replace iso2code =  "BJ" if countrycode == "BEN" & iso2code == ""
    replace iso2code =  "BF" if countrycode == "BFA" & iso2code == ""
    replace iso2code =  "BD" if countrycode == "BGD" & iso2code == ""
    replace iso2code =  "BG" if countrycode == "BGR" & iso2code == ""
    replace iso2code =  "BH" if countrycode == "BHR" & iso2code == ""
    replace iso2code =  "BS" if countrycode == "BHS" & iso2code == ""
    replace iso2code =  "BA" if countrycode == "BIH" & iso2code == ""
    replace iso2code =  "BY" if countrycode == "BLR" & iso2code == ""
    replace iso2code =  "BZ" if countrycode == "BLZ" & iso2code == ""
    replace iso2code =  "BM" if countrycode == "BMU" & iso2code == ""
    replace iso2code =  "BO" if countrycode == "BOL" & iso2code == ""
    replace iso2code =  "BR" if countrycode == "BRA" & iso2code == ""
    replace iso2code =  "BB" if countrycode == "BRB" & iso2code == ""
    replace iso2code =  "BN" if countrycode == "BRN" & iso2code == ""
    replace iso2code =  "BT" if countrycode == "BTN" & iso2code == ""
    replace iso2code =  "BW" if countrycode == "BWA" & iso2code == ""
    replace iso2code =  "C9" if countrycode == "CAA" & iso2code == ""
    replace iso2code =  "CF" if countrycode == "CAF" & iso2code == ""
    replace iso2code =  "CA" if countrycode == "CAN" & iso2code == ""
    replace iso2code =  "C4" if countrycode == "CEA" & iso2code == ""
    replace iso2code =  "C5" if countrycode == "CEU" & iso2code == ""
    replace iso2code =  "CH" if countrycode == "CHE" & iso2code == ""
    replace iso2code =  "JG" if countrycode == "CHI" & iso2code == ""
    replace iso2code =  "CL" if countrycode == "CHL" & iso2code == ""
    replace iso2code =  "CN" if countrycode == "CHN" & iso2code == ""
    replace iso2code =  "CI" if countrycode == "CIV" & iso2code == ""
    replace iso2code =  "C6" if countrycode == "CLA" & iso2code == ""
    replace iso2code =  "C7" if countrycode == "CME" & iso2code == ""
    replace iso2code =  "CM" if countrycode == "CMR" & iso2code == ""
    replace iso2code =  "CD" if countrycode == "COD" & iso2code == ""
    replace iso2code =  "CG" if countrycode == "COG" & iso2code == ""
    replace iso2code =  "CO" if countrycode == "COL" & iso2code == ""
    replace iso2code =  "KM" if countrycode == "COM" & iso2code == ""
    replace iso2code =  "CV" if countrycode == "CPV" & iso2code == ""
    replace iso2code =  "CR" if countrycode == "CRI" & iso2code == ""
    replace iso2code =  "C8" if countrycode == "CSA" & iso2code == ""
    replace iso2code =  "S3" if countrycode == "CSS" & iso2code == ""
    replace iso2code =  "CU" if countrycode == "CUB" & iso2code == ""
    replace iso2code =  "CW" if countrycode == "CUW" & iso2code == ""
    replace iso2code =  "KY" if countrycode == "CYM" & iso2code == ""
    replace iso2code =  "CY" if countrycode == "CYP" & iso2code == ""
    replace iso2code =  "CZ" if countrycode == "CZE" & iso2code == ""
    replace iso2code =  "DE" if countrycode == "DEU" & iso2code == ""
    replace iso2code =  "DJ" if countrycode == "DJI" & iso2code == ""
    replace iso2code =  "DM" if countrycode == "DMA" & iso2code == ""
    replace iso2code =  "DK" if countrycode == "DNK" & iso2code == ""
    replace iso2code =  "DO" if countrycode == "DOM" & iso2code == ""
    replace iso2code =  "DZ" if countrycode == "DZA" & iso2code == ""
    replace iso2code =  "4E" if countrycode == "EAP" & iso2code == ""
    replace iso2code =  "Z4" if countrycode == "EAS" & iso2code == ""
    replace iso2code =  "7E" if countrycode == "ECA" & iso2code == ""
    replace iso2code =  "Z7" if countrycode == "ECS" & iso2code == ""
    replace iso2code =  "EC" if countrycode == "ECU" & iso2code == ""
    replace iso2code =  "EG" if countrycode == "EGY" & iso2code == ""
    replace iso2code =  "XC" if countrycode == "EMU" & iso2code == ""
    replace iso2code =  "ER" if countrycode == "ERI" & iso2code == ""
    replace iso2code =  "ES" if countrycode == "ESP" & iso2code == ""
    replace iso2code =  "EE" if countrycode == "EST" & iso2code == ""
    replace iso2code =  "ET" if countrycode == "ETH" & iso2code == ""
    replace iso2code =  "EU" if countrycode == "EUU" & iso2code == ""
    replace iso2code =  "FI" if countrycode == "FIN" & iso2code == ""
    replace iso2code =  "FJ" if countrycode == "FJI" & iso2code == ""
    replace iso2code =  "FR" if countrycode == "FRA" & iso2code == ""
    replace iso2code =  "FO" if countrycode == "FRO" & iso2code == ""
    replace iso2code =  "FM" if countrycode == "FSM" & iso2code == ""
    replace iso2code =  "GA" if countrycode == "GAB" & iso2code == ""
    replace iso2code =  "GB" if countrycode == "GBR" & iso2code == ""
    replace iso2code =  "GE" if countrycode == "GEO" & iso2code == ""
    replace iso2code =  "GH" if countrycode == "GHA" & iso2code == ""
    replace iso2code =  "GN" if countrycode == "GIN" & iso2code == ""
    replace iso2code =  "GM" if countrycode == "GMB" & iso2code == ""
    replace iso2code =  "GW" if countrycode == "GNB" & iso2code == ""
    replace iso2code =  "GQ" if countrycode == "GNQ" & iso2code == ""
    replace iso2code =  "GR" if countrycode == "GRC" & iso2code == ""
    replace iso2code =  "GD" if countrycode == "GRD" & iso2code == ""
    replace iso2code =  "GL" if countrycode == "GRL" & iso2code == ""
    replace iso2code =  "GT" if countrycode == "GTM" & iso2code == ""
    replace iso2code =  "GU" if countrycode == "GUM" & iso2code == ""
    replace iso2code =  "GY" if countrycode == "GUY" & iso2code == ""
    replace iso2code =  "XD" if countrycode == "HIC" & iso2code == ""
    replace iso2code =  "HK" if countrycode == "HKG" & iso2code == ""
    replace iso2code =  "HN" if countrycode == "HND" & iso2code == ""
    replace iso2code =  "XE" if countrycode == "HPC" & iso2code == ""
    replace iso2code =  "HR" if countrycode == "HRV" & iso2code == ""
    replace iso2code =  "HT" if countrycode == "HTI" & iso2code == ""
    replace iso2code =  "HU" if countrycode == "HUN" & iso2code == ""
    replace iso2code =  "ID" if countrycode == "IDN" & iso2code == ""
    replace iso2code =  "IM" if countrycode == "IMN" & iso2code == ""
    replace iso2code =  "IN" if countrycode == "IND" & iso2code == ""
    replace iso2code =  "XY" if countrycode == "INX" & iso2code == ""
    replace iso2code =  "IE" if countrycode == "IRL" & iso2code == ""
    replace iso2code =  "IR" if countrycode == "IRN" & iso2code == ""
    replace iso2code =  "IQ" if countrycode == "IRQ" & iso2code == ""
    replace iso2code =  "IS" if countrycode == "ISL" & iso2code == ""
    replace iso2code =  "IL" if countrycode == "ISR" & iso2code == ""
    replace iso2code =  "IT" if countrycode == "ITA" & iso2code == ""
    replace iso2code =  "JM" if countrycode == "JAM" & iso2code == ""
    replace iso2code =  "JO" if countrycode == "JOR" & iso2code == ""
    replace iso2code =  "JP" if countrycode == "JPN" & iso2code == ""
    replace iso2code =  "KZ" if countrycode == "KAZ" & iso2code == ""
    replace iso2code =  "KE" if countrycode == "KEN" & iso2code == ""
    replace iso2code =  "KG" if countrycode == "KGZ" & iso2code == ""
    replace iso2code =  "KH" if countrycode == "KHM" & iso2code == ""
    replace iso2code =  "KI" if countrycode == "KIR" & iso2code == ""
    replace iso2code =  "KN" if countrycode == "KNA" & iso2code == ""
    replace iso2code =  "KR" if countrycode == "KOR" & iso2code == ""
    replace iso2code =  "KV" if countrycode == "KSV" & iso2code == ""
    replace iso2code =  "KW" if countrycode == "KWT" & iso2code == ""
    replace iso2code =  "XJ" if countrycode == "LAC" & iso2code == ""
    replace iso2code =  "LA" if countrycode == "LAO" & iso2code == ""
    replace iso2code =  "LB" if countrycode == "LBN" & iso2code == ""
    replace iso2code =  "LR" if countrycode == "LBR" & iso2code == ""
    replace iso2code =  "LY" if countrycode == "LBY" & iso2code == ""
    replace iso2code =  "LC" if countrycode == "LCA" & iso2code == ""
    replace iso2code =  "ZJ" if countrycode == "LCN" & iso2code == ""
    replace iso2code =  "L4" if countrycode == "LCR" & iso2code == ""
    replace iso2code =  "XL" if countrycode == "LDC" & iso2code == ""
    replace iso2code =  "XM" if countrycode == "LIC" & iso2code == ""
    replace iso2code =  "LI" if countrycode == "LIE" & iso2code == ""
    replace iso2code =  "LK" if countrycode == "LKA" & iso2code == ""
    replace iso2code =  "XN" if countrycode == "LMC" & iso2code == ""
    replace iso2code =  "XO" if countrycode == "LMY" & iso2code == ""
    replace iso2code =  "LS" if countrycode == "LSO" & iso2code == ""
    replace iso2code =  "LT" if countrycode == "LTU" & iso2code == ""
    replace iso2code =  "LU" if countrycode == "LUX" & iso2code == ""
    replace iso2code =  "LV" if countrycode == "LVA" & iso2code == ""
    replace iso2code =  "MO" if countrycode == "MAC" & iso2code == ""
    replace iso2code =  "MF" if countrycode == "MAF" & iso2code == ""
    replace iso2code =  "MA" if countrycode == "MAR" & iso2code == ""
    replace iso2code =  "L6" if countrycode == "MCA" & iso2code == ""
    replace iso2code =  "MC" if countrycode == "MCO" & iso2code == ""
    replace iso2code =  "MD" if countrycode == "MDA" & iso2code == ""
    replace iso2code =  "MG" if countrycode == "MDG" & iso2code == ""
    replace iso2code =  "MV" if countrycode == "MDV" & iso2code == ""
    replace iso2code =  "ZQ" if countrycode == "MEA" & iso2code == ""
    replace iso2code =  "MX" if countrycode == "MEX" & iso2code == ""
    replace iso2code =  "MH" if countrycode == "MHL" & iso2code == ""
    replace iso2code =  "XP" if countrycode == "MIC" & iso2code == ""
    replace iso2code =  "MK" if countrycode == "MKD" & iso2code == ""
    replace iso2code =  "ML" if countrycode == "MLI" & iso2code == ""
    replace iso2code =  "MT" if countrycode == "MLT" & iso2code == ""
    replace iso2code =  "MM" if countrycode == "MMR" & iso2code == ""
    replace iso2code =  "XQ" if countrycode == "MNA" & iso2code == ""
    replace iso2code =  "ME" if countrycode == "MNE" & iso2code == ""
    replace iso2code =  "MN" if countrycode == "MNG" & iso2code == ""
    replace iso2code =  "MP" if countrycode == "MNP" & iso2code == ""
    replace iso2code =  "MZ" if countrycode == "MOZ" & iso2code == ""
    replace iso2code =  "MR" if countrycode == "MRT" & iso2code == ""
    replace iso2code =  "MU" if countrycode == "MUS" & iso2code == ""
    replace iso2code =  "MW" if countrycode == "MWI" & iso2code == ""
    replace iso2code =  "MY" if countrycode == "MYS" & iso2code == ""
    replace iso2code =  "XU" if countrycode == "NAC" & iso2code == ""
    replace iso2code =  "M2" if countrycode == "NAF" & iso2code == ""
    replace iso2code =  "NA" if countrycode == "NAM" & iso2code == ""
    replace iso2code =  "NC" if countrycode == "NCL" & iso2code == ""
    replace iso2code =  "NE" if countrycode == "NER" & iso2code == ""
    replace iso2code =  "NG" if countrycode == "NGA" & iso2code == ""
    replace iso2code =  "NI" if countrycode == "NIC" & iso2code == ""
    replace iso2code =  "NL" if countrycode == "NLD" & iso2code == ""
    replace iso2code =  "XR" if countrycode == "NOC" & iso2code == ""
    replace iso2code =  "NO" if countrycode == "NOR" & iso2code == ""
    replace iso2code =  "NP" if countrycode == "NPL" & iso2code == ""
    replace iso2code =  "NZ" if countrycode == "NZL" & iso2code == ""
    replace iso2code =  "XS" if countrycode == "OEC" & iso2code == ""
    replace iso2code =  "OE" if countrycode == "OED" & iso2code == ""
    replace iso2code =  "OM" if countrycode == "OMN" & iso2code == ""
    replace iso2code =  "S4" if countrycode == "OSS" & iso2code == ""
    replace iso2code =  "PK" if countrycode == "PAK" & iso2code == ""
    replace iso2code =  "PA" if countrycode == "PAN" & iso2code == ""
    replace iso2code =  "PE" if countrycode == "PER" & iso2code == ""
    replace iso2code =  "PH" if countrycode == "PHL" & iso2code == ""
    replace iso2code =  "PW" if countrycode == "PLW" & iso2code == ""
    replace iso2code =  "PG" if countrycode == "PNG" & iso2code == ""
    replace iso2code =  "PL" if countrycode == "POL" & iso2code == ""
    replace iso2code =  "PR" if countrycode == "PRI" & iso2code == ""
    replace iso2code =  "KP" if countrycode == "PRK" & iso2code == ""
    replace iso2code =  "PT" if countrycode == "PRT" & iso2code == ""
    replace iso2code =  "PY" if countrycode == "PRY" & iso2code == ""
    replace iso2code =  "PS" if countrycode == "PSE" & iso2code == ""
    replace iso2code =  "S2" if countrycode == "PSS" & iso2code == ""
    replace iso2code =  "PF" if countrycode == "PYF" & iso2code == ""
    replace iso2code =  "QA" if countrycode == "QAT" & iso2code == ""
    replace iso2code =  "RO" if countrycode == "ROU" & iso2code == ""
    replace iso2code =  "RU" if countrycode == "RUS" & iso2code == ""
    replace iso2code =  "RW" if countrycode == "RWA" & iso2code == ""
    replace iso2code =  "8S" if countrycode == "SAS" & iso2code == ""
    replace iso2code =  "SA" if countrycode == "SAU" & iso2code == ""
    replace iso2code =  "L7" if countrycode == "SCE" & iso2code == ""
    replace iso2code =  "SD" if countrycode == "SDN" & iso2code == ""
    replace iso2code =  "SN" if countrycode == "SEN" & iso2code == ""
    replace iso2code =  "SG" if countrycode == "SGP" & iso2code == ""
    replace iso2code =  "SB" if countrycode == "SLB" & iso2code == ""
    replace iso2code =  "SL" if countrycode == "SLE" & iso2code == ""
    replace iso2code =  "SV" if countrycode == "SLV" & iso2code == ""
    replace iso2code =  "SM" if countrycode == "SMR" & iso2code == ""
    replace iso2code =  "SO" if countrycode == "SOM" & iso2code == ""
    replace iso2code =  "RS" if countrycode == "SRB" & iso2code == ""
    replace iso2code =  "ZF" if countrycode == "SSA" & iso2code == ""
    replace iso2code =  "SS" if countrycode == "SSD" & iso2code == ""
    replace iso2code =  "ZG" if countrycode == "SSF" & iso2code == ""
    replace iso2code =  "S1" if countrycode == "SST" & iso2code == ""
    replace iso2code =  "ST" if countrycode == "STP" & iso2code == ""
    replace iso2code =  "SR" if countrycode == "SUR" & iso2code == ""
    replace iso2code =  "SK" if countrycode == "SVK" & iso2code == ""
    replace iso2code =  "SI" if countrycode == "SVN" & iso2code == ""
    replace iso2code =  "SE" if countrycode == "SWE" & iso2code == ""
    replace iso2code =  "SZ" if countrycode == "SWZ" & iso2code == ""
    replace iso2code =  "SX" if countrycode == "SXM" & iso2code == ""
    replace iso2code =  "A4" if countrycode == "SXZ" & iso2code == ""
    replace iso2code =  "SC" if countrycode == "SYC" & iso2code == ""
    replace iso2code =  "SY" if countrycode == "SYR" & iso2code == ""
    replace iso2code =  "TC" if countrycode == "TCA" & iso2code == ""
    replace iso2code =  "TD" if countrycode == "TCD" & iso2code == ""
    replace iso2code =  "TG" if countrycode == "TGO" & iso2code == ""
    replace iso2code =  "TH" if countrycode == "THA" & iso2code == ""
    replace iso2code =  "TJ" if countrycode == "TJK" & iso2code == ""
    replace iso2code =  "TM" if countrycode == "TKM" & iso2code == ""
    replace iso2code =  "TL" if countrycode == "TLS" & iso2code == ""
    replace iso2code =  "TO" if countrycode == "TON" & iso2code == ""
    replace iso2code =  "TT" if countrycode == "TTO" & iso2code == ""
    replace iso2code =  "TN" if countrycode == "TUN" & iso2code == ""
    replace iso2code =  "TR" if countrycode == "TUR" & iso2code == ""
    replace iso2code =  "TV" if countrycode == "TUV" & iso2code == ""
    replace iso2code =  "TZ" if countrycode == "TZA" & iso2code == ""
    replace iso2code =  "UG" if countrycode == "UGA" & iso2code == ""
    replace iso2code =  "UA" if countrycode == "UKR" & iso2code == ""
    replace iso2code =  "XT" if countrycode == "UMC" & iso2code == ""
    replace iso2code =  "UY" if countrycode == "URY" & iso2code == ""
    replace iso2code =  "US" if countrycode == "USA" & iso2code == ""
    replace iso2code =  "UZ" if countrycode == "UZB" & iso2code == ""
    replace iso2code =  "VC" if countrycode == "VCT" & iso2code == ""
    replace iso2code =  "VE" if countrycode == "VEN" & iso2code == ""
    replace iso2code =  "VI" if countrycode == "VIR" & iso2code == ""
    replace iso2code =  "VN" if countrycode == "VNM" & iso2code == ""
    replace iso2code =  "VU" if countrycode == "VUT" & iso2code == ""
    replace iso2code =  "1W" if countrycode == "WLD" & iso2code == ""
    replace iso2code =  "WS" if countrycode == "WSM" & iso2code == ""
    replace iso2code =  "A5" if countrycode == "XZN" & iso2code == ""
    replace iso2code =  "YE" if countrycode == "YEM" & iso2code == ""
    replace iso2code =  "ZA" if countrycode == "ZAF" & iso2code == ""
    replace iso2code =  "ZM" if countrycode == "ZMB" & iso2code == ""
    replace iso2code =  "ZW" if countrycode == "ZWE" & iso2code == ""



    order countryname countrycode iso2code region regioncode
    lab var region      "Region"
    lab var regioncode  "Region Code"
    lab var iso2code    "Country Code (ISO 2 digits)"

}

    return local time       "`t1'"

end


*******************************************************************************
* _query                                                                      *
*  v 14  	07/01/2014               by Joao Pedro Azevedo                        *
*		API update version 2
*  v 13.4  01jul2014               by Joao Pedro Azevedo                        *
*       long reshape
*  v 13.3  30june2014               by Joao Pedro Azevedo                        *
*       new error control (clear option)
*  v 13.2  24june2014               by Joao Pedro Azevedo                        *
*       new error control
* v 13.1  23june2014               by Joao Pedro Azevedo                        *
*       regional code, name and iso2code
* v 13  20june2014               by Joao Pedro Azevedo                        *
* 		fix the dups problem                                                    *
*       improve the error messages                                              *
*       update the list of indicators to 9960                                 *
* v 12  03jan2013               by Joao Pedro Azevedo                         *
*   update to 7349 indicators
*   return list include variable name and label
* v 11  24jul2012               by Joao Pedro Azevedo                       *
*   multiple indicators
* v 10  22jan2012               by Joao Pedro Azevedo                       *
*   changes on the dialogue box
*   changes to incorporate API update from December 15th 2011
*   list of indicators updated to 5383
*   incorporates Metadata
*   hyperlinks from metadata are not valid within Stata
*   terms of use of the data are now referenced in the hlp file
* v 9.2  30aug2011               by Joao Pedro Azevedo                       *
*   changes to incorporate API update from July 28th 2011
* v 9.1  07jul2011               by Joao Pedro Azevedo                       *
*   year option on indicators query fixed
* v 9.0  27jun2011               by Joao Pedro Azevedo                       *
*   list of indicators updated 4073
* v 8.0   22fev2011               by Joao Pedro Azevedo                       *
*   new server and query structure for indicators search                        *
*   latest; year(year1:year2) options included                                  *
* v 7.0   08fev2011               by Joao Pedro Azevedo                       *
*   change ado file name                                                        *
* v 6.5   04fev2011               by Joao Pedro Azevedo                      *
*   replace _pecats.ado by _pecats2.ado
* v 6.4   03fev2011               by Joao Pedro Azevedo                      *
*   change error codes
* v 6.3   01fev2011               by Joao Pedro Azevedo                      *
*   region, regioinname, country iso2code now included
* v 6.0   31jan2011               by Joao Pedro Azevedo                      *
*   api server open to the Stata community
* v 5.0   12jan2011                 by Joao Pedro Azevedo                     *
*   change variable name in long format
* v 4.0   20dez2010                 by Joao Pedro Azevedo                     *
*   full list of countries and indicators
* v 3.0   15dez2010                 by Joao Pedro Azevedo                     *
*   rename wdi to wbopendata
* v 2.2   14dez2010                 by Joao Pedro Azevedo                     *
*   dialogue
* v 2.1   10dez2010                 by Joao Pedro Azevedo                     *
*   long option
* v 2.0   09dez2010                 by Joao Pedro Azevedo                     *
* v 1.0   02nov2010                 by Joao Pedro Azevedo                     *
*******************************************************************************
