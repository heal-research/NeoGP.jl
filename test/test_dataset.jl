using NeoGP
using Test

@testset "Datasets" begin
    @testset "parse_sigma" begin
        @test NeoGP.parse_sigma(nothing) === nothing
        @test NeoGP.parse_sigma("0.1, 2") == [0.1, 2.0]
        @test NeoGP.parse_sigma("e_x,e_y") == ["e_x", "e_y"]
        @test NeoGP.parse_sigma([1, 2]) == [1.0, 2.0]
        @test NeoGP.parse_sigma(["e_x"]) == ["e_x"]
        @test_throws ArgumentError NeoGP.parse_sigma("0.1,e_y")
        @test_throws ArgumentError NeoGP.parse_sigma("0.1,,0.2")
    end

    mktempdir() do dir
        csv = joinpath(dir, "data.csv")
        write(csv, """
            x1,x2,e_x1,e_y,y
            1.0,2.0,0.1,0.2,3.0
            2.0,3.0,0.1,0.2,5.0
            3.0,5.0,0.1,0.3,8.0
            """)

        @testset "load_dataset" begin
            ds = load_dataset(Float32, csv, "y"; inputs = ["x1", "x2"])
            @test ds isa Dataset{Float32}
            @test ds.X == Float32[1 2; 2 3; 3 5]
            @test ds.y == Float32[3, 5, 8]
            @test isnothing(ds.Xerr) && isnothing(ds.yerr)
            @test ds.varnames == ["x1", "x2"]

            ds = load_dataset(Float64, csv, "y"; inputs = ["x1"], sigma = ["e_y"])
            @test ds.yerr == [0.2, 0.2, 0.3]
            @test isnothing(ds.Xerr)

            ds = load_dataset(Float64, csv, "y"; inputs = ["x1"], sigma = ["e_x1", "e_y"],
                              likelihood = "ROXY_unif")
            @test ds.Xerr == fill(0.1, 3, 1)
            @test ds.yerr == [0.2, 0.2, 0.3]

            # the inputs are all columns except for the target and the error columns
            ds = load_dataset(Float64, csv, "y"; sigma = "e_x1,e_x1,e_y", likelihood = "roxy_mnr_diagonal")
            @test ds.varnames == ["x1", "x2"]
            @test ds.Xerr == fill(0.1, 3, 2)

            @test_throws ArgumentError load_dataset(Float64, csv, "z")
            @test_throws ArgumentError load_dataset(Float64, csv, "y"; likelihood = "roxy_unif")
            @test_throws ArgumentError load_dataset(Float64, csv, "y"; likelihood = "other")
            @test_throws ArgumentError load_dataset(Float64, csv, "y"; sigma = [0.1, 0.2])
        end

        @testset "logscale and create_likelihood" begin
            ds = load_dataset(Float64, csv, "y"; inputs = ["x1"], sigma = ["e_x1", "e_y"],
                              likelihood = "roxy_unif")
            ls = logscale(ds; x = true, y = true)
            @test ls.X ≈ log10.(ds.X)
            @test ls.y ≈ log10.(ds.y)
            @test ls.yerr ≈ ds.yerr ./ (ds.y .* log(10))
            @test logscale(ds).X == ds.X

            @test_throws ArgumentError logscale(Dataset([-1.0;;], [1.0], nothing, nothing, ["x"]); x = true)

            for name in ("roxy_unif", "roxy_mnr_diagonal")
                @test create_likelihood(name, ds) isa NeoGP.SL.AbstractLikelihood
            end
            plain = load_dataset(Float64, csv, "y"; inputs = ["x1", "x2"])
            @test create_likelihood("gaussian", plain) isa NeoGP.GaussianProfiledLikelihood
            @test create_likelihood("laplace", plain) isa NeoGP.LaplaceProfiledLikelihood
            @test_throws ArgumentError create_likelihood("roxy_unif", plain)
            @test_throws ArgumentError create_likelihood("other", plain)
        end
    end

    @testset "metrics" begin
        @test NeoGP.mean_squared_error([1.0, 2.0], [1.0, 4.0]) == 2.0
        @test NeoGP.r2_score([1.0, 2.0, 3.0], [1.0, 2.0, 3.0]) == 1.0
        @test NeoGP.r2_score([1.0, 1.0], [1.0, 2.0]) == -Inf
        @test_throws DimensionMismatch NeoGP.mean_squared_error([1.0], [1.0, 2.0])
    end
end
