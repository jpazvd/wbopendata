* Check if sjlatex is installed
clear all
set more off

di "=== Checking for required packages ==="

capture which sjlog
di "sjlog check: _rc = " _rc

if _rc != 0 {
    di as error "sjlog NOT found - attempting to install sjlatex"
    net install sjlatex, from("http://www.stata-journal.com/production") replace force
    which sjlog
}

di "All packages available"
