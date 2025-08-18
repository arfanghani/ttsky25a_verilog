/*
 * Copyright (c) 2025
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`timescale 1ns / 1ps

// Pipelined 8-bit ALU using 4-bit operands.
// ui_in[3:0]  = A[3:0]
// uio_in[3:0] = B[3:0]
// ui_in[7:5]  = opcode:
//   000 ADD   : {0,A} + {0,B}
//   001 SUB   : {0,A} - {0,B}
//   010 AND   : A & B
//   011 OR    : A | B
//   100 XOR   : A ^ B
//   101 MUL   : A * B  (4x4 -> 8-bit)
//   110 SHL1  : ({0,A} << 1)
//   111 CMP   : (A >= B) ? 1 : 0
//
// Pipeline: 2 stages (stage1 combinational -> pipe -> Y)
//
// Notes for TinyTapeout:
// - uio_oe is 0 (inputs only); uio_out is 0.
// - 'ena' may be ignored but wired to suppress lint.
// - Active-low reset rst_n.

module tt_um_alu (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (0=input, 1=output)
    input  wire       ena,      // always 1 when powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Pin usage
    wire [3:0] A = ui_in[3:0];
    wire [3:0] B = uio_in[3:0];
    wire [2:0] OP = ui_in[7:5];

    // I/O config
    assign uio_oe  = 8'b0;   // all bidir pins used as inputs
    assign uio_out = 8'b0;   // not driving bidir pins

    // Unused warning suppressor
    wire _unused = &{ena};

    // Stage 1: combinational ALU
    reg [7:0] stage1;
    always @* begin
        case (OP)
            3'b000: stage1 = {4'b0000, A} + {4'b0000, B};        // ADD
            3'b001: stage1 = {4'b0000, A} - {4'b0000, B};        // SUB
            3'b010: stage1 = {4'b0000, (A & B)};                 // AND
            3'b011: stage1 = {4'b0000, (A | B)};                 // OR
            3'b100: stage1 = {4'b0000, (A ^ B)};                 // XOR
            3'b101: stage1 = A * B;                              // MUL 4x4 -> 8b
            3'b110: stage1 = ({4'b0000, A} << 1);                // SHL1
            default: stage1 = (A >= B) ? 8'd1 : 8'd0;            // CMP (111)
        endcase
    end

    // Stage 2: pipeline register
    reg [7:0] pipe;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) pipe <= 8'd0;
        else        pipe <= stage1;
    end

    // Stage 3: output register (second stage like your MAC design)
    reg [7:0] Y;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) Y <= 8'd0;
        else        Y <= pipe;
    end

    assign uo_out = Y;

endmodule
