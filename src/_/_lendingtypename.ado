*! _lendingtypename <22 Oct 2019 : 22:00:04>                 by João Pedro Azevedo
*                 auto generated and updated using _update_countrymetadata.ado 
  
 program define _lendingtypename 
  
     syntax , match(varname) 
  
*********************
  
         gen lendingtypename = ""  
         replace lendingtypename = "Not classified"  if `match' == "ABW"  
         replace lendingtypename = "IDA"  if `match' == "AFG"  
         replace lendingtypename = "IBRD"  if `match' == "AGO"  
         replace lendingtypename = "IBRD"  if `match' == "ALB"  
         replace lendingtypename = "Not classified"  if `match' == "AND"  
         replace lendingtypename = "Not classified"  if `match' == "ARE"  
         replace lendingtypename = "IBRD"  if `match' == "ARG"  
         replace lendingtypename = "IBRD"  if `match' == "ARM"  
         replace lendingtypename = "Not classified"  if `match' == "ASM"  
         replace lendingtypename = "IBRD"  if `match' == "ATG"  
         replace lendingtypename = "Not classified"  if `match' == "AUS"  
         replace lendingtypename = "Not classified"  if `match' == "AUT"  
         replace lendingtypename = "IBRD"  if `match' == "AZE"  
         replace lendingtypename = "IDA"  if `match' == "BDI"  
         replace lendingtypename = "Not classified"  if `match' == "BEL"  
         replace lendingtypename = "IDA"  if `match' == "BEN"  
         replace lendingtypename = "IDA"  if `match' == "BFA"  
         replace lendingtypename = "IDA"  if `match' == "BGD"  
         replace lendingtypename = "IBRD"  if `match' == "BGR"  
         replace lendingtypename = "Not classified"  if `match' == "BHR"  
         replace lendingtypename = "Not classified"  if `match' == "BHS"  
         replace lendingtypename = "IBRD"  if `match' == "BIH"  
         replace lendingtypename = "IBRD"  if `match' == "BLR"  
         replace lendingtypename = "IBRD"  if `match' == "BLZ"  
         replace lendingtypename = "Not classified"  if `match' == "BMU"  
         replace lendingtypename = "IBRD"  if `match' == "BOL"  
         replace lendingtypename = "IBRD"  if `match' == "BRA"  
         replace lendingtypename = "Not classified"  if `match' == "BRB"  
         replace lendingtypename = "Not classified"  if `match' == "BRN"  
         replace lendingtypename = "IDA"  if `match' == "BTN"  
         replace lendingtypename = "IBRD"  if `match' == "BWA"  
         replace lendingtypename = "IDA"  if `match' == "CAF"  
         replace lendingtypename = "Not classified"  if `match' == "CAN"  
         replace lendingtypename = "Not classified"  if `match' == "CHE"  
         replace lendingtypename = "Not classified"  if `match' == "CHI"  
         replace lendingtypename = "IBRD"  if `match' == "CHL"  
         replace lendingtypename = "IBRD"  if `match' == "CHN"  
         replace lendingtypename = "IDA"  if `match' == "CIV"  
         replace lendingtypename = "Blend"  if `match' == "CMR"  
         replace lendingtypename = "IDA"  if `match' == "COD"  
         replace lendingtypename = "Blend"  if `match' == "COG"  
         replace lendingtypename = "IBRD"  if `match' == "COL"  
         replace lendingtypename = "IDA"  if `match' == "COM"  
         replace lendingtypename = "Blend"  if `match' == "CPV"  
         replace lendingtypename = "IBRD"  if `match' == "CRI"  
         replace lendingtypename = "Not classified"  if `match' == "CUB"  
         replace lendingtypename = "Not classified"  if `match' == "CUW"  
         replace lendingtypename = "Not classified"  if `match' == "CYM"  
         replace lendingtypename = "Not classified"  if `match' == "CYP"  
         replace lendingtypename = "Not classified"  if `match' == "CZE"  
         replace lendingtypename = "Not classified"  if `match' == "DEU"  
         replace lendingtypename = "IDA"  if `match' == "DJI"  
         replace lendingtypename = "Blend"  if `match' == "DMA"  
         replace lendingtypename = "Not classified"  if `match' == "DNK"  
         replace lendingtypename = "IBRD"  if `match' == "DOM"  
         replace lendingtypename = "IBRD"  if `match' == "DZA"  
         replace lendingtypename = "IBRD"  if `match' == "ECU"  
         replace lendingtypename = "IBRD"  if `match' == "EGY"  
         replace lendingtypename = "IDA"  if `match' == "ERI"  
         replace lendingtypename = "Not classified"  if `match' == "ESP"  
         replace lendingtypename = "Not classified"  if `match' == "EST"  
         replace lendingtypename = "IDA"  if `match' == "ETH"  
         replace lendingtypename = "Not classified"  if `match' == "FIN"  
         replace lendingtypename = "Blend"  if `match' == "FJI"  
         replace lendingtypename = "Not classified"  if `match' == "FRA"  
         replace lendingtypename = "Not classified"  if `match' == "FRO"  
         replace lendingtypename = "IDA"  if `match' == "FSM"  
         replace lendingtypename = "IBRD"  if `match' == "GAB"  
         replace lendingtypename = "Not classified"  if `match' == "GBR"  
         replace lendingtypename = "IBRD"  if `match' == "GEO"  
         replace lendingtypename = "IDA"  if `match' == "GHA"  
         replace lendingtypename = "Not classified"  if `match' == "GIB"  
         replace lendingtypename = "IDA"  if `match' == "GIN"  
         replace lendingtypename = "IDA"  if `match' == "GMB"  
         replace lendingtypename = "IDA"  if `match' == "GNB"  
         replace lendingtypename = "IBRD"  if `match' == "GNQ"  
         replace lendingtypename = "Not classified"  if `match' == "GRC"  
         replace lendingtypename = "Blend"  if `match' == "GRD"  
         replace lendingtypename = "Not classified"  if `match' == "GRL"  
         replace lendingtypename = "IBRD"  if `match' == "GTM"  
         replace lendingtypename = "Not classified"  if `match' == "GUM"  
         replace lendingtypename = "IDA"  if `match' == "GUY"  
         replace lendingtypename = "Not classified"  if `match' == "HKG"  
         replace lendingtypename = "IDA"  if `match' == "HND"  
         replace lendingtypename = "IBRD"  if `match' == "HRV"  
         replace lendingtypename = "IDA"  if `match' == "HTI"  
         replace lendingtypename = "Not classified"  if `match' == "HUN"  
         replace lendingtypename = "IBRD"  if `match' == "IDN"  
         replace lendingtypename = "Not classified"  if `match' == "IMN"  
         replace lendingtypename = "IBRD"  if `match' == "IND"  
         replace lendingtypename = "Not classified"  if `match' == "IRL"  
         replace lendingtypename = "IBRD"  if `match' == "IRN"  
         replace lendingtypename = "IBRD"  if `match' == "IRQ"  
         replace lendingtypename = "Not classified"  if `match' == "ISL"  
         replace lendingtypename = "Not classified"  if `match' == "ISR"  
         replace lendingtypename = "Not classified"  if `match' == "ITA"  
         replace lendingtypename = "IBRD"  if `match' == "JAM"  
         replace lendingtypename = "IBRD"  if `match' == "JOR"  
         replace lendingtypename = "Not classified"  if `match' == "JPN"  
         replace lendingtypename = "IBRD"  if `match' == "KAZ"  
         replace lendingtypename = "Blend"  if `match' == "KEN"  
         replace lendingtypename = "IDA"  if `match' == "KGZ"  
         replace lendingtypename = "IDA"  if `match' == "KHM"  
         replace lendingtypename = "IDA"  if `match' == "KIR"  
         replace lendingtypename = "IBRD"  if `match' == "KNA"  
         replace lendingtypename = "Not classified"  if `match' == "KOR"  
         replace lendingtypename = "Not classified"  if `match' == "KWT"  
         replace lendingtypename = "IDA"  if `match' == "LAO"  
         replace lendingtypename = "IBRD"  if `match' == "LBN"  
         replace lendingtypename = "IDA"  if `match' == "LBR"  
         replace lendingtypename = "IBRD"  if `match' == "LBY"  
         replace lendingtypename = "Blend"  if `match' == "LCA"  
         replace lendingtypename = "Not classified"  if `match' == "LIE"  
         replace lendingtypename = "IBRD"  if `match' == "LKA"  
         replace lendingtypename = "IDA"  if `match' == "LSO"  
         replace lendingtypename = "Not classified"  if `match' == "LTU"  
         replace lendingtypename = "Not classified"  if `match' == "LUX"  
         replace lendingtypename = "Not classified"  if `match' == "LVA"  
         replace lendingtypename = "Not classified"  if `match' == "MAC"  
         replace lendingtypename = "Not classified"  if `match' == "MAF"  
         replace lendingtypename = "IBRD"  if `match' == "MAR"  
         replace lendingtypename = "Not classified"  if `match' == "MCO"  
         replace lendingtypename = "Blend"  if `match' == "MDA"  
         replace lendingtypename = "IDA"  if `match' == "MDG"  
         replace lendingtypename = "IDA"  if `match' == "MDV"  
         replace lendingtypename = "IBRD"  if `match' == "MEX"  
         replace lendingtypename = "IDA"  if `match' == "MHL"  
         replace lendingtypename = "IBRD"  if `match' == "MKD"  
         replace lendingtypename = "IDA"  if `match' == "MLI"  
         replace lendingtypename = "Not classified"  if `match' == "MLT"  
         replace lendingtypename = "IDA"  if `match' == "MMR"  
         replace lendingtypename = "IBRD"  if `match' == "MNE"  
         replace lendingtypename = "Blend"  if `match' == "MNG"  
         replace lendingtypename = "Not classified"  if `match' == "MNP"  
         replace lendingtypename = "IDA"  if `match' == "MOZ"  
         replace lendingtypename = "IDA"  if `match' == "MRT"  
         replace lendingtypename = "IBRD"  if `match' == "MUS"  
         replace lendingtypename = "IDA"  if `match' == "MWI"  
         replace lendingtypename = "IBRD"  if `match' == "MYS"  
         replace lendingtypename = "IBRD"  if `match' == "NAM"  
         replace lendingtypename = "Not classified"  if `match' == "NCL"  
         replace lendingtypename = "IDA"  if `match' == "NER"  
         replace lendingtypename = "Blend"  if `match' == "NGA"  
         replace lendingtypename = "IDA"  if `match' == "NIC"  
         replace lendingtypename = "Not classified"  if `match' == "NLD"  
         replace lendingtypename = "Not classified"  if `match' == "NOR"  
         replace lendingtypename = "IDA"  if `match' == "NPL"  
         replace lendingtypename = "IBRD"  if `match' == "NRU"  
         replace lendingtypename = "Not classified"  if `match' == "NZL"  
         replace lendingtypename = "Not classified"  if `match' == "OMN"  
         replace lendingtypename = "Blend"  if `match' == "PAK"  
         replace lendingtypename = "IBRD"  if `match' == "PAN"  
         replace lendingtypename = "IBRD"  if `match' == "PER"  
         replace lendingtypename = "IBRD"  if `match' == "PHL"  
         replace lendingtypename = "IBRD"  if `match' == "PLW"  
         replace lendingtypename = "Blend"  if `match' == "PNG"  
         replace lendingtypename = "IBRD"  if `match' == "POL"  
         replace lendingtypename = "Not classified"  if `match' == "PRI"  
         replace lendingtypename = "Not classified"  if `match' == "PRK"  
         replace lendingtypename = "Not classified"  if `match' == "PRT"  
         replace lendingtypename = "IBRD"  if `match' == "PRY"  
         replace lendingtypename = "Not classified"  if `match' == "PSE"  
         replace lendingtypename = "Not classified"  if `match' == "PYF"  
         replace lendingtypename = "Not classified"  if `match' == "QAT"  
         replace lendingtypename = "IBRD"  if `match' == "ROU"  
         replace lendingtypename = "IBRD"  if `match' == "RUS"  
         replace lendingtypename = "IDA"  if `match' == "RWA"  
         replace lendingtypename = "Not classified"  if `match' == "SAU"  
         replace lendingtypename = "IDA"  if `match' == "SDN"  
         replace lendingtypename = "IDA"  if `match' == "SEN"  
         replace lendingtypename = "Not classified"  if `match' == "SGP"  
         replace lendingtypename = "IDA"  if `match' == "SLB"  
         replace lendingtypename = "IDA"  if `match' == "SLE"  
         replace lendingtypename = "IBRD"  if `match' == "SLV"  
         replace lendingtypename = "Not classified"  if `match' == "SMR"  
         replace lendingtypename = "IDA"  if `match' == "SOM"  
         replace lendingtypename = "IBRD"  if `match' == "SRB"  
         replace lendingtypename = "IDA"  if `match' == "SSD"  
         replace lendingtypename = "IDA"  if `match' == "STP"  
         replace lendingtypename = "IBRD"  if `match' == "SUR"  
         replace lendingtypename = "Not classified"  if `match' == "SVK"  
         replace lendingtypename = "Not classified"  if `match' == "SVN"  
         replace lendingtypename = "Not classified"  if `match' == "SWE"  
         replace lendingtypename = "IBRD"  if `match' == "SWZ"  
         replace lendingtypename = "Not classified"  if `match' == "SXM"  
         replace lendingtypename = "IBRD"  if `match' == "SYC"  
         replace lendingtypename = "IDA"  if `match' == "SYR"  
         replace lendingtypename = "Not classified"  if `match' == "TCA"  
         replace lendingtypename = "IDA"  if `match' == "TCD"  
         replace lendingtypename = "IDA"  if `match' == "TGO"  
         replace lendingtypename = "IBRD"  if `match' == "THA"  
         replace lendingtypename = "IDA"  if `match' == "TJK"  
         replace lendingtypename = "IBRD"  if `match' == "TKM"  
         replace lendingtypename = "Blend"  if `match' == "TLS"  
         replace lendingtypename = "IDA"  if `match' == "TON"  
         replace lendingtypename = "IBRD"  if `match' == "TTO"  
         replace lendingtypename = "IBRD"  if `match' == "TUN"  
         replace lendingtypename = "IBRD"  if `match' == "TUR"  
         replace lendingtypename = "IDA"  if `match' == "TUV"  
         replace lendingtypename = "Not classified"  if `match' == "TWN"  
         replace lendingtypename = "IDA"  if `match' == "TZA"  
         replace lendingtypename = "IDA"  if `match' == "UGA"  
         replace lendingtypename = "IBRD"  if `match' == "UKR"  
         replace lendingtypename = "IBRD"  if `match' == "URY"  
         replace lendingtypename = "Not classified"  if `match' == "USA"  
         replace lendingtypename = "Blend"  if `match' == "UZB"  
         replace lendingtypename = "Blend"  if `match' == "VCT"  
         replace lendingtypename = "IBRD"  if `match' == "VEN"  
         replace lendingtypename = "Not classified"  if `match' == "VGB"  
         replace lendingtypename = "Not classified"  if `match' == "VIR"  
         replace lendingtypename = "IBRD"  if `match' == "VNM"  
         replace lendingtypename = "IDA"  if `match' == "VUT"  
         replace lendingtypename = "IDA"  if `match' == "WSM"  
         replace lendingtypename = "IDA"  if `match' == "XKX"  
         replace lendingtypename = "IDA"  if `match' == "YEM"  
         replace lendingtypename = "IBRD"  if `match' == "ZAF"  
         replace lendingtypename = "IDA"  if `match' == "ZMB"  
  
*********************
  
 lab var lendingtypename         "Lending Type Name" 
  
*********************
  
 end 
