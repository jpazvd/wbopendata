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

. sum

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 countryname |          0
 countrycode |          0
    iso2code |          0
      region |          0
  regioncode |          0
-------------+---------------------------------------------------------
indicatorn~e |          0
indicatorc~e |          0
      yr1960 |        160    2.07e+10    9.56e+10  -3.57e+09   9.90e+11
      yr1961 |        202    1.33e+10    6.96e+10  -4.21e+09   7.20e+11
      yr1962 |        187    1.41e+10    7.11e+10  -1.49e+09   6.80e+11
-------------+---------------------------------------------------------
      yr1963 |        182    1.60e+10    7.97e+10  -4.56e+09   7.50e+11
      yr1964 |        182    1.86e+10    9.22e+10  -.3620385   8.86e+11
      yr1965 |        187    2.09e+10    1.04e+11          0   1.04e+12
      yr1966 |        184    2.35e+10    1.14e+11  -1.562071   1.15e+12
      yr1967 |        189    2.18e+10    1.10e+11    -160289   1.08e+12
-------------+---------------------------------------------------------
      yr1968 |        184    2.17e+10    1.08e+11       -9.2   1.04e+12
      yr1969 |        190    2.34e+10    1.17e+11  -3.792529   1.21e+12
      yr1970 |        438    1.21e+10    8.98e+10   -2.61457   1.45e+12
      yr1971 |        458    1.23e+10    9.29e+10  -.7906073   1.55e+12
      yr1972 |        463    1.27e+10    9.49e+10   -1081485   1.61e+12
-------------+---------------------------------------------------------
      yr1973 |        461    1.42e+10    1.03e+11  -1.114195   1.73e+12
      yr1974 |        477    1.42e+10    1.04e+11  -1.34e+09   1.77e+12
      yr1975 |        482    1.52e+10    1.11e+11  -4.40e+08   1.93e+12
      yr1976 |        486    1.47e+10    1.09e+11  -3.081322   1.89e+12
      yr1977 |        499    1.58e+10    1.14e+11     -47190   2.04e+12
-------------+---------------------------------------------------------
      yr1978 |        524    1.79e+10    1.27e+11  -1.98e+09   2.28e+12
      yr1979 |        548    1.90e+10    1.34e+11  -3.12e+09   2.45e+12
      yr1980 |        587    1.92e+10    1.38e+11  -2.78e+09   2.64e+12
      yr1981 |        589    2.05e+10    1.46e+11  -4.23e+08   2.78e+12
      yr1982 |        696    1.97e+10    1.48e+11  -8.79e+09   3.03e+12
-------------+---------------------------------------------------------
      yr1983 |        664    2.30e+10    1.67e+11  -7.41e+09   3.35e+12
      yr1984 |        679    2.64e+10    1.92e+11  -6.76e+09   3.86e+12
      yr1985 |        693    3.06e+10    2.17e+11  -3.68e+10   4.38e+12
      yr1986 |        689    3.38e+10    2.38e+11  -2.55e+10   4.77e+12
      yr1987 |        714    3.67e+10    2.63e+11  -1.22e+10   5.33e+12
-------------+---------------------------------------------------------
      yr1988 |        698    4.38e+10    3.00e+11  -1.97e+10   5.93e+12
      yr1989 |        708    4.91e+10    3.23e+11  -2.43e+10   6.18e+12
      yr1990 |        849    4.95e+10    3.23e+11  -2.42e+10   6.42e+12
      yr1991 |        821    5.79e+10    3.66e+11  -1.67e+10   7.01e+12
      yr1992 |        876    6.46e+10    4.15e+11  -1.82e+10   8.01e+12
-------------+---------------------------------------------------------
      yr1993 |        870    8.02e+10    5.07e+11  -9.46e+10   9.12e+12
      yr1994 |        861    1.01e+11    6.20e+11  -3.18e+10   1.03e+13
      yr1995 |        897    1.59e+11    9.05e+11  -9.83e+10   1.14e+13
      yr1996 |        915    1.78e+11    1.02e+12  -1.03e+11   1.26e+13
      yr1997 |        906    1.99e+11    1.13e+12  -9.12e+10   1.37e+13
