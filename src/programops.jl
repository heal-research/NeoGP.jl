# Evolutionary operators operating on expression trees in the
# SymRegInterpreter post-order linear format (`Vector{Instruction{T}}`).
#
# These operators intentionally work only on the expression-tree subset of the
# DAG-capable instruction format: every non-root instruction has exactly one
# parent and each post-order subtree occupies one contiguous interval.

using Random
using SymRegInterpreter: Instruction, Model, VAR, SCALEDVAR, PARAM, CONSTANT, ADD,
    degree, create_var_instruction,
    create_param_instruction, create_scaledvar_instruction,
    create_const_instruction

isscaledvar(instr::Instruction) = instr.opcode == SCALEDVAR
isvar(instr::Instruction) = instr.opcode == VAR
isparameter(instr::Instruction) = instr.opcode == PARAM
isterminal(instr::Instruction) = isscaledvar(instr) || isparameter(instr) ||
    isvar(instr) || instr.opcode == CONSTANT

# Validate the tree preconditions, throwing ArgumentError on a DAG or a
# malformed program.  Returns the code on success.
function validate_tree(code::AbstractVector{<:Instruction})
    isempty(code) && return code
    n = length(code)
    # every function child must be lower than its parent
    @inbounds for i in 1:n
        d = degree(code[i].opcode)
        d >= 1 && !(1 <= code[i].arg1idx < i) &&
            throw(ArgumentError("NeoGP evolutionary operators require tree-structured code (bad arg1idx at $i)"))
        d == 2 && !(1 <= code[i].arg2idx < i) &&
            throw(ArgumentError("NeoGP evolutionary operators require tree-structured code (bad arg2idx at $i)"))
    end
    # exactly one parent per non-root: count parents
    parents = Vector{Int}(undef, n)
    fill!(parents, 0)
    @inbounds for i in 1:n
        d = degree(code[i].opcode)
        if d >= 1
            parents[code[i].arg1idx] += 1
            parents[code[i].arg1idx] <= 1 || throw(ArgumentError("NeoGP evolutionary operators require tree-structured code (shared node at $(code[i].arg1idx))"))
        end
        if d == 2
            parents[code[i].arg2idx] += 1
            parents[code[i].arg2idx] <= 1 || throw(ArgumentError("NeoGP evolutionary operators require tree-structured code (shared node at $(code[i].arg2idx))"))
        end
    end
    # all non-root nodes must have exactly one parent (root = last)
    @inbounds for i in 1:n-1
        parents[i] == 1 || throw(ArgumentError("NeoGP evolutionary operators require tree-structured code (node $i has $(parents[i]) parents)"))
    end
    code
end

# recursively find the first instruction of the subtree rooted at `code[i]`
subtree_start(code::AbstractVector{<:Instruction}, i::Int) = begin
    d = degree(code[i].opcode)
    if d == 0      i
    elseif d == 1  subtree_start(code, Int(code[i].arg1idx))
    else           min(subtree_start(code, Int(code[i].arg1idx)), subtree_start(code, Int(code[i].arg2idx)))
    end
end

function expression_tree_height(code::AbstractVector{<:Instruction}, pos::Int = length(code))
    isempty(code) && return 0
    instr = code[pos]
    d = degree(instr.opcode)
    if d == 0     1
    elseif d == 1 1 + expression_tree_height(code, Int(instr.arg1idx))
    else          1 + max(expression_tree_height(code, Int(instr.arg1idx)),
                          expression_tree_height(code, Int(instr.arg2idx)))
    end
end


# ---------------------------------------------------------------------------
# grow!
# ---------------------------------------------------------------------------
# Grow a random rooted full tree into `code` (post-order).  Parameters receive
# contiguous indices 1..n_param and random initial values.  Returns `code`
# (empty if maxlen was exceeded during generation).

