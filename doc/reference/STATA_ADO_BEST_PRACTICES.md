# Best Practices for Writing Stata Ado-Files

A comprehensive guide based on analysis of 50+ production Stata packages including `estout`, `spmap`, `ftools`, `datalibweb`, `markdoc`, `github`, `alorenz`, `adecomp`, and others.

---

## Table of Contents

1. [File Structure & Organization](#1-file-structure--organization)
2. [Version Headers & Documentation](#2-version-headers--documentation)
3. [Syntax Design & Option Handling](#3-syntax-design--option-handling)
4. [Error Handling & Validation](#4-error-handling--validation)
5. [Help Files & Documentation](#5-help-files--documentation)
6. [Return Values & Stored Results](#6-return-values--stored-results)
7. [Performance & Efficiency](#7-performance--efficiency)
8. [Testing & Quality Assurance](#8-testing--quality-assurance)
9. [Distribution & Installation](#9-distribution--installation)
10. [Common Patterns & Idioms](#10-common-patterns--idioms)

---

## 1. File Structure & Organization

### 1.1 Standard Project Layout

```
mypackage/
├── README.md                    # Overview, installation, quick start
├── LICENSE                      # License file (MIT, GPL, etc.)
├── CHANGELOG.md                 # Version history
├── stata.toc                    # Package table of contents
├── mypackage.pkg                # Package manifest
├── src/
│   ├── m/
│   │   ├── mypackage.ado        # Main entry point
│   │   ├── mypackage.sthlp      # Help file
│   │   └── mypackage.dlg        # Dialog (optional)
│   └── _/
│       ├── _mp_helper1.ado      # Private helper
│       └── _mp_helper2.ado      # Private helper
├── doc/
│   └── mypackage_manual.pdf     # User manual
├── examples/
│   └── example_basic.do         # Example do-files
└── tests/
    └── test_mypackage.do        # Test scripts
```

### 1.2 File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Main command | lowercase, short | `wbopendata.ado` |
| Helper files | underscore prefix | `_query.ado` |
| Private helpers | underscore + prefix | `_wbod_parse.ado` |
| Help files | same as command | `wbopendata.sthlp` |
| Dialog files | same as command | `wbopendata.dlg` |
| Mata libraries | same as command | `wbopendata.mata` |

**From `spmap`:**
```stata
* Main file in s/ directory
spmap.ado
spmap.sthlp

* Helper files in _/ directory
_spmap_arrow.ado
_spmap_color.ado
_spmap_diagram.ado
```

### 1.3 Subcommand Architecture (from `github`)

For commands with multiple operations:

```stata
* github.ado - Main dispatcher
program github
    version 12
    
    gettoken subcmd 0 : 0
    
    if "`subcmd'" == "install"  github_install `0'
    else if "`subcmd'" == "query"    github_query `0'
    else if "`subcmd'" == "search"   github_search `0'
    else if "`subcmd'" == "check"    github_check `0'
    else {
        display as err `"unknown subcommand `subcmd'"'
        exit 199
    }
end
```

---

## 2. Version Headers & Documentation

### 2.1 Standard Version Header

Every ado-file should start with a version header:

```stata
*! version 1.2.3  15Jan2025
*! Author: João Pedro Azevedo
*! Email: jpazevedo@unicef.org
*! Title: World Bank Open Data API Client
```

**Extended header with changelog (from `markdoc`):**
```stata
*! markdoc version 5.0.0
*! Documentation: http://haghish.com/markdoc
*! Author: E. F. Haghish
*! 
*! Changelog:
*! 5.0.0 - Major rewrite for Stata 17 support
*! 4.2.0 - Added LaTeX support
*! 4.1.0 - Bug fixes
```

### 2.2 Version Requirements

**Always specify minimum Stata version:**
```stata
program mycommand
    version 14.0    // Minimum Stata version
    
    // For features requiring newer Stata:
    if c(stata_version) >= 16 {
        // Use frames
    }
    else {
        // Fallback approach
    }
end
```

**From `ftools`:**
```stata
* Check Stata version for specific features
if c(stata_version) < 14.1 {
    di as error "ftools requires Stata 14.1+"
    exit 199
}
```

### 2.3 In-Source Documentation (from `markdoc`)

```stata
/***
Title
=====

__mycommand__ — Brief description of the command

Syntax
------

__mycommand__ _varlist_ [if] [in] [, _options_]

Description
-----------

This command does something useful...

Examples
--------

    . sysuse auto, clear
    . mycommand price mpg
***/
```

---

## 3. Syntax Design & Option Handling

### 3.1 Basic Syntax Template

```stata
program mycommand, rclass
    version 14.0
    
    syntax [varlist] [if] [in] [using/] ///
        [, ///
        Replace ///
        Clear ///
        SAVing(string) ///
        Level(cilevel) ///
        NOIsily ///
        ]
    
    // Process options
    marksample touse
    
    // Main logic
end
```

### 3.2 Complex Option Handling (from `estout`)

**Grouping related options:**
```stata
syntax [anything] [using] [, ///
    /// === Cell formatting ===
    Cells(string asis) ///
    Drop(string) ///
    Keep(string) ///
    Order(string) ///
    /// === Labels ===
    Label ///
    NOLabel ///
    TItle(string) ///
    /// === Statistics ===
    STATs(string asis) ///
    STARLevels(string) ///
    /// === Output ===
    Replace ///
    Append ///
    ]
```

### 3.3 Option Validation

```stata
* Mutually exclusive options
if "`replace'" != "" & "`append'" != "" {
    di as err "options replace and append are mutually exclusive"
    exit 198
}

* Required option combinations
if "`saving'" != "" & "`replace'" == "" & "`append'" == "" {
    capture confirm file "`saving'"
    if !_rc {
        di as err "file `saving' already exists"
        exit 602
    }
}

* Numeric range validation
if `level' < 10 | `level' > 99.99 {
    di as err "level() must be between 10 and 99.99"
    exit 198
}
```

### 3.4 Default Values

```stata
* Set defaults
if "`format'" == "" local format %9.3f
if "`level'" == ""  local level = c(level)

* Using cond()
local sep = cond("`separator'" == "", ",", "`separator'")
```

---

## 4. Error Handling & Validation

### 4.1 Comprehensive Input Validation (from `adecomp`)

```stata
program mycommand
    version 14.0
    syntax varlist(min=2 max=10 numeric) [if] [in], ///
        BY(varname numeric) ///
        [Method(string)]
    
    * Validate varlist
    local nvars : word count `varlist'
    if `nvars' < 2 {
        di as err "at least two variables required"
        exit 102
    }
    
    * Validate by variable
    confirm numeric variable `by'
    qui tab `by'
    if r(r) < 2 {
        di as err "by() variable must have at least 2 groups"
        exit 198
    }
    
    * Validate method option
    if "`method'" != "" {
        local valid_methods "ols iv gmm"
        local method = lower("`method'")
        if !inlist("`method'", "ols", "iv", "gmm") {
            di as err `"method(`method') not recognized"'
            di as err `"valid methods: `valid_methods'"'
            exit 198
        }
    }
end
```

### 4.2 File Existence Checks

```stata
* Check input file exists
capture confirm file "`using'"
if _rc {
    di as err `"file `using' not found"'
    exit 601
}

* Check output file doesn't exist (without replace)
if "`replace'" == "" {
    capture confirm file "`saving'"
    if !_rc {
        di as err `"file `saving' already exists"'
        exit 602
    }
}
```

### 4.3 Dependency Checking (from `alorenz`)

```stata
program _check_dependencies
    * List of required packages
    local deps tknz linewrap spmap
    
    foreach pkg of local deps {
        capture which `pkg'
        if _rc == 111 {
            di as txt "Note: `pkg' not found, installing..."
            capture ssc install `pkg'
            if _rc {
                di as err "Could not install `pkg'"
                di as err "Please install manually: ssc install `pkg'"
                exit 601
            }
        }
    }
end
```

### 4.4 Graceful Error Recovery

```stata
* Use capture and handle errors gracefully
capture {
    tempfile tmp
    save `tmp', replace
    
    // Operations that might fail
    merge 1:1 id using "`datafile'"
}

if _rc {
    di as err "Error occurred during merge operation"
    di as err "Restoring original data..."
    use `tmp', clear
    exit _rc
}
```

### 4.5 API/Network Error Handling (from `wbopendata`)

```stata
* Handle network errors
capture copy "`url'" "`tempfile'"
if _rc {
    if _rc == 672 {
        di as err "Server returned an error"
    }
    else if _rc == 677 {
        di as err "Could not connect to server"
        di as err "Check your internet connection"
    }
    else {
        di as err "Network error (code `=_rc')"
    }
    exit _rc
}
```

---

## 5. Help Files & Documentation

### 5.1 Complete Help File Template

```smcl
{smcl}
{* *! version 1.0.0  15Jan2025}{...}
{vieweralsosee "[R] regress" "help regress"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "ssc describe mypackage" "net describe mypackage, from(https://fmwww.bc.edu/RePEc/bocode/m)"}{...}
{viewerjumpto "Syntax" "mycommand##syntax"}{...}
{viewerjumpto "Description" "mycommand##description"}{...}
{viewerjumpto "Options" "mycommand##options"}{...}
{viewerjumpto "Remarks" "mycommand##remarks"}{...}
{viewerjumpto "Examples" "mycommand##examples"}{...}
{viewerjumpto "Stored results" "mycommand##results"}{...}
{viewerjumpto "References" "mycommand##references"}{...}
{viewerjumpto "Author" "mycommand##author"}{...}

{title:Title}

{phang}
{bf:mycommand} {hline 2} Brief description of command functionality


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:mycommand}
{varlist}
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt r:eplace}}replace existing file{p_end}
{synopt:{opt clear}}clear data in memory{p_end}
{synopt:{opt sav:ing(filename)}}save results to file{p_end}

{syntab:Advanced}
{synopt:{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt:{opt noi:sily}}display intermediate output{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:mycommand} does something useful with {varlist}. The command
supports {help if} and {help in} qualifiers for subsetting data.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt replace} specifies that an existing file should be overwritten.

{phang}
{opt clear} clears the data in memory before loading new data.

{phang}
{opt saving(filename)} saves the results to {it:filename}.

{dlgtab:Advanced}

{phang}
{opt level(#)} sets the confidence level; default is {cmd:level(95)}.


{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information, see the package website at:
{browse "https://github.com/username/mycommand"}.


{marker examples}{...}
{title:Examples}

{pstd}Basic usage{p_end}
{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. mycommand price mpg}{p_end}

{pstd}With options{p_end}
{phang2}{cmd:. mycommand price mpg if foreign==1, level(90)}{p_end}

{pstd}Saving results{p_end}
{phang2}{cmd:. mycommand price mpg, saving(results.dta) replace}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:mycommand} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(mean)}}mean of dependent variable{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}command name{p_end}
{synopt:{cmd:r(varlist)}}variables used{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(table)}}results table{p_end}


{marker references}{...}
{title:References}

{phang}
Azevedo, J. P. 2025. "My Command: A Stata Package."
{it:Stata Journal} 25(1): 1-20.


{marker author}{...}
{title:Author}

{pstd}
João Pedro Azevedo{break}
UNICEF{break}
Email: {browse "mailto:jpazevedo@unicef.org":jpazevedo@unicef.org}{break}
Web: {browse "https://github.com/jpazvd"}{p_end}
```

### 5.2 Key SMCL Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `{cmd:}` | Command/keyword | `{cmd:mycommand}` |
| `{opt:}` | Option name | `{opt replace}` |
| `{it:}` | Italics (arguments) | `{it:varlist}` |
| `{bf:}` | Bold | `{bf:Important}` |
| `{err:}` | Error text (red) | `{err:Error!}` |
| `{txt:}` | Normal text | `{txt:Note:}` |
| `{res:}` | Results (yellow) | `{res:42}` |
| `{browse "url"}` | Clickable link | `{browse "https://..."}` |
| `{help cmd}` | Help link | `{help regress}` |
| `{manhelp}` | Manual entry link | `{manhelp regress R}` |
| `{phang}` | Hanging indent | (structural) |
| `{pstd}` | Standard paragraph | (structural) |
| `{synoptset}` | Option table width | `{synoptset 20 tabbed}` |

---

## 6. Return Values & Stored Results

### 6.1 r-class Programs (Non-estimation)

```stata
program mycommand, rclass
    version 14.0
    syntax varlist [if] [in]
    
    marksample touse
    
    // Calculate results
    qui summarize `varlist' if `touse'
    local n = r(N)
    local mean = r(mean)
    
    // Return scalars
    return scalar N = `n'
    return scalar mean = `mean'
    
    // Return macros
    return local cmd "mycommand"
    return local varlist "`varlist'"
    
    // Return matrices
    tempname results
    matrix `results' = (1, 2 \ 3, 4)
    return matrix table = `results'
end
```

### 6.2 e-class Programs (Estimation)

```stata
program myestimate, eclass
    version 14.0
    syntax varlist(min=2) [if] [in]
    
    marksample touse
    gettoken depvar indepvars : varlist
    
    // Estimation
    qui regress `depvar' `indepvars' if `touse'
    
    // Store results
    ereturn local cmd "myestimate"
    ereturn local depvar "`depvar'"
    ereturn scalar N = e(N)
    ereturn matrix b = e(b)
    ereturn matrix V = e(V)
    
    // Display results
    ereturn display
end
```

### 6.3 Clearing Previous Results

```stata
* Clear r() before returning new results
return clear

* For e-class
ereturn clear

* Or post all at once
ereturn post `b' `V', obs(`n') esample(`touse')
```

---

## 7. Performance & Efficiency

### 7.1 Mata Integration (from `ftools`)

```stata
* Check if Mata library is compiled
capture mata: mata which ftools()
if _rc {
    di as txt "Compiling Mata library..."
    run "`c(sysdir_plus)'f/ftools.mata"
}
```

```mata
// ftools.mata
mata:
    real matrix process_data(real matrix X) {
        // Fast operations in Mata
        return(X' * X)
    }
end
```

### 7.2 Efficient Loops

```stata
* AVOID: Slow nested loops
forvalues i = 1/`n' {
    forvalues j = 1/`m' {
        // ...
    }
}

