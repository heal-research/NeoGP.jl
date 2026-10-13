"""
    NeoGP

Tree-based genetic programming for symbolic regression.  Individuals are
expressions (linear programs of `SymRegInterpreter`) whose parameters are fitted
by maximum likelihood (`SymRegLikelihoods`) and which are selected with
model-selection criteria such as the description length (`SymRegModelSelection`).

Two algorithms are provided, a single-objective [`BasicAlgorithm`](@ref) and the
two-objective [`NSGA2`](@ref).  A typical run loads a [`Dataset`](@ref), creates
a likelihood with [`create_likelihood`](@ref), builds an algorithm from it,
calls [`initialize!`](@ref) and [`evolve!`](@ref), and reads the result with
[`best_individuals`](@ref):

```julia
using NeoGP
dataset = load_dataset(Float32, "data.csv", "y")
likelihood = create_likelihood("gaussian", dataset)
gp = NSGA2(likelihood, size(dataset.X, 2); popsize = 200, maxlen = 30)
initialize!(gp)
evolve!(gp, 50)
for (indiv, loss) in best_individuals(gp)
    println(loss, "  ", tostring(indiv, dataset.varnames))
end
```

The command line interface [`main`](@ref) is run by `script/runNeoGP.jl`.
"""
module NeoGP

using TimerOutputs
using Random
using PrecompileTools: @setup_workload, @compile_workload
using ArgParse: ArgParseSettings, @add_arg_table!, parse_args, show_help
using DelimitedFiles: readdlm
import LinearAlgebra
using SymRegInterpreter
import SymRegLikelihoods: SymRegLikelihoods, parametertype, n_likelihood_params,
   AbstractLikelihood,
   AbstractLossFunction,
   GaussianLikelihood,
   GaussianProfiledLikelihood, 
   GaussianScatterLikelihood, 
   LaplaceLikelihood,
   LaplaceProfiledLikelihood,
   LaplaceScatterLikelihood,
   MNRDenseLikelihood,
   MNRBandedLikelihood,
   MNRDiagonalLikelihood,
   XUniformDiagonalLikelihood
import SymRegModelSelection

# The model-selection criteria are extended with methods for `Individual`.
import SymRegModelSelection: description_length_terms,
    description_length_complexity_penalty,
    fractional_bayes_factor, fractional_bayes_factor_terms,
    fractional_bayes_factor_complexity_penalty,
    AIC, BIC, BIC_funccompl, BIC_funccompl_penalty,
    func_complexity, param_complexity, param_complexity_det, param_complexity_rot,
    param_complexity_rot_scaled

const SL = SymRegLikelihoods
const SMS = SymRegModelSelection

export AbstractAlgorithm, BasicAlgorithm, NSGA2, initialize!, evolve!,
    best_individuals, all_individuals,
    AbstractIndividual, Individual, predict, tostring, negloglik, individual_length,
    fractional_bayes_factor, AIC, BIC, BIC_funccompl,
    Dataset, load_dataset, logscale, create_likelihood, LogScaledLikelihood

public main,   # command line interface
    DEFAULT_FUNCTIONSET, DEFAULT_TERMINALSET, global_timer,
    # interface of individuals
    copy_indiv, extractparam, extractmodelparam, updateparam!, getlossfunction,
    getprogram, predict!, create_random, crossover, mutate!, individual_depth,
    print_indiv, optimize!, loss,
    # model-selection criteria and their components
    description_length, description_length_terms, description_length_complexity_penalty,
    fractional_bayes_factor_terms, fractional_bayes_factor_complexity_penalty,
    BIC_funccompl_penalty, func_complexity,
    param_complexity, param_complexity_rot, param_complexity_rot_scaled, param_complexity_det,
    # objective functions for the algorithms
    RoundedObjective, DescriptionLengthObjective, DescriptionLengthComplexityObjective,
    # evaluation metrics
    mean_squared_error, r2_score

import SymRegInterpreter: Instruction, Opcode, Model, ExprModel, CodeModel, code, n_param,
    interpret_vec, interpret_jac!,
    VAR, SCALEDVAR, PARAM, CONSTANT,
    ADD, SUB, MUL, DIV, INV, EXP, LOG, LOGABS, SQRT, SQRTABS, SQR, POW, POWABS,
    SIN, COS, TAN, SINH, COSH, TANH,
    degree, opcode, print_program,
    with_fit_buffer_cache,
    to_logspace_x_model, to_logspace_y_model, to_logspace_xy_model

include("programops.jl")

# Not using abs-protected operators by default because they tend to produce models
# with cusps and discontinuities that are not well-behaved for optimization and model selection.
"""
    DEFAULT_FUNCTIONSET

The opcodes of the operators that the algorithms use by default: `ADD`, `SUB`,
`MUL`, `DIV`, `INV`, `EXP`, `LOG`, `SQRT`, `SQR` and `POW`, as a sorted vector
(see `opcode_list`).  The opcodes are those of `SymRegInterpreter`.
"""
const DEFAULT_FUNCTIONSET = opcode_list([ADD, SUB, MUL, DIV, INV, EXP, LOG,
                                         SQRT, SQR, POW])

"""
    DEFAULT_TERMINALSET

The opcodes of the terminals that the algorithms use by default: `VAR` (a
variable), `SCALEDVAR` (a variable multiplied by a parameter) and `PARAM` (a
parameter), as a sorted vector.
"""
const DEFAULT_TERMINALSET = opcode_list([VAR, SCALEDVAR, PARAM])

"""
    global_timer

The `TimerOutput` in which the algorithms record their timings.  [`main`](@ref)
disables it unless `--timer` is given; to use it from Julia, enable it with
`TimerOutputs.enable_timer!(NeoGP.global_timer)` and print it with
`TimerOutputs.print_timer(NeoGP.global_timer)`.
"""
const global_timer = TimerOutput()

# TimerOutputs' `@timeit` mutates a shared timer stack, so timing into
# `global_timer` is only safe from the main task
const task_timer = Base.OncePerTask(TimerOutput)

# Merge the calling task's timer into `global_timer`.  Must only be called
# where no other task concurrently runs `@timeit` on `global_timer`.
merge_task_timer!() = merge!(global_timer, task_timer())

include("abstractindividual.jl")
include("lossfunctions.jl")
include("dataset.jl")
include("individual.jl")

# Global defaults for algorithms
const INITIAL_DEPTH = 5        # initial depth for random individuals
const PMUT_PER_NODE = 0.05     # per-node mutation probability
const CROSSOVER_PROB = 0.9     # (1 - CROSSOVER_PROB) individuals are mutated, and each node has PMUT_PER_NODE probability

include("algorithms/abstractalgorithm.jl")
include("algorithms/evalworkers.jl")
include("algorithms/basic.jl")
include("algorithms/rank_intersect.jl")
include("algorithms/nsga2.jl")

include("cli.jl")

include("precompile.jl")

end
