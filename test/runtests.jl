using NeoGP
using Test

@testset "NeoGP.jl" begin
    include("test_gaussian.jl")
    include("test_laplace.jl")
    include("test_sharedlikelihoods.jl")
    include("test_rank_intersect.jl")
    include("test_crowdingdistance.jl")
    include("test_algorithm.jl")
    include("test_dataset.jl")

    @testset "Docstrings" begin
        # every exported and public name is documented
        @test isempty(Docs.undocumented_names(NeoGP))
    end
end
