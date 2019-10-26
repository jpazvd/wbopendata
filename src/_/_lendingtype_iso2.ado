*! _lendingtype_iso2 <22 Oct 2019 : 22:00:04>                 by João Pedro Azevedo
*                 auto generated and updated using _update_countrymetadata.ado 
  
 program define _lendingtype_iso2 
  
     syntax , match(varname) 
  
*********************
  
         gen lendingtype_iso2 = ""  
         replace lendingtype_iso2 = "XX"  if `match' == "ABW"  
         replace lendingtype_iso2 = "XI"  if `match' == "AFG"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "AFR"  
         replace lendingtype_iso2 = "XF"  if `match' == "AGO"  
         replace lendingtype_iso2 = "XF"  if `match' == "ALB"  
         replace lendingtype_iso2 = "XX"  if `match' == "AND"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "ANR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "ARB"  
         replace lendingtype_iso2 = "XX"  if `match' == "ARE"  
         replace lendingtype_iso2 = "XF"  if `match' == "ARG"  
         replace lendingtype_iso2 = "XF"  if `match' == "ARM"  
         replace lendingtype_iso2 = "XX"  if `match' == "ASM"  
         replace lendingtype_iso2 = "XF"  if `match' == "ATG"  
         replace lendingtype_iso2 = "XX"  if `match' == "AUS"  
         replace lendingtype_iso2 = "XX"  if `match' == "AUT"  
         replace lendingtype_iso2 = "XF"  if `match' == "AZE"  
         replace lendingtype_iso2 = "XI"  if `match' == "BDI"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "BEA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "BEC"  
         replace lendingtype_iso2 = "XX"  if `match' == "BEL"  
         replace lendingtype_iso2 = "XI"  if `match' == "BEN"  
         replace lendingtype_iso2 = "XI"  if `match' == "BFA"  
         replace lendingtype_iso2 = "XI"  if `match' == "BGD"  
         replace lendingtype_iso2 = "XF"  if `match' == "BGR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "BHI"  
         replace lendingtype_iso2 = "XX"  if `match' == "BHR"  
         replace lendingtype_iso2 = "XX"  if `match' == "BHS"  
         replace lendingtype_iso2 = "XF"  if `match' == "BIH"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "BLA"  
         replace lendingtype_iso2 = "XF"  if `match' == "BLR"  
         replace lendingtype_iso2 = "XF"  if `match' == "BLZ"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "BMN"  
         replace lendingtype_iso2 = "XX"  if `match' == "BMU"  
         replace lendingtype_iso2 = "XF"  if `match' == "BOL"  
         replace lendingtype_iso2 = "XF"  if `match' == "BRA"  
         replace lendingtype_iso2 = "XX"  if `match' == "BRB"  
         replace lendingtype_iso2 = "XX"  if `match' == "BRN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "BSS"  
         replace lendingtype_iso2 = "XI"  if `match' == "BTN"  
         replace lendingtype_iso2 = "XF"  if `match' == "BWA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CAA"  
         replace lendingtype_iso2 = "XI"  if `match' == "CAF"  
         replace lendingtype_iso2 = "XX"  if `match' == "CAN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CEA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CEB"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CEU"  
         replace lendingtype_iso2 = "XX"  if `match' == "CHE"  
         replace lendingtype_iso2 = "XX"  if `match' == "CHI"  
         replace lendingtype_iso2 = "XF"  if `match' == "CHL"  
         replace lendingtype_iso2 = "XF"  if `match' == "CHN"  
         replace lendingtype_iso2 = "XI"  if `match' == "CIV"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CLA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CME"  
         replace lendingtype_iso2 = "XH"  if `match' == "CMR"  
         replace lendingtype_iso2 = "XI"  if `match' == "COD"  
         replace lendingtype_iso2 = "XH"  if `match' == "COG"  
         replace lendingtype_iso2 = "XF"  if `match' == "COL"  
         replace lendingtype_iso2 = "XI"  if `match' == "COM"  
         replace lendingtype_iso2 = "XH"  if `match' == "CPV"  
         replace lendingtype_iso2 = "XF"  if `match' == "CRI"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CSA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "CSS"  
         replace lendingtype_iso2 = "XX"  if `match' == "CUB"  
         replace lendingtype_iso2 = "XX"  if `match' == "CUW"  
         replace lendingtype_iso2 = "XX"  if `match' == "CYM"  
         replace lendingtype_iso2 = "XX"  if `match' == "CYP"  
         replace lendingtype_iso2 = "XX"  if `match' == "CZE"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DEA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DEC"  
         replace lendingtype_iso2 = "XX"  if `match' == "DEU"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DFS"  
         replace lendingtype_iso2 = "XI"  if `match' == "DJI"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DLA"  
         replace lendingtype_iso2 = "XH"  if `match' == "DMA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DMN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DNF"  
         replace lendingtype_iso2 = "XX"  if `match' == "DNK"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DNS"  
         replace lendingtype_iso2 = "XF"  if `match' == "DOM"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DSA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DSF"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DSS"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "DXS"  
         replace lendingtype_iso2 = "XF"  if `match' == "DZA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "EAP"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "EAR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "EAS"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "ECA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "ECS"  
         replace lendingtype_iso2 = "XF"  if `match' == "ECU"  
         replace lendingtype_iso2 = "XF"  if `match' == "EGY"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "EMU"  
         replace lendingtype_iso2 = "XI"  if `match' == "ERI"  
         replace lendingtype_iso2 = "XX"  if `match' == "ESP"  
         replace lendingtype_iso2 = "XX"  if `match' == "EST"  
         replace lendingtype_iso2 = "XI"  if `match' == "ETH"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "EUU"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "FCS"  
         replace lendingtype_iso2 = "XX"  if `match' == "FIN"  
         replace lendingtype_iso2 = "XH"  if `match' == "FJI"  
         replace lendingtype_iso2 = "XX"  if `match' == "FRA"  
         replace lendingtype_iso2 = "XX"  if `match' == "FRO"  
         replace lendingtype_iso2 = "XI"  if `match' == "FSM"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "FXS"  
         replace lendingtype_iso2 = "XF"  if `match' == "GAB"  
         replace lendingtype_iso2 = "XX"  if `match' == "GBR"  
         replace lendingtype_iso2 = "XF"  if `match' == "GEO"  
         replace lendingtype_iso2 = "XI"  if `match' == "GHA"  
         replace lendingtype_iso2 = "XX"  if `match' == "GIB"  
         replace lendingtype_iso2 = "XI"  if `match' == "GIN"  
         replace lendingtype_iso2 = "XI"  if `match' == "GMB"  
         replace lendingtype_iso2 = "XI"  if `match' == "GNB"  
         replace lendingtype_iso2 = "XF"  if `match' == "GNQ"  
         replace lendingtype_iso2 = "XX"  if `match' == "GRC"  
         replace lendingtype_iso2 = "XH"  if `match' == "GRD"  
         replace lendingtype_iso2 = "XX"  if `match' == "GRL"  
         replace lendingtype_iso2 = "XF"  if `match' == "GTM"  
         replace lendingtype_iso2 = "XX"  if `match' == "GUM"  
         replace lendingtype_iso2 = "XI"  if `match' == "GUY"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "HIC"  
         replace lendingtype_iso2 = "XX"  if `match' == "HKG"  
         replace lendingtype_iso2 = "XI"  if `match' == "HND"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "HPC"  
         replace lendingtype_iso2 = "XF"  if `match' == "HRV"  
         replace lendingtype_iso2 = "XI"  if `match' == "HTI"  
         replace lendingtype_iso2 = "XX"  if `match' == "HUN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "IBB"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "IBD"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "IBT"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "IDA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "IDB"  
         replace lendingtype_iso2 = "XF"  if `match' == "IDN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "IDX"  
         replace lendingtype_iso2 = "XX"  if `match' == "IMN"  
         replace lendingtype_iso2 = "XF"  if `match' == "IND"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "INX"  
         replace lendingtype_iso2 = "XX"  if `match' == "IRL"  
         replace lendingtype_iso2 = "XF"  if `match' == "IRN"  
         replace lendingtype_iso2 = "XF"  if `match' == "IRQ"  
         replace lendingtype_iso2 = "XX"  if `match' == "ISL"  
         replace lendingtype_iso2 = "XX"  if `match' == "ISR"  
         replace lendingtype_iso2 = "XX"  if `match' == "ITA"  
         replace lendingtype_iso2 = "XF"  if `match' == "JAM"  
         replace lendingtype_iso2 = "XF"  if `match' == "JOR"  
         replace lendingtype_iso2 = "XX"  if `match' == "JPN"  
         replace lendingtype_iso2 = "XF"  if `match' == "KAZ"  
         replace lendingtype_iso2 = "XH"  if `match' == "KEN"  
         replace lendingtype_iso2 = "XI"  if `match' == "KGZ"  
         replace lendingtype_iso2 = "XI"  if `match' == "KHM"  
         replace lendingtype_iso2 = "XI"  if `match' == "KIR"  
         replace lendingtype_iso2 = "XF"  if `match' == "KNA"  
         replace lendingtype_iso2 = "XX"  if `match' == "KOR"  
         replace lendingtype_iso2 = "XX"  if `match' == "KWT"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LAC"  
         replace lendingtype_iso2 = "XI"  if `match' == "LAO"  
         replace lendingtype_iso2 = "XF"  if `match' == "LBN"  
         replace lendingtype_iso2 = "XI"  if `match' == "LBR"  
         replace lendingtype_iso2 = "XF"  if `match' == "LBY"  
         replace lendingtype_iso2 = "XH"  if `match' == "LCA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LCN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LCR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LDC"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LIC"  
         replace lendingtype_iso2 = "XX"  if `match' == "LIE"  
         replace lendingtype_iso2 = "XF"  if `match' == "LKA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LMC"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LMY"  
         replace lendingtype_iso2 = "XI"  if `match' == "LSO"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "LTE"  
         replace lendingtype_iso2 = "XX"  if `match' == "LTU"  
         replace lendingtype_iso2 = "XX"  if `match' == "LUX"  
         replace lendingtype_iso2 = "XX"  if `match' == "LVA"  
         replace lendingtype_iso2 = "XX"  if `match' == "MAC"  
         replace lendingtype_iso2 = "XX"  if `match' == "MAF"  
         replace lendingtype_iso2 = "XF"  if `match' == "MAR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "MCA"  
         replace lendingtype_iso2 = "XX"  if `match' == "MCO"  
         replace lendingtype_iso2 = "XH"  if `match' == "MDA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "MDE"  
         replace lendingtype_iso2 = "XI"  if `match' == "MDG"  
         replace lendingtype_iso2 = "XI"  if `match' == "MDV"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "MEA"  
         replace lendingtype_iso2 = "XF"  if `match' == "MEX"  
         replace lendingtype_iso2 = "XI"  if `match' == "MHL"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "MIC"  
         replace lendingtype_iso2 = "XF"  if `match' == "MKD"  
         replace lendingtype_iso2 = "XI"  if `match' == "MLI"  
         replace lendingtype_iso2 = "XX"  if `match' == "MLT"  
         replace lendingtype_iso2 = "XI"  if `match' == "MMR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "MNA"  
         replace lendingtype_iso2 = "XF"  if `match' == "MNE"  
         replace lendingtype_iso2 = "XH"  if `match' == "MNG"  
         replace lendingtype_iso2 = "XX"  if `match' == "MNP"  
         replace lendingtype_iso2 = "XI"  if `match' == "MOZ"  
         replace lendingtype_iso2 = "XI"  if `match' == "MRT"  
         replace lendingtype_iso2 = "XF"  if `match' == "MUS"  
         replace lendingtype_iso2 = "XI"  if `match' == "MWI"  
         replace lendingtype_iso2 = "XF"  if `match' == "MYS"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "NAC"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "NAF"  
         replace lendingtype_iso2 = "XF"  if `match' == "NAM"  
         replace lendingtype_iso2 = "XX"  if `match' == "NCL"  
         replace lendingtype_iso2 = "XI"  if `match' == "NER"  
         replace lendingtype_iso2 = "XH"  if `match' == "NGA"  
         replace lendingtype_iso2 = "XI"  if `match' == "NIC"  
         replace lendingtype_iso2 = "XX"  if `match' == "NLD"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "NLS"  
         replace lendingtype_iso2 = "XX"  if `match' == "NOR"  
         replace lendingtype_iso2 = "XI"  if `match' == "NPL"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "NRS"  
         replace lendingtype_iso2 = "XF"  if `match' == "NRU"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "NXS"  
         replace lendingtype_iso2 = "XX"  if `match' == "NZL"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "OED"  
         replace lendingtype_iso2 = "XX"  if `match' == "OMN"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "OSS"  
         replace lendingtype_iso2 = "XH"  if `match' == "PAK"  
         replace lendingtype_iso2 = "XF"  if `match' == "PAN"  
         replace lendingtype_iso2 = "XF"  if `match' == "PER"  
         replace lendingtype_iso2 = "XF"  if `match' == "PHL"  
         replace lendingtype_iso2 = "XF"  if `match' == "PLW"  
         replace lendingtype_iso2 = "XH"  if `match' == "PNG"  
         replace lendingtype_iso2 = "XF"  if `match' == "POL"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "PRE"  
         replace lendingtype_iso2 = "XX"  if `match' == "PRI"  
         replace lendingtype_iso2 = "XX"  if `match' == "PRK"  
         replace lendingtype_iso2 = "XX"  if `match' == "PRT"  
         replace lendingtype_iso2 = "XF"  if `match' == "PRY"  
         replace lendingtype_iso2 = "XX"  if `match' == "PSE"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "PSS"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "PST"  
         replace lendingtype_iso2 = "XX"  if `match' == "PYF"  
         replace lendingtype_iso2 = "XX"  if `match' == "QAT"  
         replace lendingtype_iso2 = "XF"  if `match' == "ROU"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "RRS"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "RSO"  
         replace lendingtype_iso2 = "XF"  if `match' == "RUS"  
         replace lendingtype_iso2 = "XI"  if `match' == "RWA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "SAS"  
         replace lendingtype_iso2 = "XX"  if `match' == "SAU"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "SCE"  
         replace lendingtype_iso2 = "XI"  if `match' == "SDN"  
         replace lendingtype_iso2 = "XI"  if `match' == "SEN"  
         replace lendingtype_iso2 = "XX"  if `match' == "SGP"  
         replace lendingtype_iso2 = "XI"  if `match' == "SLB"  
         replace lendingtype_iso2 = "XI"  if `match' == "SLE"  
         replace lendingtype_iso2 = "XF"  if `match' == "SLV"  
         replace lendingtype_iso2 = "XX"  if `match' == "SMR"  
         replace lendingtype_iso2 = "XI"  if `match' == "SOM"  
         replace lendingtype_iso2 = "XF"  if `match' == "SRB"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "SSA"  
         replace lendingtype_iso2 = "XI"  if `match' == "SSD"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "SSF"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "SST"  
         replace lendingtype_iso2 = "XI"  if `match' == "STP"  
         replace lendingtype_iso2 = "XF"  if `match' == "SUR"  
         replace lendingtype_iso2 = "XX"  if `match' == "SVK"  
         replace lendingtype_iso2 = "XX"  if `match' == "SVN"  
         replace lendingtype_iso2 = "XX"  if `match' == "SWE"  
         replace lendingtype_iso2 = "XF"  if `match' == "SWZ"  
         replace lendingtype_iso2 = "XX"  if `match' == "SXM"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "SXZ"  
         replace lendingtype_iso2 = "XF"  if `match' == "SYC"  
         replace lendingtype_iso2 = "XI"  if `match' == "SYR"  
         replace lendingtype_iso2 = "XX"  if `match' == "TCA"  
         replace lendingtype_iso2 = "XI"  if `match' == "TCD"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "TEA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "TEC"  
         replace lendingtype_iso2 = "XI"  if `match' == "TGO"  
         replace lendingtype_iso2 = "XF"  if `match' == "THA"  
         replace lendingtype_iso2 = "XI"  if `match' == "TJK"  
         replace lendingtype_iso2 = "XF"  if `match' == "TKM"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "TLA"  
         replace lendingtype_iso2 = "XH"  if `match' == "TLS"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "TMN"  
         replace lendingtype_iso2 = "XI"  if `match' == "TON"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "TSA"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "TSS"  
         replace lendingtype_iso2 = "XF"  if `match' == "TTO"  
         replace lendingtype_iso2 = "XF"  if `match' == "TUN"  
         replace lendingtype_iso2 = "XF"  if `match' == "TUR"  
         replace lendingtype_iso2 = "XI"  if `match' == "TUV"  
         replace lendingtype_iso2 = "XX"  if `match' == "TWN"  
         replace lendingtype_iso2 = "XI"  if `match' == "TZA"  
         replace lendingtype_iso2 = "XI"  if `match' == "UGA"  
         replace lendingtype_iso2 = "XF"  if `match' == "UKR"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "UMC"  
         replace lendingtype_iso2 = "XF"  if `match' == "URY"  
         replace lendingtype_iso2 = "XX"  if `match' == "USA"  
         replace lendingtype_iso2 = "XH"  if `match' == "UZB"  
         replace lendingtype_iso2 = "XH"  if `match' == "VCT"  
         replace lendingtype_iso2 = "XF"  if `match' == "VEN"  
         replace lendingtype_iso2 = "XX"  if `match' == "VGB"  
         replace lendingtype_iso2 = "XX"  if `match' == "VIR"  
         replace lendingtype_iso2 = "XF"  if `match' == "VNM"  
         replace lendingtype_iso2 = "XI"  if `match' == "VUT"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "WLD"  
         replace lendingtype_iso2 = "XI"  if `match' == "WSM"  
         replace lendingtype_iso2 = "XI"  if `match' == "XKX"  
         replace lendingtype_iso2 = "Aggregates"  if `match' == "XZN"  
         replace lendingtype_iso2 = "XI"  if `match' == "YEM"  
         replace lendingtype_iso2 = "XF"  if `match' == "ZAF"  
         replace lendingtype_iso2 = "XI"  if `match' == "ZMB"  
  
*********************
  
 lab var lendingtype_iso2        "Lending Type Code (ISO 2 digits)" 
  
*********************
  
 end 
