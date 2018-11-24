*! 2.0.3 JPA NJC DCE Jul 2012
*! 2.0.2 NJC DCE Oct 2006
* 2.0.1 NJC 17 March 2006
* 2.0.0 NJC 12 June 2005
program _tknz, sclass
   version 8
//
// stub() - optionally add a prefix to a positionally numbered macro
// parse() - character(s) upon which to parse per normal tokenize
// nochar - exclude parsing character from list
// the program returns s(items) as the number of tokens returned
//
   syntax anything(name=list everything id="list to parse required") ///
   [, Stub(str) noCHAR Parse(str) ]
   if "`parse'" == "" {
       local parse " "
       }
   tokenize `list' , parse(`parse')
   local i = 0
   local j = 0
   while "``++j''" != "" {
       c_local `stub'`++i' `"``j''"'
       if "`char'" == "nochar" & `"`parse'"' != " " {
           local ++j
           }
       }
   sreturn local items = `i'
end
