find_package(Git QUIET)

if(GIT_FOUND)
  set(NO_GIT_DEF Off)
else()
  set(NO_GIT_DEF On)
endif()

jl_option(NO_GIT "Do not use git during the build" "${NO_GIT_DEF}")
if(NOT NO_GIT AND NOT IS_DIRECTORY "${CMAKE_SOURCE_DIR}/.git")
  message(WARNING "git information unavailable; versioning information limited")
  set(NO_GIT Off CACHE INTERNAL "" FORCE)
  jl_set_option(NO_GIT Off)
endif()

# TODO? Maybe make VERSION a configure file rather than reading it

file(READ "${CMAKE_SOURCE_DIR}/VERSION" JULIA_VERSION)
string(STRIP "${JULIA_VERSION}" JULIA_VERSION)

jl_set_make_flag(JULIA_VERSION "${JULIA_VERSION}")

if(NO_GIT)
  set(JULIA_COMMIT "${JULIA_VERSION}")
else()
  execute_process(COMMAND "${GIT_EXECUTABLE}" rev-parse --short=10 HEAD
    OUTPUT_VARIABLE JULIA_COMMIT
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

jl_set_make_flag(JULIA_COMMIT "${JULIA_COMMIT}")

# TODO Check match??
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+)\\..*$" "\\1.\\2"
  VERSDIR "${JULIA_VERSION}")
set(VERSDIR "v${VERSDIR}")

# TODO: Code bundled with Julia should be installed into a versioned directory,
# prefix/share/julia/VERSDIR, so that in the future one can have multiple
# major versions of Julia installed concurrently. Third-party code that
# is not controlled by Pkg should be installed into
# prefix/share/julia/site/VERSDIR (not prefix/share/julia/VERSDIR/site ...
# so that prefix/share/julia/VERSDIR can be overwritten without touching
# third-party code).

jl_set_make_flag(VERSDIR "${VERSDIR}")
