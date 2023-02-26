module SpmImageTycoonInstaller

using Dates
using PackageCompiler
using Pkg
using Sockets
using Term
using Term.Progress
using TOML

export install, install_shortcuts

const VERSION = VersionNumber(TOML.parsefile(joinpath(@__DIR__, "../Project.toml"))["version"]) 

const dev_url = "https://github.com/alexriss/SpmImageTycoon.jl"
const superdev_branch = "dev"
const icon_sources = ("res/media/logo_diamond.svg", "res/media/logo_diamond.png", "res/media/logo_diamond.ico")
const icon_targets= ("bin/SpmImageTycoon.svg", "bin/SpmImageTycoon.png", "bin/SpmImageTycoon.ico")

const autohotkey_dir_source = "helpers/windows_tray"
const autohotkey_dir_target= "windows_tray"
const autohotkey_ext_skip = ".bat"
const autohotkey_bat_target = "SpmImageTycoon.bat"
const autohotkey_bat_content = "\"{{ executable }}\" --julia-args -t auto\ntimeout /t 60"

global DATE_install::DateTime=Dates.now()

@enum Shortcuts ShortcutStart ShortcutDesktop


include("logging.jl")
include("progress.jl")
include("shortcuts.jl") 


"""
    get_default_install_dir()::String

Returns default installation directory depending on OS.
"""
function get_default_install_dir()::String
    if Sys.iswindows()
        d = ENV["LOCALAPPDATA"]
    elseif Sys.islinux()
        d = joinpath(homedir(), ".local/bin")
    elseif Sys.isapple()
        d = joinpath(homedir(), "Applications")
    else
        d = "."
    end

    return get_install_subdir(d)
end


"""
    get_install_subdir(dir::String)::String

Returns the sub-directory to install SpmImageTycoon to.
"""
function get_install_subdir(dir::String)::String
    d = lowercase(dir)
    (contains(d, "spmimagetycoon") || contains(d, "spmimage tycoon")) && return dir
   
    return abspath(joinpath(dir, "SpmImageTycoon"))
end


"""
    get_package_dir(name::String="")::String

Returns package directory for a certain package. Is no `name` is given, returns the `SpmImageTycoon` directory.
"""
function get_package_dir(name::String="")::String
    if name == ""
        name = "SpmImageTycoon"
    end
    d = Base.find_package(name)
    isnothing(d) && return ""
    return abspath(joinpath(Base.find_package(name), "../.."))
end


"""
    choose_install_dir(dir::String)::String

Let's the user choose a installation directory.
"""
function choose_install_dir(dir::String)::String
    println("Choose the installation directory.")
    println("Default directory is \"$dir\".")
    println("Press ENTER to keep this default.\n")
    
    install_dir_ok = false
    while !install_dir_ok
        print("Installation directory: ")
        i = readline()
        if length(i) > 0
            dir = i
        end

        dir = get_install_subdir(dir)
        if isdir(dir) && dir != get_default_install_dir()  && dir != get_last_install_dir()  # it is ok to overwrite default and previous installation directories
            i = "a"
            while i ∉ ["y","n", ""]
                print("Directory \"$dir\" exists. Overwrite [y/N]: ")
                i = lowercase(readline())
            end
            if i == "y"
                install_dir_ok = true
            end
        else
            install_dir_ok = true
        end
    end

    return abspath(dir)
end


"""
    copy_icons(dir_source::String, dir_target::String)::Nothing

Copies icons to bin directory.
"""
function copy_icons(dir_source::String, dir_target::String)::Nothing
    for (s, t) in zip(icon_sources, icon_targets)
        cp(joinpath(dir_source, s), joinpath(dir_target, t))
    end
    return nothing
end


