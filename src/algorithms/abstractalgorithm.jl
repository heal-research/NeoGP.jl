# Two variants of genetic programming algorithms are implemented in this package. 
# Algorithms share the same interface defined by the abstract type AbstractAlgorithm.

"""
    AbstractAlgorithm

Supertype of the genetic programming algorithms [`BasicAlgorithm`](@ref) and
[`NSGA2`](@ref).  An algorithm is created from a likelihood, then
[`initialize!`](@ref) creates the initial population and [`evolve!`](@ref) runs
generations; [`best_individuals`](@ref) and [`all_individuals`](@ref) return
the result.  Lower loss values are better.
"""
abstract type AbstractAlgorithm end


"""
    evolve!(alg::AbstractAlgorithm, generations = 100; iter_callback = nothing, max_time = Inf) -> alg

Run `generations` generations of `alg`, which must have been initialized with
[`initialize!`](@ref).  The optional `iter_callback`, a function without
arguments, is called after every generation.

`max_time` limits the run time of the call in seconds: a generation is not
started if it would end after `max_time` when it takes as long as the previous
generation (no generation is run if `max_time <= 0`).  `alg.generation` counts the
generations run over all calls of `evolve!`.  The offspring of a seeded algorithm
are seeded by the generation count, so `evolve!(alg, a); evolve!(alg, b)` continues
the run like `evolve!(alg, a + b)`.
"""
function evolve! end

"""
    initialize!(alg::AbstractAlgorithm) -> alg

Create and evaluate the initial population of `alg`.
"""
function initialize! end

"""
    best_individuals(alg::AbstractAlgorithm) -> Vector{Tuple{AbstractIndividual, Any}}

The best individuals of the current population with their loss values.
Single-objective algorithms return only the best individual, multi-objective
algorithms the individuals of the first Pareto front, sorted by loss.  The loss
values are numbers or tuples, depending on the algorithm.  Lower loss values are
better.
"""
function best_individuals end

"""
    all_individuals(alg::AbstractAlgorithm) -> Vector{Tuple{AbstractIndividual, Any}}

All individuals of the current population with their loss values, see
[`best_individuals`](@ref).
"""
function all_individuals end


function _validate_probability(name, probability::Real)
    isfinite(probability) && 0 <= probability <= 1 ||
        throw(ArgumentError("$name must be a finite number between 0 and 1, got $probability"))
    Float64(probability)
end