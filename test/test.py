import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_full_adder(dut):
    dut._log.info("Starting full adder test")

    # Start clock (100 MHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Initialize inputs
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0

    # Reset
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 1)

    # Test cases: (A, B, Cin, expected_sum, expected_cout)
    test_cases = [
        (0, 0, 0, 0, 0),
        (1, 0, 0, 1, 0),
        (1, 1, 0, 0, 1),
        (1, 1, 1, 1, 1),
        (0, 1, 1, 0, 1),
        (0, 0, 1, 1, 0),
        (0, 1, 0, 1, 0),
        (1, 0, 1, 0, 1),
    ]

    for A, B, Cin, expected_sum, expected_cout in test_cases:
        # Pack inputs: ui_in[0] = A, ui_in[1] = B, ui_in[2] = Cin
        dut.ui_in.value = (Cin << 2) | (B << 1) | A

        await ClockCycles(dut.clk, 1)  # Wait for output to stabilize

        # Extract outputs: assuming uo_out[0] = Sum, uo_out[1] = Cout
        sum_out = int(dut.uo_out.value) & 0b1
        cout_out = (int(dut.uo_out.value) >> 1) & 0b1

        dut._log.info(f"A={A}, B={B}, Cin={Cin} -> Sum={sum_out}, Cout={cout_out}")

        assert sum_out == expected_sum, f"Sum mismatch: expected {expected_sum}, got {sum_out}"
        assert cout_out == expected_cout, f"Cout mismatch: expected {expected_cout}, got {cout_out}"

    dut._log.info("Full adder tests passed!")

