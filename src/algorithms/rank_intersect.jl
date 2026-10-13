"""
    rank_intersect_sort(lossvalues; indices=nothing, perm=nothing)

Return the non-dominated fronts for unique, two-objective minimization
points. `perm` may supply the lexicographic ordering of `indices`.
"""
function rank_intersect_sort(lossvalues; indices=nothing, perm=nothing)
    nall = length(lossvalues)
    nall > 0 || error("No observations provided to rank_intersect_sort")
    length(lossvalues[1]) == 2 ||
        throw(ArgumentError("rank_intersect_sort supports exactly two objectives"))

    indices === nothing && (indices = collect(eachindex(lossvalues)))
    isempty(indices) && return Vector{Vector{Int}}()
    _rank_intersect_sort_2d(lossvalues, indices, perm)
end

# For points sorted lexicographically by (x, y), an earlier point dominates the
# current one exactly when its y is no greater. A Fenwick tree over y stores the
# maximum front rank for each prefix, hence query(y) + 1 is this point's rank.
function _rank_intersect_sort_2d(lossvalues, indices, perm)
    n = length(indices)
    p = isnothing(perm) ? indices[sortperm(indices, by = i -> lossvalues[i])] : perm
    length(p) == n || throw(ArgumentError("perm must contain every index once"))

    by_y = indices[sortperm(indices, by = i -> lossvalues[i][2])]
    yrank = zeros(Int, length(lossvalues))
    ny = 0
    previous = nothing
    for i in by_y
        y = lossvalues[i][2]
        if isnothing(previous) || y != previous
            ny += 1
            previous = y
        end
        yrank[i] = ny
    end

    tree = zeros(Int, ny)
    rank = zeros(Int, length(lossvalues))
    maxrank = 0
    for i in p
        j = yrank[i]
        best = 0
        while j > 0
            best = max(best, tree[j])
            j -= j & -j
        end
        r = best + 1
        rank[i] = r
        j = yrank[i]
        while j <= ny
            tree[j] = max(tree[j], r)
            j += j & -j
        end
        maxrank = max(maxrank, r)
    end

    fronts = [Int[] for _ in 1:maxrank]
    # Preserve population/index order inside fronts, rather than sort order.
    for i in indices
        push!(fronts[rank[i]], i)
    end
    fronts
end
