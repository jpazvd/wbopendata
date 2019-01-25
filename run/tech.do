
*-begin do-file--

log using tech.log,  text replace

set more off

about

sysdir

adopath

creturn list

query compilenumber

query

set debug on

set netdebug on

capture noisily copy "http://api.worldbank.org/v2/indicators?per_page=50&page=1" test.txt, public replace

capture noisily copy "http://api.worldbank.org/v2/indicators?per_page=50&page=1" test.txt, text replace

capture noisily copy "http://api.worldbank.org/v2/indicators?per_page=50&page=1" test.txt, replace

log close

*-end of do-file--

