`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump signals for waveform viewing with GTKWave
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
  end

  // Declare signals
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

  // Gate-level power pins
`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // Instantiate the DUT (Device Under Test)
  tt_um_mac user_project (
`ifdef GL_TEST
    .VPWR(VPWR),
    .VGND(VGND),
`endif
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(uio_in),
    .uio_out(uio_out),
    .uio_oe(uio_oe),
    .ena(ena),
    .clk(clk),
    .rst_n(rst_n)
  );

  // Drive wires from regs
  assign ui_in   = ui_in_reg;
  assign uio_in  = uio_in_reg;

  // Clock generation (100 MHz)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Test stimulus
  initial begin
    rst_n = 0;
    ena = 1;
    ui_in_reg = 8'b00000000;
    uio_in_reg = 8'b00000000;
    #10;
    rst_n = 1;

    // Apply input combinations: [2]=Cin, [1]=B, [0]=A
    ui_in_reg = 8'b00000000;  // A=0, B=0, Cin=0 => Sum=0, Cout=0
    #20;
    ui_in_reg = 8'b00000001;  // A=1, B=0, Cin=0 => Sum=1, Cout=0
    #20;
    ui_in_reg = 8'b00000011;  // A=1, B=1, Cin=0 => Sum=0, Cout=1
    #20;
    ui_in_reg = 8'b00000111;  // A=1, B=1, Cin=1 => Sum=1, Cout=1
    #20;
    ui_in_reg = 8'b00000110;  // A=0, B=1, Cin=1 => Sum=0, Cout=1
    #20;
    ui_in_reg = 8'b00000100;  // A=0, B=0, Cin=1 => Sum=1, Cout=0
    #20;
    ui_in_reg = 8'b00000010;  // A=0, B=1, Cin=0 => Sum=1, Cout=0
    #20;
    ui_in_reg = 8'b00000101;  // A=1, B=0, Cin=1 => Sum=0, Cout=1
    #20;

    #10;
    $stop;
  end

  // Output monitoring
  initial begin
    $monitor("Time=%0t | ui_in=%08b | uo_out=%08b", $time, ui_in, uo_out);
  end

endmodule
