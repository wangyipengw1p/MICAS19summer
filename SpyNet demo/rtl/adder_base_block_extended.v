`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2019 07:19:59 PM
// Design Name: 
// Module Name: adder_base_block_extended
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


module adder_base_block_extended #(parameter BITS = 16, parameter OVERHEAD_BITS = 12, parameter NB_BASE_BLOCKS = 8, parameter FEATURES = 21, parameter KERNEL = 7)(
    input clk,
    input [NB_BASE_BLOCKS*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums7,
    output [4*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] results
    );
    
    //wire [4*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] mid_results;
    
    genvar aa;
    for (aa=0; aa<(FEATURES-KERNEL+1); aa=aa+1)
    begin
        c_addsub_5 addA (
            .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+7*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+7*(FEATURES-KERNEL+1))]), 
            .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+6*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+6*(FEATURES-KERNEL+1))]), 
            .CLK(clk),  
            .S(results[(2*BITS+OVERHEAD_BITS)*(aa+1+3*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+3*(FEATURES-KERNEL+1))]) 
        );
        c_addsub_5 addB (
            .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+5*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+5*(FEATURES-KERNEL+1))]), 
            .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+4*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+4*(FEATURES-KERNEL+1))]), 
            .CLK(clk),  
            .S(results[(2*BITS+OVERHEAD_BITS)*(aa+1+2*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+2*(FEATURES-KERNEL+1))]) 
        );
        c_addsub_5 addC (
            .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+3*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+3*(FEATURES-KERNEL+1))]), 
            .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+2*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+2*(FEATURES-KERNEL+1))]), 
            .CLK(clk),  
            .S(results[(2*BITS+OVERHEAD_BITS)*(aa+1+(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+(FEATURES-KERNEL+1))]) 
        );
        c_addsub_5 addD (
            .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+(FEATURES-KERNEL+1))]), 
            .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            .CLK(clk),  
            .S(results[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
        );
        //c_addsub_5 addE (
        //    .A(mid_results[(2*BITS+OVERHEAD_BITS)*(aa+1+3*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+3*(FEATURES-KERNEL+1))]), 
        //    .B(mid_results[(2*BITS+OVERHEAD_BITS)*(aa+1+2*(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+2*(FEATURES-KERNEL+1))]), 
        //    .CLK(clk),  
        //    .S(results[(2*BITS+OVERHEAD_BITS)*(aa+1+(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+(FEATURES-KERNEL+1))]) 
        //);
        //c_addsub_5 addF (
        //    .A(mid_results[(2*BITS+OVERHEAD_BITS)*(aa+1+(FEATURES-KERNEL+1))-1:(2*BITS+OVERHEAD_BITS)*(aa+(FEATURES-KERNEL+1))]), 
        //    .B(mid_results[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
        //    .CLK(clk),  
        //    .S(results[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
        //);
    end
endmodule