* PREFER: Mata for matrix operations
mata: result = X * Y

* PREFER: egen with by groups instead of loops
bysort group: egen mean_x = mean(x)
```

### 7.3 Temporary Objects

```stata
* Always use tempvar, tempfile, tempname
tempvar touse diff
tempfile tmp
tempname results

gen `touse' = 1
gen `diff' = x - y
save `tmp'
matrix `results' = (1, 2)
```

### 7.4 Memory Management

```stata
* Preserve and restore for safety
preserve
    // Modify data
    keep if `touse'
    collapse (mean) x y
restore

* Or use frames (Stata 16+)
if c(stata_version) >= 16 {
    frame create results
    frame results {
        // Work in separate frame
    }
}
```

---

## 8. Testing & Quality Assurance

### 8.1 Test Script Template

```stata
*! test_mycommand.do
*! Unit tests for mycommand

clear all
set more off

local passed 0
local failed 0

* Test 1: Basic functionality
di _n "Test 1: Basic functionality"
capture {
    sysuse auto, clear
    mycommand price mpg
}
if _rc == 0 {
    di as txt "  PASS"
    local ++passed
}
else {
    di as err "  FAIL (error code `=_rc')"
    local ++failed
}

* Test 2: Options work
di _n "Test 2: Options"
capture {
    sysuse auto, clear
    mycommand price mpg, level(90) replace
}
if _rc == 0 & r(N) > 0 {
    di as txt "  PASS"
    local ++passed
}
else {
    di as err "  FAIL"
    local ++failed
}

