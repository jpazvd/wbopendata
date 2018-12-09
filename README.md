# WBOPENDATA: Stata module to access World Bank databases

## Description

    wbopendata allows Stata users to download over 9,900 indicators from the World Bank databases, including: Development
    Africa Development Indicators; Doing Business; Education Statistics; Enterprise Surveys; Global Development Finance;
    Gender Statistics; Health Nutrition and Population Statistics; International Development Association - Results Measurement
    System; Millennium Development Goals; World Development Indicators; Worldwide Governance Indicators; and LAC Equity Lab.
    These indicators include information from over 256 countries and regions, since 1960.

    Users can chose from one of three of the languages supported by the database (and Stata), namely, English, Spanish, or
    French.

    Five possible downloads options are currently supported:

      country                     over 1,000 indicators for all selected years for a single country (WDI Catalogue).
      topics                      WDI indicators within a specific topic, for all selected years and all countries (WDI
                                   Catalogue).
      indicator                   all selected years for all countries for a single indicator (from any of the catalogues:
                                   9,000+ series).
      indicator and country       all selected years for selected countries for a single indicator (from any of the
                                   catalogues: 9,000+ series).
      multiple indicator          all selected years for selected indicators separated by ; (from any of the catalogues:
                                   9,000+ series).

    Users can also choose to have the data displayed in either the wide or long format (wide is the default option).  Note
    that the reshape is the local machine, so it will require the appropriate amount of RAM to work properly.

    wbopendata draws from the main World Bank collections of development indicators, compiled from officially-recognized
    international sources. It presents the most current and accurate global development data available, and includes national,
    regional and global estimates.

    The access to this databases is made possible by the World Bank's Open Data Initiative which provide open full access to 
    World Bank databases.


## Blog Posts

[Wbopendata Stata Module Upgrade (posted on 8 July 2014 by João Pedro Azevedo)](https://blogs.worldbank.org/category/tags/wbopendata)

[New Stata module released (Posted on 6 February 2013 by João Pedro Azevedo)](http://blogs.worldbank.org/opendata/node/562)

[World Bank Development Data in Stata (posted on Thursday, 17 February 2011)](http://rlab-data.blogspot.com/2011/02/world-bank-development-data-in-stata.html)

[World Bank’s open data policy and -wbopendata- (posted on 10 February 2011 by Mitch Abdon)](http://statadaily.com/tag/wbopendata/)

## Suggested Citation

[Joao Pedro Azevedo, 2011. "WBOPENDATA: Stata module to access World Bank databases," Statistical Software Components S457234, Boston College Department of Economics, revised 10 Feb 2016.](https://ideas.repec.org/c/boc/bocode/s457234.html)

#### Handle: RePEc:boc:bocode:s457234 

#### Note: 
This module should be installed from within Stata by typing "ssc install wbopendata". Windows users should not attempt to download these files with a web browser.

#### Keywords:
Indicators; WDI; API; Open Data
