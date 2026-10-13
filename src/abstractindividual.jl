
# Abstract type for individuals
# Users can define their own individual types by subtyping this and implementing the interface

# The interface assumes:
# - Each individual produces a vector of predictions for a given input matrix X. 
# - Individuals have parameters that can be extracted and updated via extractparam and updateparam!
# - Each individual has a single loss function which is used to fit the individual's parameters to data 
#   (e.g., via maximum likelihood) using the optimize! method.
# - The loss function may also have fitting parameters (e.g., sigma_err for Gaussian likelihoods) that 
#   are part of the individual's parameter vector.

# This interface allows:
# - flexible encodings for individuals (e.g., tree-based, linear genome etc.)
# - optimization of parameters of both the program and the loss function (e.g. sigma_err for Gaussian likelihoods)
# - different loss functions for fitting individual parameters (e.g., likelihoods with different assumptions)
# 

"""
    AbstractIndividual{L}

Supertype of individuals whose parameters are fitted with the loss function
(likelihood) of type `L`.  A subtype must implement the abstract methods
[`copy_indiv`](@ref), [`extractparam`](@ref), [`extractmodelparam`](@ref),
[`updateparam!`](@ref), [`getlossfunction`](@ref), [`predict!`](@ref),
[`create_random`](@ref), [`crossover`](@ref), [`mutate!`](@ref),
[`individual_length`](@ref), [`individual_depth`](@ref) and [`print_indiv`](@ref),
and the criteria and algorithms of this package then work with it.
[`Individual`](@ref) is the implementation of this package.
"""
abstract type AbstractIndividual{L} end

####################################################
# Abstract methods (must be implemented by subtypes)
####################################################

"""
    copy_indiv(indiv::AbstractIndividual) -> AbstractIndividual

An independent copy of `indiv`.
"""
function copy_indiv end

"""
    extractparam(::Type{T}, indiv::AbstractIndividual) -> AbstractVector{T}

The parameters of `indiv` as a vector of type `T`: the parameters of the model
followed by the parameters of the loss function (e.g. the noise variance of a
Gaussian likelihood).
"""
function extractparam end

"""
    extractmodelparam(::Type{T}, indiv::AbstractIndividual) -> AbstractVector{T}

Only the parameters of the model (without the parameters of the loss function)
as a vector of type `T`.  These are used for prediction.
"""
function extractmodelparam end

"""
    updateparam!(indiv::AbstractIndividual, param::AbstractVector) -> AbstractIndividual

Set the parameters of `indiv` to `param`, in the layout of [`extractparam`](@ref).
"""
function updateparam! end

"""
    getlossfunction(indiv::AbstractIndividual) -> AbstractLossFunction

The loss function (likelihood) that is used to fit the parameters of `indiv`.
"""
function getlossfunction end

"""
    predict!(indiv::AbstractIndividual, x::AbstractMatrix, modelparam::AbstractVector,
             jacp = nothing, jacx = nothing) -> AbstractVector

The predictions of `indiv` for the observations in the rows of `x`, given the
parameters of the model `modelparam` (without the parameters of the loss
function).  For a [`LogScaledLikelihood`](@ref) the predictions are those of the
log-scaled model for log-scaled `x`.  With the matrices `jacp` and `jacx` the
Jacobians of the predictions with respect to the parameters and to `x` are
written as well.
"""
function predict! end

"""
    create_random(::Type{I}, maxlen, maxdepth, likelihood, functionset, terminalset, numvars) -> I

Create a random individual of type `I` with at most `maxlen` instructions and
depth `maxdepth`.  `functionset` and `terminalset` are collections of opcodes
(sorted vectors, see `opcode_list`, for reproducible draws), `numvars` is the
number of input variables.
"""
function create_random end

"""
    crossover(parent1::AbstractIndividual, parent2::AbstractIndividual, maxlen::Int) -> AbstractIndividual

Create an offspring of two parents by crossover.  The offspring has at most
`maxlen` instructions.
"""
function crossover end

"""
    mutate!(indiv::AbstractIndividual, pmut, numvars, functionset, terminalset) -> AbstractIndividual

Mutate `indiv` in place.  `pmut` is the mutation probability of each node.
"""
function mutate! end

