# Command line interface, run by `script/runNeoGP.jl`:
#
#     julia --project=script/ script/runNeoGP.jl --help


function show_brief_help(io::IO = stdout)
    print(io, """
usage: runNeoGP.jl training.csv target [options]

Tree-based symbolic regression with single-objective (basic) or multi-objective (NSGA2) genetic programming.

Common options:
  -a, --algorithm ALGORITHM  Algorithm type: NSGA2 or Basic (default: NSGA2)
  -g, --generations N        Number of generations (default: 100)
  -p, --popsize N            Population size (default: 1000)
  -m, --maxlen N             Maximum expression length (default: 50)
  -o, --objective OBJECTIVE  NLL, AIC, BIC, BIC_SR, DL, or FBF (default NSGA2: NLL, default Basic: BIC_SR)
      --sigma VALUE          Known noise scale/value or dataset column
      --test                 Test dataset (CSV format), same structure as training 
      --seed N               Random seed for reproducible runs
      --threads N            Number of fitness-evaluation workers (set <= 0 to use all Julia threads)
  -h, --help                 Show this help
      --help-all             Show all options, including advanced options
""")
end

"""
    main(argv)

The command line interface of NeoGP, run by `script/runNeoGP.jl`:

    julia --project=script script/runNeoGP.jl training.csv target [options]

`argv` is the vector of command line arguments: the CSV file with the training
data (with a header), the name of the target column and the options.  The
options select the algorithm, objective, likelihood and the settings of the run;
`--help` and `--help-all` list them.  The best individual of each generation is
printed as a line of comma-separated values after a header.
"""
function main(argv)
    # Help is handled below so the default screen can stay concise while the
    # full ArgParse table remains available through --help-all.
    s = ArgParseSettings(add_help = false)
    @add_arg_table! s begin
        "training"
            help = "Training data CSV file (positional)"
        "target"
            help = "Target variable name (positional)"
        "--algorithm", "-a"
            help = "Algorithm type (NSGA2, Basic)"
            arg_type = String
            default = "NSGA2"
        "--functionset"
            help = "Comma-separated list of functions to use in the function set (allowed values are ADD,SUB,MUL,DIV,INV,
