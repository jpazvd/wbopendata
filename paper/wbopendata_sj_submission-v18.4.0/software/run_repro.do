* Portable runner: works from any machine/location
local script_dir = subinstr(c(pwd), "\", "/", .)
local thisfile = subinstr("`c(filename)'", "\", "/", .)
if regexm("`thisfile'", "(.+)/[^/]+\\.do$") {
	local script_dir = regexs(1)
}

cd "`script_dir'"
do "reproduce_paper_examples.do"
