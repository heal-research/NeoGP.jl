# Helpers of the example scripts (sourced, not run).

# Directory of the output of the examples (the log of the run and the plot).
results_dir() {
    local dir="${NEOGP_RESULTS_DIR:-$root/examples/results}"
    mkdir -p "$dir"
    echo "$dir"
}

# The expression of the model in the last line of the output of runNeoGP.jl
# (`$1`), in gnuplot syntax:
#   - `^` is `**` in gnuplot,
#   - negative numbers get parentheses, because `**` binds stronger than the sign,
#   - Julia prints small `Float32` numbers as `1.0f-5`.
# The function `sqr` is defined in the gnuplot scripts.
last_model_expression() {
    last_model_raw_expression "$1" \
        | sed -E 's/([0-9])f(-?[0-9])/\1e\2/g' \
        | sed -E 's/(^|[^0-9eE.)A-Za-z_])(-[0-9.]+(e-?[0-9]+)?)/\1(\2)/g' \
        | sed -E 's/\^/**/g'
}

# The expression of the model in the last line of the output of runNeoGP.jl (`$1`)
# as printed by NeoGP.  The expression is the last, quoted field of the line; it is
# followed by the name of the likelihood and the likelihood parameters, which are removed.
last_model_raw_expression() {
    tail -n 1 "$1" \
        | sed -E 's/.*,"([^"]*)"$/\1/' \
        | sed -E 's/ [^ ]+ Float[0-9]+\[.*\]$//'
}

# The expression of the model for the title of a plot: wrapped at spaces into lines of
# at most `$2` (default: 110) characters, separated by `\n` for a gnuplot string.
last_model_title() {
    last_model_raw_expression "$1" | fold -s -w "${2:-110}" \
        | awk 'NR > 1 { printf "\\n" } { printf "%s", $0 }'
}

# Prints the terminal for a PNG file if gnuplot is installed and returns 1 otherwise.
gnuplot_png_terminal() {
    command -v gnuplot > /dev/null 2>&1 || return 1
    if gnuplot -e 'set terminal pngcairo' > /dev/null 2>&1; then
        echo pngcairo
    else
        echo png
    fi
}
