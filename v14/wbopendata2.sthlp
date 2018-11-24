{smcl}
{hline}
{* 20Sept2018 }{...}
{cmd:help wbopendata}{right:dialog:  {bf:{dialog wbopendata}}}
{right: {bf:version 14}}
{hline}

{title:Title}

{p2colset 9 24 22 2}{...}
{p2col :{hi:wbopendata} {hline 2}}World Bank Open Databases.{p_end}
{p2colreset}{...}
{title:Syntax}

{p 6 16 2}
{cmd:wbopendata}{cmd:,} {it:{help wbopendata##Options2:Parameters}} [{it:{help wbopendata##options:Options}}]

{synoptset 27 tabbed}{...}
{synopthdr:Parameters}
{synoptline}
{synopt :{opt country}(acronym)}list of country code (accepts multiples){p_end}
{p 20 20 6}{it:(and)}{p_end}
{synopt :{opt topics}(acronym)}topic code (only accepts one){p_end}
{p 20 20 6}{it:(or)}{p_end}
{synopt :{opt indicator}(acronym)}list of indicator code(accepts multiples){p_end}

{synoptset 27 tabbed}{...}
{synopthdr:Options}
{synoptline}
{synopt :{opt long}} imports the data in the long format. {p_end}
{synopt :{opt clear}} replace data in memory.{p_end}
{synopt :{opt latest}} keep only the latest available value of a single indicator.{p_end}
{synopt :{opt nometadata}} omits the display of the metadata.{p_end}
{synopt :{opt date}{cmd:(}{it:date1}{cmd::}{it:date2}{cmd:)}} time interval.{p_end}
{synopt :{opt language}{cmd:(}{it:language}{cmd:)}} select the language.{p_end}
{synoptline}
{p 4 6 2}
{cmd:wbopendata} requires a connection to the internet and supports the Stata dialogue function ({dialog wbopendata}).{p_end}
 

{marker sections}{...}
{title:Sections}

{pstd}
Sections are presented under the following headings:

		{it:{help wbopendata##desc:Command description}}
		{it:{help wbopendata##param:Parameters description}}
		{it:{help wbopendata##options:Options description}}
		{it:{help wbopendata##Examples:Examples}}
		{it:{help wbopendata##disclaimer:Disclaimer}}
		{it:{help wbopendata##termsofuse:Terms of use}}
		{it:{help wbopendata##howtocite:How to cite}}
		{it:{help wbopendata##references:References}}
		{it:{help wbopendata##acknowled:Acknowledgements}}


{marker desc}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Description}
{pstd}

{p 4 4 2}{cmd:wbopendata} allows Stata users to download over 9,900 indicators from the World Bank databases, including: Development 
Africa Development Indicators; Doing Business; Education Statistics; Enterprise Surveys; Global Development Finance; 
Gender Statistics; Health Nutrition and Population Statistics; International Development Association - Results Measurement System; 
Millennium Development Goals; World Development Indicators; Worldwide Governance Indicators; and LAC Equity Lab. These indicators include information 
from over 256 countries and regions, since 1960.{p_end}

{p 4 4 2}Users can chose from one of three of the {cmd:languages} supported by the database (and Stata), namely, English, Spanish, or French.{p_end}

{p 4 4 2}Five possible downloads options are currently supported:{p_end}

{synopt:{opt country}} over 1,000 indicators for all selected years for a single country (WDI Catalogue).{p_end}
{synopt:{opt topics}} WDI indicators within a specific topic, for all selected years and all countries (WDI Catalogue).{p_end}
{synopt:{opt indicator}} all selected years for all countries for a single indicator (from any of the catalogues: 9,000+ series).{p_end}
{synopt:{opt indicator and country}}  all selected years for selected countries for a single indicator (from any of the catalogues: 9,000+ series).{p_end}
{synopt:{opt multiple indicator}} all selected years for selected indicators separated by ; (from any of the catalogues: 9,000+ series).{p_end}

{p 4 4 2}Users can also choose to have the data displayed in either the {cmd:wide} or {cmd:long} format (wide is the default option).
Note that the reshape is the local machine, so it will require the appropriate amount of RAM to work properly.{p_end}

{p 4 4 2}{cmd:wbopendata} draws from the main  World Bank collections of development indicators, compiled from
officially-recognized international sources. It presents the most current and accurate global development
data available, and includes national, regional and global estimates.{p_end}

{p 4 4 2}The access to this databases is made possible by the {it:World Bank's Open Data Initiative} which provide 
open full access to {browse "http://data.worldbank.org/" : World Bank databases}.{p_end}


{marker param}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Parameters description}

{dlgtab: Parameters}

{synopt:{opt country(string)}}{help wbopendata##countries:Countries and Regions Abbreviations and acronyms}. If solely specified, this option
will return all the WDI indicators (1,076 series) for a single country or region (no multiple country selection allowed in 
this case). If this option is selected jointly with a specific indicator, the output is a series for a specific 
country or region, or multiple countries or region. When selecting multiple countries please use the three letters code, separated by 
a semicolon (;), with no spaces.{p_end}

{synopt:{opt topics(numlist)}}{help wbopendata##topics:Topic List} 21 topic lists are curently supported and include Agriculture & Rural Development; 
Aid Effectiveness; Economy & Growth; Education; Energy & Mining; Environment; Financial Sector; Health; Infrastructure; Social Protection & Labor; 
Poverty; Private Sector; Public Sector; Science & Technology; Social Development; Urban Development; Gender; Millenium development goals; Climate Change; 
External Debt; and, Trade (only one topic collection can be requested at the time).{p_end}

{synopt:{opt indicator(string)}}{help wbopendata_indicators##indicators:Indicators List} list of indicator codes (All series). When selecting multiple 
indicators please use semicolon (;), to separate differenet indicatos.{p_end}


{marker options}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Options description}

{dlgtab:Options}

{synopt:{opt long}} imports the data in the long format. The default option is to import the data in the wide format. It is important 
note that {cmd:wbopendata} uses Stata resources to reshape the variables, hence user has to make sure that Stata will have sufficient 
RAM to complete this operation.{p_end}

{synopt:{opt clear}} replace data in memory.{p_end}

{synopt:{opt latest}} keep only the latest available value of a single indicator (it only work if the data in the long format).{p_end}

{synopt:{opt nometadata}} omits the display of the metadata information from the series. Metadata information is only available when downloading 
specific series (indicator option). The metadata available include information on the name of the series, the source, a detailed description 
of the indicator, and the organization responsible for compiling this indicator.{p_end}

{synopt:{opt year:(year1:year2)}} allow users to select a specific time interval. Year1=Initial year; Year2=Final year.{p_end}
           
{synopt:{opt language(option)}}three languages are supported: The default language is English.{p_end}

{center: English:  	{cmd:en}          }
{center: Spanish:  	{cmd:es}          }
{center: French:   	{cmd:fr}          }
{center: Arabic:  	{cmd:ar}          }
{center: Chinese:   {cmd:zh}          }

{marker countries}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Country Acronyms}

{synoptset 33 tabbed}{...}
{synopthdr: Countries and Regions}
{synoptline}
{synopt:{opt  ABW }} Aruba {p_end}
{synopt:{opt  AFG }} Afghanistan {p_end}
{synopt:{opt  AFR }} Africa {p_end}
{synopt:{opt  AGO }} Angola {p_end}
{synopt:{opt  ALB }} Albania {p_end}
{synopt:{opt  AND }} Andorra {p_end}
{synopt:{opt  ANR }} Andean Region {p_end}
{synopt:{opt  ARB }} Arab World {p_end}
{synopt:{opt  ARE }} United Arab Emirates {p_end}
{synopt:{opt  ARG }} Argentina {p_end}
{synopt:{opt  ARM }} Armenia {p_end}
{synopt:{opt  ASM }} American Samoa {p_end}
{synopt:{opt  ATG }} Antigua and Barbuda {p_end}
{synopt:{opt  AUS }} Australia {p_end}
{synopt:{opt  AUT }} Austria {p_end}
{synopt:{opt  AZE }} Azerbaijan {p_end}
{synopt:{opt  BDI }} Burundi {p_end}
{synopt:{opt  BEL }} Belgium {p_end}
{synopt:{opt  BEN }} Benin {p_end}
{synopt:{opt  BFA }} Burkina Faso {p_end}
{synopt:{opt  BGD }} Bangladesh {p_end}
{synopt:{opt  BGR }} Bulgaria {p_end}
{synopt:{opt  BHR }} Bahrain {p_end}
{synopt:{opt  BHS }} Bahamas, The {p_end}
{synopt:{opt  BIH }} Bosnia and Herzegovina {p_end}
{synopt:{opt  BLR }} Belarus {p_end}
{synopt:{opt  BLZ }} Belize {p_end}
{synopt:{opt  BMU }} Bermuda {p_end}
{synopt:{opt  BOL }} Bolivia {p_end}
{synopt:{opt  BRA }} Brazil {p_end}
{synopt:{opt  BRB }} Barbados {p_end}
{synopt:{opt  BRN }} Brunei Darussalam {p_end}
{synopt:{opt  BTN }} Bhutan {p_end}
{synopt:{opt  BWA }} Botswana {p_end}
{synopt:{opt  CAA }} Sub-Saharan Africa (IFC classification) {p_end}
{synopt:{opt  CAF }} Central African Republic {p_end}
{synopt:{opt  CAN }} Canada {p_end}
{synopt:{opt  CEA }} East Asia and the Pacific (IFC classification) {p_end}
{synopt:{opt  CEU }} Europe and Central Asia (IFC classification) {p_end}
{synopt:{opt  CHE }} Switzerland {p_end}
{synopt:{opt  CHI }} Channel Islands {p_end}
{synopt:{opt  CHL }} Chile {p_end}
{synopt:{opt  CHN }} China {p_end}
{synopt:{opt  CIV }} Cote d'Ivoire {p_end}
{synopt:{opt  CLA }} Latin America and the Caribbean (IFC classification) {p_end}
{synopt:{opt  CME }} Middle East and North Africa (IFC classification) {p_end}
{synopt:{opt  CMR }} Cameroon {p_end}
{synopt:{opt  COD }} Congo, Dem. Rep. {p_end}
{synopt:{opt  COG }} Congo, Rep. {p_end}
{synopt:{opt  COL }} Colombia {p_end}
{synopt:{opt  COM }} Comoros {p_end}
{synopt:{opt  CPV }} Cabo Verde {p_end}
{synopt:{opt  CRI }} Costa Rica {p_end}
{synopt:{opt  CSA }} South Asia (IFC classification) {p_end}
{synopt:{opt  CSS }} Caribbean small states {p_end}
{synopt:{opt  CUB }} Cuba {p_end}
{synopt:{opt  CUW }} Curacao {p_end}
{synopt:{opt  CYM }} Cayman Islands {p_end}
{synopt:{opt  CYP }} Cyprus {p_end}
{synopt:{opt  CZE }} Czech Republic {p_end}
{synopt:{opt  DEU }} Germany {p_end}
{synopt:{opt  DJI }} Djibouti {p_end}
{synopt:{opt  DMA }} Dominica {p_end}
{synopt:{opt  DNK }} Denmark {p_end}
{synopt:{opt  DOM }} Dominican Republic {p_end}
{synopt:{opt  DZA }} Algeria {p_end}
{synopt:{opt  EAP }} East Asia & Pacific (developing only) {p_end}
{synopt:{opt  EAS }} East Asia & Pacific (all income levels) {p_end}
{synopt:{opt  ECA }} Europe & Central Asia (developing only) {p_end}
{synopt:{opt  ECS }} Europe & Central Asia (all income levels) {p_end}
{synopt:{opt  ECU }} Ecuador {p_end}
{synopt:{opt  EGY }} Egypt, Arab Rep. {p_end}
{synopt:{opt  EMU }} Euro area {p_end}
{synopt:{opt  ERI }} Eritrea {p_end}
{synopt:{opt  ESP }} Spain {p_end}
{synopt:{opt  EST }} Estonia {p_end}
{synopt:{opt  ETH }} Ethiopia {p_end}
{synopt:{opt  EUU }} European Union {p_end}
{synopt:{opt  FIN }} Finland {p_end}
{synopt:{opt  FJI }} Fiji {p_end}
{synopt:{opt  FRA }} France {p_end}
{synopt:{opt  FRO }} Faeroe Islands {p_end}
{synopt:{opt  FSM }} Micronesia, Fed. Sts. {p_end}
{synopt:{opt  GAB }} Gabon {p_end}
{synopt:{opt  GBR }} United Kingdom {p_end}
{synopt:{opt  GEO }} Georgia {p_end}
{synopt:{opt  GHA }} Ghana {p_end}
{synopt:{opt  GIN }} Guinea {p_end}
{synopt:{opt  GMB }} Gambia, The {p_end}
{synopt:{opt  GNB }} Guinea-Bissau {p_end}
{synopt:{opt  GNQ }} Equatorial Guinea {p_end}
{synopt:{opt  GRC }} Greece {p_end}
{synopt:{opt  GRD }} Grenada {p_end}
{synopt:{opt  GRL }} Greenland {p_end}
{synopt:{opt  GTM }} Guatemala {p_end}
{synopt:{opt  GUM }} Guam {p_end}
{synopt:{opt  GUY }} Guyana {p_end}
{synopt:{opt  HIC }} High income {p_end}
{synopt:{opt  HKG }} Hong Kong SAR, China {p_end}
{synopt:{opt  HND }} Honduras {p_end}
{synopt:{opt  HPC }} Heavily indebted poor countries (HIPC) {p_end}
{synopt:{opt  HRV }} Croatia {p_end}
{synopt:{opt  HTI }} Haiti {p_end}
{synopt:{opt  HUN }} Hungary {p_end}
{synopt:{opt  IDN }} Indonesia {p_end}
{synopt:{opt  IMN }} Isle of Man {p_end}
{synopt:{opt  IND }} India {p_end}
{synopt:{opt  INX }} Not classified {p_end}
{synopt:{opt  IRL }} Ireland {p_end}
{synopt:{opt  IRN }} Iran, Islamic Rep. {p_end}
{synopt:{opt  IRQ }} Iraq {p_end}
{synopt:{opt  ISL }} Iceland {p_end}
{synopt:{opt  ISR }} Israel {p_end}
{synopt:{opt  ITA }} Italy {p_end}
{synopt:{opt  JAM }} Jamaica {p_end}
{synopt:{opt  JOR }} Jordan {p_end}
{synopt:{opt  JPN }} Japan {p_end}
{synopt:{opt  KAZ }} Kazakhstan {p_end}
{synopt:{opt  KEN }} Kenya {p_end}
{synopt:{opt  KGZ }} Kyrgyz Republic {p_end}
{synopt:{opt  KHM }} Cambodia {p_end}
{synopt:{opt  KIR }} Kiribati {p_end}
{synopt:{opt  KNA }} St. Kitts and Nevis {p_end}
{synopt:{opt  KOR }} Korea, Rep. {p_end}
{synopt:{opt  KSV }} Kosovo {p_end}
{synopt:{opt  KWT }} Kuwait {p_end}
{synopt:{opt  LAC }} Latin America & Caribbean (developing only) {p_end}
{synopt:{opt  LAO }} Lao PDR {p_end}
{synopt:{opt  LBN }} Lebanon {p_end}
{synopt:{opt  LBR }} Liberia {p_end}
{synopt:{opt  LBY }} Libya {p_end}
{synopt:{opt  LCA }} St. Lucia {p_end}
{synopt:{opt  LCN }} Latin America & Caribbean (all income levels) {p_end}
{synopt:{opt  LCR }} Latin America and the Caribbean {p_end}
{synopt:{opt  LDC }} Least developed countries: UN classification {p_end}
{synopt:{opt  LIC }} Low income {p_end}
{synopt:{opt  LIE }} Liechtenstein {p_end}
{synopt:{opt  LKA }} Sri Lanka {p_end}
{synopt:{opt  LMC }} Lower middle income {p_end}
{synopt:{opt  LMY }} Low & middle income {p_end}
{synopt:{opt  LSO }} Lesotho {p_end}
{synopt:{opt  LTU }} Lithuania {p_end}
{synopt:{opt  LUX }} Luxembourg {p_end}
{synopt:{opt  LVA }} Latvia {p_end}
{synopt:{opt  MAC }} Macao SAR, China {p_end}
{synopt:{opt  MAF }} St. Martin (French part) {p_end}
{synopt:{opt  MAR }} Morocco {p_end}
{synopt:{opt  MCA }} Mexico and Central America {p_end}
{synopt:{opt  MCO }} Monaco {p_end}
{synopt:{opt  MDA }} Moldova {p_end}
{synopt:{opt  MDG }} Madagascar {p_end}
{synopt:{opt  MDV }} Maldives {p_end}
{synopt:{opt  MEA }} Middle East & North Africa (all income levels) {p_end}
{synopt:{opt  MEX }} Mexico {p_end}
{synopt:{opt  MHL }} Marshall Islands {p_end}
{synopt:{opt  MIC }} Middle income {p_end}
{synopt:{opt  MKD }} Macedonia, FYR {p_end}
{synopt:{opt  MLI }} Mali {p_end}
{synopt:{opt  MLT }} Malta {p_end}
{synopt:{opt  MMR }} Myanmar {p_end}
{synopt:{opt  MNA }} Middle East & North Africa (developing only) {p_end}
{synopt:{opt  MNE }} Montenegro {p_end}
{synopt:{opt  MNG }} Mongolia {p_end}
{synopt:{opt  MNP }} Northern Mariana Islands {p_end}
{synopt:{opt  MOZ }} Mozambique {p_end}
{synopt:{opt  MRT }} Mauritania {p_end}
{synopt:{opt  MUS }} Mauritius {p_end}
{synopt:{opt  MWI }} Malawi {p_end}
{synopt:{opt  MYS }} Malaysia {p_end}
{synopt:{opt  NAC }} North America {p_end}
{synopt:{opt  NAF }} North Africa {p_end}
{synopt:{opt  NAM }} Namibia {p_end}
{synopt:{opt  NCL }} New Caledonia {p_end}
{synopt:{opt  NER }} Niger {p_end}
{synopt:{opt  NGA }} Nigeria {p_end}
{synopt:{opt  NIC }} Nicaragua {p_end}
{synopt:{opt  NLD }} Netherlands {p_end}
{synopt:{opt  NOC }} High income: nonOECD {p_end}
{synopt:{opt  NOR }} Norway {p_end}
{synopt:{opt  NPL }} Nepal {p_end}
{synopt:{opt  NZL }} New Zealand {p_end}
{synopt:{opt  OEC }} High income: OECD {p_end}
{synopt:{opt  OED }} OECD members {p_end}
{synopt:{opt  OMN }} Oman {p_end}
{synopt:{opt  OSS }} Other small states {p_end}
{synopt:{opt  PAK }} Pakistan {p_end}
{synopt:{opt  PAN }} Panama {p_end}
{synopt:{opt  PER }} Peru {p_end}
{synopt:{opt  PHL }} Philippines {p_end}
{synopt:{opt  PLW }} Palau {p_end}
{synopt:{opt  PNG }} Papua New Guinea {p_end}
{synopt:{opt  POL }} Poland {p_end}
{synopt:{opt  PRI }} Puerto Rico {p_end}
{synopt:{opt  PRK }} Korea, Dem. Rep. {p_end}
{synopt:{opt  PRT }} Portugal {p_end}
{synopt:{opt  PRY }} Paraguay {p_end}
{synopt:{opt  PSE }} West Bank and Gaza {p_end}
{synopt:{opt  PSS }} Pacific island small states {p_end}
{synopt:{opt  PYF }} French Polynesia {p_end}
{synopt:{opt  QAT }} Qatar {p_end}
{synopt:{opt  ROU }} Romania {p_end}
{synopt:{opt  RUS }} Russian Federation {p_end}
{synopt:{opt  RWA }} Rwanda {p_end}
{synopt:{opt  SAS }} South Asia {p_end}
{synopt:{opt  SAU }} Saudi Arabia {p_end}
{synopt:{opt  SCE }} Southern Cone Extended {p_end}
{synopt:{opt  SDN }} Sudan {p_end}
{synopt:{opt  SEN }} Senegal {p_end}
{synopt:{opt  SGP }} Singapore {p_end}
{synopt:{opt  SLB }} Solomon Islands {p_end}
{synopt:{opt  SLE }} Sierra Leone {p_end}
{synopt:{opt  SLV }} El Salvador {p_end}
{synopt:{opt  SMR }} San Marino {p_end}
{synopt:{opt  SOM }} Somalia {p_end}
{synopt:{opt  SRB }} Serbia {p_end}
{synopt:{opt  SSA }} Sub-Saharan Africa (developing only) {p_end}
{synopt:{opt  SSD }} South Sudan {p_end}
{synopt:{opt  SSF }} Sub-Saharan Africa (all income levels) {p_end}
{synopt:{opt  SST }} Small states {p_end}
{synopt:{opt  STP }} Sao Tome and Principe {p_end}
{synopt:{opt  SUR }} Suriname {p_end}
{synopt:{opt  SVK }} Slovak Republic {p_end}
{synopt:{opt  SVN }} Slovenia {p_end}
{synopt:{opt  SWE }} Sweden {p_end}
{synopt:{opt  SWZ }} Swaziland {p_end}
{synopt:{opt  SXM }} Sint Maarten (Dutch part) {p_end}
{synopt:{opt  SXZ }} Sub-Saharan Africa excluding South Africa {p_end}
{synopt:{opt  SYC }} Seychelles {p_end}
{synopt:{opt  SYR }} Syrian Arab Republic {p_end}
{synopt:{opt  TCA }} Turks and Caicos Islands {p_end}
{synopt:{opt  TCD }} Chad {p_end}
{synopt:{opt  TGO }} Togo {p_end}
{synopt:{opt  THA }} Thailand {p_end}
{synopt:{opt  TJK }} Tajikistan {p_end}
{synopt:{opt  TKM }} Turkmenistan {p_end}
{synopt:{opt  TLS }} Timor-Leste {p_end}
{synopt:{opt  TON }} Tonga {p_end}
{synopt:{opt  TTO }} Trinidad and Tobago {p_end}
{synopt:{opt  TUN }} Tunisia {p_end}
{synopt:{opt  TUR }} Turkey {p_end}
{synopt:{opt  TUV }} Tuvalu {p_end}
{synopt:{opt  TZA }} Tanzania {p_end}
{synopt:{opt  UGA }} Uganda {p_end}
{synopt:{opt  UKR }} Ukraine {p_end}
{synopt:{opt  UMC }} Upper middle income {p_end}
{synopt:{opt  URY }} Uruguay {p_end}
{synopt:{opt  USA }} United States {p_end}
{synopt:{opt  UZB }} Uzbekistan {p_end}
{synopt:{opt  VCT }} St. Vincent and the Grenadines {p_end}
{synopt:{opt  VEN }} Venezuela, RB {p_end}
{synopt:{opt  VIR }} Virgin Islands (U.S.) {p_end}
{synopt:{opt  VNM }} Vietnam {p_end}
{synopt:{opt  VUT }} Vanuatu {p_end}
{synopt:{opt  WLD }} World {p_end}
{synopt:{opt  WSM }} Samoa {p_end}
{synopt:{opt  XZN }} Sub-Saharan Africa excluding South Africa and Nigeria {p_end}
{synopt:{opt  YEM }} Yemen, Rep. {p_end}
{synopt:{opt  ZAF }} South Africa {p_end}
{synopt:{opt  ZMB }} Zambia {p_end}
{synopt:{opt  ZWE }} Zimbabwe {p_end}
    


{marker topics}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Topic List}
{synoptset 33 tabbed}{...}


{synopthdr: Topic Code}
{synoptline}

{synopt:{opt   1 - Agriculture & Rural Development}} For the 70 percent of the world's poor who live in rural areas, agriculture is the main source of income and employment. But depletion and degradation of land and water pose serious challenges to producing enough food and other agricultural products to sustain livelihoods here and meet the needs of urban populations. Data presented here include measures of agricultural inputs, outputs, and productivity compiled by the UN's Food and Agriculture Organization. {p_end}

{synopt:{opt   2 - Aid Effectiveness}} Aid effectiveness is the impact that aid has in reducing poverty and inequality, increasing growth, building capacity, and accelerating achievement of the Millennium Development Goals set by the international community. Indicators here cover aid received as well as progress in reducing poverty and improving education, health, and other measures of human welfare. {p_end}

{synopt:{opt   3 - Economy & Growth}} Economic growth is central to economic development. When national income grows, real people benefit. While there is no known formula for stimulating economic growth, data can help policy-makers better understand their countries' economic situations and guide any work toward improvement. Data here covers measures of economic growth, such as gross domestic product (GDP) and gross national income (GNI). It also includes indicators representing factors known to be relevant to economic growth, such as capital stock, employment, investment, savings, consumption, government spending, imports, and exports. {p_end}

{synopt:{opt   4 - Education}} Education is one of the most powerful instruments for reducing poverty and inequality and lays a foundation for sustained economic growth. The World Bank compiles data on education inputs, participation, efficiency, and outcomes. Data on education are compiled by the United Nations Educational, Scientific, and Cultural Organization (UNESCO) Institute for Statistics from official responses to surveys and from reports provided by education authorities in each country. {p_end}

{synopt:{opt   5 - Energy & Mining}} The world economy needs ever-increasing amounts of energy to sustain economic growth, raise living standards, and reduce poverty. But today's trends in energy use are not sustainable. As the world's population grows and economies become more industrialized, nonrenewable energy sources will become scarcer and more costly. Data here on energy production, use, dependency, and efficiency are compiled by the World Bank from the International Energy Agency and the Carbon Dioxide Information Analysis Center. {p_end}

{synopt:{opt   6 - Environment}} Natural and man-made environmental resources – fresh water, clean air, forests, grasslands, marine resources, and agro-ecosystems – provide sustenance and a foundation for social and economic development.  The need to safeguard these resources crosses all borders.  Today, the World Bank is one of the key promoters and financiers of environmental upgrading in the developing world. Data here cover forests, biodiversity, emissions, and pollution. Other indicators relevant to the environment are found under data pages for Agriculture & Rural Development, Energy & Mining, Infrastructure, and Urban Development. {p_end}

{synopt:{opt   7 - Financial Sector}} An economy's financial markets are critical to its overall development. Banking systems and stock markets enhance growth, the main factor in poverty reduction. Strong financial systems provide reliable and accessible information that lowers transaction costs, which in turn bolsters resource allocation and economic growth. Indicators here include the size and liquidity of stock markets; the accessibility, stability, and efficiency of financial systems; and international migration and workers\ remittances, which affect growth and social welfare in both sending and receiving countries. {p_end}

{synopt:{opt   8 - Health}} Improving health is central to the Millennium Development Goals, and the public sector is the main provider of health care in developing countries. To reduce inequities, many countries have emphasized primary health care, including immunization, sanitation, access to safe drinking water, and safe motherhood initiatives.  Data here cover health systems, disease prevention, reproductive health, nutrition, and population dynamics. Data are from the United Nations Population Division, World Health Organization, United Nations Children's Fund, the Joint United Nations Programme on HIV/AIDS, and various other sources. {p_end}

{synopt:{opt   9 - Infrastructure}} Infrastructure helps determine the success of manufacturing and agricultural activities. Investments in water, sanitation, energy, housing, and transport also improve lives and help reduce poverty. And new information and communication technologies promote growth, improve delivery of health and other services, expand the reach of education, and support social and cultural advances. Data here are compiled from such sources as the International Road Federation, Containerisation International, the International Civil Aviation Organization, the International Energy Association, and the International Telecommunications Union. {p_end}

{synopt:{opt   10 - Social Protection & Labor}} The supply of labor available in an economy includes people who are employed, those who are unemployed but seeking work, and first-time job-seekers. Not everyone who works is included: unpaid workers, family workers, and students are often omitted, while some countries do not count members of the armed forces. Data on labor and employment are compiled by the International Labour Organization (ILO) from labor force surveys, censuses, establishment censuses and surveys, and administrative records such as employment exchange registers and unemployment insurance schemes. {p_end}

{synopt:{opt   11 - Poverty}} For countries with an active poverty monitoring program, the World Bank—in collaboration with national institutions, other development agencies, and civil society—regularly conducts analytical work to assess the extent and causes of poverty and inequality, examine the impact of growth and public policy, and review household survey data and measurement methods.  Data here includes poverty and inequality measures generated from analytical reports, from national poverty monitoring programs, and from the World Bank’s Development Research Group which has been producing internationally comparable and global poverty estimates and lines since 1990. {p_end}

{synopt:{opt   12 - Private Sector}} Private markets drive economic growth, tapping initiative and investment to create productive jobs and raise incomes. Trade is also a driver of economic growth as it integrates developing countries into the world economy and generates benefits for their people.  Data on the private sector and trade are from the World Bank Group's Private Participation in Infrastructure Project Database, Enterprise Surveys, and Doing Business Indicators, as well as from the International Monetary Fund's Balance of Payments database and International Financial Statistics, the UN Commission on Trade and Development, the World Trade Organization, and various other sources. {p_end}

{synopt:{opt   13 - Public Sector}} Effective governments improve people's standard of living by ensuring access to essential services –  health, education, water and sanitation, electricity, transport – and the opportunity to live and work in peace and security. Data here includes World Bank staff assessments of country performance in economic management, structural policies, policies for social inclusion and equity, and public sector management and institutions for the poorest countries. Also included are indicators on revenues and expenses from the International Monetary Fund's Government Finance Statistics, and on tax policies from various sources. {p_end}

{synopt:{opt   14 - Science & Technology}} Technological innovation, often fueled by governments, drives industrial growth and helps raise living standards. Data here aims to shed light on countries technology base: research and development, scientific and technical journal articles, high-technology exports, royalty and license fees, and patents and trademarks. Sources include the UNESCO Institute for Statistics, the U.S. National Science Board, the UN Statistics Division, the International Monetary Fund, and the World Intellectual Property Organization. {p_end}

{synopt:{opt   15 - Social Development}} Data here cover child labor, gender issues, refugees, and asylum seekers. Children in many countries work long hours, often combining studying with work for pay. The data on their paid work are from household surveys conducted by the International Labour Organization (ILO), the United Nations Children's Fund (UNICEF), the World Bank, and national statistical offices. Gender disparities are measured using a compilation of data on key topics such as education, health, labor force participation, and political participation.  Data on refugees are from the United Nations High Commissioner for Refugees complemented by statistics on Palestinian refugees under the mandate of the United Nations Relief and Works Agency. {p_end}

{synopt:{opt   16 - Urban Development}} Cities can be tremendously efficient. It is easier to provide water and sanitation to people living closer together, while access to health, education, and other social and cultural services is also much more readily available. However, as cities grow, the cost of meeting basic needs increases, as does the strain on the environment and natural resources. Data on urbanization, traffic and congestion, and air pollution are from the United Nations Population Division, World Health Organization, International Road Federation, World Resources Institute, and other sources. {p_end}

{synopt:{opt   17 - Gender}} Women's empowerment and the promotion of gender equality are key to achieving sustainable development. Greater gender equality can enhance economic efficiency and improve other development outcomes by removing barriers that prevent women from having the same access as men to human resource endowments, rights, and economic opportunities.  Giving women access to equal opportunities allows them to emerge as social and economic actors, influencing and shaping more inclusive policies.  Improving women’s status also leads to more investment in their children’s education, health, and overall wellbeing.  Data here covers demography, education, health, labor force and employment, and political participation. {p_end}

{synopt:{opt   18 - Millenium development goals}}  {p_end}

{synopt:{opt   19 - Climate Change}} Climate change is expected to hit developing countries the hardest. Its effects—higher temperatures, changes in precipitation patterns, rising sea levels, and more frequent weather-related disasters—pose risks for agriculture, food, and water supplies. At stake are recent gains in the fight against poverty, hunger and disease, and the lives and livelihoods of billions of people in developing countries. Addressing climate change requires unprecedented global cooperation across borders. The World Bank Group is helping support developing countries and contributing to a global solution, while tailoring our approach to the differing needs of developing country partners.  Data here cover climate systems, exposure to climate impacts, resilience, greenhouse gas emissions, and energy use.  Other indicators relevant to climate change are found under other data pages, particularly Environment, Agriculture & Rural Development, Energy & Mining, Health, Infrastructure, Poverty, and Urban Development. {p_end}

{synopt:{opt   20 - External Debt}} Debt statistics provide a detailed picture of debt stocks and flows of developing countries. Data presented as part of the Quarterly External Debt Statistics takes a closer look at the external debt of high-income countries and emerging markets to enable a more complete understanding of global financial flows. The Quarterly Public Sector Debt database provides further data on public sector valuation methods, debt instruments, and clearly defined tiers of debt for central, state and local government, as well as extra-budgetary agencies and funds. Data are gathered from national statistical organizations and central banks as well as by various major multilateral institutions and World Bank staff. {p_end}

{synopt:{opt   21 - Trade}} Trade is a key means to fight poverty and achieve the Millennium Development Goals, specifically by improving developing country access to markets, and supporting a rules based, predictable trading system. In cooperation with other international development partners, the World Bank launched the Transparency in Trade Initiative to provide free and easy access to data on country-specific trade policies. {p_end}

{marker Examples}{...}
{title:Examples}{p 50 20 2}{p_end}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{pstd}

{p 8 12}{stata "wbopendata, country(chn - China) clear" :. wbopendata, country(chn - China) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear" :. wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear" :. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear" :. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear}{p_end}

{p 8 12}{stata "wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear" :. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long": . wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long}{p_end}
 
{cmd}
        . tempfile tmp
        . wbopendata, language(en - English) indicator(it.cel.sets.p2) long clear latest
        . sort countrycode
        . save `tmp', replace
        . sysuse world-d, clear
        . merge countrycode using `tmp'
        . sum year
        . local avg = string(`r(mean)',"%16.1f")
        . spmap  it_cel_sets_p2 using "world-c.dta", id(_ID)                                  ///
                clnumber(20) fcolor(Reds2) ocolor(none ..)                                  ///
                title("Mobile cellular subscriptions (per 100 people)", size(*1.2))         ///
                legstyle(3) legend(ring(1) position(3))                                     ///
                note("Source: World Development Indicators (latest available year: `avg') using ///
                Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, ///
                Statistical Software Components S457234 Boston College Department of Economics.", size(*.7)){p_end} 
{txt}      ({stata "wbopendata_examples example01":click to run})

{cmd}
        . wbopendata, indicator(si.pov.2day ) clear long
        . drop if  si_pov_2day == .
        . sort  countryname year
        . bysort  countryname : gen diff_pov = (si_pov_2day-si_pov_2day[_n-1])/(year-year[_n-1])
        . encode regioncode, gen(reg)
        . encode countryname, gen(reg2)
        . keep if region == "Aggregates"
        . alorenz diff_pov, gp points(20) fullview  xdecrease markvar(reg2)  ///                                         
            ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional ///
            episodes of poverty reduction (%)") legend(off) title("Poverty Reduction") ///
            legend(off) note("Source: World Development Indicators using Azevedo, J.P. ///
            (2011) wbopendata: Stata module to " "access World Bank databases, Statistical ///
            Software Components S457234 Boston College Department of Economics.", size(*.7)){p_end} 
{txt}      ({stata "wbopendata_examples example02":click to run})

{cmd}
        . wbopendata, indicator(si.pov.2day ) clear long
        . drop if  si_pov_2day == .
        . sort  countryname year
        . keep if region == "Aggregates"
        . bysort  countryname : gen diff_pov = (si_pov_2day-si_pov_2day[_n-1])/(year-year[_n-1])
        . gen baseline = si_pov_2day if year == 1990
        . sort countryname baseline
        . bysort countryname : replace baseline = baseline[1] if baseline == .
        . gen mdg1 = baseline/2
        . gen present = si_pov_2day if year == 2008
        . sort countryname present
        . bysort countryname : replace present = present[1] if present == .
        . gen target = ((baseline-mdg1)/(2008-1990))*(2015-1990)
        . sort countryname year
        . gen angel45x = .
        . gen angle45y = .
        . replace angel45x = 0 in 1
        . replace angle45y = 0 in 1
        . replace angel45x = 80 in 2
        . replace angle45y = 80 in 2
        . graph twoway ///
               (scatter present  target  if year == 2008, mlabel( countrycode))    ///
               (line  angle45y angel45x ),                                         ///
                   legend(off) xtitle("Target for 2008")  ytitle(Present)          ///
                   title("MDG 1b - 2 USD")                                         ///
                   note("Source: World Development Indicators (latest available year: 2008) ///
                   using Azevedo, J.P. (2011) wbopendata: Stata module to " "access ///
                   World Bank databases, Statistical Software Components S457234 Boston ///
                    College Department of Economics.", size(*.7)){p_end} 
{txt}      ({stata "wbopendata_examples example03":click to run})


{cmd}
       . wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

       . graph twoway ///
           (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.6)) ///
           (scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8) ///
           mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
           (lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
               xtitle("GDP per capita, PPP (constant 2005 international $)") ///
               ytitle("Poverty headcount ratio at 1.25 dollar-a-day") ///
               legend(off) ///
               note("Source: World Development Indicators (latest available year as off 2012-08-08) ///
                using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, ///
                 Statistical Software Components S457234 Boston College Department of Economics.", /// 
                 size(*.7)){p_end} 

{txt}      ({stata "wbopendata_examples example04":click to run})

{marker disclaimer}{...}
{title:Disclaimer}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{p 4 4 2}Users should not use {cmd:wbopendata} without checking first for more detailed information on the 
definitions of each {browse "http://data.worldbank.org/indicator/":indicator} 
and {browse "http://data.worldbank.org/data-catalog/":data-catalogues} . The indicators names and codes used 
by {cmd:wbopendata} are precisely the same used in the World Bank data catalogue in order to facilitate such 
cross reference.{p_end}

{p 4 4 2}When downloading specific series, through the indicator options, {cmd:wbopendata} will by default display in the Stata results window the metadata available for this 
particular series, including information on the name of the series, the source, a detailed description of the indicator, and the organization 
responsible for compiling this indicator.{p_end}

{marker termsofuse}{...}
{title:Terms of use {cmd:World Bank Data}}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{p 8 12 2}The use of World Bank datasets listed in the Data Catalog is governed by a specific 
{browse "http://data.worldbank.org/summary-terms-of-use/":Terms of Use for World Bank Data}. 
The terms of use of the APIs is governed by {browse "http://go.worldbank.org/C09SUA7BK0/":the World Bank Terms and Conditions}.{p_end}


{marker howtocite}{...}
{title:Thanks for citing {cmd:wbopendata} as follows}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

{p 8 12 2}Azevedo, J.P. (2011) "wbopendata: Stata module to access World Bank databases," Statistical Software Components S457234, Boston College Department of 
Economics.{browse "http://ideas.repec.org/c/boc/bocode/s457234.html"}{p_end}

{p 8 12 2}Please make reference to the date when the database was downloaded, as statistics may change.{p_end}


{marker references}{...}
{title:References}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

    {p 4 4 2}David C. Elliott, 2002. "TKNZ: Stata module to tokenize string into named macros," Statistical Software Components
S426302, Boston College Department of Economics, revised 17 Oct 2006.{p_end} 

{marker acknowled}{...}
{title:Acknowledgements}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

    {p 4 4 2}This program was developed by Joao Pedro Azevedo.{p_end} 
    {p 4 4 2}A special thanks to the World Bank API team, in particular, Malarvizhi Veerappan, Lakshmikanthan Subramanian, Shanmugam Natarajan, and Ugendran Machakkalai.{p_end}
    {p 4 4 2}The author would like to thanks comments received from Minh Cong Nguyen, John Luke Gallup, Aart C. Kraay, Amer Hasan, Johan Mistiaen, Roy Shuji Katayama, Dean Mitchell Jolliffe, Nobuo Yoshida,
    Manohar Sharma, Gabriel Demombynes, Paolo Verme, Elizaveta Perova, Kit Baum, Kerry Kammire, Derek Wagner, Neil Fantom and Loiuse J. Cord. The usual disclaimer applies.{p_end}
    {p 4 4 2}I would like to dedicate this ado file to Dr Richard Sperling, who asked us to support intelligent and well 
    thought out public policies that help those in society who are less fortunate than we are. {browse "www.stata.com/statalist/archive/2011-02/msg00062.html"}{p_end}
    {p 4 4 2}{cmd:wbopendata} uses the Stata user written command {cmd:_pecats} produced by J. Scott Long and Jeremy Freese, and {cmd:tknz} written by David C. Elliott and 
    Nick Cox.{p_end} 
       
{title:Author}

    {p 4 4 2}Joao Pedro Azevedo (jazevedo@worldbank.org){p_end}

{title:Also see}

{psee}
Online:  {helpb spmap} {helpb tknz} (if installed)
{p_end}
