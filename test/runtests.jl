using BlockRefinedGrid
using AbstractTrees
using Test

import Base.isapprox

function isapprox(c1::GridCell, c2::GridCell)
    c1.origin ≈ c2.origin && c1.width ≈ c2.width
end

@testset "BlockRefinedGrid.jl" begin


    @testset "1D" begin
        @testset "Refinement" begin
            X0 = 10*rand(1)
            W0 = 20*rand(1)
            cell = GridCell(X0, W0)
            refine!(cell)
            @test BlockRefinedGrid.haschildren(cell)

            subcells = children(cell)

            @test length(subcells) == 2

            @test subcells[1] ≈ GridCell(X0, W0/2)
            @test subcells[2] ≈ GridCell(X0+W0/2, W0/2)
        end

        @testset "Coarsen" begin
            X0 = [-10.]
            W0 = [20.]
            subcells = [GridCell(X0, W0/2), GridCell(X0 + W0/2, W0/2)]
            cell = GridCell(X0, W0, subcells)

            coarsen!(cell)
            @test !BlockRefinedGrid.haschildren(cell)

            @test cell ≈ GridCell(X0, W0)
        end

        @testset "Find Cell" begin
            cell = GridCell([0.], [1.])
            @test findcell(cell, rand()) == cell

            @test findcell(cell, [1.4]) === nothing

            refine!(cell)
            refine!(cell[2])
            @test findcell(cell, [0.6]) == cell[2, 1]

            cell = GridCell([0.], [1.])
            refine!(cell, [0.75])
            refine!(cell, [0.75])
            @test findcell(cell, [0.6]) == cell[2, 1]

        end
    end

end
