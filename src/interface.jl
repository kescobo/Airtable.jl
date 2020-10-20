"""
    Airtable.request(method::AbstractString, cred::Credential, baseid::AbstractString; query_kwargs...)

Make a request to the Airtable API.

Required arguments:

- `method`: one of "GET", "PUT", "POST", or "PATCH",
- `cred`: an [`Airtable.Credential`](@ref) containing your API key
- `baseid`: the endpoint of your Airtable base. See https://airtable.com/api for details
- `tablename`: The name of the table (view) for the query

Query parameters are in the form of keyword arguments,
eg `filterByFormla = "NOT({Name} = '')", maxRecords=2`.
See Airtable API reference for more information.
"""
function request(method::AbstractString, cred::Credential, baseid::AbstractString, tablename::AbstractString; query_kwargs...)
    method in ("GET", "PUT", "POST", "PATCH") || error("Invalid API method: $method")
    
    query = ["api_key"=> cred.api_key]
    for (key, value) in query_kwargs
        isempty(value) && continue
        push!(query, string(key) => string(value))
    end
    path = joinpath("/", API_VERSION, baseid, HTTP.escapeuri(tablename))
    uri = HTTP.URI(host="api.airtable.com", scheme="https", path=path, query=query)
    resp = HTTP.request(method, uri)
    return JSON3.read(String(resp.body))
end

"""
    Airtable.get(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)

Shorthand for [`Airtable.request("GET", cred, baseid, tablename; query_kwargs)`](@ref Airtable.request)
"""
get(cred::Credential, baseid::AbstractString, tablename; query_kwargs...) = request("GET", cred, baseid, tablename; query_kwargs...)

"""
    Airtable.put(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)

Shorthand for [`Airtable.request("PUT", cred, baseid, tablename; query_kwargs)`](@ref Airtable.request)
"""
put(cred::Credential, baseid::AbstractString, tablename; query_kwargs...) = request("PUT", cred, baseid, tablename; query_kwargs...)

"""
    Airtable.post(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)

Shorthand for [`Airtable.request("POST", cred, baseid, tablename; query_kwargs)`](@ref Airtable.request)
"""
post(cred::Credential, baseid::AbstractString, tablename; query_kwargs...) = request("PUT", cred, baseid, tablename; query_kwargs...)

"""
    Airtable.patch(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)

Shorthand for [`Airtable.request("PATCH", cred, baseid, tablename; query_kwargs)`](@ref Airtable.request)
"""
patch(cred::Credential, baseid::AbstractString, tablename; query_kwargs...) = request("PUT", cred, baseid, tablename; query_kwargs...)

"""
    Airtable.query(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)

Shorthand for a "GET" request that handles continuation and rate-limiting.

The Airtable API will return a maximum of 100 records per requests,
and only allows 5 requests / sec. 
This function uses the `offset` field returned as part of a requst
that does not contain all possible records to make additional requests
after pausing 0.21 seconds in between.

Required arguments:

- `cred`: an [`Airtable.Credential`](@ref) containing your API key
- `baseid`: the endpoint of your Airtable base. See https://airtable.com/api for details
- `tablename`: the name of the table in your base (eg `"Table 1"`)

Query parameters are in the form of keyword arguments,
eg `filterByFormla = "NOT({Name} = '')", maxRecords=2`.
See Airtable API reference for more information.
"""
function query(cred::Credential, baseid::AbstractString, tablename::AbstractString; query_kwargs...)
    req = get(cred, baseid, tablename; query_kwargs...)
    records = req.records
    append!(records, req.records)
    while haskey(req, :offset)
        @info "Making another request with offset $(req.offset)"
        req = get(cred, baseid, tablename; offset=req.offset, query_kwargs...)
        append!(records, req.records)
        sleep(0.210)
    end
    return records
end