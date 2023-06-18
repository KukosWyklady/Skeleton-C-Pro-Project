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
VALGRIND := valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --error-exitcode=1

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

SOBJ := $(SRC:%.c=%.o)
AOBJ := $(ASRC:%.c=%.o)
TUOBJ := $(TUSRC:%.c=%.o)
TCOBJ := $(TCSRC:%.c=%.o)

DEPS := $(SOBJ:%.o=%.d) $(AOBJ:%.o=%.d) $(TUOBJ:%.o=%.d) $(TCOBJ:%.o=%.d)

AEXEC := ./main.out
TUEXEC := ./unit_tests.out
TCEXEC := ./component_tests.out

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

.PHONY: static_analyze
static_analyze:
	$(Q)$(MAKE) clean --no-print-directory
	$(Q)$(MAKE) xanalyze --no-print-directory

.PHONY: memcheck
memcheck:
	$(Q)$(MAKE) test --no-print-directory
	$(Q)$(VALGRIND) $(TUEXEC)

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
	$(call print,running memcheck:)
	$(Q)$(MAKE) memcheck --no-print-directory
	$(call print,Regression PASSED)


.PHONY: unit_tests
unit_tests: I_INC += -I$(SDIR)
unit_tests: LINKER_FLAGS += -Wl,-allow-multiple-definition
unit_tests: $(TUOBJ)
	$(call print_bin,$(TUEXEC))
	$(Q)$(CC) $(C_FLAGS) $(I_INC) $(L_INC) $(LINKER_FLAGS) $(TUOBJ) -o $(TUEXEC) $(TLIBS)


.PHONY: xanalyze
xanalyze: CC := clang --analyze -Xanalyzer -analyzer-output=text
xanalyze: I_INC += -I$(SDIR)
xanalyze: $(AOBJ) $(TUOBJ) $(TCOBJ)

.PHONY: clean
clean:
	$(call print_rm,EXEC)
	$(Q)$(RM) $(AEXEC) $(TUEXEC) $(TCEXEC)
	$(call print_rm,OBJ)
	$(Q)$(RM) $(AOBJ) $(TUOBJ) $(TCOBJ)
	$(call print_rm,DEPS)
	$(Q)$(RM) $(DEPS)

.PHONY: help
help:
	@echo "Makefile"
	@echo -e
	@echo "Targets:"
	@echo "    all               - alias for make app"
	@echo "    app               - build only app"
	@echo "    test              - build only tests"
	@echo "    regression        - build and run all tests"
	@echo "    memcheck          - build tests and run them using valgrind"
	@echo "    static_analyze    - analyze all source files (tests included)"
	@echo -e
	@echo "Makefile supports Verbose mode when V=1 (make all V=1)"
	@echo "Makefile supports Debug mode when DEBUG=1 (make all DEBUG=1)"
	@echo "To change default compiler (gcc) change CC variable (i.e export CC=clang)"


%.o: %.c %.d
	$(call print_cc,$<)
	$(Q)$(CC) $(C_FLAGS) $(I_INC) -c $< -o $@

$(DEPS):

include $(wildcard $(DEPS))
