*******************************************************************************
* _yaml_tokenize_line
*! v 1.5.1   18Feb2026               by Joao Pedro Azevedo (UNICEF)
* Tokenize a YAML line (streaming canonical parser helper)
*******************************************************************************

program define _yaml_tokenize_line, sclass
    version 14.0
    syntax, line(string)

    local trimmed = strtrim(`"`line'"')
    local indent = 0
    local templine `"`line'"'
    while (substr(`"`templine'"', 1, 1) == " ") {
        local indent = `indent' + 1
        local templine = substr(`"`templine'"', 2, .)
    }
    local is_list = (substr(`"`trimmed'"', 1, 2) == "- ")

    sreturn local trimmed `"`trimmed'"'
    sreturn local indent "`indent'"
    sreturn local is_list "`is_list'"
end
