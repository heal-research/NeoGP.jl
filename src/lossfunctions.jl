# NeoGP loss-function interface over the shared SymRegLikelihoods likelihoods,
# the log-scaled likelihoods, plus the MSE / R² scalar fit criteria.
# 
# Parameter optimization is delegated to `SymRegLikelihoods.optimize`.

# ---------------------------------------------------------------------------
# Loss-function interface
# ---------------------------------------------------------------------------

# Initialize the individual's likelihood parameters for a fresh individual:
# standard normal, and log-normal for the positive ones (the variances).  A
# profiled parameter is replaced by its estimate when the individual is
# optimized.
function initialize_likelihood_params(::Type{T}, l::SL.AbstractLossFunction) where {T}
    φ = T[convert(T, randn()) for _ in 1:n_likelihood_params(l)]
    for k in SL.positive_params(l)
        φ[k] = exp(φ[k])
    end
    φ
end

function print_lossfunction(io, l::SL.AbstractLossFunction)
    print(io, typeof(l).name.name)
end

# calling the loss function on an individual evaluates the negative log-likelihood of its model and likelihood parameters
function (l::SL.AbstractLossFunction)(indiv::AbstractIndividual, param::AbstractVector)
    SL.evaluate_nll(l, getprogram(indiv), param)
end

# `maxeval` limits the evaluations of the objective in each fit, in the unit of
# the reported `fevals`; `nothing` keeps the optimizer's default.  For
# Levenberg-Marquardt (least-squares likelihoods) these are the residual
# evaluations, at least 2; the Jacobian evaluations are not counted, and the
# iterations stay limited to 100.  For NLopt (all other likelihoods, default 300)
# they are the evaluations of the objective and its gradient; LBFGS checks the
# limit only between line searches, so it may exceed it slightly.
# ---------------------------------------------------------------------------
default_maxeval(::SL.AbstractLeastSquaresLikelihood) = 20
default_maxeval(::SL.AbstractLikelihood) = 300


# `SymRegLikelihoods.optimize` picks the optimizer by likelihood kind
# (Levenberg-Marquardt for least squares, NLopt otherwise).  Both search in
# Float64 but evaluate the model and likelihood at their native precision, so
# no conversion is needed here.  The result holds the fitted natural parameters
# in `r.x` (Float64).
#
function optimize!(l::SL.AbstractLossFunction, indiv::AbstractIndividual,
                   p0::AbstractVector{T}; maxeval = nothing) where {T}
    r = fit_parameters(l, getprogram(indiv), p0, maxeval)
    p0 .= T.(r.x)
    r.num_fevals
end

fit_parameters(l::SL.AbstractLikelihood, model, p0, ::Nothing) = fit_parameters(l, model, p0, default_maxeval(l))
fit_parameters(l::SL.AbstractLikelihood, model, p0, maxeval::Integer) = SL.optimize(l, model, p0; maxeval)



# ---------------------------------------------------------------------------
# Log-scaled likelihoods
# ---------------------------------------------------------------------------

# TODO this could be moved to SymRegLikelihoods

"""
    LogScaledLikelihood(likelihood; x = false, y = false)

Evaluate `likelihood` on a model that is defined on the original scale while the
data of `likelihood` are log10-scaled.  With `x = true` the model inputs are
log10-scaled (`f'(x) = f(10^x)`), with `y = true` its output is
(`f'(x) = log10(|f(x)|)`), and with both `f'(x) = log10(|f(10^x)|)`.

The data of `likelihood` (inputs, outputs and errors) must already be log-scaled,
see [`logscale`](@ref).  The likelihood parameters are those of `likelihood`, so
the complete parameter vector `[model params; likelihood params]` is unchanged,
and the function complexity of a model-selection criterion is that of the
original (unscaled) model.
"""
struct LogScaledLikelihood{T,L<:SL.AbstractLikelihood{T}} <: SL.AbstractLikelihood{T}
    likelihood::L
    logx::Bool
    logy::Bool

    function LogScaledLikelihood(likelihood::L; x::Bool = false,
                                 y::Bool = false) where {T,L<:SL.AbstractLikelihood{T}}
        (x || y) || throw(ArgumentError("LogScaledLikelihood requires x = true or y = true"))
        new{T,L}(likelihood, x, y)
    end
