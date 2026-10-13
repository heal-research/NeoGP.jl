#!/usr/bin/env bash
# Symbolic regression of the radial acceleration relation (RAR) of galaxies: the
# observed acceleration `gobs` as a function of the baryonic acceleration `gbar`,
# both with uncertainties (`e_gbar`, `e_gobs`).  The likelihood marginalizes the
# uncertainty of the input (`roxy_mnr_diagonal`) and estimates an intrinsic scatter; the
# data are fitted on a logarithmic scale while the models stay on the original scale.
#
#     examples/RAR.sh [extra options of runNeoGP.jl]
#
# The output of the run is written to examples/results/RAR.csv, and, if gnuplot is
# installed, the model of the last generation is plotted over the data (with their
# errors) into examples/results/RAR.png.
#
# Environment: JULIA_NUM_THREADS (default: 4), NEOGP_RESULTS_DIR (default: examples/results).
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$root/examples/common.sh"

data="$root/examples/data/RAR.csv"
results="$(results_dir)"

# The main command
julia --project="$root/script" -t "${JULIA_NUM_THREADS:-4}" "$root/script/runNeoGP.jl" \
    "$data" gobs \
    --inputs gbar --likelihood roxy_mnr_diagonal --sigma e_gbar,e_gobs \
    --logscale xy --intrinsic-scatter \
    --objective nll --model-selection dl --generations 30 --popsize 300 --maxlen 20 --seed 1 \
    "$@" | tee "$results/RAR.csv"



###############
# ---- plot the model of the last generation ----
if ! term="$(gnuplot_png_terminal)"; then
    echo "gnuplot not found: skipping the plot" >&2
    exit 0
fi
expr="$(last_model_expression "$results/RAR.csv")"
echo "Model: $expr"
model="$(last_model_title "$results/RAR.csv")"

# the columns of the data are gbar, gobs, e_gbar, e_gobs
gnuplot \
    -e "data='$data'; set terminal $term size 900,560; set output '$results/RAR.png'" \
    -e "model = \"$model\"" \
    -e "f(gbar) = $expr" - <<'EOF_GP' || echo "plotting failed" >&2
set termoption noenhanced
set datafile separator ","
sqr(x) = x * x
set logscale xy
set xlabel "gbar"
set ylabel "gobs"
set key top left
set title "RAR: model of the last generation and data with errors\n" . model
stats data every ::1 using 1 nooutput
xlo = STATS_min; xhi = STATS_max
set xrange [xlo:xhi]
set samples 500
set pointinterval 0
set xrange[0.001:1000]
plot data every ::1 using 1:2:3:4 with xyerrorbars pt 7 ps 0.2 lc rgb "gray" title "data", \
     f(x) with lines lc rgb "red" lw 2 title "model"
EOF_GP
echo "Plot: $results/RAR.png"
