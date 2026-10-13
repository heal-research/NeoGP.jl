# Run benchmarks locally using AirspeedVelocity.
# Compares two git revisions and produces markdown tables with median runtime,
# memory, and allocation differences.
#
# Usage:
#   julia --project=benchmark benchmark/run_benchmarks.jl
#   julia --project=benchmark benchmark/run_benchmarks.jl HEAD dirty
#   julia --project=benchmark benchmark/run_benchmarks.jl <rev1> <rev2>

using AirspeedVelocity
using Pkg

# Work around an AirspeedVelocity bug: its `dev_source_pkgs` resolves the
# package's `[sources]` entries one by one, in the arbitrary iteration order of
# the parsed TOML dictionary.  When one source package depends on another
# (here SymRegLikelihoods / SymRegModelSelection depend on SymRegInterpreter)
# and is added first, the resolver looks for the other one in the registry,
# where it has no versions, and fails with
# "SymRegInterpreter ... has no known versions!".
#
# Replace the method with a version that adds all URL-based sources in a single
# `Pkg.add` call, so the resolver sees every git-source package at once.
function AirspeedVelocity.Utils.dev_source_pkgs(project_path)
    project_toml = joinpath(project_path, "Project.toml")
    sources = get(Pkg.TOML.parsefile(project_toml), "sources", nothing)
    isnothing(sources) && return nothing

    add_specs = PackageSpec[]
    for (name, metadata) in sources
        subdir = get(metadata, "subdir", nothing)
        if haskey(metadata, "path")
            raw_path = metadata["path"]
            path = isabspath(raw_path) ? raw_path : joinpath(project_path, raw_path)
            Pkg.develop(PackageSpec(; name, path, subdir); io=devnull)
        else
            push!(add_specs, PackageSpec(; name, url=metadata["url"],
                                         rev=get(metadata, "rev", nothing), subdir))
        end
    end
    isempty(add_specs) || Pkg.add(add_specs; io=devnull)
    return nothing
end

const PACKAGE_DIR = realpath(joinpath(@__DIR__, ".."))
const OUTPUT_DIR = mkpath(joinpath(@__DIR__, "results"))
const BENCH_SCRIPT = joinpath(@__DIR__, "benchmarks.jl")

function has_git_worktree(root, dir)
    worktrees = read(`git -C $root worktree list`, String)
    return occursin(dir, worktrees)
end

function create_worktree(root, rev, dir)
    @info "Creating worktree for revision '$rev' at $dir"
    run(`git -C $root worktree add --detach $dir $rev`)
    return nothing
end

function remove_worktree(root, dir)
    if has_git_worktree(root, dir)
        @info "Removing worktree $dir"
        run(`git -C $root worktree remove --force $dir`)
    end
    return nothing
end

# With no arguments, compare the committed HEAD to the current working tree.
revisions = length(ARGS) >= 2 ? ARGS[1:2] : ["HEAD", "dirty"]
println("# Benchmark comparison: $(revisions[1]) vs $(revisions[2])\n")

paths = Dict{String,String}()
created_worktrees = Pair{String,String}[]

try
    for revision in revisions
        if revision == "dirty"
            paths[revision] = PACKAGE_DIR
            @info "Using current working tree for revision 'dirty'"
        else
            worktree_dir = mktempdir(; cleanup=true)
            create_worktree(PACKAGE_DIR, revision, worktree_dir)
            push!(created_worktrees, revision => worktree_dir)
            paths[revision] = worktree_dir
        end
    end

    specs = [
        PackageSpec(; name="NeoGP", path=paths[revision], rev=revision)
        for revision in revisions
    ]

    @info "Running benchmarks for: $(revisions[1]) vs $(revisions[2])"
    AirspeedVelocity.benchmark(
        specs;
        script=BENCH_SCRIPT,
        output_dir=OUTPUT_DIR,
        tune=false,
    )

    results = AirspeedVelocity.load_results(specs; input_dir=OUTPUT_DIR)

    println("\n## Median Runtime\n")
    println(AirspeedVelocity.create_table(results; key="median", add_ratio_col=true))

    println("\n## Memory / Allocations\n")
    println(AirspeedVelocity.create_table(results; key="memory", add_ratio_col=true))
finally
    for (_, dir) in created_worktrees
        remove_worktree(PACKAGE_DIR, dir)
        rm(dir; force=true, recursive=true)
    end
end