end

"""
    evaluation_model(l::AbstractLossFunction, model::Model) -> Model

The model whose predictions `l` compares with its data: `model` itself, or its
log-scaled version for a [`LogScaledLikelihood`](@ref).
"""
evaluation_model(::SL.AbstractLossFunction, model::Model) = model

function evaluation_model(l::LogScaledLikelihood, model::Model)
    if l.logx && l.logy
        to_logspace_xy_model(model)
    elseif l.logx
        to_logspace_x_model(model)
    else
        to_logspace_y_model(model)
    end
end

SL.n_observations(l::LogScaledLikelihood) = SL.n_observations(l.likelihood)
SL.n_likelihood_params(l::LogScaledLikelihood) = SL.n_likelihood_params(l.likelihood)
SL.positive_params(l::LogScaledLikelihood) = SL.positive_params(l.likelihood)
SL.has_intrinsic_scatter(l::LogScaledLikelihood) = SL.has_intrinsic_scatter(l.likelihood)

SL.evaluate_nll(l::LogScaledLikelihood, model::Model, θ::AbstractVector) =
    SL.evaluate_nll(l.likelihood, evaluation_model(l, model), θ)

SL.evaluate_nll_grad!(grad::AbstractVector, l::LogScaledLikelihood, model::Model,
                      θ::AbstractVector) =
    SL.evaluate_nll_grad!(grad, l.likelihood, evaluation_model(l, model), θ)

# The prepared likelihood is bound to the log-scaled model, so that the analytic
# gradients of the wrapped likelihood are used, e.g. for the information matrix.
SL.prepare(l::LogScaledLikelihood, model::Model) =
    SL.prepare(l.likelihood, evaluation_model(l, model))

default_maxeval(l::LogScaledLikelihood) = default_maxeval(l.likelihood)
fit_parameters(l::LogScaledLikelihood, model, p0, maxeval::Integer) =
    fit_parameters(l.likelihood, evaluation_model(l, model), p0, maxeval)

function print_lossfunction(io, l::LogScaledLikelihood)
    print(io, "LogScaled")
    print(io, l.logx ? "X" : "", l.logy ? "Y" : "", "(")
    print_lossfunction(io, l.likelihood)
    print(io, ")")
end

# ---------------------------------------------------------------------------
# Standalone evaluation metrics (train/test reporting only; MSE / R² are not
# optimizable loss functions)
# ---------------------------------------------------------------------------
"""
    mean_squared_error(y, ypred) -> Real

The mean squared error of the predictions `ypred` of the values `y`.
"""
function mean_squared_error(y::AbstractVector, ypred::AbstractVector)
    length(y) == length(ypred) ||
        throw(DimensionMismatch("length(y) != length(ypred)"))
    T = promote_type(eltype(y), eltype(ypred))
    sse = zero(T)
    @inbounds for i in eachindex(y, ypred)
        sse += abs2(y[i] - ypred[i])
    end
    sse / length(y)
end

"""
    r2_score(y, ypred) -> Real

The coefficient of determination R² of the predictions `ypred` of the values `y`
(higher is better, 1 for a perfect fit).  `-Inf` if `y` is constant.
"""
function r2_score(y::AbstractVector, ypred::AbstractVector)
    length(y) == length(ypred) ||
        throw(DimensionMismatch("length(y) != length(ypred)"))
    T = promote_type(eltype(y), eltype(ypred))
    ymean = sum(y) / length(y)
    sse = zero(T)
    tss = zero(T)
    @inbounds for i in eachindex(y, ypred)
        sse += abs2(y[i] - ypred[i])
        tss += abs2(y[i] - ymean)
    end
    iszero(tss) && return T(-Inf)
    one(T) - sse / tss
end
