*! version 1.0.0 07Feb2026
* run_batch.do - Example batch runner using dev_setup.do

version 14.0

* Initialize dev environment
quietly do "C:/GitHub/myados/wbopendata-dev/tests/dev_setup.do"

* Example: parity runner (adjust as needed)
cap noi do "C:/GitHub/myados/wbopendata-dev/tests/run_yaml_parity.do"

exit _rc
