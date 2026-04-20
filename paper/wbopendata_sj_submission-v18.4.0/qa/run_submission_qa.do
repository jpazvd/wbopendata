*******************************************************************************
* run_submission_qa.do — Master QA runner for submission package
*
* Usage (from qa/):
*   do "run_submission_qa.do"
*   do "run_submission_qa.do" core
*   do "run_submission_qa.do" help
*   do "run_submission_qa.do" dev
*
* Modes:
*   core : run run_tests.do (installed/default path)
*   help : run test_help_examples.do (installed mode)
*   dev  : run run_tests_dev.do + test_help_examples.do dev
*   all  : core + help (default)
*******************************************************************************

clear all
set more off
capture log close _all

args mode
if "`mode'" == "" local mode "all"
local mode = lower("`mode'")

* Resolve qa directory from current do-file when available; fallback to cwd
local qa_dir = subinstr(c(pwd), "\", "/", .)
local thisfile = subinstr("`c(filename)'", "\", "/", .)
if regexm("`thisfile'", "(.+)/[^/]+\\.do$") {
    local qa_dir = regexs(1)
}

* Ensure we are running from qa directory
if !regexm("`qa_dir'", "[/\\]qa[/\\]?$") {
    di as error "Could not detect qa directory from: `qa_dir'"
    di as error "Please run this do-file from the submission qa folder."
    exit 198
}

cd "`qa_dir'"
cap mkdir "`qa_dir'/logs"

local ts = subinstr("`c(current_date)'`c(current_time)'", " ", "", .)
local ts = subinstr("`ts'", ":", "", .)
local masterlog "`qa_dir'/logs/run_submission_qa_`ts'.log"

log using "`masterlog'", replace text

di as result _n _dup(78) "="
di as result "WBOPENDATA SUBMISSION QA MASTER RUN"
di as result _dup(78) "="
di as text "Mode:    `mode'"
di as text "QA dir:  `qa_dir'"
di as text "Date:    " c(current_date) " " c(current_time)
di as text "Stata:   " c(stata_version)
di as text "Working: " c(pwd)

if !inlist("`mode'", "all", "core", "help", "dev") {
    di as error "Invalid mode: `mode'"
    di as text "Valid modes: all | core | help | dev"
    log close
    exit 198
}

if inlist("`mode'", "all", "core") {
    di as text _n "--- Running core QA suite: run_tests.do ---"
    do "run_tests.do"
}

if inlist("`mode'", "all", "help") {
    di as text _n "--- Running help examples QA: test_help_examples.do (installed) ---"
    do "test_help_examples.do" installed
}

if "`mode'" == "dev" {
    di as text _n "--- Running dev QA wrapper: run_tests_dev.do ---"
    do "run_tests_dev.do"

    di as text _n "--- Running help examples QA: test_help_examples.do (dev) ---"
    do "test_help_examples.do" dev
}

di as result _n _dup(78) "="
di as result "MASTER QA RUN COMPLETED"
di as result _dup(78) "="
di as text "Master log: `masterlog'"

log close
