# Row-based datasets: every observation (row) has inputs `X`, an output `y`, and
# optionally the standard deviations of the errors of the inputs (`Xerr`) and of
# the output (`yerr`).  The errors of different rows are independent, so the
# data fit all row-based likelihoods of SymRegLikelihoods (Gaussian, Laplace and
# the ROXY likelihoods) through the same interface.

"""
    Dataset{T}

Row-based data for symbolic regression: the inputs `X` (observations × inputs),
the output `y`, optionally the standard deviations `Xerr` of the inputs (same
size as `X`) and `yerr` of the output, and the names `varnames` of the inputs.
"""
struct Dataset{T<:AbstractFloat}
    X::Matrix{T}
    y::Vector{T}
    Xerr::Union{Nothing,Matrix{T}}
    yerr::Union{Nothing,Vector{T}}
    varnames::Vector{String}

    function Dataset(X::Matrix{T}, y::Vector{T}, Xerr::Union{Nothing,Matrix{T}},
                     yerr::Union{Nothing,Vector{T}},
                     varnames::Vector{String}) where {T}
        n, d = size(X)
        length(y) == n || throw(DimensionMismatch("length(y) != size(X, 1)"))
        isnothing(Xerr) || size(Xerr) == (n, d) ||
            throw(DimensionMismatch("size(Xerr) != size(X)"))
        isnothing(yerr) || length(yerr) == n ||
            throw(DimensionMismatch("length(yerr) != size(X, 1)"))
        length(varnames) == d ||
            throw(DimensionMismatch("length(varnames) != size(X, 2)"))
        new{T}(X, y, Xerr, yerr, varnames)
    end
end

"""
    parse_sigma(sigma) -> Nothing, Vector{Float64} or Vector{String}

Parse the comma-separated errors of the `--sigma` option: all entries are
numbers or all entries are names of dataset columns.  A mixture is rejected.
`nothing` (no errors) is returned unchanged, a vector of numbers or names is
converted to `Vector{Float64}` or `Vector{String}`.
"""
parse_sigma(::Nothing) = nothing

parse_sigma(sigma::AbstractVector{<:Real}) = Float64.(sigma)
parse_sigma(sigma::AbstractVector{<:AbstractString}) = String.(sigma)

function parse_sigma(sigma::AbstractString)
    tokens = String.(strip.(split(sigma, ',')))
    any(isempty, tokens) &&
        throw(ArgumentError("sigma must be a comma-separated list without empty entries"))
    values = tryparse.(Float64, tokens)
    all(isnothing, values) && return tokens
    any(isnothing, values) &&
        throw(ArgumentError("sigma must be either all numbers or all variable names, " *
                            "a mixture is not allowed"))
    Float64.(values)
end

"""
    dataset_errors(likelihood, sigma) -> Symbol

The errors that `likelihood` requires from a dataset: `:none` (Gaussian and
Laplace without `sigma`: the noise is estimated), `:y` (Gaussian and Laplace
with a given error of the output) or `:xy` (the ROXY likelihoods, which require
`sigma`: the errors of all inputs followed by the error of the output).
"""
function dataset_errors(likelihood::AbstractString, sigma)
    if likelihood in ("gaussian", "laplace")
        isnothing(sigma) ? :none : :y
    elseif likelihood in ("roxy_unif", "roxy_mnr_diagonal")
        isnothing(sigma) &&
            throw(ArgumentError("the $likelihood likelihood requires --sigma with the " *
                                "errors of all inputs followed by the error of the target"))
        :xy
    else
        throw(ArgumentError("unknown likelihood value (allowed values are gaussian, " *
                            "laplace, roxy_unif, roxy_mnr_diagonal)"))
    end
end

function _column_index(colnames, name)
    idx = findfirst(==(name), colnames)
    isnothing(idx) &&
        throw(ArgumentError("could not find variable $name in (with variables: $colnames)"))
    idx
end

# The error values of one entry of `sigma`: a number for every row, or a column.
_error_values(::Type{T}, value::Real, data, colnames) where {T} =
    fill(T(value), size(data, 1))
_error_values(::Type{T}, name::AbstractString, data, colnames) where {T} =
    data[:, _column_index(colnames, name)]

"""
    load_dataset(T, filename, target, inputs, sigma, errors) -> Dataset{T}

Load the CSV file `filename` (with a header) as a [`Dataset`](@ref).  `target`
is the name of the output column.  The inputs are the columns `inputs`, or, if
`inputs` is empty, all columns except for the target and the error columns.

`sigma` is the result of `parse_sigma` and `errors` the errors the
likelihood requires, see `dataset_errors`: none (`:none`), the error of
the output (`:y`, one entry in `sigma`), or the errors of all inputs followed by
the error of the output (`:xy`).  Numeric entries apply to all rows, names refer
to columns of the file.
"""
function load_dataset(::Type{T}, filename::AbstractString, target::AbstractString,
                      inputs::AbstractVector{<:AbstractString}, sigma,
                      errors::Symbol) where {T}
    errors in (:none, :y, :xy) || throw(ArgumentError("unknown errors $errors"))
    (errors === :none) == isnothing(sigma) ||
        throw(ArgumentError("sigma is required if and only if the likelihood uses errors"))

    data, header = readdlm(filename, ',', T; header = true)
    colnames = String.(vec(header))

    targetidx = _column_index(colnames, target)
    errornames = sigma isa Vector{String} ? sigma : String[]
    errorcols = [_column_index(colnames, name) for name in errornames]
    inputidxs = if isempty(inputs)
        setdiff(1:length(colnames), targetidx, errorcols)
    else
        [_column_index(colnames, input) for input in inputs]
    end
    isempty(inputidxs) && throw(ArgumentError("no input variables found in $filename"))

    nsigma = errors === :y ? 1 : length(inputidxs) + 1
    if errors !== :none && length(sigma) != nsigma
        throw(ArgumentError("sigma must have $nsigma entries (" *
                            (errors === :y ? "the error of the target" :
                             "the errors of the $(length(inputidxs)) input variable(s) " *
                             "followed by the error of the target") *
                            "), got $(length(sigma))"))
    end

    X = data[:, inputidxs]
    y = data[:, targetidx]
    Xerr = nothing
    yerr = nothing
    if errors === :xy
        Xerr = similar(X)
        for (k, entry) in enumerate(sigma[1:end-1])
            Xerr[:, k] = _error_values(T, entry, data, colnames)
        end
        all(e -> isfinite(e) && e >= 0, Xerr) ||
            throw(ArgumentError("errors of the inputs must be finite and non-negative"))
    end
    if errors !== :none
        yerr = _error_values(T, sigma[end], data, colnames)
        all(e -> isfinite(e) && e > 0, yerr) ||
            throw(ArgumentError("errors of the target must be finite and positive"))
    end
    Dataset(X, y, Xerr, yerr, colnames[inputidxs])
