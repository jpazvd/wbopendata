*******************************************************************************
*! _wbopendata_sync v1.0.0  07Feb2026
*! Orchestrate metadata sync (download, Python canonical, Stata fallback)
*******************************************************************************

program define _wbopendata_sync, rclass
    version 14.0
    syntax [, FORCE FORCEPYTHON FORCESTATA GITHUBRELEASE(string) PYTHONCMD(string) OUTDIR(string)]

    local cache_base "`c(sysdir_personal)'wbopendata/"
    * Convert backslashes to forward slashes to avoid escape issues (\a, \t, etc.)
    local cache_base : subinstr local cache_base "\" "/" , all
    local cache_dir "`cache_base'cache/"
    
    capture mkdir "`cache_base'"
    capture mkdir "`cache_dir'"

    tempname fh
    local test_file "`cache_dir'_test.tmp"
    capture file open `fh' using "`test_file'", write replace
    if (_rc != 0) {
        di as error "Cannot write to cache directory: `cache_dir'"
        error 603
    }
    file close `fh'
    capture erase "`test_file'"

    local outdir_use "`outdir'"
    if ("`outdir_use'" == "") local outdir_use "`cache_dir'"
    if (substr("`outdir_use'", -1, 1) != "/" & substr("`outdir_use'", -1, 1) != "\\") {
        local outdir_use "`outdir_use'/"
    }

    local schema_version "2.0.0"

    * Check cache staleness (skip if force)
    if ("`force'" == "") {
        _wbopendata_check_staleness "`cache_dir'"
    }

    if ("`forcestata'" != "") {
        capture noisily _wbopendata_refresh_yaml, outdir("`outdir_use'") replace
        if (_rc != 0) {
            di as error "Stata fallback failed (rc = " _rc ")"
            exit _rc
        }
        _wbopendata_write_cache_meta "`schema_version'" "`cache_dir'" "stata" "stata"
        return scalar sync_success = 1
        return local method = "stata"
        exit 0
    }

    if ("`forcepython'" != "") {
        _wbopendata_run_python, outdir("`outdir_use'") pythoncmd("`pythoncmd'")
        if (_rc != 0) {
            di as error "Python pipeline failed (rc = " _rc ")"
            exit _rc
        }
        _wbopendata_write_cache_meta "`schema_version'" "`cache_dir'" "python" "python"
        return scalar sync_success = 1
        return local method = "python"
        exit 0
    }

    * Pathway B: Python canonical
    capture noisily _wbopendata_check_python, pythoncmd("`pythoncmd'")
    if (_rc == 0) {
        capture noisily _wbopendata_run_python, outdir("`outdir_use'") pythoncmd("`pythoncmd'")
        if (_rc == 0) {
            _wbopendata_write_cache_meta "`schema_version'" "`cache_dir'" "python" "python"
            return scalar sync_success = 1
            return local method = "python"
            exit 0
        }
    }

    * Pathway A: Stata fallback
    capture noisily _wbopendata_refresh_yaml, outdir("`outdir_use'") replace
    if (_rc == 0) {
        _wbopendata_write_cache_meta "`schema_version'" "`cache_dir'" "stata" "stata"
        return scalar sync_success = 1
        return local method = "stata"
        exit 0
    }

    * Pathway C: download YAML from GitHub (last resort)
    local download_ok = 0
    capture noisily _wbopendata_check_version
    local remote_ver ""
    if (_rc == 0) local remote_ver = r(remote_version)

    capture noisily _wbopendata_download_yaml, version("`remote_ver'")
    if (_rc == 0) local download_ok = 1

    if (`download_ok' == 1) {
        _wbopendata_write_cache_meta "`schema_version'" "`cache_dir'" "download" "github"
        return scalar sync_success = 1
        return local method = "download"
        exit 0
    }

    di as error "All sync pathways failed."
    exit 603
end


