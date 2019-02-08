global gitroot "C:\Users\wb255520\Documents\myados"
*global gitroot "C:\GitHub_myados"

*********************************************************************

cd "$gitroot\wbopendata\src"
shell git checkout dev
discard

*********************************************************************

_api_read

di "`r(line1)'"

di strpos("`r(line1)'","total=")

local final = strpos("`r(line1)'","total=")+1

di substr("`r(line1)'",strpos("`r(line1)'","total="),50)

di word(substr("`r(line1)'",strpos("`r(line1)'","total="),50),1)

local tmp = word(substr("`r(line1)'",strpos("`r(line1)'","total="),50),1)

di subinstr("`tmp'","total=","",.)


