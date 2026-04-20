*******************************************************************************
* yaml_dir
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* List all YAML data in memory
*******************************************************************************

program define yaml_dir, rclass
    version 14.0
    
    syntax [, Detail]
    
    local count = 0
    local n_dataset = 0
    local n_frames = 0

    di as text "{hline 60}"
    di as text "YAML data in memory"
    di as text "{hline 60}"

    * Check current dataset
    capture confirm variable key value level type
    if (_rc == 0) {
        local count = `count' + 1
        local n_dataset = 1
        di as text "  `count'. {cmd:current dataset}"
        if ("`detail'" != "") {
            di as text "     Entries: " _N
            local source : char _dta[yaml_source]
            if ("`source'" != "") {
                di as text "     Source: `source'"
            }
        }
    }
    
    * Check frames (Stata 16+)
    if (`c(stata_version)' >= 16) {
        quietly frames dir
        local all_frames `r(frames)'
        foreach fname of local all_frames {
            if (substr("`fname'", 1, 5) == "yaml_") {
                local count = `count' + 1
                local n_frames = `n_frames' + 1
                if ("`detail'" != "") {
                    frame `fname' {
                        local nobs = _N
                        local source : char _dta[yaml_source]
                    }
                    if ("`source'" != "") {
                        di as text "  `count'. {cmd:`fname'} ({result:`nobs'} entries)"
                        di as text "     Source: `source'"
                    }
                    else {
                        di as text "  `count'. {cmd:`fname'} ({result:`nobs'} entries)"
                    }
                }
                else {
                    di as text "  `count'. {cmd:`fname'}"
                }
            }
        }
    }
    
    if (`count' == 0) {
        di as text "  (no YAML data loaded)"
    }
    
    di as text "{hline 60}"
    di as text "Total: `count' YAML dataset/frame(s)"
    
    return scalar n_total = `count'
    return scalar n_dataset = `n_dataset'
    return scalar n_frames = `n_frames'
end
