*******************************************************************************
*! __wbod_check_yaml v1.0.0  21Feb2026
*! Check if yaml.ado is installed with required version
*! If not, attempt to install from SSC or GitHub
*******************************************************************************

program define __wbod_check_yaml, rclass
    version 14.0
    syntax [, MINVERSION(string) QUIET]
    
    * Default minimum version required for indicators preset
    if ("`minversion'" == "") local minversion "1.9.0"
    
    local yaml_installed = 0
    local yaml_version = ""
    local needs_install = 0
    local install_source = ""
    
    *---------------------------------------------------------------------------
    * Step 1: Check if yaml is installed
    *---------------------------------------------------------------------------
    capture which yaml
    if (_rc != 0) {
        if ("`quiet'" == "") {
            di as text "(yaml.ado not found - will attempt to install)"
        }
        local needs_install = 1
    }
    else {
        local yaml_installed = 1
        
        * Extract version from yaml.ado header
        capture findfile yaml.ado
        if (_rc == 0) {
            local yaml_path = r(fn)
            _wbopendata_parse_yaml_version "`yaml_path'"
            local yaml_version = r(version)
            
            if ("`yaml_version'" != "") {
                * Compare versions
                _wbopendata_compare_versions "`yaml_version'" "`minversion'"
                if (r(newer) == 1) {
                    * minversion is newer than installed - need upgrade
                    if ("`quiet'" == "") {
                        di as text "(yaml.ado v`yaml_version' found, but v`minversion'+ required)"
                    }
                    local needs_install = 1
                }
                else {
                    if ("`quiet'" == "") {
                        di as text "(yaml.ado v`yaml_version' OK)"
                    }
                }
            }
            else {
                * Could not parse version - assume needs update
                if ("`quiet'" == "") {
                    di as text "(yaml.ado found but version unknown - will attempt update)"
                }
                local needs_install = 1
            }
        }
    }
    
    *---------------------------------------------------------------------------
    * Step 2: Install if needed
    *---------------------------------------------------------------------------
    if (`needs_install') {
        local install_success = 0
        
        * Try SSC first
        if ("`quiet'" == "") {
            di as text "(Attempting to install yaml from SSC...)"
        }
        capture ssc install yaml, replace
        if (_rc == 0) {
            local install_success = 1
            local install_source "ssc"
            if ("`quiet'" == "") {
                di as result "yaml.ado installed from SSC"
            }
        }
        else {
            * SSC failed - try GitHub
            if ("`quiet'" == "") {
                di as text "(SSC install failed - trying GitHub...)"
            }
            
            * GitHub raw URL for yaml package
            local github_url "https://raw.githubusercontent.com/jpazvd/yaml/main/src"
            
            capture {
                * Install main files
                net install yaml, from("`github_url'") replace force
            }
            if (_rc == 0) {
                local install_success = 1
                local install_source "github"
                if ("`quiet'" == "") {
                    di as result "yaml.ado installed from GitHub"
                }
            }
            else {
                * Try alternate GitHub structure
                local github_url2 "https://raw.githubusercontent.com/jpazvd/yaml/main"
                capture net install yaml, from("`github_url2'") replace force
                if (_rc == 0) {
                    local install_success = 1
                    local install_source "github"
                    if ("`quiet'" == "") {
                        di as result "yaml.ado installed from GitHub"
                    }
                }
            }
        }
        
        if (!`install_success') {
            di as error "Could not install yaml.ado"
            di as error "Please install manually:"
            di as text "  . ssc install yaml"
            di as text "  or"  
            di as text "  . net install yaml, from(https://raw.githubusercontent.com/jpazvd/yaml/main/src)"
            exit 601
        }
        
        * Verify installation
        capture which yaml
        if (_rc != 0) {
            di as error "yaml.ado installation verification failed"
            exit 601
        }
        local yaml_installed = 1
        
        * Get installed version
        capture findfile yaml.ado
        if (_rc == 0) {
            _wbopendata_parse_yaml_version "`r(fn)'"
            local yaml_version = r(version)
        }
    }
    
    return local installed = "`yaml_installed'"
    return local version = "`yaml_version'"
    return local source = "`install_source'"
    return scalar needed_install = `needs_install'
end


*******************************************************************************
* Helper: Parse yaml.ado version from file header
*******************************************************************************
program define _wbopendata_parse_yaml_version, rclass
    version 14.0
    args yaml_path
    
    local version ""
    
    tempname fh
    capture file open `fh' using "`yaml_path'", read
    if (_rc != 0) {
        return local version ""
        exit
    }
    
    * Read first 20 lines looking for version pattern
    forvalues i = 1/20 {
        file read `fh' line
        if r(eof) continue, break
        
        * Look for patterns like:
        *   *! v 1.9.0
        *   *! yaml v1.9.0
        *   * v1.9.0
        if regexm(`"`line'"', "v[ ]*([0-9]+\.[0-9]+\.[0-9]+)") {
            local version = regexs(1)
            continue, break
        }
    }
    
    file close `fh'
    return local version "`version'"
end


*******************************************************************************
* Helper: Compare two semantic versions (MAJOR.MINOR.PATCH)
* Returns r(newer) = 1 if v2 > v1
*******************************************************************************
capture program drop _wbopendata_compare_versions
program define _wbopendata_compare_versions, rclass
    version 14.0
    args v1 v2

    tokenize "`v1'", parse(".")
    local v1a = real("`1'")
    local v1b = real("`3'")
    local v1c = real("`5'")

    tokenize "`v2'", parse(".")
    local v2a = real("`1'")
    local v2b = real("`3'")
    local v2c = real("`5'")

    local newer = 0
    if (`v2a' > `v1a') local newer = 1
    else if (`v2a' == `v1a') {
        if (`v2b' > `v1b') local newer = 1
        else if (`v2b' == `v1b') {
            if (`v2c' > `v1c') local newer = 1
        }
    }

    return scalar newer = `newer'
end


