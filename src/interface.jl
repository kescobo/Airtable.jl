"""
    Airtable.request(method::AbstractString, cred::Credential, path::AbstractString; query_kwargs...)

Make a request to the Airtable API.

Required arguments:

- `method`: one of "GET", "PUT", "POST", or "PATCH",
- `cred`: an [`Airtable.Credential`](@ref) containing your API key
- `path`: the endpoint of your Airtable base. See https://airtable.com/api for details

Query parameters are in the form of keyword arguments,
eg `filterByFormla = "NOT({Name} = '')", maxRecords=2`.
See Airtable API reference for more information.
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

"""
    Airtable.get(cred::Credential, path::AbstractString; query_kwargs...)

Shorthand for [`Airtable.request("GET", cred, path; query_kwargs)`](@ref `Airtable.request`)
"""
get(cred::Credential, path::AbstractString; query_kwargs...) = request("GET", cred, path; query_kwargs...)

"""
    Airtable.put(cred::Credential, path::AbstractString; query_kwargs...)

Shorthand for [`Airtable.request("PUT", cred, path; query_kwargs)`](@ref `Airtable.request`)
"""
put(cred::Credential, path::AbstractString; query_kwargs...) = request("PUT", cred, path; query_kwargs...)

"""
    Airtable.post(cred::Credential, path::AbstractString; query_kwargs...)

Shorthand for [`Airtable.request("POST", cred, path; query_kwargs)`](@ref `Airtable.request`)
"""
post(cred::Credential, path::AbstractString; query_kwargs...) = request("PUT", cred, path; query_kwargs...)

"""
    Airtable.patch(cred::Credential, path::AbstractString; query_kwargs...)

Shorthand for [`Airtable.request("PATCH", cred, path; query_kwargs)`](@ref `Airtable.request`)
"""
patch(cred::Credential, path::AbstractString; query_kwargs...) = request("PUT", cred, path; query_kwargs...)

"""
    Airtable.query(cred::Credential, path::AbstractString; query_kwargs...)

Shorthand for a "GET" request that handles continuation and rate-limiting.

The Airtable API will return a maximum of 100 records per requests,
and only allows 5 requests / sec. 
This function uses the `offset` field returned as part of a requst
that does not contain all possible records to make additional requests
after pausing 0.21 seconds in between.

Required arguments:

- `cred`: an [`Airtable.Credential`](@ref) containing your API key
- `path`: the endpoint of your Airtable base. See https://airtable.com/api for details

Query parameters are in the form of keyword arguments,
eg `filterByFormla = "NOT({Name} = '')", maxRecords=2`.
See Airtable API reference for more information.
"""
function query(cred::Credential, path::AbstractString; query_kwargs...)
    req = get(cred, path; query_kwargs...)
    records = req.records
    append!(records, req.records)
    while haskey(req, :offset)
        @info "Making another request with offset $(req.offset)"
        req = get(cred, path; offset=req.offset, query_kwargs...)
        append!(records, req.records)
        sleep(0.210)
    end
    return records
end