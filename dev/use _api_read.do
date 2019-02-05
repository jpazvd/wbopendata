_api_read

di "`r(line1)'"

di strpos("`r(line1)'","total=")

local final = strpos("`r(line1)'","total=")+1

di substr("`r(line1)'",strpos("`r(line1)'","total="),20)

di word(substr("`r(line1)'",strpos("`r(line1)'","total="),20),1)

local tmp = word(substr("`r(line1)'",strpos("`r(line1)'","total="),20),1)

di subinstr("`tmp'","total=","",.)