-------------+---------------------------------------------------------
      yr1998 |        878    2.21e+11    1.25e+12  -1.38e+11   1.48e+13
      yr1999 |        879    2.39e+11    1.36e+12  -1.20e+11   1.59e+13
      yr2000 |        992    2.34e+11    1.41e+12  -1.21e+11   1.73e+13
      yr2001 |        918    2.80e+11    1.62e+12  -1.59e+11   1.87e+13
      yr2002 |        960    2.98e+11    1.76e+12  -1.24e+11   2.05e+13
-------------+---------------------------------------------------------
      yr2003 |        938    3.49e+11    2.02e+12  -8.93e+10   2.25e+13
      yr2004 |        913    4.28e+11    2.33e+12  -9.02e+10   2.48e+13
      yr2005 |        988    4.57e+11    2.55e+12  -4.05e+11   2.83e+13
      yr2006 |        984    5.37e+11    2.95e+12  -1.77e+11   3.46e+13
      yr2007 |      1,018    6.33e+11    3.44e+12  -1.48e+11   4.03e+13
-------------+---------------------------------------------------------
      yr2008 |      1,018    7.22e+11    3.94e+12  -1.15e+11   4.75e+13
      yr2009 |      1,010    8.15e+11    4.55e+12  -8.72e+10   6.10e+13
      yr2010 |      1,099    8.81e+11    5.06e+12  -1.86e+11   7.26e+13
      yr2011 |      1,024    1.08e+12    6.04e+12  -4.55e+11   8.52e+13
      yr2012 |      1,023    1.19e+12    6.73e+12  -1.76e+11   9.74e+13
-------------+---------------------------------------------------------
      yr2013 |      1,042    1.29e+12    7.40e+12  -7.01e+11   1.11e+14
      yr2014 |      1,061    1.39e+12    8.06e+12  -3.04e+11   1.23e+14
      yr2015 |      1,035    1.56e+12    9.13e+12  -8.40e+11   1.39e+14
      yr2016 |        918    1.81e+12    1.06e+13  -4.44e+11   1.60e+14
      yr2017 |        662    2.68e+12    1.36e+13  -2.22e+11   1.78e+14
</samp></pre>
        # Example 2

       Download all WDI indicators of particular topic
		
<pre id="stlog-3" class="stlog"><samp>. wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear

. sum

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 countryname |          0
 countrycode |          0
    iso2code |          0
      region |          0
  regioncode |          0
-------------+---------------------------------------------------------
indicatorn~e |          0
indicatorc~e |          0
      yr1960 |      2,184    3.49e+08    1.97e+09  -8.01e+07   3.20e+10
      yr1961 |      2,287    4.07e+08    2.29e+09  -1.92e+08   3.84e+10
      yr1962 |      2,523    3.81e+08    2.21e+09  -6.32e+07   3.80e+10
-------------+---------------------------------------------------------
      yr1963 |      2,489    4.10e+08    2.40e+09  -1.80e+07   4.10e+10
      yr1964 |      2,614    4.00e+08    2.38e+09  -3.49e+08   4.04e+10
      yr1965 |      2,817    3.95e+08    2.42e+09  -5.78e+08   4.27e+10
      yr1966 |      2,868    3.92e+08    2.40e+09  -1.34e+08   4.19e+10
      yr1967 |      3,366    3.37e+08    2.28e+09  -1.01e+07   4.28e+10
-------------+---------------------------------------------------------
      yr1968 |      3,206    3.37e+08    2.16e+09   -9120000   3.94e+10
      yr1969 |      3,654    2.76e+08    1.87e+09  -1.34e+07   3.74e+10
      yr1970 |      4,303    2.48e+08    1.82e+09  -1.50e+07   3.95e+10
      yr1971 |      4,540    2.47e+08    1.85e+09  -1.50e+07   4.19e+10
      yr1972 |      4,931    2.25e+08    1.71e+09  -1.07e+07   4.05e+10
-------------+---------------------------------------------------------
      yr1973 |      4,824    2.71e+08    2.04e+09  -2.50e+07   4.69e+10
      yr1974 |      5,051    3.33e+08    2.53e+09  -3.50e+07   5.69e+10
      yr1975 |      5,209    3.85e+08    2.92e+09  -2.30e+07   6.47e+10
      yr1976 |      5,273    3.60e+08    2.73e+09  -4.10e+07   6.06e+10
      yr1977 |      5,748    3.31e+08    2.53e+09  -5.60e+07   5.82e+10
