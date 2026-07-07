`timescale 1ns / 1ps
`define WIDTH 10

module testbench;
    logic clk;
    logic rst;
    logic inp_valid;
    logic [`WIDTH-1:0] Ain;
    logic [`WIDTH-1:0] Bin;
        
    logic [`WIDTH-1:0] Q;
    logic [`WIDTH-1:0] R;
    logic out_valid;
    
    Unsigned_Pipeline_Restoring_Divider DIV (.clk(clk), 
                                             .rst(rst), 
                                             .inp_valid(inp_valid), 
                                             .Ain(Ain), 
                                             .Bin(Bin), 
                                             .Q(Q),
                                             .R(R),
                                             .out_valid(out_valid)
                                     );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0; rst = 1; inp_valid = 0; 
        @(negedge clk); rst = 0;
        @(negedge clk); inp_valid = 1; Ain = 10'd101; Bin = 10'd2;
        @(negedge clk); inp_valid = 1; Ain = 10'd203; Bin = 10'd3;
        @(negedge clk); inp_valid = 1; Ain = 10'd303; Bin = 10'd4;
        @(negedge clk); inp_valid = 1; Ain = 10'd404; Bin = 10'd5;
        @(negedge clk); inp_valid = 1; Ain = 10'd505; Bin = 10'd6;
        @(negedge clk); inp_valid = 1; Ain = 10'd606; Bin = 10'd7;
        @(negedge clk); inp_valid = 1; Ain = 10'd707;  Bin = 10'd8;
        @(negedge clk); inp_valid = 1; Ain = 10'd808;  Bin = 10'd9;
        @(negedge clk); inp_valid = 1; Ain = 10'd909;  Bin = 10'd10;                            
        @(negedge clk); inp_valid = 0;
        @(negedge out_valid); #15 $finish;
    end
endmodule
