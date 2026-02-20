*******************************************************************************
*! _yaml_collapse
*! v 1.7.0   20Feb2026               by Joao Pedro Azevedo (UNICEF)
*! Post-process: pivot long YAML output to wide format (one row per entity)
*! Expects standard canonical schema in memory: key value level parent type
*! Uses Mata for performance on large datasets (avoids reshape wide)
*!
*! Architecture (wbopendata-style, in Mata):
*!   1. Read long-format data from Stata (key, value, level, type)
*!   2. Forward-fill entity from level-2 parent keys
*!   3. Extract ind_code (strip root prefix) and field name (strip entity prefix)
*!   4. Strip numeric suffix from list item fields (topic_ids_1 -> topic_ids)
*!   5. Build wide matrix with semicolon concatenation for list items
*!   6. Write wide-format dataset (one row per entity, one column per field)
*******************************************************************************

* Define the Mata functions (compiled once, persists in memory)
mata:
mata set matastrict off

/* Binary search in sorted string vector — returns index or 0 */
real scalar _yaml_binsearch(string colvector sorted, string scalar target)
{
    real scalar lo, hi, mid

    lo = 1
    hi = rows(sorted)
    while (lo <= hi) {
        mid = trunc((lo + hi) / 2)
        if (sorted[mid] == target) return(mid)
        if (sorted[mid] < target) lo = mid + 1
        else hi = mid - 1
    }
    return(0)
}

string scalar _yaml_safe_varname(string scalar raw)
{
    string scalar name, result, ch
    real scalar i, len

    name = strlower(raw)
    len = strlen(name)
    result = ""
    for (i = 1; i <= len; i++) {
        ch = substr(name, i, 1)
        if (regexm(ch, "[a-z0-9_]")) {
            result = result + ch
        }
        else {
            result = result + "_"
        }
    }
    if (result == "") result = "v"
    if (regexm(substr(result, 1, 1), "[0-9]")) result = "v" + result
    if (strlen(result) > 32) result = substr(result, 1, 32)
    return(result)
}

string scalar _yaml_unique_varname(string scalar base, string colvector used)
{
    real scalar i
    string scalar name, suffix

    name = base
    if (rows(used) == 0) return(name)
    if (sum(used :== name) == 0) return(name)

    /* Safety limit to prevent infinite loop */
    for (i = 1; i <= 99999; i++) {
        suffix = "_" + strofreal(i)
        if (strlen(base) + strlen(suffix) > 32) {
            name = substr(base, 1, 32 - strlen(suffix)) + suffix
        }
        else {
            name = base + suffix
        }
        if (sum(used :== name) == 0) return(name)
    }
    /* Fallback if somehow all 99999 suffixes are taken */
    return(base + "_x")
}

