# Makefile
# For simulating the tt_um_mac full adder using Cocotb
# Docs: https://docs.cocotb.org/en/stable/quickstart.html

# Simulator & language settings
SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Source directory and design files
SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = tt_um_mac.v

# Simulation mode
ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD        = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))
COMPILE_ARGS    += -I$(SRC_DIR)

else

# Gate-level simulation:
SIM_BUILD        = sim_build/gl
COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1

# Sky130 library files
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v

# Your gate-level netlist
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Testbench and top-level module
VERILOG_SOURCES += $(PWD)/tb.v
TOPLEVEL = tb

# Python test script (test_project.py → MODULE = test)
MODULE = test

# Include cocotb build rules
include $(shell cocotb-config --makefiles)/Makefile.sim
