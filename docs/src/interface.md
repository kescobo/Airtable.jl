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

Here, the [`Credential`](@ref Airtable.Credential) is used automatically from the `AIRTABLE_KEY`
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
Airtable.query
```

## [`AirRecord`](@ref)s

An [`AirRecord`](@ref) refers to a specific row of a specific table.
Typically, you would not create records on your own,
but they are returned from many of the API functions
when you use types from `Airtable.jl`
(as opposed to the low-level interface just using strings).

`AirRecord`s contain `fields`, which refer to columns of the table.
Any field values that are not set in the table are not included,
But they can be accessed using `getindex()`.

```julia-repl
julia> rec = first(Airtable.query(tab))
AirRecord("recMc1HOSIxQPJyyc", AirTable("Table 1"), (Name = "Record 1", Notes = "Keep this\n", Status = "Todo", Keep = true))

julia> rec[:Name]
"Record 1"

julia> rec[:Status]
"Todo"
```

## Adding or changing records

You can add or update records using [`Airtable.post!`](@ref)
and [`Airtable.patch!`](@ref) respectively.
Using `post!` requires an `AirTable` as the first argument,
while `patch!` requires an `AirRecord`.

### Using `post!`

To use `post!`,
pass a table and a `NamedTuple` with the fields that you want to add.
Note that if the fields don't already exist in the parent table,
this will throw an error.

```julia-repl
julia> new_rec = Airtable.post!(tab, (; Name = "Some Record", Notes = "It's a nice record"))
AirRecord("recYvPIayZx1okJ41", AirTable("Table 1"), (Name = "Some Record", Notes = "It's a nice record"))
```

Notice that the return value is an [`AirRecord`](@ref).
It can be useful to hold onto this, since it contains the unique identifier.
You can also pass a vector of `NamedTuple`s to create multiple records.

See the [note about rate limits](@ref ratelimit).

### Using `patch!`

If you want to update an existing record,
use `patch!`, with an `AirRecord` as the first argument,
and a `NamedTuple` for the fields you want to change.

```julia-repl
julia> Airtable.patch!(new_rec, (; Status="Done", Notes="It *was* a nice record"))
AirRecord("recYvPIayZx1okJ41", AirTable("Table 1"), (Name = "Some Record", Notes = "It *was* a nice record", Status = "Done"))
```

Any fields that you don't include will remain the same.
If you want to clear a field, pass `missing`

```julia-repl
julia> Airtable.patch!(new_rec, (; Status="Done", Notes=missing))
AirRecord("recYvPIayZx1okJ41", AirTable("Table 1"), (Name = "Some Record", Status = "Done"))
```

### Using `delete!`

To remove a record, simply pass an `AirRecord` with the same `id` to [`delete!`](@ref).

```julia-repl
julia> Airtable.delete!(new_rec)
JSON3.Object{Base.CodeUnits{UInt8, String}, Vector{UInt64}} with 2 entries:
  :deleted => true
  :id      => "recYvPIayZx1okJ41"
```

[^1]: This is the default, you can change this with the `pageSize` parameter,
      but 100 is the maximum.

### Add/update records


## [A note on rate limits](@id ratelimit)

Airtable.com only allows 5 requests / min.
The `query` function handles that automatically,
but other functions do not (yet).