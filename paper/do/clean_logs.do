/*==============================================================================
    Clean Stata Log Files
    
    This script removes timestamps and _snippet lines from Stata log files,
    and converts emails/URLs to LaTeX hyperlinks for inclusion in documents.
    
    Usage: 
        do clean_logs.do
        do clean_logs.do "path/to/logs"
    
    By default, cleans all .tex files in ./sjlogs/
    Pass a different directory as argument to clean logs elsewhere.
    
    Author: João Pedro Azevedo
    Date: January 2026
    
     Logic overview (for future reuse/integration):
        1) Target directory: if no argument is passed, default to the paper sjlogs
            folder so running from repo root still finds the intended logs.
        2) Enumerate all .tex files (including *.log.tex) in the target directory.
        3) Stream each file line-by-line; skip only three patterns:
            - Any line containing "_snippet" (Stata prompt/footers from captures).
            - The literal continuation prompt line "> x".
            - Timestamp lines matching "r; t=#:## ###:##:##".
        4) If any skipped line is found, rewrite the file from a temp copy;
            otherwise leave it untouched. The run reports per-file actions and a
            total cleaned count. The process is idempotent and safe to re-run.
    
     To embed this cleaning as a test step, call `do clean_logs.do <path>` after
     generating sjlog exports; the routine will no-op when no matching patterns
     are present.
==============================================================================*/

clear all
set more off

// Parse directory argument (default: repo-absolute sjlogs)
// If no argument is provided, target the paper sjlogs folder explicitly so
// running from repo root still cleans the right files.
local logs_dir = cond("`0'" != "", "`0'", "C:/GitHub/myados/wbopendata/paper/sjlogs")

di as text _n "=============================================="
di as text "Cleaning Stata log files in: `logs_dir'"
di as text "=============================================="

// Get list of all .tex files in directory (includes .log.tex)
local filelist : dir "`logs_dir'" files "*.tex"

local filecount : word count `filelist'

if `filecount' == 0 {
    di as error "No .tex files found in `logs_dir'"
    exit 0
}

di as text "Found `filecount' file(s) to process"
di as text ""

local cleaned_count = 0

foreach filename of local filelist {
    
    local infile "`logs_dir'/`filename'"
    tempfile tmpfile
    
    // Read file, process lines, write to temp
    tempname fh_in fh_out
    capture file open `fh_in' using "`infile'", read text
    if _rc != 0 {
        di as error "  Cannot open: `filename'"
        continue
    }
    
    file open `fh_out' using "`tmpfile'", write text replace

    local linenum = 0
    local has_changes = 0
    
    file read `fh_in' line
    while r(eof) == 0 {
        local linenum = `linenum' + 1
        
        // Patterns to skip (only timestamps and known _snippet footers)
        local skip = 0

        // Skip any log footer/header lines referencing _snippet (prompt or not)
        if strpos(`"`line'"', "_snippet") > 0 {
            local skip = 1
            local has_changes = 1
        }
        if trim(`"`line'"') == "> x" {
            local skip = 1
            local has_changes = 1
        }

        // Skip timestamp lines (r; t=X.XX HH:MM:SS)
        if regexm(`"`line'"', "^r; t=[0-9]+\.[0-9]+ [0-9]+:[0-9]+:[0-9]+") {
            local skip = 1
            local has_changes = 1
        }

        // If not skipping, write line as-is
        if `skip' == 0 {
            file write `fh_out' `"`line'"' _n
        }
        
        file read `fh_in' line
    }
    
    file close `fh_in'
    file close `fh_out'
    
    // Replace original with cleaned version if changes were made
    if `has_changes' == 1 {
        capture copy "`tmpfile'" "`infile'", replace
        if _rc == 0 {
            local cleaned_count = `cleaned_count' + 1
            di as text "  Cleaned: `filename'"
        }
        else {
            di as error "  Error writing: `filename'"
        }
    }
    else {
        di as text "  No changes: `filename'"
    }
}

di as text _n "=============================================="
di as text "Cleaned `cleaned_count' file(s)"
di as text "=============================================="

exit
