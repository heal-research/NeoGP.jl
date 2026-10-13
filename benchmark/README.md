# NeoGP benchmarks

`benchmarks.jl` defines the suite (`const SUITE = BenchmarkGroup()`, BenchmarkTools) that
[AirspeedVelocity.jl](https://github.com/MilesCranmer/AirspeedVelocity.jl) runs.  It
measures the operations that dominate a run of the algorithms, on individuals with the
Gaussian likelihoods in `Float32` and `Float64`:

| Group | Individual | Benchmarks |
|---|---|---|
| `gaussian likelihood` | `p1*x1 + p2*x2 + p3`, 500 and 5000 observations | `optimize!`, `negloglik`-based criteria (`AIC`, `BIC`), `description_length`, `fractional_bayes_factor` |
| `pow-log-exp profiled likelihood` | `p1*abs(x1)^p2 + p3*log(x2) + p4*exp(p5*x1)`, 500 observations, profiled noise | `optimize!`, `negloglik`, `description_length` |
| `pow-log-exp scatter likelihood` | the same model, known noise and intrinsic scatter | `optimize!`, `negloglik`, `description_length` |

Keep the problems fixed and deterministic, so that revisions can be compared: add new
groups instead of changing the existing ones.

## Files

- `run_suite.jl` runs every benchmark once and prints a summary; CI uses it to check that the suite
  works.  With a file name as argument it also saves the medians (BenchmarkTools JSON) for the benchmark history.
- `run_benchmarks.jl` compares two revisions (default `HEAD dirty`) with AirspeedVelocity and prints
  Markdown tables of the median runtime and the memory.
- `Project.toml` is the benchmark environment.

## Running

```bash
julia --project=benchmark -e 'using Pkg; Pkg.instantiate()'
julia --project=benchmark benchmark/run_suite.jl                      # every benchmark once
julia --project=benchmark benchmark/run_benchmarks.jl                 # HEAD vs. the working tree
julia --project=benchmark benchmark/run_benchmarks.jl v0.1.0 HEAD     # two revisions
```

In CI `.github/workflows/Benchmark.yml` runs the suite, compares each pull request with its base
and stores the medians of every push to `main` for the charts on GitHub Pages.  Timings on shared
runners are noisy; look at the allocation table for reliable regressions.
