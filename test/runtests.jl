using BlockRefinedGrid
using AbstractTrees
using Test

import Base.isapprox

function isapprox(c1::GridCell, c2::GridCell)
    c1.origin ≈ c2.origin && c1.width ≈ c2.width
end

@testset "BlockRefinedGrid.jl" begin

    function setup_refinement_test(N)
        x = rand(N)
        w = rand(N)
        cell = GridCell(x, w)
        refine!(cell)
        @test BlockRefinedGrid.haschildren(cell)
        @test length(children(cell)) == 2^N

        x, w, cell
    end

    function test_coarsen(N, nrefine=3)
        x = rand(N)
        w = rand(N)
        cell = GridCell(x, w)
        for _=1:nrefine
            refine!(cell, x.+rand(N).*w)
        end

        @test BlockRefinedGrid.haschildren(cell)

        coarsen!(cell)

        @test !BlockRefinedGrid.haschildren(cell)

        @test cell ≈ GridCell(x, w)

    end

    function setup_findcell_test(N, nrefine=3)
        x = rand(N)
        w = rand(N)

        cell = GridCell(x, w)
        @test findcell(cell, x.+w.*rand(N)) ≈ cell

        for _=1:nrefine
            refine!(cell, x.+rand(N).*w)
        end

        x, w, cell
    end

    @testset "1D" begin
        N = 1
        @testset "Refinement" begin
            x, w, cell = setup_refinement_test(N)

            @test cell[1] ≈ GridCell(x, w/2)
            @test cell[2] ≈ GridCell(x+w/2, w/2)
        end

        @testset "Coarsen" test_coarsen(N)

        @testset "In Cell" begin
            x = rand(N)
            w = rand(N)
            cell = GridCell(x, w)

            @test BlockRefinedGrid.incell(cell, @. x+0.1*w)
            @test !BlockRefinedGrid.incell(cell, @. x+1.1*w)
            @test !BlockRefinedGrid.incell(cell, @. x-0.1*w)

        end

        @testset "Find Cell" begin
            x, w, cell = setup_findcell_test(N)

            @test findcell(cell, @. x+1.1*w) === nothing
            @test findcell(cell, @. x-0.1) === nothing

            xᵢ = x.+rand(N).*w
            @test BlockRefinedGrid.incell(findcell(cell, xᵢ), xᵢ)

        end
    end

    @testset "2D" begin
        N = 2
        @testset "Refinement" begin
            x, w, cell = setup_refinement_test(N)

            @test cell[1] ≈ GridCell(x, w/2)
            @test cell[2] ≈ GridCell(x.+[1,0].*w/2, w/2)
            @test cell[3] ≈ GridCell(x.+[0,1].*w/2, w/2)
            @test cell[4] ≈ GridCell(x.+[1,1].*w/2, w/2)
        end

        @testset "Coarsen" test_coarsen(N)

        @testset "Find Cell" begin
            x, w, cell = setup_findcell_test(N)

            @test findcell(cell, @. x + [rand(), 1.1]*w) === nothing
            @test findcell(cell, @. x + [rand(), -0.1]*w) === nothing
            @test findcell(cell, @. x + [1.1, rand()]*w) === nothing
            @test findcell(cell, @. x + [-0.1, rand()]*w) === nothing

            xᵢ = x.+w.*rand(N)
            @test BlockRefinedGrid.incell(findcell(cell, xᵢ), xᵢ)
        end
    end

end
