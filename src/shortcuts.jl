const linux_startmenu_dir::String = joinpath(homedir(), ".local/share/applications/")
const linux_startmenu_path::String = "spmimagetycoon.desktop"
const linux_executable_path::String = "bin/SpmImageTycoon"
const linux_icon_path::String = "bin/SpmImageTycoon.svg"
const linux_startmenu_content::String = """[Desktop Entry]
Name=SpmImage Tycoon
Exec={{ path }} --julia-args -t auto
Terminal=false
Type=Application
Icon={{ icon }}
"""

win_desktop_name::String = "SpmImage Tycoon"
win_desktop_name_with_ahk::String = "SpmImage Tycoon (console)"
win_desktop_ahk_name::String = "SpmImage Tycoon"
win_desktop_dir::String = joinpath(homedir(), "Desktop")
win_desktop_path::String = "SpmImage Tycoon.lnk"
win_desktop_path_with_ahk::String = "SpmImage Tycoon (console).lnk"
win_desktop_ahk_path::String = "SpmImage Tycoon.lnk"

win_startmenu_name::String = "SpmImage Tycoon"
win_startmenu_name_with_ahk::String = "SpmImage Tycoon (console)"
win_startmenu_ahk_name::String = "SpmImage Tycoon"
win_startmenu_dir::String = "{{ appdata }}/Microsoft/Windows/Start Menu/Programs/SpmImage Tycoon"
win_startmenu_path::String = "SpmImage Tycoon.lnk"
win_startmenu_path_with_ahk::String = "SpmImage Tycoon (console).lnk"
win_startmenu_ahk_path::String = "SpmImage Tycoon.lnk"

win_executable_path::String = "bin/SpmImageTycoon.exe"
win_executable_path_dir::String = "bin"
win_executable_ahk_path::String = joinpath(autohotkey_dir_target, "SpmImageTycoon_v1.ahk")
win_executable_ahk_path_v2::String = joinpath(autohotkey_dir_target, "SpmImageTycoon.ahk")
win_executable_ahk_path_dir::String = autohotkey_dir_target

win_icon_path::String = "bin/SpmImageTycoon.ico"
win_link_content_filename::String = "temp.vbs"
win_link_content_executable::String = "wscript.exe"
win_link_content::String = """Set oWS = WScript.CreateObject("WScript.Shell")
    sLinkFile = "{{ target }}"
    Set oLink = oWS.CreateShortcut(sLinkFile)
    oLink.TargetPath = "{{ path }}"
    oLink.Arguments = "--julia-args -t auto"
    oLink.Description = "{{ name }}"
    oLink.IconLocation = "{{ icon }}"
    oLink.WindowStyle = "1"
    oLink.WorkingDirectory = "{{ path_dir }}"
    oLink.Save
"""


"""
    choose_startmenu_shortcuts()::Set{Shortcuts}

Let's the user choose whether to add startmenu and desktop shortcuts.
"""
function choose_startmenu_shortcuts()::Set{Shortcuts}
    s = Set{Shortcuts}()

    println()

    # Start menu
    if Sys.iswindows() || Sys.islinux()
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
        # todo
    end

    return s
end


"""
    check_autohotkey()::Int

Checks if autohotkey is associated with the .ahk extension. Returns 0 if not, 1 if yes (v1), and 2 if yes (v2).
"""
function check_autohotkey()::Int
    if Sys.iswindows()
        res = 0
        try
            redirect_stderr(devnull) do
                assoc = read(`cmd.exe /c assoc .ahk`, String);
                if split(strip(assoc), "=")[end] == "AutoHotkeyScript"
                    ftype = read(`cmd.exe /c ftype AutoHotkeyScript`, String);
                    if contains(strip(ftype), "AutoHotkeyUX.exe")
                        res = 2
                    else # v1
                        res = 1
                    end
                end
            end
            return res
        catch
            return 0
        end
    end
    return 0
end


"""
    add_shortcut_startmenu_linux(dir_target::String)::Dict{String,Any}

Adds start menu shortcut in Linux.
"""
function add_shortcut_linux_startmenu(dir_target::String)::Dict{String,Any}
    isdir(linux_startmenu_dir) || mkpath(linux_startmenu_dir)
    p = joinpath(linux_startmenu_dir, linux_startmenu_path)
    sicon = joinpath(dir_target, linux_icon_path)
    spath = joinpath(dir_target, linux_executable_path)
    c = linux_startmenu_content
    c = replace(c, "{{ icon }}" => sicon)
    c = replace(c, "{{ path }}" => spath)
    open(p, "w") do io
        println(io, c)
    end
    return Dict{String,Any}(
        "shortcut" => p,
        "path" => spath,
        "icon" => sicon,
    )
end


"""
    add_shortcut_win(dir_target::String, dir_link_target::String, name::String;
icon_path::String, executable_path::String, executable_path_dir::String)::Dict{String,Any}

Adds desktop or startmenu shortcuts in Windows.
"""
function add_shortcut_win(dir_target::String, dir_link_target::String, name::String,
    icon_path::String, executable_path::String, executable_path_dir::String)::Dict{String,Any}

    isdir(dirname(dir_link_target)) || mkpath(dirname(dir_link_target))

    sicon = abspath(joinpath(dir_target, icon_path))
    spath = abspath(joinpath(dir_target, executable_path))
    spath_dir = abspath(joinpath(dir_target, executable_path_dir))
    c = win_link_content
    c = replace(c, "{{ name }}" => name)
    c = replace(c, "{{ target }}" => dir_link_target)
    c = replace(c, "{{ icon }}" => sicon)
    c = replace(c, "{{ path }}" => spath)
    c = replace(c, "{{ path_dir }}" => spath_dir)

    fname = tempname() * win_link_content_filename
    write(fname, c)
    _ = read(`$win_link_content_executable $fname`, String)
    rm(fname)

    return Dict{String,Any}(
        "name" => name,
        "shortcut" => dir_link_target,
        "path" => spath,
        "path_dir" => spath_dir,
        "icon" => sicon,
    )