"""
    copy_autohotkey(dir_source::String, dir_target::String)::Nothing

Copies autohotkey helpers to installation directory.
"""
function copy_autohotkey(dir_source::String, dir_target::String)::Nothing
    if Sys.iswindows()
        d_target = joinpath(dir_target, autohotkey_dir_target)
        if !isdir(d_target)
            mkpath(d_target)
        end

        d_source = joinpath(dir_source, autohotkey_dir_source)
        files = readdir(d_source, sort=true, join=true)

        map(files) do f
            if !endswith(f, autohotkey_ext_skip)
                cp(f, joinpath(d_target, basename(f)), force=true)
            end
        end

        # we have to rewrite the .bat file to use the compiled file
        c = autohotkey_bat_content
        c = replace(c, "{{ executable }}" =>  abspath(joinpath(dir_target, win_executable_path)))
        fname = joinpath(d_target, autohotkey_bat_target)
        open(fname, "w") do io
            println(io, c)
        end
    end
    return nothing
end


"""
    compile_app(dir_target::String; ver::String="main")::Tuple{String,String}

Runs the package compilation and returns an error message in case of an error.
"""
function compile_app(dir_target::String; ver::String="main")::Tuple{String,String}
    err = ""
    err_full = ""

    if isdir(dir_target)
        i = 1
        while i <=5
            try
                rm(dir_target, force=true, recursive=true)
            catch e  # can occur when directory is busy or no write privileges
                err = sprint(showerror, e)
                err_full = sprint(showerror, e, catch_backtrace())
            end
            isdir(dir_target) || break
            sleep(1)
            i += 1
        end
        i == 6 && return err, err_full
    end

    if ver != "local"
        Pkg.activate(temp=true)
        if ver == "dev"
            Pkg.add(url=dev_url)
        elseif ver == "superdev"
            Pkg.add(url=dev_url, rev=superdev_branch)
        else
            Pkg.add("SpmImageTycoon")
        end
    
        # we need make sure Blink/Electron is installed, too
        Pkg.build("Blink")
    end

    dir_source = get_package_dir()
    try
        create_app(dir_source, dir_target, incremental=false, filter_stdlibs=true, include_lazy_artifacts=true, force=true)
        copy_icons(dir_source, dir_target)
        copy_autohotkey(dir_source, dir_target)
    catch e
        err = sprint(showerror, e)
        err_full = sprint(showerror, e, catch_backtrace())
    end

    return err, err_full
end


"""
    compile_app_sim(return_error::Bool=false)::Tuple{String,String}

Simulation of compilation. If `return_error` is `true`, sends back a simulated error message.
"""
function compile_app_sim(return_error::Bool=false)::Tuple{String,String}
    println("""
    Activating new project at `...`
    Resolving package versions...
    Updating `...Project.toml`
    [...] + SpmImageTycoon v...
    Updating `...Manifest.toml`
    """)
    sleep(1.5)
    println("""
    PackageCompiler: bundled artifacts:
    ├── FFTW_jll - 7.222 MiB
    ├── Ghostscript_jll - 31.649 MiB
    ├── ImageMagick_jll - 25.772 MiB
    ├── Imath_jll - 1.005 MiB
    ├── IntelOpenMP_jll - 5.973 MiB
    ├── JpegTurbo_jll - 4.951 MiB
    ├── LERC_jll - 758.367 KiB
    ├── Libtiff_jll - 9.929 MiB
    ├── MKL_jll - 647.176 MiB
    ├── OpenEXR_jll - 10.481 MiB
    ├── OpenSpecFun_jll - 798.680 KiB
    ├── WebIO
    │   └── web - 694.920 KiB
    ├── Zstd_jll - 3.936 MiB
    ├── libpng_jll - 1.714 MiB
    └── libsixel_jll - 1.464 MiB
    """)
    sleep(1.5)
    println("""Total artifact file size: 753.470 MiB""")
    sleep(0.5)
    println("""[02m:04s] PackageCompiler: compiling base system image (incremental=false)""")
    sleep(0.5)
    println("""Precompiling project...""")
    sleep(0.5)
    println("""163 dependencies successfully precompiled in 419 seconds""")
    sleep(1.)
    println("""[08m:40s] PackageCompiler: compiling nonincremental system image""")
    sleep(1.)
    println("""[08m:40s] PackageCompiler: compiling nonincremental system image""")
    sleep(1.)
    println("""✔ [08m:40s] PackageCompiler: compiling nonincremental system image""")

    if return_error
        return "Error message.", "Long error messages. Long error messages.\nLong error messages. Long error messages. Long error messages."
    else
        return "", ""
    end
