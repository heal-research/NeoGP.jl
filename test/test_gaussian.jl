@testset "Gaussian likelihood" begin
    n = 1000
    X = randn(Float32, n, 2)
    y   = 2.0f0 * X[:,1] .- 3.0f0 * X[:,2] .+ 0.5f0
    y_n = y .+ 0.1f0 * randn(Float32, n)
    # p1*x1 + p2*x2 + p3 (SCALEDVAR: arg1=var, arg2=param; PARAM: arg1=param)
    code = NeoGP.Instruction{Float32}[
        NeoGP.Instruction(NeoGP.SCALEDVAR, 1, 1, 1.0f0),
        NeoGP.Instruction(NeoGP.SCALEDVAR, 2, 2, 1.0f0),
        NeoGP.Instruction(NeoGP.ADD, 1, 2, 0.0f0),
        NeoGP.Instruction(NeoGP.PARAM, 3, 0, 1.0f0),
        NeoGP.Instruction(NeoGP.ADD, 3, 4, 0.0f0),
        ]

    # profiled sigma²: a parameter of the individual [p1..p3; sigma²], set to
    # its estimate by the fit rather than searched over
    lik = NeoGP.GaussianProfiledLikelihood(X, y_n)
    @test NeoGP.n_likelihood_params(lik) == 1
    indiv = NeoGP.Individual(code, lik)
    @test only(indiv.likelihood_param) > 0
    p0 = ones(Float32, 4)
    NeoGP.optimize!(lik, indiv, p0)
    @test p0[1:3] ≈ [2.0f0, -3.0f0, 0.5f0] atol=1e-1
    @test p0[4] ≈ 0.01f0 rtol=0.2
    NeoGP.updateparam!(indiv, p0)
    @test NeoGP.negloglik(indiv) < -500
    @test isfinite(NeoGP.description_length(indiv))
    @test isfinite(NeoGP.BIC(indiv))
    @test isfinite(NeoGP.AIC(indiv))
    @test isfinite(NeoGP.fractional_bayes_factor(indiv))
    @test isfinite(NeoGP.description_length_terms(indiv)[2]) # func_complexity

    # every DL wrapper takes the choice of parameter complexity; the default is
    # the rotated one
    (l, m, p) = NeoGP._model_selection_args(indiv)
    @test NeoGP.description_length_terms(indiv)[3] == NeoGP.param_complexity_rot(p, l, m)
    for f in (NeoGP.param_complexity, NeoGP.param_complexity_rot,
              NeoGP.param_complexity_rot_scaled, NeoGP.param_complexity_det)
        pc = f(p, l, m)
        @test NeoGP.description_length_terms(indiv; paramCompFunc = f)[3] == pc
        @test NeoGP.description_length(indiv; paramCompFunc = f) ≈
              sum(NeoGP.description_length_terms(indiv; paramCompFunc = f))
        @test NeoGP.description_length_complexity_penalty(indiv; paramCompFunc = f) ≈
              NeoGP.func_complexity(indiv) + pc
    end

    # scalar fixed sigma
    lik = NeoGP.GaussianLikelihood(X, y_n, 0.1f0)
    @test NeoGP.n_likelihood_params(lik) == 0
    indiv = NeoGP.Individual(code, lik)
    p0 = ones(Float32, 3)
    NeoGP.optimize!(lik, indiv, p0)
    @test p0 ≈ [2.0f0, -3.0f0, 0.5f0] atol=1e-1
    NeoGP.updateparam!(indiv, p0)
    @test isfinite(NeoGP.description_length(indiv))

    # vector fixed sigma
    lik = NeoGP.GaussianLikelihood(X, y_n, 0.1f0 .* ones(Float32, n))
    indiv = NeoGP.Individual(code, lik)
    p0 = ones(Float32, 3)
    NeoGP.optimize!(lik, indiv, p0)
    @test p0 ≈ [2.0f0, -3.0f0, 0.5f0] atol=1e-1
    NeoGP.updateparam!(indiv, p0)
    @test isfinite(NeoGP.fractional_bayes_factor(indiv))

    # individual-level optimize! writes back into the model, then predict uses it
    NeoGP.optimize!(indiv)
    mp = NeoGP.extractmodelparam(Float32, indiv)
    ypred = NeoGP.predict!(indiv, X, mp)
    @test length(ypred) == n
    @test NeoGP.mean_squared_error(y_n, ypred) < 0.05
end
