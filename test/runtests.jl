using SpmImageTycoonInstaller
using Test

@testset "SpmImageTycoonInstaller.jl" begin
    @test contains(SpmImageTycoonInstaller.get_default_install_dir(), "SpmImageTycoon")

    out = Pipe()
    err = Pipe()
    redirect_stdio(;stdout=out, stderr=err) do
        # install(;test_run=true, test_run_quick=true)
    end
    res = read(out, String)
    #@show res
    #@test contains(res, "beverage")
    #@show read(err, String)
    
end
