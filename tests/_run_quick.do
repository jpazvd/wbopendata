clear all
set more off
capture mkdir "logs"
log using "logs/test_help_examples2.log", replace text
do "test_help_examples.do"
log close
