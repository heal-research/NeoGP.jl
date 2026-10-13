# SymRegLikelihoods reachable through a NeoGP Individual.
#
# NeoGP Individuals carry a SymRegInterpreter `CodeModel`.  The shared
# likelihoods are model-agnostic (they take the model explicitly), so they
# evaluate directly on a NeoGP Individual's model.  These tests pin the ESR
# fixture nll values through that path and confirm the shared package loads
# alongside NeoGP without symbol clashes.

using SymRegLikelihoods
using SymRegLikelihoods: GaussianLikelihood, XUniformDiagonalLikelihood, MNRDiagonalLikelihood,
    evaluate_nll, evaluate_nll_grad!
using SymRegInterpreter: Model, to_logspace_xy_model
using DelimitedFiles

@testset "Shared likelihoods through a NeoGP Individual" begin
    X = reshape(Float64[1, 2, 3, 4, 5], :, 1)
    y = 2.0 .* vec(X) .- 1.0
    # p1*x1 + p2 (SCALEDVAR: arg1=var 1, arg2=param 1; PARAM: arg1=param 2)
    code = NeoGP.Instruction{Float64}[
        NeoGP.Instruction(NeoGP.SCALEDVAR, 1, 1, 1.0),  # p1*x1
        NeoGP.Instruction(NeoGP.PARAM, 2, 0, 1.0),      # p2
        NeoGP.Instruction(NeoGP.ADD, 1, 2, 0.0),
    ]
    # the loss function on an Individual is only a data/config holder here —
    # the fixture evaluates the shared likelihood directly on the model
    indiv = NeoGP.Individual(code, NeoGP.GaussianLikelihood(X, y, 0.5))
    model = NeoGP.getprogram(indiv)
    @test model isa NeoGP.CodeModel

    l = GaussianLikelihood(X, y, 0.5)
    nll = evaluate_nll(l, model, [2.0, -1.0])
    @test isfinite(nll)
    # matches the exact-fit NLL for sigma=0.5, n=5
    @test nll ≈ 5/2 * log(2 * pi) - 5 * log(2) + 0 atol=1e-8

    @test SymRegLikelihoods.parametertype(l) <: AbstractFloat
end

@testset "RAR fixture through a NeoGP Individual" begin
    csv = joinpath(pkgdir(SymRegLikelihoods), "test", "RAR.csv")
    m, hdr = readdlm(csv, ',', Float64; header=true)
    hdr = vec(hdr)
    gbar = m[:, findfirst(==("gbar"), hdr)]
    gobs = m[:, findfirst(==("gobs"), hdr)]
    elgbar = m[:, findfirst(==("e_gbar"), hdr)] ./ (gbar * log(10))
    elgobs = m[:, findfirst(==("e_gobs"), hdr)] ./ (gobs * log(10))
    data = [gbar log10.(gbar) elgbar.^2 log10.(gobs) elgobs.^2]
    @test size(data, 1) > 128   # exercises the (now-fixed) batched adjoint

    body = :(p[1] * (abs(p[2] + x[1])^p[3] + x[1]))
    model = to_logspace_xy_model(Model(Float64, Expr(:->, :(x, p), body), 3))
    indiv = NeoGP.Individual(model, NeoGP.GaussianLikelihood([gbar gobs], gobs, 0.5))
    rar = XUniformDiagonalLikelihood(log10.(gbar), elgbar, log10.(gobs), elgobs)
    p = [0.8395593155955371, -0.022204122733443278, 0.38093147640767777]
    nll = evaluate_nll(rar, NeoGP.getprogram(indiv), p)
    @test nll ≈ -1279.1 atol=1e-1

    # the same through the common dataset interface: NeoGP log-scales the data
    # and evaluates the model defined on the original scale in log space
    raw = NeoGP.Dataset(reshape(gbar, :, 1), gobs,
                        reshape(m[:, findfirst(==("e_gbar"), hdr)], :, 1),
                        m[:, findfirst(==("e_gobs"), hdr)], ["gbar"])
    lograr = NeoGP.LogScaledLikelihood(
        NeoGP.create_likelihood("roxy_unif", NeoGP.logscale(raw; x = true, y = true));
        x = true, y = true)
    linear = NeoGP.Individual(Model(Float64, Expr(:->, :(x, p), body), 3),
                              NeoGP.GaussianLikelihood([gbar gobs], gobs, 0.5))
    @test evaluate_nll(lograr, NeoGP.getprogram(linear), p) ≈ nll

    # the same likelihood prepared for the log-scaled model; the prepared
    # object must reproduce the fixture and its analytic gradient must agree
    # with the model-agnostic wrapper and with ForwardDiff
    pl = SymRegLikelihoods.prepare(lograr, NeoGP.getprogram(linear))
    @test evaluate_nll(pl, p) ≈ nll
    grad = zeros(3)
    @test evaluate_nll_grad!(grad, pl, p) ≈ nll
    fdgrad = zeros(3)
    SymRegLikelihoods.evaluate_nll_grad_fd!(fdgrad, pl, p)
    @test grad ≈ fdgrad rtol=1e-6
    wrapped = zeros(3)
    evaluate_nll_grad!(wrapped, lograr, NeoGP.getprogram(linear), p)
    @test wrapped ≈ grad rtol=1e-12
