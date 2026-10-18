#####################################################################
# Non-dominated Sorting Genetic Algorithm II (NSGA-II) implementation
# Supports only two objectives
#####################################################################
"""
    NSGA2(likelihood, numvars; kwargs...)
    NSGA2(X, y; kwargs...)

Two-objective genetic programming with the non-dominated sorting genetic algorithm
NSGA-II (Pareto ranks and crowding distance, tournament selection, elitist
truncation).  The parameters of every individual are fitted by maximum likelihood
with the `likelihood` (an `AbstractLikelihood` of SymRegLikelihoods, `numvars` is
the number of input variables), and the two objectives `indiv_loss_func` are
minimized.  The second form uses a Gaussian likelihood with profiled noise
(`GaussianProfiledLikelihood`) of the data `X` (one observation per row) and `y`.

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
- `indiv_loss_func`: a tuple of the two objective functions of an individual (default: `(loss, individual_length)`), e.g. `(negloglik, individual_length)` or a pair of [`RoundedObjective`](@ref)s.  Rounding the objectives makes equally good individuals share a slot of the Pareto front.

[`best_individuals`](@ref) returns the individuals of the first Pareto front
with the tuples of their objectives, sorted by the first objective.  The
constructor prints the settings of the run.
"""
mutable struct NSGA2{T <: AbstractFloat,
                     L <: AbstractLossFunction{T},
                     F <: NTuple{2,Function},   # concrete tuple type of the two objective functions (like `F2 <: Function` in `BasicAlgorithm`)
                     I <: AbstractIndividual{L}} <: AbstractAlgorithm
    const fitting_obj_func::L         # for parameter optimization (via optimize!(::L, ...) method) to fit model to data
    const indiv_loss_func::F          # tuple of the two objective functions for individuals (e.g., (loss, individual_length))
    const pop::Vector{I}              # population of individuals
    const loss::Vector{NTuple{2, T}}
    const ranks::Vector{Int}          # Pareto ranks of the population (lower is better)
    const crowdingdistance::Vector{T} # crowding distance values of the population (=manhattan distance to next closest individual in objective space) (higher is better)
    fevals::Int                       # number of function evaluations performed (includes function and gradient evaluations during parameter optimization)
    generation::Int                   # number of generations run by `evolve!` (counted over all calls, seeds the offspring)
    const seed::Int
    const maxlen::Int
    const popsize::Int
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
NSGA2(X::AbstractMatrix, y::AbstractVector; kwargs...) =
    NSGA2(GaussianProfiledLikelihood(X, y), size(X, 2); kwargs...)
    
function NSGA2(fitting_obj_func::LT, 
    numvars::Int;                           # number of variables allowed in the programs (from the likelihood)
    seed::Int = -1, popsize::Int = 1000, tournamentsize::Int = 2, maxlen::Int = 100,
    mutation_prob::Real = PMUT_PER_NODE, crossover_prob::Real = CROSSOVER_PROB,
    indiv_loss_func::F2 = (loss, individual_length), # by default use the loss function's default loss and individual length
    threads::Int = 0,                       # use all available threads by default
    maxeval::Union{Nothing,Int} = nothing,  # limit of each parameter fit (`nothing`: the optimizer's default), see `fit_parameters`
    functionset = DEFAULT_FUNCTIONSET,      # full function set by default (any collection of opcodes)
    terminalset = DEFAULT_TERMINALSET,      # full terminal set by default
    individual_type::Union{Nothing,Type{<:AbstractIndividual}} = nothing,  # `nothing`: `Individual{T, LT}` with `T = parametertype(fitting_obj_func)`
    ) where {LT <: AbstractLossFunction, F2 <: NTuple{2,Function}}
    
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
    pop = Vector{I}(); sizehint!(pop, 2 * popsize)
    loss = Vector{NTuple{2,T}}(); sizehint!(loss, 2 * popsize)
    ranks = Vector{Int}(); sizehint!(ranks, 2 * popsize)
    crowdingdistance = Vector{T}(); sizehint!(crowdingdistance, 2 * popsize)
    
    alg = NSGA2{T,LT,F2,I}(fitting_obj_func, indiv_loss_func, pop, loss, ranks, crowdingdistance, 0, 0, seed, maxlen, popsize,
        tournamentsize, mutation_prob, crossover_prob,
        opcode_list(functionset), opcode_list(terminalset), numvars, threads, maxeval)
    
    println("""
        -- NEO GP (NSGA2)--
        SEED=$(alg.seed)
        THREADS=$threads
        MAX_LEN=$(alg.maxlen)
        POPSIZE=$(alg.popsize)
        TOURNAMENT_SIZE=$(alg.tournamentsize)
        INITIAL_DEPTH=$INITIAL_DEPTH
        CROSSOVER_PROB=$(alg.crossover_prob)
        PMUT_PER_NODE=$(alg.mutation_prob)
        FUNCTION_SET=$(join(alg.functionset, ","))
        TERMINAL_SET=$(join(alg.terminalset, ","))
        LIKELIHOOD=$(typeof(fitting_obj_func))
        LOSS=$indiv_loss_func
        MAXEVAL=$(something(alg.maxeval, default_maxeval(alg.fitting_obj_func)))
        ----------------------------------""")
   
    return alg