end

"""
    load_dataset(T, filename, target; inputs = String[], sigma = nothing,
                 likelihood = "gaussian") -> Dataset{T}

Load the CSV file `filename` as a [`Dataset`](@ref) for the row-based
`likelihood` (see [`create_likelihood`](@ref)), with the errors `sigma` that
it requires: the error of the target for `"gaussian"` and `"laplace"`
(optional), the errors of all inputs followed by the error of the target for the
`"roxy_unif"` and `"roxy_mnr_diagonal"` likelihoods.  `sigma` is a vector of
numbers or of column names (or a comma-separated string, as the command line
option `--sigma`).  The inputs are the columns `inputs`, by default all columns
except for the target and the error columns.
"""
function load_dataset(::Type{T}, filename::AbstractString, target::AbstractString;
                      inputs::AbstractVector{<:AbstractString} = String[], sigma = nothing,
                      likelihood::AbstractString = "gaussian") where {T}
    sigma = parse_sigma(sigma)
    load_dataset(T, filename, target, inputs, sigma, dataset_errors(lowercase(likelihood), sigma))
end

"""
    logscale(dataset; x = false, y = false) -> Dataset

The dataset with log10-scaled inputs (`x = true`) and/or output (`y = true`).
The errors are scaled by first-order error propagation, `σ' = σ / (v ln 10)` for
a value `v`.  Scaled values must be positive.  Use [`LogScaledLikelihood`](@ref)
to fit a model on the original scale to scaled data.
"""
function logscale(dataset::Dataset{T}; x::Bool = false, y::Bool = false) where {T}
    X, Xerr, yvec, yerr = dataset.X, dataset.Xerr, dataset.y, dataset.yerr
    ln10 = log(T(10))
    if x
        all(>(0), X) || throw(ArgumentError("log-scaling the inputs requires positive inputs"))
        isnothing(Xerr) || (Xerr = Xerr ./ (X .* ln10))
        X = log10.(X)
    end
    if y
        all(>(0), yvec) || throw(ArgumentError("log-scaling the target requires positive values"))
        isnothing(yerr) || (yerr = yerr ./ (yvec .* ln10))
        yvec = log10.(yvec)
    end
    Dataset(X, yvec, Xerr, yerr, dataset.varnames)
end

"""
    create_likelihood(name, dataset; intrinsic_scatter = false) -> AbstractLikelihood

The row-based likelihood `name` (`"gaussian"`, `"laplace"`, `"roxy_unif"` or
`"roxy_mnr_diagonal"`) of `dataset`.  `dataset` must have the errors that
`dataset_errors` requires for `name`.

All likelihoods support an intrinsic scatter, which is added to the given
errors of the output with `intrinsic_scatter = true`.  The Gaussian and Laplace
likelihoods of data without errors estimate the noise instead (profiled) and
therefore always have it.
"""
function create_likelihood(name::AbstractString, dataset::Dataset;
                           intrinsic_scatter::Bool = false)
    (; X, y, Xerr, yerr) = dataset
    if name in ("gaussian", "laplace")
        gaussian = (name == "gaussian")
        if isnothing(yerr)
            gaussian ? GaussianProfiledLikelihood(X, y) : LaplaceProfiledLikelihood(X, y)
        elseif intrinsic_scatter
            gaussian ? GaussianScatterLikelihood(X, y, yerr) : LaplaceScatterLikelihood(X, y, yerr)
        else
            gaussian ? GaussianLikelihood(X, y, yerr) : LaplaceLikelihood(X, y, yerr)
        end
    elseif name in ("roxy_unif", "roxy_mnr_diagonal")
        (isnothing(Xerr) || isnothing(yerr)) &&
            throw(ArgumentError("the $name likelihood requires errors of the inputs and the target"))
        if name == "roxy_unif"
            size(X, 2) == 1 ||
                throw(ArgumentError("roxy_unif supports exactly one input variable, got $(size(X, 2))"))
            XUniformDiagonalLikelihood(X[:, 1], Xerr[:, 1], y, yerr; intrinsic_scatter)
        else
            MNRDiagonalLikelihood(X, Xerr, y, yerr; intrinsic_scatter)
        end
    else
        throw(ArgumentError("unknown likelihood value (allowed values are gaussian, " *
                            "laplace, roxy_unif, roxy_mnr_diagonal)"))
    end
end
