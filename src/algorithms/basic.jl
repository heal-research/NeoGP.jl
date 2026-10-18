################################
# Basic GP algorithm
# panmictic, generational, single-objective genetic algorithm
################################

"""
    BasicAlgorithm(likelihood, numvars; kwargs...)
    BasicAlgorithm(X, y; kwargs...)

Single-objective genetic programming: a panmictic, generational algorithm with
tournament selection and one elite.  The parameters of every individual are fitted
by maximum likelihood with the `likelihood` (an `AbstractLikelihood` of
SymRegLikelihoods, `numvars` is the number of input variables), and the fitness
that is minimized is `indiv_loss_func(indiv)`.  The second form uses a Gaussian
likelihood with profiled noise (`GaussianProfiledLikelihood`) of the data `X` (one
observation per row) and `y`.

# Keyword arguments
- `seed`: seed of the random number generator for reproducible runs (default: `-1`, no seeding)
- `popsize`: population size (default: 1000)
- `tournamentsize`: size of the tournaments of the parent selection (default: 2)
- `maxlen`: maximum length of an individual in instructions (default: 100)
- `mutation_prob`: per-node mutation probability (default: 0.05)
- `crossover_prob`: probability that an offspring is created by crossover instead of mutation (default: 0.9)
- `threads`: number of threads of the fitness evaluation, at most `Threads.nthreads()` (default: `0`, all threads)
- `maxeval`: limit of the evaluations of each parameter fit, see [`optimize!`](@ref) (default: `nothing`, the default of the optimizer)
- `functionset`: the opcodes of the operators (default: [`DEFAULT_FUNCTIONSET`](@ref))
- `terminalset`: the opcodes of the terminals (default: [`DEFAULT_TERMINALSET`](@ref))
- `individual_type`: the type of the individuals, a subtype of [`AbstractIndividual`](@ref) (default: `nothing`, [`Individual`](@ref))
- `indiv_loss_func`: the fitness function of an individual, e.g. [`negloglik`](@ref), [`BIC_funccompl`](@ref) or [`description_length`](@ref) (default: [`loss`](@ref))

[`best_individuals`](@ref) returns the best individual and its fitness.  The
constructor prints the settings of the run.
"""
mutable struct BasicAlgorithm{T <: AbstractFloat,
                              L <: AbstractLossFunction{T},
                              F2 <: Function, 
                              I <: AbstractIndividual{L}} <: AbstractAlgorithm
    const fitting_obj_function::L         # for parameter optimization (via optimize!(::L, ...) method) to fit model to data
    const individual_loss_function::F2    # for fitness evaluation of individuals (e.g., negloglik, description_length, ...)
    const pop::Vector{I}                  # population of individuals
    const loss::Vector{T}                 # loss values of individuals in the population (= result of individual_loss_function.(pop))
    fevals::Int                           # number of function evaluations performed (includes function and gradient evaluations during parameter optimization)
    generation::Int                       # number of generations run by `evolve!` (counted over all calls, seeds the offspring)
    const seed::Int
    const maxlen::Int                     # maximum code-length of individuals
    const tournamentsize::Int
    const mutation_prob::Float64          # per-node probability used by mutation offspring
    const crossover_prob::Float64         # probability that an offspring uses crossover
    const functionset::Vector{Opcode}     # sorted (`opcode_list`), for reproducible draws
    const terminalset::Vector{Opcode}
    const numvars::Int                    # number of variables allowed in the programs (from the likelihood)
    const nthreads::Int                   # maximum number of threads to use for fitness evaluation
    const maxeval::Union{Nothing,Int}     # limit of each parameter fit (`nothing`: the optimizer's default), see `fit_parameters`
end


# a simple interface for the Gaussian likelihood (params optimized, sigma profiled)
BasicAlgorithm(X::AbstractMatrix, y::AbstractVector; kwargs...) =
    BasicAlgorithm(GaussianProfiledLikelihood(X, y), size(X, 2); kwargs...)
    
