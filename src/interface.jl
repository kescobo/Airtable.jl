struct AirBase
    id::String
end

id(bs::AirBase) = bs.id
path(bs::AirBase) = joinpath("/", API_VERSION, id(bs))
Base.show(io::IO, bs::AirBase) = println(io, "Airtable Base '$(id(bs))'")

struct AirTable
    id::String
    base::AirBase
end

id(tab::AirTable) = tab.id
base(tab::AirTable) = tab.base
path(tab::AirTable) = joinpath(path(base(tab)), id(tab))
Base.show(io::IO, tab::AirTable) = print(io, "AirTable(\"$(id(tab))\")")


struct AirRecord
    id::String
    table::AirTable
    fields::NamedTuple

    function AirRecord(id, table, fields)
        new(id, table, NamedTuple(fields))
    end
end

AirRecord(; id, table, fields=Dict()) = AirRecord(id, table, fields)

id(rec::AirRecord) = rec.id
table(rec::AirRecord) = rec.table
base(rec::AirRecord) = base(table(rec))
fields(rec::AirRecord) = rec.fields
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

    while haskey(resp, :offset)
        @info "Making another request with offset $(resp.offset)"
        resp = get(cred, path(tab); offset=resp.offset, query_kwargs...)
        append!(records, map(rec-> AirRecord(rec.id, tab, rec.fields), resp.records))
        sleep(0.210)
    end
    return records
end

query(cred::Credential, tab::AirTable; query_kwargs...) = query(cred, id(base(tab)), id(tab); query_kwargs...)
query(tab::AirTable; query_kwargs...) = query(Credential(), tab; query_kwargs...)

get(cred::Credential, rec::AirRecord) = AirRecord(get(cred, path(rec)), table(rec))
get(rec::AirRecord) = get(Credential(), rec)


post!(cred::Credential, tab::AirTable, rec::AirRecord) = post!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write(rec))
post!(cred::Credential, tab::AirTable, recs::IO) = post!(cred, path(tab), ["Content-Type" => "application/json"], JSON3.write(JSON3.read(recs)))

post!(tab::AirTable, rec::AirRecord) = records(tab, post!(Credential(), path(tab), ["Content-Type" => "application/json"], JSON3.write(rec)).records)
post!(tab::AirTable, recs::IO) = records(tab, post!(Credential(), path(tab), ["Content-Type" => "application/json"], JSON3.write(JSON3.read(recs))).records)

delete!(cred::Credential, rec::AirRecord) = delete!(cred, path(rec))
delete!(rec::AirRecord) = delete!(Credential(), rec)

patch!(cred::Credential, rec::AirRecord) = patch!(cred, path(rec), ["Content-Type" => "application/json"], JSON3.write(rec))
patch!(rec::AirRecord) = patch!(Credential(), rec)
patch!(cred::Credential, rec::AirRecord, fields::NamedTuple) = patch!(cred, path(rec), ["Content-Type" => "application/json"], string("""{ "fields": """, JSON3.write(fields), " }"))
patch!(rec::AirRecord, fields::NamedTuple) = patch!(Credential(), rec, fields)

records(tab::AirTable, resp::JSON3.Array) = map(resp-> AirRecord(resp.id, tab, resp.fields), resp)

Base.getindex(rec::AirRecord, k::Symbol) = fields(rec)[k]
Base.keys(rec::AirRecord) = keys(fields(rec))