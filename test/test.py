# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


# Dictionary mapping opcode to operation description and expected function
ALU_OPS = {
    0b000: ("ADD", lambda a, b: (a + b) & 0xFF),
    0b001: ("SUB", lambda a, b: (a - b) & 0xFF),
    0b010: ("AND", lambda a, b: a & b),
    0b011: ("OR",  lambda a, b: a | b),
    0b100: ("XOR", lambda a, b: a ^ b),
    0b101: ("MUL", lambda a, b: (a * b) & 0xFF),
    0b110: ("SHL1", lambda a, b: (a << 1) & 0xFF),
    0b111: ("CMP", lambda a, b: 1 if a >= b else 0)
}


@cocotb.test()
async def test_alu(dut):
    """Test the pipelined 8-bit ALU."""

    dut._log.info("Starting ALU test")

    # Start clock: 10us period (100 kHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    # Test all opcodes with sample values
    test_cases = [
        (0b000, 3, 2),   # ADD
        (0b001, 9, 3),   # SUB
        (0b010, 4, 3),   # AND
        (0b011, 5, 10),  # OR
        (0b100, 5, 10),  # XOR
        (0b101, 4, 3),   # MUL
        (0b110, 7, 0),   # SHL1 (B unused)
        (0b111, 12, 8),  # CMP (A >= B)
        (0b111, 8, 12),  # CMP (A < B)
    ]

    for opcode, a, b in test_cases:
        # Combine opcode and operand A in ui_in
        dut.ui_in.value = (opcode << 5) | (a & 0x0F)
        dut.uio_in.value = b & 0x0F

        # Wait **2 clock cycles** for pipeline latency
        await ClockCycles(dut.clk, 2)

        # Expected output
        expected = ALU_OPS[opcode][1](a, b)

        dut._log.info(
            f"OP={ALU_OPS[opcode][0]} A={a} B={b} | uo_out={int(dut.uo_out.value)} expected={expected}"
        )

        # Assert output
        assert int(dut.uo_out.value) == expected, (
            f"ALU test failed: OP={ALU_OPS[opcode][0]} A={a} B={b} "
            f"got {int(dut.uo_out.value)} expected {expected}"
        )

    dut._log.info("ALU test completed successfully")
