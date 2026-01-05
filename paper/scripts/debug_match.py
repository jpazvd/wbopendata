#!/usr/bin/env python3
"""Debug path matching."""
import re

line = '    C:/GitHub/myados/wbopendata/paper/figs/wbopendata_worldstat_world_fertilit'
print(f'Line: {repr(line)}')
print(f'Strip: {repr(line.strip())}')
pattern = r'^\s*C:/.*\.(pdf|png|eps)?$'
match = re.match(pattern, line.strip(), re.IGNORECASE)
print(f'Match with strip: {match}')

# The issue is line.strip() removes whitespace, then pattern expects ^\s*
# Let's try matching the original line
match2 = re.match(pattern, line, re.IGNORECASE)
print(f'Match without strip: {match2}')

# Better: just check if it's a partial path
if line.strip().startswith('C:/') and ('figs/' in line or 'GitHub' in line):
    print("Would match as path line")
