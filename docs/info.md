<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

# Pipelined 8-bit ALU (4-bit operands)

## Credits
We gratefully acknowledge the Department of CSE. 

## How it works
The `tt_um_alu` module implements a **pipelined 8-bit ALU** for Tiny Tapeout projects. It uses 4-bit operands `A` and `B` with a 3-bit opcode to select operations. The ALU includes a **two-stage pipeline** for fast and stable output.

### Input and Output Ports
- **Inputs:**
  - `ui_in[7:5]` (3-bit opcode)
  - `ui_in[3:0]` (operand A)
  - `uio_in[3:0]` (operand B)
  - `clk` (1-bit clock)
  - `rst_n` (active-low reset)
  - `ena` (enable, always 1)
- **Outputs:**
  - `uo_out[7:0]` (ALU result)
  - `uio_oe[7:0]` (set to 0, inputs only)
  - `uio_out[7:0]` (not used)

## Supported Operations
| Opcode | Operation | Description |
|--------|-----------|-------------|
| 000    | ADD       | `{0,A} + {0,B}` |
| 001    | SUB       | `{0,A} - {0,B}` |
| 010    | AND       | `A & B` |
| 011    | OR        | `A | B` |
| 100    | XOR       | `A ^ B` |
| 101    | MUL       | `A * B` (4×4 → 8-bit) |
| 110    | SHL1      | `{0,A} << 1` |
| 111    | CMP       | `(A >= B) ? 1 : 0` |

## Internal Architecture
1. **Stage 1 (Combinational ALU):** Computes result according to opcode.
2. **Stage 2 (Pipeline Register):** Holds stage1 output for one clock cycle.
3. **Stage 3 (Output Register):** Final pipeline stage to drive `uo_out`.

`uio_in` is used only as operand B. Bidirectional pins are not driven (`uio_oe=0`).

## Reset Behavior
- When `rst_n` is low:
  - Pipeline registers are cleared to `0x00`
  - Output `uo_out` is `0x00`

## How to Test
Use the provided **Verilog testbench** (`tb.v`) or **cocotb Python test** (`test.py`).

### Example Test Scenarios (expected `uo_out` after 2 clock cycles)
| OP  | A  | B  | Result |
|-----|----|----|--------|
| 000 | 3  | 2  | 5      |
| 101 | 4  | 3  | 12     |
| 001 | 9  | 3  | 6      |
| 100 | 5  | 10 | 15     |
| 110 | 7  | –  | 14     |
| 111 | 8  | 12 | 0      |
| 111 | 12 | 8  | 1      |

### Monitoring Output
The testbench prints a trace of inputs and results:
```verilog
initial begin
    $monitor("Time=%0t | ui_in=%b (OP=%b A=%0d) | uio_in=%b (B=%0d) | uo_out=%0d",
        $time, ui_in, ui_in[7:5], ui_in[3:0], uio_in, uio_in[3:0], uo_out);
end


## How to test

Use the provided **Verilog testbench** (`tb.v`) or **cocotb Python test** (`test.py`).

### Example Test Scenarios (expected `uo_out` after 2 clock cycles)
| OP  | A  | B  | Result |
|-----|----|----|--------|
| 000 | 3  | 2  | 5      |
| 101 | 4  | 3  | 12     |
| 001 | 9  | 3  | 6      |
| 100 | 5  | 10 | 15     |
| 110 | 7  | –  | 14     |
| 111 | 8  | 12 | 0      |
| 111 | 12 | 8  | 1      |

### Monitoring Output
The testbench prints a trace of inputs and results:
```verilog
initial begin
    $monitor("Time=%0t | ui_in=%b (OP=%b A=%0d) | uio_in=%b (B=%0d) | uo_out=%0d",
        $time, ui_in, ui_in[7:5], ui_in[3:0], uio_in, uio_in[3:0], uo_out);
end

## External hardware

None
