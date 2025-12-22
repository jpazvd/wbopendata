program define _linewrap, rclass 
*!	_linewrap  by Mead Over & Joao Pedro Azevedo  Version 2.1 4Jun2023
*   Renamed from linewrap to _linewrap for wbopendata package
*	This program splits a long string into lines of -maxlength- characters each
*	There are -r(nlines)- lines of text, named -r(line1)-, -r(line2)- ...
*
*	The -square- option combines with -maxlength- to force a line break every =maxlength-
*	characters even if the break is in the middle of a word.  Without the -square- option,
*	default behavior is to break each line at the first word break before =maxlength-

*	Alternatively, with the -words- option, each line is a word.

*	The -display- option prints each of the multiple lines.  The -linenumber- option
*	adds sequence numbers to the displayed lines

	version 14.0  //  Required for Unicode support
	syntax , [LOngstring(string) MAXlength(integer 79) Words Characters Display  ///
		LInenumbers Title(string) SQuare Name(string) replace STack add continue  ///
		noheader Parse(passthru) debug LASTpchar]
		
	foreach opt in parse square words characters  {
		if `"``opt''"'~= "" {
			local optlist `optlist' `opt'
		}
	}
	opts_exclusive `"`optlist'"'
	
	if `"`longstring'"'==`""' {
		if "`continue'"=="continue" {
			local longstring "There is no text in the option -longstring()- to wrap or display."
			local exitworeturn exitworeturn  //  For version 1.8, can this macro be eliminated?
		}
		else {
			di as err "without option -continue-, option longstring() required"
			exit 198
		}
	}
	
	if ("`add'"!="" ) {
		local keeplast "return add"
		return add
	}
	
	if ("`replace'"!="" ) {
		di as err "The option -replace- is obsolete. Use option -add- to accumulate stored results."
		exit 198
	}

	if ("`name'" == "") {
		local name "line"
		local stackname "stack"
		local n_name nlines
		local s_name strlen
	}
	else {
		local stackname `name'		
		local n_name nlines_`name'
		local s_name strlen_`name'
	}
	local `n_name'
	
	if "`title'" ~= "" {
		di _n as txt "`title'"
	}

	if "`display'"~="" | "`linenumbers'"~="" {
		if "`linenumbers'"~="" {
			local tab5 _col(5)
		}
		if "`header'"~="noheader"  {
			local newline _n `tab5'
			foreach i of numlist 1/`maxlength' {
				if mod(`i',10) == 0 {
					di `newline' as txt int(`i'/10) _c
				}
				else {
					di `newline' " " _c
				}
				local newline _c
			}
			local newline _n `tab5'
			foreach i of numlist 1/`maxlength' {
				di as txt `newline' mod(`i',10) _c
				local newline _c
			}
			di _n
		}
		if "`linenumbers'"~="" {
			local ln \`line' _col(5)
		}
		//  Use local -show- to implement the display option
		local show show
	}

	if "`words'"=="" & "`characters'"=="" {
		local longstring = ustrtrim(stritrim(`"`longstring'"'))
		local  lngth =  ustrlen(`"`longstring'"')  //  Number of Unicode characters
		local dlngth = udstrlen(`"`longstring'"')  //  Number of display columns <= -lngth-

		if "`square'"~="" {    // Wrap at maxlength regardless of spaces
			local nlines = ceil((`lngth'-1)/`maxlength')
			if `dlngth' > `lngth'  local nlines = `nlines' + 1
			foreach line of numlist 1/`nlines' {
				local tmpstr = usubstr(`"`longstring'"', (`line'-1)*`maxlength'+1,`maxlength')
				if "`show'"~="" {
					di as txt `ln'  as res `"`tmpstr'"'
				}
				if "`exitworeturn'"=="" return local `name'`line' = `"`tmpstr'"'
			}
		}  //  End of code for -square-

        *&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		else {  //  Break lines on spaces and optionally also on parse characters
			local line = 0
			local restofstr `"`longstring'"'
			local lngthrest = udstrlen(`"`longstring'"')  //  Total number of characters in the rest of the string
			
	
			//  Loop to create the lines of text from -longstring-
			while `lngthrest' > 0  {

				local line = `line' + 1

				//	Call subroutine to find the line break
				findlinebreak , restofstr(`"`restofstr'"') lngthrest(`lngthrest') maxlength(`maxlength') `parse' `debug' `lastpchar'

				local linelnth `r(linelnth)'

				local tmpstr = ustrtrim(usubstr(`"`restofstr'"',1, `linelnth'))
				
				local restofstr = ustrtrim(usubstr(`"`restofstr'"',`linelnth'+1,.))
				local lngthrest = udstrlen(`"`restofstr'"')  //  Total number of characters in the rest of the string
				
				local nlines = `line'
	
				if "`show'"~="" {
					di as txt `ln'  as res `"`tmpstr'"'
				}
				if "`exitworeturn'"=="" return local `name'`line' = `"`tmpstr'"'

			}  //  End of loop to create lines of text using spaces or parse characters

		}  // End of parsing on spaces and optionally on parse characters
		*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
		
	}  //  End of logic if NOT parsing on -words- or -characters-
	
	else {  // Option -words- or -characters- selected
		if "`words'"=="words" & "`characters'"=="characters" {
		    di as err "Choose either the option -words- or the option -characters, not both"
			exit 198
		}
		if "`words'"=="words" {
			local nlines : word count `longstring'  //  Number of lines = number of words
			local longstring = ustrtrim(stritrim(`"`longstring'"'))
			foreach line of numlist 1/`nlines' {
				local tmpstr : word `line' of `longstring'
				if "`show'"~="" {
					di as txt `ln'  as res `"`tmpstr'"'
				}
				if "`exitworeturn'"=="" return local `name'`line' = `"`tmpstr'"'
			}
		}
		if "`characters'"=="characters" {
			local longstring = ustrtrim(stritrim(`"`longstring'"'))
			local nlines : ustrlen local longstring  //  Number of lines = number of Unicode characters

			foreach line of numlist 1/`nlines' {
				local tmpstr = usubstr(`"`longstring'"',`line',1)
				if "`show'"~="" {
					di as txt `ln'  as res `"`tmpstr'"'
				}
				if "`exitworeturn'"=="" return local `name'`line' = `"`tmpstr'"'
			}
		}
	}

	if "`stack'"=="stack" {
		foreach i of numlist 1/`nlines' {
			local `stackname' = `"``stackname''"' +  " "  +  `""`return(`name'`i')'""'

if "`debug'" ~="" di as err "This is nline # " as res `i' as err " and -`stackname'- is: " as res `"``stackname''"'

		}
		if "`exitworeturn'"=="" return local `stackname' = `"``stackname''"'
	}
	if "`exitworeturn'"=="" {
		return local `n_name'  `nlines'
		return local `s_name'  `lngth'
	} 
	else {
		return local `n_name'  0
		return local `s_name'  0
	}
	
	`keeplast'
	return local linelnth
	
end  /* End of main program  */

program define findlinebreak , rclass
*!	For version 2.0 of linewrap.ado
version 14 

	syntax, restofstr(string) lngthrest(integer) maxlength(integer) [parse(string) debug otheropts lastpchar ]

	//	Put the parse characters into macros -char`i'-, and collected in -charlist-
	//  Though it's inefficient, we assemble this -charlist- each time this program is called.
	if `"`parse'"'~=""  {
		//  Put each parse character into its own macro: -char`i'-
		tokenize `"`parse'"' , parse(`"`parse'"')
		//  Loop over the parse characters
		local i = 1
		while "``i''" ~= "" {
			local char`i' `"``i''"'
			local charlist `charlist'   `char`i''
			local comma ", "
			local i = `i' + 1
		}
		local charlist = ustrtrim(`"`charlist'"')
	}		

	//  Assumption: No line can be longer than -maxlength-

	//	Look at a chunk of -maxlength- characters
	//		Remove trailing blanks
	local chunk = ustrrtrim(usubstr(`"`restofstr'"',1,`maxlength'))
                                  if "`debug'" ~="" di as err "-chunk- is: " as res `"`chunk'"'

	//	Look for the first blank from the end of the string
	//	Get its position from the end of the string
	//		If there is no blank, -blnkpos- equals 0
	local blnkpos = ustrrpos(`"`chunk'"'," ")				
                                  if "`debug'" ~="" di as err "Position in line of closest blank before -maxlength-: -blnkpos- is: " as res "`blnkpos'"
		if `blnkpos' == 0 | `lngthrest' <= `maxlength' {
			local blnkpos = `maxlength' + 1
                                  if "`debug'" ~="" di as err "Since -blnkpos- ==0, set -blnkpos- to: " as res "`blnkpos'"
		}

	//  &&&&&&&&&&&&&&&     -parse()- option selected     &&&&&&&&&&&&&&&&&
	//  Search the "chunk" of text for the parse characters
	//  closest to the -maxlength- end of the line.
	if `"`charlist'"'~=""  {
                                  if "`debug'" ~="" di as err "Characters for parsing, -charlist-, are : " as res "`charlist'"

		//  For each chunk of text, Loop over the parse characters
		local minbrkpos = .
		local maxbrkpos = 0  //  for future use
		foreach char in `charlist'  {
			local posofchar = ustrrpos(`"`chunk'"',"`char'")
				if "`char'"=="," {
					local posofchar = cond(`posofchar' > 0, `posofchar' , .)
				}
				else {
					//  Subtract 1 to keep the parsed character at the end of the line of text
					local posofchar = cond(`posofchar' > 1, `posofchar' - 1, .)
				}
			local minbrkpos = min(`posofchar' , `minbrkpos')						
			local maxbrkpos = max(`posofchar' , `maxbrkpos')  //  for future use
                                  if "`debug'" ~="" di as err "For the parse character |" as res "`char'" as err "|, -minbrkpos- is: " as res "`minbrkpos'" as err " and -maxbrkpos- is: " as res "`maxbrkpos'"
		
		} //  End of loop over the parse characters for this line

		local maxbrkpos = cond(`maxbrkpos'==0, `maxlength' + 2 ,`maxbrkpos' )
                                  if "`debug'" ~="" di as err "Across all the parse characters, -minbrkpos- is: " as res "`minbrkpos'"  as err " and -maxbrkpos- is: " as res "`maxbrkpos'"

		if "`lastpchar'"=="lastpchar" {
			local linelnth   = min(`maxlength', `blnkpos' , `maxbrkpos' )	
                                 if "`debug'" ~="" di as err "min(maxlength, blnkpos, maxbrkpos) is: " as res `"min(`maxlength', `blnkpos' , `maxbrkpos' )"'
		}
		else {
			local linelnth   = min(`maxlength', `blnkpos' , `minbrkpos' )
                                 if "`debug'" ~="" di as err "min(maxlength, blnkpos, minbrkpos) is: " as res `"min(`maxlength', `blnkpos' , `minbrkpos' )"'
		}
                                 if "`debug'" ~="" di as err "-linelnth- is: " as res "`linelnth'"

		return local linelnth `linelnth'
		return local charlist `charlist'

	}
	*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
	
	//  &&&&&&&&&&     -parse()- option not selected     &&&&&&&&&
	else {
		local linelnth   = min(`maxlength', `blnkpos')
		return local linelnth `linelnth'

	}
				
end   /*  End of program -findlinebreak-  */


* Ver 1.0 6/18/2012 Long string split into lines of -maxlength- each
* Ver 1.1 9/3/2015  Add option to split the long string into words
* 	with one word on each line.
* Ver 1.2 9/5/2015  Add options -display- and -linenumbers- to print the long string
* 	Adds the -square- option to cut each line precisely at -maxlength- characters.
* 	Changes the default to cut lines at the first word break before -maxlength-.
* 	Also add the -title- option 
* Ver 1.3 11/5/2015  Fix a bug in the line wrapping under -maxlength- control
* 	when the square option is not selected.
* Ver 1.4 18Jan2019  Joao Pedro Azevedo  added the name() option, which allows
*   the user to specify the names of the returned macros and accumulate saved lines
*   over multiple executions.
* Ver 1.5 22Jan2020  Fixes bug in -name- option.  Adds replace option
* Ver 1.6 13Feb2021 Add the -stack-, -add- and -character-  options
*	Make comptible with Unicode strings, replacing -length()- with -udstrlen()-
*	Make the -replace- option obsolete.
* Ver 1.7 11Oct2022 Add the -continue- option and allow -longstring()- to be optional
*	Return to the user the number of characters in -longstring()- 
*	Allow embedded quotes provided user applies double quotes to the entire string.
* Ver 1.8 1Feb2023 Add the option = parse("pchars")- to break the text not only at spaces 
*	but also at the last in the line occurence of selected other characters.
* Ver 2.0 1Jun2023 Add -noheader option to suppress the numbering of display columns 
*		when display or linenumbers option are selected. 
* Ver 2.1 4Jun2023 Fix bug in the option -add-
*	
*	Future possibilities:
*		Enable breaking the text ONLY at a parsing character.
*		Add a -phang- option so that the second and subsequent lines of wrapped text 
*		are indented by, say, 4 spaces.
