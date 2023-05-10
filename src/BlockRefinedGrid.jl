module BlockRefinedGrid

using AbstractTrees, StaticArrays
import Base.getindex, Base.checkbounds

export GridCell, cellorigin, cellwidth, cellcenter, cellbounds
export coarsen!, refine!
export findcell

"""
    GridCell

Stores a block refined grid in a tree
"""
struct GridCell{N, T}
    origin::SVector{N, T}
    width::SVector{N, T}
    children::Vector{GridCell{N, T}}
    function GridCell(origin, width, children=GridCell[])
        origin, width = promote(origin, width)
        N = length(origin)
        T = eltype(origin)
        new{N, T}(origin, width, children)
    end
end

# Abstract Tree functions
AbstractTrees.nodevalue(cell::GridCell) = cell.origin, cell.width
AbstractTrees.children(cell::GridCell) = cell.children

"""
    haschildren(cell::GridCell)

Returns `true` if the cell has a children
"""
haschildren(cell::GridCell) = !isempty(cell.children)

"""
    cellorigin(cell::GridCell)

Returns the origin of the cell.
"""
cellorigin(cell::GridCell) = cell.origin

"""
    cellwidth(cell::GridCell)

Returns the width of the cell.
"""
cellwidth(cell::GridCell) = cell.width

"""
    cellcenter(cell::GridCell)

Returns the center of the cell.
"""
cellcenter(cell::GridCell) = cellorigin(cell)+0.5*cellwidth(cell)

"""
    cellbounds(cell::GridCell)

Returns the bounds of the cell.
"""
cellbounds(cell::GridCell) = cellorigin(cell), cellorigin(cell)+cellwidth(cell)

checkbounds(cell::GridCell, index::Int) = checkbounds(children(cell), index)

getindex(cell::GridCell, index::Int) = cell.children[index]

function getindex(cell::GridCell, index::Vararg{Int})
    n = cell
    for i in index
        @boundscheck checkbounds(cell, i)
        n = n[i]
    end
    n
end


"""
    coarsen!(cell::GridCell)

Reduce the refinement of the cell
"""
coarsen!(cell::GridCell) = resize!(cell.children, 0)

"""
    refine!(cell::GridCell[, x::Float64])

Refine the cell

If position `x` is given, it will refine the cell containing `x`.
"""
function refine!(cell::GridCell{N, T}) where {N, T<:Number}
    origin = cellorigin(cell)
    subwidth = 0.5*cellwidth(cell)

    resize!(cell.children, 2^N)

    idims = Tuple(sfill(2, N))
    linear_indices = LinearIndices(idims)
    
    for index in CartesianIndices(idims)
        offset = SVector(Tuple(index)).-1
        suborigin = origin + offset.*subwidth
        child = GridCell(suborigin, subwidth)

        i = linear_indices[index]
        cell.children[i] = child
    end
end
sfill(v, n) = @SVector fill(v, n)

"""
    incell(cell::GridCell, x)

Return `true` if position `x` is in the cell
"""
function incell(cell::GridCell, x)
    xmin, xmax = cellbounds(cell)
    all(xmin.<=x.<xmax)
end

"""
    findcell(cell, x)

Return the cell containing position `x`, `nothing` if `x` not in the cell 
"""
function findcell(cell, x)
    @assert length(cellorigin(cell)) == length(x)
    if incell(cell, x)
        !haschildren(cell) && return cell
        for child in children(cell)
            cell = findcell(child, x)
            !(cell===nothing) && return cell
        end
    end
    nothing
end

function refine!(cell::GridCell, x)
    cell = findcell(cell, x)
    cell===nothing && return
    refine!(cell)
end

end
