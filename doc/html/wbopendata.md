        ### Version Control
	
<pre id="stlog-1" class="stlog"><samp>. which wbopendata
.\w\wbopendata.ado
*!  v 15.1          04Mar2019               by Joao Pedro Azevedo 

. which _query
.\_\_query.ado
*! v 15.1       04Mar2019               by Joao Pedro Azevedo                   
&gt;   

. which wbopendata.sthlp
.\w\wbopendata.sthlp
</samp></pre>
        ### Example 1

        Download all WDI indiators for a single country (i.e. China)

<pre id="stlog-2" class="stlog"><samp>. wbopendata, country(chn - China) clear

. tab indicatorcode in 1/10

           Indicator Code |      Freq.     Percent        Cum.
--------------------------+-----------------------------------
        ST.INT.RCPT.XP.ZS |          1       10.00       10.00
           ST.INT.TRNR.CD |          1       10.00       20.00
           ST.INT.TRNX.CD |          1       10.00       30.00
           ST.INT.TVLR.CD |          1       10.00       40.00
           ST.INT.TVLX.CD |          1       10.00       50.00
           ST.INT.XPND.CD |          1       10.00       60.00
        ST.INT.XPND.MP.ZS |          1       10.00       70.00
        TG.VAL.TOTL.GD.ZS |          1       10.00       80.00
        TM.QTY.MRCH.XD.WD |          1       10.00       90.00
        TM.TAX.MANF.BC.ZS |          1       10.00      100.00
--------------------------+-----------------------------------
                    Total |         10      100.00
</samp></pre>
        ### Example 2

       Download all WDI indicators of particular topic
		
<pre id="stlog-3" class="stlog"><samp>. wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear

. tab indicatorcode in 1/10

   Indicator Code |      Freq.     Percent        Cum.
------------------+-----------------------------------
   DC.DAC.SVNL.CD |          1       10.00       10.00
   DC.DAC.SWEL.CD |          1       10.00       20.00
   DC.DAC.TOTL.CD |          1       10.00       30.00
   DC.DAC.USAL.CD |          1       10.00       40.00
   DT.DIS.IDAG.CD |          1       10.00       50.00
   DT.DOD.MDRI.CD |          1       10.00       60.00
   DT.NFL.FAOG.CD |          1       10.00       70.00
   DT.NFL.IAEA.CD |          1       10.00       80.00
   DT.NFL.IFAD.CD |          1       10.00       90.00
   DT.NFL.ILOG.CD |          1       10.00      100.00
------------------+-----------------------------------
            Total |         10      100.00
</samp></pre>
        ### Example 3

        Download specific indicator [ag.agr.trac.no]

<pre id="stlog-4" class="stlog"><samp>. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural mac
&gt; hinery, tractors) clear



Metadata: ag.agr.trac.no

--------------------------------------------------------------------------------
    
    Name: Agricultural machinery, tractors
 
  ------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 -------------------------------------------------------------------------------
    
    Source Note: Agricultural machinery refers to the number of wheel and
    crawler tractors (excluding garden tractors) in use in agriculture at the
    end of the calendar year specified or during the first quarter of the
    following year.
 
 -------------------------------------------------------------------------------
    
    Source Organization: Food and Agriculture Organization, electronic files
    and web site.
 
 -------------------------------------------------------------------------------
    
      
    Topics: Agriculture &amp; Rural Development
 
 -------------------------------------------------------------------------------



. tab countryname in 1/10

                           Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                            Afghanistan |          1       10.00       10.00
                                Albania |          1       10.00       20.00
                         American Samoa |          1       10.00       30.00
                                Andorra |          1       10.00       40.00
                                 Angola |          1       10.00       50.00
                             Arab World |          1       10.00       60.00
                              Argentina |          1       10.00       70.00
                                Armenia |          1       10.00       80.00
                                  Aruba |          1       10.00       90.00
                   United Arab Emirates |          1       10.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         10      100.00
</samp></pre>
        ### Example 4

        Download specific indicator and report in long format [ag.agr.trac.no]

<pre id="stlog-5" class="stlog"><samp>. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural mac
&gt; hinery, tractors) long clear



Metadata: ag.agr.trac.no

--------------------------------------------------------------------------------
    
    Name: Agricultural machinery, tractors
 
  ------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 -------------------------------------------------------------------------------
    
    Source Note: Agricultural machinery refers to the number of wheel and
    crawler tractors (excluding garden tractors) in use in agriculture at the
    end of the calendar year specified or during the first quarter of the
    following year.
 
 -------------------------------------------------------------------------------
    
    Source Organization: Food and Agriculture Organization, electronic files
    and web site.
 
 -------------------------------------------------------------------------------
    
      
    Topics: Agriculture &amp; Rural Development
 
 -------------------------------------------------------------------------------



. tab year in 1/10

       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       1960 |          1       10.00       10.00
       1961 |          1       10.00       20.00
       1962 |          1       10.00       30.00
       1963 |          1       10.00       40.00
       1964 |          1       10.00       50.00
       1965 |          1       10.00       60.00
       1966 |          1       10.00       70.00
       1967 |          1       10.00       80.00
       1968 |          1       10.00       90.00
       1969 |          1       10.00      100.00
------------+-----------------------------------
      Total |         10      100.00
</samp></pre>
        ### Example 5

        Download specific indicator for specific countries, and report in long 
		format [ag.agr.trac.no]

<pre id="stlog-6" class="stlog"><samp>. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear



Metadata: sp.pop.0610.fe.un

--------------------------------------------------------------------------------
    
    Name: Population, ages 6-10, female
 
  ------------------------------------------------------------------------------
    
    Source: Education Statistics
 
 -------------------------------------------------------------------------------
    
    Source Note: Population, ages 6-10, female is the total number of females
    age 6-10.
 
 -------------------------------------------------------------------------------
    
    Source Organization: UNESCO Institute for Statistics (Derived)
 
 -------------------------------------------------------------------------------
    
      
    Topics: Education
 
 -------------------------------------------------------------------------------



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
        ### Example 6

        Download specific indicator, for specific countries and year, and report 
		in long format [ag.agr.trac.no]

<pre id="stlog-7" class="stlog"><samp>. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) ///
&gt;                         year(2000:2010) clear  long



Metadata: sp.pop.0610.fe.un

--------------------------------------------------------------------------------
    
    Name: Population, ages 6-10, female
 
  ------------------------------------------------------------------------------
    
    Source: Education Statistics
 
 -------------------------------------------------------------------------------
    
    Source Note: Population, ages 6-10, female is the total number of females
    age 6-10.
 
 -------------------------------------------------------------------------------
    
    Source Organization: UNESCO Institute for Statistics (Derived)
 
 -------------------------------------------------------------------------------
    
      
    Topics: Education
 
 -------------------------------------------------------------------------------



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
        ### Example 7

        Map latest values of global mobile phone coverage

