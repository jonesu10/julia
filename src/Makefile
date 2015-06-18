include $(JULIAHOME)/Make.inc

override CFLAGS += $(JCFLAGS)
override CXXFLAGS += $(JCXXFLAGS)
override CPPFLAGS += $(JCPPFLAGS)

BUILDDIR ?= .

SRCS = \
	jltypes gf ast builtins module codegen disasm debuginfo interpreter \
	alloc dlload sys init task array dump toplevel jl_uv jlapi profile llvm-simdloop simplevector

HEADERS = julia.h julia_internal.h options.h $(wildcard support/*.h) $(LIBUV_INC)/uv.h

FLAGS = \
	-D_GNU_SOURCE -Iflisp -Isupport -I$(CMAKE_BINARY_DIR)/src \
	-I$(call exec,$(LLVM_CONFIG) --includedir) \
	-I$(LIBUV_INC) -I$(build_includedir) -DLIBRARY_EXPORTS \
	-I$(BUILDDIR) -I$(JULIAHOME)/deps/valgrind
ifneq ($(USEMSVC), 1)
override FLAGS += -Wall -Wno-strict-aliasing -fno-omit-frame-pointer -fvisibility=hidden -fno-common
endif

# In LLVM < 3.4, --ldflags includes both options and libraries, so use it both before and after --libs
# In LLVM >= 3.4, --ldflags has only options, and --system-libs has the libraries.
LLVMLINK = $(call exec,$(LLVM_CONFIG) --ldflags) $(call exec,$(LLVM_CONFIG) --libs) $(call exec,$(LLVM_CONFIG) --ldflags) $(call exec,$(LLVM_CONFIG) --system-libs 2> /dev/null)
ifeq ($(USE_LLVM_SHLIB),1)
LLVMLINK = $(call exec,$(LLVM_CONFIG) --ldflags) -lLLVM-$(call exec,$(LLVM_CONFIG) --version)
override FLAGS += -DLLVM_SHLIB
endif

COMMON_LIBS = $(WHOLE_ARCHIVE) $(CMAKE_BINARY_DIR)/src/flisp/libflisp.a $(CMAKE_BINARY_DIR)/src/support/libsupport.a -L$(build_shlibdir) -L$(build_libdir) $(LIBUV) $(LIBUTF8PROC) $(NO_WHOLE_ARCHIVE) $(LLVMLINK) $(OSLIBS)

OBJS = $(SRCS:%=$(BUILDDIR)/%.o)
DOBJS = $(SRCS:%=$(BUILDDIR)/%.dbg.obj)
override DEBUGFLAGS += $(FLAGS)
override SHIPFLAGS += $(FLAGS)

SRCS += gc

override JCFLAGS += -DCOPY_STACKS

default: $(JULIA_BUILD_MODE) # contains either "debug" or "release"
all: debug release

release debug: %: libjulia-%

$(BUILDDIR):
	mkdir $(BUILDDIR)

$(BUILDDIR)/%.o: %.c $(HEADERS) | $(BUILDDIR)
	@$(call PRINT_CC, $(CC) $(CPPFLAGS) $(CFLAGS) $(SHIPFLAGS) $(DISABLE_ASSERTIONS) -c $< -o $@)
$(BUILDDIR)/%.dbg.obj: %.c $(HEADERS) | $(BUILDDIR)
	@$(call PRINT_CC, $(CC) $(CPPFLAGS) $(CFLAGS) $(DEBUGFLAGS) -c $< -o $@)
$(BUILDDIR)/%.o: %.cpp $(HEADERS) $(shell which $(LLVM_CONFIG)) | $(BUILDDIR)
	@$(call PRINT_CC, $(CXX) $(call exec,$(LLVM_CONFIG) --cxxflags) $(CPPFLAGS) $(CXXFLAGS) $(SHIPFLAGS) -c $< -o $@)
$(BUILDDIR)/%.dbg.obj: %.cpp $(HEADERS) $(shell which $(LLVM_CONFIG)) | $(BUILDDIR)
	@$(call PRINT_CC, $(CXX) $(call exec,$(LLVM_CONFIG) --cxxflags) $(CPPFLAGS) $(CXXFLAGS) $(DEBUGFLAGS) -c $< -o $@)

$(BUILDDIR)/ast.o $(BUILDDIR)/ast.dbg.obj: $(CMAKE_BINARY_DIR)/src/julia_flisp.boot.inc flisp/*.h
$(BUILDDIR)/codegen.o $(BUILDDIR)/codegen.dbg.obj: intrinsics.cpp cgutils.cpp ccall.cpp abi_*.cpp
$(BUILDDIR)/builtins.o $(BUILDDIR)/builtins.dbg.obj: table.c

ifneq ($(USEMSVC), 1)
CXXLD = $(CXX) -shared
ifeq ($(OS),WINNT)
CXXLD += -Wl,--out-implib,$(build_libdir)/$(notdir $@).a
endif
else
CXXLD = $(LD) -dll -export:jl_setjmp -export:jl_longjmp
endif

$(build_shlibdir)/libjulia-debug.$(SHLIB_EXT): julia.expmap $(DOBJS)
	@$(call PRINT_LINK, $(CXXLD) $(CXXFLAGS) $(CXXLDFLAGS) $(DEBUGFLAGS) $(DOBJS) $(RPATH_ORIGIN) -o $@ $(LDFLAGS) $(JLIBLDFLAGS) $(COMMON_LIBS))
	$(INSTALL_NAME_CMD)libjulia-debug.$(SHLIB_EXT) $@
	$(DSYMUTIL) $@
$(BUILDDIR)/libjulia-debug.a: julia.expmap $(DOBJS)
	rm -f $@
	@$(call PRINT_LINK, ar -rcs $@ $(DOBJS))
libjulia-debug: $(build_shlibdir)/libjulia-debug.$(SHLIB_EXT)

ifeq ($(SHLIB_EXT), so)
  SONAME = -Wl,-soname=libjulia.so
else
  SONAME =
endif

$(build_shlibdir)/libjulia.$(SHLIB_EXT): julia.expmap $(OBJS)
	@$(call PRINT_LINK, $(CXXLD) $(CXXFLAGS) $(CXXLDFLAGS) $(SHIPFLAGS) $(OBJS) $(RPATH_ORIGIN) -o $@ $(LDFLAGS) $(JLIBLDFLAGS) $(COMMON_LIBS) $(SONAME)) $(CXXLDFLAGS)
	$(INSTALL_NAME_CMD)libjulia.$(SHLIB_EXT) $@
	$(DSYMUTIL) $@
$(BUILDDIR)/libjulia.a: julia.expmap $(OBJS)
	rm -f $@
	@$(call PRINT_LINK, ar -rcs $@ $(OBJS))
libjulia-release: $(build_shlibdir)/libjulia.$(SHLIB_EXT)

.PHONY: debug release
