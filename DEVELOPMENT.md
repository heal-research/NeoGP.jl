### Developing NeoGP together with SymReg.jl and GeodesicLM.jl

`Project.toml` takes the SymReg packages from the tag `v0.1.0` of SymReg.jl, and
SymRegLikelihoods takes GeodesicLM from the tag `v0.1.0` of GeodesicLM.jl.  To work
on local checkouts of all three repositories at once, use an environment outside the
repositories whose `[sources]` point at the checkouts; these paths take precedence
over the URLs of the packages:

```toml
# e.g. ~/.julia/dev/SymRegDev/Project.toml (add the test dependencies to [deps] as well)
[deps]
GeodesicLM = "ef14dfaf-8eb7-4021-bbb1-710ada96a62d"
NeoGP = "fe65fcaf-0a20-4e9a-99a2-9f417ca4b589"
SymRegInterpreter = "9cc144f2-1b19-4da5-9bda-8b16939d5016"
SymRegLikelihoods = "5dbddfb3-81a2-4501-9291-94e15007dd70"
SymRegModelSelection = "43995dcf-12bc-4b34-8149-31828cb04d39"

[sources]
GeodesicLM = {path = "../GeodesicLM.jl"}
NeoGP = {path = "../NeoGP.jl"}
SymRegInterpreter = {path = "../SymReg.jl/SymRegInterpreter"}
SymRegLikelihoods = {path = "../SymReg.jl/SymRegLikelihoods"}
SymRegModelSelection = {path = "../SymReg.jl/SymRegModelSelection"}
```

Run the tests in this environment with `include("../NeoGP.jl/test/runtests.jl")`
rather than `Pkg.test("NeoGP")`, whose sandbox applies the URLs of NeoGP's `[sources]`.


### Tests

```bash
julia --project -e 'using Pkg; Pkg.test()'                 # unit tests
julia --project=script script/test_cli_e2e.jl              # end-to-end tests of the command line interface
```

The unit tests include a check that every exported and public name has a docstring.
CI runs both on Julia 1.13 (the lower bound of `[compat]`), the latest release and
the pre-release, and a job with the lowest compatible versions of the registered
dependencies.  The jobs are skipped while the repository is private.


### Precompilation workload

`NeoGP` precompiles its hot paths with `PrecompileTools` (`src/precompile.jl`):
short CLI runs for every objective, plus prediction, parameter extraction, a
bounded parameter fit and every objective function (with every selectable
parameter complexity) for the whole Gaussian likelihood family (plain,
profiled, scatter and log-scaled) in `Float32` and `Float64`.

The workload is on by default and is turned off through the
`precompile_workload` local preference of this package in its
`LocalPreferences.toml` (`[NeoGP]` section), e.g. via

```julia
using Preferences
Preferences.set_preferences!("NeoGP"; precompile_workload = false)
```

followed by `Pkg.precompile()`.  `LocalPreferences.toml` is not under version control,
so users always get the precompiled first run; turn the workload off in your
checkout for a fast dev loop.


### Code coverage

CI runs the unit tests and the end-to-end tests of the command line interface
with coverage of `src/` and uploads it to [Codecov](https://codecov.io/gh/heal-research/NeoGP.jl)
(configured in `codecov.yml`; coverage is reported, it never blocks a pull request).

`coverage/run_coverage.jl` collects the same coverage locally.  It runs both test
suites in separate processes with coverage of `src/`, merges the results with
[CoverageTools.jl](https://github.com/JuliaCI/CoverageTools.jl) (which also counts
the lines of functions that were never compiled), removes the `.cov` files and writes
the LCOV tracefile `coverage/results/lcov.info`:

```bash
julia --project=coverage -e 'using Pkg; Pkg.instantiate()'   # once
julia --project=coverage coverage/run_coverage.jl            # add --html for an HTML report (needs lcov's genhtml)
lcov --summary coverage/results/lcov.info
```


### Benchmarking

The benchmarks in `benchmark/benchmarks.jl` are a `BenchmarkTools` suite for
the interpreter and likelihood operations on individuals; see
[`benchmark/README.md`](benchmark/README.md).  Compare two revisions locally with
AirspeedVelocity:

```bash
# Compare the committed HEAD with the current working tree (including local changes).
julia --project=benchmark benchmark/run_benchmarks.jl

# Or compare any two revisions, tags, or commit hashes.
julia --project=benchmark benchmark/run_benchmarks.jl <rev1> <rev2>
```

The first invocation resolves the benchmark environment. For each committed
revision, the runner creates a temporary detached Git worktree, benchmarks it,
and removes it afterward. The special revision `dirty` refers to the current
working tree, so `HEAD dirty` is useful for measuring uncommitted changes.
Raw AirspeedVelocity results are retained in `benchmark/results/`; the runner
prints Markdown tables comparing median runtime and memory/allocation usage.

In CI, `.github/workflows/Benchmark.yml` runs every benchmark once with
`benchmark/run_suite.jl` (so that a broken suite fails the build), compares a pull request
with its base in the job summary, and adds the medians of every push to `main` to the
[benchmark history](https://heal-research.github.io/NeoGP.jl/dev/bench/) on GitHub Pages (the
`gh-pages` branch, `dev/bench`).  The timings come from shared runners; the allocation
table is the reliable part.


### Releasing

1. Check that CI is green and that `version` in `Project.toml` and the tags in `[sources]` are right.
2. Tag the commit, `git tag v0.1.0 && git push origin v0.1.0`.
3. The package is not registered; the dependencies on SymReg.jl are `[sources]` entries with a tag, so a
   release of SymReg.jl comes first.