function grow!(code::Vector{Instruction{T}}, maxlen::Int, depth::Int,
               numvars::Int, functionset, terminalset; rng::Random.AbstractRNG = Random.default_rng()) where {T}
    maxlen >= 1 || throw(ArgumentError("maxlen must be at least 1, got $maxlen"))
    depth >= 0 || throw(ArgumentError("depth must be non-negative, got $depth"))
    numvars >= 1 || throw(ArgumentError("numvars must be at least 1, got $numvars"))
    empty!(code)
    fs = functionset
    ts = terminalset
    validate_operator_sets(fs, ts)
    
    random_model_value(T, rng) = convert(T, randn(rng))

    function gen(d)::Union{Int,Nothing}
        
        length(code) < maxlen || return nothing

        # Randomly stop and emit a terminal (gives trees of varying size,
        # mirroring the original pre-order generator); force a function at the
        # root so well-formed non-trivial trees result, and a terminal at depth 0.
        chooseterminal = d == 0 || (!isempty(code) && !isempty(fs) && rand(rng) < 0.5)
        if chooseterminal
            # an empty terminal set means "all terminal kinds are allowed"
            symb = _rand_element(rng, ts)
            if symb == VAR
                push!(code, create_var_instruction(T, rand(rng, 1:numvars)))
            elseif symb == SCALEDVAR
                push!(code, create_scaledvar_instruction(T, 0, rand(rng, 1:numvars); val=random_model_value(T,rng)))
            elseif symb == PARAM
                push!(code, create_param_instruction(T, 0; val=random_model_value(T,rng)))
            elseif symb == CONSTANT 
                push!(code, create_const_instruction(random_model_value(T,rng)))
            else
                throw(ArgumentError("unknown terminal symbol $symb"))
            end
            return length(code)
        else
            opc = _rand_element(rng, fs)
            f = degree(opc)
            if f == 1
                c = gen(d - 1)
                c === nothing && return nothing
                push!(code, Instruction{T}(opc, UInt32(c), UInt32(0), zero(T)))
            else
                l = gen(d - 1); l === nothing && return nothing
                r = gen(d - 1); r === nothing && return nothing
                push!(code, Instruction{T}(opc, UInt32(l), UInt32(r), zero(T)))
            end
            return length(code)
        end
    end

    root = gen(depth)
    if root === nothing
        empty!(code)
    else
        assign_param_indices!(code)
    end
    code
end

# ---------------------------------------------------------------------------
# crossover
# ---------------------------------------------------------------------------

# Copy of `instr` with its child indices mapped through `f`.
@inline function _remap_children(instr::Instruction{T}, f) where {T}
    dg = degree(instr.opcode)
    dg == 0 && return instr
    a1 = UInt32(f(Int(instr.arg1idx)))
    a2 = dg == 2 ? UInt32(f(Int(instr.arg2idx))) : UInt32(0)
    Instruction{T}(instr.opcode, a1, a2, instr.val)
end

# Single-point subtree crossover on post-order trees.  The subtree of code1
# rooted at a random `r` (occupying `rlo:r`) is replaced by a uniformly chosen
# donor subtree of code2 (occupying `dlo:d`) such that the offspring fits into
# `maxlen`.  Parameter values travel with the spliced instructions; parameter
# indices are reassigned afterwards.  If no donor fits, returns a copy of code1.
#
# The offspring consists of three contiguous regions, each a shifted copy of a
# contiguous parent interval:
#
#   A = newcode[1 : rlo-1]          <- code1[1 : rlo-1]   (children unchanged)
#   B = newcode[rlo : rlo+ds-1]     <- code2[dlo : d]     (shift rlo - dlo)
#   C = newcode[rlo+ds : end]       <- code1[r+1 : len1]  (shift rlo + ds - 1 - r)
#
# In a tree, the only node of `rlo:r` referenced from outside is the root `r`
# (by its parent in C); shifting it like the rest of C maps it exactly onto
# the donor root at the end of B.
function crossover(code1::Vector{Instruction{T}}, code2::Vector{Instruction{T}},
                   maxlen::Int; rng::Random.AbstractRNG = Random.default_rng()) where {T}
    validate_tree(code1) # throws on a DAG or malformed program
    validate_tree(code2)
    isempty(code1) && return copy(code2)
    len1 = length(code1); len2 = length(code2)

    r = rand(rng, 1:len1)
    rlo = subtree_start(code1, r)
    maxds = maxlen - len1 + (r - rlo + 1) # largest donor size that still fits

    # Subtree sizes of code2 (children precede parents in post-order), counting
    # the donor candidates that fit.
    sizes = Vector{Int}(undef, len2)
    ncand = 0
    @inbounds for i in 1:len2
        instr = code2[i]
        dg = degree(instr.opcode)
        s = 1
        dg >= 1 && (s += sizes[instr.arg1idx])
        dg == 2 && (s += sizes[instr.arg2idx])
        sizes[i] = s
        ncand += s <= maxds
    end
    ncand == 0 && return copy(code1)

    # root `d` of the pick-th fitting candidate
    pick = rand(rng, 1:ncand)
    d = 0
    @inbounds while pick > 0
        d += 1
        pick -= sizes[d] <= maxds
    end
    ds = sizes[d]
    dlo = d - ds + 1

    shiftB = rlo - dlo
    shiftC = rlo + ds - 1 - r
    newcode = Vector{Instruction{T}}(undef, len1 + shiftC)
    copyto!(newcode, 1, code1, 1, rlo - 1)
    @inbounds for k in dlo:d
        newcode[k + shiftB] = _remap_children(code2[k], i -> i + shiftB)
    end
    @inbounds for k in r+1:len1
        newcode[k + shiftC] = _remap_children(code1[k], i -> i < rlo ? i : i + shiftC)
    end

    assign_param_indices!(newcode)
    # The splice only redirects existing tree edges and replaces one subtree by
    # another tree subtree, so the result is tree-structured if both inputs are.
    newcode
