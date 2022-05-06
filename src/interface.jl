"""
    AirBase(id::String)

A wrapper for an [Airtable Base](https://support.airtable.com/hc/en-us/articles/202576419-Introduction-to-Airtable-bases),
containing its unique identifier. 
The ID can be identified from the URL of the base (the part right after `airtable.com`),
or by clicking `HELP -> API documentation` from within your base.
"""
struct AirBase
    id::String
end

"""
    id(::AirBase)

Accessor function for a base identifier.
"""
id(bs::AirBase) = bs.id

"""
    path(::AirBase)

Accessor function for the API path to the base.
This is just the base ID preceded by the API version number (only `v0` for now).

```jldoctest
julia> b = AirBase("appphImnhJO8AXmmo");

julia> path(b)
"/v0/appphImnhJO8AXmmo"
```
"""
path(bs::AirBase) = joinpath("/", API_VERSION, id(bs))
Base.show(io::IO, bs::AirBase) = println(io, "Airtable Base '$(id(bs))'")

"""
    AirTable(id::String, ::AirBase)

A wrapper for an [Airtable Table](https://support.airtable.com/hc/en-us/articles/360021333094-Getting-started-tables-records-and-fields),
containing its unique identifier or name, and parent [`AirBase`](@ref). 
"""
struct AirTable
    id::String
    base::AirBase
end

"""
    id(::AirTable)

Accessor function for a table identifier.
"""
id(tab::AirTable) = tab.id

"""
    base(::AirTable)

Accessor function for the parent base of a table
"""
base(tab::AirTable) = tab.base

"""
    path(::AirTable)

Accessor function for the API path to the table.
This is just the table ID preceded by the [path to the base](@ref `path(::AirBase)`)

```jldoctest
julia> b = AirBase("appphImnhJO8AXmmo");

julia> tab = AirTable("Table 1", b);

julia> path(tab)
"/v0/appphImnhJO8AXmmo/Table 1"
```
"""
path(tab::AirTable) = joinpath(path(base(tab)), id(tab))
Base.show(io::IO, tab::AirTable) = print(io, "AirTable(\"$(id(tab))\")")


"""
    AirRecord(id::String, table::AirTable, fields::NamedTuple)

A wrapper for an [Airtable Record](https://support.airtable.com/hc/en-us/articles/360021333094-Getting-started-tables-records-and-fields),
containing its unique identifier, parent [`AirTable`](@ref),
and values for any stored fields in a NamedTuple.

Typically, you won't crete these on your own, but they will be returned from API queries.

Field values can be accessed using [`getindex`](@ref `Base.getindex(::AirRecord, ::Symbol)`).
"""
struct AirRecord
    id::String
    table::AirTable
    fields::NamedTuple

    function AirRecord(id, table, fields)
        new(id, table, NamedTuple(fields))
    end
end

AirRecord(; id, table, fields=Dict()) = AirRecord(id, table, fields)

"""
    id(::AirRecord)

Accessor function for a record identifier.
"""
id(rec::AirRecord) = rec.id

"""
    table(::AirRecord)

Accessor function the the parent [`AirTable`](@ref) of a record.
"""
table(rec::AirRecord) = rec.table

"""
    base(::AirRecord)

Accessor function the the parent [`AirBase`](@ref) of a record.
"""
base(rec::AirRecord) = base(table(rec))

"""
    base(::AirRecord)

Accessor function the the fields within an [`AirRecord`](@ref).
Individual values can also be accessed with [`getindex`](@ref `Base.getindex(::AirRecord, ::Symbol)`).
"""
fields(rec::AirRecord) = rec.fields


"""
    path(::AirTable)

Accessor function for the API path to the table.
This is just the table ID preceded by the [path to the table](@ref `path(::AirTable)`)
"""
path(rec::AirRecord) = joinpath(path(table(rec)), id(rec))

JSON3.write(rec::AirRecord) = string("""{ "id": "$(id(rec))", "fields": """, JSON3.write(fields(rec)), "}")
AirRecord(rec::JSON3.Object, tab::AirTable) = AirRecord(rec.id, tab, rec.fields)

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
    tab = AirTable(tablename, AirBase(baseid))
    resp = get(cred, path(tab); query_kwargs...)
    records = map(rec-> AirRecord(rec.id, tab, rec.fields), resp.records)

    if haskey(resp, :offset)
        prog = ProgressUnknown("Making additional requests:", spinner=true)
        while haskey(resp, :offset)
            ProgressMeter.next!(prog)
            resp = get(cred, path(tab); offset=resp.offset, query_kwargs...)
            append!(records, map(rec-> AirRecord(rec.id, tab, rec.fields), resp.records))
        end
        ProgressMeter.finish!(prog)
    end

    return records
