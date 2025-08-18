`default_nettype none
`timescale 1ns / 1ps

module tb;
    reg clk;
    reg rst_n;
    reg ena;
    reg  [7:0] ui_in_reg;
    reg  [7:0] uio_in_reg;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    // Instantiate DUT
    tt_um_mac dut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in_reg),
        .uio_in(uio_in_reg),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // VCD dump for GTKWave
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
        #1;
    end

    // Test stimulus
    initial begin
        rst_n = 0; ena = 1;
        ui_in_reg = 0; uio_in_reg = 0;
        #10; rst_n = 1;

        ui_in_reg = 8'b00000011; uio_in_reg = 8'b00000010; #20;
        ui_in_reg = 8'b00000001; uio_in_reg = 8'b00000100; #20;
        ui_in_reg = 8'b00000101; uio_in_reg = 8'b00000011; #20;
        ui_in_reg = 8'b00000111; uio_in_reg = 8'b00000010; #20;
        ui_in_reg = 8'b00000000; uio_in_reg = 8'b00000000; #20;
        ui_in_reg = 8'b00000001; uio_in_reg = 8'b00000001; #20;

        $stop;
    end

    // Optional monitor
    initial begin
        $monitor("Time=%0d | ui_in=%b uio_in=%b | uo_out=%b", 
                 $time, ui_in_reg, uio_in_reg, uo_out);
    end
endmodule
