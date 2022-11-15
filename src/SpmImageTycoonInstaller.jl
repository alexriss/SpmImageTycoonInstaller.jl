module SpmImageTycoonInstaller

using PackageCompiler
using Pkg

export install


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
    println("Please choose the installation directory (make sure you have sufficient write privileges).")
    println("Default directory is \"$dir\".")
    println("Press ENTER to keep this default.")
    
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
        if isdir(dir)
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
    install(dir::String=""; test_run::Bool=false)::Nothing

Interactively installs SpmImageTycoon.
"""
function install(dir::String=""; test_run::Bool=false, test_run_quick::Bool=false)::Nothing
    println("Welcome to the installation of SpmImageTycoon.\n")

    t = (dir == "") ? get_default_install_dir() : dir
    t = choose_install_dir(t)

    if !test_run_quick
        Pkg.activate(temp=true)
        Pkg.add("SpmImageTycoon")
        d = get_package_dir()
    end

    println("\nInstalling into directory \"$t\". Please have a beverage.")
    if !test_run && !test_run_quick
        create_app(d, t, incremental=false, filter_stdlibs=true, include_lazy_artifacts=true, force=true)
    end

    println("\nInstallation complete. Enjoy SpmImageTycoon.")
    readline()

    return nothing
end


"""Entry point for sysimage/binary created by PackageCompiler.jl"""
function julia_main()::Cint
    install()
    return 0
end

end
