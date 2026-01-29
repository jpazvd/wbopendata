*******************************************************************************
*! _wbopendata_info v1.0.0  20Jan2026
*! Return indicator metadata from cached YAML (Pathway C)
*******************************************************************************

program define _wbopendata_info, rclass
    version 14.0
    syntax , INDICATOR(string)

    local code_raw = trim("`indicator'")
    if ("`code_raw'" == "") {
        di as err "indicator() required"
        exit 198
    }

    local code_u = subinstr("`code_raw'", ".", "_", .)

    _wbopendata_get_yaml_path, type(indicators)
    local yaml_path = r(path)

    * Try yaml.ado path; fall back to direct parse if it fails or not found
    capture noisily {
        preserve
        quietly {
            yaml read using "`yaml_path'", replace
            keep if strpos(key, "indicators_") == 1

            gen rest = substr(key, 12, .)
            gen rev = reverse(rest)
            gen pos = strpos(rev, "_")
            gen field = reverse(substr(rev, 1, pos - 1))
            gen code = substr(rest, 1, strlen(rest) - pos)
            drop if missing(field)

            keep if code == "`code_u'"
            if (_N == 0) {
                restore
                error 111
            }

            reshape wide value, i(code) j(field) string
        }

        local name = ""
        capture local name = valuename[1]
        local desc = ""
        capture local desc = valuedescription[1]
        local note = ""
        capture local note = valuenote[1]
        local source = ""
        capture local source = valuesource_name[1]
        local topicnames = ""
        capture local topicnames = valuetopic_names[1]

        * Graceful fallbacks
        if ("`name'" == "")       local name "N/A"
        if ("`source'" == "")     local source "N/A"
        if ("`topicnames'" == "") local topicnames "N/A"
        if ("`desc'" == "")       local desc "N/A"
        if ("`note'" == "")       local note "N/A"

        di as text "Indicator: " as result "`code_raw'"
        di as text "Name: " as result "`name'"
        di as text "Source: " as result "`source'"
        di as text "Topics: " as result "`topicnames'"
        di as text "Description:" 
        di as result "`desc'"
        di as text "Note:" 
        di as result "`note'"

        return local indicator = "`code_raw'"
        return local name = "`name'"
        return local source = "`source'"
        return local topics = "`topicnames'"
        return local description = "`desc'"
        return local note = "`note'"
        return local yaml_path = "`yaml_path'"
        return scalar used_fallback = 0

        restore
        exit 0
    }

    * Fallback: direct parse
    tempname fh
    file open `fh' using "`yaml_path'", read text

    local in_ind = 0
    local found = 0
    local name ""
    local desc ""
    local note ""
    local source ""
    local topicnames ""

    file read `fh' line
    while r(eof) == 0 {
        local orig `"`macval(line)'"'
        local trimmed = strtrim(`"`orig'"')

        if ("`trimmed'" == "indicators:") {
            local in_ind = 1
            file read `fh' line
            continue
        }

        if (`in_ind') {
            if (substr(`"`orig'"',1,2) == "  " & substr(`"`orig'"',3,1) != " " & strpos(`"`orig'"', ":") > 0) {
                local code_here = subinstr(strtrim(subinstr(`"`orig'"',":", "", 1)), " ", "", .)
                if (upper("`code_here'") == upper("`code_u'")) {
                    * read fields until next indicator or EOF
                    file read `fh' line
                    while (r(eof) == 0) {
                        local orig2 `"`macval(line)'"'
                        local t = strtrim(`"`orig2'"')
                        if (substr(`"`orig2'"',1,2) == "  " & substr(`"`orig2'"',3,1) != " " & strpos(`"`orig2'"', ":") > 0) {
                            continue, break
                        }
                        if (regexm("`t'", "^name:[ ]*(.+)$"))         local name = regexs(1)
                        else if (regexm("`t'", "^description:[ ]*(.+)$")) local desc = regexs(1)
                        else if (regexm("`t'", "^note:[ ]*(.+)$"))       local note = regexs(1)
                        else if (regexm("`t'", "^topic_names:[ ]*(.+)$")) local topicnames = regexs(1)
                        else if (regexm("`t'", "^source_org:[ ]*(.+)$"))  local source = regexs(1)
                        file read `fh' line
                    }
                    local found = 1
                    continue, break
                }
            }
        }

        file read `fh' line
    }

    file close `fh'

    if (!`found') {
        di as err "Indicator not found in YAML: `code_raw' (fallback parse)"
        exit 111
    }

    if ("`name'" == "")       local name "N/A"
    if ("`source'" == "")     local source "N/A"
    if ("`topicnames'" == "") local topicnames "N/A"
    if ("`desc'" == "")       local desc "N/A"
    if ("`note'" == "")       local note "N/A"

    di as text "Indicator: " as result "`code_raw'"
    di as text "Name: " as result "`name'"
    di as text "Source: " as result "`source'"
    di as text "Topics: " as result "`topicnames'"
    di as text "Description:" 
    di as result "`desc'"
    di as text "Note:" 
    di as result "`note'"

    return local indicator = "`code_raw'"
    return local name = "`name'"
    return local source = "`source'"
    return local topics = "`topicnames'"
    return local description = "`desc'"
    return local note = "`note'"
    return local yaml_path = "`yaml_path'"
    return scalar used_fallback = 1
end
