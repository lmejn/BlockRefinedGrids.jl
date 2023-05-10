using BlockRefinedGrid
using Test

@testset "BlockRefinedGrid.jl" begin

    @testset "Refinement" begin
        X0 = 10*rand()
        W0 = 20*rand()
        cell = GridCell(X0, W0)
        refine!(cell)
        @test BlockRefinedGrid.haschildren(cell)

        subcells = children(cell)

        @test length(subcells) == 2

        @test cellorigin(subcells[1]) ≈ X0
        @test cellwidth(subcells[1]) ≈ W0/2

        @test cellorigin(subcells[2]) ≈ X0 + W0/2
        @test cellwidth(subcells[2]) ≈ W0/2
    end

    @testset "Coarsen" begin
        X0 = -10.
        W0 = 20.
        subcells = [GridCell(X0, W0/2), GridCell(X0 + W0/2, W0/2)]
        cell = GridCell(X0, W0, subcells)

        coarsen!(cell)
        @test !BlockRefinedGrid.haschildren(cell)

        subcells = children(cell)
        @test cellorigin(cell) ≈ X0
        @test cellwidth(cell) ≈ W0
    end

    @testset "Find Cell" begin
        cell = GridCell(0., 1.)
        @test findcell(cell, rand()) == cell

        @test findcell(cell, 1.4) === nothing

        refine!(cell)
        refine!(cell[2])
        @test findcell(cell, 0.6) == cell[2, 1]

        cell = GridCell(0., 1.)
        refine!(cell, 0.75)
        refine!(cell, 0.75)
        @test findcell(cell, 0.6) == cell[2, 1]

    end

end
