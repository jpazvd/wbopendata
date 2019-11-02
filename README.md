# WBOPENDATA: Stata module to access World Bank databases

## Description

wbopendata allows Stata users to download over 17,000 indicators from the World Bank databases, including: Development Africa Development Indicators; Doing Business; Education Statistics; Enterprise Surveys; Global Development Finance;
    Gender Statistics; Health Nutrition and Population Statistics; International Development Association - Results Measurement
    System; Millennium Development Goals; World Development Indicators; Worldwide Governance Indicators; and LAC Equity Lab.
    These indicators include information from over 256 countries and regions, since 1960.

Users can chose from one of three of the languages supported by the database (and Stata), namely, English, Spanish, or French.

Five possible downloads options are currently supported:

- country: over 2,500 indicators for all selected years for a single country (WDI Catalogue).
- topics: WDI indicators within a specific topic, for all selected years and all countries (WDI Catalogue).
- indicator: all selected years for all countries for a single indicator (from any of the catalogues: 17,000+ series).
- indicator and country: all selected years for selected countries for a single indicator (from any of the catalogues: 17,000+ series).
- multiple indicator: all selected years for selected indicators separated by ; (from any of the catalogues: 17,000+ series).

Users can also choose to have the data displayed in either the wide or long format (wide is the default option).  Note that the reshape is the local machine, so it will require the appropriate amount of RAM to work properly.

wbopendata draws from the main World Bank collections of development indicators, compiled from officially-recognized international sources. It presents the most current and accurate global development data available, and includes national, regional and global estimates.

The access to this databases is made possible by the World Bank's Open Data Initiative which provide open full access to [World Bank databases](http://data.worldbank.org/).

### Parameters

- country(string): Countries and Regions Abbreviations and acronyms. If solely specified, this option will return all the WDI indicators (1,076 series) for a single country or region (no multiple country selection allowed in this case). If this option is selected jointly with a specific indicator, the output is a series for a specific country or region, or multiple countries or region. When selecting multiple countries please use the three letters code, separated by a semicolon (;), with no spaces.


- topics(numlist): Topic List 21 topic lists are curently supported and include Agriculture & Rural Development; Aid Effectiveness; Economy & Growth; Education; Energy & Mining; Environment; Financial Sector; Health; Infrastructure; Social Protection & Labor; Poverty; Private Sector; Public Sector; Science & Technology; Social Development; Urban Development; Gender; Millenium development goals; Climate Change; External Debt; and, Trade (only one topic collection can be requested at the time).


- indicator(string): Indicators List list of indicator codes (All series). When selecting multiple indicators please use semicolon (;), to separate differenet indicatos.

## Disclaimer

   Users should not use wbopendata without checking first for more detailed information on the definitions of each [indicator](http://data.worldbank.org/indicator/)
    and [data-catalogues](http://data.worldbank.org/data-catalog/). The indicators names and codes used by wbopendata are precisely the same used in the World Bank data
    catalogue in order to facilitate such cross reference.

   When downloading specific series, through the indicator options, wbopendata will by default display in the Stata results
    window the metadata available for this particular series, including information on the name of the series, the source, a
    detailed description of the indicator, and the organization responsible for compiling this indicator.

## Terms of use World Bank Data
   
The use of World Bank datasets listed in the Data Catalog is governed by a specific [Terms of Use for World Bank Data](http://data.worldbank.org/summary-terms-of-use/).
            
The terms of use of the APIs is governed by the [World Bank Terms and Conditions](http://go.worldbank.org/C09SUA7BK0/).


## Blog Posts

[Wbopendata Stata Module Upgrade (posted on 8 July 2014 by João Pedro Azevedo)](https://blogs.worldbank.org/category/tags/wbopendata)

[New Stata module released (Posted on 6 February 2013 by João Pedro Azevedo)](http://blogs.worldbank.org/opendata/node/562)

[World Bank Development Data in Stata (posted on Thursday, 17 February 2011)](http://rlab-data.blogspot.com/2011/02/world-bank-development-data-in-stata.html)

[World Bank’s open data policy and -wbopendata- (posted on 10 February 2011 by Mitch Abdon)](http://statadaily.com/tag/wbopendata/)


## Examples

**(Examples of code and output)[https://github.com/jpazvd/wbopendata/blob/master/doc/wbopendata.md]**

## Suggested Citation

[Joao Pedro Azevedo, 2011. "WBOPENDATA: Stata module to access World Bank databases," Statistical Software Components S457234, Boston College Department of Economics, revised 10 Feb 2016.](https://ideas.repec.org/c/boc/bocode/s457234.html)

#### Handle: RePEc:boc:bocode:s457234 

#### Note: 
This module should be installed from within Stata by typing "ssc install wbopendata". Windows users should not attempt to download these files with a web browser.

#### Keywords:
Indicators; WDI; API; Open Data

## Author: 

  **João Pedro Azevedo**  
  [jazevedo@worldbank.org](mailto:jazevedo@worldbank.org)  
  World Bank  
  [World Bank Staff page](http://www.worldbank.org/en/about/people/j/joao-pedro-azevedo)  
  [Twitter](https://twitter.com/jpazvd)  