end



# ---------------------------------------------------------------------------
# mutate!
# ---------------------------------------------------------------------------

# Mutate an in-place tree.  Function nodes switch to a same-arity function;
# terminals may change kind, variable index, or parameter value (per-node).
# Draw one element uniformly at random from any iterable collection, without
# materializing it.

# Returns the number of model parameters after mutation and index reassignment.
function mutate!(code::Vector{Instruction{T}}, pmut::Real, numvars::Int,
                 functionset, terminalset; rng::Random.AbstractRNG = Random.default_rng()) where {T}
    validate_tree(code)
    fs = functionset
    ts = terminalset
    validate_operator_sets(fs, ts)
    for i in eachindex(code)
        rand(rng) < pmut || continue
        instr = code[i]
        if isterminal(instr)
            # compute the mutated instruction (immutable => rebuild on change).
            # Layout: PARAM stores its (later-remapped) parameter index and
            # derives its value from arg1idx at extraction; VAR stores its
            # variable index in arg1idx; SCALEDVAR stores the variable index in
            # arg1idx and the (later-remapped) parameter index in arg2idx.
            op = instr.opcode; arg1 = instr.arg1idx; arg2 = instr.arg2idx; val = instr.val
            # possibly change kind among the requested terminals
            if rand(rng) < 0.3
                kind = _rand_element(rng, ts)
                if kind == VAR           op = VAR; arg1 = UInt32(rand(rng, 1:numvars)); arg2 = UInt32(0)
                elseif kind == SCALEDVAR op = SCALEDVAR; arg1 = UInt32(rand(rng, 1:numvars))  # keep arg2 (param idx, remapped below)
                elseif kind == CONSTANT  op = CONSTANT; arg1 = UInt32(0); arg2 = UInt32(0)
                else                     op = PARAM;    arg1 = UInt32(0); arg2 = UInt32(0)       # param idx remapped below
                end
            end
            if op == PARAM || op == SCALEDVAR
                # # value / index jitter
                rand(rng) < pmut && (val += convert(T, randn(rng)))
            end
            if op == VAR || op == SCALEDVAR
                # randomly change the variable index (arg1idx) with probability pmut
                rand(rng) < pmut && (arg1 = UInt32(rand(rng, 1:numvars)))
            end
            code[i] = Instruction{T}(op, arg1, arg2, val)
        else
            # replace by a uniformly drawn function of the same arity
            d = degree(instr.opcode)
            op = _rand_matching(rng, fs, f -> degree(f) == d, instr.opcode)
            code[i] = Instruction{T}(op, instr.arg1idx, instr.arg2idx, instr.val)
        end
    end
    nparam = assign_param_indices!(code)
    # Mutation preserves every parent edge and function arity, so the initial
    # tree validation remains valid after the terminal/function replacements.
    nparam
