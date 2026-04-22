*******************************************************************************
*! __wbod_sync_preview v1.4.0  21Apr2026
*! Display metadata status diagnostic before sync
*! v1.4.0: Add installed version, cache location, inline hyperlinks, clickable detail rows
*! v1.2.0: Added country metadata count display
*! v1.1.0: Added detail option for per-source/topic breakdown
*! Author: João Pedro Azevedo (World Bank | UNICEF)
*! Contact: https://jpazvd.github.io
*! License: MIT
*******************************************************************************

program define __wbod_sync_preview, rclass
    version 14.0
    syntax [, DETAIL]

    local show_detail = ("`detail'" != "")

    *---------------------------------------------------------------------------
    * 0. Installed package version (from wbopendata.ado header comment)
    *---------------------------------------------------------------------------
    * Read installed version — scan first 5 lines of wbopendata.ado for *! v X.Y.Z
    local pkg_ver = ""
    local _wbf "`c(sysdir_plus)'w/wbopendata.ado"
    local _wbf : subinstr local _wbf "\" "/" , all
    if fileexists("`_wbf'") {
        tempname _fh
        capture {
            file open `_fh' using "`_wbf'", read
            forvalues _ln = 1/5 {
                file read `_fh' _wbline
                if regexm("`_wbline'", "v ([0-9]+\.[0-9]+\.[0-9]+)") {
                    local pkg_ver = regexs(1)
                    continue, break
                }
            }
            file close `_fh'
        }
    }

    *---------------------------------------------------------------------------
    * 1. Resolve cache directory and paths
    *---------------------------------------------------------------------------
    local cache_dir "`c(sysdir_plus)'_/"
    local cache_dir : subinstr local cache_dir "\" "/" , all

    local vf "`cache_dir'metadata_version.txt"
    local tf "`cache_dir'cache_timestamp.txt"
    local mf "`cache_dir'cache_metadata.yaml"

    *---------------------------------------------------------------------------
    * 2. Read cache metadata
    *---------------------------------------------------------------------------
    local has_cache = 0
    local cache_ver = ""
    local cache_ts = ""
    local cache_method = ""

    if (fileexists("`vf'")) {
        local has_cache = 1
        tempname fh
        file open `fh' using "`vf'", read
        file read `fh' cache_ver
        file close `fh'
        local cache_ver = strtrim("`cache_ver'")
    }

    if (fileexists("`tf'")) {
        tempname fh
        file open `fh' using "`tf'", read
        file read `fh' cache_ts
        file close `fh'
        local cache_ts = strtrim("`cache_ts'")
    }

    * Parse method from cache_metadata.yaml if available
    if (fileexists("`mf'")) {
        tempname fh
        file open `fh' using "`mf'", read
        file read `fh' line
        while r(eof) == 0 {
            if (strpos("`line'", "method:") > 0) {
                local cache_method = strtrim(subinstr("`line'", "method:", "", 1))
                continue, break
            }
            file read `fh' line
        }
        file close `fh'
    }

    *---------------------------------------------------------------------------
    * 3. Count indicators/sources/topics from cached YAML metadata
    *---------------------------------------------------------------------------
    local ind_count = 0
    local src_count = 0
    local top_count = 0

    __wbod_get_yaml_path, type(indicators)
    local ind_yaml = r(path)
    if (fileexists("`ind_yaml'")) {
        * Count actual indicator entries by counting "    code: " lines
        * This matches the search parser which drops blank codes
        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            gen _trimmed = strtrim(rawline)
            keep if strpos(_trimmed, "code: ") == 1
            gen _val = strtrim(subinstr(_trimmed, "code:", "", 1))
            drop if _val == "" | _val == "''"
            local ind_count = _N
        }
        restore
    }

    __wbod_get_yaml_path, type(sources)
    local src_yaml = r(path)
    if (fileexists("`src_yaml'")) {
        * Read total_sources from _metadata section
        preserve
        quietly {
            infix str500 rawline 1-500 using "`src_yaml'", clear
            gen byte has_total = strpos(rawline, "total_sources:") > 0
            sum has_total, meanonly
            if (r(max) == 1) {
                keep if has_total
                keep in 1
                local line = rawline[1]
                local colon = strpos("`line'", ":")
                local val = strtrim(substr("`line'", `colon' + 1, .))
                local src_count = real("`val'")
                if missing(`src_count') local src_count = 0
            }
        }
        restore
    }

    __wbod_get_yaml_path, type(topics)
    local top_yaml = r(path)
    if (fileexists("`top_yaml'")) {
        * Read total_topics from _metadata section
        preserve
        quietly {
            infix str500 rawline 1-500 using "`top_yaml'", clear
            gen byte has_total = strpos(rawline, "total_topics:") > 0
            sum has_total, meanonly
            if (r(max) == 1) {
                keep if has_total
                keep in 1
                local line = rawline[1]
                local colon = strpos("`line'", ":")
                local val = strtrim(substr("`line'", `colon' + 1, .))
                local top_count = real("`val'")
                if missing(`top_count') local top_count = 0
            }
        }
        restore
    }

    *---------------------------------------------------------------------------
    * 3b. Get country metadata count from parameters YAML
    *---------------------------------------------------------------------------
    local ctry_count = 0
    __wbod_get_yaml_path, type(parameters)
    local param_yaml = r(path)
    if (fileexists("`param_yaml'")) {
        preserve
        quietly {
            infix str500 rawline 1-500 using "`param_yaml'", clear
            gen byte has_ctry = strpos(rawline, "ctrymetadata:") > 0
            sum has_ctry, meanonly
            if (r(max) == 1) {
                keep if has_ctry
                keep in 1
                local line = rawline[1]
                local colon = strpos("`line'", ":")
                local val = strtrim(substr("`line'", `colon' + 1, .))
                local ctry_count = real("`val'")
                if missing(`ctry_count') local ctry_count = 0
            }
        }
        restore
    }

    *---------------------------------------------------------------------------
    * 3c. Collect source and topic breakdown data (for stats history)
    *---------------------------------------------------------------------------
    local by_source = ""
    local by_topic = ""
    
    if (`has_cache' & fileexists("`ind_yaml'")) {
        * Collect source breakdown
        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            keep if strpos(rawline, "source_id:") > 0
            gen str10 source_id = strtrim(subinstr(rawline, "source_id:", "", 1))
            replace source_id = subinstr(source_id, "'", "", .)
            replace source_id = subinstr(source_id, `"""', "", .)
            gen byte one = 1
            collapse (sum) count = one, by(source_id)
            gsort -count
            local nrows = _N
            forvalues i = 1/`nrows' {
                local sid = source_id[`i']
                local cnt = count[`i']
                local by_source = "`by_source' `sid':`cnt'"
            }
        }
        restore
        local by_source = strtrim("`by_source'")
        
        * Collect topic breakdown
        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            gen byte is_topic_entry = (strpos(strtrim(rawline), "- '") == 1)
            keep if is_topic_entry
            gen str10 topic_id = ""
            replace topic_id = subinstr(strtrim(rawline), "- '", "", 1)
            replace topic_id = subinstr(topic_id, "'", "", .)
            gen byte is_num = real(topic_id) != .
            keep if is_num
            gen byte one = 1
            collapse (sum) count = one, by(topic_id)
            gsort -count
            local nrows = _N
            forvalues i = 1/`nrows' {
                local tid = topic_id[`i']
                local cnt = count[`i']
                local by_topic = "`by_topic' `tid':`cnt'"
            }
        }
        restore
        local by_topic = strtrim("`by_topic'")
    }

    *---------------------------------------------------------------------------
    * 4. Check Python availability
    *---------------------------------------------------------------------------
    local python_ok = 0
    local python_ver = ""
    capture shell python -V 2>&1
    if (_rc == 0) {
        local python_ok = 1
        * Try to capture version (best effort)
        tempfile pyver
        capture shell python -V > "`pyver'" 2>&1
        if (_rc == 0 & fileexists("`pyver'")) {
            tempname fh
            capture file open `fh' using "`pyver'", read
            if (_rc == 0) {
                file read `fh' python_ver
                file close `fh'
                local python_ver = strtrim("`python_ver'")
            }
        }
    }

    *---------------------------------------------------------------------------
    * 5. Check remote version (optional, may fail if offline)
    *---------------------------------------------------------------------------
    local remote_ver = ""
    local needs_update = 0
    local check_success = 0
    capture noisily __wbod_check_version
    if (_rc == 0) {
        local remote_ver = r(remote_version)
        local needs_update = r(needs_update)
        local check_success = r(check_success)
    }

    *---------------------------------------------------------------------------
    * 6. Quick API check for current indicator count
    *---------------------------------------------------------------------------
    local api_ind_count = .
    capture {
        __wbod_api_read, parameter(total)
        local api_ind_count = r(total1)
    }

    *---------------------------------------------------------------------------
    * 7. Display diagnostic
    *---------------------------------------------------------------------------
    * Compare installed vs GitHub release version (parse MAJOR.MINOR.PATCH)
    local ver_cmp = 0
    if ("`pkg_ver'" != "" & "`remote_ver'" != "") {
        local _iv1 = real(word(subinstr("`pkg_ver'",   ".", " ", .), 1))
        local _iv2 = real(word(subinstr("`pkg_ver'",   ".", " ", .), 2))
        local _iv3 = real(word(subinstr("`pkg_ver'",   ".", " ", .), 3))
        local _rv1 = real(word(subinstr("`remote_ver'",".", " ", .), 1))
        local _rv2 = real(word(subinstr("`remote_ver'",".", " ", .), 2))
        local _rv3 = real(word(subinstr("`remote_ver'",".", " ", .), 3))
        if      (`_iv1' > `_rv1') local ver_cmp =  1
        else if (`_iv1' < `_rv1') local ver_cmp = -1
        else if (`_iv2' > `_rv2') local ver_cmp =  1
        else if (`_iv2' < `_rv2') local ver_cmp = -1
        else if (`_iv3' > `_rv3') local ver_cmp =  1
        else if (`_iv3' < `_rv3') local ver_cmp = -1
    }

    di as text ""
    di as text "{hline 70}"
    di as result "wbopendata Metadata Status"
    di as text "{hline 70}"
    di ""

    if (`has_cache') {
        di as text "  Cache Status"
        di as text "  {hline 40}"
        di as text "  Version:          " as result "v`cache_ver'"
        di as text "  Last sync:        " as result "`cache_ts'"
        if ("`cache_method'" != "") {
            di as text "  Sync method:      " as result "`cache_method'"
        }
        di as text "  Location:         " as text "`cache_dir'"
        di ""
        di as text "  Cached Records"
        di as text "  {hline 40}"
        local ind_fmt : di %9.0fc `ind_count'
        local src_fmt : di %9.0fc `src_count'
        local top_fmt : di %9.0fc `top_count'
        local ctry_fmt : di %9.0fc `ctry_count'
        di as text "  Indicators:       " as result "`ind_fmt'" as text `"   {stata "wbopendata, sync detail":[breakdown]}"'
        di as text "  Sources:          " as result "`src_fmt'" as text `"   {stata "wbopendata, sources":[browse]}"'
        di as text "  Topics:           " as result "`top_fmt'" as text `"   {stata "wbopendata, alltopics":[browse]}"'
        di as text "  Country metadata: " as result "`ctry_fmt'"
    }
    else {
        di as text "  Cache Status:     " as error "Not found"
        di as text "  Location:         " as text "`cache_dir'"
    }

    * Show API comparison if available
    if (`api_ind_count' != .) {
        di ""
        di as text "  Remote Status (WB API)"
        di as text "  {hline 40}"
        local api_fmt : di %9.0fc `api_ind_count'
        di as text "  API indicators:   " as result "`api_fmt'"
        if (`has_cache' & `ind_count' > 0) {
            local diff = `api_ind_count' - `ind_count'
            if (`diff' > 0) {
                di as text "  Change:           " as result "+`diff' new" as text `"   {stata "wbopendata, sync replace":[sync & see breakdown]}"'
            }
            else if (`diff' < 0) {
                local diff_abs = abs(`diff')
                di as text "  Change:           " as result "`diff_abs' removed" as text `"   {stata "wbopendata, sync replace":[sync & see breakdown]}"'
            }
            else {
                di as text "  Change:           " as result "none (up to date)"
            }
        }
    }

    * Package version comparison (always shown if installed version known)
    if ("`pkg_ver'" != "" | `check_success') {
        di ""
        di as text "  Package Version"
        di as text "  {hline 40}"
        if ("`pkg_ver'" != "") {
            di as text "  Installed:        " as result "v`pkg_ver'" as text `"   {stata "help wbopendata_whatsnew":[what's new]}"'
        }
        if (`check_success') {
            di as text "  GitHub release:   " as result "v`remote_ver'"
            if ("`pkg_ver'" != "") {
                if (`ver_cmp' == 1) {
                    di as text "  Status:           " as result "Installed is ahead of release" as text " (dev/unreleased)"
                }
                else if (`ver_cmp' == -1) {
                    di as text "  Status:           " as result "Update available" as text `"   {stata "wbopendata, sync replace":[sync now]}"'
                }
                else {
                    di as text "  Status:           " as result "Up to date"
                }
            }
            else {
                if (`needs_update') {
                    di as text "  Status:           " as result "Update available" as text `"   {stata "wbopendata, sync replace":[sync now]}"'
                }
                else {
                    di as text "  Status:           " as result "Up to date"
                }
            }
        }
    }

    * Show sync pathway
    di ""
    di as text "  Sync Pathway"
    di as text "  {hline 40}"
    if (`python_ok') {
        if ("`python_ver'" != "") {
            di as text "  Python:           " as result "available (`python_ver')"
        }
        else {
            di as text "  Python:           " as result "available"
        }
        di as text "  Will use:         " as result "Python canonical"
    }
    else {
        di as text "  Python:           " as text "not detected"
        di as text "  Will use:         " as result "Stata fallback"
    }

    *---------------------------------------------------------------------------
    * 7b. Detail mode: show per-source and per-topic indicator counts
    *---------------------------------------------------------------------------
    if (`show_detail' & `has_cache' & fileexists("`ind_yaml'")) {
        
        *-----------------------------------------------------------------------
        * Sources breakdown
        *-----------------------------------------------------------------------
        di ""
        di as text "{hline 70}"
        di as result "  Indicators by Source"
        di as text "{hline 70}"
        
        * Count indicators per source
        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear

            * Extract source_id lines
            keep if strpos(rawline, "source_id:") > 0
            gen str20 source_id = strtrim(subinstr(rawline, "source_id:", "", 1))
            replace source_id = subinstr(source_id, "'", "", .)
            replace source_id = subinstr(source_id, `"""', "", .)

            * Collapse to get counts
            gen byte one = 1
            collapse (sum) count = one, by(source_id)

            * VG-format IDs (e.g., VGOA_02.) are vintage/archive sources
            * not present in the 71-entry sources YAML. Filter them out.
            gen byte is_std = !regexm(source_id, "^VG")
            sum count if !is_std, meanonly
            local n_other   = cond(r(N) > 0, r(N),   0)
            local cnt_other = cond(r(N) > 0, r(sum), 0)
            keep if is_std
            drop is_std
            gsort -count
        }

        * Display header
        di ""
        di as text "  {col 4}ID{col 10}Source Name{col 55}Indicators"
        di as text "  {hline 60}"

        * Display each standard source
        local nrows = _N
        forvalues i = 1/`nrows' {
            local sid = source_id[`i']
            local cnt = count[`i']

            * Format count with commas
            local cnt_fmt : di %8.0fc `cnt'

            * Get source name
            capture noisily __wbod_get_source_name `sid'
            local sname = r(source_name)
            if ("`sname'" == "") local sname "Source `sid'"
            local sname = substr("`sname'", 1, 40)

            local src_cmd `"wbopendata, search() searchsource(`sid')"'
            di as result `"  {col 4}`sid'{col 10}"' `"{stata "`src_cmd'":`sname'}"' as text `"  {col 55}`cnt_fmt'"'
        }

        * Roll up VG-format vintage sources into a single summary line
        if (`n_other' > 0) {
            local cnt_other_fmt : di %8.0fc `cnt_other'
            di as text `"  {col 4}(VG*){col 10}Vintage/archive sources (`n_other' IDs){col 55}`cnt_other_fmt'"'
        }

        di as text "  {hline 60}"
        restore

        *-----------------------------------------------------------------------
        * Topics breakdown
        *-----------------------------------------------------------------------
        di ""
        di as text "{hline 70}"
        di as result "  Indicators by Topic"
        di as text "{hline 70}"
        
        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            
            * Match lines with topic_ids entries: "    - '11'" patterns
            * Use strpos for simpler matching - look for lines with - ' pattern
            gen byte is_topic_entry = (strpos(strtrim(rawline), "- '") == 1)
            keep if is_topic_entry
            
            * Extract the topic ID number from pattern - 'XX'
            gen str10 topic_id = ""
            replace topic_id = subinstr(strtrim(rawline), "- '", "", 1)
            replace topic_id = subinstr(topic_id, "'", "", .)
            
            * Only keep valid numeric topic IDs
            gen byte is_num = real(topic_id) != .
            keep if is_num
            
            gen byte one = 1
            collapse (sum) count = one, by(topic_id)
            gsort -count
        }
        
        * Display header
        di ""
        di as text "  {col 4}ID{col 10}Topic Name{col 55}Indicators"
        di as text "  {hline 60}"
        
        local nrows = _N
        if (`nrows' == 0) {
            di as text "  {col 4}(No topic entries found)"
        }
        else {
            forvalues i = 1/`nrows' {
                local tid = topic_id[`i']
                local cnt = count[`i']
                
                * Format count with commas
                local cnt_fmt : di %8.0fc `cnt'
                
                * Get topic name
                capture noisily __wbod_get_topic_name `tid'
                local tname = r(topic_name)
                if ("`tname'" == "") {
                    local tname "Topic `tid'"
                }
                * Truncate name to fit
                local tname = substr("`tname'", 1, 40)

                local top_cmd `"wbopendata, search() searchtopic(`tid')"'
                di as result `"  {col 4}`tid'{col 10}"' `"{stata "`top_cmd'":`tname'}"' as text `"  {col 55}`cnt_fmt'"'
            }
        }
        
        di as text "  {hline 60}"
        restore
    }

    di ""
    di as text "{hline 70}"
    di ""
    di as text "Actions:"
    di ""
    di `"  {stata "wbopendata, sync replace":  Sync metadata now}"'
    di `"  {stata "wbopendata, sync detail":  View breakdown by source/topic}"'
    di `"  {stata "wbopendata, sync replace force":  Force sync (even if fresh)}"'
    di `"  {stata "wbopendata, sync replace forcestata":  Force Stata pathway}"'
    if (`python_ok') {
        di `"  {stata "wbopendata, sync replace forcepython":  Force Python pathway}"'
    }
    di ""
    di `"  {stata "wbopendata, sources":  View sources}"'
    di `"  {stata "wbopendata, alltopics":  View topics}"'
    di `"  {stata "wbopendata, search(poverty)":  Search indicators by keyword}"'
    di `"  {stata "help wbopendata":  Full documentation}"'
    di ""
    di as text "{hline 70}"

    *---------------------------------------------------------------------------
    * 8. Return values
    *---------------------------------------------------------------------------
    return scalar has_cache = `has_cache'
    return scalar ind_count = `ind_count'
    return scalar src_count = `src_count'
    return scalar top_count = `top_count'
    return scalar ctry_count = `ctry_count'
    return scalar python_available = `python_ok'
    return scalar needs_update = `needs_update'
    if (`api_ind_count' != .) return scalar api_ind_count = `api_ind_count'
    if ("`cache_ver'" != "") return local cache_version = "`cache_ver'"
    if ("`cache_ts'" != "") return local cache_timestamp = "`cache_ts'"
    if ("`cache_method'" != "") return local cache_method = "`cache_method'"
    if ("`remote_ver'" != "") return local remote_version = "`remote_ver'"
    if ("`by_source'" != "") return local by_source = "`by_source'"
    if ("`by_topic'" != "") return local by_topic = "`by_topic'"
end

* Note: Helper programs __wbod_get_source_name and __wbod_get_topic_name
* are now in separate .ado files for standalone accessibility


