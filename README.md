# Block Refined Grids

[![Build Status](https://github.com/lmejn/BlockRefinedGrid.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/lmejn/BlockRefinedGrid.jl/actions/workflows/CI.yml?query=branch%3Amain)

A small package for creating block refined grids.

Currently, only supports 1D grids.

## Usage

A grid is defined by a single `GridCell`, which stores the `origin`, `width` and `children` of the cell.

Start off by creating one grid cell:
```julia
cell = GridCell(-10., 20.)
```

We can refine the cell, which splits the cell in half, creating two more cells in 1D:
```julia
refine!(cell)
```

The cell can also be coarsened, which removes all subcells in `cell`:
```julia
coarsen!(cell)
```

Cells can be indexed as well.
This returns the first subcell of the 2nd subcell of the first subcell of the root cell:
```julia
cell[1, 2, 1]
```

Cells can also be located by position.
This returns the cell containing position `x`:
```julia
findcell(cell, x)
```

This functionality is combined with refinement which allows you to refine a cell at a position `x`:
```julia
refine!(cell, x)
```



