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

function Credential(; api_key=Base.get(ENV, "AIRTABLE_KEY", nothing))
    isnothing(api_key) && throw(ArgumentError("Environment does not have `$AIRTABLE_KEY` set. Must past api key directly"))
    return Credential(api_key)
end

Base.show(io::IO, ::Credential) = println(io, "Airtable.Credential(<secrets>)")

@testset "Credentials" begin
    key = Airtable.Credential()
    @test key isa Airtable.Credential
    @test key.api_key isa String
end