* Test 3: Error handling
di _n "Test 3: Invalid input should error"
capture mycommand
if _rc != 0 {
    di as txt "  PASS (correctly errored)"
    local ++passed
}
else {
    di as err "  FAIL (should have errored)"
    local ++failed
}

* Summary
di _n(2) "============================="
di "Tests passed: `passed'"
di "Tests failed: `failed'"
di "============================="

if `failed' > 0 {
    exit 1
}
```

### 8.2 Continuous Integration

**.github/workflows/stata-tests.yml:**
```yaml
name: Stata Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        uses: stata-actions/setup-stata@v1
        with:
          version: 17
      - run: stata -b do tests/run_tests.do
```

### 8.3 Version Compatibility Testing

```stata
* Test across Stata versions
if c(stata_version) >= 16 {
    // Test frame features
}
if c(stata_version) >= 15 {
    // Test putdocx features
}
if c(stata_version) >= 14 {
    // Test unicode features
}
```

---

## 9. Distribution & Installation

### 9.1 Package Manifest (stata.toc)

```
v 3
d mypackage - Brief description
d Author: João Pedro Azevedo
d Support: jpazevedo@unicef.org
d Distribution-Date: 20250115
d 
p mypackage
```

### 9.2 Package File (.pkg)

```
v 3
d mypackage. Brief description of the package
d 
d Author: João Pedro Azevedo
d UNICEF
d Support: jpazevedo@unicef.org
d 
d Distribution-Date: 20250115
d Version: 1.2.3
d 
d Keywords: data, analysis, statistics
d 
f src/m/mypackage.ado
f src/m/mypackage.sthlp
f src/m/mypackage.dlg
f src/_/_mp_helper1.ado
f src/_/_mp_helper2.ado
f examples/example1.do
f doc/mypackage_manual.pdf
```

