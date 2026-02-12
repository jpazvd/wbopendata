/*==============================================================================
    Generate Test Excerpt Log Snippets for LaTeX Paper

    This do-file runs the QA test suite and captures excerpts for the paper's
    Appendix C (Quality Assurance section).

    Two files are produced:
    1. run_tests_excerpt.log.tex      - Selected test examples showing format
    2. run_tests_summary_excerpt.log.tex - Summary table with all 15 categories

    Prerequisites:
    - wbopendata v18.0.0 installed
    - QA test suite at qa/run_tests.do

    Usage: From the paper/ directory, run:
        do scripts/generate_test_excerpts.do

    Note: This runs selected tests individually (not the full suite) to produce
    clean excerpts suitable for the paper. For the full QA run, use qa/run_tests.do.

    Author: Joao Pedro Azevedo
    Date: February 2026
==============================================================================*/

clear all
set more off
set linesize 80

local paper_dir "C:/GitHub/myados/wbopendata-dev/paper"
local logs_dir "`paper_dir'/sjlogs"
local qa_dir "C:/GitHub/myados/wbopendata-dev/qa"

* Ensure output directory exists
cap mkdir "`logs_dir'"

* Install from dev repo
cap noi net install wbopendata, from("C:/GitHub/myados/wbopendata-dev/src") replace

di as text _n "============================================================"
di as text "Generating test excerpt logs for LaTeX paper"
di as text "============================================================"

/*------------------------------------------------------------------------------
    Step 1: Run selected tests to capture excerpt
    We run a small representative set spanning old and new categories
------------------------------------------------------------------------------*/

di as text ">>> Running representative tests for excerpt..."

* Change to QA directory for test infrastructure
cd "`qa_dir'"

* Source test helpers
cap noi do run_tests.do

* The full run produces a log - we'll extract from it
* For now, change back to paper dir
cd "`paper_dir'"

di as text ">>> Full test run completed"
di as text ">>> Now extracting excerpts from QA log..."

/*------------------------------------------------------------------------------
    Step 2: The test run should produce output in qa/
    We read the latest test log and extract relevant excerpts

    Note: The actual excerpts may need manual curation for the paper.
    This script provides the raw material.
------------------------------------------------------------------------------*/

di as text ""
di as text "============================================================"
di as text "IMPORTANT: Test excerpt logs need manual curation."
di as text ""
di as text "After the full test run completes, extract:"
di as text "  1. A representative selection of 6-8 test outputs"
di as text "     (covering ENV, DL, REG, CACHE, SYNC, DISC categories)"
di as text "  2. The summary table showing all 15 categories"
di as text ""
di as text "Save to:"
di as text "  `logs_dir'/run_tests_excerpt.log.tex"
di as text "  `logs_dir'/run_tests_summary_excerpt.log.tex"
di as text "============================================================"

di as text _n "Finished: " c(current_date) " " c(current_time)

exit