-------------+---------------------------------------------------------
      yr1978 |      5,441    3.93e+08    2.86e+09  -6.40e+07   6.79e+10
      yr1979 |      5,615    4.26e+08    2.98e+09  -7.18e+07   6.81e+10
      yr1980 |      5,903    4.53e+08    3.23e+09  -3.30e+07   7.48e+10
      yr1981 |      5,983    4.46e+08    3.17e+09  -3.10e+07   7.47e+10
      yr1982 |      6,293    4.08e+08    2.93e+09  -3.60e+07   6.94e+10
-------------+---------------------------------------------------------
      yr1983 |      6,108    4.01e+08    2.82e+09  -2.20e+07   6.68e+10
      yr1984 |      6,193    4.09e+08    2.93e+09  -4.98e+07   7.10e+10
      yr1985 |      6,229    4.37e+08    3.09e+09  -5.60e+07   7.46e+10
      yr1986 |      6,338    4.47e+08    3.04e+09  -3.60e+07   7.17e+10
      yr1987 |      6,630    4.42e+08    2.99e+09  -3.70e+07   6.85e+10
-------------+---------------------------------------------------------
      yr1988 |      6,476    4.72e+08    3.11e+09  -5.70e+07   6.84e+10
      yr1989 |      6,588    4.82e+08    3.21e+09  -7.60e+07   7.09e+10
      yr1990 |      7,371    5.48e+08    3.72e+09  -1.40e+08   8.13e+10
      yr1991 |      7,818    5.58e+08    3.76e+09  -9.02e+07   8.31e+10
      yr1992 |      8,331    4.91e+08    3.41e+09  -4.48e+08   7.74e+10
-------------+---------------------------------------------------------
      yr1993 |      8,292    4.54e+08    3.17e+09  -1.82e+08   7.33e+10
      yr1994 |      8,456    4.79e+08    3.34e+09  -1.14e+08   7.55e+10
      yr1995 |      8,587    4.49e+08    3.10e+09  -3.43e+08   6.66e+10
      yr1996 |      8,637    4.13e+08    2.89e+09  -4.83e+08   6.65e+10
      yr1997 |      8,851    3.61e+08    2.61e+09  -2.59e+08   6.40e+10
-------------+---------------------------------------------------------
      yr1998 |      8,670    3.95e+08    2.81e+09  -1.02e+08   6.85e+10
      yr1999 |      8,779    4.02e+08    2.87e+09  -1.58e+08   6.86e+10
      yr2000 |      9,145    3.71e+08    2.72e+09  -1.98e+08   6.90e+10
      yr2001 |      9,026    4.04e+08    2.97e+09  -1.32e+08   7.42e+10
      yr2002 |      9,360    4.39e+08    3.33e+09  -1.36e+08   8.56e+10
-------------+---------------------------------------------------------
      yr2003 |      9,154    5.12e+08    3.73e+09  -1.00e+09   8.65e+10
      yr2004 |      9,216    5.42e+08    3.94e+09  -3.19e+08   8.95e+10
      yr2005 |      9,252    7.46e+08    5.56e+09  -3.14e+08   1.15e+11
      yr2006 |      9,472    7.20e+08    5.40e+09  -4.54e+08   1.11e+11
      yr2007 |      9,778    6.30e+08    4.87e+09  -6.85e+08   1.08e+11
-------------+---------------------------------------------------------
      yr2008 |      9,591    7.17e+08    5.52e+09  -7.48e+08   1.26e+11
      yr2009 |      9,501    7.16e+08    5.62e+09  -5.13e+08   1.27e+11
      yr2010 |      9,528    7.32e+08    5.77e+09  -7.12e+08   1.31e+11
      yr2011 |      9,529    7.77e+08    6.08e+09  -6.17e+08   1.42e+11
      yr2012 |      9,944    7.14e+08    5.73e+09  -8.80e+08   1.34e+11
-------------+---------------------------------------------------------
      yr2013 |      9,823    7.93e+08    6.38e+09  -8.21e+08   1.51e+11
      yr2014 |      9,536    7.96e+08    6.49e+09  -1.19e+09   1.62e+11
      yr2015 |      9,610    7.70e+08    6.41e+09  -9.99e+08   1.53e+11
      yr2016 |      9,168    8.55e+08    6.87e+09  -1.21e+09   1.58e+11
      yr2017 |      1,187    1.06e+07    1.32e+08  -1.46e+07   2.49e+09
