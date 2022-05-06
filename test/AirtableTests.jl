module AirtableTests

using Airtable
using Airtable.HTTP
using Airtable.JSON3
using ReTest

@testset "Airtable.jl" begin
    @testset "Constructors" begin
        bs = AirBase("appphImnhJO8AXmmo")
        @test Airtable.id(bs) == "appphImnhJO8AXmmo"
        @test Airtable.path(bs) == "/v0/appphImnhJO8AXmmo"
        
        tab = AirTable("Table 1", bs)
        @test Airtable.id(tab) == "Table 1"
        @test Airtable.path(tab) == "/v0/appphImnhJO8AXmmo/Table 1"

        rec = AirRecord("some id", tab, Dict())
        @test Airtable.id(rec) == "some id"
        @test Airtable.path(rec) == "/v0/appphImnhJO8AXmmo/Table 1/some id"

    end

    @testset "Interface" begin
        tab = AirTable("Table 1", AirBase("appphImnhJO8AXmmo"))

        @test length(Airtable.query(tab; filterByFormula="{Keep}")) == 3

        resp = Airtable.post!(tab, open(joinpath(@__DIR__, "add_records.json")))
        
        @test resp isa Vector{AirRecord}
        @test length(resp) == 2

        for rec in resp
            sleep(1) # avoid over-taxing api

            @test rec[:Status] != "In progress"
            @test Airtable.patch!(rec, (; Status="In progress")).id == Airtable.id(rec)
            @test Airtable.get(rec)[:Status] == "In progress"
            @test_throws HTTP.ExceptionRequest.StatusError Airtable.patch!(rec, (; Status="Not valid"))
            Airtable.patch!(rec, (; Status = rec[:Status]))

            @test keys(rec) == (:Name, :Notes, :Status)
            @test Airtable.delete!(rec).deleted
            @test_throws HTTP.ExceptionRequest.StatusError Airtable.get(rec)
        end
        resp = Airtable.post!(tab, open(joinpath(@__DIR__, "add_records.json")))
        Airtable.patch!(tab, resp, [(; Status="In progress") for _ in 1:length(resp)])
        @test all([Airtable.get(rec)[:Status] == "In progress" for rec in resp])

    end
    # Cleanup
    dontkeep = Airtable.query(AirTable("Table 1", AirBase("appphImnhJO8AXmmo")); filterByFormula="NOT({Keep})")
    if !isempty(dontkeep)
        sleep(1)
        for rec in dontkeep
            Airtable.delete!(rec)
        end
    end
end

end