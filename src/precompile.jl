# Precompilation workload, consisting of two parts:
#
#   1. short runs of the command line interface (`main`) for every objective,
#      which also compiles the GP operators, the worker/evaluation pipeline
#      and the CLI's stable objective functors (see cli.jl);
#   2. the whole Gaussian likelihood family (plain, profiled, scatter and the
#      log-scaled variants) in Float32 and Float64: prediction, parameter
#      extraction, a bounded parameter fit, and every objective function
#      (including every selectable parameter complexity) per combination.
#
# So a CLI or library run starts without compiling these paths first.  The
# fits, the information matrix for every ForwardDiff chunk size and the
# model-selection criteria are precompiled by SymRegLikelihoods and
# SymRegModelSelection.
#
# The workload is gated by PrecompileTools through the `precompile_workload`
# local preference of THIS package (default on).  Turn it off by setting
#
#     [NeoGP]
#     precompile_workload = false
#
# in the package's `LocalPreferences.toml` (e.g. via
# `Preferences.set_preferences!("NeoGP"; precompile_workload = false)`) and
# precompiling again (`Pkg.precompile()`).  The `LocalPreferences.toml` of
# this repo disables the workload for a fast dev loop; enable it before
# shipping so users get the precompiled first run.

@setup_workload begin
    @compile_workload begin
        # --- short CLI runs for every objective ----------------------------
        for T in (Float32,)
            n, nvar = 64, 3
            rng = Random.Xoshiro(1)
            X = randn(rng, T, n, nvar)
            y = T(2) .* X[:, 1] .- X[:, 2] .* X[:, 3] .+ T(0.1) .* randn(rng, T, n)
            mktempdir() do dir
                csv = joinpath(dir, "data.csv")
                open(csv, "w") do io
                    println(io, "x1,x2,x3,y")
                    for i in 1:n
                        println(io, join((X[i, 1], X[i, 2], X[i, 3], y[i]), ","))
                    end
                end
                # `--threads 1`: with more threads `main` disables the global timer,
                # which would then be stored disabled in the package image
                redirect_stdout(devnull) do
                    for objective in ("nll", "aic", "bic", "bic_sr", "dl", "fbf")
                        main([csv, "y", "-o", objective, "-p", "20", "-g", "3",
                              "-m", "20", "--seed", "1", "--threads", "1"])
                    end
                    main([csv, "y", "-o", "nll", "-p", "20", "-g", "3", "-m", "20",
                          "--seed", "1", "--threads", "1", "--maxeval", "10"])
                end
            end
        end

        # --- Gaussian likelihood family in Float32 and Float64 ---------------
        for T in (Float32, Float64)
            n, nvar = 64, 3
            rng = Random.Xoshiro(1)
            X = randn(rng, T, n, nvar)
            y = T(2) .* X[:, 1] .- X[:, 2] .* X[:, 3] .+ T(0.1) .* randn(rng, T, n)
            yerr = fill(T(0.05), n)
            for likelihood in (GaussianLikelihood(X, y, yerr),
                               GaussianProfiledLikelihood(X, y),
                               GaussianScatterLikelihood(X, y, yerr),
                               # LogScaledLikelihood(profiled; x = true),
                               # LogScaledLikelihood(profiled; y = true),
                               # LogScaledLikelihood(profiled; x = true, y = true)
                               )
                indiv = create_random(Individual{T, typeof(likelihood)}, 20, 5,
                                      likelihood, DEFAULT_FUNCTIONSET, DEFAULT_TERMINALSET, nvar)
                # prediction and parameter extraction
                predict!(indiv, X, extractmodelparam(T, indiv))
                extractparam(T, indiv)
                # every objective function
                negloglik(indiv)
                AIC(indiv)
                BIC(indiv)
                BIC_funccompl(indiv)
                BIC_funccompl_penalty(indiv)
                func_complexity(indiv)
                individual_length(indiv)
                description_length_terms(indiv)
                description_length(indiv)
                description_length_complexity_penalty(indiv)
                fractional_bayes_factor(indiv)
                fractional_bayes_factor_terms(indiv)
                fractional_bayes_factor_complexity_penalty(indiv)
                # ... with every parameter complexity the CLI can select
                for pcf in (param_complexity, param_complexity_rot,
                            param_complexity_rot_scaled, param_complexity_det)
                    description_length(indiv; paramCompFunc = pcf)
                    description_length_complexity_penalty(indiv; paramCompFunc = pcf)
                end
                # the CLI's stable objective functors (see cli.jl)
                RoundedObjective(negloglik, 1)(indiv)
                RoundedObjective(BIC_funccompl_penalty, 1)(indiv)
                DescriptionLengthObjective(param_complexity_rot)(indiv)
                RoundedObjective(DescriptionLengthComplexityObjective(param_complexity_rot), 1)(indiv)
                # a bounded parameter fit (the workers' path); random models
                # may occasionally be degenerate, so never fail precompilation
                try
                    evaluate_loss!(indiv, negloglik; optimize = true, maxeval = 8)
                catch ex
                    @debug "skipped a degenerate precompile fit" exception = ex
                end
            end
        end
    end
end