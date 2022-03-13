"""
    Airtable.request(method::AbstractString, cred::Credential, path[, headers = []]; query_kwargs...)

Make a request to the Airtable API.

Required arguments:

- `method`: one of "GET", "PUT", "POST", or "PATCH",
- `cred`: an [`Airtable.Credential`](@ref) containing your API key
- `path`: This often takes the form `<base id>/<table name>` or `<base id>/<table name>/<record id>`

Optional arguments:

- `headers`: a vector of `Pair`s representing header arguments (the things noted in the airtable API as -H arguments).
  Eg. `["Content-Type" => "application/json"]`

Query parameters are in the form of keyword arguments,
eg `filterByFormla = "NOT({Name} = '')", maxRecords=2`.
See [Airtable API](https://airtable.com/api) reference for more information.
"""
function request(method::AbstractString, cred::Credential, path, headers=[], body=nothing; query_kwargs...)
    method in ("GET", "PUT", "POST", "PATCH", "DELETE") || error("Invalid API method: $method")
    
    headers = append!(["Authorization"=> "Bearer $(cred.api_key)"], headers)
    query = []
    for (key, value) in query_kwargs
        isempty(value) && continue
        push!(query, string(key) => string(value))
    end
    path = joinpath("/", API_VERSION, joinpath(HTTP.escapeuri.(splitpath(path))))
    uri = HTTP.URI(; host="api.airtable.com", scheme="https", path, query)
    resp = isnothing(body) ? HTTP.request(method, uri, headers) : 
                             HTTP.request(method, uri, headers, body)
    return JSON3.read(String(resp.body))
end

"""
    Airtable.get(cred::Credential, path[, headers=[], body=nothing]; query_kwargs...)

Shorthand for [`Airtable.request("GET", cred, path[, headers, body]; query_kwargs)`](@ref Airtable.request)
"""
get(cred::Credential, path, headers=[], body=nothing; query_kwargs...) = request("GET", cred, path, headers, body; query_kwargs...)

"""
    Airtable.put(cred::Credential, path[, headers=[], body=nothing]; query_kwargs...)

Shorthand for [`Airtable.request("PUT", cred, path[, headers, body]; query_kwargs)`](@ref Airtable.request)
"""
put(cred::Credential, path, headers=[], body=nothing; query_kwargs...) = request("PUT", cred, path, headers, body; query_kwargs...)

"""
    Airtable.post(cred::Credential, path[, headers=[], body=nothing]; query_kwargs...)

Shorthand for [`Airtable.request("POST", cred, path[, headers, body]; query_kwargs)`](@ref Airtable.request)
"""
post(cred::Credential, path, headers=[], body=nothing; query_kwargs...) = request("POST", cred, path, headers, body; query_kwargs...)

"""
    Airtable.patch(cred::Credential, path[, headers=[], body=nothing]; query_kwargs...)

Shorthand for [`Airtable.request("PATCH", cred, path[, headers, body]; query_kwargs)`](@ref Airtable.request)
"""
patch(cred::Credential, path, headers=[], body=nothing; query_kwargs...) = request("PATCH", cred, path, headers, body; query_kwargs...)

"""
    Airtable.delete(cred::Credential, path[, headers=[], body=nothing]; query_kwargs...)

Shorthand for [`Airtable.request("DELETE", cred, path[, headers, body]; query_kwargs)`](@ref Airtable.request)
"""
delete(cred::Credential, path, headers=[], body=nothing; query_kwargs...) = request("DELETE", cred, path, headers, body; query_kwargs...)

"""
    Airtable.query(cred::Credential, baseid, tablename; query_kwargs...)

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

If you know the exact record id, pass that as a fourth positional argument
"""
function query(cred::Credential, baseid, tablename; query_kwargs...)
    path = joinpath(baseid, tablename)
    req = get(cred, path; query_kwargs...)
    records = Any[req.records...]
    append!(records, req.records)
    while haskey(req, :offset)
        @info "Making another request with offset $(req.offset)"
        req = get(cred, path; offset=req.offset, query_kwargs...)
        append!(records, req.records)
        sleep(0.210)
    end
    return records
end

function record(cred, baseid, tablename, record)
    path = joinpath(baseid, tablename, record)
    return get(cred, path)
end

function delete_record(cred, baseid, tablename, record)
    path = joinpath(baseid, tablename, record)
    return delete(cred, path)
end