### 9.3 SSC Submission Checklist

- [ ] All file names are lowercase
- [ ] No spaces in filenames
- [ ] Version number in .ado header matches .pkg
- [ ] Help file (.sthlp) is complete
- [ ] `search mypackage` shows no conflicts
- [ ] Dependencies are documented
- [ ] Test script runs without errors
- [ ] Contact email is valid

---

## 10. Common Patterns & Idioms

### 10.1 Subcommand Dispatcher

```stata
program mycommand
    version 14.0
    
    gettoken subcmd 0 : 0, parse(" ,")
    
    local subcmds "load save export list help"
    
    if `: list subcmd in subcmds' {
        _mc_`subcmd' `0'
    }
    else if "`subcmd'" == "" {
        di as err "subcommand required"
        di as err "available: `subcmds'"
        exit 198
    }
    else {
        di as err `"unknown subcommand: `subcmd'"'
        exit 199
    }
end

program _mc_load
    // Implementation
end

program _mc_save
    // Implementation
end
```

### 10.2 Global Settings Manager (from `datalibweb`)

```stata
* User sets global preferences
global MYPACKAGE_VERSION 2
global MYPACKAGE_CACHE "D:/data/cache"
global MYPACKAGE_VERBOSE 1

* Package reads globals with defaults
local version = cond("$MYPACKAGE_VERSION" != "", ///
    $MYPACKAGE_VERSION, 1)
    