POW,POWABS,EXP,LOG,LOGABS,SQRT,SQRTABS,SQR,SIN,COS,TAN,SINH,COSH,TANH)"
            default = "ADD,SUB,MUL,DIV,EXP,LOG,SQRT,POW"
        "--generations", "-g"
            help = "Number of generations"
            arg_type = Int
            default = 100
        "--help", "-h"
            help = "Show brief help and exit"
            action = :store_true
        "--help-all"
            help = "Show all options and exit"
            action = :store_true
        "--inputs"
            help = "Comma-separated list of input variable names (if no inputs are specified, all variables except the target and target error are used as inputs)"
            default = "" # if empty, all variables except target and target error are used as inputs
        "--intrinsic-scatter"
            help = "Estimate an intrinsic scatter additionally to the errors given by --sigma"
            action = :store_true
        "--likelihood", "-l"
            help = "Likelihood of data given model and parameters (default: gaussian; alternatives: gaussian, laplace, roxy_unif, roxy_mnr_diagonal). The ROXY likelihoods require --sigma and marginalize the errors of the inputs; roxy_unif supports a single input variable"
            default = "gaussian"
        "--logscale"
            help = "Log10-scale the inputs (x), the target (y), or both (xy) of the data. The model is still defined on the original scale and the data must be positive"
            default = ""
        "--max-time"
            help = "Maximum run time in seconds (default: no limit). No generation is started that would end after the limit if it takes as long as the previous one"
            arg_type = Float64
            default = Inf
        "--maxeval"
            help = "Maximum number of objective evaluations of each parameter fit, counted like fevals: residual evaluations of Levenberg-Marquardt for the Gaussian likelihood (default: 20; 50 can give better models at about twice the runtime), evaluations of the objective and its gradient of NLopt for the other likelihoods (default: 300)"
            arg_type = Int
        "--maxlen", "-m"
            help = "Maximum expression length"
            arg_type = Int
            default = 50
        "--model-selection"
            help = "Only for NSGA2: Model selection (defaults to DL, allowed values: NLL, AIC, BIC, BIC_SR, DL, FBF)"
            default = ""
        "--objective", "-o"
            help = "Objective used for optimization (default: NLL; possible values: NLL, AIC, BIC, BIC_SR, DL, FBF)"
            default = ""
        "--param-complexity"
            help = "Parameter complexity used in the description length, only with DL as objective or model selection (possible values: diag = diagonal of the Fisher information only, rot = rotated (default), rot_scaled = rotated in relative coordinates, independent of the units of the data, det = determinant of the Fisher information)"
            default = ""
        "--popsize", "-p"
            help = "Population size"
            arg_type = Int
            default = 1000
        "--seed"
            help = "Random seed for reproducible runs"
            arg_type = Int
            default = -1
        "--sigma"
            help = "Errors (standard deviations; the scale for the Laplace likelihood) as comma-separated numbers or comma-separated names of dataset columns, a mixture is not allowed. Gaussian and Laplace: one entry, the error of the target (without --sigma the noise is estimated). ROXY likelihoods (required): one entry for each input variable followed by one for the target"
        "--test"
            help = "Test dataset file in CSV format (defaults to training file)"
            default = ""
        "--threads"
            help = "Maximum number of parallel threads (make sure to set JULIA_NUM_THREADS environment variable accordingly, e.g. export JULIA_NUM_THREADS=4, or julia -t 4 runNeoGP.jl ...)"
            arg_type = Int
            default = -1
        "--timer"
            help = "Print a TimerOutputs report after evolution"
            action = :store_true
        "--tournamentsize", "-t"
            help = "Tournament size for selection; should be increased with larger population sizes"
            arg_type = Int
            default = 2
    end

    if any(arg -> arg == "--help-all", argv)
        show_help(stdout, s; exit_when_done = false)
        return nothing
    elseif any(arg -> arg == "--help" || arg == "-h", argv)
        show_brief_help()
        return nothing
    end

    parsed = parse_args(argv, s; as_symbols=false)
    if length(argv) < 2 || !haskey(parsed, "training") || !haskey(parsed, "target")
        println("Usage: NeoGP.jl trainingdata.csv targetvariable")
        return
    end

    trainingfilename = parsed["training"]
    algorithm = lowercase(parsed["algorithm"])
    targetname = parsed["target"]
    generations = parsed["generations"]
    popsize = parsed["popsize"]
    tournamentsize = parsed["tournamentsize"]
    maxlen = parsed["maxlen"]
    max_time = parsed["max-time"]
    generations >= 1 || throw(ArgumentError("generations must be >= 1, got $generations"))
    
    objective = lowercase(parsed["objective"])
    if isempty(objective)
        algorithm == "basic" && (objective = "bic_sr")
        algorithm == "nsga2" && (objective = "nll")
    end
    requested_model_selection = lowercase(parsed["model-selection"])
    if algorithm == "nsga2"
        if isempty(requested_model_selection)
            model_selection = "dl"
        else
            model_selection = requested_model_selection
        end
    else
        if !isempty(requested_model_selection)
            @warn "model_selection argument is only applicable for NSGA2 algorithm. Ignoring model_selection argument."
        end
        model_selection = objective
    end

    # The description length is the only criterion with a parameter complexity,
    # so the choice is refused unless DL is used, after the rules above have
    # settled the effective model selection.
    param_complexity_name = lowercase(parsed["param-complexity"])
    if !isempty(param_complexity_name) && objective != "dl" && model_selection != "dl"
        error("param-complexity argument is only applicable when the description length (dl) is the objective or the model selection")
    end
    paramCompFunc = if param_complexity_name in ("", "rot") NeoGP.param_complexity_rot
    elseif param_complexity_name == "diag"       NeoGP.param_complexity
    elseif param_complexity_name == "rot_scaled" NeoGP.param_complexity_rot_scaled
    elseif param_complexity_name == "det"        NeoGP.param_complexity_det
    else
        error("unknown parameter complexity value (allowed values are diag, rot, rot_scaled, det)")
    end

    likelihood_name = lowercase(parsed["likelihood"])
    sigmastr = parsed["sigma"]
    seed = parsed["seed"]
    nthreads = parsed["threads"] <= 0 ? Threads.nthreads() : parsed["threads"]
    timer_requested = parsed["timer"]
    if timer_requested
        TimerOutputs.reset_timer!(NeoGP.global_timer)
        TimerOutputs.enable_timer!(NeoGP.global_timer)
    else
        # Never emit timing data unless the user explicitly requested it.
        TimerOutputs.disable_timer!(NeoGP.global_timer)
    end
    testfilename = parsed["test"] == "" ? trainingfilename : parsed["test"]
    
    functionset = empty(NeoGP.DEFAULT_FUNCTIONSET)   # Vector{SymRegInterpreter.Opcode}; the algorithms sort it
    for fstr in split(parsed["functionset"], ",")
        name = strip(fstr)
        symbol = Symbol(name)
        isdefined(NeoGP, symbol) || throw(ArgumentError("unknown function name: $name"))
        f = getfield(NeoGP, symbol)
        f isa eltype(functionset) && degree(f) > 0 ||
            throw(ArgumentError("unknown function name: $name"))
        push!(functionset, f)
    end
    inputs = split(parsed["inputs"], ",", keepempty=false)

    
    objective in ("nll", "aic", "bic", "bic_sr", "dl", "fbf") ||
        error("unknown objective function value (allowed values are nll, aic, bic, bic_sr, fbf, dl)")

    # All likelihoods are row-based and use the same dataset interface; the
    # likelihood determines which errors the dataset needs.
    sigma = parse_sigma(sigmastr)
    errors = dataset_errors(likelihood_name, sigma)
    logscale_name = lowercase(parsed["logscale"])
    logscale_name in ("", "x", "y", "xy") ||
        throw(ArgumentError("unknown logscale value (allowed values are x, y, xy)"))
    logx = occursin('x', logscale_name)
    logy = occursin('y', logscale_name)

    train = load_dataset(Float32, trainingfilename, targetname, inputs, sigma, errors)
    test = load_dataset(Float32, testfilename, targetname, inputs, sigma, errors)
    train.varnames == test.varnames ||
        throw(ArgumentError("variable names in training and test datasets do not match"))
    if logx || logy
        train = logscale(train; x = logx, y = logy)
        test = logscale(test; x = logx, y = logy)
    end

    if parsed["intrinsic-scatter"] && errors === :none
        @warn "--intrinsic-scatter without --sigma: the noise is estimated (profiled) anyway"
    end
    numvars = size(train.X, 2)
    lossfunction = create_likelihood(likelihood_name, train;
                                     intrinsic_scatter = parsed["intrinsic-scatter"])
    # The model is defined on the original scale, the likelihood evaluates the
    # scaled data.
    if logx || logy
        lossfunction = NeoGP.LogScaledLikelihood(lossfunction; x = logx, y = logy)
    end

    if !isempty(model_selection)
        if model_selection == "nll"        model_selection_obj = NeoGP.negloglik
        elseif model_selection == "aic"    model_selection_obj = NeoGP.AIC
        elseif model_selection == "bic"    model_selection_obj = NeoGP.BIC
        elseif model_selection == "bic_sr" model_selection_obj = NeoGP.BIC_funccompl
        elseif model_selection == "dl"     model_selection_obj = NeoGP.DescriptionLengthObjective(paramCompFunc)
        elseif model_selection == "fbf"    model_selection_obj = NeoGP.fractional_bayes_factor
        else
            error("unknown model selection objective value (allowed values are nll, aic, bic, bic_sr, fbf, dl)")
        end
    end
    
    # Basic uses the model-selection criterion directly as fitness.
    if algorithm == "basic"
        gp = NeoGP.BasicAlgorithm(lossfunction, numvars; seed = seed, tournamentsize = tournamentsize, popsize=popsize, maxlen = maxlen,
            indiv_loss_func = model_selection_obj, threads = nthreads, maxeval = parsed["maxeval"], functionset = functionset)
    elseif algorithm == "nsga2"
        # for NSGA2 we distinguish between the (multi-objective)loss function and 
        # the model selection objective for selecting the best individual from the Pareto front at the end
        if objective == "nll"        loss_func = (NeoGP.negloglik, NeoGP.individual_length)
        elseif objective == "aic"    loss_func = (NeoGP.negloglik, NeoGP.individual_length)
        elseif objective == "bic"    loss_func = (NeoGP.negloglik, NeoGP.individual_length)
        elseif objective == "bic_sr" loss_func = (NeoGP.RoundedObjective(NeoGP.negloglik, 1), NeoGP.RoundedObjective(NeoGP.BIC_funccompl_penalty, 1))
        elseif objective == "dl"     loss_func = (NeoGP.RoundedObjective(NeoGP.negloglik, 1), NeoGP.RoundedObjective(NeoGP.DescriptionLengthComplexityObjective(paramCompFunc), 1))
        elseif objective == "fbf"    loss_func = (NeoGP.RoundedObjective(NeoGP.negloglik, 1), NeoGP.RoundedObjective(NeoGP.fractional_bayes_factor_complexity_penalty, 1))
        else error("unknown optimization objective function value (allowed values are nll, aic, bic, bic_sr, fbf, dl)")
        end
        gp = NeoGP.NSGA2(lossfunction, numvars; seed = seed, tournamentsize = tournamentsize, popsize = popsize, maxlen = maxlen,
            indiv_loss_func = loss_func, threads = nthreads, maxeval = parsed["maxeval"], functionset = functionset)
    else
        error("unknown algorithm type (allowed values are NSGA2, Basic)")
    end
    
    gen = 0
    println("gen,fevals,|bestfront|,best_loss,selection_obj,RMSE_train,RMSE_test,R2_train,R2_test,NLL,DL,func_compl,param_compl,FBF,size,expression")

    # for logging
    callback = () -> begin
        gen += 1
        
        front = NeoGP.best_individuals(gp)
        
        best_sel_obj, bestidx = findmin(tup -> model_selection_obj(tup[1]), front)  # find individual with best model selection objective
        best_indiv, best_loss = front[bestidx]
        
        modelparam = NeoGP.extractmodelparam(Float32, best_indiv)
        best_expr_str = NeoGP.tostring(best_indiv, train.varnames)
        ypred_train = NeoGP.predict!(best_indiv, train.X, modelparam)
        rmse_train  = sqrt(NeoGP.mean_squared_error(train.y, ypred_train))
        r2_train    = NeoGP.r2_score(train.y, ypred_train)
        ypred_test  = NeoGP.predict!(best_indiv, test.X, modelparam)
        rmse_test   = sqrt(NeoGP.mean_squared_error(test.y, ypred_test))
        r2_test     = NeoGP.r2_score(test.y, ypred_test)
        
        (nll, func_compl, param_compl) = NeoGP.description_length_terms(best_indiv; paramCompFunc)
        dl = nll + func_compl + param_compl
        
        fbf = NeoGP.fractional_bayes_factor(best_indiv)
        
        println("$gen,$(gp.fevals),$(length(front)),\"$(best_loss)\",$(best_sel_obj),$rmse_train,$rmse_test,$r2_train,$r2_test,$(nll),$(dl),$func_compl,$param_compl,$fbf,$(NeoGP.individual_length(best_indiv)),\"$(best_expr_str)\"")
        nothing
    end
    
    LinearAlgebra.BLAS.set_num_threads(1) # avoid BLAS multithreading conflicts

    start = time()
    NeoGP.initialize!(gp)
    callback() # report for initial population
    if generations > 1
        max_time -= time() - start # account for time spent in initialization and first callback
        NeoGP.evolve!(gp, generations - 1, iter_callback = callback, max_time = max_time)
    end
    timer_requested && TimerOutputs.print_timer(NeoGP.global_timer)

    nothing
