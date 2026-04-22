*******************************************************************************
*! __wbod_sync_diff v1.0.1  22Apr2026
*! Snapshot indicator codes before sync; compare and display diff after sync.
*! Called by wbopendata.ado around the __wbod_sync call.
*!
*! Usage:
*!   __wbod_sync_diff, before("path/to/snapshot.dta")
*!       Reads current indicator YAML, saves code list to the given path.
*!
*!   __wbod_sync_diff, after("path/to/snapshot.dta") [limit(N)]
*!       Reads new indicator YAML, merges with snapshot, displays diff.
*!       Silently exits if snapshot does not exist or no changes found.
*******************************************************************************

program define __wbod_sync_diff
    version 14.0
    syntax, [BEFORE(string) AFTER(string) LIMIT(integer 20)]

    *---------------------------------------------------------------------------
    * BEFORE: snapshot current indicator codes → Stata .dta file
    *---------------------------------------------------------------------------
    if ("`before'" != "") {
        __wbod_get_yaml_path, type(indicators)
        local ind_yaml = r(path)
        if (!fileexists("`ind_yaml'")) exit 0

        preserve
        quietly {
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            gen str32 _trimmed = strtrim(rawline)
            keep if strpos(_trimmed, "code: ") == 1
            gen str32 code = strtrim(subinstr(_trimmed, "code:", "", 1))
            replace code = subinstr(code, "'", "", .)
            replace code = subinstr(code, `"""', "", .)
            drop if code == ""
            keep code
            duplicates drop code, force
            save "`before'", replace
        }
        restore
        exit 0
    }

    *---------------------------------------------------------------------------
    * AFTER: compare new YAML vs snapshot, display what changed
    *---------------------------------------------------------------------------
    if ("`after'" != "") {
        if (!fileexists("`after'")) exit 0

        __wbod_get_yaml_path, type(indicators)
        local ind_yaml = r(path)
        if (!fileexists("`ind_yaml'")) exit 0

        preserve
        quietly {
            * Read new indicator codes
            infix str500 rawline 1-500 using "`ind_yaml'", clear
            gen str32 _trimmed = strtrim(rawline)
            keep if strpos(_trimmed, "code: ") == 1
            gen str32 code = strtrim(subinstr(_trimmed, "code:", "", 1))
            replace code = subinstr(code, "'", "", .)
            replace code = subinstr(code, `"""', "", .)
            drop if code == ""
            keep code
            duplicates drop code, force

            * Merge with before-snapshot
            * _merge==1 : in new YAML only → ADDED
            * _merge==2 : in snapshot only → REMOVED
            * _merge==3 : in both → unchanged
            merge 1:1 code using "`after'"
        }

        quietly count if _merge == 1
        local n_added = r(N)
        quietly count if _merge == 2
        local n_removed = r(N)

        if (`n_added' == 0 & `n_removed' == 0) {
            di as text "  Indicator list:    " as result "unchanged"
            restore
            exit 0
        }

        * Collect codes for display
        local added_codes   ""
        local removed_codes ""
        if (`n_added'   > 0) quietly levelsof code if _merge == 1, local(added_codes)   clean
        if (`n_removed' > 0) quietly levelsof code if _merge == 2, local(removed_codes) clean

        restore

        * Display diff section
        di as text ""
        di as text "  Changes since last sync"
        di as text "  {hline 40}"

        if (`n_added' > 0) {
            di as text "  Added:          " as result %6.0fc `n_added' as text " indicators"
            local i = 0
            foreach c of local added_codes {
                local i = `i' + 1
                if (`i' > `limit') continue, break
                di as text "    + `c'"
            }
            if (`n_added' > `limit') {
                local _more = `n_added' - `limit'
                di as text "    ... and `_more' more"
            }
        }
        else {
            di as text "  Added:          " as result "none"
        }

        if (`n_removed' > 0) {
            di as text "  Removed:        " as result %6.0fc `n_removed' as text " indicators"
            local i = 0
            foreach c of local removed_codes {
                local i = `i' + 1
                if (`i' > `limit') continue, break
                di as text "    - `c'"
            }
            if (`n_removed' > `limit') {
                local _more = `n_removed' - `limit'
                di as text "    ... and `_more' more"
            }
        }
        else {
            di as text "  Removed:        " as result "none"
        }

        exit 0
    }
end