function BasicAlgorithm(fitting_obj_func::LT,
    numvars::Int;                           # number of variables allowed in the programs (from the likelihood)
    seed::Int=-1, popsize::Int=1000, tournamentsize::Int=2,
    mutation_prob::Real=PMUT_PER_NODE, crossover_prob::Real=CROSSOVER_PROB,
    maxlen::Int=100,
    indiv_loss_func::F2 = loss,           # (ind::AbstractIndividual) -> Float64, by default use the fitting_obj_function value as individual fitness 
                                          # (we distinguish this because we might optimize parameters for the NLL but select individuals based on NLL + complexity penalty)
    threads::Int=0,                       # use all available threads by default
    maxeval::Union{Nothing,Int}=nothing,  # limit of each parameter fit (`nothing`: the optimizer's default), see `fit_parameters`
    functionset = DEFAULT_FUNCTIONSET,    # full function set by default (any collection of opcodes)
    terminalset = DEFAULT_TERMINALSET,    # full terminal set by default
    individual_type::Union{Nothing,Type{<:AbstractIndividual}} = nothing,  # `nothing`: `Individual{T, LT}` with `T = parametertype(fitting_obj_func)`
    ) where {LT <: AbstractLossFunction, F2 <: Function}

    # validate arguments
    popsize >= 1        || throw(ArgumentError("popsize must be >= 1, got $popsize"))
    tournamentsize >= 1 || throw(ArgumentError("tournamentsize must be >= 1, got $tournamentsize"))
    maxlen >= 1         || throw(ArgumentError("maxlen must be >= 1, got $maxlen"))
    threads = threads <= 0 ? Threads.nthreads() : threads
    1 <= threads <= Threads.nthreads() || throw(ArgumentError("threads must be between 1 and $(Threads.nthreads()), got $threads"))

    mutation_prob = _validate_probability("mutation_prob", mutation_prob)
    crossover_prob = _validate_probability("crossover_prob", crossover_prob)
    maxeval === nothing || maxeval >= 1 || throw(ArgumentError("maxeval must be at least 1, got $maxeval"))

    seed >= 0 && Random.seed!(seed)

    T = parametertype(fitting_obj_func)
    I = individual_type === nothing ? Individual{T, LT} : individual_type
    I <: AbstractIndividual{LT} ||
        throw(ArgumentError("individual_type must be a subtype of AbstractIndividual{$LT}, got $I"))
    pop = Vector{I}(undef, popsize)
    loss = Vector{T}(undef, popsize)
    
    alg = BasicAlgorithm{T,LT,F2,I}(fitting_obj_func, indiv_loss_func, pop, loss, 0, 0, seed, maxlen,
        tournamentsize, mutation_prob, crossover_prob,
        opcode_list(functionset), opcode_list(terminalset), numvars, threads, maxeval)
    
    println("""
        -- NEO GP (Basic GP)--
        SEED=$(alg.seed)
        THREADS=$threads
        MAX_LEN=$(alg.maxlen)
        POPSIZE=$(length(alg.pop))
        TOURNAMENT_SIZE=$(alg.tournamentsize)
        INITIAL_DEPTH=$INITIAL_DEPTH
        CROSSOVER_PROB=$(alg.crossover_prob)
        PMUT_PER_NODE=$(alg.mutation_prob)
        FUNCTION_SET=$(join(alg.functionset, ","))
        TERMINAL_SET=$(join(alg.terminalset, ","))
        LIKELIHOOD=$(typeof(fitting_obj_func))
        LOSS=$indiv_loss_func
        MAXEVAL=$(something(alg.maxeval, default_maxeval(alg.fitting_obj_function)))
        ----------------------------------""")
   
    return alg
end

function initialize!(alg::BasicAlgorithm)
    T = eltype(alg.loss) # loss value type (e.g., Float64)
    I = eltype(alg.pop)
    pop = alg.pop
    popsize = length(pop)

    # we use multi-threaded fitness evaluation workers and communicate via channels
    lossevalqueue = Channel{Tuple{I,Int}}(popsize)
    resultqueue = Channel{Tuple{I,T,Int,Int}}(popsize)

    evalworkers = start_fitness_eval_workers(lossevalqueue, resultqueue, alg.nthreads, alg.individual_loss_function, alg.maxeval)

    # create random pop
    @timeit global_timer "initial population" begin
        for i in 1:popsize
            @timeit global_timer "create_random" indiv = create_random(I, alg.maxlen, INITIAL_DEPTH, alg.fitting_obj_function, alg.functionset, alg.terminalset, alg.numvars)
            put!(lossevalqueue, (indiv, i))
        end

        # place results by their slot index (not arrival order) so population layout is
        # independent of non-deterministic worker completion order
        process_worker_results(resultqueue, popsize) do (indiv, loss, fevals, idx)
            pop[idx] = indiv
            alg.loss[idx] = isnan(loss) ? typemax(T) : loss
            alg.fevals += fevals
        end
    end

    close(lossevalqueue) # signal for workers to stop
    foreach(wait, evalworkers) # join workers
    alg