end


# The CLI applies model-selection criteria as fitness functions, and the
# two-objective NSGA2 runs quantize both criteria to a 0.1 grid so that
# equally-good models share a Pareto-front slot.  As *named functors* (rather
# than per-run closures) these objectives have stable, precompilable types:
# the same type is recreated on every run and is covered by the
# precompilation workload (see precompile.jl).

"""
    RoundedObjective(criterion, digits) <: Function

`r(indiv) = round(criterion(indiv); digits)` — one quantized NSGA2 objective.
"""
struct RoundedObjective{F<:Function} <: Function
    criterion::F
    digits::Int
end
(r::RoundedObjective)(indiv::AbstractIndividual) = round(r.criterion(indiv); digits = r.digits)

"""
    DescriptionLengthObjective(paramCompFunc) <: Function

`d(indiv) = description_length(indiv; paramCompFunc)`.
"""
struct DescriptionLengthObjective{P} <: Function
    paramCompFunc::P
end
(d::DescriptionLengthObjective)(indiv::AbstractIndividual) =
    description_length(indiv; paramCompFunc = d.paramCompFunc)

"""
    DescriptionLengthComplexityObjective(paramCompFunc) <: Function

`d(indiv) = description_length_complexity_penalty(indiv; paramCompFunc)` — the
parameter-complexity component of the description length as one NSGA2 objective.
"""
struct DescriptionLengthComplexityObjective{P} <: Function
    paramCompFunc::P
end
(d::DescriptionLengthComplexityObjective)(indiv::AbstractIndividual) =
    description_length_complexity_penalty(indiv; paramCompFunc = d.paramCompFunc)