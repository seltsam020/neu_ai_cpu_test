`timescale 1ns / 1ps
module mul_plus(
    input clk,
    input start_i,
    input mul_sign,  
    input [31:0] opdata1_i,
    input [31:0] opdata2_i,
    output [63:0] result_o,
    output        ready_o
    );

    reg judge;
    reg [31:0] multiplier;
    wire [63:0] temporary_value;
    reg [63:0] mul_temporary;
    reg result_sign;
    
    always @(posedge clk) begin
        if (!start_i || ready_o) begin
            judge <= 1'b0;
        end
        else begin
            judge <= 1'b1;
        end
    end

    wire op1_sign;
    wire op2_sign;
    wire [31:0] op1_absolute;
    wire [31:0] op2_absolute;
    assign op1_sign = mul_sign & opdata1_i[31];
    assign op2_sign = mul_sign & opdata2_i[31];
    assign op1_absolute = op1_sign ? (~opdata1_i+1) : opdata1_i;
    assign op2_absolute = op2_sign ? (~opdata2_i+1) : opdata2_i;

    reg  [63:0] multiplicand;
    always @ (posedge clk) begin //±»³ËÊý
        if (judge) begin
            multiplicand <= {multiplicand[62:0],1'b0};
        end
        else if (start_i) begin
            multiplicand <= {32'd0,op1_absolute};
        end
    end
    
    always @ (posedge clk) begin //³ËÊý
        if(judge) begin
            multiplier <= {1'b0,multiplier[31:1]};
        end
        else if(start_i) begin
            multiplier <= op2_absolute;
        end
    end
    assign temporary_value = multiplier[0] ? multiplicand : 64'd0;
    
    always @ (posedge clk) begin
        if (judge) begin
            mul_temporary <= mul_temporary + temporary_value;
        end      
        else if (start_i) begin
            mul_temporary <= 64'd0;
        end
     end
     
    always @ (posedge clk) begin
        if (judge) begin
              result_sign <= op1_sign ^ op2_sign;
        end
    end 

    assign result_o = result_sign ? (~mul_temporary+1) : mul_temporary;
    assign ready_o  = judge & multiplier == 32'b0;
endmodule