end

function initialize!(alg::NSGA2)
    T = parametertype(alg.fitting_obj_func) # loss value type (e.g., Float64)
    I = eltype(alg.pop)  # individual type
    # we use multi-threaded fitness evaluation workers and communicate via channels
    lossevalqueue = Channel{Tuple{I,Int}}(alg.popsize)
    resultqueue = Channel{Tuple{I,NTuple{2,T},Int,Int}}(alg.popsize)

    evalworkers = start_fitness_eval_workers(lossevalqueue, resultqueue, alg.nthreads, alg.indiv_loss_func, alg.maxeval)

    pop = alg.pop
    # create random pop
    @timeit global_timer "initial population" begin
        for i in 1:alg.popsize
            @timeit global_timer "create_random" indiv = create_random(I, alg.maxlen, INITIAL_DEPTH, alg.fitting_obj_func, alg.functionset, alg.terminalset, alg.numvars)
            put!(lossevalqueue, (indiv, i))
        end
        # place results by their slot index (not arrival order) so population layout is
        # independent of non-deterministic worker completion order
        newindivs = Vector{I}(undef, alg.popsize)
        newloss = Vector{NTuple{2,T}}(undef, alg.popsize)
        process_worker_results(resultqueue, alg.popsize) do (indiv, loss, fevals, idx)
            loss = map(fi -> isnan(fi) ? typemax(T) : fi, loss)

            newindivs[idx] = indiv
            newloss[idx] = loss
            alg.fevals += fevals
        end

        append!(alg.pop, newindivs)
        append!(alg.loss, newloss)
        resize!(alg.crowdingdistance, alg.popsize) # overwritten by crowding-distance calculation
        resize!(alg.ranks, alg.popsize)
        fill!(alg.ranks, typemax(Int)) # placeholder, updated below

        @timeit global_timer "calculate_fronts_with_duplicates!" calculate_fronts_with_duplicates!(alg)
    end

    @assert length(alg.pop) == alg.popsize
    
    close(lossevalqueue) # signal for workers to stop
    foreach(wait, evalworkers) # join workers
    alg
end

