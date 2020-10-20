```@meta
CurrentModule = Airtable
```

```@example api
```
# Airtable

An (unofficial) API for interacting with the [Airtable](http://www.airtable.com) API.

```@index
Order   = [:type, :function]
```

## Using this package

This package is a very thin wrapper around the Airtable REST API,
using [`HTTP.jl`](https://juliaweb.github.io/HTTP.jl/stable/) to do the hard stuff.
No types or methods are exported,
mostly because I didn't want to think too hard about naming them.

This documentation should be used in close conjuntion with the airtable API
documentation, which is generated automatically for you using your actual tables
(see below).

Most functions require 4 parts:

1. a [`Credential`](@ref), which stores your [API key](@ref)
2. a [Base ID](@ref)
3. [a `tablename`](@ref Tablename) - which refers to the specific table from your base
4. an [API query](@ref), in the form of keyword arguments

### API key

To obtain your API key, go to your [account settings page](https://airtable.com/account)
and click on the "generate API key" button.
If you previously made a key, you can regenerate it, or just copy the one that's there.

![Get airtable API key]()

You can then create an [`Airtable.Credential`](@ref) using that key as a string,
or set it as an environmental variable (`AIRTABLE_KEY` by default).

```@docs
Credential
```

### Base ID

Open your airtable base, click the help button in the upper right,
and then click "API documentation".
Airtable generates documentation for your sepecific base -
near the top you should see a sentence like the follwing,
with a different alphanumeric sequence for your base:

> The ID of this base is appphImnhJO8AXmmo

It will also appear in the url of the base documentation.
For example, the `Test` base for this repo has the url `https://airtable.com/appphImnhJO8AXmmo/api/docs`.

### Tablename

Within each base, you may have multiple tables.
The `tablename` argument in the following functions is just a string
with the table name, eg `"Table 1"`.

### API Query

Use keyword arguments to add commponents to the API request body.
For example, if you want a `GET` request to only contain the `Name` field,
you could include `; fields=["Name"]` keyword argument to the [`get`](@ref)
function.

## Interface

The primary function is [`Airtable.request`](@ref),
which contains all of the components for building an API query
and parses the returned data with [`JSON3.jl`](https://github.com/quinnj/JSON3.jl).

The following examples use [this airtable base](https://airtable.com/shrx4BWLV1HurniFD),
which has the ID "appphImnhJO8AXmmo", and the API key described above.
To run this code, you will need to substitute the API key and ID
from your own base.
These examples only scratch the surface -
much more information is available in the API documentation for your own base.

```@docs
request
```

### Retrieve records

```jldoctest api; setup = :(using Airtable)
julia> key=Airtable.Credential();

julia> req1 = Airtable.request("GET", key, "appphImnhJO8AXmmo", "Table 1"; maxRecords=2)
JSON3.Object{Base.CodeUnits{UInt8, String}, Vector{UInt64}} with 1 entry:
  :records => JSON3.Object[{…

julia> req1.records
2-element JSON3.Array{JSON3.Object, Base.CodeUnits{UInt8, String}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}}:
 {
            "id": "recMc1HOSIxQPJyyc",
        "fields": {
                       "Name": "Record 1",
                      "Notes": "Some notes",
                     "Status": "Todo"
                  },
   "createdTime": "2020-10-16T21:04:11.000Z"
}
 {
            "id": "recMwT4P4tKlSLJoH",
        "fields": {
                       "Name": "Record 2",
                      "Notes": "Other notes",
                     "Status": "In progress"
                  },
   "createdTime": "2020-10-16T21:04:11.000Z"
}

julia> req2 = Airtable.request("GET", key, "appphImnhJO8AXmmo", "Table 1"; filterByFormula="Status = 'Done'")
JSON3.Object{Base.CodeUnits{UInt8, String}, Vector{UInt64}} with 1 entry:
  :records => JSON3.Object[{…

julia> req2.records
1-element JSON3.Array{JSON3.Object, Base.CodeUnits{UInt8, String}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}}:
 {
            "id": "recSStgr3yJnQc2Wg",
        "fields": {
                       "Name": "Record 3 ",
                     "Status": "Done"
                  },
   "createdTime": "2020-10-16T21:04:11.000Z"
}
```

### Retrieving lots of records

The airtable API will only return 100 records per request[^1],
and only allows 5 requests/sec.
To facilitate retrieving lots of records,
You can use the [`Airtable.query`](@ref) function.

```@docs
query
```

[^1]: This is the default, you can change this with the `pageSize` parameter,
      but 100 is the maximum.

### Add/Update Records

I haven't actually figured this out yet 🤔.
If you want to help, let me know!
