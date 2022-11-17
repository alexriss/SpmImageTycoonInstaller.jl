using SpmImageTycoonInstaller
using Suppressor
using Test

@testset "SpmImageTycoonInstaller.jl" begin
    @test contains(SpmImageTycoonInstaller.get_default_install_dir(), "SpmImageTycoon")

    out = Pipe()
    err = Pipe()
    res = @capture_out install(;test_run=true, test_run_quick=true, interactive=false)
    
    @test contains(res, "beverage")
    @test contains(res, "complete")
    @test contains(res, "Enjoy")
end
