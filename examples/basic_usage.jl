using BlockRefinedGrid
using AbstractTrees

g(n) = isempty(children(n)) ? (cellbounds(n), []) : (cellbounds(n), children(n))

xg = -10.:0.1:10.
xtree = GridCell(xg[1], xg[end]-xg[1]); treemap(g, xtree)
refine!(xtree)
for i=1:4
    refine!(xtree, -1.)
    refine!(xtree, 1.)
end
treemap(g, xtree)

f(x) = exp(-x^2)

using Plots

begin
    plot(xg, f)
    plot!(cellcenter.(Leaves(xtree)), f, marker=:dot)
end
