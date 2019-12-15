`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/14/2019 06:02:52 PM
// Design Name: 
// Module Name: base_block_extended_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module base_block_extended_top (
    input clk
    );

    wire [895:0]  filters;
    wire [895:0] features;
    wire [2463:0] biases;
    reg  [895:0]  filtersreg = {896{1'b0}};
    reg  [895:0] featuresreg = {896{1'b0}};
    reg  [2463:0] biasesreg = {2463{1'b0}};
    wire [895:0] sums1;
    wire [791:0] sums3;
    wire [483:0] sums5;
    wire [351:0] sums7;
    wire [263:0] sums9;
    wire [219:0] sums11;
    wire [175:0] sums13;
    reg  [9:0]   counter = 10'b0000000000;
    
    base_block_extended #(.BITS(16),.OVERHEAD_BITS(12),.OUTPUTS(1)) base_block_extended(
        .clk(clk),
        .filters(filters),
        .features(features),
        .biases(biases),
        .sums1(sums1),
        .sums3(sums3),
        .sums5(sums5),
        .sums7(sums7),
        .sums9(sums9),
        .sums11(sums11),
        .sums13(sums13)
        );
        
    always @(posedge clk)
    begin
        case(counter)
            10'b0000000000      :       counter <= 10'b0000000001;
            10'b0000000001      :       counter <= 10'b0000000010;
            10'b0000000010      :       counter <= 10'b0000000011;
            10'b0000000011      :       counter <= 10'b0000000100;
            10'b0000000100      :       counter <= 10'b0000000101;
            10'b0000000101      :       counter <= 10'b0000000110;
            10'b0000000110      :       counter <= 10'b0000000111;
            10'b0000000111      :       counter <= 10'b0000001000;
            10'b0000001000      :       counter <= 10'b0000001001;
            10'b0000001001      :       counter <= 10'b0000001010;
            10'b0000001010      :       counter <= 10'b0000001011;
            10'b0000001011      :       counter <= 10'b0000001100;
            10'b0000001100      :       counter <= 10'b0000001101;
            10'b0000001101      :       begin
                                        counter <= 10'b0000001110;
                                        end
            10'b0000001110      :       begin
                                        counter <= 10'b0000001111;
                                        
            
                                        end
            10'b0000001111      :       begin
                                        counter <= 10'b0000010000;
                                        filtersreg <= {{16'b0000000000000001},{16'b0000000000000010},{16'b0000000000000011},
                                        {16'b0000000000000100},{16'b0000000000000101},{16'b0000000000000110},{16'b0000000000000111},
                                        {16'b0000000000001000},{16'b0000000000001001},{16'b0000000000001010},{16'b0000000000001011},
                                        {16'b0000000000001100},{16'b0000000000001101},{16'b0000000000001110},{16'b0000000000001111},
                                        {16'b0000000000010000},{16'b0000000000010001},{16'b0000000000010010},{16'b0000000000010011},
                                        {16'b0000000000010100},{16'b0000000000010101},{16'b0000000000010110},{16'b0000000000010111},
                                        {16'b0000000000011000},{16'b0000000000011001},{16'b0000000000011010},{16'b0000000000011011},
                                        {16'b0000000000011100},{16'b0000000000011101},{16'b0000000000011110},{16'b0000000000011111},
                                        {16'b0000000000100000},{16'b0000000000100001},{16'b0000000000100010},{16'b0000000000100011},
                                        {16'b0000000000100100},{16'b0000000000100101},{16'b0000000000100110},{16'b0000000000100111},
                                        {16'b0000000000101000},{16'b0000000000101001},{16'b0000000000101010},{16'b0000000000101011},
                                        {16'b0000000000101100},{16'b0000000000101101},{16'b0000000000101110},{16'b0000000000101111},
                                        {16'b0000000000110000},{16'b0000000000110001},{16'b0000000000110010},{16'b0000000000110011},
                                        {16'b0000000000110100},{16'b0000000000110101},{16'b0000000000110110},{16'b0000000000110111},
                                        {16'b0000000000111000}};
                                        featuresreg <= {{16'b0000000000000001},{16'b0000000000000010},{16'b0000000000000011},
                                        {16'b0000000000000100},{16'b0000000000000101},{16'b0000000000000110},{16'b0000000000000111},
                                        {16'b0000000000001000},{16'b0000000000001001},{16'b0000000000001010},{16'b0000000000001011},
                                        {16'b0000000000001100},{16'b0000000000001101},{16'b0000000000001110},{16'b0000000000001111},
                                        {16'b0000000000010000},{16'b0000000000010001},{16'b0000000000010010},{16'b0000000000010011},
                                        {16'b0000000000010100},{16'b0000000000010101},{16'b0000000000010110},{16'b0000000000010111},
                                        {16'b0000000000011000},{16'b0000000000011001},{16'b0000000000011010},{16'b0000000000011011},
                                        {16'b0000000000011100},{16'b0000000000011101},{16'b0000000000011110},{16'b0000000000011111},
                                        {16'b0000000000100000},{16'b0000000000100001},{16'b0000000000100010},{16'b0000000000100011},
                                        {16'b0000000000100100},{16'b0000000000100101},{16'b0000000000100110},{16'b0000000000100111},
                                        {16'b0000000000101000},{16'b0000000000101001},{16'b0000000000101010},{16'b0000000000101011},
                                        {16'b0000000000101100},{16'b0000000000101101},{16'b0000000000101110},{16'b0000000000101111},
                                        {16'b0000000000110000},{16'b0000000000110001},{16'b0000000000110010},{16'b0000000000110011},
                                        {16'b0000000000110100},{16'b0000000000110101},{16'b0000000000110110},{16'b0000000000110111},
                                        {16'b0000000000111000}};
                                        
                                        end
            10'b0000010000      :       begin
                                        counter <= 10'b0000010001;
                                        filtersreg <= {56{16'b0000000000000000}};
                                        biasesreg <= {{44'b00000000000000000000000000000000000000111000},
                                        {44'b00000000000000000000000000000000000000110111},
                                        {44'b00000000000000000000000000000000000000110110},
                                        {44'b00000000000000000000000000000000000000110101},
                                        {44'b00000000000000000000000000000000000000110100},
                                        {44'b00000000000000000000000000000000000000110011},
                                        {44'b00000000000000000000000000000000000000110010},
                                        {44'b00000000000000000000000000000000000000110001},
                                        {44'b00000000000000000000000000000000000000110000},
                                        {44'b00000000000000000000000000000000000000101111},
                                        {44'b00000000000000000000000000000000000000101110},
                                        {44'b00000000000000000000000000000000000000101101},
                                        {44'b00000000000000000000000000000000000000101100},
                                        {44'b00000000000000000000000000000000000000101011},
                                        {44'b00000000000000000000000000000000000000101010},
                                        {44'b00000000000000000000000000000000000000101001},
                                        {44'b00000000000000000000000000000000000000101000},
                                        {44'b00000000000000000000000000000000000000100111},
                                        {44'b00000000000000000000000000000000000000100110},
                                        {44'b00000000000000000000000000000000000000100101},
                                        {44'b00000000000000000000000000000000000000100100},
                                        {44'b00000000000000000000000000000000000000100011},
                                        {44'b00000000000000000000000000000000000000100010},
                                        {44'b00000000000000000000000000000000000000100001},
                                        {44'b00000000000000000000000000000000000000100000},
                                        {44'b00000000000000000000000000000000000000011111},
                                        {44'b00000000000000000000000000000000000000011110},
                                        {44'b00000000000000000000000000000000000000011101},
                                        {44'b00000000000000000000000000000000000000011100},
                                        {44'b00000000000000000000000000000000000000011011},
                                        {44'b00000000000000000000000000000000000000011010},
                                        {44'b00000000000000000000000000000000000000011001},
                                        {44'b00000000000000000000000000000000000000011000},
                                        {44'b00000000000000000000000000000000000000010111},
                                        {44'b00000000000000000000000000000000000000010110},
                                        {44'b00000000000000000000000000000000000000010101},
                                        {44'b00000000000000000000000000000000000000010100},
                                        {44'b00000000000000000000000000000000000000010011},
                                        {44'b00000000000000000000000000000000000000010010},
                                        {44'b00000000000000000000000000000000000000010001},
                                        {44'b00000000000000000000000000000000000000010000},
                                        {44'b00000000000000000000000000000000000000001111},
                                        {44'b00000000000000000000000000000000000000001110},
                                        {44'b00000000000000000000000000000000000000001101},
                                        {44'b00000000000000000000000000000000000000001100},
                                        {44'b00000000000000000000000000000000000000001011},
                                        {44'b00000000000000000000000000000000000000001010},
                                        {44'b00000000000000000000000000000000000000001001},
                                        {44'b00000000000000000000000000000000000000001000},
                                        {44'b00000000000000000000000000000000000000000111},
                                        {44'b00000000000000000000000000000000000000000110},
                                        {44'b00000000000000000000000000000000000000000101},
                                        {44'b00000000000000000000000000000000000000000100},
                                        {44'b00000000000000000000000000000000000000000011},
                                        {44'b00000000000000000000000000000000000000000010},
                                        {44'b00000000000000000000000000000000000000000001}};
                                        end
            10'b0000010001      :       biasesreg <= {56{44'b00000000000000000000000000000000000000000000}};
            
        endcase
    
    end
    assign filters = filtersreg;
    assign features = featuresreg;
    assign biases = biasesreg;
        
endmodule
