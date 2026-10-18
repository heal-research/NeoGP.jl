using TimerOutputs
using Random: MersenneTwister
# Reduced-scale algorithm tests: every individual's parameters are now fully
# optimized through `SymRegLikelihoods.optimize` (which `prepare()`s the
# likelihood and runs NLopt/LM), which is intentionally heavier than the
# former lightweight LBFGS.  A smaller population / fewer generations keep the
# suite green in reasonable time while still exercising initialize! + evolve!
# + best_individuals for every algorithm and loss type.
function test_alg(gp, generations = 3)
    NeoGP.initialize!(gp)
    NeoGP.evolve!(gp, generations)

    for (best_individual, fitness) in NeoGP.best_individuals(gp)
        println("$fitness $(NeoGP.tostring(best_individual))")
    end
end

function test_basicalgorithm(lossfunction, fitness_func, numvars, generations = 3)
    gp = NeoGP.BasicAlgorithm(lossfunction, numvars,
        seed = 3141, popsize = 30, maxlen = 30, tournamentsize = 2,
        indiv_loss_func = fitness_func, threads = 1)

    test_alg(gp, generations)
end

function test_NSGA2(lossfunction, fitness_func, numvars, generations = 3)
    gp = NeoGP.NSGA2(lossfunction, numvars,
        seed = 3141, popsize = 30, maxlen = 30, tournamentsize = 2,
        indiv_loss_func = fitness_func, threads = 1)

    test_alg(gp, generations)
end


@testset "Algorithm Tests" begin
    # Test different data types and likelihoods
    for T in (Float32, Float64)

        X = randn(T, 30, 3)
        y = convert(Vector{T}, X[:,1] .^ 2 .+ 2 .* X[:,2] .- 3 .* X[:,3] .+ 0.5)
        for likelihood in (NeoGP.GaussianProfiledLikelihood(X, y), NeoGP.LaplaceProfiledLikelihood(X, y)),
            fitness_func in ((args...) -> round(NeoGP.negloglik(args...), digits=2),
                             (args...) -> round(NeoGP.description_length(args...), digits=2))
            test_basicalgorithm(likelihood, fitness_func, size(X, 2))
            test_NSGA2(likelihood, (fitness_func, NeoGP.individual_length), size(X, 2))
        end
    end

    @testset "function and terminal sets are sorted opcode lists" begin
        # The draws must not depend on the container or order the sets are
        # given in (a Set's order follows hash(::Opcode), which changes with
        # every build of SymRegInterpreter), so a seed reproduces a run.
        X = randn(MersenneTwister(1), Float32, 30, 3)
        y = X[:, 1] .^ 2 .+ 2 .* X[:, 2]
        lik = NeoGP.GaussianProfiledLikelihood(X, y)
        fs = [NeoGP.MUL, NeoGP.ADD, NeoGP.EXP, NeoGP.SUB, NeoGP.DIV]
        fronts = map((Set(fs), reverse(fs), [fs; fs])) do functionset
            gp = NeoGP.NSGA2(lik, size(X, 2); seed = 7, popsize = 20, maxlen = 20, threads = 1, functionset,
                             terminalset = Set([NeoGP.PARAM, NeoGP.VAR]))
            @test gp.functionset == sort(fs)
            @test gp.terminalset == [NeoGP.PARAM, NeoGP.VAR]
            NeoGP.initialize!(gp)
            NeoGP.evolve!(gp, 3)
            [NeoGP.tostring(i) for (i, _) in NeoGP.best_individuals(gp)]
        end
        @test fronts[1] == fronts[2] == fronts[3]
        @test issorted(NeoGP.DEFAULT_FUNCTIONSET) && allunique(NeoGP.DEFAULT_FUNCTIONSET)
    end
end

@testset "Generations over several calls of evolve! and max_time" begin
    rng = MersenneTwister(4)
    X = randn(rng, Float32, 50, 2)
    y = X[:, 1] .^ 2 .- 2 .* X[:, 2] .+ 0.1f0 .* randn(rng, Float32, 50)
    lik = NeoGP.GaussianProfiledLikelihood(X, y)
    for algorithm in (NeoGP.BasicAlgorithm, NeoGP.NSGA2)
        function run(generations...; kwargs...)
            gp = redirect_stdout(devnull) do
                algorithm(lik, size(X, 2); seed = 5, popsize = 20, maxlen = 20, threads = 1)
            end
            NeoGP.initialize!(gp)
            foreach(g -> NeoGP.evolve!(gp, g; kwargs...), generations)
            gp
        end
        front(gp) = [(NeoGP.tostring(i), l) for (i, l) in NeoGP.best_individuals(gp)]

        # the offspring are seeded by the generation count over all calls
        gp = run(4)
        @test gp.generation == 4
        @test front(run(1, 1, 2)) == front(gp)
        @test front(run(2, 2)) == front(gp)
        @test front(run(4)) == front(gp)

        # no generation if max_time is exceeded, otherwise at least one
        @test run(5; max_time = 0).generation == 0
        @test run(5; max_time = -1).generation == 0
        @test run(5; max_time = 1e9).generation == 5
        t = @elapsed gp = run(10^6; max_time = 2.0)
        @test 1 <= gp.generation < 10^6
        @test t < 10
    end
