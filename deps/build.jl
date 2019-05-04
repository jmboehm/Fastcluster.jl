using BinaryProvider

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))

# These are the two binary objects we care about
products = Product[
    LibraryProduct(prefix, "libfastcluster", :libfastcluster)
]

# Download binaries from hosted location
bin_prefix = "https://github.com/jmboehm/FastclusterBuilder/releases/download/0.0.1"
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/libfastcluster.v0.0.1.aarch64-linux-gnu.tar.gz", "74f873d6120ca95d7a4ef500c1f17d8636c5f1165452e4efccb8b66db0b0d921"),
    Linux(:armv7l, :glibc)  => ("$bin_prefix/libfastcluster.v0.0.1.arm-linux-gnueabihf.tar.gz", "04708fc8f5e5cb9b5432a842d1c29f3a8739445f1613655b31350f7a461590b4"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/libfastcluster.v0.0.1.powerpc64le-linux-gnu.tar.gz", "9c5ff18272a241df216885a45b76ec7b535ff0c9a0314ce7d8052ac7288f638f"),
    Linux(:i686, :glibc)    => ("$bin_prefix/libfastcluster.v0.0.1.i686-linux-gnu.tar.gz", "ca945df0fe0248c7e84ff0035201de832e46941a67c1deaff38ad7411986e9f6"),
    Linux(:x86_64, :glibc)  => ("$bin_prefix/libfastcluster.v0.0.1.x86_64-linux-gnu.tar.gz", "1762bc297a6f2bd9eafd3e3da2d9ba5e56b502b6834d1a861fc0eee8a0be77d5"),

    Linux(:aarch64, :musl)  => ("$bin_prefix/libfastcluster.v0.0.1.aarch64-linux-musl.tar.gz", "fab9df6f18f62550ea85690e3e3070de7fe9f9f6c991198953dae75d350ac878"),
    Linux(:armv7l, :musl)   => ("$bin_prefix/libfastcluster.v0.0.1.arm-linux-musleabihf.tar.gz", "9af5b1631a5e8ecf33dcf660d79270c7fe428ea6d3614e9d15a3c52f4bf16b70"),
    Linux(:i686, :musl)     => ("$bin_prefix/libfastcluster.v0.0.1.i686-linux-musl.tar.gz", "b167e77606216af5baaa58726b314b930944c1bb169c83dc93861eaa62a2adf8"),
    Linux(:x86_64, :musl)   => ("$bin_prefix/libfastcluster.v0.0.1.x86_64-linux-musl.tar.gz", "6d4f7d89656aeac60e889b470bd39986ede9d88d1ea351b02da5822f5dbbc55a"),

    FreeBSD(:x86_64)        => ("$bin_prefix/libfastcluster.v0.0.1.x86_64-unknown-freebsd11.1.tar.gz", "2d70eae69980f537abfe0395e5539ad46a0db3c5f402236931677829065ee55e"),
    MacOS(:x86_64)          => ("$bin_prefix/libfastcluster.v0.0.1.x86_64-apple-darwin14.tar.gz", "7154e6d81bf91df3e59e2d2e76243b62e098d4b45a8e4df1d5bf14d6d6857c06"),

    Windows(:i686)          => ("$bin_prefix/libfastcluster.v0.0.1.i686-w64-mingw32.tar.gz", "3926031d25e52f894ef89b5f65de4b9bc57aa09c80d2f6e9824353c5c6429c9d"),
    Windows(:x86_64)        => ("$bin_prefix/libfastcluster.v0.0.1.x86_64-w64-mingw32.tar.gz", "3926031d25e52f894ef89b5f65de4b9bc57aa09c80d2f6e9824353c5c6429c9d"),
)
# To get hashes:
# function url2hash(url::String)
#     path = download(url)
#     open(io-> bytes2hex(BinaryProvider.sha256(io)), path)
# end
# for i in keys(download_info)
#         @show i
#         @show url2hash(download_info[i][1])
# end

# First, check to see if we're all satisfied
if any(!satisfied(p; verbose=verbose) for p in products)
    try
        # Download and install binaries
        url, tarball_hash = choose_download(download_info)
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    catch e
        if typeof(e) <: ArgumentError
            error("Your platform $(Sys.MACHINE) is not supported by this package!")
        else
            rethrow(e)
        end
    end

    # Finally, write out a deps.jl file
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
