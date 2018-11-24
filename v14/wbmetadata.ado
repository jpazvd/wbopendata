*! version 0.3  6dec2016
*! Minh Cong Nguyen
* API to call meta data
cap program drop wbmetadata
program define wbmetadata, rclass
	version 13, missing
    local verstata : di "version " string(_caller()) ", missing:"   
	syntax, surveyid(string) [key(string)]
	return clear
	tempfile data1
	local site http://microdatalib.worldbank.org/index.php/api/v2/catalog/find_by_idno
	cap copy "`site'/`surveyid'" "`data1'"
	if _rc==0 {	
		_txtsearch, dofile0(`data1') namelist(`key')
		foreach item of local key {
			return local `item' `=`item'_stcode'
		}		
	}
end

/*
*! version 0.1  2jun2015
*! Minh Cong Nguyen
* API to call meta data
cap program drop wbmetadata
program define wbmetadata, rclass
	version 13, missing
    local verstata : di "version " string(_caller()) ", missing:"   
	syntax, surveyid(string) [key(string)]
	return clear
	tempfile data1
	cap copy "http://microdatalib.worldbank.org/index.php/api/v2/catalog/search?sk=`surveyid'" "`data1'"
	if _rc==0 {
		foreach item of local key {
			_txtsearch, dofile0(`data1') varname(`item')
			return local `item' `=stcode'
		}	
	}
end
*/
