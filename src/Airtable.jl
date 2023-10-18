module Airtable

export AirBase,
       AirTable,
       AirRecord,
       path

using Dates
using HTTP
using JSON3
using Preferences: @load_preference, @set_preferences!
using ProgressMeter
using ReTest

const API_VERSION = "v0"

include("ratelimiting.jl")
include("auth.jl")
include("api.jl")
include("interface.jl")

end
