#

set(flisp_SRCS flisp.c
  builtins.c
  string.c
  equalhash.c
  table.c
  iostream.c
  julia_extensions.c)

if(USEMSVC)
  set(flisp_SRCS ${flisp_SRCS} dirname.c)
endif()

set(flmain_SRCS flmain.c)

include_directories(../support ${LIBUV_INC} ${UTF8PROC_INC})

add_definitions(-DLIBRARY_EXPORT -DUTF8PROC_EXPORTS)

if(NOT USEMSVC)
  add_definitions(-Wall -Wno-strict-aliasing -DUSE_COMPUTED_GOTO
    -fvisibility=hidden -pthread)
endif()

add_library(flisp STATIC ${flisp_SRCS})

add_executable(flmain ${flmain_SRCS})

if(NOT WIN32)
  target_link_libraries(flisp -pthread)
  target_link_libraries(flmain -pthread)
endif()

target_link_libraries(flisp ${LIBUV} ${UTF8PROC} support dl)
target_link_libraries(flmain flisp)
