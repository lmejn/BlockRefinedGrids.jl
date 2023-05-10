module BlockRefinedGrid

using AbstractTrees
import Base.getindex, Base.checkbounds

export GridCell, cellorigin, cellwidth, cellcenter, cellbounds
export coarsen!, refine!

"""
    GridCell

Stores a block refined grid in a tree
"""
struct GridCell
    origin::Float64
    width::Float64
    children::Vector{GridCell}
    GridCell(origin, width, children=GridCell[]) = new(origin, width, children)
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
    refine!(cell::GridCell)

Refine the cell
"""
function refine!(cell::GridCell)
    origin = cellorigin(cell)
    width = cellwidth(cell)

    resize!(cell.children, 2)
    
    cell.children .= [GridCell(origin, 0.5*width),
                      GridCell(origin+0.5*width, 0.5*width)]
end

end
