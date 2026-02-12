clear all
set more off

* Test if sjlog is available
cap which sjlog
if _rc != 0 {
    di as error "sjlog NOT installed. Installing sjlatex..."
    cap noi net install sjlatex, from("http://www.stata-journal.com/production") replace
    cap which sjlog
    if _rc != 0 {
        di as error "FAILED to install sjlatex"
        exit 198
    }
}
di as text "sjlog is available"

* Test sjlog
local logs_dir "C:/GitHub/myados/wbopendata-dev/paper/sjlogs"

sjlog using "`logs_dir'/_test_sjlog", replace
di "Hello from sjlog test"
sjlog close, replace

di as text "Test file created at: `logs_dir'/_test_sjlog.log.tex"

exit
