{smcl}
{hline}
{* 14Apr2020 }{...}
{cmd:help wbopendata}{right:dialog:  {bf:{dialog wbopendata}}}
{right:Indicator List:  {bf:{help wbopendata_sourceid##indicators:Indicators List}}}
{right: {bf:version 16.2.1}}
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
{synopt :{opt year}{cmd:(}{it:date1}{cmd::}{it:date2}{cmd:)}} time interval (in yearly, quarterly or monthly depending on the series).{p_end}
{synopt :{opt language}{cmd:(}{it:language}{cmd:)}} select the language.{p_end}
{synopt :{opt full}} adds full list of country attributes.{p_end}
{synopt :{opt iso}} adds 2 digits ISO codes to country attributes.{p_end}
{synopt :{opt update query}} query the current vintage of indicators and country metadata available.{p_end}
{synopt :{opt update check}} checks the availability of new indicators and country metadata available for download.{p_end}
{synopt :{opt update all}} refreshes the indicators and country metadata information.{p_end}
{synopt :{opt match(varname)}} mergue {help wbopendata##attributes:country attributes} using WDI countrycodes.{p_end}
{synopt :{opt projection}} World Bank {help wbopendata_sourceid_indicators40##sourceid_40:population estimates and projections} (HPP) .{p_end}
{synopt :{opt metadataoffline}} download all indicator metadata informaiton and generates 71 sthlp files in your local machine.{p_end}
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
		{it:{help wbopendata##attributes:List of supported country attributes}}
		{it:{help wbopendata##countries:Country code and names by selected attributes}}
		{it:{help wbopendata##sourceid:Indicators by Source}}
		{it:{help wbopendata##topic:Topic List}}
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

{p 4 4 2}{cmd:wbopendata} allows Stata users to download over 17,000 indicators from the World Bank databases, including: Development 
Africa Development Indicators; Doing Business; Education Statistics; Enterprise Surveys; Global Development Finance; 
Gender Statistics; Health Nutrition and Population Statistics; International Development Association - Results Measurement System; 
Millennium Development Goals; World Development Indicators; Worldwide Governance Indicators; and LAC Equity Lab. These indicators include information 
from over 256 countries and regions, since 1960.{p_end}

{p 4 4 2}Users can chose from one of three of the {cmd:languages} supported by the database (and Stata), namely, English, Spanish, or French.{p_end}

{p 4 4 2}Five possible downloads options are currently supported:{p_end}

{synopt:{opt country}} over 1,000 indicators for all selected years for a single country (WDI Catalogue).{p_end}
{synopt:{opt topics}} WDI indicators within a specific topic, for all selected years and all countries (WDI Catalogue).{p_end}
{synopt:{opt indicator}} all selected years for all countries for a single indicator (from any of the catalogues: 17,000+ series).{p_end}
{synopt:{opt indicator and country}}  all selected years for selected countries for a single indicator (from any of the catalogues: 17,000+ series).{p_end}
{synopt:{opt multiple indicator}} all selected years for selected indicators separated by ; (from any of the catalogues: 17,000+ series).{p_end}

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
{synopt:{opt indicator(string)}}{help wbopendata_sourceid##indicators:Indicators List} list of indicator codes (All series). When selecting multiple 
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

{synopt:{opt nometadata}} omits the display of the metadata information from the series. Metadata information is only available when downloading specific series (indicator option). The metadata available include information on the name of the series, the source, a detailed description 
of the indicator, and the organization responsible for compiling this indicator.{p_end}

{synopt:{opt year:(date1:date2)}} allow users to select a specific time interval. Date1=Initial date; Date2=Final date. For most indicators Date should be expressed in yearly format, however for specific series quartely and montly series will be supported. Please check data documentation 
at the World Bank Data website to identify which format is supported.{p_end}
           
{synopt:{opt language(option)}}three languages are supported: The default language is English.{p_end}

{center: English:  {cmd:en}          }
{center: Spanish:  {cmd:es}          }
{center: French:   {cmd:fr}          }

{synopt :{opt full}} adds full list of country attributes.{p_end}

{synopt :{opt iso}} adds only 2 digits ISO codes to country attributes.{p_end}

{synopt :{opt update query}} query the current vintage of indicators available and country metadata.{p_end}

{synopt :{opt update check}} checks the availability of new indicators  and country metadata available for download.{p_end}

{synopt :{opt update all}} refreshes the indicators and country metadata information.{p_end}

{synopt :{opt match(varname)}} mergue {it:{help wbopendata##attributes:country attributes}} using WDI countrycodes.{p_end}

{synopt :{opt projection}} World Bank staff {help wbopendata_sourceid_indicators40##sourceid_40:population projection estimates} using the World Bank's total population and age/sex distributions of the United Nations Population Division's World Population Prospects: 2019 Revision.{p_end} 

{synopt :{opt metadataoffline}} refresh all metadata information, and generate a local copy of all indicators metadata organized by topics and source. This option creates 71 new help files in your local machine with approximately 15mb of documentation.{p_end}
	
{marker attributes}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:List Country attributes currently supported}

{synoptset 33 tabbed}{...}
{synopthdr: Country attributes}
{synoptline}
{synopt:{opt countrycode}}Country Code{p_end}
{synopt:{opt countryname}}Country Name{p_end}
{synopt:{opt region_iso2}}Region Code (ISO 2 digits){p_end}
{synopt:{opt regionname}}Region Name{p_end}
{synopt:{opt adminregion}}Administrative Region Code{p_end}
{synopt:{opt adminregion_iso2}}Administrative Region Code (ISO 2 digits){p_end}
{synopt:{opt adminregionname}}Administrative Region Name{p_end}
{synopt:{opt incomelevel}}Income Level Code{p_end}
{synopt:{opt incomelevel_iso2}}Income Level Code (ISO 2 digits){p_end}
{synopt:{opt incomelevelname}}Income Level Name{p_end}
{synopt:{opt lendingtype}}Lending Type Code{p_end}
{synopt:{opt region}}Region Code{p_end}
{synopt:{opt lendingtype_iso2}}Lending Type Code (ISO 2 digits){p_end}
{synopt:{opt lendingtypename}}Lending Type Name{p_end}
{synopt:{opt capital}}Capital Name{p_end}
{synopt:{opt latitude}}Capital Latitude{p_end}
{synopt:{opt longitude}}Capital Longitude{p_end}
{synoptline}


{marker countries}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Country Names and Codes by Groups}

{synoptset 33 tabbed}{...}
{marker region}
{synopthdr: Regions}
{synoptline}
{synopt:{opt NA}}{help wbopendata_region##NA:Aggregates}{p_end}
{synopt:{opt EAS}}{help wbopendata_region##EAS:East Asia and Pacific}{p_end}
{synopt:{opt ECS}}{help wbopendata_region##ECS:Europe and Central Asia}{p_end}
{synopt:{opt LCN}}{help wbopendata_region##LCN:Latin American and the Caribbean}{p_end}
{synopt:{opt MEA}}{help wbopendata_region##MEA:Middle East and North Africa}{p_end}
{synopt:{opt NAC}}{help wbopendata_region##NAC:North America}{p_end}
{synopt:{opt SAS}}{help wbopendata_region##SAS:South Asia}{p_end}
{synopt:{opt SSF}}{help wbopendata_region##SSF:Sub-Saharan Africa}{p_end}
{synoptline}


{marker adminregion}
{synopthdr: Administrative Regions}
{synoptline}
{synopt:{opt EAP}}{help wbopendata_adminregion##EAP:East Asia and Pacific}{p_end}
{synopt:{opt ECA}}{help wbopendata_adminregion##ECA:Europe and Central Asia}{p_end}
{synopt:{opt LAC}}{help wbopendata_adminregion##LAC:Latin American and the Caribbean}{p_end}
{synopt:{opt MNA}}{help wbopendata_adminregion##MNA:Middle East and North Africa}{p_end}
{synopt:{opt SAS}}{help wbopendata_adminregion##SAS:South Asia}{p_end}
{synopt:{opt SSA}}{help wbopendata_adminregion##SSA:Sub-Saharan Africa}{p_end}
{synoptline}


{marker incomelevel}
{synopthdr: Income Level Groups}
{synoptline}
{synopt:{opt NA}}{help wbopendata_incomelevel##NA:Aggregates}{p_end}
{synopt:{opt HIC}}{help wbopendata_incomelevel##HIC:High income}{p_end}
{synopt:{opt UMC}}{help wbopendata_incomelevel##UMC:Upper middle income}{p_end}
{synopt:{opt LMC}}{help wbopendata_incomelevel##LMC:Lower middle income}{p_end}
{synopt:{opt LIC}}{help wbopendata_incomelevel##LIC:Low income}{p_end}
{synoptline}


{marker lendingtype}
{synopthdr: Lending Type Group}
{synoptline}
{synopt:{opt IBD}}{help wbopendata_lendingtype##IBD:IBRD}{p_end}
{synopt:{opt IDX}}{help wbopendata_lendingtype##IDX:IDA}{p_end}
{synopt:{opt IDB}}{help wbopendata_lendingtype##IDB:Blend}{p_end}
{synopt:{opt LNX}}{help wbopendata_lendingtype##LNX:Not classified}{p_end}
{synoptline}


{marker sourceid}{...}    
{synoptset 33 tabbed}{...}
{synopthdr:Source Code}{it:{help wbopendata_sourceid_indicators01##:  (Source TOC)}}
{synoptline}
{synopt:{opt 01}}  {help wbopendata_sourceid_indicators01##sourceid_01:Doing Business}{p_end}
{synopt:{opt 02}}  {help wbopendata_sourceid_indicators02##sourceid_02:World Development Indicators}{p_end}
{synopt:{opt 03}}  {help wbopendata_sourceid_indicators03##sourceid_03:Worldwide Governance Indicators}{p_end}
{synopt:{opt 05}}  {help wbopendata_sourceid_indicators05##sourceid_05:Subnational Malnutrition Database}{p_end}
{synopt:{opt 06}}  {help wbopendata_sourceid_indicators06##sourceid_06:International Debt Statistics}{p_end}
{synopt:{opt 11}}  {help wbopendata_sourceid_indicators11##sourceid_11:Africa Development Indicators}{p_end}
{synopt:{opt 12}}  {help wbopendata_sourceid_indicators12##sourceid_12:Education Statistics}{p_end}
{synopt:{opt 13}}  {help wbopendata_sourceid_indicators13##sourceid_13:Enterprise Surveys}{p_end}
{synopt:{opt 14}}  {help wbopendata_sourceid_indicators14##sourceid_14:Gender Statistics}{p_end}
{synopt:{opt 15}}  {help wbopendata_sourceid_indicators15##sourceid_15:Global Economic Monitor}{p_end}
{synopt:{opt 16}}  {help wbopendata_sourceid_indicators16##sourceid_16:Health Nutrition and Population Statistics}{p_end}
{synopt:{opt 18}}  {help wbopendata_sourceid_indicators18##sourceid_18:IDA Results Measurement System}{p_end}
{synopt:{opt 19}}  {help wbopendata_sourceid_indicators19##sourceid_19:Millennium Development Goals}{p_end}
{synopt:{opt 20}}  {help wbopendata_sourceid_indicators20##sourceid_20:Quarterly Public Sector Debt}{p_end}
{synopt:{opt 22}}  {help wbopendata_sourceid_indicators22##sourceid_22:Quarterly External Debt Statistics SDDS}{p_end}
{synopt:{opt 23}}  {help wbopendata_sourceid_indicators23##sourceid_23:Quarterly External Debt Statistics GDDS}{p_end}
{synopt:{opt 24}}  {help wbopendata_sourceid_indicators24##sourceid_24:Poverty and Equity}{p_end}
{synopt:{opt 25}}  {help wbopendata_sourceid_indicators25##sourceid_25:Jobs}{p_end}
{synopt:{opt 27}}  {help wbopendata_sourceid_indicators27##sourceid_27:Global Economic Prospects}{p_end}
{synopt:{opt 28}}  {help wbopendata_sourceid_indicators28##sourceid_28:Global Financial Inclusion}{p_end}
{synopt:{opt 29}}  {help wbopendata_sourceid_indicators29##sourceid_29:The Atlas of Social Protection: Indicators of Resilience and Equity}{p_end}
{synopt:{opt 30}}  {help wbopendata_sourceid_indicators30##sourceid_30:Exporter Dynamics Database – Indicators at Country-Year Level}{p_end}
{synopt:{opt 32}}  {help wbopendata_sourceid_indicators32##sourceid_32:Global Financial Development}{p_end}
{synopt:{opt 33}}  {help wbopendata_sourceid_indicators33##sourceid_33:G20 Financial Inclusion Indicators}{p_end}
{synopt:{opt 34}}  {help wbopendata_sourceid_indicators34##sourceid_34:Global Partnership for Education}{p_end}
{synopt:{opt 35}}  {help wbopendata_sourceid_indicators35##sourceid_35:Sustainable Energy for All}{p_end}
{synopt:{opt 36}}  {help wbopendata_sourceid_indicators36##sourceid_36:Statistical Capacity Indicators}{p_end}
{synopt:{opt 37}}  {help wbopendata_sourceid_indicators37##sourceid_37:LAC Equity Lab}{p_end}
{synopt:{opt 39}}  {help wbopendata_sourceid_indicators39##sourceid_39:Health Nutrition and Population Statistics by Wealth Quintile}{p_end}
{synopt:{opt 40}}  {help wbopendata_sourceid_indicators40##sourceid_40:Population estimates and projections}{p_end}
{synopt:{opt 41}}  {help wbopendata_sourceid_indicators41##sourceid_41:Country Partnership Strategy for India (FY2013 - 17)}{p_end}
{synopt:{opt 45}}  {help wbopendata_sourceid_indicators45##sourceid_45:Indonesia Database for Policy and Economic Research}{p_end}
{synopt:{opt 46}}  {help wbopendata_sourceid_indicators46##sourceid_46:Sustainable Development Goals}{p_end}
{synopt:{opt 50}}  {help wbopendata_sourceid_indicators50##sourceid_50:Subnational Population}{p_end}
{synopt:{opt 54}}  {help wbopendata_sourceid_indicators54##sourceid_54:Joint External Debt Hub}{p_end}
{synopt:{opt 57}}  {help wbopendata_sourceid_indicators57##sourceid_57:WDI Database Archives}{p_end}
{synopt:{opt 59}}  {help wbopendata_sourceid_indicators59##sourceid_59:Wealth Accounts}{p_end}
{synopt:{opt 60}}  {help wbopendata_sourceid_indicators60##sourceid_60:Economic Fitness}{p_end}
{synopt:{opt 61}}  {help wbopendata_sourceid_indicators61##sourceid_61:PPPs Regulatory Quality}{p_end}
{synopt:{opt 62}}  {help wbopendata_sourceid_indicators62##sourceid_62:International Comparison Program (ICP) 2011}{p_end}
{synopt:{opt 63}}  {help wbopendata_sourceid_indicators63##sourceid_63:Human Capital Index}{p_end}
{synopt:{opt 64}}  {help wbopendata_sourceid_indicators64##sourceid_64:Worldwide Bureaucracy Indicators}{p_end}
{synopt:{opt 65}}  {help wbopendata_sourceid_indicators65##sourceid_65:Health Equity and Financial Protection Indicators}{p_end}
{synopt:{opt 66}}  {help wbopendata_sourceid_indicators66##sourceid_66:Logistics Performance Index}{p_end}
{synopt:{opt 67}}  {help wbopendata_sourceid_indicators67##sourceid_67:PEFA 2011}{p_end}
{synopt:{opt 69}}  {help wbopendata_sourceid_indicators69##sourceid_69:Global Financial Inclusion and Consumer Protection Survey}{p_end}
{synopt:{opt 70}}  {help wbopendata_sourceid_indicators70##sourceid_70:Economic Fitness 2}{p_end}
{synopt:{opt 71}}  {help wbopendata_sourceid_indicators71##sourceid_71:International Comparison Program (ICP) 2005}{p_end}
{synopt:{opt 73}}  {help wbopendata_sourceid_indicators73##sourceid_73:Global Financial Inclusion and Consumer Protection Survey (Internal)}{p_end}
{synopt:{opt 75}}  {help wbopendata_sourceid_indicators75##sourceid_75:Environment, Social and Governance (ESG) Data}{p_end}
{synoptline}


{marker topic}{marker topicid}{...}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{title:Topic List}
{synoptset 33 tabbed}{...}


{synopthdr: Topic Code}
{synoptline}

{synopt:{help wbopendata_topicid##topicid_01:1 - Agriculture & Rural Development}} For the 70 percent of the world's poor who live in rural areas, agriculture is the main source of income and employment. But depletion and degradation of land and water pose serious challenges to producing enough food and other agricultural products to sustain livelihoods here and meet the needs of urban populations. Data presented here include measures of agricultural inputs, outputs, and productivity compiled by the UN's Food and Agriculture Organization. {p_end}

{synopt:{help wbopendata_topicid##topicid_02:2 - Aid Effectiveness}} Aid effectiveness is the impact that aid has in reducing poverty and inequality, increasing growth, building capacity, and accelerating achievement of the Millennium Development Goals set by the international community. Indicators here cover aid received as well as progress in reducing poverty and improving education, health, and other measures of human welfare. {p_end}

{synopt:{help wbopendata_topicid##topicid_03:3 - Economy & Growth}} Economic growth is central to economic development. When national income grows, real people benefit. While there is no known formula for stimulating economic growth, data can help policy-makers better understand their countries' economic situations and guide any work toward improvement. Data here covers measures of economic growth, such as gross domestic product (GDP) and gross national income (GNI). It also includes indicators representing factors known to be relevant to economic growth, such as capital stock, employment, investment, savings, consumption, government spending, imports, and exports. {p_end}

{synopt:{help wbopendata_topicid##topicid_04:4 - Education}} Education is one of the most powerful instruments for reducing poverty and inequality and lays a foundation for sustained economic growth. The World Bank compiles data on education inputs, participation, efficiency, and outcomes. Data on education are compiled by the United Nations Educational, Scientific, and Cultural Organization (UNESCO) Institute for Statistics from official responses to surveys and from reports provided by education authorities in each country. {p_end}

{synopt:{help wbopendata_topicid##topicid_05:5 - Energy & Mining}} The world economy needs ever-increasing amounts of energy to sustain economic growth, raise living standards, and reduce poverty. But today's trends in energy use are not sustainable. As the world's population grows and economies become more industrialized, nonrenewable energy sources will become scarcer and more costly. Data here on energy production, use, dependency, and efficiency are compiled by the World Bank from the International Energy Agency and the Carbon Dioxide Information Analysis Center. {p_end}

{synopt:{help wbopendata_topicid##topicid_06:6 - Environment}} Natural and man-made environmental resources (fresh water, clean air, forests, grasslands, marine resources, and agro-ecosystems) provide sustenance and a foundation for social and economic development.  The need to safeguard these resources crosses all borders.  Today, the World Bank is one of the key promoters and financiers of environmental upgrading in the developing world. Data here cover forests, biodiversity, emissions, and pollution. Other indicators relevant to the environment are found under data pages for Agriculture & Rural Development, Energy & Mining, Infrastructure, and Urban Development. {p_end}

{synopt:{help wbopendata_topicid##topicid_07:7 - Financial Sector}} An economy's financial markets are critical to its overall development. Banking systems and stock markets enhance growth, the main factor in poverty reduction. Strong financial systems provide reliable and accessible information that lowers transaction costs, which in turn bolsters resource allocation and economic growth. Indicators here include the size and liquidity of stock markets; the accessibility, stability, and efficiency of financial systems; and international migration and workers\ remittances, which affect growth and social welfare in both sending and receiving countries. {p_end}

{synopt:{help wbopendata_topicid##topicid_08:8 - Health}} Improving health is central to the Millennium Development Goals, and the public sector is the main provider of health care in developing countries. To reduce inequities, many countries have emphasized primary health care, including immunization, sanitation, access to safe drinking water, and safe motherhood initiatives.  Data here cover health systems, disease prevention, reproductive health, nutrition, and population dynamics. Data are from the United Nations Population Division, World Health Organization, United Nations Children's Fund, the Joint United Nations Programme on HIV/AIDS, and various other sources. {p_end}

{synopt:{help wbopendata_topicid##topicid_09:9 - Infrastructure}} Infrastructure helps determine the success of manufacturing and agricultural activities. Investments in water, sanitation, energy, housing, and transport also improve lives and help reduce poverty. And new information and communication technologies promote growth, improve delivery of health and other services, expand the reach of education, and support social and cultural advances. Data here are compiled from such sources as the International Road Federation, Containerisation International, the International Civil Aviation Organization, the International Energy Association, and the International Telecommunications Union. {p_end}

{synopt:{help wbopendata_topicid##topicid_10:10 - Social Protection & Labor}} The supply of labor available in an economy includes people who are employed, those who are unemployed but seeking work, and first-time job-seekers. Not everyone who works is included: unpaid workers, family workers, and students are often omitted, while some countries do not count members of the armed forces. Data on labor and employment are compiled by the International Labour Organization (ILO) from labor force surveys, censuses, establishment censuses and surveys, and administrative records such as employment exchange registers and unemployment insurance schemes. {p_end}

{synopt:{help wbopendata_topicid##topicid_11:11 - Poverty}} For countries with an active poverty monitoring program, the World Bank in collaboration with national institutions, other development agencies, and civil society regularly conducts analytical work to assess the extent and causes of poverty and inequality, examine the impact of growth and public policy, and review household survey data and measurement methods.  Data here includes poverty and inequality measures generated from analytical reports, from national poverty monitoring programs, and from the World Bank's Development Research Group which has been producing internationally comparable and global poverty estimates and lines since 1990. {p_end}

{synopt:{help wbopendata_topicid##topicid_12:12 - Private Sector}} Private markets drive economic growth, tapping initiative and investment to create productive jobs and raise incomes. Trade is also a driver of economic growth as it integrates developing countries into the world economy and generates benefits for their people.  Data on the private sector and trade are from the World Bank Group's Private Participation in Infrastructure Project Database, Enterprise Surveys, and Doing Business Indicators, as well as from the International Monetary Fund's Balance of Payments database and International Financial Statistics, the UN Commission on Trade and Development, the World Trade Organization, and various other sources. {p_end}

{synopt:{help wbopendata_topicid##topicid_13:13 - Public Sector}} Effective governments improve people's standard of living by ensuring access to essential services (health, education, water and sanitation, electricity, transport and the opportunity to live and work in peace and security). Data here includes World Bank staff assessments of country performance in economic management, structural policies, policies for social inclusion and equity, and public sector management and institutions for the poorest countries. Also included are indicators on revenues and expenses from the International Monetary Fund's Government Finance Statistics, and on tax policies from various sources. {p_end}

{synopt:{help wbopendata_topicid##topicid_14:14 - Science & Technology}} Technological innovation, often fueled by governments, drives industrial growth and helps raise living standards. Data here aims to shed light on countries technology base: research and development, scientific and technical journal articles, high-technology exports, royalty and license fees, and patents and trademarks. Sources include the UNESCO Institute for Statistics, the U.S. National Science Board, the UN Statistics Division, the International Monetary Fund, and the World Intellectual Property Organization. {p_end}

{synopt:{help wbopendata_topicid##topicid_15:15 - Social Development}} Data here cover child labor, gender issues, refugees, and asylum seekers. Children in many countries work long hours, often combining studying with work for pay. The data on their paid work are from household surveys conducted by the International Labour Organization (ILO), the United Nations Children's Fund (UNICEF), the World Bank, and national statistical offices. Gender disparities are measured using a compilation of data on key topics such as education, health, labor force participation, and political participation.  Data on refugees are from the United Nations High Commissioner for Refugees complemented by statistics on Palestinian refugees under the mandate of the United Nations Relief and Works Agency. {p_end}

{synopt:{help wbopendata_topicid##topicid_16:16 - Urban Development}} Cities can be tremendously efficient. It is easier to provide water and sanitation to people living closer together, while access to health, education, and other social and cultural services is also much more readily available. However, as cities grow, the cost of meeting basic needs increases, as does the strain on the environment and natural resources. Data on urbanization, traffic and congestion, and air pollution are from the United Nations Population Division, World Health Organization, International Road Federation, World Resources Institute, and other sources. {p_end}

{synopt:{help wbopendata_topicid##topicid_17:17 - Gender}} Women's empowerment and the promotion of gender equality are key to achieving sustainable development. Greater gender equality can enhance economic efficiency and improve other development outcomes by removing barriers that prevent women from having the same access as men to human resource endowments, rights, and economic opportunities.  Giving women access to equal opportunities allows them to emerge as social and economic actors, influencing and shaping more inclusive policies.  Improving women's status also leads to more investment in their children's education, health, and overall wellbeing.  Data here covers demography, education, health, labor force and employment, and political participation. {p_end}

{synopt:{help wbopendata_topicid##topicid_18:18 - Millenium development goals}}{p_end}

{synopt:{help wbopendata_topicid##topicid_19:19 - Climate Change}} Climate change is expected to hit developing countries the hardest. Its effects higher temperatures, changes in precipitation patterns, rising sea levels, and more frequent weather-related disasters pose risks for agriculture, food, and water supplies. At stake are recent gains in the fight against poverty, hunger and disease, and the lives and livelihoods of billions of people in developing countries. Addressing climate change requires unprecedented global cooperation across borders. The World Bank Group is helping support developing countries and contributing to a global solution, while tailoring our approach to the differing needs of developing country partners.  Data here cover climate systems, exposure to climate impacts, resilience, greenhouse gas emissions, and energy use.  Other indicators relevant to climate change are found under other data pages, particularly Environment, Agriculture & Rural Development, Energy & Mining, Health, Infrastructure, Poverty, and Urban Development. {p_end}

{synopt:{help wbopendata_topicid##topicid_20:20 - External Debt}} Debt statistics provide a detailed picture of debt stocks and flows of developing countries. Data presented as part of the Quarterly External Debt Statistics takes a closer look at the external debt of high-income countries and emerging markets to enable a more complete understanding of global financial flows. The Quarterly Public Sector Debt database provides further data on public sector valuation methods, debt instruments, and clearly defined tiers of debt for central, state and local government, as well as extra-budgetary agencies and funds. Data are gathered from national statistical organizations and central banks as well as by various major multilateral institutions and World Bank staff. {p_end}

{synopt:{help wbopendata_topicid##topicid_21:21 - Trade}} Trade is a key means to fight poverty and achieve the Millennium Development Goals, specifically by improving developing country access to markets, and supporting a rules based, predictable trading system. In cooperation with other international development partners, the World Bank launched the Transparency in Trade Initiative to provide free and easy access to data on country-specific trade policies. {p_end}
{synoptline}


{marker Examples}{...}
{title:Examples}{p 50 20 2}{p_end}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}
{pstd}

{p 8 12}{stata "wbopendata, update query" :. wbopendata, update query}{p_end}

{p 8 12}{stata "wbopendata, update check" :. wbopendata, update check}{p_end}

{p 8 12}{stata "wbopendata, update all" :. wbopendata, update all}{p_end}

{p 8 12}{stata "wbopendata, metadataoffline" :. wbopendata, metadataoffline}{p_end}

{p 8 12}{stata "wbopendata, country(chn - China) clear" :. wbopendata, country(chn - China) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear" :. wbopendata, language(en - English) topics(2 - Aid Effectiveness) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear" :. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) clear}{p_end}

{p 8 12}{stata "wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear" :. wbopendata, language(en - English) indicator(ag.agr.trac.no - Agricultural machinery, tractors) long clear}{p_end}

{p 8 12}{stata "wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear" :. wbopendata, country(ago;bdi;chi;dnk;esp) indicator(sp.pop.0610.fe.un) clear}{p_end}

{p 8 12}{stata "wbopendata, indicator(SP.POP.1014.FE; SP.POP.1014.MA) year(1990:2050) projection clear" :. wbopendata, indicator(SP.POP.1014.FE; SP.POP.1014.MA) year(1990:2050) projection clear}{p_end}

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
                Statistical Software Components S457234 Boston College Department of Economics.", ///
				size(*.7))
{txt}      ({stata "wbopendata_examples example01":click to run})

{cmd}
        . wbopendata, indicator(si.pov.dday ) clear long
        . drop if  si_pov_dday == .
        . sort  countryname year
        . bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
        . encode region, gen(reg)
        . encode countryname, gen(reg2)
        . alorenz diff_pov, gp points(100) fullview  xdecrease markvar(reg2)  ///                                         
            ytitle("Change in Poverty (p.p.)") xtitle("Proportion of regional ///
            episodes of poverty reduction (%)") legend(off) title("Poverty Reduction") ///
        	mlabelangle(45)	legend(off)	///
			note("Source: World Development Indicators using Azevedo, J.P. (2011) ///
            wbopendata: Stata module to " "access World Bank databases, Statistical ///
            Software Components S457234 Boston College Department of Economics.", ///
			size(*.7))
{txt}      ({stata "wbopendata_examples example02":click to run})

{cmd}
        . wbopendata, indicator(si.pov.dday ) clear long
        . drop if  si_pov_dday == .
        . sort  countryname year
        . keep if regionname == "Aggregates"
        . bysort  countryname : gen diff_pov = (si_pov_dday-si_pov_dday[_n-1])/(year-year[_n-1])
        . gen baseline = si_pov_dday if year == 1990
        . sort countryname baseline
        . bysort countryname : replace baseline = baseline[1] if baseline == .
        . gen mdg1 = baseline/2
        . gen present = si_pov_dday if year == 2008
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
                   title("MDG 1 - 1.9 USD")                                         ///
                   note("Source: World Development Indicators (latest available year: 2008) ///
                   using Azevedo, J.P. (2011) wbopendata: Stata module to " "access ///
                   World Bank databases, Statistical Software Components S457234 Boston ///
                   College Department of Economics.", size(*.7))
{txt}      ({stata "wbopendata_examples example03":click to run})


{cmd}
       . wbopendata, indicator(si.pov.dday; ny.gdp.pcap.pp.kd) clear long latest

       . graph twoway ///
           (scatter si_pov_dday ny_gdp_pcap_pp_kd, msize(*.6)) ///
           (scatter si_pov_dday ny_gdp_pcap_pp_kd if region == "Aggregates", msize(*.8) ///
           mlabel(countryname)  mlabsize(*.8)  mlabangle(25)) ///
           (lowess si_pov_dday ny_gdp_pcap_pp_kd) , ///
               xtitle("GDP per capita, PPP (constant 2011 international $)") ///
               ytitle("Poverty headcount ratio at the International Poverty Line") ///
               mlabelangle(45)	legend(off) ///
               note("Source: World Development Indicators (latest available year as off 2012-08-08) ///
               using Azevedo, J.P. (2011) wbopendata: Stata module to " "access World Bank databases, ///
               Statistical Software Components S457234 Boston College Department of Economics.", /// 
               size(*.7))

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

{p 8 12 2}Please make reference to the date when the database was downloaded, as indicator values and availabiltiy may change.{p_end}


{marker references}{...}
{title:References}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

    {p 4 4 2}David C. Elliott, 2002. "TKNZ: Stata module to tokenize string into named macros," Statistical Software Components
S426302, Boston College Department of Economics, revised 17 Oct 2006.{p_end} 

{marker acknowled}{...}
{title:Acknowledgements}
{p 40 20 2}(Go up to {it:{help wbopendata##sections:Sections Menu}}){p_end}

    {p 4 4 2}This program was developed by Joao Pedro Azevedo.{p_end} 
    {p 4 4 2}A special thanks to the World Bank API team, in particular, Malarvizhi Veerappan, Lakshmikanthan Subramanian, Shanmugam Natarajan, Ugendran Machakkalai, Rochelle Glenene O'Hagan, Timothy Grant Herzog, 
	and Ana Florina Pirlea.{p_end}
    {p 4 4 2}The author would like to thanks comments received from Minh Cong Nguyen, John Luke Gallup, Aart C. Kraay, Amer Hasan, Johan Mistiaen, Roy Shuji Katayama, Dean Mitchell Jolliffe, Nobuo Yoshida,
    Manohar Sharma, Gabriel Demombynes, Paolo Verme, Elizaveta Perova, Kit Baum, Kerry Kammire, Derek Wagner, Neil Fantom and Loiuse J. Cord. The usual disclaimer applies.{p_end}
    {p 4 4 2}I would like to dedicate this ado file to Dr Richard Sperling, who asked us to support intelligent and well 
    thought out public policies that help those in society who are less fortunate than we are. {browse "www.stata.com/statalist/archive/2011-02/msg00062.html"}{p_end}
    {p 4 4 2}{cmd:wbopendata} uses the Stata user written command {cmd:_pecats} produced by J. Scott Long and Jeremy Freese, and {cmd:tknz} written by David C. Elliott and 
    Nick Cox.{p_end} 
       
{title:Author}

    {p 4 4 2}Joao Pedro Azevedo (jazevedo@worldbank.org){p_end}

{title:GitHub Respository}

{p 4 4 2}For previous releases and additional examples please visit wbopendata {browse "https://github.com/jpazvd/wbopendata" :GitHub Repo}{p_end}

{p 4 4 2}Please make any enhancement suggestions and/or report any problems with wbopendata at {browse "https://github.com/jpazvd/wbopendata/issues" :Issues and Suggestions page}{p_end}

{title:Also see}

{psee}
Online: {helpb linewrap} {helpb alorenz} {helpb spmap} {helpb tknz} (if installed)
{p_end}