function evolve!(alg::NSGA2, generations::Int=100; iter_callback=nothing, max_time::Real=Inf)
    generations >= 1 || throw(ArgumentError("generations must be >= 1, got $generations"))
    start = time()
    T = parametertype(alg.fitting_obj_func) # loss value type (e.g., Float64)
    I = eltype(alg.pop)  # individual type
    # we use multi-threaded fitness evaluation workers and communicate via channels
    lossevalqueue = Channel{Tuple{I,Int}}(alg.popsize)
    resultqueue = Channel{Tuple{I,NTuple{2,T},Int,Int}}(alg.popsize)

    evalworkers = start_fitness_eval_workers(lossevalqueue, resultqueue, alg.nthreads, alg.indiv_loss_func, alg.maxeval)


    children = Vector{I}(undef, alg.popsize)
    childloss = Vector{NTuple{2,T}}(undef, alg.popsize)
    lastduration = 0.0 # of the previous generation
    @timeit global_timer "evolve_generations" for _ in 1:generations
        # stop before a generation that would end after max_time (if it takes as long as the previous one)
        genstart = time()
        genstart - start + lastduration > max_time && break
        alg.generation += 1
        gen = alg.generation

        # Bound child-generation tasks by the requested worker count.
        ngenworkers = min(alg.nthreads, alg.popsize)
        waitall([Threads.@spawn begin
            @timeit task_timer() "selection, xover, and mutation" for slot in worker:ngenworkers:alg.popsize
                # Reseed per slot so the offspring is independent of task scheduling.
                alg.seed >= 0 && Random.seed!(hash((alg.seed, gen, slot)))
                if rand() < alg.crossover_prob
                    parent1 = select_tournament(alg)
                    parent2 = select_tournament(alg)
                    child = crossover(parent1, parent2, alg.maxlen)
                else
                    parent = select_tournament(alg)
                    child = copy_indiv(parent)
                    mutate!(child, alg.mutation_prob, alg.numvars, alg.functionset, alg.terminalset)
                end
                children[slot] = child
            end
            merge_task_timer!()
            nothing
        end for worker in 1:ngenworkers])

        # Push children to the workers by length, so the longest individuals are fitted first
        for slot in sortperm(children, by = individual_length, rev = true)
            put!(lossevalqueue, (children[slot], slot))
        end

        # Results are written into the preallocated offspring-loss vector by
        # slot.
        process_worker_results(resultqueue, alg.popsize) do (indiv, loss, fevals, idx)
            childloss[idx] = map(fi -> isnan(fi) ? typemax(T) : fi, loss)
            children[idx] = indiv
            alg.fevals += fevals
        end

        # merge populations, calculate ranks and crowding distance, and truncate back to popsize
        append!(alg.pop, children)
        append!(alg.loss, childloss)
        oldranklen = length(alg.ranks)
        resize!(alg.ranks, oldranklen + alg.popsize)
        fill!(@view(alg.ranks[oldranklen+1:end]), typemax(Int)) # placeholder, updated below

        @timeit global_timer "calculate_fronts_with_duplicates!" fronts = calculate_fronts_with_duplicates!(alg)
        @timeit global_timer "truncate_population!" truncate_population!(alg, fronts)
        
        isnothing(iter_callback) || @timeit global_timer "iter_callback" with_fit_buffer_cache() do; iter_callback() end
        lastduration = time() - genstart
    end
    
    
    close(lossevalqueue) # signal for workers to stop
    foreach(wait, evalworkers) # join workers
    alg
end

function calculate_fronts_with_duplicates!(alg::NSGA2)
    pop = alg.pop
    loss = alg.loss
    
    # Sort once to identify duplicates and order the 2-D non-dominated sweep.
    @timeit global_timer "find uniq" begin
        p = sortperm(loss)
        isuniq = trues(length(pop))
        pos = 1
        while pos <= length(p)
            stop = pos + 1
            while stop <= length(p) && loss[p[stop]] == loss[p[pos]]
                stop += 1
            end
            if stop - pos > 1
                keep = minimum(@view p[pos:(stop - 1)])
                for q in pos:(stop - 1)
                    isuniq[p[q]] = p[q] == keep
                end
            end
            pos = stop
        end
        # `p` is already the lexicographic sort required by rank_intersect_sort;
        # filter it instead of sorting the unique losses a second time.
        uniq = filter(i -> isuniq[i], p)
        notuniq = findall(!, isuniq)
    end

    @timeit global_timer "ranking" begin    
        @timeit global_timer "rank_intersect_sort" fronts = rank_intersect_sort(loss; indices = uniq, perm = uniq)
        append!(fronts[end], notuniq) # duplicates remain worst-ranked

        for (rank, front) in enumerate(fronts)
            for idx in front
                alg.ranks[idx] = rank
            end
        end
        @timeit global_timer "crowdingdistance" crowdingdistance_manhattan!(alg.crowdingdistance, alg.loss, fronts)
    end
    fronts
