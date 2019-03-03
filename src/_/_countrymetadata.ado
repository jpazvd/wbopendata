*******************************************************************************
*! v 15.2  	3Mar2019               by Joao Pedro Azevedo   
*	self-standing code to create country attribute table
*******************************************************************************

program define _countrymetadata , rclass

	version 9.0

	******************************************************

	syntax ,						///
			[ 						///
				ISO					///
				REGION				///
				ADMINREGION			///
				INCOMELEVEL			///
				LENDINGTYPE			///
				CAPITAL				///
				FULL				///
		  ]
	
	
	******************************************************

*	qui _countryname
	qui _countrycode_iso2
	
	qui _regioncode
	qui _regioncode_iso2
	qui _regionname

	qui _adminregion
	qui _adminregion_iso2
	qui _adminregionname
	
	qui _incomelevel
	qui _incomelevel_iso2
	qui _incomelevelname
	
	qui _lendingtype
	qui _lendingtype_iso2
	qui _lendingtypename
	
	qui _capital
	qui _latitude
	qui _longitude

	******************************************************

*	lab var countryname			"Country Name"
    lab var countrycode_iso2    "Country Code (ISO 2 digits)"

    lab var regioncode  		"Region Code"
	lab var regioncode_iso2		"Region Code (ISO 2 digits)"
    lab var regionname      	"Region Name"

    lab var adminregion  		"Administrative Region Code"
	lab var adminregion_iso2	"Administrative Region Code (ISO 2 digits)"
    lab var adminregionname	    "Administrative Region Name"

    lab var incomelevel  		"Income Level Code"
	lab var incomelevel_iso2	"Income Level Code (ISO 2 digits)"
    lab var incomelevelname    	"Income Level Name"
	
	lab var lendingtype  		"Lending Type Code"
	lab var lendingtype_iso2	"Lending Type Code (ISO 2 digits)"
    lab var lendingtypename    	"Lending Type Name"
	
	lab var capital		  		"Capital Name"
	lab var latitude			"Capital Latitude"
    lab var longitude	      	"Capital Longitude"

	******************************************************

	order countrycode countryname countrycode_iso2 regioncode regioncode_iso2 regionname adminregion adminregion_iso2 adminregionname incomelevel incomelevel_iso2 incomelevelname lendingtype lendingtype_iso2 lendingtypename capital latitude longitude

end

