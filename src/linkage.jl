# linkage.jl

# converts a distance matrix to the vector format expected by the library
function dist_to_vec(m::Array{T,2}) where {T<:Real}
    # check that matrix is square
    rows = size(m, 1)
    if rows != size(m,2)
        error("dist_to_vec() expects a square matrix.")
    end
    v = T[]
    for c = 1:rows
        for r = (c+1):rows
            push!(v,m[r,c])
        end
    end
    return v
end

#
# d::Array{Float64,2} is the dissimilarity matrix between the points to cluster. You
#   can use the [Distances.jl](https://github.com/JuliaStats/Distances.jl) package to
#   generate dissimilarity matrix.
# method::Symbol is one of the following: `:single`, `:complete`, `:average`, `:weighted`, `:ward`, `:centroid`, `:median`.
#
# *NOTE:* The methods `:ward`, `:centroid`, and `:median` the function assumes that
# the distance metric used is the squared Euclidean distance (e.g. `SqEuclidean()` in Distances.jl).
# This is different to the R interface of fastcluster, which, for the `Ward.D2` method, operates on the
# squares of the distances that are passed to the `hclust` function. (The Python interface operates on the
# squares of the distances passed to the `linkage` function for all three methods, `:ward`, `:centroid`, and `:median`.)
# We choose this way in order to save on memory.
function linkage(d::Array{T,2}, method::Symbol) where {T<:Real}
    return linkage_ext(d, method, false)
end

# The linkage!(d::Array{T,2}, method::Symbol) version of the function
# allows fastcluster to write in the memory occupied by `d` (without
# restoring the memory to the original values afterwards. Use this
# version if memory is scarce and you do not care about the content
# of `d` afterwards.
function linkage!(d::Array{T,2}, method::Symbol) where {T<:Real}
    return linkage_ext(d, method, false)
end

# preserve_input::Bool is an optional argument that, if set to `false`, allows
#   fastcluster to write onto the memory occupied by `d`, thereby preserving
#   memory.
function linkage_ext(d::Array{T,2}, method::Symbol, preserve_input::Bool) where {T<:Real}

    # dictionary for linkage methods, from fastcluster
    mthidx = Dict(:single => 0,
              :complete  => 1,
              :average   => 2,
              :weighted  => 3,
              :ward      => 4,
              :centroid  => 5,
              :median    => 6 )

    nobs = size(d, 1)
    m = zeros(Int32,2*(nobs-1))
    height = zeros(Float64,nobs-1)

    # D = pairwise(metric, X, dims=1)
    d2 = dist_to_vec(d)

    # Cxx.jl version
    #@cxx hclust_fast(nobs, pointer(d), mthidx[method], pointer(m), pointer(height) )

    # call the C function
    t = ccall((:hclust_fast, "src/libfastcluster.so"),
        Int32,
        (Int32, Ptr{Cdouble},Int32, Ptr{Cdouble},Ptr{Cdouble}),
        nobs, d2, mthidx[method], m, height
        )

    return m, height

    #
    # o = Array{Int32,1}(undef, 2*(nobs-1))
    # out = Base.unsafe_wrap(Array{Int32,1}, m, 2*(nobs-1))
    #
    #
    # N = size(X,1)
    # # get distances
    # D = pairwise(metric, X, dims=1)
    # Z = Array{Float64,2}(undef,N - 1, 4)
    # if N > 1:
    #     linkage_wrap(N, X, Z, mthidx[method])
    # return Z

end

# This function returns the labels for the k-cluster cut.
# Labels are between 1 and k.
function cutree(m::Vector{Int32}, nobs::Int64, k::Int64)

    # allocate memory for new array
    labels = Vector{Int32}(undef, nobs)

    # Cxx.jl version
    #@cxx cutree_k(nobs, pointer(m), k, pointer(labels))

    t = ccall((:cutree_k, "src/libfastcluster.so"),
        Int32,
        (Int32, Ptr{Cdouble}, Int32, Ptr{Cint}),
        nobs, m, k, labels
        )

    labels .+= 1
    # convert this to Int64, better to use in Julia
    labels64::Vector{Int64} = labels

    return labels64

end
