	findfile wbopendata.ini , `path'
	view `r(fn)' 
	display `r(fn)'
	
	
	http://api.worldbank.org/v2/indicators
	