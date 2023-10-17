"""
     Credential(; token)
     
A credential object for Airtable.
If the token is not provided,
it will be read from, 

1. the Preferences key "readwrite_pat"
2. the Preferences key "readonly_pat"
3. the `AIRTABLE_KEY` environment variable.

Read the [Airtable docs](https://support.airtable.com/docs/airtable-api-key-deprecation-notice)
for more info on personal access tokens,
or go to [Airtable account settings](https://airtable.com/create/tokens) 
to aquire your personal access token(s).

```jldoctest; setup = :(using Airtable)
# with local preferences set, or after running `export AIRTABLE_KEY=<api key>` in the shell
julia> key = Airtable.Credential()
Airtable.Credential(<secrets>)
```

"""
struct Credential
    token::String
end


function Credential(; token = @load_preference("readwrite_pat",
                                @load_preference("readonly_pat", 
                                Base.get(ENV, "AIRTABLE_KEY", nothing))))
    isnothing(token) && throw(ArgumentError("Environment does not have personal access token set. Must past api key directly"))
    return Credential(token)
end

Base.show(io::IO, ::Credential) = println(io, "Airtable.Credential(<secrets>)")

@testset "Credentials" begin
    key = Airtable.Credential()
    @test key isa Airtable.Credential
    @test key.token isa String
end