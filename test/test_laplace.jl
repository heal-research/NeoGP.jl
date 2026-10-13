@testset "Laplace likelihood" begin
    n = 1000

    X = randn(Float32, n, 2)
    y   = 2.0f0 * X[:,1] .- 3.0f0 * X[:,2] .+ 0.5f0

    code = NeoGP.Instruction{Float32}[
        NeoGP.Instruction(NeoGP.SCALEDVAR, 1, 1, 1.0f0), # p1*x1
        NeoGP.Instruction(NeoGP.SCALEDVAR, 2, 2, 1.0f0), # p2*x2
        NeoGP.Instruction(NeoGP.ADD, 1, 2, 0.0f0),
        NeoGP.Instruction(NeoGP.PARAM, 3, 0, 1.0f0),     # p3
        NeoGP.Instruction(NeoGP.ADD, 3, 4, 0.0f0),
        ]
        
    # add Laplace noise
    u = rand(Float32, n) .- 0.5f0
    noise_lapl = sign.(u) .* log.(1 .- 2 .* abs.(u))
    y_n = y .+ 0.1f0 .* noise_lapl

    # profiled scale: b² is a parameter of the individual [p1..p3; b²], set
    # to its estimate by the fit rather than searched over
    lik = NeoGP.LaplaceProfiledLikelihood(X, y_n)
    @test NeoGP.n_likelihood_params(lik) == 1
    indiv = NeoGP.Individual(code, lik)
    p0 = ones(Float32, 4)
    NeoGP.optimize!(lik, indiv, p0)
    @test p0[1:3] ≈ [2.0f0, -3.0f0, 0.5f0] atol=1e-1
    @test p0[4] ≈ 0.01f0 rtol=0.2
    NeoGP.updateparam!(indiv, p0)
    @test isfinite(NeoGP.description_length(indiv))
    @test isfinite(NeoGP.BIC(indiv))
    @test isfinite(NeoGP.AIC(indiv))
    @test isfinite(NeoGP.fractional_bayes_factor(indiv))

    # scalar fixed scale
    lik = NeoGP.LaplaceLikelihood(X, y_n, 0.1f0)
    @test NeoGP.n_likelihood_params(lik) == 0
    indiv = NeoGP.Individual(code, lik)
    p0 = ones(Float32, 3)
    NeoGP.optimize!(lik, indiv, p0)
    @test p0 ≈ [2.0f0, -3.0f0, 0.5f0] atol=1e-1
    NeoGP.updateparam!(indiv, p0)
    @test isfinite(NeoGP.description_length(indiv))

    # vector fixed scale
    lik = NeoGP.LaplaceLikelihood(X, y_n, 0.1f0 .* ones(Float32, n))
    indiv = NeoGP.Individual(code, lik)
    p0 = ones(Float32, 3)
    NeoGP.optimize!(lik, indiv, p0)
    @test p0 ≈ [2.0f0, -3.0f0, 0.5f0] atol=1e-1
    NeoGP.updateparam!(indiv, p0)
    @test isfinite(NeoGP.fractional_bayes_factor(indiv))
end
