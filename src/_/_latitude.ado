*! _latitude <22 Oct 2019 : 22:00:04>                 by João Pedro Azevedo
*                 auto generated and updated using _update_countrymetadata.ado 
  
 program define _latitude 
  
     syntax , match(varname) 
  
  
  
         gen  double latitude = .  
         replace latitude = real("12.5167")    if `match' == "ABW"  
         replace latitude = real("34.5228")    if `match' == "AFG"  
         replace latitude = real("-8.81155")    if `match' == "AGO"  
         replace latitude = real("41.3317")    if `match' == "ALB"  
         replace latitude = real("42.5075")    if `match' == "AND"  
         replace latitude = real("24.4764")    if `match' == "ARE"  
         replace latitude = real("-34.6118")    if `match' == "ARG"  
         replace latitude = real("40.1596")    if `match' == "ARM"  
         replace latitude = real("-14.2846")    if `match' == "ASM"  
         replace latitude = real("17.1175")    if `match' == "ATG"  
         replace latitude = real("-35.282")    if `match' == "AUS"  
         replace latitude = real("48.2201")    if `match' == "AUT"  
         replace latitude = real("40.3834")    if `match' == "AZE"  
         replace latitude = real("-3.3784")    if `match' == "BDI"  
         replace latitude = real("50.8371")    if `match' == "BEL"  
         replace latitude = real("6.4779")    if `match' == "BEN"  
         replace latitude = real("12.3605")    if `match' == "BFA"  
         replace latitude = real("23.7055")    if `match' == "BGD"  
         replace latitude = real("42.7105")    if `match' == "BGR"  
         replace latitude = real("26.1921")    if `match' == "BHR"  
         replace latitude = real("25.0661")    if `match' == "BHS"  
         replace latitude = real("43.8607")    if `match' == "BIH"  
         replace latitude = real("53.9678")    if `match' == "BLR"  
         replace latitude = real("17.2534")    if `match' == "BLZ"  
         replace latitude = real("32.3293")    if `match' == "BMU"  
         replace latitude = real("-13.9908")    if `match' == "BOL"  
         replace latitude = real("-15.7801")    if `match' == "BRA"  
         replace latitude = real("13.0935")    if `match' == "BRB"  
         replace latitude = real("4.94199")    if `match' == "BRN"  
         replace latitude = real("27.5768")    if `match' == "BTN"  
         replace latitude = real("-24.6544")    if `match' == "BWA"  
         replace latitude = real("5.63056")    if `match' == "CAF"  
         replace latitude = real("45.4215")    if `match' == "CAN"  
         replace latitude = real("46.948")    if `match' == "CHE"  
         replace latitude = real("<wb:latitude")    if `match' == "CHI"  
         replace latitude = real("-33.475")    if `match' == "CHL"  
         replace latitude = real("40.0495")    if `match' == "CHN"  
         replace latitude = real("5.332")    if `match' == "CIV"  
         replace latitude = real("3.8721")    if `match' == "CMR"  
         replace latitude = real("-4.325")    if `match' == "COD"  
         replace latitude = real("-4.2767")    if `match' == "COG"  
         replace latitude = real("4.60987")    if `match' == "COL"  
         replace latitude = real("-11.6986")    if `match' == "COM"  
         replace latitude = real("14.9218")    if `match' == "CPV"  
         replace latitude = real("9.63701")    if `match' == "CRI"  
         replace latitude = real("23.1333")    if `match' == "CUB"  
         replace latitude = real("<wb:latitude")    if `match' == "CUW"  
         replace latitude = real("19.3022")    if `match' == "CYM"  
         replace latitude = real("35.1676")    if `match' == "CYP"  
         replace latitude = real("50.0878")    if `match' == "CZE"  
         replace latitude = real("52.5235")    if `match' == "DEU"  
         replace latitude = real("11.5806")    if `match' == "DJI"  
         replace latitude = real("15.2976")    if `match' == "DMA"  
         replace latitude = real("55.6763")    if `match' == "DNK"  
         replace latitude = real("18.479")    if `match' == "DOM"  
         replace latitude = real("36.7397")    if `match' == "DZA"  
         replace latitude = real("-0.229498")    if `match' == "ECU"  
         replace latitude = real("30.0982")    if `match' == "EGY"  
         replace latitude = real("15.3315")    if `match' == "ERI"  
         replace latitude = real("40.4167")    if `match' == "ESP"  
         replace latitude = real("59.4392")    if `match' == "EST"  
         replace latitude = real("9.02274")    if `match' == "ETH"  
         replace latitude = real("60.1608")    if `match' == "FIN"  
         replace latitude = real("-18.1149")    if `match' == "FJI"  
         replace latitude = real("48.8566")    if `match' == "FRA"  
         replace latitude = real("61.8926")    if `match' == "FRO"  
         replace latitude = real("6.91771")    if `match' == "FSM"  
         replace latitude = real("0.38832")    if `match' == "GAB"  
         replace latitude = real("51.5002")    if `match' == "GBR"  
         replace latitude = real("41.71")    if `match' == "GEO"  
         replace latitude = real("5.57045")    if `match' == "GHA"  
         replace latitude = real("<wb:latitude")    if `match' == "GIB"  
         replace latitude = real("9.51667")    if `match' == "GIN"  
         replace latitude = real("13.4495")    if `match' == "GMB"  
         replace latitude = real("11.8037")    if `match' == "GNB"  
         replace latitude = real("3.7523")    if `match' == "GNQ"  
         replace latitude = real("37.9792")    if `match' == "GRC"  
         replace latitude = real("12.0653")    if `match' == "GRD"  
         replace latitude = real("64.1836")    if `match' == "GRL"  
         replace latitude = real("14.6248")    if `match' == "GTM"  
         replace latitude = real("13.4443")    if `match' == "GUM"  
         replace latitude = real("6.80461")    if `match' == "GUY"  
         replace latitude = real("22.3964")    if `match' == "HKG"  
         replace latitude = real("15.1333")    if `match' == "HND"  
         replace latitude = real("45.8069")    if `match' == "HRV"  
         replace latitude = real("18.5392")    if `match' == "HTI"  
         replace latitude = real("47.4984")    if `match' == "HUN"  
         replace latitude = real("-6.19752")    if `match' == "IDN"  
         replace latitude = real("54.1509")    if `match' == "IMN"  
         replace latitude = real("28.6353")    if `match' == "IND"  
         replace latitude = real("53.3441")    if `match' == "IRL"  
         replace latitude = real("35.6878")    if `match' == "IRN"  
         replace latitude = real("33.3302")    if `match' == "IRQ"  
         replace latitude = real("64.1353")    if `match' == "ISL"  
         replace latitude = real("31.7717")    if `match' == "ISR"  
         replace latitude = real("41.8955")    if `match' == "ITA"  
         replace latitude = real("17.9927")    if `match' == "JAM"  
         replace latitude = real("31.9497")    if `match' == "JOR"  
         replace latitude = real("35.67")    if `match' == "JPN"  
         replace latitude = real("51.1879")    if `match' == "KAZ"  
         replace latitude = real("-1.27975")    if `match' == "KEN"  
         replace latitude = real("42.8851")    if `match' == "KGZ"  
         replace latitude = real("11.5556")    if `match' == "KHM"  
         replace latitude = real("1.32905")    if `match' == "KIR"  
         replace latitude = real("17.3")    if `match' == "KNA"  
         replace latitude = real("37.5323")    if `match' == "KOR"  
         replace latitude = real("29.3721")    if `match' == "KWT"  
         replace latitude = real("18.5826")    if `match' == "LAO"  
         replace latitude = real("33.8872")    if `match' == "LBN"  
         replace latitude = real("6.30039")    if `match' == "LBR"  
         replace latitude = real("32.8578")    if `match' == "LBY"  
         replace latitude = real("14")    if `match' == "LCA"  
         replace latitude = real("47.1411")    if `match' == "LIE"  
         replace latitude = real("6.92148")    if `match' == "LKA"  
         replace latitude = real("-29.5208")    if `match' == "LSO"  
         replace latitude = real("54.6896")    if `match' == "LTU"  
         replace latitude = real("49.61")    if `match' == "LUX"  
         replace latitude = real("56.9465")    if `match' == "LVA"  
         replace latitude = real("22.1667")    if `match' == "MAC"  
         replace latitude = real("<wb:latitude")    if `match' == "MAF"  
         replace latitude = real("33.9905")    if `match' == "MAR"  
         replace latitude = real("43.7325")    if `match' == "MCO"  
         replace latitude = real("47.0167")    if `match' == "MDA"  
         replace latitude = real("-20.4667")    if `match' == "MDG"  
         replace latitude = real("4.1742")    if `match' == "MDV"  
         replace latitude = real("19.427")    if `match' == "MEX"  
         replace latitude = real("7.11046")    if `match' == "MHL"  
         replace latitude = real("42.0024")    if `match' == "MKD"  
         replace latitude = real("13.5667")    if `match' == "MLI"  
         replace latitude = real("35.9042")    if `match' == "MLT"  
         replace latitude = real("21.914")    if `match' == "MMR"  
         replace latitude = real("42.4602")    if `match' == "MNE"  
         replace latitude = real("47.9129")    if `match' == "MNG"  
         replace latitude = real("15.1935")    if `match' == "MNP"  
         replace latitude = real("-25.9664")    if `match' == "MOZ"  
         replace latitude = real("18.2367")    if `match' == "MRT"  
         replace latitude = real("-20.1605")    if `match' == "MUS"  
         replace latitude = real("-13.9899")    if `match' == "MWI"  
         replace latitude = real("3.12433")    if `match' == "MYS"  
         replace latitude = real("-22.5648")    if `match' == "NAM"  
         replace latitude = real("-22.2677")    if `match' == "NCL"  
         replace latitude = real("13.514")    if `match' == "NER"  
         replace latitude = real("9.05804")    if `match' == "NGA"  
         replace latitude = real("12.1475")    if `match' == "NIC"  
         replace latitude = real("52.3738")    if `match' == "NLD"  
         replace latitude = real("59.9138")    if `match' == "NOR"  
         replace latitude = real("27.6939")    if `match' == "NPL"  
         replace latitude = real("-0.5477")    if `match' == "NRU"  
         replace latitude = real("-41.2865")    if `match' == "NZL"  
         replace latitude = real("23.6105")    if `match' == "OMN"  
         replace latitude = real("30.5167")    if `match' == "PAK"  
         replace latitude = real("8.99427")    if `match' == "PAN"  
         replace latitude = real("-12.0931")    if `match' == "PER"  
         replace latitude = real("14.5515")    if `match' == "PHL"  
         replace latitude = real("7.34194")    if `match' == "PLW"  
         replace latitude = real("-9.47357")    if `match' == "PNG"  
         replace latitude = real("52.26")    if `match' == "POL"  
         replace latitude = real("18.23")    if `match' == "PRI"  
         replace latitude = real("39.0319")    if `match' == "PRK"  
         replace latitude = real("38.7072")    if `match' == "PRT"  
         replace latitude = real("-25.3005")    if `match' == "PRY"  
         replace latitude = real("<wb:latitude")    if `match' == "PSE"  
         replace latitude = real("-17.535")    if `match' == "PYF"  
         replace latitude = real("25.2948")    if `match' == "QAT"  
         replace latitude = real("44.4479")    if `match' == "ROU"  
         replace latitude = real("55.7558")    if `match' == "RUS"  
         replace latitude = real("-1.95325")    if `match' == "RWA"  
         replace latitude = real("24.6748")    if `match' == "SAU"  
         replace latitude = real("15.5932")    if `match' == "SDN"  
         replace latitude = real("14.7247")    if `match' == "SEN"  
         replace latitude = real("1.28941")    if `match' == "SGP"  
         replace latitude = real("-9.42676")    if `match' == "SLB"  
         replace latitude = real("8.4821")    if `match' == "SLE"  
         replace latitude = real("13.7034")    if `match' == "SLV"  
         replace latitude = real("43.9322")    if `match' == "SMR"  
         replace latitude = real("2.07515")    if `match' == "SOM"  
         replace latitude = real("44.8024")    if `match' == "SRB"  
         replace latitude = real("4.85")    if `match' == "SSD"  
         replace latitude = real("0.20618")    if `match' == "STP"  
         replace latitude = real("5.8232")    if `match' == "SUR"  
         replace latitude = real("48.1484")    if `match' == "SVK"  
         replace latitude = real("46.0546")    if `match' == "SVN"  
         replace latitude = real("59.3327")    if `match' == "SWE"  
         replace latitude = real("-26.5225")    if `match' == "SWZ"  
         replace latitude = real("<wb:latitude")    if `match' == "SXM"  
         replace latitude = real("-4.6309")    if `match' == "SYC"  
         replace latitude = real("33.5146")    if `match' == "SYR"  
         replace latitude = real("21.4602778")    if `match' == "TCA"  
         replace latitude = real("12.1048")    if `match' == "TCD"  
         replace latitude = real("6.1228")    if `match' == "TGO"  
         replace latitude = real("13.7308")    if `match' == "THA"  
         replace latitude = real("38.5878")    if `match' == "TJK"  
         replace latitude = real("37.9509")    if `match' == "TKM"  
         replace latitude = real("-8.56667")    if `match' == "TLS"  
         replace latitude = real("-21.136")    if `match' == "TON"  
         replace latitude = real("10.6596")    if `match' == "TTO"  
         replace latitude = real("36.7899")    if `match' == "TUN"  
         replace latitude = real("39.7153")    if `match' == "TUR"  
         replace latitude = real("-8.6314877")    if `match' == "TUV"  
         replace latitude = real("<wb:latitude")    if `match' == "TWN"  
         replace latitude = real("-6.17486")    if `match' == "TZA"  
         replace latitude = real("0.314269")    if `match' == "UGA"  
         replace latitude = real("50.4536")    if `match' == "UKR"  
         replace latitude = real("-34.8941")    if `match' == "URY"  
         replace latitude = real("38.8895")    if `match' == "USA"  
         replace latitude = real("41.3052")    if `match' == "UZB"  
         replace latitude = real("13.2035")    if `match' == "VCT"  
         replace latitude = real("9.08165")    if `match' == "VEN"  
         replace latitude = real("18.431389")    if `match' == "VGB"  
         replace latitude = real("18.3358")    if `match' == "VIR"  
         replace latitude = real("21.0069")    if `match' == "VNM"  
         replace latitude = real("-17.7404")    if `match' == "VUT"  
         replace latitude = real("-13.8314")    if `match' == "WSM"  
         replace latitude = real("42.565")    if `match' == "XKX"  
         replace latitude = real("15.352")    if `match' == "YEM"  
         replace latitude = real("-25.746")    if `match' == "ZAF"  
         replace latitude = real("-15.3982")    if `match' == "ZMB"  
  
*********************
  
 lab var latitude                        "Capital Latitude" 
  
*********************
  
 end 