end

# Return parameter values ordered by parameter index (1..n_param).  For the
# tree representation every parameter index has exactly one defining terminal.
function extractparam(::Type{T}, code::AbstractVector{Instruction{T}}) where {T}
    np = model_nparam(code)
    result = Vector{T}(undef, np)
    for instr in code
        if instr.opcode == PARAM
            result[instr.arg1idx] = instr.val
        elseif instr.opcode == SCALEDVAR
            result[instr.arg2idx] = instr.val
        end
    end
    result
end

# Write the numeric parameter vector back into the terminal instruction values.
# Since an Instruction is immutable, each affected element is replaced with a
# new instruction carrying the updated value.
function updateparam!(code::AbstractVector{Instruction{T}}, param::AbstractVector) where {T}
    for i in eachindex(code)
        instr = code[i]
        if instr.opcode == PARAM
            code[i] = Instruction{T}(PARAM, instr.arg1idx, UInt32(0), T(param[instr.arg1idx]))
        elseif instr.opcode == SCALEDVAR
            code[i] = Instruction{T}(SCALEDVAR, instr.arg1idx, instr.arg2idx,
                                     T(param[instr.arg2idx]))
        end
    end
    code
end

function tostring(code::AbstractVector{<:Instruction}, varnames=nothing)
    buf = IOBuffer()
    print_program(buf, code, varnames)
    String(take!(buf))
end


"""
    opcode_list(items) -> Vector{Opcode}

The opcodes in `items` (any collection) as a sorted vector without duplicates.
"""
opcode_list(items) = sort!(unique!(collect(Opcode, items)))

function validate_operator_sets(functionset, terminalset)
    !isempty(functionset) || throw(ArgumentError("functionset must be non-empty"))
    !isempty(terminalset) || throw(ArgumentError("terminalset must be non-empty"))
    all(op -> degree(op) in (1, 2), functionset) ||
        throw(ArgumentError("functionset must contain only unary or binary opcodes"))
    all(op -> degree(op) == 0, terminalset) ||
        throw(ArgumentError("terminalset must contain only terminal opcodes"))
    nothing
end

# Assign parameter indices 1..n_param contiguously in post-order order to the
# PARAM / SCALEDVAR terminals, preserving their current values.
# Returns the number of model parameters after reassignment.
function assign_param_indices!(code::Vector{Instruction{T}}) where {T}
    nparam = 0
    for i in eachindex(code)
        instr = code[i]
        if instr.opcode == PARAM
            nparam += 1
            # PARAM: parameter index lives in arg1idx
            code[i] = Instruction{T}(PARAM, UInt32(nparam), UInt32(0), instr.val) # Instruction is immutable, so we must replace it
        elseif instr.opcode == SCALEDVAR
            nparam += 1
            # SCALEDVAR: variable index in arg1idx, parameter index in arg2idx
            code[i] = Instruction{T}(SCALEDVAR, instr.arg1idx, UInt32(nparam), instr.val)
        end
    end
    nparam
end

model_nparam(code::AbstractVector{<:Instruction}) = begin
    n = 0
    for instr in code
        if instr.opcode == PARAM
            n = max(n, Int(instr.arg1idx)) # PARAM: parameter index lives in arg1idx
        elseif instr.opcode == SCALEDVAR
            n = max(n, Int(instr.arg2idx)) # SCALEDVAR: variable index in arg1idx, parameter index in arg2idx
        end
    end
    n
end


# Reservoir sampling of size one; returns `dflt` when
# nothing matches the predicate.
function _rand_matching(rng::Random.AbstractRNG, items, pred, dflt)
    n = 0
    chosen = dflt
    for it in items
        pred(it) || continue
        n += 1
        (n == 1 || rand(rng) * n < 1) && (chosen = it)
    end
    n == 0 ? dflt : chosen
end

# same as above without filtering
_rand_element(rng::Random.AbstractRNG, items) =
    _rand_matching(rng, items, _ -> true, first(items))
