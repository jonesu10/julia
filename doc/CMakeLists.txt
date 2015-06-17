#

add_custom_target(julia-doc-html ALL
  COMMAND make html ${jl_make_flags}
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
