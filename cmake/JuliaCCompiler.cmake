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

push_c_flags(CMAKE_CXX_FLAGS -std=c++11)
set(JL_CPP_FLAGS)

if(CMAKE_C_COMPILER_ID STREQUAL "AppleClang" OR
    CMAKE_C_COMPILER_ID STREQUAL "Clang")
  jl_set_option(USECLANG On)
  push_c_flags(CMAKE_C_FLAGS -pipe -fPIC -fno-strict-aliasing
    -D_FILE_OFFSET_BITS=64)
  push_c_flags(CMAKE_CXX_FLAGS -pipe -fPIC -fno-rtti)
  push_c_flags(CMAKE_C_FLAGS_DEBUG -O0 -g -DJL_DEBUG_BUILD
    -fstack-protector-all)
  push_c_flags(CMAKE_CXX_FLAGS_DEBUG -O0 -g -DJL_DEBUG_BUILD
    -fstack-protector-all)
  push_c_flags(CMAKE_C_FLAGS_RELEASE -O3 -g)
  push_c_flags(CMAKE_CXX_FLAGS_RELEASE -O3 -g)
  if(APPLE)
    if(USE_LIBCPP)
      push_c_flags(CMAKE_C_FLAGS -stdlib=libc++ -mmacosx-version-min=10.7)
      push_c_flags(CMAKE_CXX_FLAGS -stdlib=libc++ -mmacosx-version-min=10.7)
    else()
      push_c_flags(CMAKE_C_FLAGS -mmacosx-version-min=10.6)
      push_c_flags(CMAKE_CXX_FLAGS -mmacosx-version-min=10.6)
    endif()
    push_c_flags(JL_CPP_FLAGS -D_LARGEFILE_SOURCE -D_DARWIN_USE_64_BIT_INODE=1)
  endif()
elseif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
  jl_set_option(USEGCC On)
  push_c_flags(CMAKE_C_FLAGS -std=gnu99 -pipe -fPIC -fno-strict-aliasing
    -D_FILE_OFFSET_BITS=64)
  push_c_flags(CMAKE_CXX_FLAGS -pipe -fPIC -fno-rtti)
  push_c_flags(CMAKE_C_FLAGS_DEBUG -O0 -ggdb3 -DJL_DEBUG_BUILD
    -fstack-protector-all)
  push_c_flags(CMAKE_CXX_FLAGS_DEBUG -O0 -ggdb3 -DJL_DEBUG_BUILD
    -fstack-protector-all)
  push_c_flags(CMAKE_C_FLAGS_RELEASE -O3 -ggdb3 -falign-functions)
  push_c_flags(CMAKE_CXX_FLAGS_RELEASE -O3 -ggdb3 -falign-functions)
elseif(CMAKE_C_COMPILER_ID STREQUAL "Intel")
  jl_set_option(USEICC On)
  push_c_flags(CMAKE_C_FLAGS -std=gnu99 -pipe -fPIC -fno-strict-aliasing
    -D_FILE_OFFSET_BITS=64 -fp-model precise -fp-model except -no-ftz)
  push_c_flags(CMAKE_CXX_FLAGS -pipe -fPIC -fno-rtti)
  push_c_flags(CMAKE_C_FLAGS_DEBUG -O0 -g -DJL_DEBUG_BUILD
    -fstack-protector-all)
  push_c_flags(CMAKE_CXX_FLAGS_DEBUG -O0 -g -DJL_DEBUG_BUILD
    -fstack-protector-all)
  push_c_flags(CMAKE_C_FLAGS_RELEASE -O3 -g -falign-functions)
  push_c_flags(CMAKE_CXX_FLAGS_RELEASE -O3 -g -falign-functions)
elseif(CMAKE_C_COMPILER_ID STREQUAL "MSVC")
  jl_set_option(USEMSVC On)
else()
  # TODO
  message(FATAL_ERROR "Unsupported compiler ${CMAKE_C_COMPILER_ID}")
endif()

push_c_flags(CMAKE_C_FLAGS "-I${CMAKE_BINARY_DIR}/include")
push_c_flags(CMAKE_CXX_FLAGS "-I${CMAKE_BINARY_DIR}/include")

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

jl_set_make_flag(JCFLAGS "${CMAKE_C_FLAGS}")
jl_set_make_flag(JCXXFLAGS "${CMAKE_CXX_FLAGS}")

jl_set_make_flag(JCPPFLAGS "${JL_CPP_FLAGS}")

jl_set_make_flag(DEBUGFLAGS "${CMAKE_C_FLAGS_DEBUG}")
jl_set_make_flag(SHIPFLAGS "${CMAKE_C_FLAGS_RELEASE}")