end

function select_tournament(pop, loss, tournamentsize)
    bestidx = rand(1:length(pop))
    bestloss = loss[bestidx]
    for _ in 2:tournamentsize
        idx = rand(1:length(pop))
        if loss[idx] < bestloss
            bestidx = idx
            bestloss = loss[idx]
        end
    end
    pop[bestidx]
end

function evolve!(alg::BasicAlgorithm, generations::Int=100; iter_callback=nothing, max_time::Real=Inf)
    generations >= 1 || throw(ArgumentError("generations must be >= 1, got $generations"))
    start = time()
    T = eltype(alg.loss) # loss value type (e.g., Float64)
    I = eltype(alg.pop)
    popsize = length(alg.pop)


    lossevalqueue = Channel{Tuple{I,Int}}(popsize)
    resultqueue = Channel{Tuple{I,T,Int,Int}}(popsize)

    evalworkers = start_fitness_eval_workers(lossevalqueue, resultqueue, alg.nthreads, alg.individual_loss_function, alg.maxeval)

    # generational replacement with one elite
    lastduration = 0.0 # of the previous generation
    @timeit global_timer "evolve_generations" for _ in 1:generations
        # stop before a generation that would end after max_time (if it takes as long as the previous one)
        genstart = time()
        genstart - start + lastduration >= max_time && break
        alg.generation += 1
        gen = alg.generation

        eliteloss,eliteidx = findmin(alg.loss)
        put!(lossevalqueue, (copy_indiv(alg.pop[eliteidx]), 1)) # also evaluate the elite again (for dynamic fitness function or parameter optimization); elite always occupies slot 1

        # Bound child-generation tasks by the requested worker count.
        ngenworkers = min(alg.nthreads, popsize - 1)
        waitall([Threads.@spawn begin
            @timeit task_timer() "selection, xover, and mutation" for slot in (worker + 1):ngenworkers:popsize # slot 1 is the elite
                # Reseed per slot so the offspring is independent of task scheduling.
                alg.seed >= 0 && Random.seed!(hash((alg.seed, gen, slot)))
                if rand() < alg.crossover_prob
                    parent1 = select_tournament(alg.pop, alg.loss, alg.tournamentsize)
                    parent2 = select_tournament(alg.pop, alg.loss, alg.tournamentsize)
                    child = crossover(parent1, parent2, alg.maxlen)
                else
                    parent = select_tournament(alg.pop, alg.loss, alg.tournamentsize)
                    child = copy_indiv(parent)
                    mutate!(child, alg.mutation_prob, alg.numvars, alg.functionset, alg.terminalset)
                end
                put!(lossevalqueue, (child, slot))
            end
            merge_task_timer!()
            nothing
        end for worker in 1:ngenworkers]) # wait because the next step overwrites pop

        # place results by their slot index (not arrival order) so population layout is
        # independent of non-deterministic worker completion order
        process_worker_results(resultqueue, popsize) do (indiv, loss, fevals, idx)
            alg.pop[idx] = indiv
            alg.loss[idx] = isnan(loss) ? typemax(T) : loss
            alg.fevals += fevals
        end

        isnothing(iter_callback) || @timeit global_timer "iter_callback" with_fit_buffer_cache() do; iter_callback() end
        lastduration = time() - genstart
    end
    
    close(lossevalqueue) # signal for workers to stop
    foreach(wait, evalworkers) # join workers
    alg
end


all_individuals(alg::BasicAlgorithm) = collect(zip(alg.pop, alg.loss))

function best_individuals(alg::BasicAlgorithm)
    bestloss,bestidx = findmin(alg.loss)
    bestindiv = alg.pop[bestidx]
    
    [(bestindiv, bestloss)] # the interface requires a vector of tuples
end
