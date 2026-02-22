*******************************************************************************
* yaml_frames
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* List YAML frames only
*******************************************************************************

program define yaml_frames, rclass
    version 14.0
    
    syntax [, Detail]
    
    if (`c(stata_version)' < 16) {
        di as err "frames require Stata 16 or later"
        exit 198
    }
    
    local frame_count = 0
    
    di as text "{hline 60}"
    di as text "YAML frames in memory"
    di as text "{hline 60}"
    
    quietly frames dir
    local all_frames `r(frames)'
    foreach fname of local all_frames {
        if (substr("`fname'", 1, 5) == "yaml_") {
            local frame_count = `frame_count' + 1
            if ("`detail'" != "") {
                frame `fname' {
                    local nobs = _N
                    local source : char _dta[yaml_source]
                }
                if ("`source'" != "") {
                    di as text "  `frame_count'. {cmd:`fname'} ({result:`nobs'} entries)"
                    di as text "     Source: `source'"
                }
                else {
                    di as text "  `frame_count'. {cmd:`fname'} ({result:`nobs'} entries)"
                }
            }
            else {
                di as text "  `frame_count'. {cmd:`fname'}"
            }
        }
    }
    
    if (`frame_count' == 0) {
        di as text "  (no YAML frames loaded)"
    }
    
    di as text "{hline 60}"
    di as text "Total: `frame_count' YAML frame(s)"
    di as text ""
    
    * Return results
    return scalar n_frames = `frame_count'
end
