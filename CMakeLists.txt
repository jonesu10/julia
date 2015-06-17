project(Julia C CXX)

## Setup cmake paths
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Utilities for defining options
include(JuliaOptions)

# Set versions
include(JuliaVersion)

# Architecture and compiler/flags
jl_str_option(ARCH "" "")
jl_set_option(JL_IS_MINGW "${MINGW}")
jl_set_option(JL_IS_MSYS "${MSYS}")

include(JuliaDirs)
include(JuliaCCompiler)

# TODO only enable if necessary
enable_language(Fortran)
include(JuliaFortranCompiler)

# OPENBLAS build options
jl_str_option(OPENBLAS_TARGET_ARCH "OpenBLAS Arch" "")
jl_str_option(OPENBLAS_SYMBOLSUFFIX "OpenBLAS symbol suffix" "")

# If OPENBLAS_TARGET_ARCH is set, we default to disabling OPENBLAS_DYNAMIC_ARCH
if(OPENBLAS_TARGET_ARCH STREQUAL "")
  jl_option(OPENBLAS_DYNAMIC_ARCH "" Off)
else()
  jl_option(OPENBLAS_DYNAMIC_ARCH "" On)
endif()
jl_option(OPENBLAS_USE_THREAD "" On)

# use_system options
use_system_opt(LLVM)
use_system_opt(LIBUNWIND)
use_system_opt(PCRE)
use_system_opt(LIBM)
use_system_opt(OPENLIBM)
jl_option(UNTRUSTED_SYSTEM_LIBM "Do not trust system libm" Off)
use_system_opt(OPENSPECFUN)
use_system_opt(DSFMT)
use_system_opt(BLAS)
use_system_opt(LAPACK)
use_system_opt(FFTW)
use_system_opt(GMP)
use_system_opt(MPFR)
use_system_opt(ARPACK)
use_system_opt(SUITESPARSE)
use_system_opt(RMATH)
use_system_opt(LIBUV)
use_system_opt(UTF8PROC)
use_system_opt(LIBGIT2)
use_system_opt(PATCHELF)

jl_option(USE_GPL_LIBS "Whether to use GPL libraries or not." On)

# LLVM related options
jl_option(USE_LLVM_SHLIB "Link to the LLVM shared library" Off)
jl_option(LLVM_ASSERTIONS "" Off)
jl_option(LLVM_DEBUG "" Off)
# Enable to get lldb (often does not work, no chance with llvm3.2 and earlier)
# see http://lldb.llvm.org/build.html for dependencies
jl_option(BUILD_LLDB "Build lldb" Off)
jl_option(BUILD_LLVM_CLANG "Build clang and compiler-rt" ${BUILD_LLDB})

include(JuliaDeps)

## Settings for various Intel tools
jl_option(USE_INTEL_MKL "Use MKL" Off)
jl_option(USE_INTEL_MKL_FFT "Use MKL FFT" Off)
jl_option(USE_INTEL_LIBM "Use Intel LIBM" Off)
jl_option(USE_INTEL_JITEVENTS
  "Enable profiling with Intel VTune Amplifier" Off)

jl_set_make_flag(CMAKE "${CMAKE_COMMAND}")

set(JL_SYSTEM_IMAGE_PATH "${build_private_libdir_rel}/sys.ji")

configure_file(src/julia-config.h.in include/julia/julia-config.h @ONLY)

# This is the trick in cmake to have proper dependency on a file
# For another command that depend on the output of this which needs to be
# updated automatically. The (custom) command should depend on the file output
# and the corresponding (custom) target should depend on this target.
if(WIN32 OR CYGWIN)
  add_custom_command(OUTPUT "${build_sysconfdir}/julia/juliarc.jl"
    COMMAND "${CMAKE_COMMAND}"
    "-DNSRC=2" "-DSRC1=${CMAKE_SOURCE_DIR}/etc/juliarc.jl"
    "-DSRC2=${CMAKE_SOURCE_DIR}/contrib/windows/juliarc.jl"
    "-DDST=${build_sysconfdir}/julia/juliarc.jl"
    -P "${CMAKE_SOURCE_DIR}/cmake/CatFiles.cmake"
    DEPENDS etc/juliarc.jl contrib/windows/juliarc.jl
    "${CMAKE_SOURCE_DIR}/cmake/CatFiles.cmake")
elseif(APPLE)
  add_custom_command(OUTPUT "${build_sysconfdir}/julia/juliarc.jl"
    COMMAND "${CMAKE_COMMAND}"
    "-DNSRC=2" "-DSRC1=${CMAKE_SOURCE_DIR}/etc/juliarc.jl"
    "-DSRC2=${CMAKE_SOURCE_DIR}/contrib/mac/juliarc.jl"
    "-DDST=${build_sysconfdir}/julia/juliarc.jl"
    -P "${CMAKE_SOURCE_DIR}/cmake/CatFiles.cmake"
    DEPENDS etc/juliarc.jl contrib/mac/juliarc.jl
    "${CMAKE_SOURCE_DIR}/cmake/CatFiles.cmake")
else()
  add_custom_command(OUTPUT "${build_sysconfdir}/julia/juliarc.jl"
    COMMAND "${CMAKE_COMMAND}" -E copy
    "${CMAKE_SOURCE_DIR}/etc/juliarc.jl"
    "${build_sysconfdir}/julia/juliarc.jl"
    DEPENDS etc/juliarc.jl)
endif()

add_custom_target(juliarc-jl
  DEPENDS "${build_sysconfdir}/julia/juliarc.jl")

add_custom_command(OUTPUT "${build_man1dir}/julia.1"
  COMMAND "${CMAKE_COMMAND}" -E copy
  "${CMAKE_SOURCE_DIR}/doc/man/julia.1"
  "${build_man1dir}/julia.1"
  DEPENDS doc/man/julia.1)

add_custom_target(julia-man1
  DEPENDS "${build_man1dir}/julia.1")

# TODO
if(USE_SYSTEM_LIBUV)
  set(LIBUV /usr/lib/libuv-julia.a)
  set(LIBUV_INC /usr/include)
else()
  set(LIBUV "${build_libdir}/libuv.a")
  set(LIBUV_INC "${build_includedir}")
endif()

jl_set_make_flag(LIBUV "${LIBUV}")
jl_set_make_flag(LIBUV_INC "${LIBUV_INC}")

if(USE_SYSTEM_UTF8PROC)
  set(LIBUTF8PROC -lutf8proc)
  set(UTF8PROC_INC /usr/include)
else()
  set(LIBUTF8PROC "${build_libdir}/libutf8proc.a")
  set(UTF8PROC_INC "${build_includedir}")
endif()

jl_set_make_flag(LIBUTF8PROC "${LIBUTF8PROC}")
jl_set_make_flag(UTF8PROC_INC "${UTF8PROC_INC}")

jl_get_make_flags(jl_make_flags)

# message("${jl_make_flags}")

add_subdirectory(deps)
add_subdirectory(test)
add_subdirectory(contrib)
add_subdirectory(src)

add_custom_target(julia ALL
  DEPENDS julia-deps libccalltest stringreplace flmain
  COMMAND make ${jl_make_flags}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
