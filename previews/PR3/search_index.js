var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Airtable","category":"page"},{"location":"#Airtable","page":"Home","title":"Airtable","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"An (unofficial) API for interacting with the Airtable API.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Order   = [:type, :function]","category":"page"},{"location":"#Using-this-package","page":"Home","title":"Using this package","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is a very thin wrapper around the Airtable REST API, using HTTP.jl to do the hard stuff. No types or methods are exported, mostly because I didn't want to think too hard about naming them.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This documentation should be used in close conjuntion with the airtable API documentation, which is generated automatically for you using your actual tables (see below).","category":"page"},{"location":"","page":"Home","title":"Home","text":"Most functions require 4 parts:","category":"page"},{"location":"","page":"Home","title":"Home","text":"a Credential, which stores your API key\na Base ID\na tablename - which refers to the specific table from your base\nan API query, in the form of keyword arguments","category":"page"},{"location":"#apikey","page":"Home","title":"API key","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To obtain your API key, go to your account settings page and click on the \"generate API key\" button. If you previously made a key, you can regenerate it, or just copy the one that's there.","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Get airtable API key)","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can then create an Airtable.Credential using that key as a string, or set it as an environmental variable (AIRTABLE_KEY by default).","category":"page"},{"location":"","page":"Home","title":"Home","text":"Credential","category":"page"},{"location":"#Airtable.Credential","page":"Home","title":"Airtable.Credential","text":" Credential(; api_key)\n\nA credential object for Airtable. If the apikey or apitoken are not provided, they will be read from the AIRTABLE_KEY environment variable. Go to Airtable account settings  to aquire your credentials.\n\n# after running `export AIRTABLE_KEY=<api key>` in the shell\njulia> key = Airtable.Credential()\nAirtable.Credential(<secrets>)\n\n\n\n\n\n","category":"type"},{"location":"#baseid","page":"Home","title":"Base ID","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Open your airtable base, click the help button in the upper right, and then click \"API documentation\". Airtable generates documentation for your sepecific base - near the top you should see a sentence like the follwing, with a different alphanumeric sequence for your base:","category":"page"},{"location":"","page":"Home","title":"Home","text":"The ID of this base is appphImnhJO8AXmmo","category":"page"},{"location":"","page":"Home","title":"Home","text":"It will also appear in the url of the base documentation. For example, the Test base for this repo has the url https://airtable.com/appphImnhJO8AXmmo/api/docs.","category":"page"},{"location":"#Tablename","page":"Home","title":"Tablename","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Within each base, you may have multiple tables. The tablename argument in the following functions is just a string with the table name, eg \"Table 1\".","category":"page"},{"location":"#apiquery","page":"Home","title":"API Query","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Use keyword arguments to add commponents to the API request body. For example, if you want a GET request to only contain the Name field, you could include ; fields=[\"Name\"] keyword argument to the Airtable.get function.","category":"page"},{"location":"#Interface","page":"Home","title":"Interface","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The primary function is Airtable.request, which contains all of the components for building an API query and parses the returned data with JSON3.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The following examples use this airtable base, which has the ID \"appphImnhJO8AXmmo\", and the API key described above. To run this code, you will need to substitute the API key and ID from your own base. These examples only scratch the surface - much more information is available in the API documentation for your own base.","category":"page"},{"location":"","page":"Home","title":"Home","text":"request","category":"page"},{"location":"#Airtable.request","page":"Home","title":"Airtable.request","text":"Airtable.request(method::AbstractString, cred::Credential, baseid::AbstractString; query_kwargs...)\n\nMake a request to the Airtable API.\n\nRequired arguments:\n\nmethod: one of \"GET\", \"PUT\", \"POST\", or \"PATCH\",\ncred: an Airtable.Credential containing your API key\nbaseid: the endpoint of your Airtable base. See https://airtable.com/api for details\ntablename: The name of the table (view) for the query\n\nQuery parameters are in the form of keyword arguments, eg filterByFormla = \"NOT({Name} = '')\", maxRecords=2. See Airtable API reference for more information.\n\n\n\n\n\n","category":"function"},{"location":"#Retrieve-records","page":"Home","title":"Retrieve records","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"julia> key=Airtable.Credential();\n\njulia> req1 = Airtable.request(\"GET\", key, \"appphImnhJO8AXmmo\", \"Table 1\"; maxRecords=2)\nJSON3.Object{Base.CodeUnits{UInt8, String}, Vector{UInt64}} with 1 entry:\n  :records => JSON3.Object[{…\n\njulia> req1.records\n2-element JSON3.Array{JSON3.Object, Base.CodeUnits{UInt8, String}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}}:\n {\n            \"id\": \"recMc1HOSIxQPJyyc\",\n        \"fields\": {\n                       \"Name\": \"Record 1\",\n                      \"Notes\": \"Some notes\",\n                     \"Status\": \"Todo\"\n                  },\n   \"createdTime\": \"2020-10-16T21:04:11.000Z\"\n}\n {\n            \"id\": \"recMwT4P4tKlSLJoH\",\n        \"fields\": {\n                       \"Name\": \"Record 2\",\n                      \"Notes\": \"Other notes\",\n                     \"Status\": \"In progress\"\n                  },\n   \"createdTime\": \"2020-10-16T21:04:11.000Z\"\n}\n\njulia> req2 = Airtable.request(\"GET\", key, \"appphImnhJO8AXmmo\", \"Table 1\"; filterByFormula=\"Status = 'Done'\")\nJSON3.Object{Base.CodeUnits{UInt8, String}, Vector{UInt64}} with 1 entry:\n  :records => JSON3.Object[{…\n\njulia> req2.records\n1-element JSON3.Array{JSON3.Object, Base.CodeUnits{UInt8, String}, SubArray{UInt64, 1, Vector{UInt64}, Tuple{UnitRange{Int64}}, true}}:\n {\n            \"id\": \"recSStgr3yJnQc2Wg\",\n        \"fields\": {\n                       \"Name\": \"Record 3 \",\n                     \"Status\": \"Done\"\n                  },\n   \"createdTime\": \"2020-10-16T21:04:11.000Z\"\n}","category":"page"},{"location":"#Retrieving-lots-of-records","page":"Home","title":"Retrieving lots of records","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"The airtable API will only return 100 records per request[1], and only allows 5 requests/sec. To facilitate retrieving lots of records, You can use the Airtable.query function.","category":"page"},{"location":"","page":"Home","title":"Home","text":"query","category":"page"},{"location":"#Airtable.query","page":"Home","title":"Airtable.query","text":"Airtable.query(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)\n\nShorthand for a \"GET\" request that handles continuation and rate-limiting.\n\nThe Airtable API will return a maximum of 100 records per requests, and only allows 5 requests / sec.  This function uses the offset field returned as part of a requst that does not contain all possible records to make additional requests after pausing 0.21 seconds in between.\n\nRequired arguments:\n\ncred: an Airtable.Credential containing your API key\nbaseid: the endpoint of your Airtable base. See https://airtable.com/api for details\ntablename: the name of the table in your base (eg \"Table 1\")\n\nQuery parameters are in the form of keyword arguments, eg filterByFormla = \"NOT({Name} = '')\", maxRecords=2. See Airtable API reference for more information.\n\n\n\n\n\n","category":"function"},{"location":"","page":"Home","title":"Home","text":"[1]: This is the default, you can change this with the pageSize parameter,   but 100 is the maximum.","category":"page"},{"location":"#Add/Update-Records","page":"Home","title":"Add/Update Records","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"I haven't actually figured this out yet 🤔. If you want to help, let me know!","category":"page"},{"location":"#Other-functions","page":"Home","title":"Other functions","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Here are some shorthands for GET, POST, PATCH, and PUT.","category":"page"},{"location":"","page":"Home","title":"Home","text":"get\npost\npatch\nput","category":"page"},{"location":"#Airtable.get","page":"Home","title":"Airtable.get","text":"Airtable.get(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)\n\nShorthand for Airtable.request(\"GET\", cred, baseid, tablename; query_kwargs)\n\n\n\n\n\n","category":"function"},{"location":"#Airtable.post","page":"Home","title":"Airtable.post","text":"Airtable.post(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)\n\nShorthand for Airtable.request(\"POST\", cred, baseid, tablename; query_kwargs)\n\n\n\n\n\n","category":"function"},{"location":"#Airtable.patch","page":"Home","title":"Airtable.patch","text":"Airtable.patch(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)\n\nShorthand for Airtable.request(\"PATCH\", cred, baseid, tablename; query_kwargs)\n\n\n\n\n\n","category":"function"},{"location":"#Airtable.put","page":"Home","title":"Airtable.put","text":"Airtable.put(cred::Credential, baseid::AbstractString, tablename; query_kwargs...)\n\nShorthand for Airtable.request(\"PUT\", cred, baseid, tablename; query_kwargs)\n\n\n\n\n\n","category":"function"}]
}
