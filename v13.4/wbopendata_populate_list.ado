*! v 10  22jan2012               by Joao Pedro Azevedo                       *

program wbopendata_populate_list
		 version 9
		 args obj file
		 		
		 quietly findfile `"`file'"'

		 tempname fHandle
		 file open `fHandle' using `"`r(fn)'"', read text

		 local is_country = index("`obj'", "country") > 0

		 file read `fHandle' line

		 while (r(eof)==0) {
		 		 .wbopendata_dlg.`obj'.Arrpush `"`line'"'
		 		 if (`is_country') {
		 		 		 local val = substr("`line'", 1, 3) + ";"
		 		 		 .wbopendata_dlg.countryvalues.Arrpush `"`val'"'
		 		 }
		 		 file read `fHandle' line
		 }
		 file close `fHandle'
end
