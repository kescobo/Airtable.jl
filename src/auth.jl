"""
     Credential(; api_key)
     
A credential object for Airtable.
If the api_key or api_token are not provided,
they will be read from the `AIRTABLE_KEY` environment variable.
Go to [Airtable account settings](https://airtable.com/account) 
to aquire your credentials.

```jldoctest; setup = :(using Airtable)
# after running `export AIRTABLE_KEY=<api key>` in the shell
julia> key = Airtable.Credential()
Airtable.Credential(<secrets>)
```
"""
struct Credential
    api_key::String
end

load_preference(pref::AbstractString, default=nothing) = @load_preference(pref, default)
set_readwrite!(pat::AbstractString) = @set_preferences!("readwrite_pat"=> pat)
set_readonly!(pat::AbstractString) = @set_preferences!("readonly_pat"=> pat)

function set_readwrite!()
    print("Enter Read/Write Personal Access Token: ")
    pat = readline()
    set_readwrite!(pat)
    println("Set!")
end
function set_readonly!()
    print("Enter Read-only Personal Access Token: ")
    pat = readline()
    set_readonly!(pat)
    println("Set!")
end


function Credential(; api_key = load_preference("readwrite_pat",
                                load_preference("readonly_pat", 
                                Base.get(ENV, "AIRTABLE_KEY", nothing))))
    isnothing(api_key) && throw(ArgumentError("Environment does not have personal access token set. Must past api key directly"))
    return Credential(api_key)
end

Base.show(io::IO, ::Credential) = println(io, "Airtable.Credential(<secrets>)")

@testset "Credentials" begin
    key = Airtable.Credential()
    @test key isa Airtable.Credential
    @test key.api_key isa String
end