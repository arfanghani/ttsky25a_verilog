# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    """Test 2x2 multiplier + accumulator behavior"""

    dut._log.info("Start")

    # Create a clock with 10us period
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)  # wait a few cycles for reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    dut._log.info("Test 2x2 multiplier behavior")

    # Test vectors: (A, B, expected product)
    test_vectors = [
        (0, 0, 0),
        (0, 1, 0),
        (1, 0, 0),
        (1, 1, 1),
        (2, 1, 2),
        (1, 2, 2),
        (2, 2, 4),
        (3, 1, 3),
        (1, 3, 3),
        (3, 2, 6),
        (2, 3, 6),
        (3, 3, 9),
    ]

    for a_val, b_val, expected in test_vectors:
        dut.ui_in.value = a_val
        dut.uio_in.value = b_val

        # Wait 2 clock cycles for registered output to settle
        await ClockCycles(dut.clk, 2)

        got = int(dut.uo_out.value)
        dut._log.info(f"A={a_val} B={b_val} | got={got} expected={expected}")

        assert got == expected, f"Multiplier failed: {a_val}*{b_val} got {got} expected {expected}"

    dut._log.info("All test vectors passed!")
