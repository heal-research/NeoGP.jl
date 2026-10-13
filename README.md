# NeoGP.jl

[![CI](https://github.com/heal-research/NeoGP.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/heal-research/NeoGP.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/heal-research/NeoGP.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/heal-research/NeoGP.jl)
[![Benchmarks](https://img.shields.io/badge/benchmarks-history-blue)](https://heal-research.github.io/NeoGP.jl/dev/bench/)

Tree-based genetic programming for symbolic regression.  NeoGP evolves
expressions whose parameters are fitted by maximum likelihood and selects them
with model-selection criteria, in particular the description length.

- Algorithms: single-objective genetic programming (`BasicAlgorithm`) and the
  two-objective NSGA-II (`NSGA2`), with multi-threaded fitness evaluation.
- Likelihoods ([SymRegLikelihoods](https://github.com/gkronber/SymReg.jl)): Gaussian
  and Laplace with known, estimated or intrinsic-scatter noise, and likelihoods
  that marginalize errors in the inputs.  Data can be fitted on a logarithmic scale
  while the models stay on the original scale.
- Model selection ([SymRegModelSelection](https://github.com/gkronber/SymReg.jl)):
  description length, fractional Bayes factor, AIC and BIC.
- A command line interface and a Julia API.

## Installation

NeoGP and its dependencies from [SymReg.jl](https://github.com/gkronber/SymReg.jl) and
[GeodesicLM.jl](https://github.com/gkronber/GeodesicLM.jl) are not registered; Julia 1.13 or newer
installs them from their git repositories:

```julia
using Pkg
Pkg.add(url = "https://github.com/heal-research/NeoGP.jl")
```

The command line interface and the examples run in the environment `script/` of a
checkout of this repository:

```bash
git clone https://github.com/heal-research/NeoGP.jl
cd NeoGP.jl
julia --project=script -e 'using Pkg; Pkg.instantiate()'
```

## Quickstart

[QUICKSTART.md](QUICKSTART.md) walks through three examples with the command line
interface: the friction factor of rough pipes (Nikuradse), the
radial acceleration relation of galaxies (RAR) with uncertainties in both variables, and
the synthetic Salustowicz function with noise, extrapolated beyond the training data
(references of the datasets are in the quickstart).
Run them with `examples/nikuradse_1.sh`, `examples/RAR.sh` and `examples/salustowicz.sh`; each writes its output and, if
gnuplot is installed, a plot of the model of the last generation over the data:

<p>
<img src="examples/results/nikuradse_1.png" alt="Nikuradse data and the model of the last generation" width="32%">
<img src="examples/results/RAR.png" alt="RAR data and the model of the last generation" width="32%">
<img src="examples/results/salustowicz.png" alt="Salustowicz data and the model of the last generation" width="32%">
</p>



## Command line interface

The command line script `script/runNeoGP.jl` runs an algorithm on a CSV file with a header, from the project root folder:

```
> julia --project=script script/runNeoGP.jl --help
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
```

Use `--help-all` for model selection, parameter complexity, fitting limits,
function set, test data, and other advanced options. 

### Datasets and likelihoods

All likelihoods available through the CLI script are row-based (the errors of 
different rows are independent) and use the same dataset: a CSV file with a 
header, the inputs `X`, the target `y`, and optionally the errors (standard 
deviations) of the inputs and the target.
The `--inputs` option selects the input columns (default: all columns except the
target and the error columns), and `--sigma` gives the errors as comma-separated
numbers or comma-separated column names (a mixture is not allowed):

| `--likelihood`       | `--sigma`                                              |
|----------------------|--------------------------------------------------------|
| `gaussian`, `laplace` | optional: the error of the target; if it is omitted, the noise is estimated |
| `roxy_unif`, `roxy_mnr_diagonal` | required: one error per input, then the error of the target; `roxy_unif` supports a single input |

The ROXY likelihoods (`roxy_unif`, `roxy_mnr_diagonal`) marginalize the errors of the inputs, see
Bartlett, D. J., Desmond, H. (2023). Marginalised Normal Regression: Unbiased curve fitting
in the presence of x-errors. arXiv:2309.00948.
<https://doi.org/10.48550/arXiv.2309.00948>;
code: [ROXY](https://github.com/DeaglanBartlett/roxy/tree/main).

`--intrinsic-scatter` estimates an intrinsic scatter in addition to the given errors
for all likelihoods. With `--logscale x`, `y` or `xy` the inputs, the target, or both
are log10-scaled (errors by first-order error propagation) while the model is still
defined on the original scale. For example, the radial acceleration relation
(`gbar`, `gobs` and their errors `e_gbar`, `e_gobs`) is fitted with

```
> julia --project=script script/runNeoGP.jl examples/data/RAR.csv gobs --inputs gbar \
      --likelihood roxy_mnr_diagonal --sigma e_gbar,e_gobs --logscale xy --intrinsic-scatter
```

The RMSE and R² columns of the output are computed on the scale of the likelihood,
i.e. on the log-scaled data.

## Development

Run the tests with

```bash
julia --project -e 'using Pkg; Pkg.test()'
```

CI additionally runs the end-to-end tests of the command line interface
(`script/test_cli_e2e.jl`), reports the coverage to
[Codecov](https://codecov.io/gh/heal-research/NeoGP.jl) (`coverage/run_coverage.jl` collects it
locally), and compares the benchmarks in `benchmark/` of a pull request with its base;
every push to `main` is added to the
[benchmark history](https://heal-research.github.io/NeoGP.jl/dev/bench/).  See
[DEVELOPMENT.md](DEVELOPMENT.md).

## Publications
If you use NeoGP please cite:

- Kronberger, Gabriel, et al. "Guiding Multi-Objective Genetic Programming with Description Length Improves Symbolic Regression Solutions." arXiv preprint arXiv:2605.22374 (2026).

BibTeX:
```
@misc{kronberger2026guidingmultiobjectivegeneticprogramming,
      title={Guiding Multi-Objective Genetic Programming with Description Length Improves Symbolic Regression Solutions}, 
      author={Gabriel Kronberger and Fabricio Olivetti de Franca and Deaglan J. Bartlett and Harry Desmond and Pedro G. Ferreira},
      year={2026},
      eprint={2605.22374},
      archivePrefix={arXiv},
      primaryClass={cs.NE},
      url={https://arxiv.org/abs/2605.22374}, 
}
```

## License

MIT, see [LICENSE](LICENSE).
