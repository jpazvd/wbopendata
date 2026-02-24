*******************************************************************************
*! _wbopendata_check_version v1.1.0  22Feb2026
*! Check remote metadata release tag vs local cache
*******************************************************************************

program define _wbopendata_check_version, rclass
    version 14.0

    local cache_dir = c(sysdir_plus) + "_/"
    local vf = "`cache_dir'metadata_version.txt"

    capture confirm file "`vf'"
    if (_rc == 0) {
        tempname fh
        file open `fh' using "`vf'", read
        file read `fh' local_ver
        file close `fh'
        local local_ver = trim("`local_ver'")
    }
    else local local_ver "0.0.0"

    local api_url "https://api.github.com/repos/jpazvd/wbopendata/releases/latest"
    local tmpjson `"`c(tmpdir)'wbod_version.json"'
    local remote_ver ""
    local check_success = 0

    capture copy `"`api_url'"' `"`tmpjson'"', replace
    if (_rc == 0) {
        capture noisily _wbopendata_parse_github_json `"`tmpjson'"'
        if (_rc == 0) {
            local remote_ver `"`r(tag_version)'"'
            local check_success = 1
        }
        else {
            di as text "(Could not parse version info - using local version)"
            local remote_ver "`local_ver'"
        }
        capture erase `"`tmpjson'"'
    }
    else {
        di as text "(Could not check for updates - using local version)"
        local remote_ver "`local_ver'"
    }

    local needs_update = 0
    if ("`remote_ver'" != "" & "`remote_ver'" != "`local_ver'") {
        _wbopendata_compare_versions "`local_ver'" "`remote_ver'"
        local needs_update = r(newer)
    }
    * If no local cache exists at all, force an update when we got a real version
    if (`needs_update' == 0 & "`local_ver'" == "0.0.0" & `check_success') {
        local needs_update = 1
    }

    return local local_version = "`local_ver'"
    return local remote_version = "`remote_ver'"
    return scalar needs_update = `needs_update'
    return scalar check_success = `check_success'
end


program define _wbopendata_parse_github_json, rclass
    version 14.0
    args json_file

    local tag_version ""

    * GitHub API returns JSON on a single line.  The "body" field contains
    * markdown with backticks and quotes that break Stata macro quoting
    * when the whole line is placed in a local.
    * Fix: split on commas first so each JSON field is a short, safe line.

    * Step 1: replace commas with newlines so each JSON key is a short line
    tempfile split_json
    filefilter "`json_file'" "`split_json'", from(",") to(",\n")

    * Step 2: further isolate the tag_name value by splitting on colons
    *   Input line:  "tag_name":"v17.7.1",
    *   After split:  "tag_name"   \n   "v17.7.1",
    tempfile split2
    filefilter "`split_json'" "`split2'", from(":") to(":\n")

    * Step 3: scan for the "tag_name" key, then grab the next "v..." value
    *   After colon-split the sequence is:
    *     "tag_name"         ← key line (contains "tag_name")
    *     "v17.7.1",         ← value line (starts with "v)
    tempname fh
    file open `fh' using "`split2'", read
    local found_key = 0
    file read `fh' line
    while r(eof) == 0 {
        if `found_key' {
            * This line is the tag value, e.g.  "v17.7.1",
            * Use regexm to extract MAJOR.MINOR.PATCH directly
            * — avoids all quoting issues with substr/inrange on
            *   characters that happen to be double-quote marks.
            if regexm(`"`line'"', "([0-9]+\.[0-9]+\.[0-9]+)") {
                local tag_version = regexs(1)
            }
            continue, break
        }
        * Look for the key line containing tag_name
        if strpos(`"`line'"', "tag_name") > 0 {
            local found_key = 1
        }
        file read `fh' line
    }
    file close `fh'

    return local tag_version = trim("`tag_version'")
end


program define _wbopendata_compare_versions, rclass
    version 14.0
    args v1 v2

    tokenize "`v1'", parse(".")
    local v1a = real("`1'")
    local v1b = real("`3'")
    local v1c = real("`5'")

    tokenize "`v2'", parse(".")
    local v2a = real("`1'")
    local v2b = real("`3'")
    local v2c = real("`5'")

    local newer = 0
    if (`v2a' > `v1a') local newer = 1
    else if (`v2a' == `v1a') {
        if (`v2b' > `v1b') local newer = 1
        else if (`v2b' == `v1b') {
            if (`v2c' > `v1c') local newer = 1
        }
    }

    return scalar newer = `newer'
end
