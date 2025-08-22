# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("Starting full adder test")

    # Clock setup
    clock = Clock(dut.clk, 10, units="ns")  # 100MHz
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # Define test cases: (A, B, Cin, expected_sum, expected_cout)
    cases = [
        (0, 0, 0, 0, 0),
        (1, 0, 0, 1, 0),
        (1, 1, 0, 0, 1),
        (1, 1, 1, 1, 1),
        (0, 1, 1, 0, 1),
        (0, 0, 1, 1, 0),
        (0, 1, 0, 1, 0),
        (1, 0, 1, 0, 1),
    ]

    for A, B, Cin, expected_sum, expected_cout in cases:
        dut.ui_in.value = (Cin << 2) | (B << 1) | A
        await ClockCycles(dut.clk, 1)

        actual_sum = int(dut.uo_out.value) & 0b1
        actual_cout = (int(dut.uo_out.value) >> 1) & 0b1

        dut._log.info(f"A={A}, B={B}, Cin={Cin} -> Sum={actual_sum}, Cout={actual_cout}")

        assert actual_sum == expected_sum, f"Sum mismatch: expected {expected_sum}, got {actual_sum}"
        assert actual_cout == expected_cout, f"Cout mismatch: expected {expected_cout}, got {actual_cout}"

    dut._log.info("Full adder tests passed")
