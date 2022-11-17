module SpmImageTycoonInstaller

using Dates
using PackageCompiler
using Pkg
using Term
using Term.Progress
using TOML

export install

const VERSION = VersionNumber(TOML.parsefile(joinpath(@__DIR__, "../Project.toml"))["version"]) 

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
        d = "~/.local/bin"
    elseif Sys.isapple()
        d = "~/Applications"
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
    get_package_dir()::String

Returns package directory for SpmImageTycoon.
"""
function get_package_dir()::String
    return joinpath(Base.find_package("SpmImageTycoon"), "../..")
end


"""
    choose_install_dir(dir::String)::String

Let's the user choose a installation directory.
"""
function choose_install_dir(dir::String)::String
    println("Please choose the installation directory.")
    println("(Make sure you have sufficient write privileges).\n")
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
        if i == "y"
            push!(s, ShortcutStart)
        end
    end

    # Desktop
    if Sys.iswindows()
        print("Add Desktop shortcut [Y/n]: ")
        i = lowercase(readline())
        if i == "y"
            push!(s, ShortcutDesktop)
        end
    end

    if Sys.isapple()
        pass # todo
    end

    return s
end


"""
    compile_app(dir_target::String)::Tuple{String,String}

Runs the package compilation and returns an error message in case of an error. STDOUT is redirected into the global varible OUT.
"""
function compile_app(dir_target::String)::Tuple{String,String}
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
    Pkg.add("SpmImageTycoon")
    dir_source = get_package_dir()

    try
        create_app(dir_source, dir_target, incremental=false, filter_stdlibs=true, include_lazy_artifacts=true, force=true)
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
    sleep(1.5)
    println("""[08m:40s] PackageCompiler: compiling nonincremental system image""")
    sleep(1.5)
    println("""[08m:40s] PackageCompiler: compiling nonincremental system image""")
    sleep(1.5)
    println("""✔ [08m:40s] PackageCompiler: compiling nonincremental system image""")

    if return_error
        return "Error message.", "Long error messages. Long error messages.\nLong error messages. Long error messages. Long error messages."
    else
        return "", ""
    end
end


"""
    wrapper_compile_app(dir_target::String; test_run::Bool=false)::Bool

Wrapper that runs the `compile_app` function asynchronosly and updates the progress bar.
"""
function wrapper_compile_app(dir_target::String; test_run::Bool=false)::Bool
    out_stdout = stdout
    out_stderr = stderr

    out_filename1, out_filename2 = get_log_filenames()

    if test_run
        compile_task = @task compile_app_sim()
    else
        compile_task = @task compile_app(dir_target)
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
    install(dir::String=""; test_run::Bool=false, interactive::Bool=true)::Nothing

Installs SpmImageTycoon.
"""
function install(dir::String=""; test_run::Bool=false, interactive::Bool=true)::Nothing
    Term.Consoles.clear()
    println()
    print(Panel("Welcome to the installation of $(@bold "SpmImage Tycoon")."; width=66, justify=:center, style="gold1", box=:DOUBLE))
    println("\n\n")

    dir_target = (dir == "") ? get_default_install_dir() : dir
    if interactive
        dir_target = choose_install_dir(dir_target)
        shortcuts = choose_startmenu_shortcuts()
    end

    global DATE_install = Dates.now()
    println("\nInstalling into directory \"$(dir_target)\".\nPlease have a beverage.\n")

    errors_occured = wrapper_compile_app(dir_target, test_run=test_run)

    if !errors_occured
        println("\n\n")
        println(Panel("Installation complete. Enjoy SpmImage Tycoon."; width = 66, justify = :center))
        println()
    end

    if !test_run
        data_shortcuts = add_shortcuts(shortcuts)
        data = Dict(
            "date" => DATE_install,
            "target" => dir_target,
            "shortcuts" => data_shortcuts
        )
        save_info_log(data)
        Pkg.activate()
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
