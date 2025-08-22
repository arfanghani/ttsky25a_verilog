`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // Dump signals for viewing with GTKWave
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // Declare signals
  reg clk;
  reg rst_n;
  reg ena;
  wire [7:0] ui_in;
  wire [7:0] uio_in;
  reg [7:0] ui_in_reg;
  reg [7:0] uio_in_reg;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // Instantiate the DUT
  tt_um_mac user_project (
`ifdef GL_TEST
    .VPWR(1'b1),
    .VGND(1'b0),
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

  // Assign regs to wires
  assign ui_in = ui_in_reg;
  assign uio_in = uio_in_reg;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10ns period = 100MHz
  end

  // Stimulus
  initial begin
    ena = 1;
    rst_n = 0;
    ui_in_reg = 8'b00000000;
    uio_in_reg = 8'b00000000;
    #10;
    rst_n = 1;

    // A=0, B=0, Cin=0 => Sum=0, Cout=0
    ui_in_reg = 8'b00000000;
    #10;

    // A=1, B=0, Cin=0 => Sum=1, Cout=0
    ui_in_reg = 8'b00000001;
    #10;

    // A=1, B=1, Cin=0 => Sum=0, Cout=1
    ui_in_reg = 8'b00000011;
    #10;

    // A=1, B=1, Cin=1 => Sum=1, Cout=1
    ui_in_reg = 8'b00000111;
    #10;

    // A=0, B=1, Cin=1 => Sum=0, Cout=1
    ui_in_reg = 8'b00000110;
    #10;

    $stop;
  end

  // Monitor output
  initial begin
    $monitor("Time=%0t | A=%b, B=%b, Cin=%b | Sum=%b, Cout=%b | uo_out=%b",
             $time,
             ui_in[0], ui_in[1], ui_in[2],
             uo_out[0], uo_out[1],
             uo_out);
  end

endmodule