program define _wbopendata_run_python
    version 14.0
    syntax , OUTDIR(string) [PYTHONCMD(string)]

    local python_cmd "`pythoncmd'"
    if ("`python_cmd'" == "") local python_cmd "python"

    local script ""

    local candidate1 "`c(pwd)'/src/py/update_metadata.py"
    if (fileexists("`candidate1'")) local script "`candidate1'"

    if ("`script'" == "") {
        local candidate2 "`c(pwd)'/wbopendata-dev/src/py/update_metadata.py"
        if (fileexists("`candidate2'")) local script "`candidate2'"
    }

    if ("`script'" == "") {
        capture findfile wbopendata.ado
        if (_rc == 0) {
            local fn `r(fn)'
            local root : subinstr local fn "/src/w/wbopendata.ado" ""
            local root : subinstr local root "\src\w\wbopendata.ado" ""
            local candidate3 "`root'/src/py/update_metadata.py"
            if (fileexists("`candidate3'")) local script "`candidate3'"
        }
    }

    * Check installed package directory (ado/plus/py/)
    if ("`script'" == "") {
        local candidate4 "`c(sysdir_plus)'py/update_metadata.py"
        if (fileexists("`candidate4'")) local script "`candidate4'"
    }

    if ("`script'" == "") {
        di as error "Python pipeline not found (update_metadata.py missing)."
        exit 601
    }

    local cmd "`python_cmd' \"`script'\" --output-dir \"`outdir'\""
    di as text "Running Python pipeline..."
    shell `cmd'
    if (_rc != 0) exit _rc
end


program define _wbopendata_check_python
    version 14.0
    syntax , [PYTHONCMD(string)]

    local python_cmd "`pythoncmd'"
    if ("`python_cmd'" == "") local python_cmd "python"

    shell "`python_cmd'" -V
    if (_rc != 0) {
        exit _rc
    }
end


program define _wbopendata_check_staleness
    version 14.0
    args cache_dir

    local tf "`cache_dir'cache_timestamp.txt"
    if (!fileexists("`tf'")) exit 0

    tempname fh
    file open `fh' using "`tf'", read
    file read `fh' line
    file close `fh'

    local w1 : word 1 of `line'
    local w2 : word 2 of `line'
    local w3 : word 3 of `line'
    local ts_date "`w1' `w2' `w3'"
    local last_date = date("`ts_date'", "DMY")
    local today = date("`c(current_date)'", "DMY")

    if (!missing(`last_date') & !missing(`today')) {
        local days_since = `today' - `last_date'
        if (`days_since' > 30) {
            di as text ""
            di as err "Warning: metadata cache is `days_since' days old (last sync: `ts_date')."
            di as text "Run: wbopendata, sync"
        }
    }
end


program define _wbopendata_write_cache_meta
    version 14.0
    * Use args instead of syntax to avoid path parsing issues with colons
    args version cache_dir method source

    tempname vfh tfh
    file open `vfh' using "`cache_dir'metadata_version.txt", write replace
    file write `vfh' "`version'"
    file close `vfh'

    file open `tfh' using "`cache_dir'cache_timestamp.txt", write replace
    file write `tfh' "`c(current_date)' `c(current_time)'"
    file close `tfh'

    local method_val "`method'"
    if ("`method_val'" == "") local method_val "unknown"
    local source_val "`source'"
    if ("`source_val'" == "") local source_val "unknown"

    tempname mfh
    file open `mfh' using "`cache_dir'cache_metadata.yaml", write replace
    file write `mfh' "_metadata:" _n
    file write `mfh' "  platform: stata" _n
    file write `mfh' "  version: `version'" _n
    file write `mfh' "  synced_at: `c(current_date)' `c(current_time)'" _n
    file write `mfh' "  method: `method_val'" _n
    file write `mfh' "  source: `source_val'" _n
    file close `mfh'

    _wbopendata_update_sync_history "`cache_dir'" "`version'" "`method_val'" "`source_val'"
end


program define _wbopendata_update_sync_history
    version 14.0
    * Use args instead of syntax to avoid path parsing issues with colons
    args cache_dir version method source

    local hf "`cache_dir'cache_sync_history.yaml"
    local ts "`c(current_date)' `c(current_time)'"

    tempname fh
    if (!fileexists("`hf'")) {
        file open `fh' using "`hf'", write replace
        file write `fh' "_sync_history:" _n
    }
    else {
        file open `fh' using "`hf'", write append
    }

    file write `fh' "- synced_at: `ts'" _n
    file write `fh' "  version: `version'" _n
    file write `fh' "  method: `method'" _n
    file write `fh' "  source: `source'" _n
    file close `fh'
end
