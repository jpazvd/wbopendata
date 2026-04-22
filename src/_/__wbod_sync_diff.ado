*******************************************************************************
*! __wbod_sync_diff v1.2.0  22Apr2026
*! Snapshot indicator codes before sync; compare and display diff after sync.
*! Called by wbopendata.ado around the __wbod_sync call.
*!
*! Usage:
*!   __wbod_sync_diff, before("path/to/snapshot.dta")
*!       Reads current indicator YAML, saves code+source list to the given path.
*!
*!   __wbod_sync_diff, after("path/to/snapshot.dta") [limit(N)]
*!       Reads new indicator YAML, merges with snapshot, displays source table.
*!       Silently exits if snapshot does not exist or no changes found.
*******************************************************************************

program define __wbod_sync_diff
    version 14.0
    syntax, [BEFORE(string) AFTER(string) LIMIT(integer 10)]

    *---------------------------------------------------------------------------
    * BEFORE: snapshot current indicator codes + source names → .dta file
    *---------------------------------------------------------------------------
    if ("`before'" != "") {
        __wbod_get_yaml_path, type(indicators)
        local ind_yaml = r(path)
        if (!fileexists("`ind_yaml'")) exit 0

        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            * str244 prevents the truncation that str32 caused on long code lines
            gen str244 _trimmed = strtrim(rawline)
            gen byte is_code = (strpos(_trimmed, "code: ") == 1)
            gen byte is_src  = (strpos(_trimmed, "source_name: ") == 1)
            keep if is_code | is_src

            gen str244 code = ""
            replace code = strtrim(subinstr(_trimmed, "code:", "", 1)) if is_code
            replace code = subinstr(code, "'", "", .)
            replace code = subinstr(code, `"""', "", .)

            gen str200 src_pre = ""
            replace src_pre = strtrim(subinstr(_trimmed, "source_name:", "", 1)) if is_src
            replace src_pre = subinstr(src_pre, "'", "", .) if is_src
            replace src_pre = subinstr(src_pre, `"""', "", .) if is_src

            * Pair each source_name with the preceding code line
            * (source_name always follows code within each indicator block)
            gen long ind_grp = sum(is_code)
            bysort ind_grp: replace src_pre = src_pre[_N]
            keep if is_code
            drop if code == ""
            keep code src_pre
            duplicates drop code, force
            save "`before'", replace
        }
        restore
        exit 0
    }

    *---------------------------------------------------------------------------
    * AFTER: compare new YAML vs snapshot, display source-level breakdown
    *---------------------------------------------------------------------------
    if ("`after'" != "") {
        if (!fileexists("`after'")) exit 0

        __wbod_get_yaml_path, type(indicators)
        local ind_yaml = r(path)
        if (!fileexists("`ind_yaml'")) exit 0

        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            gen str244 _trimmed = strtrim(rawline)
            gen byte is_code = (strpos(_trimmed, "code: ") == 1)
            gen byte is_src  = (strpos(_trimmed, "source_name: ") == 1)
            keep if is_code | is_src

            gen str244 code = ""
            replace code = strtrim(subinstr(_trimmed, "code:", "", 1)) if is_code
            replace code = subinstr(code, "'", "", .)
            replace code = subinstr(code, `"""', "", .)

            gen str200 source_name = ""
            replace source_name = strtrim(subinstr(_trimmed, "source_name:", "", 1)) if is_src
            replace source_name = subinstr(source_name, "'", "", .) if is_src
            replace source_name = subinstr(source_name, `"""', "", .) if is_src

            gen long ind_grp = sum(is_code)
            bysort ind_grp: replace source_name = source_name[_N]
            keep if is_code
            drop if code == ""
            keep code source_name
            duplicates drop code, force

            * Merge with before-snapshot
            * _merge==1: in new YAML only → ADDED
            * _merge==2: in snapshot only → REMOVED
            * _merge==3: in both          → unchanged
            merge 1:1 code using "`after'"
            * After merge: source_name (from new YAML, available for _merge 1,3)
            *              src_pre     (from snapshot,  available for _merge 2,3)
        }

        quietly count if _merge == 1
        local n_added = r(N)
        quietly count if _merge == 2
        local n_removed = r(N)
        local net = `n_added' - `n_removed'

        if (`n_added' == 0 & `n_removed' == 0) {
            di as text "  Indicator list:    " as result "unchanged"
            restore
            exit 0
        }

        * Build source-level summary (collapse inside preserve)
        quietly {
            gen str200 src_disp = source_name
            replace src_disp = src_pre if _merge == 2 & (src_disp == "" | src_disp == ".")
            replace src_disp = "(Unknown source)" if src_disp == "" | src_disp == "."
            gen byte is_add = (_merge == 1)
            gen byte is_rem = (_merge == 2)
            collapse (sum) n_add=is_add n_rem=is_rem, by(src_disp)
            gen long net_s = n_add - n_rem
            gen long abs_s = abs(net_s)
            gsort -abs_s -n_add
        }

        * Collect into locals before restore
        quietly count
        local n_src = r(N)
        local show = min(`n_src', `limit')
        forvalues i = 1/`show' {
            local sn_`i'  = src_disp[`i']
            local na_`i'  = n_add[`i']
            local nr_`i'  = n_rem[`i']
            local nn_`i'  = net_s[`i']
        }
        restore

        * Display source breakdown table
        di as text ""
        di as text "  Changes since last sync"
        di as text "  {hline 58}"
        di as text "  " %-38s "Source" "  {col 43}Added" "{col 51}Removed" "{col 59}Net"
        di as text "  {hline 58}"

        forvalues i = 1/`show' {
            local sname = "`sn_`i''"
            if (length("`sname'") > 38) local sname = substr("`sname'", 1, 38)
            local nn = `nn_`i''
            local nsign = cond(`nn' >= 0, "+", "")
            di as text "  " %-38s "`sname'" as result ///
                _col(43) %5.0fc `na_`i'' ///
                _col(51) %5.0fc `nr_`i'' ///
                _col(57) "`nsign'`nn'"
        }
        if (`n_src' > `limit') {
            local _more = `n_src' - `limit'
            di as text "  ({res}`_more'{txt} more sources)"
        }
        di as text "  {hline 58}"
        local nsign = cond(`net' >= 0, "+", "")
        di as text "  " %-38s "TOTAL" as result ///
            _col(43) %5.0fc `n_added' ///
            _col(51) %5.0fc `n_removed' ///
            _col(57) "`nsign'`net'"

        exit 0
    }
end
