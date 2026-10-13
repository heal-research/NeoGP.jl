#!/usr/bin/env bash
# Symbolic regression of the friction factor of turbulent flow in rough pipes
# (Nikuradse data): the target is a function of the relative roughness `r_k` and
# the logarithm of the Reynolds number `log_Re`.  Gaussian noise of unknown variance.
#
#     examples/nikuradse_1.sh [extra options of runNeoGP.jl]
#
# The output of the run is written to examples/results/nikuradse_1.csv, and, if
# gnuplot is installed, the model of the last generation is plotted over the
# data into examples/results/nikuradse_1.png (one curve for each value of `r_k`).
#
# Environment: JULIA_NUM_THREADS (default: 4), NEOGP_RESULTS_DIR (default: examples/results).
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$root/examples/common.sh"

train="$root/examples/data/nikuradse_1_train.csv"
test="$root/examples/data/nikuradse_1_test.csv"
results="$(results_dir)"

# The main command
julia --project="$root/script" -t "${JULIA_NUM_THREADS:-4}" "$root/script/runNeoGP.jl" \
    "$train" target --test "$test" \
    --algorithm NSGA2  \
    --generations 200 --popsize 1000 --maxlen 30 --seed 2 \
    --param-complexity rot \
    "$@" | tee "$results/nikuradse_1.csv"

#################################################
# ---- plot the model of the last generation ----
if ! term="$(gnuplot_png_terminal)"; then
    echo "gnuplot not found: skipping the plot" >&2
    exit 0
fi
expr="$(last_model_expression "$results/nikuradse_1.csv")"
echo "Model: $expr"
model="$(last_model_title "$results/nikuradse_1.csv")"
# the values of r_k in the data
rks="$(awk -F, 'FNR > 1 { print $1 }' "$train" "$test" | sort -g -u | tr '\n' ' ')"

gnuplot \
    -e "train='$train'; test='$test'; rks='$rks'; set terminal $term size 900,560; set output '$results/nikuradse_1.png'" \
    -e "model = \"$model\"" \
    -e "f(r_k, log_Re) = $expr" - <<'EOF_GP' || echo "plotting failed" >&2
set termoption noenhanced
set datafile separator ","
sqr(x) = x * x
set xlabel "log_Re"
set ylabel "target"
set key title "r_k" outside right
set title "Nikuradse: model of the last generation (lines), training (filled) and test data\n" . model
stats train every ::1 using 2 nooutput
# xlo = STATS_min; xhi = STATS_max
stats test every ::1 using 2 nooutput
# xlo = (STATS_min < xlo ? STATS_min : xlo); xhi = (STATS_max > xhi ? STATS_max : xhi)
set xrange [3:7]
set samples 300
r(i) = real(word(rks, i))
plot for [i=1:words(rks)] train every ::1 using 2:($1 == r(i) ? $3 : NaN) with points pt 7 ps 0.4 lc i title word(rks, i), \
     for [i=1:words(rks)] test every ::1 using 2:($1 == r(i) ? $3 : NaN) with points pt 6 ps 0.5 lc i notitle, \
     for [i=1:words(rks)] f(r(i), x) with lines lc i lw 1.5 notitle
EOF_GP
echo "Plot: $results/nikuradse_1.png"