end


"""
    add_shortcut_win_startmenu(dir_target::String; autohotkey::Bool=false)::Dict{String,Any}

Adds startmenu shortcut in Windows.
"""
function add_shortcut_win_startmenu(dir_target::String; autohotkey::Bool=false)::Dict{String,Any}
    d = replace(win_startmenu_dir, "{{ appdata }}" => ENV["APPDATA"])
    p = autohotkey ? win_startmenu_path_with_ahk : win_startmenu_path
    p = abspath(joinpath(d, p))
    n = autohotkey ? win_startmenu_name_with_ahk : win_startmenu_name
    return add_shortcut_win(dir_target, p, n, win_icon_path, win_executable_path, win_executable_path_dir)
end


"""
    add_shortcut_win_ahk_startmenu(dir_target::String, ahk::Int)::Dict{String,Any}

Adds startmenu shortcut in Windows to the Autohotkey script.
"""
function add_shortcut_win_ahk_startmenu(dir_target::String, ahk::Int)::Dict{String,Any}
    d = replace(win_startmenu_dir, "{{ appdata }}" => ENV["APPDATA"])
    p = abspath(joinpath(d, win_startmenu_ahk_path))
    ahk_path = (ahk == 2) ? win_executable_ahk_path_v2 : win_executable_ahk_path
    return add_shortcut_win(dir_target, p, win_startmenu_ahk_name, win_icon_path, ahk_path, win_executable_ahk_path_dir)
end


"""
    add_shortcut_win_desktop(dir_target::String; autohotkey::Bool=false)::Dict{String,Any}

Adds desktop shortcut in Windows.
"""
function add_shortcut_win_desktop(dir_target::String; autohotkey::Bool=false)::Dict{String,Any}
    p = autohotkey ? win_desktop_path_with_ahk : win_desktop_path
    n = autohotkey ? win_desktop_name_with_ahk : win_desktop_name
    p = abspath(joinpath(win_desktop_dir, p))
    return add_shortcut_win(dir_target, p, n, win_icon_path, win_executable_path, win_executable_path_dir)
end


"""
    add_shortcut_win_ahk_desktop(dir_target::String, ahk::Int)::Dict{String,Any}

Adds desktop shortcut in Windows to the Autohotkey script.
"""
function add_shortcut_win_ahk_desktop(dir_target::String, ahk::Int)::Dict{String,Any}
    p = abspath(joinpath(win_desktop_dir, win_desktop_ahk_path))
    ahk_path = (ahk == 2) ? win_executable_ahk_path_v2 : win_executable_ahk_path
    return add_shortcut_win(dir_target, p, win_desktop_ahk_name, win_icon_path, ahk_path, win_executable_ahk_path_dir)
end


"""
    add_shortcuts(s::Set{Shortcuts}, dir_target::String)::Tuple{Dict{String,Any},String,String}
    
Adds shortcuts to Start Menu and Desktop.
"""
function add_shortcuts(s::Set{Shortcuts}, dir_target::String)::Tuple{Dict{String,Any},String,String}
    d = Dict{String,Any}(
        "num" => length(s),
        "errors" => false
    )

    length(s) > 0 && println("\n")

    err = ""
    err_full = ""
    try
        ahk = 0
        ahk_present = false
        if Sys.iswindows()
            ahk = check_autohotkey()
            ahk_present = ahk > 0
        end
        if ShortcutStart in s
            println(@italic "Adding Start Menu shortcut.")

            if Sys.iswindows()
                d["StartMenu"] = add_shortcut_win_startmenu(dir_target, autohotkey=ahk_present)
                ahk_present && (d["StartMenu_AHK"] = add_shortcut_win_ahk_startmenu(dir_target, ahk))
            end
            if Sys.islinux()
                d["StartMenu"] = add_shortcut_linux_startmenu(dir_target)
            end
        end

        if ShortcutDesktop in s
            println(@italic "Adding Desktop shortcut.")

            if Sys.iswindows()
                d["Desktop"] = add_shortcut_win_desktop(dir_target, autohotkey=ahk_present)
                ahk_present && (d["Desktop_AHK"] = add_shortcut_win_ahk_desktop(dir_target, ahk))
            end
        end
    catch e
        d["errors"] = true
        err = sprint(showerror, e)
        err_full = sprint(showerror, e, catch_backtrace())
    end

    return d, err, err_full
end


"""
    add_shortcuts_sim(s::Set{Shortcuts})::Tuple{Dict{String,Any},String,String}

Test run function for adding shortcuts.
"""
function add_shortcuts_sim(s::Set{Shortcuts})::Tuple{Dict{String,Any},String,String}
    d = Dict{String,Any}(
        "num" => length(s),
        "errors" => false
    )

    length(s) > 0 && println("\n")

    err = ""
    err_full = ""

    if ShortcutStart in s
        println(@italic "Adding Start Menu shortcut.")
        d["StartMenu"] = Dict(
            "shortcut" => "...",
            "path" => "...",
            "icon" => "...",
        )
    end

    if ShortcutDesktop in s
        println(@italic "Adding Desktop shortcut.")
        d["Desktop"] = Dict(
            "shortcut" => "...",
            "path" => "...",
            "icon" => "...",
        )
    end

    # throw test error once in a while
    if rand() < 0.5 && !isdefined(Main, :Test)
        d["errors"] = true
        err = "Test error."
        err_full = "This error is thrown randomly, just to test this pathway."
    end
    return d, err, err_full
end