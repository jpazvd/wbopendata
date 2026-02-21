*******************************************************************************
* yaml
*! v 1.9.0   20Feb2026               by Joao Pedro Azevedo (UNICEF)
* Read and write YAML files in Stata
* v1.9.0: INDICATORS preset for wbopendata/unicefdata parsing
* v1.8.0: collapse colfields() and maxlevel() options for selective columns
* v1.7.0: Mata bulk-load (BULK), collapsed wide-format output (COLLAPSE)
* v1.5.0: Added canonical early-exit targets, streaming tokenization, index frames,
*         fastread block scalar capture, unsupported-feature checks, and file checks
* v1.3.1: Fixed return value propagation from frame context in yaml_get and yaml_list
*         Fixed hyphen-to-underscore normalization in yaml_get search prefix
*******************************************************************************

/*
DESCRIPTION:
    Main command for YAML file operations in Stata.
    Supports reading, writing, and displaying YAML data.
    
    DEFAULT BEHAVIOR: Uses current dataset.
    FRAME OPTION: Use frame(name) to work with Stata frames (16+).
    
SYNTAX:
    yaml read using "filename.yaml" [, frame(name) options]
    yaml write using "filename.yaml" [, frame(name) options]
    yaml describe [, frame(name)]
    yaml list [keys] [, frame(name) options]
    yaml get keyname [, frame(name) options]
    yaml validate [, frame(name) options]
    yaml dir [, detail]
    yaml frames [, detail]
    yaml clear [framename] [, all]
    
SUBCOMMANDS:
    read     - Read YAML file into Stata (dataset by default, or frame)
    write    - Write Stata data to YAML file
    describe - Display structure of loaded YAML data
    list     - List specific keys or all keys
    get      - Get metadata attributes for a specific key
    validate - Validate YAML data
    dir      - List all YAML data in memory (dataset and frames)
    frames   - List only YAML frames in memory (Stata 16+)
    clear    - Clear YAML data from memory
    
OPTIONS:
    frame(name) - Use specified frame instead of current dataset
*/

program define yaml
    version 14.0

    gettoken subcmd 0 : 0, parse(" ,")

    local subcmd = lower("`subcmd'")

    if ("`subcmd'" == "") {
        di as err "subcommand required"
        di as err "syntax: yaml {read|write|describe|list|get|validate|dir|frames|clear} ..."
        exit 198
    }

    if ("`subcmd'" == "read") {
        yaml_read `0'
    }
    else if ("`subcmd'" == "write") {
        yaml_write `0'
    }
    else if ("`subcmd'" == "describe" | "`subcmd'" == "desc") {
        yaml_describe `0'
    }
    else if ("`subcmd'" == "list") {
        yaml_list `0'
    }
    else if ("`subcmd'" == "get") {
        yaml_get `0'
    }
    else if ("`subcmd'" == "validate" | "`subcmd'" == "check") {
        yaml_validate `0'
    }
    else if ("`subcmd'" == "dir") {
        yaml_dir `0'
    }
    else if ("`subcmd'" == "frames" | "`subcmd'" == "frame") {
        yaml_frames `0'
    }
    else if ("`subcmd'" == "clear") {
        yaml_clear `0'
    }
    else {
        di as err "unknown subcommand: `subcmd'"
        di as err "valid subcommands: read, write, describe, list, get, validate, dir, frames, clear"
        exit 198
    }
end
