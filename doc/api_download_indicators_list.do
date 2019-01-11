

local query1 "http://api.worldbank.org/v2/indicators?per_page=15000&page=1"

local query2 "http://api.worldbank.org/v2/indicators?per_page=15000&page=2"

copy "`query1'" indicator_1_2.txt, text replace

copy "`query2'" indicator_2_2.txt, text replace


copy "`query1'" indicator_1_2.xml,  public  replace

copy "`query2'" indicator_2_2.xml,  public replace
