# Tag: v18.1.0

## Tag message

```
wbopendata v18.1.0

Discovery commands, char metadata, offline testing, 89-test QA suite.

New features (v18.0):
  - Discovery commands: sources, alltopics, search(), info()
  - YAML metadata architecture: 2 files replace 89 sthlp files
  - Sync system redesign: safe dryrun default, replace safety gate
  - Cache management: cache(info|checkversion|update|clear)
  - Modular architecture: 34 ado files

New features (v18.1):
  - Variable-level char metadata (default-on, nochar to suppress)
  - Deterministic offline testing via offline() option
  - Error condition tests via rcof methodology (Gould 2001)

Bug fixes:
  - Compound quoting for SMCL {browse} tags in metadata returns
  - YAML parser embedded quotes via Mata st_sstore() bypass
  - foreach failure with topic names containing parentheses
  - _rc leaking from internal sub-calls
  - Stray set trace on in dead code

QA: 89 tests across 17 categories (up from 44/9 in v17.7.1)
Indicators: 29,323 from 71 sources (up from 20,147 from 51 sources)
```

## Command to create the tag

```bash
git tag -a v18.1.0 -m "wbopendata v18.1.0

Discovery commands, char metadata, offline testing, 89-test QA suite.

New features (v18.0):
  - Discovery commands: sources, alltopics, search(), info()
  - YAML metadata architecture: 2 files replace 89 sthlp files
  - Sync system redesign: safe dryrun default, replace safety gate
  - Cache management: cache(info|checkversion|update|clear)
  - Modular architecture: 34 ado files

New features (v18.1):
  - Variable-level char metadata (default-on, nochar to suppress)
  - Deterministic offline testing via offline() option
  - Error condition tests via rcof methodology (Gould 2001)

Bug fixes:
  - Compound quoting for SMCL {browse} tags in metadata returns
  - YAML parser embedded quotes via Mata st_sstore() bypass
  - foreach failure with topic names containing parentheses
  - _rc leaking from internal sub-calls
  - Stray set trace on in dead code

QA: 89 tests across 17 categories (up from 44/9 in v17.7.1)
Indicators: 29,323 from 71 sources (up from 20,147 from 51 sources)"
```
