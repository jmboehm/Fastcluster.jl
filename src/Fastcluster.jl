
# TODO
# - add an interface via points & distance metrics
# - get rid of `nobs` in `cutree()`

module Fastcluster

    # # Load in `deps.jl`, complaining if it does not exist
    # const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
    # if !isfile(depsjl_path)
    #     error("Fastcluster.jl not installed properly, run Pkg.build(\"Fastcluster\"), restart Julia and try again")
    # end
    # include(depsjl_path)

    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    # no dependencies

    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export linkage, cutree

    # global const __pkgsrcdir = @__DIR__
    # global const __libfastcluster = joinpath(__pkgsrcdir, "../lib/libfastcluster.dylib")
    global const __pkgsrcdir = @__DIR__
    global const libfastcluster = joinpath(__pkgsrcdir, "../deps/usr/libfastcluster.so")


    ##############################################################################
    ##
    ## Load files
    ##
    ##############################################################################

    include("linkage.jl")

    ##############################################################################
    ##
    ## Initialize libfastcluster
    ##
    ##############################################################################

    function __init__()

        # Always check your dependencies from `deps.jl`
        #check_deps()

        # make sure that libfastcluster.so exists and can be called
        try
            d = @__DIR__
            t = ccall((:validate, libfastcluster),
                Int32,
                ()
                )
            if t != 42
                error("Failed to load libfastcluster.")
            end
        catch
            error("Failed to load libfastcluster.")
        end

    end

end
