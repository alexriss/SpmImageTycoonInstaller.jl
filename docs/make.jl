using SpmImageTycoonInstaller
using Documenter

DocMeta.setdocmeta!(SpmImageTycoonInstaller, :DocTestSetup, :(using SpmImageTycoonInstaller); recursive=true)

makedocs(;
    modules=[SpmImageTycoonInstaller],
    authors="Alex Riss",
    repo="https://github.com/alexriss/SpmImageTycoonInstaller.jl/blob/{commit}{path}#{line}",
    sitename="SpmImageTycoonInstaller.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://alexriss.github.io/SpmImageTycoonInstaller.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/alexriss/SpmImageTycoonInstaller.jl",
    devbranch="master",
)
