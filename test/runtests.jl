using BlockRefinedGrid
using AbstractTrees
using Test

import Base.isapprox

function isapprox(c1::GridCell, c2::GridCell)
    c1.origin ≈ c2.origin && c1.width ≈ c2.width
end

@testset "BlockRefinedGrid.jl" begin

    N = 1
    @testset "1D" begin
        @testset "Refinement" begin
            x = rand(N)
            w = rand(N)
            cell = GridCell(x, w)
            refine!(cell)
            @test BlockRefinedGrid.haschildren(cell)

            subcells = children(cell)

            @test length(subcells) == 2^N

            @test subcells[1] ≈ GridCell(x, w/2)
            @test subcells[2] ≈ GridCell(x+w/2, w/2)
        end

        @testset "Coarsen" begin
            x = rand(N)
            w = rand(N)
            subcells = [GridCell(x, w/2), GridCell(x + w/2, w/2)]
            cell = GridCell(x, w, subcells)

            @test BlockRefinedGrid.haschildren(cell)

            coarsen!(cell)
            @test !BlockRefinedGrid.haschildren(cell)

            @test cell ≈ GridCell(x, w)
        end

        @testset "In Cell" begin
            x = rand(N)
            w = rand(N)
            cell = GridCell(x, w)

            @test BlockRefinedGrid.incell(cell, @. x+0.1*w)
            @test !BlockRefinedGrid.incell(cell, @. x+1.1*w)
            @test !BlockRefinedGrid.incell(cell, @. x-0.1*w)

        end

        @testset "Find Cell" begin
            x = rand(N)
            w = rand(N)
            cell = GridCell(x, w)
            @test findcell(cell, x.+w.*rand(N)) == cell

            @test findcell(cell, @. x+1.1*w) === nothing
            @test findcell(cell, @. x-0.1) === nothing

            xᵢ = x.+w.*rand(N)
            refine!(cell, xᵢ)
            refine!(cell, xᵢ)
            @test BlockRefinedGrid.incell(findcell(cell, xᵢ), xᵢ)

        end
    end

    @testset "2D" begin
        @testset "Refinement" begin
            X0 = 10*rand(2)
            W0 = 20*rand(2)
            cell = GridCell(X0, W0)
            refine!(cell)
            @test BlockRefinedGrid.haschildren(cell)

            subcells = children(cell)

            @test length(subcells) == 4

            @test subcells[1] ≈ GridCell(X0, W0/2)
            @test subcells[2] ≈ GridCell(X0.+[1,0].*W0/2, W0/2)
            @test subcells[3] ≈ GridCell(X0.+[0,1].*W0/2, W0/2)
            @test subcells[4] ≈ GridCell(X0.+[1,1].*W0/2, W0/2)
        end

        @testset "Coarsen" begin
            X0 = [-10., -10.]
            W0 = [20., 20.]
            subcells = [GridCell(X0, W0/2), GridCell(X0 + W0/2, W0/2)]
            cell = GridCell(X0, W0, subcells)

            coarsen!(cell)
            @test !BlockRefinedGrid.haschildren(cell)

            @test cell ≈ GridCell(X0, W0)
        end

        @testset "Find Cell" begin
            cell = GridCell([0., 0.], [1., 1.])
            @test findcell(cell, rand(2)) ≈ cell

            @test findcell(cell, [1.4, 0.5]) === nothing

            x = [0.6, 0.2]
            refine!(cell, x)
            refine!(cell, x)
            @test BlockRefinedGrid.incell(findcell(cell, x), x)
        end
    end

end
