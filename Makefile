SHELL := /bin/bash

# Check for sanity to avoid later confusion

ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

# Generate C++ in executable form
VERILATOR_FLAGS += --binary -j 0
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -x-assign fast
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
# VERILATOR_FLAGS += --assert
# Generate coverage analysis
# VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt

# Input files for Verilator
SRC_FILES= -y ./src
TEST_PATH = ./test/$(TOP)_tb.sv
VERILATOR_INPUT = $(TEST_PATH) $(SRC_FILES)

VERILATOR_IGNORE +=  -Wno-UNUSEDSIGNAL -Wno-WIDTHTRUNC -Wno-UNUSEDPARAM

default: run

run:
	# VERILATOR_FLAGS += --binary -j 0
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_IGNORE) -DBEHAV_SIM=1 $(VERILATOR_INPUT)
	./obj_dir/V$(TOP)_tb +trace
	gtkwave dumpfile.vcd

# Other targets
lint:
	# VERILATOR_FLAGS += "--lint-only"
	$(VERILATOR) $(VERILATOR_FLAGS)

show-config:
	$(VERILATOR) -V

clean:
	-rm -rf obj_dir logs *.log *.dmp *.vcd coverage.dat core
	clear
