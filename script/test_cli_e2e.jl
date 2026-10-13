module ScriptCLIE2ETests

using Test
using DelimitedFiles

import NeoGP
using NeoGP: main

function write_dataset(path, rows)
    open(path, "w") do io
        println(io, "x1,x2,sigma,y")
        for (x1, x2, sigma, y) in rows
            println(io, join((x1, x2, sigma, y), ","))
        end
    end
    path
end

function make_synthetic_datasets(tmpdir)
    train_rows = [
        (-2.0, -1.0, 0.15, -2.25),
        (-1.5,  0.5, 0.12, -3.125),
        (-1.0,  1.0, 0.10, -2.5),
        (-0.5, -2.0, 0.14,  1.5),
        ( 0.0, -1.5, 0.11,  1.375),
        ( 0.5,  0.0, 0.10,  1.0),
        ( 1.0,  1.5, 0.13,  0.625),
        ( 1.5, -0.5, 0.16,  3.125),
        ( 2.0,  0.5, 0.18,  3.75),
        ( 2.5,  2.0, 0.20,  3.375),
    ]
    test_rows = [
        (-1.25, -0.75, 0.11, -1.8125),
        (-0.25,  1.25, 0.10, -0.6875),
        ( 0.75, -1.25, 0.12,  2.3125),
        ( 1.75,  0.75, 0.17,  2.6875),
    ]

    train = write_dataset(joinpath(tmpdir, "train.csv"), train_rows)
    test = write_dataset(joinpath(tmpdir, "test.csv"), test_rows)
    (; train, test)
end

function run_main(args)
    main(args)
end

# The CSV log only: `@time` prints to stdout as well, and its numbers vary.
function run_main_log(args)
    path = tempname()
    open(path, "w") do io
        redirect_stdout(() -> main(args), io)
    end
    lines = filter(l -> occursin(r"^\d+,", l), readlines(path))
    rm(path; force = true)
    lines
end

macro test_throws_message(msg, expr)
    quote
        ex = try
            $(esc(expr))
            nothing
        catch err
            err
        end
        @test ex isa ErrorException
        @test ex !== nothing
        @test occursin($(esc(msg)), ex.msg)
    end
end

function common_args(paths; algorithm, objective, inputs="x1,x2", extra_args=String[])
    [
        paths.train,
        "y",
        "--algorithm", algorithm,
        "--objective", objective,
        "--seed", "3141",
        "--generations", "3",
        "--popsize", "10",
        "--tournamentsize", "2",
        "--maxlen", "20",
        "--threads", "1",
        "--inputs", inputs,
        "--functionset", "ADD,SUB,MUL,DIV,LOG,EXP",
        "--test", paths.test,
        extra_args...,
    ]
end

