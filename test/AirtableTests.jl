module AirtableTests

using Airtable
using Airtable.HTTP
using Airtable.JSON3
using ReTest

@testset "Airtable.jl" begin
    key = Airtable.Credential()
    @test key isa Airtable.Credential
    @test key.api_key isa String


    @test length(Airtable.get(key, "appphImnhJO8AXmmo/Table 1"; filterByFormula="{Keep}").records) == 3

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
        stat = resp.fields.Status
        @test stat != "In progress"
        @test Airtable.patch(key, "appphImnhJO8AXmmo/Table 1/$id", ["Content-Type" => "application/json"], """{"fields": {"Status": "In progress"}}""").id == id
        @test Airtable.record(key, "appphImnhJO8AXmmo", "Table 1", id).fields.Status == "In progress"
        @test_throws HTTP.ExceptionRequest.StatusError Airtable.patch(key, "appphImnhJO8AXmmo/Table 1/$id", ["Content-Type" => "application/json"], """{"fields": {"Status": "Not Valid"}}""")
        @test Airtable.patch(key, "appphImnhJO8AXmmo/Table 1/$id", ["Content-Type" => "application/json"], """{"fields": {"Status": "$stat"}}""").id == id

        @test collect(keys(resp.fields)) == [:Name, :Notes, :Status]
        @test Airtable.delete_record(key, "appphImnhJO8AXmmo", "Table 1", id).deleted
        @test_throws HTTP.ExceptionRequest.StatusError Airtable.record(key, "appphImnhJO8AXmmo", "Table 1", id)
    end

    # Cleanup
    dontkeep = Airtable.get(key, "appphImnhJO8AXmmo/Table 1"; filterByFormula="NOT({Keep})").records
    if !isempty(dontkeep)
        sleep(1)
        for rec in records
            Airtable.delete_record(key, "appphImnhJO8AXmmo", "Table 1", rec.id)
        end
    end
end

end