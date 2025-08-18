# SPDX-FileCopyrightText: © 2025
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# Helper to pack fields like the tb does: ui_in = {OP[2:0], A[3:0]}
def ui_word(op, a):
    return ((op & 0x7) << 5) | (a & 0xF)

def uio_word(b):
    return (b & 0xF)  # lower 4 bits used; upper 4 ignored

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start ALU test")

    # 10 us period like your original test (100 kHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value   = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 4)
    dut.rst_n.value = 1

    # Pipeline latency = 2 cycles after changing inputs
    LAT = 2

    # ADD: 3 + 2 = 5
    dut.ui_in.value  = ui_word(0b000, 3)
    dut.uio_in.value = uio_word(2)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 5

    # MUL: 4 * 3 = 12
    dut.ui_in.value  = ui_word(0b101, 4)
    dut.uio_in.value = uio_word(3)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 12

    # SUB: 9 - 3 = 6
    dut.ui_in.value  = ui_word(0b001, 9)
    dut.uio_in.value = uio_word(3)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 6

    # XOR: 5 ^ 10 = 15
    dut.ui_in.value  = ui_word(0b100, 5)
    dut.uio_in.value = uio_word(10)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 15

    # SHL1: 7 << 1 = 14 (B ignored)
    dut.ui_in.value  = ui_word(0b110, 7)
    dut.uio_in.value = uio_word(0)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 14

    # CMP: (8 >= 12) -> 0, then (12 >= 8) -> 1
    dut.ui_in.value  = ui_word(0b111, 8)
    dut.uio_in.value = uio_word(12)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 0

    dut.ui_in.value  = ui_word(0b111, 12)
    dut.uio_in.value = uio_word(8)
    await ClockCycles(dut.clk, LAT)
    assert int(dut.uo_out.value) == 1

    dut._log.info("All ALU tests passed")
