module SpmImageTycoonInstaller

using Dates
using PackageCompiler
using Pkg
using Term
using Term.Progress
using TOML

export install

const VERSION = VersionNumber(TOML.parsefile(joinpath(@__DIR__, "../Project.toml"))["version"]) 

include("progress_bar.jl")
include("logging.jl")


global OUT::Pipe = Pipe()  # used for redirected STDOUT
global OUT_buffer::IOBuffer = IOBuffer()


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
    compile_app(dir_source::String, dir_target::String)::Tuple{String,String}

Runs the package compilation and returns an error message in case of an error. STDOUT is redirected into the global varible OUT.
"""
function compile_app(dir_source::String, dir_target::String)::Tuple{String,String}
    err = ""
    err_full = ""
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
    wrapper_compile_app(dir_source::String, dir_target::String; test_run::Bool=false)::Bool

Wrapper that runs the `compile_app` function asynchronosly and updates the progress bar.
"""
function wrapper_compile_app(dir_source::String, dir_target::String; test_run::Bool=false)::Bool
    out_stdout = stdout
    # global OUT = Pipe()
    # Base.link_pipe!(OUT; reader_supports_async = true, writer_supports_async = true)

    out_filename = get_log_filename()

    if test_run
        compile_task = @task compile_app_sim()
    else
        compile_task = @task compile_app(dir_source, dir_target)
    end

    out_file = open(out_filename, "a")
    redirect_stdio(;stdout=out_file)
    # buffer_redirect_task = @async write(OUT_buffer, OUT.in)
    
    schedule(compile_task)
    update_progress(compile_task, out_file, out_filename, out_stdout)

    redirect_stdio(stdout=out_stdout)
    close(out_file)
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

    # istaskdone(buffer_redirect_task) ||  Base.throwto(buffer_redirect_task, InterruptException())

    return errors_occured
end


"""
    update_progress(compile_task::Task, out_redirect_stream::IOStream, out_redirect_filename::String, out_stdout::Any)::Nothing

Analyzes the redirected STDOUT and updates the progress bar accordingly.
"""
function update_progress(compile_task::Task, out_redirect_stream::IOStream, out_redirect_filename::String, out_stdout::Any)::Nothing
    # pbar, job = setup_progress_bar()
    date_last = Dates.now()
    
    step_number = 0
    while(!istaskdone(compile_task))
        flush(out_redirect_stream)
        out_str = read(out_redirect_filename, String)

        if step_number >= 4
            if (Dates.now() - date_last) / Millisecond(1000) > 30
                print(".")
                date_last = Dates.now()
            end
        elseif (contains(out_str, "compiling base system image")) && step_number < 4
            print(out_stdout, @italic "Compiling.")
            step_number = 4
            date_last = Dates.now()
        elseif (contains(out_str, "bundled artifacts")) && step_number < 3
            println(out_stdout, @italic "Bundling.")
            step_number = 3
        elseif contains(out_str, "Activating new project") && step_number < 2
            println(out_stdout, @italic "Getting package.")
            step_number = 2
        elseif step_number < 1
            println(out_stdout, @italic "Setting up.")
            step_number = 1
        end

        # with(pbar) do
        #     redirect_stdio(stdout=out_stdout) do
        #         update!(job)
        #         render(pbar)
        #         flush(stdout)
        #     end
        # end
        sleep(1)
    end

    return nothing
end


"""
    install(dir::String=""; test_run::Bool=false, test_run_quick::Bool=false)::Nothing

Installs SpmImageTycoon.
"""
function install(dir::String=""; test_run::Bool=false, test_run_quick::Bool=false, interactive::Bool=true)::Nothing
    Term.Consoles.clear()
    println()
    print(Panel("Welcome to the installation of $(@bold "SpmImage Tycoon")."; width=66, justify=:center, style="gold1", box=:DOUBLE))
    println("\n\n")

    t = (dir == "") ? get_default_install_dir() : dir
    if interactive
        t = choose_install_dir(t)
    end
    d = ""

    if !test_run_quick
        Pkg.activate(temp=true)
        Pkg.add("SpmImageTycoon")
        d = get_package_dir()
    end

    println("\nInstalling into directory \"$t\".\nPlease have a beverage.\n")

    errors_occured = wrapper_compile_app(d, t, test_run=test_run || test_run_quick)

    if !errors_occured
        println("\n\n")
        println(Panel("Installation complete. Enjoy SpmImage Tycoon."; width = 66, justify = :center))
        println()
    end

    if !test_run_quick
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


function testr()
    stdout_ = stdout
    redirect_stdio(stdout=devnull) do
        println("test1")
        redirect_stdio(stdout=stdout_) do
            println("test2")
        end
    end
end

end

