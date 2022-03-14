```@meta
CurrentModule = Airtable
```

# Airtable

An (unofficial) API for interacting with the [Airtable](http://www.airtable.com) API.

```@index
Order   = [:type, :function]
```

## Using this package

This package is wrapper for the Airtable REST API,
using [`HTTP.jl`](https://juliaweb.github.io/HTTP.jl/stable/) to do the hard stuff.

This documentation should be used in close conjunction with the Airtable API
documentation, which is generated automatically for you using your actual tables
(see below).

To use this documentation effectively,
you should understand a few of the terms Airtable uses:

1. A "Base" is like a project.
   There may be several tables contained within a base that can refer to each other.
2. A "Table" is a 2D array where each row is a "Record"
   and each column is "Field".
3. A "Record" (a row of a table) is an individual observation
   which may have any number of "field" values.
4. A "Field" (a column of a table) is a named and typed datapoint.
   When fields are missing for a given record, they are typically not included in API responses.

All API operations also require that you provide authorization in the form of an API key.

### [API key](@id apikey)

To obtain your API key, go to your [account settings page](https://airtable.com/account)
and click on the "generate API key" button.
If you previously made a key, you can regenerate it, or just copy the one that's there.

![Get airtable API key](img/api-key.png)

You can then create an [`Airtable.Credential`](@ref) using that key as a string,
or set it as an environmental variable (`AIRTABLE_KEY` by default).

```@docs
Credential
```

It is recommended that you use the environmental variable,
since many functions can use that by default instead of requiring that you pass it as an argument.

### [Base ID](@id baseid)

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

### [API Query](@id apiquery)

Use keyword arguments to add commponents to the API request body.
For example, if you want a `GET` request to only contain the `Name` field,
you could include `; fields=["Name"]` keyword argument to the [`Airtable.get`](@ref)
function.

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

### Other functions

Here are some shorthands for `GET`, `POST`, `PATCH`, and `PUT`, `DELETE`.

```@docs
get
post!
patch!
put!
delete!
```
