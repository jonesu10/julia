#

set(libsupport_SRCS
  hashing.c
  timefuncs.c
  ptrhash.c
  operators.c
  utf8.c
  ios.c
  htable.c
  bitvector.c
  int2str.c
  libsupportinit.c
  arraylist.c
  strtod.c)

if(WIN32)
  set(libsupport_SRCS asprintf.c)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(libsupport_SRCS _setjmp.win64.c _longjmp.win64.c)
  else()
    set(libsupport_SRCS _setjmp.win32.c _longjmp.win32.c)
  endif()
endif()
