#!/usr/bin/env bash
# Symbolic regression of the one-dimensional Salustowicz function
#     f(x) = exp(-x) x^3 cos(x) sin(x) (cos(x) sin(x)^2 - 1)
# as used by Vladislavleva et al. (2009): training data on x = 0.05:0.1:10, with
# Gaussian noise of 10% of the variance of f added.  The model is plotted on the range
# of their test data, x = -0.5:0.05:10.5 (extrapolation at both ends).  The function set
# has no power, log or square root, which are undefined for negative inputs.
#
#     examples/salustowicz.sh [extra options of runNeoGP.jl]
#
# The data are generated into examples/data/salustowicz_train.csv.  The output of the
# run is written to examples/results/salustowicz.csv, and, if gnuplot is installed, the
# model of the last generation is plotted over the data into
# examples/results/salustowicz.png.
#
# Environment: JULIA_NUM_THREADS (default: 4), NEOGP_RESULTS_DIR (default: examples/results).
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$root/examples/common.sh"

train="$root/examples/data/salustowicz_train.csv"
results="$(results_dir)"

# Generate the training data with noise of 10% of the variance of f
julia -e 'using Random; f(x) = exp(-x) * x^3 * cos(x) * sin(x) * (cos(x) * sin(x)^2 - 1);
    x = 0.05:0.1:10; y = f.(x); y .+= sqrt(0.1 * sum(abs2, y .- sum(y) / length(y)) / length(y)) .* randn(Xoshiro(1), length(y));
    write(ARGS[1], "x,target\n" * join(["$a,$b\n" for (a, b) in zip(x, y)]))' "$train"

# The main command
julia --project="$root/script" -t "${JULIA_NUM_THREADS:-4}" "$root/script/runNeoGP.jl" \
    "$train" target \
    --algorithm NSGA2 --functionset ADD,SUB,MUL,DIV,EXP,SIN,COS,SQR \
    --generations 100 --popsize 1000 --maxlen 30 --seed 1 \
    "$@" | tee "$results/salustowicz.csv"

#################################################
# ---- plot the model of the last generation ----
if ! term="$(gnuplot_png_terminal)"; then
    echo "gnuplot not found: skipping the plot" >&2
    exit 0
fi
expr="$(last_model_expression "$results/salustowicz.csv")"
echo "Model: $expr"
model="$(last_model_title "$results/salustowicz.csv")"

gnuplot \
    -e "train='$train'; set terminal $term size 900,560; set output '$results/salustowicz.png'" \
    -e "model = \"$model\"" \
    -e "f(x) = $expr" - <<'EOF_GP' || echo "plotting failed" >&2
set termoption noenhanced
set datafile separator ","
sqr(x) = x * x
set xlabel "x"
set ylabel "target"
set key bottom right
set title "Salustowicz: model of the last generation and noisy training data\n" . model
set xrange [-0.5:10.5]
set yrange [-1:1]
set samples 500
salustowicz(x) = exp(-x) * x**3 * cos(x) * sin(x) * (cos(x) * sin(x)**2 - 1)
plot salustowicz(x) with lines lc rgb "gray" lw 3 title "f(x)", \
     train every ::1 using 1:2 with points pt 7 ps 0.6 lc rgb "black" title "training data", \
     f(x) with lines lc rgb "red" lw 1.5 title "model"
EOF_GP
echo "Plot: $results/salustowicz.png"
