#!/usr/bin/env python3
"""
Clean Stata log files for LaTeX inclusion.

Removes:
- "name: _snippet" header lines
- "r; t=X.XX HH:MM:SS" timing lines  
- "log close _snippet" and trailing separator lines
- Leading/trailing blank lines
- ". " only lines (empty commands)
- Stray "> ex" or "> x" continuation lines
- References to temp files (AppData/Local/Temp)
- Line continuation markers "> " (joins with previous line, preserves ///)
- "cap noi " prefix from commands
- "if _rc" control flow blocks at end
- Extra indentation after command dots (". " → ". ")
- "// /" broken continuations → "///"
"""

import re
from pathlib import Path

def clean_log(content: str) -> str:
    lines = content.split('\n')
    cleaned = []
    
    # Process all lines, filtering out unwanted content
    in_content = False
    for line in lines:
        # Skip "name:  _snippet" lines
        if re.match(r'^\s*name:\s*_snippet', line):
            continue
        # Skip timing lines (r; t=...)
        if re.match(r'^r;\s*t=[\d.]+\s+\d{2}:\d{2}:\d{2}', line):
            continue
        # Skip "log close _snippet" and stop processing
        if re.match(r'^\.\s*log\s+close\s+_snippet', line):
            break
        # Skip standalone empty command lines ". "
        if line.strip() == '.' or line.strip() == '. ':
            continue
        # Skip stray "> ex" or "> x" continuation at start
        if not in_content and line.strip() in ('> ex', '> x', '>x'):
            continue
        # Skip leading empty lines
        if not in_content and line.strip() == '':
            continue
        # Skip lines referencing temp files
        if re.search(r'AppData/Local/Temp|JPAZEV~1|ST_[0-9a-f]+_\d+\.tmp', line):
            continue
        # Skip "(file ... not found)" temp file messages
        if re.search(r'\(file.*\.tmp not found\)', line):
            continue
        # Skip "if _rc" control flow lines (error handling boilerplate)
        if re.match(r'^\.\s*if\s+_rc\s*!=?\s*0', line):
            continue
        if re.match(r'^\.\s*di\s+as\s+text\s+"Note:\s*worldstat', line):
            continue
        if line.strip() == '. }' or line.strip() == '.}':
            continue
        # Skip empty local macro initializations (`. local varname ""` or `. local varname `""'`)
        if re.match(r'^\.\s*local\s+\w+\s+(`""\'?|"")?\s*$', line):
            continue
        # Skip comment-only lines (`. * comment text`)
        if re.match(r'^\.\s*\*\s*(Store|Initialize|Setup)', line, re.IGNORECASE):
            continue
        # Skip graph export commands and their responses
        if re.match(r'^[>\s]*\.?\s*(cap\s+noi\s+)?graph\s+export\s+', line):
            continue
        if re.match(r'^file\s+.*\.(pdf|png|eps)', line, re.IGNORECASE):
            continue
        if re.search(r'saved as (PDF|PNG|EPS)', line, re.IGNORECASE):
            continue
        # Skip truncated path lines from graph export (lines that are just paths)
        if line.strip().startswith('C:/') and ('figs/' in line or '/paper/' in line):
            continue
        # Skip standalone continuation lines that complete graph export (> lace, etc)
        if re.match(r'^[>\s]*lace\s*$', line):
            continue
        # Skip worldstat indicator list URL line
        if re.search(r'For a full list of indicators.*worldbank\.270a\.info', line):
            continue
        # Skip orphaned URL fragments (icator.html, stat", worldstat", format, etc)
        # These are continuations of filtered lines
        if line.strip() in ('icator.html.', 'icator.html', 'stat"', 'worldstat"', 'format', 
                            'as PDF format', 'saved as PDF format'):
            continue
        # Skip continuation lines that are orphaned fragments (start with > and contain filtered content)
        if line.startswith('>') and re.search(r'icator\.html|stat"|worldstat"|worldbank\.270a|format=CSV', line):
            continue
        # Skip standalone "file" lines (incomplete path output)
        if line.strip() == 'file':
            continue
        # Skip truncated file path lines from worldstat
        if re.match(r'^\s*C:/GitHub/.*\.(pdf|png)$', line.strip()):
            continue
        # Skip "(you are using old merge syntax...)" warnings
        if re.search(r'\(you are using old .*syntax', line):
            continue
        # Skip empty lines with only continuation markers
        if line.strip() in ('/', '///', '//', '>', '> /'):
            continue
            
        in_content = True
        
        # Remove "cap noi " prefix from commands
        line = re.sub(r'^(\.\s*)cap\s+noi\s+', r'\1', line)
        
        # Fix extra indentation: ".     command" → ". command"
        line = re.sub(r'^\.(\s{2,})', '. ', line)
        
        # Fix broken "// /" → "///"
        line = re.sub(r'//\s+/', '///', line)
        
        # Fix trailing "//" that should be "///" (line continuation)
        if line.rstrip().endswith(', //') or line.rstrip().endswith(') //'):
            line = line.rstrip()[:-2] + '///'
        
        cleaned.append(line)
    
    # Join continuation lines: "> " lines should be appended to previous line
    # BUT preserve line breaks after "///" for readability
    joined = []
    for line in cleaned:
        if line.startswith('> ') and joined:
            prev = joined[-1]
            cont = line[2:].lstrip()
            # If previous line ends with "///", keep as separate line with proper indent
            if prev.rstrip().endswith('///'):
                joined.append('      ' + cont)  # 6-space indent (aligns with ". " prefix)
            else:
                # For other continuations, also use indentation instead of "> "
                joined.append('      ' + cont)
        else:
            joined.append(line)
    
    cleaned = joined
    
    # Remove trailing empty lines and separators
    while cleaned and (cleaned[-1].strip() == '' or 
                       cleaned[-1].strip() == '-' * 80 or
                       re.match(r'^-+$', cleaned[-1].strip())):
        cleaned.pop()
    
    # Remove "name: _snippet" if it appears at end
    while cleaned and re.match(r'^\s*name:\s*_snippet', cleaned[-1]):
        cleaned.pop()
    
    # Remove trailing separator again
    while cleaned and cleaned[-1].strip().startswith('-' * 20):
        cleaned.pop()
    
    # Remove trailing "if _rc" blocks and empty braces
    while cleaned and (cleaned[-1].strip() in ('. }', '.}', '}') or
                       re.match(r'^\.\s*if\s+_rc', cleaned[-1]) or
                       re.match(r'^\.\s*di\s+as\s+text\s+"Note:', cleaned[-1])):
        cleaned.pop()
    
    # Remove trailing whitespace from each line
    cleaned = [line.rstrip() for line in cleaned]
    
    # Collapse multiple consecutive blank lines into single blank line
    final = []
    prev_blank = False
    for line in cleaned:
        is_blank = line.strip() == ''
        if is_blank and prev_blank:
            continue  # Skip consecutive blank lines
        final.append(line)
        prev_blank = is_blank
    
    return '\n'.join(final)

def main():
    sjlogs_dir = Path(__file__).parent / 'sjlogs'
    
    # Read from .tex files (raw Stata output), write to .log.tex files (cleaned)
    for tex_file in sjlogs_dir.glob('*.tex'):
        # Skip .log.tex files - we want to read the raw .tex and create .log.tex
        if tex_file.name.endswith('.log.tex'):
            continue
        
        log_file = tex_file.with_suffix('.log.tex')
        print(f"Cleaning {tex_file.name}...")
        content = tex_file.read_text(encoding='utf-8')
        cleaned = clean_log(content)
        log_file.write_text(cleaned, encoding='utf-8')
        print(f"  Done: {len(content)} -> {len(cleaned)} chars")

if __name__ == '__main__':
    main()
