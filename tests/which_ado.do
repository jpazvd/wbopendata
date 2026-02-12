clear all
set more off

capture log close _all
log using "C:\GitHub\myados\wbopendata-dev\tests\which_ado.log", text replace

quietly do "C:/GitHub/myados/wbopendata-dev/tests/dev_setup.do"

which _wbopendata_refresh_yaml
which _api_read_indicators

log close
exit, clear