end


"""
    wrapper_compile_app(dir_target::String; ver::String="main", test_run::Bool=false, debug::Bool=false)::Bool

Wrapper that runs the `compile_app` function asynchronosly and updates the progress bar.
"""
function wrapper_compile_app(dir_target::String; ver::String="main", test_run::Bool=false, debug::Bool=false)::Bool
    if test_run
        compile_task = @task compile_app_sim()
    else
        compile_task = @task compile_app(dir_target, ver=ver)
    end

    if debug
        schedule(compile_task)
    else
        out_stdout = stdout
        out_stderr = stderr
        out_filename1, out_filename2 = get_log_filenames()
        out_file1 = open(out_filename1, "w")
        out_file2 = open(out_filename2, "w")
        redirect_stdio(;stdout=out_file1,stderr=out_file2)
        
        schedule(compile_task)
        update_progress(compile_task, out_file1, out_file2, out_filename1, out_filename2, out_stdout)

        redirect_stdio(stdout=out_stdout, stderr=out_stderr)
        close(out_file1)
        close(out_file2)
    end
    err, err_full = fetch(compile_task)
    
    errors_occured = false
    if length(err) > 0
        errors_occured = true
        println()
        println(Panel("Errors occured during the installation:"; width=66, justify=:center))
        println()
        println(err)
        println(err_full)
    end

    return errors_occured
end


"""
    basic_checks(; ver::String="main", debug::Bool=false)::Bool

Some basic checks before installation.
"""
function basic_checks(; ver::String="main", debug::Bool=false)::Bool
    if ver == "local"
        if isnothing(get_package_dir())
            println(@bold "Error: No local installation found.")
            println("To use the `local` version, you need to have SpmImageTycoon installed locally.")
            return false
        end
        return true  # the other checks are not necessary for a local version installation
    end

    try
        if debug
            Sockets.connect("github.com", 443)
        else
            redirect_stderr(devnull) do
                Sockets.connect("github.com", 443)
            end
        end
    catch
        println(@bold "Error: No active internet connection detected.")
        println("Please connect to the internet and run the installer again.")
        return false
    end

    # we need `unzip` for Blink.jl installation on Linux
    if Sys.islinux()
        try
            if debug
                _ = read(`which unzip`, String);
            else
                redirect_stderr(devnull) do
                    _ = read(`which unzip`, String);
                end
            end
        catch
            println(@bold "Error: `unzip` not present on your system.")
            println("On Debian/Ubuntu systems you can install it with:")
            println("sudo apt install unzip")
            return false
        end
    end
    return true
end


