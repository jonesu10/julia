#

add_custom_target(julia-copy-all-base)

function(copy_jl src)
  if("${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    return()
  endif()
  add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${src}"
    COMMAND "${CMAKE_COMMAND}" -E copy
    "${CMAKE_CURRENT_SOURCE_DIR}/${src}"
    "${CMAKE_CURRENT_BINARY_DIR}/${src}"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${src}")
  # TODO maybe handle other invalid target names too
  string(REPLACE "/" "-" target "${src}")
  add_custom_target(julia-copy-base-${target}
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${src}")
  add_dependencies(julia-copy-all-base julia-copy-base-${target})
endfunction()

set(core_img_SRCS
  coreimg.jl
  essentials.jl
  reflection.jl
  options.jl
  promotion.jl
  tuple.jl
  range.jl
  expr.jl
  error.jl
  bool.jl
  number.jl
  int.jl
  operators.jl
  pointer.jl
  abstractarray.jl
  array.jl
  hashing.jl
  nofloat_hashing.jl
  functors.jl
  reduce.jl
  intset.jl
  dict.jl
  iterator.jl
  inference.jl)

# Not including duplicated ones in coreimg
set(sys_img_SRCS
  Dates.jl
  Enums.jl
  LineEdit.jl
  REPL.jl
  REPLCompletions.jl
  Terminals.jl
  abstractarraymath.jl
  arraymath.jl
  ascii.jl
  base.jl
  base64.jl
  basedocs.jl
  bitarray.jl
  boot.jl
  broadcast.jl
  c.jl
  cartesian.jl
  char.jl
  client.jl
  collections.jl
  combinatorics.jl
  complex.jl
  constants.jl
  dSFMT.jl
  datafmt.jl
  dates/accessors.jl
  dates/adjusters.jl
  dates/arithmetic.jl
  dates/conversions.jl
  dates/io.jl
  dates/periods.jl
  dates/query.jl
  dates/ranges.jl
  dates/types.jl
  deepcopy.jl
  deprecated.jl
  docs.jl
  dsp.jl
  emoji_symbols.jl
  env.jl
  errno.jl
  exports.jl
  fastmath.jl
  fftw.jl
  file.jl
  float.jl
  float16.jl
  floatfuncs.jl
  fs.jl
  gmp.jl
  grisu.jl
  grisu/bignum.jl
  grisu/bignums.jl
  grisu/fastfixed.jl
  grisu/fastprecision.jl
  grisu/fastshortest.jl
  grisu/float.jl
  hashing2.jl
  help.jl
  i18n.jl
  interactiveutil.jl
  intfuncs.jl
  io.jl
  iobuffer.jl
  iostream.jl
  latex_symbols.jl
  libc.jl
  libdl.jl
  linalg.jl
  linalg/arnoldi.jl
  linalg/arpack.jl
  linalg/bidiag.jl
  linalg/bitarray.jl
  linalg/blas.jl
  linalg/bunchkaufman.jl
  linalg/cholesky.jl
  linalg/dense.jl
  linalg/diagonal.jl
  linalg/eigen.jl
  linalg/exceptions.jl
  linalg/factorization.jl
  linalg/generic.jl
  linalg/givens.jl
  linalg/lapack.jl
  linalg/ldlt.jl
  linalg/lu.jl
  linalg/matmul.jl
  linalg/qr.jl
  linalg/rectfullpacked.jl
  linalg/schur.jl
  linalg/special.jl
  linalg/svd.jl
  linalg/symmetric.jl
  linalg/triangular.jl
  linalg/tridiag.jl
  linalg/uniformscaling.jl
  loading.jl
  lock.jl
  managers.jl
  markdown/Common/Common.jl
  markdown/Common/block.jl
  markdown/Common/inline.jl
  markdown/GitHub/GitHub.jl
  markdown/GitHub/table.jl
  markdown/IPython/IPython.jl
  markdown/Julia/Julia.jl
  markdown/Julia/interp.jl
  markdown/Markdown.jl
  markdown/parse/config.jl
  markdown/parse/parse.jl
  markdown/parse/util.jl
  markdown/render/html.jl
  markdown/render/latex.jl
  markdown/render/plain.jl
  markdown/render/rich.jl
  markdown/render/terminal/formatting.jl
  markdown/render/terminal/render.jl
  math.jl
  meta.jl
  methodshow.jl
  mmap.jl
  mpfr.jl
  multi.jl
  multidimensional.jl
  multimedia.jl
  nullable.jl
  ordering.jl
  osutils.jl
  path.jl
  pcre.jl
  pkg.jl
  pkg/cache.jl
  pkg/dir.jl
  pkg/entry.jl
  pkg/generate.jl
  pkg/git.jl
  pkg/github.jl
  pkg/query.jl
  pkg/read.jl
  pkg/reqs.jl
  pkg/resolve.jl
  pkg/resolve/fieldvalue.jl
  pkg/resolve/interface.jl
  pkg/resolve/maxsum.jl
  pkg/resolve/versionweight.jl
  pkg/types.jl
  pkg/write.jl
  poll.jl
  precompile.jl
  primes.jl
  printf.jl
  process.jl
  profile.jl
  quadgk.jl
  random.jl
  rational.jl
  reducedim.jl
  refpointer.jl
  regex.jl
  replutil.jl
  rounding.jl
  serialize.jl
  set.jl
  sharedarray.jl
  show.jl
  simdloop.jl
  socket.jl
  sort.jl
  sparse.jl
  sparse/abstractsparse.jl
  sparse/cholmod.jl
  sparse/cholmod_h.jl
  sparse/csparse.jl
  sparse/linalg.jl
  sparse/sparsematrix.jl
  sparse/spqr.jl
  sparse/umfpack.jl
  sparse/umfpack_h.jl
  special/bessel.jl
  special/erf.jl
  special/gamma.jl
  special/log.jl
  special/trig.jl
  stat.jl
  statistics.jl
  stream.jl
  string.jl
  subarray.jl
  sysimg.jl
  sysinfo.jl
  task.jl
  test.jl
  utf16.jl
  utf32.jl
  utf8.jl
  utf8proc.jl
  utferror.jl
  utftypes.jl
  util.jl
  version.jl)

foreach(jl_file ${core_img_SRCS} ${sys_img_SRCS})
  copy_jl(${jl_file})
endforeach()

# JULIA_CPU_TARGET

add_custom_command(OUTPUT "${build_private_libdir}/inference0.o"
  COMMAND "${build_bindir}/julia" -C native
  --build "${build_private_libdir}/inference0" coreimg.jl
  WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
  DEPENDS ${core_img_SRCS})

add_custom_target(julia-inference0 ALL
  DEPENDS "${build_private_libdir}/inference0.o"
  julia-ui  julia-copy-all-base)
