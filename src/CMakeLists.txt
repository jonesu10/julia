#

add_subdirectory(support)
add_subdirectory(flisp)

set(FLISP_EXECUTABLE "${CMAKE_CURRENT_BINARY_DIR}/flisp/flisp")

set(julia_flisp_boot_SRCS
  julia-parser.scm
  julia-syntax.scm
  match.scm
  utils.scm
  jlfrontend.scm
  mk_julia_flisp_boot.scm)

set(julia_flisp_boot "${CMAKE_CURRENT_BINARY_DIR}/julia_flisp.boot")

add_custom_command(OUTPUT "${julia_flisp_boot}"
  COMMAND "${CMAKE_COMMAND}" -E env "julia_flisp.boot=${julia_flisp_boot}"
  "${FLISP_EXECUTABLE}" ./mk_julia_flisp_boot.scm
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  DEPENDS ${julia_flisp_boot_SRCS} flmain)

add_custom_target(julia_flisp_boot
  DEPENDS "${julia_flisp_boot}" flmain)

set(julia_flisp_boot_inc "${CMAKE_CURRENT_BINARY_DIR}/julia_flisp.boot.inc")

#TODO make the input and output arguments or envs
add_custom_command(OUTPUT "${julia_flisp_boot_inc}"
  COMMAND "${FLISP_EXECUTABLE}" ./bin2hex.scm < "${julia_flisp_boot}"
  > "${julia_flisp_boot_inc}"
  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
  DEPENDS "${julia_flisp_boot}" flmain)

add_custom_target(julia_flisp_boot_inc
  DEPENDS "${julia_flisp_boot_inc}" julia_flisp_boot)
