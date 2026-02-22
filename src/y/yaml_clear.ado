*******************************************************************************
* yaml_clear
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* Clear YAML data from memory
*******************************************************************************

program define yaml_clear
    version 14.0
    
    syntax [anything(name=framename)] [, All]
    
    * If no framename, clear current dataset
    if ("`framename'" == "") {
        if ("`all'" != "") {
            * Clear all yaml_* frames (Stata 16+)
            if (`c(stata_version)' < 16) {
                di as err "frames require Stata 16 or later"
                exit 198
            }
            
            quietly frames dir
            local frames "`r(frames)'"
            foreach fname of local frames {
                if (substr("`fname'", 1, 5) == "yaml_") {
                    capture frame drop `fname'
                }
            }
            di as text "Cleared all yaml_* frames."
        }
        else {
            * Clear current dataset
            clear
            di as text "Cleared current dataset."
        }
    }
    else {
        * Clear specific frame
        if (`c(stata_version)' < 16) {
            di as err "frames require Stata 16 or later"
            exit 198
        }
        
        if (substr("`framename'", 1, 5) != "yaml_") {
            local framename "yaml_`framename'"
        }
        capture frame drop `framename'
        di as text "Cleared frame `framename'."
    }
end
