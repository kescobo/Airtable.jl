module Airtable

using HTTP
using JSON3

const API_VERSION = "v0"

include("auth.jl")
include("interface.jl")

end