end

@testset "Limit of the parameter fits" begin
    rng = MersenneTwister(1)
    X = randn(rng, Float32, 200, 2)
    y = 2.0f0 .* exp.(0.5f0 .* X[:, 1]) .- X[:, 2] .* X[:, 1] .+ 0.1f0 .* randn(rng, Float32, 200)
    lik = NeoGP.GaussianProfiledLikelihood(X, y)

    # the same initial population (same seed), each fit stopped at most as late:
    # Levenberg-Marquardt (least squares) and NLopt (Laplace)
    function initial_fevals(l; kwargs...)
        gp = redirect_stdout(devnull) do
            NeoGP.NSGA2(l, size(X, 2); seed = 3141, popsize = 30, maxlen = 30, threads = 1, kwargs...)
        end
        NeoGP.initialize!(gp)
        gp.fevals
    end
    @test initial_fevals(lik; maxeval = 2) < initial_fevals(lik)
    laplace = NeoGP.LaplaceProfiledLikelihood(X, y)
    @test initial_fevals(laplace; maxeval = 2) < initial_fevals(laplace)

    @test_throws ArgumentError NeoGP.BasicAlgorithm(lik, size(X, 2); maxeval = 0)
end

@testset "Algorithm parameter validation" begin
    X = randn(MersenneTwister(3), Float32, 10, 1)
    y = vec(X)
    lik = NeoGP.GaussianProfiledLikelihood(X, y)
    for algorithm in (NeoGP.BasicAlgorithm, NeoGP.NSGA2)
        @test_throws ArgumentError algorithm(lik, size(X, 2); popsize = 0)
        @test_throws ArgumentError algorithm(lik, size(X, 2); tournamentsize = 0)
        @test_throws ArgumentError algorithm(lik, size(X, 2); maxlen = 0)
        @test_throws ArgumentError algorithm(lik, size(X, 2); threads = Threads.nthreads() + 1)
        @test_throws ArgumentError algorithm(lik, size(X, 2); mutation_prob = -0.1)
        @test_throws ArgumentError algorithm(lik, size(X, 2); crossover_prob = 1.1)
        alg = redirect_stdout(devnull) do
            algorithm(lik, size(X, 2); popsize = 1, mutation_prob = 0.2, crossover_prob = 0.8)
        end
        @test alg.mutation_prob == 0.2
        @test alg.crossover_prob == 0.8
    end
    gp = redirect_stdout(devnull) do
        NeoGP.BasicAlgorithm(lik, size(X, 2); popsize = 1, threads = 1)
    end
    @test_throws ArgumentError NeoGP.evolve!(gp, 0)
end

@testset "An exception in an evaluation worker is reported, not a hang" begin
    rng = MersenneTwister(2)
    X = randn(rng, 100, 2)
    y = X[:, 1] .- 2 .* X[:, 2] .+ 0.1 .* randn(rng, 100)
    lik = NeoGP.GaussianProfiledLikelihood(X, y)
    failing(indiv) = error("evaluation failed")
    for alg in (:nsga2, :basic)
        gp = redirect_stdout(devnull) do
            alg === :nsga2 ?
                NeoGP.NSGA2(lik, size(X, 2); seed = 1, popsize = 20, maxlen = 20, threads = Threads.nthreads(),
                            indiv_loss_func = (failing, NeoGP.individual_length)) :
                NeoGP.BasicAlgorithm(lik, size(X, 2); seed = 1, popsize = 20, maxlen = 20, threads = Threads.nthreads(),
                                     indiv_loss_func = failing)
        end
        # before the fix the main loop waited forever for the lost results
        t = Threads.@spawn try
            NeoGP.initialize!(gp)
            nothing
        catch ex
            ex
        end
        @test timedwait(() -> istaskdone(t), 60.0) === :ok
        ex = fetch(t)
        @test ex isa CapturedException
        @test occursin("evaluation failed", sprint(showerror, ex))
    end
end