</samp></pre>
        # Example 3

        Download specific indicator [ag.agr.trac.no]

<pre id="stlog-4" class="stlog"><samp>. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machiner
&gt; y, tractors) clear



Metadata: ag.agr.trac.no

-------------------------------------------------------------------------------------
    
    Name: Agricultural machinery, tractors
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Agricultural machinery refers to the number of wheel and crawler
    tractors (excluding garden tractors) in use in agriculture at the end of the
    calendar year specified or during the first quarter of the following year.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: Food and Agriculture Organization, electronic files and
    web site.
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Agriculture &amp; Rural Development
 
 ------------------------------------------------------------------------------------



. sum

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 countryname |          0
 countrycode |          0
    iso2code |          0
      region |          0
  regioncode |          0
-------------+---------------------------------------------------------
indicatorn~e |          0
indicatorc~e |          0
      yr1960 |          0
      yr1961 |        200    329782.8     1417677          1    9934791
      yr1962 |        200    344303.5     1469017          1   1.03e+07
-------------+---------------------------------------------------------
      yr1963 |        200    359831.2     1523524          1   1.08e+07
      yr1964 |        200    375212.7     1577863          1   1.12e+07
      yr1965 |        200      389204     1625543          1   1.16e+07
      yr1966 |        199    426543.6     1781885          2   1.26e+07
      yr1967 |        199    440548.7     1821841          2   1.30e+07
-------------+---------------------------------------------------------
      yr1968 |        199    454416.5     1860666          2   1.33e+07
      yr1969 |        196    476322.7     1914380          2   1.37e+07
      yr1970 |        195    484328.5     1937244          3   1.38e+07
      yr1971 |        192    506079.3     1987549          3   1.41e+07
      yr1972 |        186    536150.8     2049520          3   1.44e+07
-------------+---------------------------------------------------------
      yr1973 |        186    552354.4     2089598          3   1.48e+07
      yr1974 |        185    576802.6     2155404          4   1.53e+07
      yr1975 |        182    602941.6     2192350          4   1.56e+07
      yr1976 |        181    626212.5     2244596          4   1.60e+07
      yr1977 |        180    654243.4     2308622          4   1.65e+07
-------------+---------------------------------------------------------
      yr1978 |        177    690802.1     2383787          4   1.71e+07
      yr1979 |        177    715000.1     2425324          1   1.75e+07
      yr1980 |        178    741255.1     2501614          1   1.82e+07
      yr1981 |        178      760268     2535275          1   1.85e+07
      yr1982 |        177    784378.1     2593017          1   1.90e+07
-------------+---------------------------------------------------------
      yr1983 |        175    811651.2     2650847          1   1.93e+07
      yr1984 |        174    836505.3     2702855          1   1.97e+07
      yr1985 |        173    866298.4     2780418          1   2.03e+07
      yr1986 |        172    892912.5     2837918          1   2.07e+07
      yr1987 |        171    917109.6     2890037          1   2.11e+07
-------------+---------------------------------------------------------
      yr1988 |        169    937991.4     2917214          1   2.12e+07
      yr1989 |        169    955998.5     2950038          1   2.15e+07
      yr1990 |        167    959717.4     2907476          1   2.12e+07
      yr1991 |        164    975449.4     2905196          1   2.11e+07
      yr1992 |        186     1089559     3120610          1   2.37e+07
-------------+---------------------------------------------------------
      yr1993 |        188     1085762     3129406          1   2.39e+07
      yr1994 |        187     1098624     3154886          1   2.40e+07
      yr1995 |        188     1099381     3158440          1   2.41e+07
      yr1996 |        182     1134329     3198923          1   2.42e+07
      yr1997 |        174     1191418     3275436          1   2.43e+07
-------------+---------------------------------------------------------
      yr1998 |        163     1253731     3380509          1   2.44e+07
      yr1999 |        154     1324340     3494289          1   2.47e+07
      yr2000 |        152     1357553     3564601          1   2.51e+07
      yr2001 |         78    908622.1     2504048          8   1.31e+07
      yr2002 |         84      852358     2450340          1   1.33e+07
-------------+---------------------------------------------------------
      yr2003 |         75    803340.3     2170558          1   1.15e+07
      yr2004 |         74    808908.1     2169429          1   1.14e+07
      yr2005 |         68    878856.2     2247605          1   1.14e+07
      yr2006 |         51    357399.6    988077.1          1    5163541
      yr2007 |         43    262114.4    762531.2          1    4389812
