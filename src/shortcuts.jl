"""
    add_shortcuts(s::Set{Shortcuts})::Dict{Any,Any}
    
Adds shortcuts to Start Menu and Desktop.
"""
function add_shortcuts(s::Set{Shortcuts})::Dict{Any,Any}
    d = Dict()

    if ShortcutStart in s
        if Sys.iswindows()

        end
        if Sys.islinux() && isdir("~/.local/share/applications/")
        end
    end

    if ShortcutDesktop in s
        if Sys.iswindows()
        end
    end

    return d
end