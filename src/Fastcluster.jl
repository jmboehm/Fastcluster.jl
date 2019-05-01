
# TODO
# - use `BinaryBuilder.jl` or something to host binaries
# - add an interface via points & distance metrics
# - get rid of `nobs` in `cutree()`

module Fastcluster

    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    #using Distances
    #using Cxx
    #using Libdl

    #using RCall
    #using JLD2

    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export linkage, cutree



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

        # make sure that libfastcluster.so exists and can be called
        t = ccall((:validate, "src/libfastcluster.so"),
            Int32,
            ()
            )
        if t != 42
            error("Failed to load libfastcluster.so.")
        end

        # path_to_lib = @__DIR__
        # addHeaderDir(path_to_lib, kind=C_System)
        # Libdl.dlopen(path_to_lib * "/libfastcluster.so", Libdl.RTLD_GLOBAL)
        # cxxinclude("fastcluster.h")
    end

end