"""
    individual_length(indiv::AbstractIndividual) -> Int

The length of `indiv`, i.e. the number of nodes of its expression tree.
"""
function individual_length end

"""
    individual_depth(indiv::AbstractIndividual) -> Int

The depth of `indiv`, i.e. the maximum nesting level of its expression tree.
"""
function individual_depth end

"""
    print_indiv(io::IO, indiv::AbstractIndividual, varnames = nothing)

Print `indiv` to `io`, using `varnames` as names of the input variables.
"""
function print_indiv end
####################################################


"""
    predict(indiv::AbstractIndividual, x::AbstractMatrix) -> AbstractVector
    predict(indiv::AbstractIndividual, x::AbstractMatrix, modelparam::AbstractVector)

The predictions of `indiv` for the observations in the rows of `x`, with the
current parameters of `indiv` or with the model parameters `modelparam`.
See [`predict!`](@ref).
"""
function predict(indiv::AbstractIndividual, x::AbstractMatrix)
    T = parametertype(getlossfunction(indiv))
    predict(indiv, x, extractmodelparam(T, indiv))
end

function predict(indiv::AbstractIndividual, x::AbstractMatrix, modelparam::AbstractVector)
    predict!(indiv, x, modelparam)
end

"""
    optimize!(indiv::AbstractIndividual; maxeval = nothing) -> Int

Fit the parameters of `indiv` (those of its model and of its loss function) by
maximum likelihood, in place, and return the number of evaluations of the
objective.  `maxeval` limits the evaluations of the fit; `nothing` keeps the
default of the optimizer (20 for the least-squares likelihoods, 300 for the
others).  Subtypes may override this method for a custom optimization.
"""
function optimize!(indiv::AbstractIndividual; maxeval = nothing)
    T = parametertype(getlossfunction(indiv))
    param = extractparam(T, indiv)
    isempty(param) && return 0

    @timeit task_timer() "optimize!" fevals = optimize!(getlossfunction(indiv), indiv, param; maxeval)

    updateparam!(indiv, param)
    
    fevals
end

"""
    loss(indiv::AbstractIndividual) -> Real

The loss of `indiv` at its current parameters: the negative log-likelihood of
its loss function.
"""
function loss(indiv::AbstractIndividual)
    lossfunc = getlossfunction(indiv)
    param = extractparam(parametertype(lossfunc), indiv)
    lossfunc(indiv, param)
end



# evaluate_loss! may change parameter values of individuals (when optimize == true).
# `loss_func` is a function that takes (indiv::AbstractIndividual) as argument.
# The loss function is a type parameter (F2), so the concrete function type is
# preserved through the evaluation workers (like the `F2 <: Function` field of
# `BasicAlgorithm` and the `F <: NTuple{2,Function}` field of `NSGA2`).
# Single-objective version
function evaluate_loss!(indiv::AbstractIndividual, loss_func::F2; optimize=false,
                        maxeval=nothing) where {F2 <: Function}
    fevals = 1
    optimize && (fevals += optimize!(indiv; maxeval))
    T = parametertype(getlossfunction(indiv))
    T(loss_func(indiv)), fevals
end

# two-objective version (NSGA2)
function evaluate_loss!(indiv::AbstractIndividual, loss_func::F2; optimize=false,
                        maxeval=nothing) where {F2 <: NTuple{2,Function}}
    fevals = 1
    optimize && (fevals += optimize!(indiv; maxeval))
    T = parametertype(getlossfunction(indiv))
    f1, f2 = loss_func
    NTuple{2,T}((f1(indiv), f2(indiv))), fevals
end


"""
    tostring(indiv::AbstractIndividual, varnames = nothing) -> String

The string printed by [`print_indiv`](@ref).  `varnames` are the names of the
input variables, e.g. `dataset.varnames` of a [`Dataset`](@ref).
"""
function tostring(indiv::AbstractIndividual, varnames::Union{Nothing,AbstractVector{<:AbstractString}} = nothing)
    buf = IOBuffer()
    print_indiv(buf, indiv, varnames)
    String(take!(buf))
end

