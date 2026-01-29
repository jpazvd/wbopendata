*******************************************************************************
*! _wbopendata_check_version v1.0.0  20Jan2026
*! Check remote metadata release tag vs local cache
*******************************************************************************

program define _wbopendata_check_version, rclass
    version 14.0

    local cache_dir = c(sysdir_personal) + "wbopendata/cache/"
    local vf = "`cache_dir'metadata_version.txt"

    if (file_exists("`vf'")) {
        tempname fh
        file open `fh' using "`vf'", read
        file read `fh' local_ver
        file close `fh'
        local local_ver = trim("`local_ver'")
    }
    else local local_ver "0.0.0"

    local api_url "https://api.github.com/repos/jpazvd/wbopendata/releases/latest"
    local tmpjson = "`c(tmpdir)'wbod_version.json"
    local remote_ver ""
    local check_success = 0

    capture copy "`api_url'" "`tmpjson'", replace
    if (_rc == 0) {
        _wbopendata_parse_github_json "`tmpjson'"
        local remote_ver = r(tag_version)
        local check_success = 1
        capture erase "`tmpjson'"
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

    return local local_version = "`local_ver'"
    return local remote_version = "`remote_ver'"
    return scalar needs_update = `needs_update'
    return scalar check_success = `check_success'
end


program define _wbopendata_parse_github_json, rclass
    version 14.0
    args json_file

    tempname fh
    file open `fh' using "`json_file'", read
    local tag_version ""
    file read `fh' line
    while (r(eof) == 0) {
        if (strpos(`"`line'"', `""tag_name""') > 0) {
            local start = strpos(`"`line'"', `""metadata-v""') + 12
            local rest = substr(`"`line'"', `start', .)
            local end = strpos(`"`rest'"', `""""')
            if (`end' > 1) local tag_version = substr(`"`rest'"', 1, `end' - 1)
            continue, break
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
