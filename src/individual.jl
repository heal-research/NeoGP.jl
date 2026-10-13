# An `Individual` represents its model as a SymRegInterpreter `CodeModel`
# (a post-order linear program; the code carries the model parameter values in
# the terminal instructions, so they are heritable genome state) together with
# the shared likelihood (stateless) and the likelihood parameter values,
# which are also heritable (inherited from the first parent on crossover).
#
# Parameter optimization goes through `SymRegLikelihoods.optimize`, which
# `prepare()`s the likelihood for the individual's model before optimizing the
# complete parameter vector `[model params; likelihood params]`.
# `T` is the numeric type shared by the model (`CodeModel{T}`), the likelihood
# (`L <: AbstractLossFunction{T}`) and the likelihood parameter vector, so the
# fields are concretely typed (no `CodeModel{T} where {T}` existential) and a
# model/likelihood type mismatch is rejected at construction instead of
# failing with a MethodError on first use.
"""
    Individual(code, likelihood)
    Individual(model, likelihood)
    Individual(code, likelihood, likelihood_param)

A tree-structured symbolic regression model with its parameters, as evolved by
the algorithms of this package: the model is a `SymRegInterpreter` `CodeModel`
(a post-order linear program, `code` is a `Vector{Instruction{T}}`, or a `Model`
whose code is copied) and `likelihood` is the loss function (an
`AbstractLikelihood{T}` of SymRegLikelihoods, shared between individuals).  The
parameter values of the model are stored in the code, the parameters of the
likelihood (e.g. the noise variance) in the individual, initialized randomly
or with `likelihood_param`.

The parameters are fitted with [`optimize!`](@ref).  The model is returned by
[`getprogram`](@ref); the model-selection criteria [`negloglik`](@ref),
[`description_length`](@ref), [`BIC`](@ref), ... are evaluated at the current
parameters.
"""
mutable struct Individual{T<:AbstractFloat, L<:AbstractLossFunction{T}} <: AbstractIndividual{L}
    model::CodeModel{T}
    lossfunction::L
    likelihood_param::Vector{T}  # likelihood parameter values (heritable)

    function Individual(model::CodeModel{T}, lossfunction::L,
                        likelihood_param::Vector) where {T, L<:AbstractLossFunction{T}}
        new{T,L}(model, lossfunction, convert(Vector{T}, likelihood_param))
    end
end

# Build an Individual directly from a post-order linear program.
function Individual(code::Vector{Instruction{T}}, lossfunction::L) where {T, L<:AbstractLossFunction{T}}
    Individual(CodeModel(code, model_nparam(code)), lossfunction,
               initialize_likelihood_params(T, lossfunction))
end

# ... with explicitly supplied (heritable) likelihood parameter values.
Individual(code::Vector{<:Instruction}, lossfunction::L,
           likelihood_param::Vector) where {L} =
    Individual(CodeModel(code, model_nparam(code)), lossfunction, likelihood_param)

# Accept a Model by copying its code as a CodeModel.
Individual(model::Model{T}, lossfunction::L) where {T, L<:AbstractLossFunction{T}} =
    Individual(CodeModel(copy(code(model)), model_nparam(code(model))), lossfunction,
               initialize_likelihood_params(T, lossfunction))

#########################################################
# Implementation of abstract methods
#########################################################
# `Instruction` is an immutable bits type, so `copy` of the code vector already
# gives a fully independent genome;
copy_indiv(indiv::Individual) =
    Individual(CodeModel(copy(code(getprogram(indiv))), n_param(getprogram(indiv))),
               getlossfunction(indiv), copy(indiv.likelihood_param))

# Get model parameters from the code terminals.
extractmodelparam(::Type{T}, indiv::Individual{T}) where {T} =
    extractparam(T, code(getprogram(indiv)))

# Get the vector of all parameters `[model params; likelihood params]`.
function extractparam(::Type{T}, indiv::Individual{T}) where {T}
    mp = extractmodelparam(T, indiv)
    # skip for likelihoods without parameters
    isempty(indiv.likelihood_param) && return mp
    vcat(mp, indiv.likelihood_param)
end

# Update all parameters, model parameters stored in code terminals, likeihoods params in the individual
function updateparam!(indiv::Individual{T}, param::AbstractVector) where {T}
    prog = code(getprogram(indiv))
    nm = model_nparam(prog)
    updateparam!(prog, @view param[1:nm])           # write model values into code
    indiv.likelihood_param = T.(param[nm+1:end])
    indiv
end

getlossfunction(indiv::Individual) = indiv.lossfunction

"""
    getprogram(indiv::Individual) -> CodeModel

The model (`SymRegInterpreter.CodeModel`) of `indiv`, which stores the values of
the model parameters.
"""
getprogram(indiv::Individual) = indiv.model