-------------+---------------------------------------------------------
      yr2008 |         27      152855    351220.4          1    1566340
      yr2009 |          8    439531.4      570105        353    1577290
      yr2010 |          0
      yr2011 |          0
      yr2012 |          0
-------------+---------------------------------------------------------
      yr2013 |          0
      yr2014 |          0
      yr2015 |          0
      yr2016 |          0
      yr2017 |          0
</samp></pre>
        # Example 4

        Download specific indicator and report in long format [ag.agr.trac.no]

<pre id="stlog-5" class="stlog"><samp>. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machiner
&gt; y, tractors) long clear



Metadata: ag.agr.trac.no

-------------------------------------------------------------------------------------
    
    Name: Agricultural machinery, tractors
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Agricultural machinery refers to the number of wheel and crawler
    tractors (excluding garden tractors) in use in agriculture at the end of the
    calendar year specified or during the first quarter of the following year.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: Food and Agriculture Organization, electronic files and
    web site.
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Agriculture &amp; Rural Development
 
 ------------------------------------------------------------------------------------



. sum

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
 countryname |          0
 countrycode |          0
    iso2code |          0
      region |          0
  regioncode |          0
-------------+---------------------------------------------------------
        year |     15,312      1988.5    16.74122       1960       2017
ag_agr_tra~o |      7,783    746185.7     2505168          1   2.51e+07
</samp></pre>
        # Example 5

        Download specific indicator for specific countries, and report in long 
		format [ag.agr.trac.no]

<pre id="stlog-6" class="stlog"><samp>. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear



Metadata: sp.pop.0610.fe.un

-------------------------------------------------------------------------------------
    
    Name: Population, ages 6-10, female
 
  -----------------------------------------------------------------------------------
    
    Source: Education Statistics
 
 ------------------------------------------------------------------------------------
    
    Source Note: Population, ages 6-10, female is the total number of females age
    6-10.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: UNESCO Institute for Statistics (Derived)
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Education
 
 ------------------------------------------------------------------------------------



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
        # Example 6

        Download specific indicator, for specific countries and year, and report 
		in long format [ag.agr.trac.no]

<pre id="stlog-7" class="stlog"><samp>. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) ///
&gt;                         year(2000:2010) clear  long



Metadata: sp.pop.0610.fe.un

-------------------------------------------------------------------------------------
    
    Name: Population, ages 6-10, female
 
  -----------------------------------------------------------------------------------
    
    Source: Education Statistics
 
 ------------------------------------------------------------------------------------
    
    Source Note: Population, ages 6-10, female is the total number of females age
    6-10.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: UNESCO Institute for Statistics (Derived)
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Education
 
 ------------------------------------------------------------------------------------



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
        # Example 7

        Map latest values of global mobile phone coverage

<pre id="stlog-8" class="stlog"><samp>.    qui tempfile tmp

. wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest



Metadata: it.cel.sets.p2

