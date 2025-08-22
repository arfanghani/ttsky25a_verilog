/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

module tt_um_mac(
    input  wire [7:0] ui_in,     // Dedicated inputs
    output wire [7:0] uo_out,    // Dedicated outputs
    input  wire [7:0] uio_in,    // IOs: Input path
    output wire [7:0] uio_out,   // IOs: Output path
    output wire [7:0] uio_oe,    // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,       // always 1 when the design is powered, so you can ignore it
    input  wire       clk,       // clock
    input  wire       rst_n      // reset_n - low to reset
);

    // Assign IO directions (not used)
    assign uio_oe  = 8'b0;
    assign uio_out = 8'b0;
    wire _unused = &{ena};

    // Full Adder inputs:
    // We'll use:
    // ui_in[0] = A
    // ui_in[1] = B
    // ui_in[2] = Cin
    wire A = ui_in[0];
    wire B = ui_in[1];
    wire Cin = ui_in[2];

    wire Sum, Cout;

    // Instantiate Full Adder
    full_adder fa (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Output format:
    // uo_out[0] = Sum
    // uo_out[1] = Cout
    assign uo_out = {6'b0, Cout, Sum};

endmodule

// Simple Full Adder Module
module full_adder (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire Sum,
    output wire Cout
);
    assign Sum  = A ^ B ^ Cin;
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
endmodule
