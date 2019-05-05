# Fastcluster.jl

[![Build Status](https://travis-ci.org/jmboehm/Fastcluster.jl.svg?branch=master)](https://travis-ci.org/jmboehm/Fastcluster.jl) [![Coverage Status](https://coveralls.io/repos/jmboehm/Fastcluster.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jmboehm/Fastcluster.jl?branch=master) [![codecov.io](http://codecov.io/github/jmboehm/Fastcluster.jl/coverage.svg?branch=master)](http://codecov.io/github/jmboehm/Fastcluster.jl?branch=master)

Julia wrapper to Daniel Muellner's [fastcluster](http://danifold.net/fastcluster.html) library for hierarchical clustering.

## Installation

```julia
Pkg.clone("http://github.com/jmboehm/Fastcluster.jl.git")
```

## Usage

The main function is

```julia
linkage(d::Array{T,2}, method::Symbol) where {T<:Real}
```
which returns a tuple `m, h` that contains the dendrogram information. The input arguments are:
- `d::Array{Float64,2}` is the dissimilarity matrix between the points to cluster. You can use the [Distances.jl](https://github.com/JuliaStats/Distances.jl) package to generate the dissimilarity matrix (see example below).
- `method::Symbol` is one of the following: `:single`, `:complete`, `:average`, `:weighted`, `:ward`, `:centroid`, `:median`. These clustering methods are described in the [documentation of fastcluster](http://danifold.net/fastcluster.html). Note that the behavior of `:ward` is different to those in the R and Python interfaces (see below).

The function
```julia
linkage!(d::Array{T,2}, method::Symbol) where {T<:Real}
```
is a memory-saving alternative that allows fastcluster to overwrite some content in `d`, instead of allocating more memory for the computations.

Finally, you cut the dendrogram at a particular height to get a specified number of clusters `k` with the function

```julia
function cutree(m::Vector{Int32}, nobs::Int64, k::Int64)
```
where
- `m::Vector{Int32}` is the `m` component of the dendrogram returned by `linkage()`.
- `nobs::Int64` is the number of original observations. By default, that is `(length(m)>>1)+1`
- `k::Int64` is the desired number of clusters.
The behavior of this function is very similar their counterparts in R and python.

## Example

```julia

using RDatasets, Fastcluster

df = dataset("datasets", "iris")

points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
d = pairwise(Euclidean(), points, dims=1)
m,h = linkage(d, :single)
cut = cutree(m,(length(m)>>1)+1,3)
```
## Important Caveat for Ward Linkage

*NOTE:* The methods `:ward`, `:centroid`, and `:median` the function assumes that the distance metric used is the squared Euclidean distance (e.g. `SqEuclidean()` in Distances.jl). This is different to the R interface of fastcluster, which, for the `Ward.D2` method, operates on the squares of the distances that are passed to the `hclust` function. (The Python interface operates on the squares of the distances passed to the `linkage` function for all three methods, `:ward`, `:centroid`, and `:median`.) We choose this way in order to save on memory.

Hence, the following two snippets produce the same output:
```julia
using RDatasets, Fastcluster
df = dataset("datasets", "iris")
points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
d = pairwise(SqEuclidean(), points, dims=1)
m,h = linkage(d, meth)
cut = Fastcluster.cutree(m,(length(m)>>1)+1,3)
```

```julia
using RDatasets, Fastcluster
using RCall

df = dataset("datasets", "iris")
points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
d2 = pairwise(Euclidean(), points, dims=1)
@rput d
R"library('fastcluster')"
R"clusters <- hclust(as.dist(d), \"ward.D2\")"
R"clusterCut <- cutree(clusters, k = 3)"
@rget clusterCut
```
