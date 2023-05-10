using BlockRefinedGrid
using Plots, AbstractTrees

function plotbox!(p, cell; kwargs...)
    b, t = cellbounds(cell)
    X = [b[1], t[1], t[1], b[1]]
    Y = [b[2], b[2], t[2], t[2]]
    rect = Shape(X, Y)
    plot!(p, rect; kwargs...)
end

function plotcell!(p, tree; kwargs...)
    for cell in Leaves(tree)
        plotbox!(p, cell; kwargs...) # primary=false
    end
    p
end
plotcell(tree; kwargs...) = plotcell!(plot(), tree; kwargs...)

tree = GridCell([-10., -10.], [20., 20.])
p = plotcell(tree; aspect_ratio=1, color=1, legend=false)
savefig(p, "assets/cell1.svg")

refine!(tree)
refine!(tree[1])
p = plotcell(tree; aspect_ratio=1, color=1, legend=false)
savefig(p, "assets/cell_refine.svg")

begin
    p = plotcell(tree; aspect_ratio=1, color=1, legend=false)
    plotcell!(p, tree[1]; aspect_ratio=1, color=2, legend=false)
    plotcell!(p, tree[1, 2]; aspect_ratio=1, color=3, legend=false)
    savefig(p, "assets/cell_indexed.svg")
end

function pretty_tree()
    N = 48
    M = 3
    tree = GridCell([-10., -10.], [20., 20.])
    for _=1:M, θ = 4π*range(0, 1, length=N)
        refine!(tree, θ*[cos(θ), sin(θ)])
    end
    tree
end

begin
    tree = pretty_tree()
    p = plotcell(tree; aspect_ratio=1, color=1, legend=false)
    savefig(p, "assets/cell_refine_pretty.svg")
    p
end


x = [2., -3.]
cell = findcell(tree, x)

begin
    p = plotcell(tree; aspect_ratio=1, color=1)
    plotcell!(p, cell; color=2, legend=false)
    plot!(p, [x[1]], [x[2]], color=3, marker=:dot)
    savefig(p, "assets/cell_findcell.svg")
    p
end

refine!(tree, x)
p = plotcell(tree; aspect_ratio=1, color=1, legend=false)

begin
    p = plotcell(tree; aspect_ratio=1, color=1)
    plotcell!(p, cell; color=2, legend=false)
    plot!(p, [x[1]], [x[2]], color=3, marker=:dot)
    savefig(p, "assets/cell_refine_findcell.svg")
    p
end