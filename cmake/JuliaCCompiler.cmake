#

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