"""
    install(dir::String=""; ver::String="main", shortcuts_only::Bool=false,
        interactive::Bool=true, debug::Bool=false, test::Bool=false)::Nothing

Installs SpmImageTycoon.

A specific directory can be directly given as `dir`.

`ver` specifies the version to install: `"main"` (default), `"dev"` for the development version,
`"local"` for the locally installed version of `SpmImageTycoon`.

If `shortcuts_only` is  `true`. then only shortcuts will be installed - not the app itself (use this only if you installed the app before - otherwise the shortcuts won't work).
If `interactive` is `false`, then the install will proceed without user interaction.
If 'debug' is `true`, then the behind-the-scenes output of the installation will be shown (instead of written to a log file).
If `test` is `true`, then installation will only be simulated and compilation will be skipped.
"""
function install(dir::String=""; ver::String="main", shortcuts_only::Bool=false,
        interactive::Bool=true, debug::Bool=false, test::Bool=false)::Nothing
    Term.Consoles.clear()
    println()
    print(Panel("Welcome to the installation of $(@bold "SpmImage Tycoon")!"; width=66, justify=:center, style="gold1", box=:DOUBLE))
    println("\n")

    basic_checks(ver=ver, debug=debug) || return

    dir_last = get_last_install_dir()
    if dir != ""
        dir_target = get_install_subdir(dir)
    elseif !isnothing(dir_last)
        dir_target = dir_last
    else
        dir_target = get_default_install_dir()
    end

    shortcuts = Set{Shortcuts}([ShortcutStart, ShortcutDesktop])
    if interactive
        dir_target = choose_install_dir(dir_target)
        shortcuts = choose_startmenu_shortcuts()
    end

    global DATE_install = Dates.now()

    if !shortcuts_only
        if !(ver in ["main", "dev", "local", "superdev"])
            println("Unknown version `$(ver)`. Using main version of SpmImage Tycoon.")
            ver = "main"
        end
        (ver == "dev") && println("\nUsing the development version of SpmImage Tycoon.")
        (ver == "local") && println("\nUsing the local version of SpmImage Tycoon.")
        (ver == "superdev") && println("\nUsing the experimental version of SpmImage Tycoon. Very brave of you!")
        println("\nInstalling into directory \"$(dir_target)\".\nPlease have a beverage.\n")

        errors_occured = wrapper_compile_app(dir_target, ver=ver, test_run=test, debug=debug)
    else
        errors_occured = false
    end

    version_tycoon = "..."
    version_spmimages = "..."
    version_spmspectroscopy = "..."
    data_shortcuts = Dict{String,Any}("num" => length(shortcuts))
    if test
        if !errors_occured 
            data_shortcuts, err, err_full = add_shortcuts_sim(shortcuts)
        end
    else
        if !errors_occured
            data_shortcuts, err, err_full = add_shortcuts(shortcuts, dir_target)
        end
        try
            version_tycoon = TOML.parsefile(joinpath(get_package_dir(), "Project.toml"))["version"]
            version_spmimages = TOML.parsefile(joinpath(get_package_dir("SpmImages"), "Project.toml"))["version"]
            version_spmspectroscopy = TOML.parsefile(joinpath(get_package_dir("SpmSpectroscopy"), "Project.toml"))["version"]
        catch
        end
        if debug
            Pkg.activate()
        else
            redirect_stderr(devnull) do
                Pkg.activate()
            end
        end
    end

    data = Dict{String,Any}(
        "date_start" => DATE_install,
        "date_end" => Dates.now(),
        "target" => dir_target,
        "version" => string(VERSION),
        "interactive" => interactive,
        "channel" => ver,
        "shortcuts" => data_shortcuts,
        "packages" => Dict{String,Any}(
            "SpmImageTycoon" => version_tycoon,
            "SpmImages" => version_spmimages,
            "SpmSpectroscopy" => version_spmspectroscopy,
        ),
        "errors" => errors_occured,
        "shortcuts_only" => shortcuts_only
    )
    save_info_log(data)

    if !errors_occured && !data_shortcuts["errors"]
        println("\n\n")
        println(Panel("Installation complete. Enjoy SpmImage Tycoon."; width = 66, justify = :center))
        println()
    elseif shortcuts_only && data_shortcuts["errors"]
        println("\n\n")
        println("Errors were encountered when trying to create shortcuts.")
        print("Press ENTER to view the error trace: ")
        readline()
        println()
        println(err)
        println(err_full)
    elseif !errors_occured
        println("\n\n")
        println(Panel("SpmImage Tycoon was installed."; width = 66, justify = :center))
        println("\n\nBut some errors were encountered when trying to create shortcuts.")
        print("Press ENTER to view the error trace: ")
        readline()
        println()
        println(err)
        println(err_full)
    end

    return nothing
end

"""
    install_shortcuts(dir::String=""; test::Bool=false, interactive::Bool=true)::Nothing

Installs shortcuts for SpmImage Tycoon. Use this only if you installed the app before - otherwise the shortcuts won't work.

If `test` is `true`, then installation will only be simulated and compilation will be skipped.
If `interactive` is `false`, then the install will proceed without user interaction.
"""
function install_shortcuts(dir::String=""; test::Bool=false, interactive::Bool=true)::Nothing
    return install(dir, shortcuts_only=true, test=test, interactive=interactive)
end


"""Entry point for sysimage/binary created by PackageCompiler.jl"""
function julia_main()::Cint
    install()
    readline()
    return 0
end


end
