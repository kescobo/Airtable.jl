# Low-level interface

`Airtable.jl` has wrappers around several of the functions from `HTTP.jl`.
These are intended to work approximately the same way,
with the following exceptions:

1. They require that you pass a `Credential` containing your API key
2. Rather than returning the raw response, it reads the response into a `JSON3` type.
3. Keyword arguments are converted into query parameters.

## Interface

The primary function is [`Airtable.request`](@ref),
which contains all of the components for building an API query
and parses the returned data with [`JSON3.jl`](https://github.com/quinnj/JSON3.jl).

The following examples use [this airtable base](https://airtable.com/shrx4BWLV1HurniFD),
which has the ID "appphImnhJO8AXmmo", and the API key [described here](@ref apikey).
To run this code, you will need to substitute the API key and ID
from your own base.
These examples only scratch the surface -
much more information is available in the API documentation for your own base.

```@docs
request
```

### Retrieve records

```julia-repl
julia> key=Airtable.Credential();

julia> req1 = Airtable.request("GET", key, "appphImnhJO8AXmmo/Table 1"; maxRecords=2)
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

julia> req2 = Airtable.request("GET", key, "appphImnhJO8AXmmo/Table 1"; filterByFormula="Status = 'Done'")
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

### Add a record

If you need to pass headers,
they can be passed as a 4th positional argument.

```julia-repl
julia> Airtable.request("POST", key, "appphImnhJO8AXmmo/Table 1",
                              ["Content-Type" => "application/json"], # this is appended to the "Authorization" header, handled by `key`
                              """
                              {
                              "records": [
                                          {
                                             "fields": {
                                                            "Name": "TEST1",
                                                            "Notes": "Some note",
                                                         "Status": "Todo"
                                                      }
                                          },
                                          {
                                             "fields": {
                                                            "Name": "TEST2",
                                                            "Notes": "Other note",
                                                         "Status": "Done"
                                                      }
                                          }
                                       ]
                              }""")
```

You can also use `JSON3` to convert julia types. Eg, the above could have been

```julia-repl
julia> records = (; records = [
                       (; fields= (; Name="TEST1", Notes="Some note", Status="Todo")),
                       (; fields= (; Name="TEST2", Notes="Other note", Status="Done"))
                       ]
                   );

julia> body = JSON3.write(records);

julia> Airtable.request("POST", key, "appphImnhJO8AXmmo/Table 1", ["Content-Type" => "application/json"], body)
```
