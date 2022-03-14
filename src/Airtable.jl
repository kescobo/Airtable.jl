module Airtable

export AirBase,
       AirTable,
       AirRecord,
       path

using HTTP
using JSON3
using Tables
using ReTest

const API_VERSION = "v0"

include("auth.jl")
include("api.jl")
include("interface.jl")

end