local verbose = cond("$MYPACKAGE_VERBOSE" != "", ///
    $MYPACKAGE_VERBOSE, 0)
```

### 10.3 Progress Display

```stata
program show_progress
    args current total task
    
    local pct = round(100 * `current' / `total')
    local bars = round(`pct' / 5)
    local spaces = 20 - `bars'
    
    local bar = substr("####################", 1, `bars')
    local space = substr("                    ", 1, `spaces')
    
    di _continue char(13) as txt "`task': [" ///
        as res "`bar'" as txt "`space'" ///
        as txt "] " as res "`pct'%" _continue
end

* Usage:
forvalues i = 1/100 {
    show_progress `i' 100 "Processing"
    // Do work
}
di ""  // Final newline
```

### 10.4 Quiet vs. Verbose Mode

```stata
program mycommand
    syntax [, Verbose Quiet]
    
    if "`verbose'" != "" {
        local noi "noisily"
    }
    else if "`quiet'" != "" {
        local noi "quietly"
    }
    else {
        local noi ""
    }
    
    `noi' di "Processing..."
    `noi' command1
    `noi' command2
end
```

### 10.5 Cleanup on Exit

```stata
program mycommand
    version 14.0
    
    * Set up cleanup
    capture noisily {
        // Main program logic
        _mycommand_impl `0'
    }
    local rc = _rc
    
    * Always clean up
    capture mata: mata drop __mytempmat
    capture frame drop __myworkframe
    
    * Exit with original error code
    if `rc' exit `rc'
end

program _mycommand_impl
    // Actual implementation
end
```

### 10.6 Assertion-Based Validation

```stata
* Use assert for internal consistency checks
assert `n' > 0
assert inlist("`type'", "ols", "iv", "gmm")

* Capture for user input errors
capture assert `n' > 0
if _rc {
    di as err "no observations"
    exit 2000
}
```

---

## Quick Reference Card

### Essential Commands

| Task | Command |
|------|---------|
| Parse syntax | `syntax varlist [if] [in] [, options]` |
| Create temp var | `tempvar x` → `gen `x' = 1` |
| Create temp file | `tempfile tmp` → `save `tmp'` |
| Create temp name | `tempname mat` → `matrix `mat' = I(3)` |
| Mark sample | `marksample touse` |
| Return scalar | `return scalar N = 42` |
| Return macro | `return local cmd "mycommand"` |
| Return matrix | `return matrix table = `results'` |
| Check file exists | `confirm file "filename"` |
| Check command exists | `which commandname` |
| Get token | `gettoken first rest : varlist` |
| Conditional display | ``noi' display "text"` |

### Standard Option Names

| Option | Typical Syntax |
|--------|----------------|
| Replace file | `Replace` |
| Clear data | `Clear` |
| Save output | `SAVing(string)` |
| Confidence level | `Level(cilevel)` |
| Display details | `NOIsily` or `Verbose` |
| Suppress output | `Quietly` |
| Format output | `Format(string)` |

---

*Document created: December 2025*
*Based on analysis of 50+ production Stata packages*
*For Stata Journal submission guidelines, see STATA_JOURNAL_GUIDELINES.md*
