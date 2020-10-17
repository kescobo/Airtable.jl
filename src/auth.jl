"""
     Credential(; api_key)

     A credentials and identity object for Trello.
If the api_key or api_token are not provided,
they will be read from the `AIRTABLE_KEY` environment variable.
Go to [Airtable account settings](https://airtable.com/account) 
to aquire your credentials.
"""
struct Credential
    api_key::String
end

function Credential(; api_key=ENV["AIRTABLE_KEY"])
    return Credential(api_key)
end

Base.show(io::IO, ::Credential) = println(io, "Airtable.Credential(<secrets>)")