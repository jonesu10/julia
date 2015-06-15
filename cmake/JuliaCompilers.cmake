#

jl_str_option(JULIA_C_COMPILER "C/C++ compiler to use" "")
jl_str_option(JULIA_FORTRAN_COMPILER "Fortran compiler to use" "")
# libc++ is standard on OS X 10.9, but not for earlier releases
jl_option(USE_LIBCPP "Use libc++" Off)
# assume we don't have LIBSSP support in our compiler,
# will enable later if likely true
jl_option(HAVE_SSP "Have LibSSP support" Off)

#
jl_set_option(USEICC Off)
jl_set_option(USEGCC Off)
jl_set_option(USECLANG Off)
jl_set_option(USEMSVC Off)

jl_set_option(USEIFC Off)

if(JULIA_C_COMPILER STREQUAL icc)
  jl_set_option(USEICC On)
elseif(JULIA_C_COMPILER STREQUAL gcc)
  jl_set_option(USEGCC On)
elseif(JULIA_C_COMPILER STREQUAL clang)
  jl_set_option(USECLANG On)
elseif(JULIA_C_COMPILER STREQUAL msvc)
  jl_set_option(USEMSVC On)
endif()

if(JULIA_FORTRAN_COMPILER STREQUAL ifc)
  jl_set_option(USEIFC On)
endif()