-------------------------------------------------------------------------------------
    
    Name: Mobile cellular subscriptions (per 100 people)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Mobile cellular telephone subscriptions are subscriptions to a
    public mobile telephone service that provide access to the PSTN using cellular
    technology. The indicator includes (and is split into) the number of postpaid
    subscriptions, and the number of active prepaid accounts (i.e. that have been
    used during the last three months"}). The indicator applies to all mobile
    cellular subscriptions that offer voice communications. It excludes
    subscriptions via data cards or USB modems, subscriptions to public mobile data
    services, private trunked mobile radio, telepoint, radio paging and telemetry
    services.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: International Telecommunication Union, World
    Telecommunication/ICT Development Report and database.
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Infrastructure
 
 ------------------------------------------------------------------------------------



. local labelvar "`r(varlabel1)'"

. sort countrycode

. save `tmp', replace
(note: file C:\Users\wb255520\AppData\Local\Temp\ST_ea20_000003.tmp not found)
file C:\Users\wb255520\AppData\Local\Temp\ST_ea20_000003.tmp saved

. qui sysuse world-d, clear

. qui merge countrycode using `tmp'

. qui sum year

. local avg = string(`r(mean)',"%16.1f")

. spmap  it_cel_sets_p2 using "world-c.dta", id(_ID)                                 
&gt;  ///
&gt;                 clnumber(20) fcolor(Reds2) ocolor(none ..)                         
&gt;          ///
&gt;                 title("`labelvar'", size(*1.2))         ///
&gt;                 legstyle(3) legend(ring(1) position(3))                            
&gt;          ///
&gt;                 note("Source: World Development Indicators (latest available year: 
&gt; `avg') using  Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank
&gt;  databases, Statistical Software Components S457234 Boston College Department of Ec
&gt; onomics.")
</samp></pre>
<figure id="fig-8">
<a href="wbopendata_8.png"><img alt="wbopendata_8.png" src="wbopendata_8.png"/></a>
</figure>
        # Example 8

        Bencharmk latest poverty levels by percapital income, highlighting single 
		country

<pre id="stlog-9" class="stlog"><samp>. wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest



Metadata: si.pov.dday

-------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the
    population living on less than $1.90 a day at 2011 international prices. As a
    result of revisions in PPP exchange rates, poverty rates for individual
    countries cannot be compared with poverty rates reported in earlier editions.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on
    primary household survey data obtained from government statistical agencies and
    World Bank country departments. Data for high-income economies are from the
    Luxembourg Income Study database. For more information and methodology, please
    see PovcalNet (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ------------------------------------------------------------------------------------





Metadata: ny.gdp.pcap.pp.kd

-------------------------------------------------------------------------------------
    
    Name: GDP per capita, PPP (constant 2011 international $)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: GDP per capita based on purchasing power parity (PPP"}). PPP GDP
    is gross domestic product converted to international dollars using purchasing
    power parity rates. An international dollar has the same purchasing power over
    GDP as the U.S. dollar has in the United States. GDP at purchaser's prices is
    the sum of gross value added by all resident producers in the economy plus any
    product taxes and minus any subsidies not included in the value of the
    products. It is calculated without making deductions for depreciation of
    fabricated assets or for depletion and degradation of natural resources. Data
    are in constant 2011 international dollars.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: World Bank, International Comparison Program database.
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Economy &amp; Growth
 
 ------------------------------------------------------------------------------------



. linewrap , longstring("`r(varlabel1)'") maxlength(52) name(ylabel)

. linewrap , longstring("`r(varlabel2)'") maxlength(52) name(xlabel)

. twoway ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.2)) ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd if string(si_pov_dday) == "35.8", //
&gt; /
&gt;                 msize(*.8) mlabel(countryname)) ///
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

        # Exercise 9

        Benchmark epsiodes of poveryt reduction by Region

<pre id="stlog-10" class="stlog"><samp>. wbopendata, indicator(si.pov.dday ) clear long



Metadata: si.pov.dday

-------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the
    population living on less than $1.90 a day at 2011 international prices. As a
    result of revisions in PPP exchange rates, poverty rates for individual
    countries cannot be compared with poverty rates reported in earlier editions.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on
    primary household survey data obtained from government statistical agencies and
    World Bank country departments. Data for high-income economies are from the
    Luxembourg Income Study database. For more information and methodology, please
    see PovcalNet (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ------------------------------------------------------------------------------------



.    drop if  si_pov_dday == .
(13,710 observations deleted)

.    sort  countryname year

.    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[
&gt; _n-1])
(175 missing values generated)

.    encode regioncode, gen(reg)

.    encode countryname, gen(reg2)

.    keep if region == "Aggregates"
(1,432 observations deleted)

.    alorenz diff_pov, gp points(20) xdecrease markvar(reg2)                    ///
&gt;        ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional episodes o
&gt; f poverty reduction (%)")   ///
&gt;        legend(off) title("Poverty Reduction")                                      
&gt;       ///
&gt;        legend(off) note("Source: World Development Indicators using Azevedo, J.P. (
&gt; 2011) wbopendata: Stata module to " "access World Bank databases, Statistical Softw
&gt; are Components S457234 Boston College Department of Economics.", size(*.7))
</samp></pre>
<figure id="fig-10">
<a href="wbopendata_10.png"><img alt="wbopendata_10.png" src="wbopendata_10.png"/></a>
</figure>

        # Exercise 10

        Benchmark MDG progress using 2008 as cutoff value

<pre id="stlog-11" class="stlog"><samp>. wbopendata, indicator(si.pov.dday ) clear long



Metadata: si.pov.dday

