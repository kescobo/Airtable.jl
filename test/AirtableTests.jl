module AirtableTests

using Airtable
using Airtable.HTTP
using Airtable.JSON3
using ReTest

@testset "Airtable.jl" begin
    key = Airtable.Credential()
    @test key isa Airtable.Credential
    @test key.api_key isa String


    @test length(Airtable.get(key, "appphImnhJO8AXmmo/Table 1").records) == 3

    resp = Airtable.post(key, "appphImnhJO8AXmmo/Table 1", 
                             ["Content-Type" => "application/json"], 
                             JSON3.read(open("add_records.json")) |> JSON3.write)
    
    @test resp isa JSON3.Object
    @test resp.records isa JSON3.Array
    @test length(resp.records) == 2

    ids = map(rec-> rec.id, resp.records)
    for id in ids
        sleep(1) # avoid over-taxing api
        local resp = Airtable.record(key, "appphImnhJO8AXmmo", "Table 1", id)
        @test resp isa JSON3.Object
        @test resp.id == id
        @test collect(keys(resp.fields)) == [:Name, :Notes, :Status]
        @test Airtable.delete_record(key, "appphImnhJO8AXmmo", "Table 1", id).deleted
        @test_throws HTTP.ExceptionRequest.StatusError Airtable.record(key, "appphImnhJO8AXmmo", "Table 1", id)
    end


end

end