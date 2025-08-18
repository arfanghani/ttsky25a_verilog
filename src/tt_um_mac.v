// SPDX-FileCopyrightText: © 2024 Tiny Tapeout
// SPDX-License-Identifier: Apache-2.0
`default_nettype none

module tt_um_mac (
    input  wire [7:0] ui_in,   // 8 user inputs
    output reg  [7:0] uo_out,  // 8 user outputs
    input  wire [7:0] uio_in,  // bidir in
    output wire [7:0] uio_out, // unused
    output wire [7:0] uio_oe,  // unused
    input  wire       ena,     // enable
    input  wire       clk,     // clock
    input  wire       rst_n    // reset
);

    // Use only lower 2 bits of ui_in and uio_in
    wire [1:0] a = ui_in[1:0];
    wire [1:0] b = uio_in[1:0];
    wire [3:0] prod;

    assign prod = a * b;

    assign uio_out = 8'b0; // not used
    assign uio_oe  = 8'b0; // not used

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uo_out <= 8'b0;
        else if (ena)
            uo_out <= {4'b0, prod}; // lower 4 bits show result
    end

endmodule
