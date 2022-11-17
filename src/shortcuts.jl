const linux_startmenu_dir::String = "~/.local/share/applications/"
const linux_startmenu_path::String = "spmimagetycoon.desktop"
const linux_executable_path::String = "bin/SpmImageTycoon"
const linux_icon_path::String = "bin/SpmImageTycoon.svg"
const linux_startmenu_content::String = """[Desktop Entry]
Name=SpmImageTycoon
Exec={{ path }} --julia-args -t auto
Terminal=false
Type=Application
Icon={{ icon }}
"""


"""
    choose_startmenu_shortcuts()::Set{Shortcuts}

Let's the user choose whether to add startmenu and desktop shortcuts.
"""
function choose_startmenu_shortcuts()::Set{Shortcuts}
    s = Set{Shortcuts}()

    println()

    # Start menu
    if Sys.iswindows() || (Sys.islinux() && isdir(linux_startmenu_dir))
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
    add_shortcuts(s::Set{Shortcuts}, dir_target::String)::Dict{String,Any}
    
Adds shortcuts to Start Menu and Desktop.
"""
function add_shortcuts(s::Set{Shortcuts}, dir_target::String)::Dict{String,Any}
    d = Dict{String,Any}()

    length(s) > 0 && println("\n")

    if ShortcutStart in s
        println(@italic "Adding Start Menu shortcut.")
        if Sys.iswindows()

        end
        if Sys.islinux() && isdir(linux_startmenu_dir)
            p = joinpath(linux_startmenu_dir, linux_startmenu_path)
            c = linux_startmenu_content
            c = replace(c, "{{ icon }}" => joinpath(dir_target, linux_icon_path))
            c = replace(c, "{{ path }}" => joinpath(dir_target, linux_executable_path))
            open(p, "w") do io
                println(io, c)
            end
        end
    end

    if ShortcutDesktop in s
        println(@italic "Adding Desktop shortcut.")
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