# Interface

A number of functions have been added to make it a bit easier
to interact with the Airtable API.
These are built on top of the [low-level interface](@ref lowlevel),
which is just a thin wrapper around the `HTTP.jl` functions.

## [`Airtable.query`](@ref) function

If you are interested in retrieving records,
your best bet is the [`Airtable.query`](@ref) function.
Because the airtable API will only return 100 records per request[^1],
and only allows 5 requests/sec,
`query()` automatically handles the "paging", pausing for 0.2 seconds
in between each request so that you won't hit your limit.

At minimum, `query()` requires an [`AirTable`](@ref) (note the capital 'T'),
which requires that you know the [base name](@ref baseid)
and table name for your air table.
If you only pass the table, you will retrieve all of the records
for that table.

```julia-repl
julia> tab = AirTable("Table 1", AirBase("appphImnhJO8AXmmo"))
AirTable("Table 1")

julia> Airtable.query(tab)
3-element Vector{AirRecord}:
 AirRecord("recMc1HOSIxQPJyyc", AirTable("Table 1"), (Name = "Record 1", Notes = "Keep this\n", Status = "Todo", Keep = true))
 AirRecord("recMwT4P4tKlSLJoH", AirTable("Table 1"), (Name = "Record 2", Notes = "Also keep this", Status = "In progress", Keep = t
rue))
 AirRecord("recSStgr3yJnQc2Wg", AirTable("Table 1"), (Name = "Record 3", Status = "Done", Keep = true))
```

Here, the [`Credential`](@ref) is used automatically from the `AIRTABLE_KEY`
environmental variable.
As you can see, unlike the low-level functions that return
`JSON3.Object`s, `query()` returns [`AirRecord`s](@ref Airtable.AirRecord)

You may also pass additional query parameters (passed as keyword arguments) to filter,
or otherwise modify the query.

```julia-repl
julia> Airtable.query(tab; filterByFormula="{Status} = 'Todo'")
1-element Vector{AirRecord}:
 AirRecord("recMc1HOSIxQPJyyc", AirTable("Table 1"), (Name = "Record 1", Notes = "Keep this\n", Status = "Todo", Keep = true))

julia> Airtable.query(tab; filterByFormula="{Status} != 'Todo'")
2-element Vector{AirRecord}:
 AirRecord("recMwT4P4tKlSLJoH", AirTable("Table 1"), (Name = "Record 2", Notes = "Also keep this", Status = "In progress", Keep = t
rue))
 AirRecord("recSStgr3yJnQc2Wg", AirTable("Table 1"), (Name = "Record 3", Status = "Done", Keep = true))
```

For more information about usable query parameters, refer to the airtable documentation.

```@docs
AirBase
AirTable
AirRecord
query
```



[^1]: This is the default, you can change this with the `pageSize` parameter,
      but 100 is the maximum.

### Add/Update Records

I haven't actually figured this out yet 🤔.
If you want to help, let me know!