void _yaml_mata_collapse(string scalar mapfile)
{
    real scalar    n, i, j, m, capacity, root_len, ent_len
    real scalar    ne, nf, ei, fi, vi, last_us, k, all_digits
    string scalar  cur_entity, cur_root, root, ic, f, suffix
    string colvector keys, values, types, entity, roots
    real colvector   levels
    string colvector r_ic, r_fld, r_val, u_ent, u_fld, safe_fld
    string matrix    wide
    real scalar fh

    /* ---- Read long-format data from Stata ---- */
    n      = st_nobs()
    keys   = st_sdata(., st_varindex("key"))
    values = st_sdata(., st_varindex("value"))
    levels = st_data(., st_varindex("level"))
    types  = st_sdata(., st_varindex("type"))

    /* ---- Forward-fill entity AND root from parent keys ---- */
    /* Each entity has its own level-1 root (e.g., _metadata vs indicators) */
    entity = J(n, 1, "")
    roots  = J(n, 1, "")
    cur_entity = ""
    cur_root   = ""
    for (i = 1; i <= n; i++) {
        if (types[i] == "parent" & levels[i] == 1) {
            cur_root = keys[i]
        }
        if (types[i] == "parent" & levels[i] == 2) {
            cur_entity = keys[i]
        }
        entity[i] = cur_entity
        roots[i]  = cur_root
    }

    /* ---- Single pass: extract (ind_code, field, value) triples ---- */
    capacity = 50000
    r_ic  = J(capacity, 1, "")
    r_fld = J(capacity, 1, "")
    r_val = J(capacity, 1, "")
    m = 0

    for (i = 1; i <= n; i++) {
        /* Skip parent rows and rows without entity */
        if (types[i] == "parent") continue
        if (entity[i] == "" | entity[i] == ".") continue

        /* Skip _metadata section (not indicator data) */
        if (roots[i] == "_metadata") continue

        /* Extract ind_code (strip entity's own root prefix + separator) */
        root = roots[i]
        root_len = strlen(root)
        if (root != "") {
            ic = substr(entity[i], root_len + 2, .)
        }
        else {
            ic = entity[i]
        }
        if (ic == "" | ic == ".") continue

        /* Extract field name (strip entity prefix + separator) */
        ent_len = strlen(entity[i])
        f = substr(keys[i], ent_len + 2, .)

        /* For list items, strip numeric suffix (topic_ids_1 -> topic_ids) */
        if (types[i] == "list_item") {
            last_us = 0
            for (k = strlen(f); k >= 1; k--) {
                if (substr(f, k, 1) == "_") {
                    last_us = k
                    break
                }
            }
            if (last_us > 0) {
                suffix = substr(f, last_us + 1, .)
                if (strlen(suffix) > 0) {
                    all_digits = 1
                    for (k = 1; k <= strlen(suffix); k++) {
                        if (strtoreal(substr(suffix, k, 1)) >= .) {
                            all_digits = 0
                            break
                        }
                    }
                    if (all_digits) f = substr(f, 1, last_us - 1)
                }
            }
        }

        if (f == "") continue

        /* Append to result vectors (grow if needed) */
        m++
        if (m > capacity) {
            capacity = capacity * 2
            r_ic  = r_ic  \ J(capacity - rows(r_ic), 1, "")
            r_fld = r_fld \ J(capacity - rows(r_fld), 1, "")
            r_val = r_val \ J(capacity - rows(r_val), 1, "")
        }
        r_ic[m]  = ic
        r_fld[m] = f
        r_val[m] = values[i]
    }

    /* Trim to actual count (handle empty case) */
    if (m == 0) {
        stata("qui clear")
        st_local("collapse_nrows", "0")
        st_local("collapse_ncols", "0")
        return
    }
    r_ic  = r_ic[1::m]
    r_fld = r_fld[1::m]
    r_val = r_val[1::m]

    /* ---- Build unique sorted entities and fields ---- */
    u_ent = uniqrows(r_ic)
    u_fld = uniqrows(r_fld)
    ne = rows(u_ent)
    nf = rows(u_fld)

    /* ---- Build safe, unique Stata field names (lowercase, 32 chars max) ---- */
    safe_fld = J(nf, 1, "")
    for (j = 1; j <= nf; j++) {
        safe_fld[j] = _yaml_safe_varname(u_fld[j])
        if (j > 1) {
            safe_fld[j] = _yaml_unique_varname(safe_fld[j], safe_fld[1::(j-1)])
        }
    }

    /* ---- Populate wide matrix (binary search + semicolon-concat) ---- */
    wide = J(ne, nf, "")
    for (i = 1; i <= m; i++) {
        ei = _yaml_binsearch(u_ent, r_ic[i])
        fi = _yaml_binsearch(u_fld, r_fld[i])
        if (ei == 0 | fi == 0) continue
        if (wide[ei, fi] == "") {
            wide[ei, fi] = r_val[i]
        }
        else {
            wide[ei, fi] = wide[ei, fi] + ";" + r_val[i]
        }
    }

    /* ---- Write wide-format dataset to Stata ---- */
    stata("qui clear")
    st_addobs(ne)

    vi = st_addvar("str244", "ind_code")
    for (i = 1; i <= ne; i++) {
        st_sstore(i, vi, u_ent[i])
    }

    for (j = 1; j <= nf; j++) {
        vi = st_addvar("strL", safe_fld[j])
        for (i = 1; i <= ne; i++) {
            if (wide[i, j] != "") {
                st_sstore(i, vi, wide[i, j])
            }
        }
    }

    /* ---- Write field-name mapping to disk (if requested) ---- */
    if (mapfile != "") {
        fh = fopen(mapfile, "w")
        if (fh >= 0) {
            fput(fh, "orig_field\tsafe_field")
            for (j = 1; j <= nf; j++) {
                fput(fh, u_fld[j] + "\t" + safe_fld[j])
            }
            fclose(fh)
        }
    }

    /* Report dimensions back to ado caller */
    st_local("collapse_nrows", strofreal(ne))
    st_local("collapse_ncols", strofreal(nf))
}

end

program define _yaml_collapse
    version 14.0

    quietly {
        tempfile fname_map
        local fname_map "`fname_map'"
        mata: _yaml_mata_collapse("`fname_map'")
        char _dta[yaml_fname_map] "`fname_map'"
        char _dta[yaml_fname_map_n] "`collapse_ncols'"
        compress
    }
end

program define _yaml_fname_map, rclass
    version 14.0
    syntax , [FRAME(string) CLEAR]

    local mapfile : char _dta[yaml_fname_map]
    if ("`mapfile'" == "") {
        di as error "yaml fname map not found (char _dta[yaml_fname_map])"
        exit 601
    }
    capture confirm file "`mapfile'"
    if (_rc != 0) {
        di as error "yaml fname map file missing: `mapfile'"
        exit 601
    }

    if ("`clear'" != "") {
        import delimited using "`mapfile'", clear varnames(1) delimiter(tab)
        return local frame ""
        return local mapfile "`mapfile'"
        exit
    }

    if ("`frame'" == "") {
        local frame "yaml_fname_map"
    }

    capture frame drop `frame'
    frame create `frame'
    frame `frame' {
        import delimited using "`mapfile'", clear varnames(1) delimiter(tab)
    }
    return local frame "`frame'"
    return local mapfile "`mapfile'"
end
