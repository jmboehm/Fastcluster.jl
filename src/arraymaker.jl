using Cxx
using Libdl

const path_to_lib = pwd()

addHeaderDir(path_to_lib, kind=C_System)
Libdl.dlopen(path_to_lib * "/src/libArrayMaker.so", Libdl.RTLD_GLOBAL)
cxxinclude("src/ArrayMaker.h")

# Creating class object
maker = @cxxnew ArrayMaker(5,2.0)

arr = @cxx maker->fillArr()


pointer_to_array(arr, 5)