end

# truncation selection based on rank and crowding distance
function truncate_population!(alg::NSGA2, fronts)
    newpopidx = Vector{Int}()
    for front in fronts
        if length(newpopidx) + length(front) <= alg.popsize
            append!(newpopidx, front)
        else
            # sort front by crowding distance and take the best individuals to fill the population
            sortedfront = sort(front, by = i -> alg.crowdingdistance[i], rev=true) # prefer higher crowding distance
            nneeded = alg.popsize - length(newpopidx)
            append!(newpopidx, sortedfront[1:nneeded])
            break
        end
    end
    
    # Sorting so that we cannot destroy an element that has not been copied yet.
    sort!(newpopidx)
    for (dest, src) in enumerate(newpopidx)
        alg.pop[dest] = alg.pop[src]
        alg.loss[dest] = alg.loss[src]
        alg.ranks[dest] = alg.ranks[src]
        alg.crowdingdistance[dest] = alg.crowdingdistance[src]
    end
    # truncate
    resize!(alg.pop, alg.popsize)
    resize!(alg.loss, alg.popsize)
    resize!(alg.ranks, alg.popsize)
    resize!(alg.crowdingdistance, alg.popsize)
end

all_individuals(alg::NSGA2) = collect(zip(alg.pop, alg.loss))
best_individuals(alg::NSGA2) = sort([(alg.pop[i], alg.loss[i]) for i in 1:length(alg.pop) if alg.ranks[i] == 1], by = x -> x[2]) # return all individuals in first front (sort by loss values)


# Tournament selection based on Pareto rank and crowding distance
function select_tournament(alg::NSGA2)
    pop = alg.pop
    tournamentsize = alg.tournamentsize
    n = length(pop)
    bestidx = rand(1:n)
    
    for _ in 2:tournamentsize
        otheridx = rand(1:n)   # drawn one at a time: no index vector to allocate
        if alg.ranks[otheridx] < alg.ranks[bestidx] || 
           (alg.ranks[otheridx] == alg.ranks[bestidx]) && (alg.crowdingdistance[otheridx] > alg.crowdingdistance[bestidx])
           bestidx = otheridx
        end
    end
    pop[bestidx]
end

# NSGA-II crowding distance for exactly two objectives: for each objective the
# front is sorted by that objective's value, boundary points get an infinite
# distance, and interior points accumulate the distance to their neighbors
# normalized by the objective's range.
function crowdingdistance_manhattan!(distance, loss::Vector{<:NTuple{2}}, fronts)
    n = length(loss)
    resize!(distance, n)
    fill!(distance, zero(eltype(distance)))

    for front in fronts
        isempty(front) && continue

        # sum distantces for each of the two objectives
        for obj in (1, 2)
            # sort front by objective
            sortedfront = sort(front, by = i -> loss[i][obj])
            # assign infinite distance to boundary points
            distance[sortedfront[1]] = Inf
            distance[sortedfront[end]] = Inf
            fmin = loss[sortedfront[1]][obj]
            fmax = loss[sortedfront[end]][obj]
            fmax == fmin && continue
            # compute distances for internal points
            for j in 2:(length(front)-1)
                prev = loss[sortedfront[j-1]][obj]
                next = loss[sortedfront[j+1]][obj]
                distance[sortedfront[j]] += (next - prev) / (fmax - fmin)
            end
        end
    end

    distance
end

function crowdingdistance_manhattan(loss, fronts)
    T = eltype(loss[1])
    distance = Vector{T}(undef, length(loss))
    crowdingdistance_manhattan!(distance, loss, fronts)
end
