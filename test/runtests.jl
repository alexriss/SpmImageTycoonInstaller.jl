using SpmImageTycoonInstaller
using Suppressor
using Test

@testset "SpmImageTycoonInstaller.jl" begin
    @test contains(SpmImageTycoonInstaller.get_default_install_dir(), "SpmImageTycoon")

    out = Pipe()
    err = Pipe()
    res = @capture_out install(;test_run=true, interactive=false)
    
    @test contains(res, "beverage")

    @test contains(res, "Start Menu")
    @test contains(res, "Setting up.")
    @test contains(res, "Getting package.")
    @test contains(res, "Bundling.")
    @test contains(res, "Compiling.")

    @test contains(res, "complete")
    @test contains(res, "Enjoy")

end
