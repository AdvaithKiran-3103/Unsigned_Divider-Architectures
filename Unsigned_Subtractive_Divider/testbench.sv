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
    logic busy;
        
    Unsigned_Subtractive_Divider DIV (.clk(clk), 
                                      .rst(rst), 
                                      .inp_valid(inp_valid), 
                                      .Ain(Ain), 
                                      .Bin(Bin), 
                                      .Q(Q),
                                      .R(R), 
                                      .busy(busy),
                                      .out_valid(out_valid)
                                     );
                                                
    always #5 clk = ~clk;
    initial begin
        clk = 0; rst = 1; inp_valid = 0; 
        @(negedge clk); rst = 0;
        @(negedge clk); inp_valid = 1; 
                        Ain = 10'd1021; Bin = 10'd50;
        @(negedge clk); inp_valid = 0;
        
        @(posedge out_valid); #20 $finish;
    end
endmodule