-------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the
    population living on less than $1.90 a day at 2011 international prices. As a
    result of revisions in PPP exchange rates, poverty rates for individual
    countries cannot be compared with poverty rates reported in earlier editions.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on
    primary household survey data obtained from government statistical agencies and
    World Bank country departments. Data for high-income economies are from the
    Luxembourg Income Study database. For more information and methodology, please
    see PovcalNet (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ------------------------------------------------------------------------------------



.    drop if  si_pov_dday == .
(13,710 observations deleted)

.    sort  countryname year

.    keep if region == "Aggregates"
(1,432 observations deleted)

.    bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[
&gt; _n-1])
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
&gt;            title("MDG 1 - 1.9 USD")                                         ///
&gt;            note("Source: World Development Indicators (latest available year: 2008)
&gt;  using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databa
&gt; ses, Statistical Software Components S457234 Boston College Department of Economics
&gt; .", size(*.7))
</samp></pre>
<figure id="fig-11">
<a href="wbopendata_11.png"><img alt="wbopendata_11.png" src="wbopendata_11.png"/></a>
</figure>

        # Exercise 11

        Bencharmk latest poverty levels by percapital income, highlighting regional 
		averages

<pre id="stlog-12" class="stlog"><samp>. wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest



Metadata: si.pov.dday

-------------------------------------------------------------------------------------
    
    Name: Poverty headcount ratio at $1.90 a day (2011 PPP) (% of population)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: Poverty headcount ratio at $1.90 a day is the percentage of the
    population living on less than $1.90 a day at 2011 international prices. As a
    result of revisions in PPP exchange rates, poverty rates for individual
    countries cannot be compared with poverty rates reported in earlier editions.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: World Bank, Development Research Group. Data are based on
    primary household survey data obtained from government statistical agencies and
    World Bank country departments. Data for high-income economies are from the
    Luxembourg Income Study database. For more information and methodology, please
    see PovcalNet (http://iresearch.worldbank.org/PovcalNet/index.htm"}"}).
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Poverty
 
 ------------------------------------------------------------------------------------
      
    Topics: Aid Effectiveness
 
 ------------------------------------------------------------------------------------
      
    Topics: Climate Change
 
 ------------------------------------------------------------------------------------





Metadata: ny.gdp.pcap.pp.kd

-------------------------------------------------------------------------------------
    
    Name: GDP per capita, PPP (constant 2011 international $)
 
  -----------------------------------------------------------------------------------
    
    Source: World Development Indicators
 
 ------------------------------------------------------------------------------------
    
    Source Note: GDP per capita based on purchasing power parity (PPP"}). PPP GDP
    is gross domestic product converted to international dollars using purchasing
    power parity rates. An international dollar has the same purchasing power over
    GDP as the U.S. dollar has in the United States. GDP at purchaser's prices is
    the sum of gross value added by all resident producers in the economy plus any
    product taxes and minus any subsidies not included in the value of the
    products. It is calculated without making deductions for depreciation of
    fabricated assets or for depletion and degradation of natural resources. Data
    are in constant 2011 international dollars.
 
 ------------------------------------------------------------------------------------
    
    Source Organization: World Bank, International Comparison Program database.
 
 ------------------------------------------------------------------------------------
    
      
    Topics: Economy &amp; Growth
 
 ------------------------------------------------------------------------------------



. 
. local time "$S_FNDATE"

. 
. linewrap , longstring("`r(varlabel1)'") maxlength(52) name(ylabel)

. linewrap , longstring("`r(varlabel2)'") maxlength(52) name(xlabel)

. 
. graph twoway ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.3)) ///
&gt;         (scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8
&gt; ) mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
&gt;         (lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
&gt;                 legend(off) ///
&gt;                 xtitle("`r(xlabel1)'" "`r(xlabel2)'" "`r(xlabel3)'") ///
&gt;                 ytitle("`r(ylabel1)'" "`r(ylabel2)'" "`r(ylabel3)'") ///           
&gt;      
&gt;                 note("Source: World Development Indicators (latest available year a
&gt; s off `time') using Azevedo, J.P. (2011) wbopendata: Stata" "module to access World
&gt;  Bank databases, Statistical Software Components S457234 Boston College Department 
&gt; of Economics.", size(*.7))
</samp></pre>
<figure id="fig-12">
<a href="wbopendata_12.png"><img alt="wbopendata_12.png" src="wbopendata_12.png"/></a>
</figure>
