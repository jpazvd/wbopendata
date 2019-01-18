<pre id="stlog-1" class="stlog"><samp>. which wbopendata
.\w\wbopendata.ado
*! v14.1        19Jan2019               by Joao Pedro Azevedo 

. which _query
.\_\_query.ado
*! v 14.0       14Jan2019               by Joao Pedro Azevedo                     *

. which wbopendata.sthlp
.\w\wbopendata.sthlp
</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-2" class="stlog"><samp>. wbopendata, country(chn - China) clear
</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-3" class="stlog"><samp>. wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear
</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-4" class="stlog"><samp>. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear



Metadata: ag.agr.trac.no

----------------------------------------------------------------------------------------------------------------------
    
    Name: Agricultural machinery, tractors
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Agricultural machinery refers to the number of wheel and crawler tractors (excluding garden
    tractors) in use in agriculture at the end of the calendar year specified or during the first quarter of the
    following year.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: Food and Agriculture Organization, electronic files and web site.
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Agriculture &amp; Rural Development
 
 ---------------------------------------------------------------------------------------------------------------------


</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-5" class="stlog"><samp>. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear



Metadata: ag.agr.trac.no

----------------------------------------------------------------------------------------------------------------------
    
    Name: Agricultural machinery, tractors
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Agricultural machinery refers to the number of wheel and crawler tractors (excluding garden
    tractors) in use in agriculture at the end of the calendar year specified or during the first quarter of the
    following year.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: Food and Agriculture Organization, electronic files and web site.
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Agriculture &amp; Rural Development
 
 ---------------------------------------------------------------------------------------------------------------------


</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-6" class="stlog"><samp>. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear



Metadata: sp.pop.0610.fe.un

----------------------------------------------------------------------------------------------------------------------
    
    Name: Population, ages 6-10, female
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: Education Statistics
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Population, ages 6-10, female is the total number of females age 6-10.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: UNESCO Institute for Statistics (Derived)
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Education
 
 ---------------------------------------------------------------------------------------------------------------------



. tab countryname 

   Country Name |      Freq.     Percent        Cum.
----------------+-----------------------------------
         Angola |          1       20.00       20.00
        Burundi |          1       20.00       40.00
Channel Islands |          1       20.00       60.00
        Denmark |          1       20.00       80.00
          Spain |          1       20.00      100.00
----------------+-----------------------------------
          Total |          5      100.00
</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-7" class="stlog"><samp>. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) year(2000:2010) clear  long



Metadata: sp.pop.0610.fe.un

----------------------------------------------------------------------------------------------------------------------
    
    Name: Population, ages 6-10, female
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: Education Statistics
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Population, ages 6-10, female is the total number of females age 6-10.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: UNESCO Institute for Statistics (Derived)
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Education
 
 ---------------------------------------------------------------------------------------------------------------------



. tab  year countryname 

           |                      Country Name
      Year |    Angola    Burundi  Channel..    Denmark      Spain |     Total
-----------+-------------------------------------------------------+----------
      2000 |         1          1          1          1          1 |         5 
      2001 |         1          1          1          1          1 |         5 
      2002 |         1          1          1          1          1 |         5 
      2003 |         1          1          1          1          1 |         5 
      2004 |         1          1          1          1          1 |         5 
      2005 |         1          1          1          1          1 |         5 
      2006 |         1          1          1          1          1 |         5 
      2007 |         1          1          1          1          1 |         5 
      2008 |         1          1          1          1          1 |         5 
      2009 |         1          1          1          1          1 |         5 
      2010 |         1          1          1          1          1 |         5 
-----------+-------------------------------------------------------+----------
     Total |        11         11         11         11         11 |        55 

. tab  year countryname if sp_pop_0610_fe_un != .

           |                Country Name
      Year |    Angola    Burundi    Denmark      Spain |     Total
-----------+--------------------------------------------+----------
      2000 |         1          1          1          1 |         4 
      2001 |         1          1          1          1 |         4 
      2002 |         1          1          1          1 |         4 
      2003 |         1          1          1          1 |         4 
      2004 |         1          1          1          1 |         4 
      2005 |         1          1          1          1 |         4 
      2006 |         1          1          1          1 |         4 
      2007 |         1          1          1          1 |         4 
      2008 |         1          1          1          1 |         4 
      2009 |         1          1          1          1 |         4 
      2010 |         1          1          1          1 |         4 
-----------+--------------------------------------------+----------
     Total |        11         11         11         11 |        44 
</samp></pre>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-8" class="stlog"><samp>.    qui tempfile tmp

. wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest



Metadata: it.cel.sets.p2

----------------------------------------------------------------------------------------------------------------------
    
    Name: Mobile cellular subscriptions (per 100 people)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Mobile cellular telephone subscriptions are subscriptions to a public mobile telephone service that
    provide access to the PSTN using cellular technology. The indicator includes (and is split into) the number of
    postpaid subscriptions, and the number of active prepaid accounts (i.e. that have been used during the last
    three months"}). The indicator applies to all mobile cellular subscriptions that offer voice communications. It
    excludes subscriptions via data cards or USB modems, subscriptions to public mobile data services, private
    trunked mobile radio, telepoint, radio paging and telemetry services.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: International Telecommunication Union, World Telecommunication/ICT Development Report and
    database.
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Infrastructure
 
 ---------------------------------------------------------------------------------------------------------------------



. local labelvar "`r(varlabel1)'"

. sort countrycode

. save `tmp', replace
(note: file C:\Users\wb255520\AppData\Local\Temp\ST_ea20_000003.tmp not found)
file C:\Users\wb255520\AppData\Local\Temp\ST_ea20_000003.tmp saved

. qui sysuse world-d, clear

. qui merge countrycode using `tmp'

. qui sum year

. local avg = string(`r(mean)',"%16.1f")

. spmap  it_cel_sets_p2 using "world-c.dta", id(_ID)                                  ///
&gt;                 clnumber(20) fcolor(Reds2) ocolor(none ..)                                  ///
&gt;                 title("`labelvar'", size(*1.2))         ///
&gt;                 legstyle(3) legend(ring(1) position(3))                                     ///
&gt;                 note("Source: World Development Indicators (latest available year: `avg') using  Azevedo, J.P. (2011
&gt; ) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College
&gt;  Department of Economics.")
</samp></pre>
<figure id="fig-8">
<a href="wbopendata_8.png"><img alt="wbopendata_8.png" src="wbopendata_8.png"/></a>
</figure>
        # Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-9" class="stlog"><samp>. wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest



Metadata: si.pov.dday

----------------------------------------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the population living on less than
    $1.90 a day at 2011 international prices. As a result of revisions in PPP exchange rates, poverty rates for
    individual countries cannot be compared with poverty rates reported in earlier editions.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on primary household survey data
    obtained from government statistical agencies and World Bank country departments. Data for high-income economies
    are from the Luxembourg Income Study database. For more information and methodology, please see PovcalNet
    (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ---------------------------------------------------------------------------------------------------------------------





Metadata: ny.gdp.pcap.pp.kd

----------------------------------------------------------------------------------------------------------------------
    
    Name: GDP per capita, PPP (constant 2011 international $)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: GDP per capita based on purchasing power parity (PPP"}). PPP GDP is gross domestic product
    converted to international dollars using purchasing power parity rates. An international dollar has the same
    purchasing power over GDP as the U.S. dollar has in the United States. GDP at purchaser's prices is the sum of
    gross value added by all resident producers in the economy plus any product taxes and minus any subsidies not
    included in the value of the products. It is calculated without making deductions for depreciation of fabricated
    assets or for depletion and degradation of natural resources. Data are in constant 2011 international dollars.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: World Bank, International Comparison Program database.
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Economy &amp; Growth
 
 ---------------------------------------------------------------------------------------------------------------------



. 
. linewrap , longstring("`r(varlabel1)'") maxlength(52) name(ylabel)

. linewrap , longstring("`r(varlabel2)'") maxlength(52) name(xlabel)

. 
. twoway ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.2)) ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd if string(si_pov_dday) == "35.8", msize(*.8) mlabel(countryname)) ///
&gt;         (lowess si_pov_dday ny_gdp_pcap_pp_kd) ///
&gt;                 if regioncode != "NA" ///
&gt;                 , legend(off) ///
&gt;                 xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
&gt;                 ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///
&gt;                 note("Source: `r(source1)' using WBOPENDATA")
</samp></pre>
<figure id="fig-9">
<a href="wbopendata_9.png"><img alt="wbopendata_9.png" src="wbopendata_9.png"/></a>
</figure>

        # Exercise 2

        Run a regression of price on milage and display the relation in a scatter plot.

<pre id="stlog-10" class="stlog"><samp>. wbopendata, indicator(si.pov.dday ) clear long



Metadata: si.pov.dday

----------------------------------------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the population living on less than
    $1.90 a day at 2011 international prices. As a result of revisions in PPP exchange rates, poverty rates for
    individual countries cannot be compared with poverty rates reported in earlier editions.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on primary household survey data
    obtained from government statistical agencies and World Bank country departments. Data for high-income economies
    are from the Luxembourg Income Study database. For more information and methodology, please see PovcalNet
    (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ---------------------------------------------------------------------------------------------------------------------



.    drop if  si_pov_dday == .
(13,710 observations deleted)

.    sort  countryname year

.    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
(175 missing values generated)

.    encode regioncode, gen(reg)

.    encode countryname, gen(reg2)

.    keep if region == "Aggregates"
(1,432 observations deleted)

.    alorenz diff_pov, gp points(20) fullview  xdecrease markvar(reg2)                                           ///
&gt;        ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional episodes of poverty reduction (%)")   ///
&gt;        legend(off) title("Poverty Reduction")                                                                  ///
&gt;        legend(off) note("Source: World Development Indicators using Azevedo, J.P. (2011) wbopendata: Stata module to
&gt;  " "access World Bank databases, Statistical Software Components S457234 Boston College Department of Economics.", s
&gt; ize(*.7))

Result:  Total

----------------------------------------------------------------------------------------------------------------------
percentil |                                               Result: Total                                               
e         |      maxdiff_pov     mean_diff_pov  ac_mean_diff_pov             speso          ac_speso          prop_pop
----------+-----------------------------------------------------------------------------------------------------------
        1 |            -3.30             -3.83             -3.83              7.00              7.00              4.43
        2 |            -2.50             -2.72             -3.24              8.00             15.00              5.06
        3 |            -2.00             -2.12             -2.85              8.00             23.00              5.06
        4 |            -1.70             -1.85             -2.59              8.00             31.00              5.06
        5 |            -1.53             -1.60             -2.39              8.00             39.00              5.06
        6 |            -1.33             -1.42             -2.22              8.00             47.00              5.06
        7 |            -1.23             -1.28             -2.09              8.00             55.00              5.06
        8 |            -1.05             -1.12             -1.96              8.00             63.00              5.06
        9 |            -0.93             -0.97             -1.85              8.00             71.00              5.06
       10 |            -0.87             -0.90             -1.77              7.00             78.00              4.43
       11 |            -0.67             -0.73             -1.67              8.00             86.00              5.06
       12 |            -0.57             -0.62             -1.58              8.00             94.00              5.06
       13 |            -0.37             -0.42             -1.49              8.00            102.00              5.06
       14 |            -0.30             -0.33             -1.40              8.00            110.00              5.06
       15 |            -0.20             -0.23             -1.33              8.00            118.00              5.06
       16 |            -0.07             -0.11             -1.25              8.00            126.00              5.06
       17 |             0.00             -0.02             -1.17              8.00            134.00              5.06
       18 |             0.07              0.03             -1.11              8.00            142.00              5.06
       19 |             0.47              0.23             -1.04              8.00            150.00              5.06
       20 |                               1.04             -0.93              8.00            158.00              5.06
----------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------
percentil |                    Result: Total                    
e         |      ac_prop_pop     prop_diff_pov  ac_prop_diff_pov
----------+-----------------------------------------------------
        1 |             4.43             18.22             18.22
        2 |             9.49             14.78             33.00
        3 |            14.56             11.53             44.53
        4 |            19.62             10.05             54.58
        5 |            24.68              8.73             63.30
        6 |            29.75              7.74             71.04
        7 |            34.81              6.95             77.99
        8 |            39.87              6.09             84.08
        9 |            44.94              5.30             89.38
       10 |            49.37              4.28             93.66
       11 |            54.43              3.97             97.63
       12 |            59.49              3.37            101.00
       13 |            64.56              2.30            103.30
       14 |            69.62              1.78            105.08
       15 |            74.68              1.27            106.35
       16 |            79.75              0.61            106.96
       17 |            84.81              0.10            107.06
       18 |            89.87             -0.17            106.89
       19 |            94.94             -1.22            105.67
       20 |           100.00             -5.67            100.00
----------------------------------------------------------------
</samp></pre>
<figure id="fig-10">
<a href="wbopendata_10.png"><img alt="wbopendata_10.png" src="wbopendata_10.png"/></a>
</figure>

        # Exercise 2

        Run a regression of price on milage and display the relation in a scatter plot.

<pre id="stlog-11" class="stlog"><samp>. wbopendata, indicator(si.pov.dday ) clear long



Metadata: si.pov.dday

----------------------------------------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the population living on less than
    $1.90 a day at 2011 international prices. As a result of revisions in PPP exchange rates, poverty rates for
    individual countries cannot be compared with poverty rates reported in earlier editions.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on primary household survey data
    obtained from government statistical agencies and World Bank country departments. Data for high-income economies
    are from the Luxembourg Income Study database. For more information and methodology, please see PovcalNet
    (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ---------------------------------------------------------------------------------------------------------------------



.    drop if  si_pov_dday == .
(13,710 observations deleted)

.    sort  countryname year

.    keep if region == "Aggregates"
(1,432 observations deleted)

.    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
(12 missing values generated)

.    gen baseline = si_pov_dday if year == 1990
(159 missing values generated)

.    sort countryname baseline

.    bysort countryname : replace baseline = baseline[1] if baseline == .
(148 real changes made)

.    gen mdg1 = baseline/2
(11 missing values generated)

.    gen present = si_pov_dday if year == 2008
(158 missing values generated)

.    sort countryname present

.    bysort countryname : replace present = present[1] if present == .
(158 real changes made)

.    gen target = ((baseline-mdg1)/(2008-1990))*(2015-1990)
(11 missing values generated)

.    sort countryname year

.    gen angel45x = .
(170 missing values generated)

.    gen angle45y = .
(170 missing values generated)

.    replace angel45x = 0 in 1
(1 real change made)

.    replace angle45y = 0 in 1
(1 real change made)

.    replace angel45x = 80 in 2
(1 real change made)

.    replace angle45y = 80 in 2
(1 real change made)

.    graph twoway ///
&gt;        (scatter present  target  if year == 2008, mlabel( countrycode))    ///
&gt;        (line  angle45y angel45x ),                                         ///
&gt;            legend(off) xtitle("Target for 2008")  ytitle(Present)          ///
&gt;            title("MDG 1b - 1.9 USD")                                         ///
&gt;            note("Source: World Development Indicators (latest available year: 2008) using Azevedo, J.P. (2011) wbope
&gt; ndata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston College Depart
&gt; ment of Economics.", size(*.7))
</samp></pre>
<figure id="fig-11">
<a href="wbopendata_11.png"><img alt="wbopendata_11.png" src="wbopendata_11.png"/></a>
</figure>

        # Exercise 2

        Run a regression of price on milage and display the relation in a scatter plot.

<pre id="stlog-12" class="stlog"><samp>. wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest



Metadata: si.pov.dday

----------------------------------------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the population living on less than
    $1.90 a day at 2011 international prices. As a result of revisions in PPP exchange rates, poverty rates for
    individual countries cannot be compared with poverty rates reported in earlier editions.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on primary household survey data
    obtained from government statistical agencies and World Bank country departments. Data for high-income economies
    are from the Luxembourg Income Study database. For more information and methodology, please see PovcalNet
    (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ---------------------------------------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ---------------------------------------------------------------------------------------------------------------------





Metadata: ny.gdp.pcap.pp.kd

----------------------------------------------------------------------------------------------------------------------
    
    Name: GDP per capita, PPP (constant 2011 international $)
 
  --------------------------------------------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Note: GDP per capita based on purchasing power parity (PPP"}). PPP GDP is gross domestic product
    converted to international dollars using purchasing power parity rates. An international dollar has the same
    purchasing power over GDP as the U.S. dollar has in the United States. GDP at purchaser's prices is the sum of
    gross value added by all resident producers in the economy plus any product taxes and minus any subsidies not
    included in the value of the products. It is calculated without making deductions for depreciation of fabricated
    assets or for depletion and degradation of natural resources. Data are in constant 2011 international dollars.
 
 ---------------------------------------------------------------------------------------------------------------------
    
    Source Organization: World Bank, International Comparison Program database.
 
 ---------------------------------------------------------------------------------------------------------------------
    
      
    Topics: Economy &amp; Growth
 
 ---------------------------------------------------------------------------------------------------------------------



. 
. local time "$S_FNDATE"

. 
. graph twoway ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.6)) ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8) mlabel(countryname)  mlabsize(*
&gt; .8)  mlabangle(25)) ///
&gt;         (lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
&gt;                 xtitle("`r(varlabel2)'") ///
&gt;                 ytitle("`r(varlabel1)'") ///
&gt;                 legend(off) ///
&gt;                 note("Source: World Development Indicators (latest available year as off `time') using Azevedo, J.P.
&gt;  (2011) wbopendata: Stata module to " "access World Bank databases, Statistical Software Components S457234 Boston C
&gt; ollege Department of Economics.", size(*.7))
</samp></pre>
<figure id="fig-12">
<a href="wbopendata_12.png"><img alt="wbopendata_12.png" src="wbopendata_12.png"/></a>
</figure>
