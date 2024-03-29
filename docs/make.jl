using Airtable
using Documenter

makedocs(;
    modules=[Airtable],
    authors="Kevin Bonham, PhD <kevbonham@gmail.com> and contributors",
    repo="https://github.com/kescobo/Airtable.jl/blob/{commit}{path}#L{line}",
    sitename="Airtable.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://kescobo.github.io/Airtable.jl",
        assets=String[],
    ),
    pages=[
        "Home"                => "index.md",
        "Interface"           => "interface.md",
        "Low-level interface" => "low-level.md",
    ],
)

deploydocs(;
    repo="github.com/kescobo/Airtable.jl",
    devbranch="main",
    push_preview=true,
)
