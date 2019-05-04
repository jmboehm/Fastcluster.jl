# Test file for linkage.jl

# These tests compare the results with the R interface of fastcluster,
# NOT with another implementation of hierarchical clustering. Hence,
# they should be taken as a validity of the interface, NOT the package
# as such.

using Test
using RDatasets
using Distances
using DataFrames
using RCall

using Fastcluster

# this function assumes that clusters are indexed 1:k
function are_clusters_equal(c1::Vector{T}, c2::Vector{T}) where {T<:Integer}
    k = maximum(c1)
    if k!=maximum(c2)
        # different number of clusters
        return false
    end
    out = zeros(T, k,k)
    for i = 1:k
        for j = 1:k
            out[i,j] = sum((c1 .== i) .& (c2 .== j))
        end
    end
    return all(sum(out.>=1,dims=1) .== 1) & all(sum(out.>=1,dims=2) .== 1)
end

# Start the testing. Happy testing.

df = dataset("datasets", "iris")
#
# answers = Dict{Symbol,Vector{Int64}}()
#
# answers[:single] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
# answers[:complete] = [1, 2, 2, 2, 1, 1, 2, 1, 2, 2, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 2, 2, 1, 1, 1, 2, 2, 1, 1, 1, 2, 1, 1, 1, 2, 1, 1, 2, 2, 1, 1, 2, 1, 2, 1, 1, 3, 1, 3, 2, 1, 2, 1, 2, 1, 2, 2, 1, 1, 1, 2, 3, 2, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 1, 2, 1, 3, 1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 3, 1, 1, 3, 2, 3, 1, 3, 1, 1, 1, 2, 2, 1, 1, 3, 3, 1, 3, 2, 3, 1, 3, 3, 1, 1, 1, 3, 3, 3, 1, 1, 1, 3, 1, 1, 1, 3, 3, 3, 2, 3, 3, 1, 1, 1, 1, 1]
# answers[:average] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 3, 2, 2, 3, 1, 3, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 3, 2, 2, 3, 2, 2, 2, 3, 3, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
# answers[:weighted] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 2, 2, 2, 1, 2, 1, 1, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 1, 2, 2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 3, 2, 2, 3, 1, 3, 2, 3, 2, 2, 2, 1, 1, 2, 2, 3, 3, 2, 2, 1, 3, 2, 2, 3, 2, 2, 2, 3, 3, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2]
# answers[:centroid] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 1, 2, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 2, 2, 2, 3, 2, 2, 3, 1, 3, 2, 3, 2, 2, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 3, 2, 2, 3, 2, 2, 2, 3, 3, 3, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
# answers[:median] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 2, 1, 2, 1, 2, 1, 1, 1, 2, 1, 1, 2, 1, 1, 2, 1, 1, 1, 2, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 3, 2, 2, 3, 1, 3, 2, 3, 2, 2, 2, 1, 1, 2, 2, 3, 3, 2, 2, 1, 3, 2, 2, 3, 2, 1, 2, 3, 3, 3, 2, 2, 1, 3, 2, 2, 1, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]
# answers[:ward] = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 2, 3, 2, 1, 2, 1, 1, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 2, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 1, 3, 2, 3, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 3, 2, 3, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 2, 3, 2, 2, 3]
#
# for meth in [:single, :complete, :average, :weighted, :centroid, :median]
#     println("Testing interface with method=:$(string(meth))...")
#     for k in [3]
#         # run once with R interface, and once with Fastcluster.jl interface
#         points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
#         d = pairwise(Euclidean(), points, dims=1)
#         m,h = Fastcluster.linkage(d, meth)
#         c_fastcluster = Fastcluster.cutree(m,(length(m)>>1)+1,k)
#         #@show c_fastcluster
#         @test are_clusters_equal(c_fastcluster, answers[meth])
#     end
#     println("Ok.")
# end
#
# # for
# for meth in [:ward]
#     println("Testing interface with method=:$(string(meth))...")
#     for k in [3]
#         # run once with R interface, and once with Fastcluster.jl interface
#         points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
#         d = pairwise(SqEuclidean(), points, dims=1)
#         m,h = Fastcluster.linkage(d, meth)
#         c_fastcluster = Fastcluster.cutree(m,(length(m)>>1)+1,k)
#         d2 = pairwise(Euclidean(), points, dims=1)
#         #@show c_fastcluster
#         @test are_clusters_equal(c_fastcluster, answers[meth])
#     end
#     println("Ok.")
# end



R"r = getOption(\"repos\")
r[\"CRAN\"] = \"http://cran.uk.r-project.org\"
options(repos = r)
rm(r)"
R"install.packages(\"fastcluster\", lib = Sys.getenv(\"R_LIBS_USER\"))"

# function to wrap R interface:
function cluster_and_cut_R(d::Array{T,2}, method::Symbol, nclusters::Int64) where {T<:Real}

    @rput d

    mthidx = Dict(:single => 0,
              :complete  => 1,
              :average   => 2,
              :weighted  => 3,
              :ward      => 4,
              :centroid  => 5,
              :median    => 6 )

    # for R's fastcluster, method must be: "single", "complete",
    # "average", "mcquitty", "ward.D",
    # "ward.D2", "centroid" or "median".

    R"library('fastcluster')"

    if method == :single
        R"clusters <- hclust(as.dist(d), \"single\")"
    elseif method == :complete
        R"clusters <- hclust(as.dist(d), \"complete\")"
    elseif method == :average
        R"clusters <- hclust(as.dist(d), \"average\")"
    elseif method == :weighted
        R"clusters <- hclust(as.dist(d), \"mcquitty\")"
    elseif method == :ward
        R"clusters <- hclust(as.dist(d), \"ward.D2\")"
    elseif method == :ward1
        R"clusters <- hclust(as.dist(d), \"ward.D\")"
    elseif method == :centroid
        R"clusters <- hclust(as.dist(d), \"centroid\")"
    elseif method == :median
        R"clusters <- hclust(as.dist(d), \"median\")"
    else
        error("Invalid or unsupported method.")
    end

    @rput nclusters
    R"clusterCut <- cutree(clusters, k = nclusters)"
    @rget clusterCut

    return clusterCut

end

for meth in [:single, :complete, :average, :weighted, :centroid, :median]
    println("Testing interface with method=:$(string(meth))...")
    for k in [1 , 3, 5]
        # run once with R interface, and once with Fastcluster.jl interface
        points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
        d = pairwise(Euclidean(), points, dims=1)
        m,h = Fastcluster.linkage(d, meth)
        c_fastcluster = Fastcluster.cutree(m,(length(m)>>1)+1,k)
        r_fastcluster = cluster_and_cut_R(d, meth, k)
        @test are_clusters_equal(c_fastcluster, r_fastcluster)
    end
    println("Ok.")
end

# for
for meth in [:ward]
    println("Testing interface with method=:$(string(meth))...")
    for k in [1 , 3, 5]
        # run once with R interface, and once with Fastcluster.jl interface
        points = convert(Array{Float64,2},df[:,[:SepalWidth, :SepalLength]])
        d = pairwise(SqEuclidean(), points, dims=1)
        m,h = Fastcluster.linkage(d, meth)
        c_fastcluster = Fastcluster.cutree(m,(length(m)>>1)+1,k)
        d2 = pairwise(Euclidean(), points, dims=1)
        r_fastcluster = cluster_and_cut_R(d2, meth, k)
        @test are_clusters_equal(c_fastcluster, r_fastcluster)
    end
    println("Ok.")
end
