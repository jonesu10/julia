#

# libc++ is standard on OS X 10.9, but not for earlier releases
jl_option(USE_LIBCPP "Use libc++" Off)
# assume we don't have LIBSSP support in our compiler,
# will enable later if likely true
jl_option(HAVE_SSP "Have LibSSP support" Off)

jl_set_option(USEICC Off)
jl_set_option(USEGCC Off)
jl_set_option(USECLANG Off)
jl_set_option(USEMSVC Off)

if(CMAKE_C_COMPILER_ID STREQUAL "AppleClang" OR
    CMAKE_C_COMPILER_ID STREQUAL "Clang")
  jl_set_option(USECLANG On)
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  jl_set_option(USEGCC On)
elseif(CMAKE_C_COMPILER_ID STREQUAL "Intel")
  jl_set_option(USEICC On)
elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  jl_set_option(USEMSVC On)
else()
  # TODO
  message(FATAL_ERROR "Unsupported compiler ${CMAKE_C_COMPILER_ID}")
endif()

if(NOT USECLANG)
  if(USE_LIBCPP)
    message(FATAL_ERROR
      "USE_LIBCPP only supported with clang. Try setting USE_LIBCPP=0")
  endif()
  if(SANITIZE)
    message(FATAL_ERROR
      "Address Sanitizer only supported with clang. Try setting SANITIZE=0")
  endif()
endif()

jl_set_make_flag(CC "${CMAKE_C_COMPILER}")
jl_set_make_flag(CXX "${CMAKE_CXX_COMPILER}")
string(SUBSTRING "${CMAKE_SHARED_LIBRARY_SUFFIX}" 1 -1 SHLIB)
jl_set_make_flag(SHLIB_EXT "${SHLIB}")
