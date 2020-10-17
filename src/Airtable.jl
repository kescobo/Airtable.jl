module Airtable

using HTTP
using JSON3

include("auth.jl")

"""
    Airtable.request(method::AbstractString, cred::Credential, path::AbstractString; query_kwargs...)

Make a request to the Airtable API.

Required arguments:

- `method`: one of "GET", "PUT", "POST", or "PATCH",
- `cred`: an [`Airtable.Credential`](@ref) containing your API key
- `path`: the endpoint of your Airtable base. See https://airtable.com/api for details

Query arguments are in the form of keyword arguments.
"""
function request(method::AbstractString, cred::Credential, path::AbstractString; query_kwargs...)
    method in ("GET", "PUT", "POST", "PATCH") || error("Invalid API method: $method")
    
    query = ["api_key"=> cred.api_key]
    for (key, value) in query_kwargs
        isempty(value) && continue
        push!(query, string(key) => string(value))
    end
    uri = HTTP.URI(host="api.airtable.com", scheme="https", path=path, query=query)
    resp = HTTP.request(method, uri)
    return JSON3.read(String(resp.body))
end

function query(cred::Credential, path::AbstractString; query_kwargs...)
    records = []
    req = airtable_request("GET", cred, path; query_kwargs...)
    append!(records, req.records)
    while haskey(req, :offset) && length(records) < 2200
        @info "Making another request"
        req = airtable_request("GET", cred, path; offset=req.offset, query_kwargs...)
        append!(records, req.records)
        sleep(0.250)
    end
    return records
end

end
