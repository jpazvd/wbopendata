*******************************************************************************
*! v 1.1  	 22Dec2024        	   by Joao Pedro Azevedo                      *  
*	Wrapper for linewrap to format metadata for Stata graphs
*   Multiple output formats: stack, lines, newline, smcl
*******************************************************************************

program def _metadata_linewrap, rclass

version 14.0

    syntax , TEXT(string) [MAXLength(integer 50) PREfix(string) ///
             FORmat(string) noSTRIP]
	
	* Default prefix if not specified
	if ("`prefix'" == "") {
		local prefix "wrapped"
	}
	
	* Default format: all formats returned
	* Options: stack | lines | newline | smcl | all
	if ("`format'" == "") {
		local format "all"
	}

    quietly {
	
		*-----------------------------------------------------------------------
		* Strip SMCL tags (like {browse}) for graph compatibility unless nostrip
		if ("`strip'" != "nostrip") {
			* Remove {browse "url"} tags, keep just the URL
			local cleantext `"`text'"'
			
			* Pattern: {browse "url"} -> url
			while (strpos(`"`cleantext'"', `"{browse "') > 0) {
				local pos1 = strpos(`"`cleantext'"', `"{browse "')
				local temp1 = substr(`"`cleantext'"', `pos1' + 9, .)
				local pos2 = strpos(`"`temp1'"', `""}"')
				if (`pos2' > 0) {
					local url = substr(`"`temp1'"', 1, `pos2' - 1)
					local before = substr(`"`cleantext'"', 1, `pos1' - 1)
					local after = substr(`"`temp1'"', `pos2' + 3, .)
					local cleantext `"`before'`url'`after'"'
				}
				else {
					continue, break
				}
			}
			
			* Pattern: {browse "url":text} -> text
			while (strpos(`"`cleantext'"', `"{browse "') > 0) {
				local pos1 = strpos(`"`cleantext'"', `"{browse "')
				local temp1 = substr(`"`cleantext'"', `pos1' + 9, .)
				local pos2 = strpos(`"`temp1'"', `":"')
				local pos3 = strpos(`"`temp1'"', `"}"')
				if (`pos2' > 0 & `pos3' > `pos2') {
					local disptext = substr(`"`temp1'"', `pos2' + 1, `pos3' - `pos2' - 1)
					local before = substr(`"`cleantext'"', 1, `pos1' - 1)
					local after = substr(`"`temp1'"', `pos3' + 1, .)
					local cleantext `"`before'`disptext'`after'"'
				}
				else {
					continue, break
				}
			}
			
			local text `"`cleantext'"'
		}
		
		*-----------------------------------------------------------------------
		* Call _linewrap to split text into lines
		cap _linewrap, longstring(`"`text'"') maxlength(`maxlength')
		
		if (_rc != 0) {
			* _linewrap not available or error - return original as single line
			noi di as error "Warning: _linewrap not available, returning original text"
			return local `prefix'_line1 `"`text'"'
			return scalar `prefix'_nlines = 1
			return local `prefix'_stack `""`text'""'
			return local `prefix'_newline `"`text'"'
			return local `prefix'_smcl `"`text'"'
			exit 0
		}
		
		*-----------------------------------------------------------------------
		* Capture results from linewrap
		local nlines = r(nlines)
		
		*-----------------------------------------------------------------------
		* Build different output formats
		
		* Initialize formats
		local fmt_stack ""      // "line1" "line2" "line3" - for title()
		local fmt_newline ""    // line1`=char(10)'line2 - embedded newlines
		local fmt_smcl ""       // line1{break}line2 - for SMCL display
		
		forvalues i = 1/`nlines' {
			local thisline `"`r(line`i')'"'
			
			*-------------------------------------------------------------------
			* FORMAT: lines - individual line returns
			if inlist("`format'", "lines", "all") {
				return local `prefix'_line`i' `"`thisline'"'
			}
			
			*-------------------------------------------------------------------
			* FORMAT: stack - "line1" "line2" for graph title()
			if inlist("`format'", "stack", "all") {
				if (`i' == 1) {
					local fmt_stack `""`thisline'""'
				}
				else {
					local fmt_stack `"`fmt_stack' "`thisline'""'
				}
			}
			
			*-------------------------------------------------------------------
			* FORMAT: newline - single string with char(10) line breaks
			if inlist("`format'", "newline", "all") {
				if (`i' == 1) {
					local fmt_newline `"`thisline'"'
				}
				else {
					local nl = char(10)
					local fmt_newline `"`fmt_newline'`nl'`thisline'"'
				}
			}
			
			*-------------------------------------------------------------------
			* FORMAT: smcl - with {break} tags for Results window
			if inlist("`format'", "smcl", "all") {
				if (`i' == 1) {
					local fmt_smcl `"`thisline'"'
				}
				else {
					local fmt_smcl `"`fmt_smcl'{break}`thisline'"'
				}
			}
		}
		
		*-----------------------------------------------------------------------
		* Return results based on format
		return scalar `prefix'_nlines = `nlines'
		return local `prefix'_original `"`text'"'
		
		if inlist("`format'", "stack", "all") {
			return local `prefix'_stack `"`fmt_stack'"'
		}
		if inlist("`format'", "newline", "all") {
			return local `prefix'_newline `"`fmt_newline'"'
		}
		if inlist("`format'", "smcl", "all") {
			return local `prefix'_smcl `"`fmt_smcl'"'
		}
		
	}

end

/********************************************************************************
USAGE:
	_metadata_linewrap, text("Long indicator name that needs wrapping") ///
	                    maxlength(40) prefix(title) format(all)
	
	return list
	
OUTPUT FORMATS:
	
	* STACK - for graph title(), subtitle(), note() options
	*   r(title_stack) = `""Long indicator name" "that needs wrapping""'
	*   Usage: twoway scatter y x, title(`r(title_stack)')
	
	* LINES - individual lines for manual assembly
	*   r(title_line1) = "Long indicator name"
	*   r(title_line2) = "that needs wrapping"
	*   r(title_nlines) = 2
	
	* NEWLINE - single string with embedded line breaks (char 10)
	*   r(title_newline) = "Long indicator name" + char(10) + "that needs wrapping"
	*   Usage: Some export contexts, putdocx, etc.
	
	* SMCL - with {break} tags for Stata Results window
	*   r(title_smcl) = "Long indicator name{break}that needs wrapping"
	*   Usage: di in smcl "`r(title_smcl)'"

EXAMPLES:
	
	* Get indicator metadata and wrap the name for a graph
	_query_metadata, indicator(SH.DYN.MORT)
	_metadata_linewrap, text("`r(name)'") maxlength(45) prefix(title)
	twoway scatter y x, title(`r(title_stack)')
	
	* Wrap description with only stack format
	_metadata_linewrap, text("`r(description)'") maxlength(60) ///
	                    prefix(desc) format(stack)
	graph bar y, note(`r(desc_stack)')

********************************************************************************/