end

@testset "Diagonal MNR fixture through a NeoGP Individual" begin
    csv = joinpath(pkgdir(SymRegLikelihoods), "test", "RAR.csv")
    m, hdr = readdlm(csv, ',', Float64; header=true)
    hdr = vec(hdr)
    gbar = m[:, findfirst(==("gbar"), hdr)]
    gobs = m[:, findfirst(==("gobs"), hdr)]
    elgbar = m[:, findfirst(==("e_gbar"), hdr)] ./ (gbar * log(10))
    elgobs = m[:, findfirst(==("e_gobs"), hdr)] ./ (gobs * log(10))
    data = [gbar log10.(gbar) elgbar.^2 log10.(gobs) elgobs.^2]

    # the raw-derivative convention: the model is moved to log space, the
    # likelihood is evaluated at the observed log10(gbar)
    body = :(p[1] * abs(x[1])^(-1 / (p[2] + abs(p[3] + x[1])^p[4])))
    model = to_logspace_xy_model(Model(Float64, Expr(:->, :(x, p), body), 4))
    indiv = NeoGP.Individual(model, NeoGP.GaussianLikelihood([gbar gobs], gobs, 0.5))
    mnr = MNRDiagonalLikelihood(log10.(gbar), elgbar, log10.(gobs), elgobs)
    # p = [model params; sigma², mu_gauss, w²] at the ESR fixture values
    p = [-1.7302245173940842, -2.40586258570395, -0.017892186956077034,
         0.051284150873232376, 0.07915900803213895^2, -0.5024228473024372,
         0.7397713386530679^2]
    nll = evaluate_nll(mnr, NeoGP.getprogram(indiv), p)
    @test nll ≈ 1464.219863790258 atol=1e-4   # as in the SymRegLikelihoods fixture

    # the same through the common dataset interface: NeoGP log-scales the data
    # and evaluates the model defined on the original scale in log space
    raw = NeoGP.Dataset(reshape(gbar, :, 1), gobs,
                        reshape(m[:, findfirst(==("e_gbar"), hdr)], :, 1),
                        m[:, findfirst(==("e_gobs"), hdr)], ["gbar"])
    logmnr = NeoGP.LogScaledLikelihood(
        NeoGP.create_likelihood("roxy_mnr_diagonal", NeoGP.logscale(raw; x = true, y = true);
                                intrinsic_scatter = true);
        x = true, y = true)
    linear = NeoGP.Individual(Model(Float64, Expr(:->, :(x, p), body), 4),
                              NeoGP.GaussianLikelihood([gbar gobs], gobs, 0.5))
    @test evaluate_nll(logmnr, NeoGP.getprogram(linear), p) ≈ nll

    # the same likelihood prepared for the log-scaled model; the prepared
    # object must reproduce the fixture and its analytic gradient must agree
    # with the model-agnostic wrapper and with ForwardDiff
    pl = SymRegLikelihoods.prepare(logmnr, NeoGP.getprogram(linear))
    @test evaluate_nll(pl, p) ≈ nll
    grad = zeros(7)
    @test evaluate_nll_grad!(grad, pl, p) ≈ nll
    fdgrad = zeros(7)
    SymRegLikelihoods.evaluate_nll_grad_fd!(fdgrad, pl, p)
    @test grad ≈ fdgrad rtol=1e-6
    wrapped = zeros(7)
    evaluate_nll_grad!(wrapped, logmnr, NeoGP.getprogram(linear), p)
    @test wrapped ≈ grad rtol=1e-12
end
