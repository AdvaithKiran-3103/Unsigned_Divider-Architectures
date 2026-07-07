 /* ****** This module implements unsigned division 
           Ain/Bin using Restoring Division Algorithm ***** */
`timescale 1ns/1ps
`define WIDTH 10

module Unsigned_Restoring_Divider(
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
    logic [`WIDTH:0]   B;
    logic [`WIDTH:0]   P;
    logic [$clog2(`WIDTH+1)-1:0] count;
    logic [`WIDTH:0] PA, diff;
    typedef enum logic {IDLE, DIVIDE} state_t;
    state_t state;

    assign PA = {P[`WIDTH-1:0], A[`WIDTH-1]};
    assign diff = PA - B;  // diff[WIDTH] = 1 indicates A < B
                           // borrow occurred
    always_ff @(posedge clk) begin
        if(rst) begin
            {busy, out_valid} <= 0;
        end else begin
            busy      <= (inp_valid || (state == DIVIDE));
            out_valid <= (state == DIVIDE && count == `WIDTH);
        end
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            state <= IDLE;
            {A, B, Q, R, P} <= 0;
            count <= 0;
        end else begin
            case(state)
                IDLE: begin
                    if(inp_valid) begin
                        A <= Ain;
                        B <= {1'b0, Bin};
                        {P, Q, R} <= 0;
                        count <= 0;
                        state <= DIVIDE;
                    end
                end  
                DIVIDE: begin
                    if(count == `WIDTH) begin
                        state <= IDLE;
                        Q <= A;
                        R <= P[`WIDTH-1:0];
                    end else begin
                        P <= diff[`WIDTH]? PA : diff;
                        A <= diff[`WIDTH]? {A[`WIDTH-2:0], 1'b0} 
                                         : {A[`WIDTH-2:0], 1'b1};
                        count <= count+1;    
                    end
                end
            endcase
        end
    end
endmodule