using BenchmarkTools
using NeoGP
using Random

const SUITE = BenchmarkGroup()

# Every benchmark runs inside `with_fit_buffer_cache()`, as the evaluation
# workers do, so the interpreter buffers are reused across calls.  Without the
# cache each call allocates them anew and measures a path NeoGP does not take.

function gaussian_likelihood(::Type{T}, n) where {T <: AbstractFloat}
    rng = MersenneTwister(0)
    X = randn(rng, T, n, 2)
    y = T(2) .* X[:, 1] .- T(3) .* X[:, 2] .+ T(0.5)
    y_noisy = y .+ T(0.1) .* randn(rng, T, n)
    # model f = p1*x1 + p2*x2 + p3 in shared post-order (SCALEDVAR / PARAM)
    # 4-field form.  Parameter values live in the terminal `val` fields
    # (heritable genome state).
    code = NeoGP.Instruction{T}[
        NeoGP.Instruction(NeoGP.SCALEDVAR, 1, 1, one(T)),  # r1 = p1*x1 (var=1, param=1)
        NeoGP.Instruction(NeoGP.SCALEDVAR, 2, 2, one(T)),  # r2 = p2*x2 (var=2, param=2)
        NeoGP.Instruction(NeoGP.ADD, 1, 2, zero(T)),       # r3 = r1 + r2
        NeoGP.Instruction(NeoGP.PARAM, 3, 0, one(T)),      # r4 = p3
        NeoGP.Instruction(NeoGP.ADD, 3, 4, zero(T)),       # r5 = r3 + r4
    ]

    likelihood = NeoGP.GaussianProfiledLikelihood(X, y_noisy)
    individual = NeoGP.Individual(code, likelihood)
    initial_parameters = ones(T, 4)   # 3 model params and the profiled sigma²

    return (; likelihood, individual, initial_parameters)
end

# Model built from the transcendental kernels that dominate typical GP models:
# f = p1*|x1|^p2 + p3*log(x2) + p4*exp(p5*x1) (POWABS, LOG, EXP, with a
# non-integer exponent), with profiled noise (LM) or known noise plus intrinsic
# scatter (NLopt).  The individual holds its MLE, where NeoGP evaluates the
# model-selection criteria.
function pow_log_exp_likelihood(::Type{T}, n, scatter::Bool) where {T <: AbstractFloat}
    rng = MersenneTwister(1)
    X = rand(rng, T, n, 2) .* T(3) .+ T(0.5)   # positive inputs for log(x2)
    model = NeoGP.Model(T, Expr(:->, :(x, p),
        :(p[1] * abs(x[1])^p[2] + p[3] * log(x[2]) + p[4] * exp(p[5] * x[1]))), 5)
    y = copy(NeoGP.interpret_vec(model, X, T[1.5, 1.7, 0.8, 0.3, -0.6])) .+ T(0.1) .* randn(rng, T, n)

    likelihood = scatter ? NeoGP.GaussianScatterLikelihood(X, y, fill(T(0.05), n)) :
                           NeoGP.GaussianProfiledLikelihood(X, y)
    individual = NeoGP.Individual(model, likelihood)
    initial_parameters = T[1.2, 1.5, 1.0, 0.2, -0.5, 0.01]   # 5 model params and sigma² or sigma_int²
    NeoGP.updateparam!(individual, initial_parameters)
    NeoGP.optimize!(individual)

    return (; likelihood, individual, initial_parameters)
end

for T in (Float32, Float64), n in (500,), scatter in (false, true)
    case_name = "$T / $n observations"
    group = scatter ? "pow-log-exp scatter likelihood" : "pow-log-exp profiled likelihood"

    likelihood_conf = pow_log_exp_likelihood(T, n, scatter)
    SUITE[group]["optimize!"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.optimize!(
        $(likelihood_conf.likelihood), $(likelihood_conf.individual), parameters,
    ) end setup = (parameters = copy($(likelihood_conf.initial_parameters))) evals = 10
    SUITE[group]["description_length"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.description_length(
        $(likelihood_conf.individual),
    ) end
    SUITE[group]["negloglik"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.negloglik(
        $(likelihood_conf.individual),
    ) end
end

for T in (Float32, Float64), n in (500, 5_000)
    case_name = "$T / $n observations"

    likelihood_conf = gaussian_likelihood(T, n)
    SUITE["gaussian likelihood"]["optimize!"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.optimize!(
        $(likelihood_conf.likelihood), $(likelihood_conf.individual), parameters,
    ) end setup = (parameters = copy($(likelihood_conf.initial_parameters))) evals = 10
    SUITE["gaussian likelihood"]["description_length"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.description_length(
        $(likelihood_conf.individual),
    ) end
    SUITE["gaussian likelihood"]["fractional_bayes_factor"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.fractional_bayes_factor(
        $(likelihood_conf.individual),
    ) end
    SUITE["gaussian likelihood"]["BIC"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.BIC(
        $(likelihood_conf.individual),
    ) end
    SUITE["gaussian likelihood"]["AIC"][case_name] = @benchmarkable NeoGP.with_fit_buffer_cache() do; NeoGP.AIC(
        $(likelihood_conf.individual),
    ) end
end

SUITE
