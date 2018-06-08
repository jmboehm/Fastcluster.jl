
# ``points`` is an (n,m) array that contains the n points in m-dimensional space
# ``method`` is either
#   - :ward1
#   - :ward2
function hclust{T<:AbstractFloat}(points::Array{T,2}, method::Symbol, nclusters::Int64)
    
    @rput points
    
    R"library('fastcluster')"
    if method == :ward2
        R"clusters <- hclust(dist(points), \"ward.D2\")"
    elseif method == :ward1
        R"clusters <- hclust(dist(points), \"ward.D\")"
    end
    
    R"clusterCut <- cutree(clusters, $nclusters)"
    @rget clusterCut
    
    return clusterCut

end