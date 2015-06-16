include $(JULIAHOME)/Make.inc

default: $(JULIA_BUILD_MODE) # contains either "debug" or "release"
all: debug release

# sort is used to remove potential duplicates

$(foreach link,base test,$(eval $(call symlink_target,$(link),$(build_datarootdir)/julia)))

# Build the HTML docs (skipped if already exists, notably in tarballs)
doc/_build/html:
	@$(MAKE) -C doc html

# doc needs to live under $(build_docdir), not under $(build_datarootdir)/julia/
$(subst $(abspath $(JULIAHOME))/,,$(abspath $(build_docdir))): $(build_docdir)
$(build_docdir):
	@mkdir -p $@/examples
	@cp -R examples/*.jl $@/examples/
	@cp -R examples/clustermanager $@/examples/

julia-symlink: julia-ui-$(JULIA_BUILD_MODE)
ifneq ($(OS),WINNT)
ifndef JULIA_VAGRANT_BUILD
	@ln -sf "$(shell contrib/relative_path.sh "$(JULIAHOME)" "$(JULIA_EXECUTABLE)")" julia
endif
endif

julia-base:
	@$(MAKE) $(QUIET_MAKE) -C base

julia-libccalltest:
	@$(MAKE) $(QUIET_MAKE) -C test libccalltest

julia-src-release julia-src-debug : julia-src-% :
	@$(MAKE) $(QUIET_MAKE) -C src libjulia-$*

julia-ui-release julia-ui-debug : julia-ui-% : julia-src-%
	@$(MAKE) $(QUIET_MAKE) -C ui julia-$*

julia-sysimg : julia-base julia-ui-$(JULIA_BUILD_MODE)
	@$(MAKE) $(QUIET_MAKE) $(build_private_libdir)/sys.$(SHLIB_EXT) JULIA_BUILD_MODE=$(JULIA_BUILD_MODE)

julia-debug julia-release : julia-% : julia-ui-% julia-symlink julia-sysimg julia-libccalltest

debug release : % : julia-%

check-whitespace:
ifneq ($(NO_GIT), 1)
	@contrib/check-whitespace.sh
else
	$(warn "Skipping whitespace check because git is unavailable")
endif

$(build_docdir)/helpdb.jl: doc/helpdb.jl
	@cp $< $@

.SECONDARY: $(build_private_libdir)/inference0.o
.SECONDARY: $(build_private_libdir)/inference.o
.SECONDARY: $(build_private_libdir)/sys.o

$(build_private_libdir)/%.$(SHLIB_EXT): $(build_private_libdir)/%.o
ifneq ($(USEMSVC), 1)
	@$(call PRINT_LINK, $(CXX) $(LDFLAGS) -shared -fPIC -L$(build_private_libdir) -L$(build_libdir) -L$(build_shlibdir) -o $@ $< \
		$$([ $(OS) = Darwin ] && echo '' -Wl,-undefined,dynamic_lookup || echo '' -Wl,--unresolved-symbols,ignore-all ) \
		$$([ $(OS) = WINNT ] && echo '' -ljulia -lssp))
	$(DSYMUTIL) $@
else
	@true
endif

CORE_SRCS := base/boot.jl base/coreimg.jl \
		base/abstractarray.jl \
		base/array.jl \
		base/bool.jl \
		base/dict.jl \
		base/error.jl \
		base/essentials.jl \
		base/expr.jl \
		base/functors.jl \
		base/hashing.jl \
		base/inference.jl \
		base/int.jl \
		base/intset.jl \
		base/iterator.jl \
		base/nofloat_hashing.jl \
		base/number.jl \
		base/operators.jl \
		base/options.jl \
		base/pointer.jl \
		base/promotion.jl \
		base/range.jl \
		base/reduce.jl \
		base/reflection.jl \
		base/tuple.jl

BASE_SRCS := $(wildcard base/*.jl base/*/*.jl base/*/*/*.jl)

$(build_private_libdir)/inference0.o: $(CORE_SRCS)
	@$(call PRINT_JULIA, cd base && \
	$(call spawn,$(JULIA_EXECUTABLE)) -C $(JULIA_CPU_TARGET) --build $(call cygpath_w,$(build_private_libdir)/inference0) -f \
		coreimg.jl)

$(build_private_libdir)/inference.o: $(build_private_libdir)/inference0.$(SHLIB_EXT)
	@$(call PRINT_JULIA, cd base && \
	$(call spawn,$(JULIA_EXECUTABLE)) -C $(JULIA_CPU_TARGET) --build $(call cygpath_w,$(build_private_libdir)/inference) -f \
		-J $(call cygpath_w,$(build_private_libdir)/inference0.ji) coreimg.jl)

COMMA:=,
$(build_private_libdir)/sys.o: VERSION $(BASE_SRCS) $(build_docdir)/helpdb.jl $(build_private_libdir)/inference.$(SHLIB_EXT)
	@$(call PRINT_JULIA, cd base && \
	$(call spawn,$(JULIA_EXECUTABLE)) -C $(JULIA_CPU_TARGET) --build $(call cygpath_w,$(build_private_libdir)/sys) -f \
		-J $(call cygpath_w,$(build_private_libdir)/inference.ji) sysimg.jl \
		|| { echo '*** This error is usually fixed by running `make clean`. If the error persists$(COMMA) try `make cleanall`. ***' && false; } )

$(build_bindir)/stringreplace: contrib/stringreplace.c
	@$(call PRINT_CC, $(CC) -o $(build_bindir)/stringreplace contrib/stringreplace.c)

.PHONY: default debug release check-whitespace release-candidate \
	julia-debug julia-release \
	julia-ui-release julia-ui-debug julia-src-release julia-src-debug \
	julia-symlink julia-base julia-sysimg \
	test testall testall1 test
