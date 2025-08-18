`default_nettype none
`timescale 1ns / 1ps

/* Simple testbench for GTKWave viewing.
   Drives ui_in/uio_in and monitors uo_out.
   Matches the two-cycle pipeline latency of tt_um_alu.
*/
module tb ();

  // Dump signals
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Wires and regs
  reg clk;
  reg rst_n;
  reg ena;
  wire [7:0] ui_in;
  wire [7:0] uio_in;
  reg  [7:0] ui_in_reg;
  reg  [7:0] uio_in_reg;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // DUT
  tt_um_alu user_project (
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  assign ui_in  = ui_in_reg;
  assign uio_in = uio_in_reg;

  // 10ns clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Stimulus helper
  task set_inputs(input [2:0] op, input [3:0] a, input [3:0] b);
    begin
      ui_in_reg  = {op, a};
      uio_in_reg = {4'b0000, b};
    end
  endtask

  // Drive sequence
  initial begin
    ena = 1'b1;
    rst_n = 1'b0;
    ui_in_reg  = 8'h00;
    uio_in_reg = 8'h00;
    #20;          // reset low for 2 cycles
    rst_n = 1'b1;

    // ADD: 3 + 2 = 5
    set_inputs(3'b000, 4'd3, 4'd2);
    #20; // 2 cycles latency
    // MUL: 4 * 3 = 12
    set_inputs(3'b101, 4'd4, 4'd3);
    #20;
    // SUB: 9 - 3 = 6
    set_inputs(3'b001, 4'd9, 4'd3);
    #20;
    // XOR: 5 ^ 10 = 15
    set_inputs(3'b100, 4'd5, 4'd10);
    #20;
    // SHL1: 7<<1 = 14 (B ignored)
    set_inputs(3'b110, 4'd7, 4'd0);
    #20;
    // CMP: (8>=12) ? 0 : 0 -> 0, then (12>=8)? 1 -> 1
    set_inputs(3'b111, 4'd8, 4'd12);
    #20;
    set_inputs(3'b111, 4'd12, 4'd8);
    #20;

    #10;
    $stop;
  end

  // Monitor
  initial begin
    $monitor("t=%0t ui_in=%b (OP=%b A=%0d) | uio_in=%b (B=%0d) | uo_out=%0d",
      $time, ui_in, ui_in[7:5], ui_in[3:0], uio_in, uio_in[3:0], uo_out);
  end

endmodule
