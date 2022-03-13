module Airtable

using HTTP
using JSON3
using ReTest

const API_VERSION = "v0"

include("auth.jl")
include("interface.jl")

end