# Returns the predictions for `x` given the model parameter vector.  The
# predictions are on the scale of the individual's likelihood: for a
# `LogScaledLikelihood` they are those of the log-scaled model for log-scaled `x`.
function predict!(indiv::Individual, x::AbstractMatrix, modelparam::AbstractVector,
    jacp::Union{Nothing,AbstractMatrix} = nothing,
    jacx::Union{Nothing,AbstractMatrix} = nothing)
    model = evaluation_model(getlossfunction(indiv), getprogram(indiv))
    if jacp === nothing && jacx === nothing
        return interpret_vec(model, x, modelparam)
    end
    y = zeros(eltype(modelparam), size(x, 1))
    interpret_jac!(y, jacp, jacx, model, x, modelparam)
    y
end



function create_random(::Type{Individual{T,L}}, maxlen, maxdepth, likelihood::L, functionset, terminalset, numvars) where {T<:AbstractFloat, L<:AbstractLossFunction{T}}
    # Custom `AbstractIndividual` subtypes dispatch on their own type and
    # implement their own `create_random` (the abstract interface contract).
    buffer = Instruction{T}[]
    while isempty(buffer)
        grow!(buffer, maxlen, maxdepth, numvars, functionset, terminalset)
    end
    Individual(buffer, likelihood)
end

function crossover(parent1::Individual, parent2::Individual, maxlen::Int)
    offspring_code = crossover(code(getprogram(parent1)), code(getprogram(parent2)), maxlen)
    # likelihood parameter values are inherited from the first parent
    Individual(offspring_code, getlossfunction(parent1), copy(parent1.likelihood_param))
end

function mutate!(indiv::Individual, pmut, numvars, functionset, terminalset)
    if rand() < pmut
        indiv.likelihood_param =
            initialize_likelihood_params(parametertype(getlossfunction(indiv)),
                                         getlossfunction(indiv))
    end
    prog = code(getprogram(indiv))
    # Mutation returns the reindexed parameter count, avoiding a third full
    # program scan after mutation and parameter-index reassignment.
    nparam = mutate!(prog, pmut, numvars, functionset, terminalset)
    if nparam != n_param(getprogram(indiv))
         # CodeModel is immutable and we need to update the number of parameters.
         # TODO: make `CodeModel` mutable in `SymRegInterpreter`, `ExprModel` already is
        indiv.model = CodeModel(prog, nparam)
    end
    indiv
end

# This function counts the number of nodes if the code would be represented as expression tree.
# We count 3 nodes for scaledvar terminals (x * param). 
# Currently, we do not count the abs function in fused protected operators (logabs, powabs) separately. 
function individual_length(indiv::Individual)
    progcode = code(getprogram(indiv))
    length(progcode) + 2 * count(isscaledvar, progcode)  # count the parameters and multiplication nodes for scaled variables extra
end

individual_depth(indiv::Individual) = expression_tree_height(code(getprogram(indiv)))

function print_indiv(io::IO, indiv::Individual{T}, varnames::Union{Nothing,AbstractVector{<:AbstractString}} = nothing) where {T}
    print_program(io, code(getprogram(indiv)), varnames)
    print(io, " ")
    print_lossfunction(io, getlossfunction(indiv))
    num_model_params = n_param(getprogram(indiv))
    print(io, " $(extractparam(T, indiv)[num_model_params+1:end])")
end

# ---------------------------------------------------------------------------
# Parameter optimization
# ---------------------------------------------------------------------------

function optimize!(indiv::Individual{T}; maxeval = nothing) where {T}
    model = getprogram(indiv)
    p0 = extractparam(T, indiv)
    isempty(p0) && return 0

    r = try
        fit_parameters(getlossfunction(indiv), model, p0, maxeval)
    catch ex
        # A failed optimization must never crash an evaluation worker.
        # It leaves the parameters unchanged and reports zero evaluations.

        # A broken build (see `SL._is_bug`) must surface.
        SL._is_bug(ex) && rethrow()
        @debug "parameter optimization failed for individual" exception = ex
        return 0
    end

    nm = n_param(model)
    updateparam!(code(model), T.(@view r.x[1:nm]))     # model params -> code
    indiv.likelihood_param = T.(r.x[nm+1:end])
    r.num_fevals
end

# ---------------------------------------------------------------------------
# Fitness / model selection criteria
# Methods of the criteria of SymRegModelSelection (and `negloglik`) that take
# only the individual: they evaluate the individual's model and likelihood
# at its current parameter values.
# ---------------------------------------------------------------------------

