# PRETTY PRINTS
define print_cc
	$(if $(Q), @echo "[CC]        $(1)")
endef

define print_bin
	$(if $(Q), @echo "[BIN]       $(1)")
endef

define print_rm
    $(if $(Q), @echo "[RM]        $(1)")
endef

define print
    $(if $(Q), @echo "$(1)")
endef

# LINUX SHELL
MV    := mv
RM    := rm -rf
CP    := cp 2>/dev/null
AR    := ar rcs
WC    := wc
BC    := bc
GREP  := grep -q
AWK   := awk
MKDIR := mkdir -p

# OTHER PROGRAMS
VALGRIND_MEMCHECK := valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --trace-children=yes --error-exitcode=1
VALGRIND_CACHE := valgrind --tool=cachegrind --branch-sim=yes

TEST_COV := gcov
TEST_COV_HTML := gcovr -r . --html --html-details
GPROF := gprof

CLANG_TIDY := clang-tidy --quiet
CLANG_TIDY_CHECKS := -checks=bugprone-*,clang-analyzer-*,cert-*,concurrency-*,misc-*,modernize-*,performance-*,readability-* --warnings-as-errors=*

# DIRS
SDIR := ./src
IDIR := ./include ./libs/c-logger/include/ ./libs/criterion/usr/local/include/
ADIR := ./app
TDIR := ./tests
LDIR := ./libs/c-logger/lib/ ./libs/criterion/usr/local/lib/x86_64-linux-gnu
TUDIR := $(TDIR)/unit
TMDIR := $(TDIR)/mocks
TCDIR := $(TDIR)/component
SCRIPT_DIR := ./scripts

