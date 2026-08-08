*******************************************************************************
*! __wbod_parse_yaml_ind_v2 v1.2.1  06Aug2026
*! Parse YAML indicators file using the yaml package's bulk collapse (faster)
*! Preferred parser; falls back to __wbod_parse_yaml_ind when yaml is unavailable
*! v1.2.1: minversion floor 1.9.0 -> 1.9.1 (source_org in the indicators
*!         preset colfields arrived in yaml v1.9.1)
*! v1.2.0: Graceful fallback to the built-in native parser if the yaml package
*!         cannot be resolved/installed or the read fails (works offline on the
*!         shipped file). Session sentinel $WBOD_yaml_checked in {1, native}.
*! v1.1.0: Strip empty YAML arrays [], add source_org to colfields
*!
*! Uses the yaml indicators preset (bulk + collapse) for faster parsing.
*! Produces identical output variables for compatibility with __wbopendata_search_cache
*! (same 11-column contract the native parser emits, so either path is a drop-in).
*******************************************************************************

program define __wbod_parse_yaml_ind_v2
    version 14.0
    args yaml_path

    * Resolve the yaml dependency once per session. On success the fast path
    * is used; if yaml cannot be made available, remember that ("native") and
    * use wbopendata's built-in parser from here on -- no repeated install
    * attempts, and search() keeps working offline on the shipped YAML file.
    if ("$WBOD_yaml_checked" == "") {
        capture __wbod_check_yaml, minversion(1.9.1)
        if (_rc == 0)  global WBOD_yaml_checked "1"
        else           global WBOD_yaml_checked "native"
    }

    if ("$WBOD_yaml_checked" == "native") {
        di as text "(yaml package unavailable - using wbopendata's built-in parser)"
        __wbod_parse_yaml_ind "`yaml_path'"
        exit
    }

    * Fast path via the yaml package. If the read itself fails despite the
    * package being present, fall back rather than hard-erroring.
    capture yaml read using "`yaml_path'", indicators replace blockscalars strl
    if (_rc != 0) {
        di as text "(yaml read failed - using wbopendata's built-in parser)"
        __wbod_parse_yaml_ind "`yaml_path'"
        exit
    }

    quietly {

        * Rename variables to match __wbod_parse_yaml_ind output format
        * yaml collapse produces: ind_code, code, name, source_id, source_name,
        *                         description, topic_ids, topic_names
        *                         (unit, note, limited_data may be missing if no data)
        * search_cache expects:   ind_code, field_name, field_source_id, field_source_name,
        *                         field_desc, field_unit, field_topic_ids, field_topic,
        *                         field_note, field_limited_data, field_source
        
        * Drop redundant code column (ind_code already has the code)
        capture drop code
        
        * Rename fields with field_ prefix (use capture for optional fields)
        rename name field_name
        rename source_id field_source_id
        rename source_name field_source_name
        rename description field_desc
        rename topic_ids field_topic_ids
        rename topic_names field_topic
        
        * Handle optional fields that may not exist
        capture rename unit field_unit
        if (_rc != 0) gen str1 field_unit = ""

        capture rename note field_note
        if (_rc != 0) gen str1 field_note = ""

        capture rename limited_data field_limited_data
        if (_rc != 0) gen byte field_limited_data = 0

        * Rename source_org (now included in colfields via indicators preset)
        capture rename source_org field_source
        if (_rc != 0) gen strL field_source = field_source_id + " " + field_source_name

        * Normalize empty YAML arrays: [] -> ""
        replace field_topic_ids = "" if field_topic_ids == "[]"
        replace field_topic = "" if field_topic == "[]"
        
        * Drop empty indicator rows (if any)
        drop if ind_code == ""
        
        * Keep only necessary columns for smaller cache footprint
        keep ind_code field_name field_desc field_source field_source_name ///
             field_topic field_note field_source_id field_topic_ids ///
             field_unit field_limited_data
    }
end