end

query(cred::Credential, tab::AirTable; query_kwargs...) = query(cred, id(base(tab)), id(tab); query_kwargs...)
query(tab::AirTable; query_kwargs...) = query(Credential(), tab; query_kwargs...)

get(cred::Credential, rec::AirRecord) = AirRecord(get(cred, path(rec)), table(rec))
get(rec::AirRecord) = get(Credential(), rec)

_extract_records(tab::AirTable, resp) = map(rec-> AirRecord(rec.id, tab, rec.fields), resp.records)
_extract_record(tab::AirTable, rec) = AirRecord(rec.id, tab, rec.fields)

function post!(cred::Credential, tab::AirTable, rec::AirRecord)
    resp = post!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write(rec))
    return _extract_record(tab, resp)
end

function post!(cred::Credential, tab::AirTable, recs::IO)
    resp = post!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write(JSON3.read(recs)))
    return _extract_records(tab, resp)
end

function post!(cred::Credential, tab::AirTable, rec::NamedTuple)
    resp = post!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write((; fields=rec)))
    return _extract_record(tab, resp)
end


function post!(cred::Credential, tab::AirTable, recs::Vector{<:NamedTuple})
    resps = AirRecord[]
    for recpart in Iterators.partition(recs, 10)
        topost = (; records = [(; fields = nt) for nt in recpart])
        resp = post!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write(topost))
        append!(resps, _extract_records(tab, resp))
    end
    return resps
end

post!(tab::AirTable, rec::AirRecord)           = post!(Credential(), tab, rec)
post!(tab::AirTable, recs::IO)                 = post!(Credential(), tab, recs)
post!(tab::AirTable, rec::NamedTuple)          = post!(Credential(), tab, rec)
post!(tab::AirTable, recs::Vector{<:NamedTuple}) = post!(Credential(), tab, recs)

delete!(cred::Credential, rec::AirRecord) = delete!(cred, path(rec))
delete!(rec::AirRecord) = delete!(Credential(), rec)

patch!(cred::Credential, rec::AirRecord) = _extract_record(table(rec), patch!(cred, path(rec), ["Content-Type" => "application/json"], JSON3.write(rec)))
patch!(cred::Credential, rec::AirRecord, fields::NamedTuple) = _extract_record(table(rec), patch!(cred, path(rec), ["Content-Type" => "application/json"],  JSON3.write((; fields))))

function patch!(cred::Credential, tab::AirTable, recs::Vector{<:AirRecord})
    resps = AirRecord[]
    for recpart in Iterators.partition(recs, 10)
        resp = patch!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write((; records = [
            (; id=id(rec), fields=fields(rec)) for rec in recpart
        ])))
        append!(resps, _extract_records(tab, resp))
    end
    return resps
end

function patch!(cred::Credential, tab::AirTable, recs::Vector{<:AirRecord}, fields::Vector{<:NamedTuple})
    length(recs) == length(fields) || throw(ArgumentError("Lengths of records vector and fields vector must be the same"))
    patch!(cred, tab, [AirRecord(Airtable.id(rec), tab, fs) for (rec, fs) in zip(recs, fields)])
end


patch!(rec::AirRecord) = patch!(Credential(), rec)
patch!(rec::AirRecord, fields::NamedTuple) = patch!(Credential(), rec, fields)
patch!(tab::AirTable, recs::Vector{<:AirRecord}) = patch!(Credential(), tab, recs)
patch!(tab::AirTable, recs::Vector{<:AirRecord}, fields::Vector{<:NamedTuple}) = patch!(Credential(), tab, recs, fields)


Base.getindex(rec::AirRecord, k::Symbol) = fields(rec)[k]
Base.keys(rec::AirRecord) = keys(fields(rec))
Base.haskey(rec::AirRecord, key::Symbol) = key ∈ keys(rec)
Base.get(rec::AirRecord, key, default) = haskey(rec, key) ? rec[key] : default
