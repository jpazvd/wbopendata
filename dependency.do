* wbopendata package dependencies.
*
* Run automatically by `github install`; run by hand after `net install` or
* `ssc install`, neither of which has a dependency mechanism:
*
*   do "https://raw.githubusercontent.com/jpazvd/wbopendata/main/dependency.do"
*
* Every install is capture-prefixed, so one unreachable source does not stop
* the rest.

*-----------------------------------------------------------------------------
* Recommended: yaml
*
* wbopendata parses its indicator and topic catalogs faster through yaml. It is
* NOT strictly required: __wbod_parse_yaml_ind_v2 falls back to a built-in
* native parser that emits the same 11-column result, so the package works
* either way. What yaml buys is speed, not capability.
*
* Since v18.8.0 yaml is resolved externally rather than vendored, so it is worth
* installing. Installed only if missing, SSC first with GitHub as the fallback:
* doing it unconditionally would re-download every run and -- once yaml reaches
* SSC -- overwrite the SSC copy with the GitHub one each time.
*-----------------------------------------------------------------------------
capture which yaml
if _rc {
    capture ssc install yaml
    capture which yaml
    if _rc {
        * Not on SSC yet. Install from the canonical public repository.
        capture net install yaml,                                              ///
            from("https://raw.githubusercontent.com/jpazvd/yaml/main/src") replace
    }
    capture which yaml
    if _rc {
        display as text "yaml could not be installed; wbopendata will use its"
        display as text "built-in native parser instead (same result, slower)."
        display as text "To install it later:"
        display as text `"  . net install yaml, from("https://raw.githubusercontent.com/jpazvd/yaml/main/src") replace"'
    }
}

*-----------------------------------------------------------------------------
* Optional: used by examples in the help file, not by the command itself.
* Skipped when already present, for the same reason as above.
*-----------------------------------------------------------------------------
capture which linewrap
if _rc  cap: net install linewrap, from("http://digital.cgdev.org/doc/stata/MO/Misc")

capture which alorenz
if _rc  cap: ssc install alorenz

capture which spmap
if _rc  cap: ssc install spmap

capture which tknz
if _rc  cap: ssc install tknz
