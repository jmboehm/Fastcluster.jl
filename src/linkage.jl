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
        for r = 1:(c-1)
            push!(v,m[r,c])
        end
    end
    return v
end

# The optional argument 'preserve_input' specifies whether the method
# makes a working copy of the dissimilarity vector or writes temporary
# data into the existing array. If the dissimilarities are generated for
# the clustering step only and are not needed afterward, approximately
# half the memory can be saved by specifying 'preserve_input=False'. Note
# that the input array X contains unspecified values after this procedure.
# It is therefore safer to write
#
#   linkage(X, method=..., preserve_input=false)
#   X = []
#
# to make sure that the matrix X is not accessed accidentally after it has
# been used as scratch memory. (The single linkage algorithm does not
# write to the distance matrix or its copy anyway, so the 'preserve_input'
# flag has no effect in this case.)

# If X contains vector data, it must be a two-dimensional array with N
# observations in D dimensions as an (N×D) array. The preserve_input
# argument is ignored in this case. The specified metric is used to
# generate pairwise distances from the input. The following two function
# calls yield the same output:
#
#   linkage(pdist(X, metric), method="...", preserve_input=False)
#   linkage(X, metric=metric, method="...")
#
# For method=:ward, the function assumes that metric = SqEuclidean() will be chosen.

function linkage(X::Array{T,2}; method::Symbol = :single, metric = Euclidean(), preserve_input::Bool = true) where {T<:Real}

    X = rand(Float64, 10, 2)
    metric = SqEuclidean()
    method = :ward

    # actual code starts here

    mthidx = Dict(:single => 0,
              :complete  => 1,
              :average   => 2,
              :weighted  => 3,
              :ward      => 4,
              :centroid  => 5,
              :median    => 6 )

    nobs = size(X, 1)
    m = zeros(Int32,2*(nobs-1))
    height = zeros(Float64,nobs-1)

    D = pairwise(metric, X, dims=1)
    d = dist_to_vec(D)

    # Cxx.jl version
    #@cxx hclust_fast(nobs, pointer(d), mthidx[method], pointer(m), pointer(height) )

    # call the C function
    t = ccall((:hclust_fast, "src/libfastcluster.so"),
        Int32,
        (Int32, Ptr{Cdouble},Int32, Ptr{Cdouble},Ptr{Cdouble}),
        nobs, d, mthidx[method], m, height
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
# Labels are between 0 and k-1.
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

    return labels

end
