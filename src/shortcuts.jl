"""
    choose_startmenu_shortcuts()::Set{Shortcuts}

Let's the user choose whether to add startmenu and desktop shortcuts.
"""
function choose_startmenu_shortcuts()::Set{Shortcuts}
    s = Set{Shortcuts}()

    println()

    # Start menu
    if Sys.iswindows() || (Sys.islinux() && isdir("~/.local/share/applications/"))
        print("Add Start Menu shortcut [Y/n]: ")
        i = lowercase(readline())
        if i == "y" || i == ""
            push!(s, ShortcutStart)
        end
    end

    # Desktop
    if Sys.iswindows()
        print("Add Desktop shortcut [Y/n]: ")
        i = lowercase(readline())
        if i == "y" || i == ""
            push!(s, ShortcutDesktop)
        end
    end

    if Sys.isapple()
        pass # todo
    end

    return s
end


"""
    add_shortcuts(s::Set{Shortcuts})::Dict{String,Any}
    
Adds shortcuts to Start Menu and Desktop.
"""
function add_shortcuts(s::Set{Shortcuts})::Dict{String,Any}
    d = Dict{String,Any}()

    length(s) > 0 && println("\n")

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


"""
    add_shortcuts_sim(s::Set{Shortcuts})::Dict{String,Any}

Test run function for adding shortcuts.
"""
function add_shortcuts_sim(s::Set{Shortcuts})::Dict{String,Any}
    d = Dict{String,Any}()

    length(s) > 0 && println("\n")

    if ShortcutStart in s
        println(@italic "Adding Start Menu shortcut.")
        d["Start Menu"] = Dict(
            "location" => "...",
            "target" => "...",
            "icon" => "...",
        )
    end

    if ShortcutDesktop in s
        println(@italic "Adding Desktop shortcut.")
        d["Desktop"] = Dict(
            "location" => "...",
            "target" => "...",
            "icon" => "...",
        )
    end

    return d
end