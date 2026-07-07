`timescale 1ns / 1ps
`define WIDTH 10

module Unsigned_Pipeline_Restoring_Divider(
    input  logic clk, 
    input  logic rst,
    input  logic inp_valid,                  
    input  logic [`WIDTH-1:0] Ain,    // Ain = Dividend  
    input  logic [`WIDTH-1:0] Bin,    // Bin = Divisor  
    output logic [`WIDTH-1:0] Q,      // Q = Quotient = floor(Ain/Bin)
    output logic [`WIDTH-1:0] R,      // R = Remainder = Ain%Bin     
    output logic out_valid            
    );
    
    logic [`WIDTH-1:0] A[`WIDTH-1:0];
    logic [`WIDTH:0]   B[`WIDTH-1:0];
    logic [`WIDTH:0]   P[`WIDTH-1:0];
    logic [`WIDTH:0] PA[`WIDTH-1:0];
    logic [`WIDTH:0] diff[`WIDTH-1:0];
    logic data_valid[`WIDTH-1:0];
    
    assign Q = A[`WIDTH-1];
    assign R = P[`WIDTH-1][`WIDTH-1:0];
    assign out_valid = data_valid[`WIDTH-1];
    
    always_comb begin
        PA[0]   = {{`WIDTH{1'b0}}, Ain[`WIDTH-1]};
        diff[0] = PA[0] - {1'b0,Bin};
        for(int i=1; i<`WIDTH; i=i+1) begin
            PA[i]   = {P[i-1][`WIDTH-1:0], A[i-1][`WIDTH-1]};
            diff[i] = PA[i]- B[i-1]; 
        end
    end
    
    always_ff@(posedge clk) begin
        if(rst) begin
                for (int i=0; i<`WIDTH; i++) begin
                    P[i] <= 0;
                    A[i] <= 0;
                    B[i] <= 0;
                    data_valid[i] <= 0;
                end
        end else begin
            data_valid[0] <= inp_valid;
            if(inp_valid) begin
                P[0] <= diff[0][`WIDTH]? PA[0] : diff[0];
                A[0] <= diff[0][`WIDTH]? {Ain[`WIDTH-2:0], 1'b0}
                                       : {Ain[`WIDTH-2:0], 1'b1};  
                B[0] <= {1'b0, Bin};
            end
            
            for(int i=1; i<`WIDTH; i=i+1) begin
                data_valid[i] <= data_valid[i-1];
                if(data_valid[i-1]) begin
                    P[i] <= diff[i][`WIDTH]? PA[i] : diff[i];
                    A[i] <= diff[i][`WIDTH]? {A[i-1][`WIDTH-2:0], 1'b0}
                                           : {A[i-1][`WIDTH-2:0], 1'b1};
                    B[i] <= B[i-1]; 
                end 
            end
        end
    end 
endmodule
