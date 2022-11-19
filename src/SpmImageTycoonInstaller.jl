module SpmImageTycoonInstaller

using Dates
using PackageCompiler
using Pkg
using Sockets
using Term
using Term.Progress
using TOML

export install

const VERSION = VersionNumber(TOML.parsefile(joinpath(@__DIR__, "../Project.toml"))["version"]) 

const dev_url = "https://github.com/alexriss/SpmImageTycoon.jl"
const icon_sources = ("res/media/logo_diamond.svg", "res/media/logo_diamond.png", "res/media/logo_diamond.ico")
const icon_targets= ("bin/SpmImageTycoon.svg", "bin/SpmImageTycoon.png", "bin/SpmImageTycoon.ico")

const autohotkey_dir_source = "helpers/windows_tray"
const autohotkey_dir_target= "windows_tray"
const autohotkey_bat_target = "windows_tray/SpmImageTycoon.bat"
const autohotkey_bat_content = "{{ executable }} --julia-args -t auto\ntimeout /t 60"

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

    return abspath(get_install_subdir(d))
end


"""
    get_install_subdir(dir::String)::String

Returns the sub-directory to install SpmImageTycoon to.
"""
function get_install_subdir(dir::String)::String
    return joinpath(dir, "SpmImageTycoon")
end


"""
    get_package_dir(name::String="")::String

Returns package directory for a certain package. Is no `name` is given, returns the `SpmImageTycoon` directory.
"""
function get_package_dir(name::String="")::String
    if name == ""
        name = "SpmImageTycoon"
    end
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

        if !contains(dir, "SpmImageTycoon")
            dir = joinpath(dir, "SpmImageTycoon")
        end
        dir = abspath(dir)
        if isdir(dir) && dir != get_default_install_dir()  # it is ok to overwrite default installation directory
            i = "a"
            while i ∉ ["y","n", ""]
                print("Directory \"$dir\" exists. Overwrite? [y/N]")
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
        cp(joinpath(dir_source, autohotkey_dir_source), joinpath(dir_target, autohotkey_dir_target))

        # we have to rewrite the .bat file to use the compiled file
        c = autohotkey_bat_content
        c = replace(c, "{{ executable }}" =>  abspath(joinpath(dir_target, win_executable_path)))
        open(joinpath(dir_target, autohotkey_bat_target), "w") do io
            println(io, c)
        end
    end
    return nothing
end


"""
    compile_app(dir_target::String, dev_version::Bool=false)::Tuple{String,String}

Runs the package compilation and returns an error message in case of an error. STDOUT is redirected into the global varible OUT.
"""
function compile_app(dir_target::String; dev_version::Bool=false)::Tuple{String,String}
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

    Pkg.activate(temp=true)
    if dev_version
        Pkg.add(url=dev_url)
    else
        Pkg.add("SpmImageTycoon")
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
    wrapper_compile_app(dir_target::String; test_run::Bool=false, dev_version::Bool=false)::Bool

Wrapper that runs the `compile_app` function asynchronosly and updates the progress bar.
"""
function wrapper_compile_app(dir_target::String; test_run::Bool=false, dev_version::Bool=false)::Bool
    out_stdout = stdout
    out_stderr = stderr

    out_filename1, out_filename2 = get_log_filenames()

    if test_run
        compile_task = @task compile_app_sim()
    else
        compile_task = @task compile_app(dir_target, dev_version=dev_version)
    end

    out_file1 = open(out_filename1, "w")
    out_file2 = open(out_filename2, "w")
    redirect_stdio(;stdout=out_file1,stderr=out_file2)
    # buffer_redirect_task = @async write(OUT_buffer, OUT.in)
    
    schedule(compile_task)
    update_progress(compile_task, out_file1, out_file2, out_filename1, out_filename2, out_stdout)

    redirect_stdio(stdout=out_stdout, stderr=out_stderr)
    close(out_file1)
    close(out_file2)
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
    basic_checks()::Bool

Some basic checks before installation.
"""
function basic_checks()::Bool
    try
        Sockets.connect("github.com", 443)
    catch
        println(@bold "Error: No active internet connection detected.")
        println("Please connect to the internet and run the installer again.")
        return false
    end

    # we need `unzip` for Blink.jl installation on Linux
    if Sys.islinux()
        try
            _ = read(`which unzip`, String);
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
    install(dir::String=""; test_run::Bool=false, interactive::Bool=true, dev_version::Bool=false)::Nothing

Installs SpmImageTycoon.

A specific directory can be directly given as `dir`.
If `test_run` is `true`, then installation will only be simulated and compilation will be skipped.
If `interactive` is `false`, then the install will proceed without user interaction.
If `dev_version` is `true`, then the experimental development version of `SpmImageTycoon` will be installed.
"""
function install(dir::String=""; test_run::Bool=false, interactive::Bool=true, dev_version::Bool=false)::Nothing
    Term.Consoles.clear()
    println()
    print(Panel("Welcome to the installation of $(@bold "SpmImage Tycoon")!"; width=66, justify=:center, style="gold1", box=:DOUBLE))
    println("\n")

    basic_checks() || return

    dir_last = get_last_install_dir()
    if dir != ""
        dir_target = dir
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
    dev_version && println("\nUsing development version of SpmImage Tycoon.")
    println("\nInstalling into directory \"$(dir_target)\".\nPlease have a beverage.\n")

    errors_occured = wrapper_compile_app(dir_target, test_run=test_run, dev_version=dev_version)

    if test_run
        data_shortcuts = add_shortcuts_sim(shortcuts)
        version_tycoon = "..."
        version_spmimages = "..."
        version_spmspectroscopy = "..."
    else
        data_shortcuts = add_shortcuts(shortcuts, dir_target)
        version_tycoon = TOML.parsefile(joinpath(get_package_dir(), "Project.toml"))["version"]
        version_spmimages = TOML.parsefile(joinpath(get_package_dir("SpmImages"), "Project.toml"))["version"]
        version_spmspectroscopy = TOML.parsefile(joinpath(get_package_dir("SpmSpectroscopy"), "Project.toml"))["version"]
        redirect_stderr(devnull) do
            Pkg.activate()
        end
    end

    data = Dict{String,Any}(
        "date_start" => DATE_install,
        "date_end" => Dates.now(),
        "target" => dir_target,
        "version" => string(VERSION),
        "interactive" => interactive,
        "dev_version" => dev_version,
        "shortcuts" => data_shortcuts,
        "packages" => Dict{String,Any}(
            "SpmImageTycoon" => version_tycoon,
            "SpmImages" => version_spmimages,
            "SpmSpectroscopy" => version_spmspectroscopy,
        )
    )
    save_info_log(data)

    if !errors_occured
        println("\n\n")
        println(Panel("Installation complete. Enjoy SpmImage Tycoon."; width = 66, justify = :center))
        println()
    end

    return nothing
end


"""Entry point for sysimage/binary created by PackageCompiler.jl"""
function julia_main()::Cint
    install()
    readline()
    return 0
end


end
