project(Julia NONE)
# Do not enable any languages yet because we might want to set compilers

## Setup cmake paths
cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
  "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Utilities for defining options
include(JuliaOptions)

# Set versions
include(JuliaVersion)

jl_str_option(ARCH "" "")

include(JuliaCompilers)

enable_language(C CXX Fortran)

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

jl_option(USE_LLVM_SHLIB "Link to the LLVM shared library" Off)

include(JuliaDirs)

## Settings for various Intel tools
jl_option(USE_INTEL_MKL "Use MKL" Off)
jl_option(USE_INTEL_MKL_FFT "Use MKL FFT" Off)
jl_option(USE_INTEL_LIBM "Use Intel LIBM" Off)
jl_option(USE_INTEL_JITEVENTS
  "Enable profiling with Intel VTune Amplifier" Off)

jl_set_make_flag(CMAKE "${CMAKE_COMMAND}")

jl_get_make_flags(jl_make_flags)

message("${jl_make_flags}")

add_custom_target(julia ALL
  COMMAND make ${jl_make_flags}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
