 /* ****** This module implements unsigned division 
           Ain/Bin using repeated substraction ***** */
`timescale 1ns/1ps
`define WIDTH 10

module Unsigned_Subtractive_Divider(
    input  logic clk, 
    input  logic rst,
    input  logic inp_valid,                  
    input  logic [`WIDTH-1:0] Ain,    // Ain = Dividend  
    input  logic [`WIDTH-1:0] Bin,    // Bin = Divisor  
    output logic [`WIDTH-1:0] Q,      // Q = Quotient = floor(Ain/Bin)
    output logic [`WIDTH-1:0] R,      // R = Remainder = Ain%Bin     
    output logic busy,
    output logic out_valid            
    );
    
    logic [`WIDTH-1:0] A;
    logic [`WIDTH-1:0] B;
    logic [`WIDTH:0] diff;
    
    typedef enum logic {IDLE, DIVIDE} state_t;
    state_t state;
    
    assign diff = {1'b0, A} - {1'b0, B};  // diff[WIDTH] = 1 indicates A < B 
                                          // borrow occurred
    always_ff @(posedge clk) begin
        if(rst) begin
            busy      <= 0;
            out_valid <= 0;
        end else begin
            busy      <= (inp_valid || (state == DIVIDE));
            out_valid <= (state == DIVIDE && diff[`WIDTH]); 
        end 
    end
    
    always_ff @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            {A, B, Q, R} <= 0;
        end else begin
            case(state)
            IDLE: begin 
                if(inp_valid) begin
                    {A, B} <= {Ain, Bin};
                    {Q, R} <= 0;
                    state  <= DIVIDE;
                end
            end
            DIVIDE: begin 
                if(diff[`WIDTH]) begin
                    state <= IDLE;
                    R <= A;
                end else begin
                    Q <= Q + 1;
                    A <= diff;
                end
            end
            default: state <= IDLE;
            endcase
        end
    end    
endmodule