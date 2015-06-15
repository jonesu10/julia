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
endif()

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