"""
    negloglik(indiv::Individual) -> Real

The negative log-likelihood of the data of `indiv`'s likelihood for its model
and its current parameter values.
"""
function negloglik(indiv::Individual{T}) where {T}
    lossf = getlossfunction(indiv)
    SL.evaluate_nll(lossf, getprogram(indiv), extractparam(T, indiv))
end

@inline function _model_selection_args(indiv::Individual{T}) where {T}
    (getlossfunction(indiv), getprogram(indiv), extractparam(T, indiv))
end

# The parameter complexities `param_complexity`, `param_complexity_rot`,
# `param_complexity_rot_scaled` and `param_complexity_det` of SymRegModelSelection
# (imported in NeoGP.jl) are the choices of `paramCompFunc` below:
#   param_complexity             only the diagonal of the Fisher information
#   param_complexity_rot         rotated onto its singular vectors (the default)
#   param_complexity_rot_scaled  rotated in relative coordinates θ/|θ̂|, which
#                                makes it independent of the units of the data
#   param_complexity_det         from the determinant of the Fisher information

"""
    description_length(indiv::Individual; paramCompFunc = param_complexity_rot) -> Real

The description length of `indiv` as a number: the sum of the negative
log-likelihood, the function complexity and the parameter complexity, see
[`description_length_terms`](@ref).  (Unlike
`SymRegModelSelection.description_length` it does not return the terms as well.)  `paramCompFunc` selects the parameter
complexity, one of [`param_complexity_rot`](@ref) (default),
[`param_complexity`](@ref), [`param_complexity_rot_scaled`](@ref) and
[`param_complexity_det`](@ref).
"""
description_length(indiv::Individual; paramCompFunc = param_complexity_rot) =
    sum(SMS.description_length_terms(_model_selection_args(indiv)...; paramCompFunc))

"""
    description_length_terms(indiv::Individual; paramCompFunc = param_complexity_rot)

The three terms of the description length of `indiv` as a tuple
`(negloglik, func_complexity, param_complexity)`.
"""
description_length_terms(indiv::Individual; paramCompFunc = param_complexity_rot) =
    SMS.description_length_terms(_model_selection_args(indiv)...; paramCompFunc)

"""
    description_length_complexity_penalty(indiv::Individual; paramCompFunc = param_complexity_rot)

The description length of `indiv` without its negative log-likelihood, i.e. the
sum of the function complexity and the parameter complexity.
"""
description_length_complexity_penalty(indiv::Individual; paramCompFunc = param_complexity_rot) =
    SMS.description_length_complexity_penalty(_model_selection_args(indiv)...; paramCompFunc)

"""
    func_complexity(indiv::Individual)

The function complexity of the model of `indiv`, see
`SymRegModelSelection.func_complexity`.
"""
func_complexity(indiv::Individual) = SMS.func_complexity(getprogram(indiv))

"""
    BIC(indiv::Individual) -> Real

The Bayesian information criterion of `indiv`.
"""
BIC(indiv::Individual) = SMS.BIC(_model_selection_args(indiv)...)

"""
    BIC_funccompl(indiv::Individual) -> Real

The Bayesian information criterion of `indiv` with the function complexity
as additional penalty.
"""
BIC_funccompl(indiv::Individual) =
    SMS.BIC_funccompl(_model_selection_args(indiv)...)

"""
    BIC_funccompl_penalty(indiv::Individual) -> Real

The penalty of [`BIC_funccompl`](@ref), i.e. the criterion without the negative
log-likelihood.
"""
BIC_funccompl_penalty(indiv::Individual) =
    SMS.BIC_funccompl_penalty(_model_selection_args(indiv)...)

"""
    AIC(indiv::Individual) -> Real

The Akaike information criterion of `indiv`.
"""
AIC(indiv::Individual) = SMS.AIC(_model_selection_args(indiv)...)

"""
    fractional_bayes_factor(indiv::Individual) -> Real

The fractional Bayes factor model-selection criterion of `indiv` (lower is better).
"""
fractional_bayes_factor(indiv::Individual) =
    SMS.fractional_bayes_factor(_model_selection_args(indiv)...)

"""
    fractional_bayes_factor_terms(indiv::Individual)

The two components of the fractional Bayes factor of `indiv` as a tuple: the
scaled negative log-likelihood and the complexity penalty.
"""
fractional_bayes_factor_terms(indiv::Individual) =
    SMS.fractional_bayes_factor_terms(_model_selection_args(indiv)...)

"""
    fractional_bayes_factor_complexity_penalty(indiv::Individual) -> Real

The fractional Bayes factor of `indiv` without its negative log-likelihood.
"""
fractional_bayes_factor_complexity_penalty(indiv::Individual) =
    SMS.fractional_bayes_factor_complexity_penalty(_model_selection_args(indiv)...)
