mutable struct Timer
    idx::Int
    last5::Vector{DateTime}

    Timer() = new(1, zeros(DateTime, 5))
end

function _ratelimit!(t::Timer)
    n = now()
    e = t.last5[t.idx]
    rl = n - e
    if rl < Millisecond(1000)
        @warn "Pausing for rate-limiting"
        sleep(Millisecond(1000) - rl)
        n = now()
    end

    t.last5[t.idx] = n
    t.idx = 1 + (t.idx % 5)
end

const _ratelimiter = Timer()

@testset "Rate Limiting" begin
    tab = AirTable("Table 1", AirBase("appphImnhJO8AXmmo"))
    # Make > 5 requests in a second, and be sure no error is thrown
    for i in 1:7
        q = Airtable.query(tab)
        if i == 7
            @test q isa Vector{AirRecord}
        end
    end

end