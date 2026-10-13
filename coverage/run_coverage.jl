# Collect the line coverage of the unit tests and of the command line end-to-end
# tests (`script/test_cli_e2e.jl`) of NeoGP and write an LCOV tracefile, which can
# be analysed with the `lcov` tools (or uploaded to Codecov / Coveralls in CI).
#
# Both test suites run in separate Julia processes, tracking only the `src/`
# directory of the package.  The resulting `.cov` files are merged and converted
# with CoverageTools.jl, which also parses the sources and marks lines of
# functions that were never compiled as not covered (Julia's native LCOV output
# omits them).  The `.cov` files are removed from `src/` afterwards.
#
# Outputs (paths in the tracefile are relative to the repository root):
#   coverage/results/lcov.info   tracefile of the unit and end-to-end tests
#   coverage/results/html/       HTML report (only with `--html`, needs `genhtml`)
#
# Usage (from the repository root):
#   julia --project=coverage -e 'using Pkg; Pkg.instantiate()'   # once
#   julia --project=coverage coverage/run_coverage.jl
#   julia --project=coverage coverage/run_coverage.jl --html
#
# Analysis with lcov:
#   lcov --summary coverage/results/lcov.info
#   lcov --list coverage/results/lcov.info
#   genhtml coverage/results/lcov.info --output-directory coverage/results/html
#
# The script exits with a non-zero status if a test suite fails; the tracefile is
# written regardless.

using CoverageTools
using Printf

const REPO_DIR = realpath(joinpath(@__DIR__, ".."))
const RESULTS_DIR = joinpath(@__DIR__, "results")
const SRC_DIR = "src"

# Runs `args` in a fresh Julia process (project `project`) and returns whether it succeeded.
function run_julia(project, args::Cmd)
    cmd = `$(Base.julia_cmd()) --startup-file=no --project=$project $args`
    return success(run(ignorestatus(cmd)))
end

function main(args)
    html = "--html" in args
    unknown = filter(!=("--html"), args)
    isempty(unknown) || error("unknown arguments $(join(unknown, ", ")); expected --html")
    mkpath(RESULTS_DIR)
    failed = String[]
    coverage = "@" * joinpath(REPO_DIR, SRC_DIR)

    # relative paths keep the tracefile independent of the checkout location
    cd(REPO_DIR) do
        clean_folder(SRC_DIR)

        @info "Running the unit tests with coverage"
        code = "using Pkg; Pkg.instantiate(); Pkg.test(; coverage = $(repr(coverage)))"
        run_julia(".", `-e $code`) || push!(failed, "unit tests")

        @info "Running the command line end-to-end tests with coverage"
        run_julia("script", `-e "using Pkg; Pkg.instantiate()"`)
        run_julia("script", `--code-coverage=$coverage script/test_cli_e2e.jl`) ||
            push!(failed, "end-to-end tests")

        fcs = process_folder(SRC_DIR)
        clean_folder(SRC_DIR)
        LCOV.writefile(joinpath(RESULTS_DIR, "lcov.info"), fcs)

        covered, total = get_summary(fcs)
        println("\nLine coverage of $SRC_DIR/")
        for fc in sort(fcs; by = fc -> fc.filename)
            c, t = get_summary(fc)
            @printf("  %-36s %6.2f%%  (%d / %d lines)\n", fc.filename,
                    t == 0 ? 100.0 : 100 * c / t, c, t)
        end
        @printf("  %-36s %6.2f%%  (%d / %d lines)\n", "total",
                total == 0 ? 0.0 : 100 * covered / total, covered, total)
    end

    tracefile = joinpath(RESULTS_DIR, "lcov.info")
    println("\nLCOV tracefile: ", relpath(tracefile, REPO_DIR))

    if html
        htmldir = joinpath(RESULTS_DIR, "html")
        if Sys.which("genhtml") === nothing
            @warn "`genhtml` not found; skipping HTML report (install lcov)"
        else
            cd(REPO_DIR) do
                run(`genhtml --quiet $tracefile --output-directory $htmldir`)
            end
            println("HTML report:    ", relpath(joinpath(htmldir, "index.html"), REPO_DIR))
        end
    end

    if !isempty(failed)
        @error "Failures in: $(join(failed, ", "))"
        exit(1)
    end
    return nothing
end

main(ARGS)
