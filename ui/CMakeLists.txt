#

add_custom_target(julia-ui ALL
  DEPENDS julia-deps libjulia
  COMMAND make julia-release ${jl_make_flags}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