@testset "CLI end-to-end" begin
    mktempdir() do tmpdir
        paths = make_synthetic_datasets(tmpdir)

        @testset "NSGA2 objectives" begin
            for likelihood in ("gaussian", "laplace"), objective in ("nll", "aic", "bic", "bic_sr", "dl", "fbf")
                @test run_main(common_args(paths; algorithm="nsga2", objective,
                    extra_args=["--likelihood", likelihood, "--sigma", "sigma"])) === nothing
            end
        end

        @testset "Basic objectives" begin
            for likelihood in ("gaussian", "laplace"), objective in ("nll", "aic", "bic", "bic_sr", "dl", "fbf")
                @test run_main(common_args(paths; algorithm="basic", objective,
                    extra_args=["--likelihood", likelihood, "--sigma", "sigma"])) === nothing
            end
        end

        @testset "Parameter complexity of the description length" begin
            lik = ["--likelihood", "gaussian", "--sigma", "sigma"]
            for variant in ("diag", "rot", "rot_scaled", "det")
                pc = [lik; "--param-complexity"; variant]
                # DL as the objective, as the model selection only, and as the fitness
                @test run_main(common_args(paths; algorithm="nsga2", objective="dl", extra_args=pc)) === nothing
                @test run_main(common_args(paths; algorithm="nsga2", objective="bic",
                    extra_args=[pc; "--model-selection"; "dl"])) === nothing
                @test run_main(common_args(paths; algorithm="basic", objective="dl", extra_args=pc)) === nothing
            end

            # The choice reaches the model selection and the logged DL columns.
            # A BIC objective fixes the evolution, so only those can differ: an
            # unset switch is the rotated variant, and the determinant variant
            # differs from it for any model (the diagonal and the rotations
            # coincide for a model with a single parameter, so they are not
            # compared here).
            dl_log(variant...) = run_main_log(common_args(paths; algorithm="nsga2", objective="bic",
                extra_args=[lik; "--model-selection"; "dl"; (isempty(variant) ? String[] : ["--param-complexity", variant[1]])]))
            @test dl_log() == dl_log("rot")
            @test dl_log("det") != dl_log("rot")

            # refused where no description length is computed
            @test_throws_message "param-complexity argument is only applicable" run_main(common_args(paths;
                algorithm="nsga2", objective="bic", extra_args=[lik; "--model-selection"; "bic_sr"; "--param-complexity"; "rot_scaled"]))
            # Basic ignores --model-selection, so DL is not in play there either
            @test_throws_message "param-complexity argument is only applicable" run_main(common_args(paths;
                algorithm="basic", objective="bic", extra_args=[lik; "--model-selection"; "dl"; "--param-complexity"; "diag"]))
            @test_throws_message "unknown parameter complexity value" run_main(common_args(paths;
                algorithm="nsga2", objective="dl", extra_args=[lik; "--param-complexity"; "rotated"]))
        end

        @testset "Noise model of the Gaussian and Laplace likelihoods" begin
            for likelihood in ("gaussian", "laplace"), objective in ("nll", "dl"),
                    noise in (String[],                                    # unknown noise, profiled
                              ["--sigma", "sigma", "--intrinsic-scatter"], # known noise plus scatter
                              ["--sigma", "0.2", "--intrinsic-scatter"])
                @test run_main(common_args(paths; algorithm="nsga2", objective,
                    extra_args=["--likelihood"; likelihood; noise])) === nothing
            end
            @test run_main(common_args(paths; algorithm="basic", objective="dl")) === nothing

            # the noise model reaches the fit: profiled, known, and known plus scatter differ
            bic_log(noise...) = run_main_log(common_args(paths; algorithm="nsga2", objective="bic",
                extra_args=collect(String, noise)))
            profiled = bic_log()
            known = bic_log("--sigma", "sigma")
            scatter = bic_log("--sigma", "sigma", "--intrinsic-scatter")
            @test profiled != known
            @test scatter != known

            # without --sigma the noise is estimated anyway; the flag only warns
            @test_logs (:warn, r"intrinsic-scatter without --sigma") match_mode=:any run_main(
                common_args(paths; algorithm="nsga2", objective="bic", extra_args=["--intrinsic-scatter"]))
        end

        @testset "Limit of the parameter fits" begin
            for algorithm in ("nsga2", "basic")
                @test run_main(common_args(paths; algorithm, objective="bic",
                    extra_args=["--maxeval", "5"])) === nothing
            end
            # a tighter limit reaches a different population, with Levenberg-Marquardt
            # (gaussian) and NLopt (laplace)
            for lik in (String[], ["--likelihood", "laplace"])
                @test run_main_log(common_args(paths; algorithm="nsga2", objective="bic", extra_args=[lik; "--maxeval"; "1"])) !=
                      run_main_log(common_args(paths; algorithm="nsga2", objective="bic", extra_args=lik))
            end
            @test_throws ArgumentError run_main(common_args(paths; algorithm="nsga2",
                objective="bic", extra_args=["--maxeval", "0"]))
        end

        @testset "Timer and CLI argument validation" begin
            # Timing is opt-in even for a single-worker run.
            NeoGP.TimerOutputs.disable_timer!(NeoGP.global_timer)
            result = redirect_stdout(devnull) do
                main(common_args(paths; algorithm="basic", objective="bic"))
            end
            @test result === nothing
            @test !NeoGP.global_timer.enabled
            result = redirect_stdout(devnull) do
                main(common_args(paths; algorithm="basic", objective="bic", extra_args=["--timer"]))
            end
            @test result === nothing
            @test NeoGP.global_timer.enabled

            @test_throws ArgumentError run_main(common_args(paths;
                algorithm="basic", objective="bic", extra_args=["--functionset", "ADD,NOT_AN_OPCODE"]))
            @test_throws ArgumentError run_main(common_args(paths;
                algorithm="basic", objective="bic", extra_args=["--inputs", "missing_column"]))
            @test_throws ArgumentError run_main(common_args(paths;
                algorithm="basic", objective="bic", extra_args=["--maxlen", "0"]))
            @test_throws ArgumentError run_main(common_args(paths;
                algorithm="basic", objective="bic", extra_args=["--generations", "0"]))
            @test_throws ArgumentError run_main(common_args(paths;
                algorithm="basic", objective="bic", extra_args=["--threads", string(Threads.nthreads() + 1)]))
        end

        @testset "ROXY likelihoods" begin
            # one error per input variable, then one for the target, as numbers ...
            mnr = ["--likelihood", "roxy_mnr_diagonal", "--sigma", "0.1,0.1,0.15"]
            for algorithm in ("nsga2", "basic"), objective in ("nll", "bic", "dl")
                @test run_main(common_args(paths; algorithm, objective, extra_args=mnr)) === nothing
            end
            # ... or as the same number of columns of the dataset, with an intrinsic scatter
            for (likelihood, inputs, sigma) in (("roxy_mnr_diagonal", "x1,x2", "sigma,sigma,sigma"),
                                                ("roxy_unif", "x1", "sigma,sigma"))
                @test run_main(common_args(paths; algorithm="nsga2", objective="bic", inputs,
                    extra_args=["--likelihood", likelihood, "--sigma", sigma,
                                "--intrinsic-scatter"])) === nothing
            end

            # the errors are required, one for each input variable and one for the target,
            # and all numbers or all column names
            for likelihood in ("roxy_mnr_diagonal", "roxy_unif")
                @test_throws ArgumentError run_main(common_args(paths; algorithm="nsga2",
                    objective="bic", extra_args=["--likelihood", likelihood]))
                @test_throws ArgumentError run_main(common_args(paths; algorithm="nsga2",
                    objective="bic", extra_args=["--likelihood", likelihood, "--sigma", "0.1"]))
            end
            @test_throws ArgumentError run_main(common_args(paths; algorithm="nsga2",
                objective="bic", extra_args=["--likelihood", "roxy_mnr_diagonal", "--sigma", "sigma,0.1,0.1"]))
        end

        @testset "Log-scaled data" begin
            positive = write_dataset(joinpath(tmpdir, "positive.csv"),
                [(x, 1 + x / 2, 0.1, 2x + 1 + x / 2) for x in 0.5:0.5:5])
            args(extra) = common_args((; train = positive, test = positive); algorithm="nsga2",
                objective="bic", inputs="x1", extra_args=extra)
            for likelihood in ("gaussian", "roxy_unif"), logscale in ("x", "y", "xy")
                sigma = likelihood == "gaussian" ? ["--sigma", "sigma"] : ["--sigma", "sigma,sigma"]
                @test run_main(args(["--likelihood", likelihood, "--logscale", logscale, sigma...])) === nothing
            end
            # the data must be positive
            @test_throws ArgumentError run_main(common_args(paths; algorithm="nsga2",
                objective="bic", extra_args=["--logscale", "xy"]))
        end
    end
end

end