# FILES
SRC := $(wildcard $(SDIR)/*.c)
ASRC := $(SRC) $(wildcard $(ADIR)/*.c)
TUSRC := $(SRC) $(wildcard $(TUDIR)/*.c)
TCSRC := $(SRC) $(wildcard $(TCDIR)/*.c)
TMSRC := $(wildcard $(TMDIR)/*.c)

SOBJ := $(SRC:%.c=%.o)
AOBJ := $(ASRC:%.c=%.o)
TUOBJ := $(TUSRC:%.c=%.o)
TCOBJ := $(TCSRC:%.c=%.o)
TMOBJ := $(TMSRC:%.c=%.o)

GCOV_OBJ := $(SOBJ:%.o=%.gcda) $(AOBJ:%.o=%.gcda) $(TUOBJ:%.o=%.gcda) $(TCOBJ:%.o=%.gcda) \
			$(SOBJ:%.o=%.gcno) $(AOBJ:%.o=%.gcno) $(TUOBJ:%.o=%.gcno) $(TCOBJ:%.o=%.gcno)

DEPS := $(SOBJ:%.o=%.d) $(AOBJ:%.o=%.d) $(TUOBJ:%.o=%.d) $(TCOBJ:%.o=%.d) $(TMOBJ:%.o=%.d)

AEXEC := ./main.out
TUEXEC := ./unit_tests.out
TCEXEC := ./component_tests.out

TU_COV_REPORT := ./unit_tests_coverage.html
TC_COV_REPORT := ./component_tests_coverage.html

GPROF_BIN := ./gmon.out
TU_GPROF_REPORT := ./unit_tests_gprof_report.txt
TC_GPROF_REPORT := ./component_tests_gprof_report.txt

TU_CACHE_BIN := ./unit_tests_cache_bin.out
TC_CACHE_BIN := ./component_tests_cache_bin.out

TU_CACHE_LOG := ./unit_tests_cache_log.txt
TC_CACHE_LOG := ./component_tests_cache_log.txt

# COMPI, DEFAULT GCC
CC ?= gcc

C_STD   := -std=c99
C_OPT   := -O3
C_FLAGS :=
C_WARNS :=

DEP_FLAGS := -MMD -MP
LINKER_FLAGS := $(foreach d, $(LDIR), -Wl,-R$d) -fPIC

I_INC := $(foreach d, $(IDIR), -I$d)
L_INC := $(foreach d, $(LDIR), -L$d)
SLIBS := -llogger
TLIBS := $(SLIBS) -lcriterion
ALIBS := $(SLIBS)

ifeq ($(CC),clang)
	C_WARNS +=  -Weverything -Wno-padded -Wno-gnu-zero-variadic-macro-arguments -Wno-newline-eof -Wno-reserved-id-macro \
				-Wno-missing-variable-declarations
else ifneq (, $(filter $(CC), cc gcc))
	C_WARNS += -Wall -Wextra -pedantic -Wcast-align \
			   -Winit-self -Wlogical-op -Wmissing-include-dirs \
			   -Wredundant-decls -Wshadow -Wstrict-overflow=5 -Wundef  \
			   -Wwrite-strings -Wpointer-arith -Wmissing-declarations \
			   -Wuninitialized -Wno-old-style-definition -Wno-old-style-declaration -Wstrict-prototypes \
			   -Wmissing-prototypes -Wswitch-default -Wbad-function-cast \
			   -Wnested-externs -Wconversion -Wunreachable-code
endif

ifeq ("$(origin DEBUG)", "command line")
	GGDB := -ggdb3 -gdwarf-4
	C_OPT := -O0
else
	GGDB :=
endif

C_FLAGS += $(C_STD) $(C_OPT) $(GGDB) $(C_WARNS) $(DEP_FLAGS)

# ARGS (Quiet OR Verbose), type make V=1 to enable verbose mode
ifeq ("$(origin V)", "command line")
	Q :=
else
	Q ?= @
endif

all:
	$(Q)$(MAKE) app --no-print-directory

.PHONY: app
app: $(AOBJ)
	$(call print_bin,$(AEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(AOBJ) -o $(AEXEC) $(ALIBS)

.PHONY: test
test:
	$(Q)$(MAKE) unit_tests --no-print-directory
	$(Q)$(MAKE) component_tests --no-print-directory
	$(Q)$(MAKE) mock_tests --no-print-directory

.PHONY: run_tests
run_tests:
	$(Q)$(MAKE) test --no-print-directory
	$(TUEXEC)
	$(TCEXEC)
	$(Q)$(MAKE) mock_tests_run --no-print-directory

.PHONY: test_coverage
test_coverage:
	$(Q)$(MAKE) unit_tests_coverage --no-print-directory
	$(Q)$(MAKE) component_tests_coverage --no-print-directory

.PHONY: static_analyze
static_analyze:
	$(Q)$(MAKE) clean --no-print-directory
	$(Q)$(MAKE) xanalyze --no-print-directory
	$(Q)$(MAKE) clang_tidy --no-print-directory

.PHONY: memcheck
memcheck:
	$(Q)$(MAKE) test --no-print-directory
	$(Q)$(VALGRIND_MEMCHECK) $(TUEXEC)
	$(Q)$(VALGRIND_MEMCHECK) $(TCEXEC)
	$(Q)$(MAKE) mock_tests_memcheck --no-print-directory

.PHONY: code_profiling
code_profiling:
	$(Q)$(MAKE) unit_tests_code_profiling_gprof --no-print-directory
	$(Q)$(MAKE) component_tests_code_profiling_gprof --no-print-directory
	$(Q)$(MAKE) clean --no-print-directory
	$(Q)$(MAKE) cache_report --no-print-directory

.PHONY: cache_report
cache_report:
	$(Q)$(MAKE) test --no-print-directory
	$(Q)$(VALGRIND_CACHE) --log-file=$(TU_CACHE_LOG) --cachegrind-out-file=$(TU_CACHE_BIN) $(TUEXEC)
	$(Q)$(VALGRIND_CACHE) --log-file=$(TC_CACHE_LOG) --cachegrind-out-file=$(TC_CACHE_BIN) $(TCEXEC)

.PHONY: regression
regression:
	$(call print,Regression has been started:)
	$(call print,cleaning:)
	$(Q)$(MAKE) clean --no-print-directory
	$(call print,building app:)
	$(Q)$(MAKE) app --no-print-directory
	$(call print,cleaning:)
	$(Q)$(MAKE) clean --no-print-directory
	$(call print,building tests:)
	$(Q)$(MAKE) test --no-print-directory
	$(call print,analyzing code:)
	$(Q)$(MAKE) static_analyze --no-print-directory
	$(call print,running tests:)
	$(Q)$(MAKE) test --no-print-directory
	$(Q)$(TUEXEC)
	$(Q)$(TCEXEC)
	$(call print,running memcheck:)
	$(Q)$(MAKE) memcheck --no-print-directory
	$(call print,cleaning:)
	$(Q)$(MAKE) clean --no-print-directory
	$(call print,checking test coverage:)
	$(Q)$(MAKE) test_coverage --no-print-directory
	$(call print,Regression PASSED)


.PHONY: unit_tests
unit_tests: I_INC += -I$(SDIR)
unit_tests: LINKER_FLAGS += -Wl,-allow-multiple-definition
unit_tests: $(TUOBJ)
	$(call print_bin,$(TUEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TUOBJ) -o $(TUEXEC) $(TLIBS)

.PHONY: component_tests
component_tests: $(TCOBJ)
	$(call print_bin,$(TCEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TCOBJ) -o $(TCEXEC) $(TLIBS)

######################################

# MOCK: 1 LINE = 1 TEST
.PHONY: mock_tests
mock_tests: I_INC += -I$(SDIR)
mock_tests: $(TMOBJ)
	$(call print_bin,./mock_tests_foo.out)
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TMDIR)/test_foo.o -o ./mock_tests_foo.out $(TLIBS)

.PHONY: mock_tests_run
mock_tests_run:
	./mock_tests_foo.out

.PHONY: mock_tests_memcheck
mock_tests_memcheck:
	$(Q)$(VALGRIND_MEMCHECK) ./mock_tests_foo.out

######################################

.PHONY: unit_tests_coverage
unit_tests_coverage: CC = gcc
unit_tests_coverage: C_FLAGS = -O0 -ggdb3 -fprofile-arcs -ftest-coverage $(C_STD)
unit_tests_coverage: I_INC += -I$(SDIR)
unit_tests_coverage: LINKER_FLAGS += -Wl,-allow-multiple-definition
unit_tests_coverage: $(TUOBJ)
	$(call print_bin,$(TUEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TUOBJ) -o $(TUEXEC) $(TLIBS)
	$(call print,"Executing tests")
	$(Q)$(TUEXEC)
	$(Q)$(TEST_COV_HTML) -o $(TU_COV_REPORT)
	$(Q)$(RM) $(GCOV_OBJ)


.PHONY: component_tests_coverage
component_tests_coverage: CC = gcc
component_tests_coverage: C_FLAGS = -O0 -ggdb3 -fprofile-arcs -ftest-coverage $(C_STD)
component_tests_coverage: $(TCOBJ)
	$(call print_bin,$(TCEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TCOBJ) -o $(TCEXEC) $(TLIBS)
	$(call print,"Executing tests")
	$(Q)$(TCEXEC)
	$(Q)$(TEST_COV_HTML) -o $(TC_COV_REPORT)
	$(Q)$(RM) $(GCOV_OBJ)


.PHONY: xanalyze
xanalyze: CC := clang --analyze -Xanalyzer -analyzer-output=text
xanalyze: I_INC += -I$(SDIR)
xanalyze: $(AOBJ) $(TUOBJ) $(TCOBJ)

.PHONY: unit_tests_code_profiling
unit_tests_code_profiling_gprof: CC = gcc
unit_tests_code_profiling_gprof: C_FLAGS = -O0 -ggdb3 -pg $(C_STD)
unit_tests_code_profiling_gprof: I_INC += -I$(SDIR)
unit_tests_code_profiling_gprof: LINKER_FLAGS += -Wl,-allow-multiple-definition
unit_tests_code_profiling_gprof: $(TUOBJ)
	$(call print_bin,$(TUEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TUOBJ) -o $(TUEXEC) $(TLIBS)
	$(call print,"Executing tests")
	$(Q)$(TUEXEC)
# $(Q)$(GPROF) $(TUEXEC) $(GPROF_BIN) > $(TU_GPROF_REPORT)
# $(Q)$(RM) $(GPROF_BIN)

.PHONY: component_tests_code_profiling
component_tests_code_profiling_gprof: CC = gcc
component_tests_code_profiling_gprof: C_FLAGS = -O0 -ggdb3 -pg $(C_STD)
component_tests_code_profiling_gprof: $(TCOBJ)
	$(call print_bin,$(TCEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TCOBJ) -o $(TCEXEC) $(TLIBS)
	$(call print,"Executing tests")
	$(Q)$(TCEXEC)
# $(Q)$(GPROF) $(TUEXEC) $(GPROF_BIN) > $(TC_GPROF_REPORT)
# $(Q)$(RM) $(GPROF_BIN)

.PHONY:clang_tidy
clang_tidy:
	$(CLANG_TIDY) $(CLANG_TIDY_CHECKS) $(ASRC) -- $(I_INC)

.PHONY: clean
clean:
	$(call print_rm,EXEC)
	$(Q)$(RM) $(AEXEC) $(TUEXEC) $(TCEXEC) ./mock_tests*
	$(call print_rm,OBJ)
	$(Q)$(RM) $(AOBJ) $(TUOBJ) $(TCOBJ) $(TMOBJ) $(GCOV_OBJ)
	$(call print_rm,DEPS)
	$(Q)$(RM) $(DEPS)
	$(call print_rm,REPORTS)
	$(Q)$(RM) $(TC_COV_REPORT) $(TU_COV_REPORT) *.html sandbox-gmon* $(GPROF_BIN) \
	          $(TC_CACHE_BIN) $(TC_CACHE_LOG) $(TU_CACHE_BIN) $(TU_CACHE_LOG) $(TC_GPROF_REPORT) $(TU_GPROF_REPORT)

.PHONY: help
help:
	@echo "Makefile"
	@echo -e
	@echo "Targets:"
	@echo "    all               - alias for make app"
	@echo "    app               - build only app"
	@echo "    test              - build only tests"
	@echo "    run_tests         - build and runa all tests"
	@echo "    regression        - build and run all regression tests"
	@echo "    memcheck          - build tests and run them using valgrind"
	@echo "    static_analyze    - analyze all source files (tests included)"
	@echo "    test_coverage     - create html report about test coverage"
	@echo -e
	@echo "Makefile supports Verbose mode when V=1 (make all V=1)"
	@echo "Makefile supports Debug mode when DEBUG=1 (make all DEBUG=1)"
	@echo "To change default compiler (gcc) change CC variable (i.e export CC=clang)"


%.o: %.c %.d
	$(call print_cc,$<)
	$(Q)$(CC) $(C_FLAGS) $(I_INC) -c $< -o $@

$(DEPS):

include $(wildcard $(DEPS))

# Does not work because of criterion
# valgrind --tool=callgrind --cache-sim=yes --branch-sim=yes --simulate-wb=yes --simulate-hwpref=yes --cacheuse=yes ./component_tests.out