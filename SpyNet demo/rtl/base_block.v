`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/06/2019 02:56:00 PM
// Design Name:
// Module Name: base_block
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


module base_block #(parameter BITS = 16, parameter KERNEL = 7, parameter FEATURES = 12, parameter OVERHEAD_BITS = 12) (
    input clk,
    input [KERNEL*BITS-1:0] filters,
    input [FEATURES*BITS-1:0] features,
    input [(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] biases,
    output [(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums
    );

    wire [2*(FEATURES-KERNEL+1)*KERNEL*BITS-1:0] temp_results_wire;
   // reg  [2*(FEATURES-KERNEL+1)*KERNEL*BITS-1:0] temp_results_reg;

    wire [(FEATURES-KERNEL+1)*(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))-1:0] add1_wire;
   // reg [(FEATURES-KERNEL+1)*(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))-1:0] add1_reg;

    wire [(FEATURES-KERNEL+1)*((2*BITS+2)+(2*BITS+OVERHEAD_BITS))-1:0] add2_wire;
   // reg [(FEATURES-KERNEL+1)*((2*BITS+2)+(2*BITS+OVERHEAD_BITS))-1:0] add2_reg;

    wire [(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] results_wire;
   // reg  [(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] results_reg;

    // Multiplications
    genvar ii;
    genvar jj;
    generate
        for (ii=0; ii<KERNEL; ii=ii+1)
        begin
            for (jj=ii; jj<ii+FEATURES-KERNEL+1; jj=jj+1)
            begin
                mult_gen_0 mul (
                    .CLK(clk),
                    .A(filters[(ii+1)*BITS-1:ii*BITS]),
                    .B(features[(jj+1)*BITS-1:jj*BITS]),
                    .P(temp_results_wire[2*(ii*(FEATURES-KERNEL)+jj+1)*BITS-1:2*(ii*(FEATURES-KERNEL)+jj)*BITS])
                );
            end
        end
    endgenerate

    // Adders layer 1
    genvar kk;
    genvar ll;
    generate
        for (ll=0; ll<FEATURES-KERNEL+1; ll=ll+1)
        begin
            for (kk=0; kk <3; kk=kk+1)
            begin
                 c_addsub_0 add (
                    .A(temp_results_wire[2*((2+2*kk)*(FEATURES-KERNEL+1)+ll+1)*BITS-1:2*((2+2*kk)*(FEATURES-KERNEL+1)+ll)*BITS]),
                    .B(temp_results_wire[2*((1+2*kk)*(FEATURES-KERNEL+1)+ll+1)*BITS-1:2*((1+2*kk)*(FEATURES-KERNEL+1)+ll)*BITS]),
                    .CLK(clk),
                    .S(add1_wire[(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*ll+(kk+1)*(2*BITS+1)-1:(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*ll+kk*(2*BITS+1)])
                 );
            end
            c_addsub_1 add1 (
                .A(temp_results_wire[2*(ll+1)*BITS-1:2*ll*BITS]),      // input wire [31 : 0] A
                .B(biases[(2*BITS+OVERHEAD_BITS)*(ll+1)-1:(2*BITS+OVERHEAD_BITS)*ll]), // input wire [43 : 0] B
                .CLK(clk),  // input wire CLK
                .S(add1_wire[(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*(ll+1)-1:(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*(ll+1)-(2*BITS+OVERHEAD_BITS)]) // output wire [43 : 0] S
            );
        end
    endgenerate

    // Adders layer 2
    genvar mm;
    generate
        for (mm=0; mm<FEATURES-KERNEL+1; mm=mm+1)
        begin
            c_addsub_2 add2 (
                .A(add1_wire[(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*mm+2*BITS:(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*mm]), // input wire [32 : 0] A
                .B(add1_wire[(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*mm+4*BITS+1:(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*mm+2*BITS+1]), // input wire [32 : 0] B
                .CLK(clk),  // input wire CLK
                .S(add2_wire[(2*BITS+2+2*BITS+OVERHEAD_BITS)*mm+2*BITS+1:(2*BITS+2+2*BITS+OVERHEAD_BITS)*mm]) // output wire [33 : 0] S
            );
            c_addsub_3 add3 (
                .A(add1_wire[(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*mm+6*BITS+2:(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*mm+4*BITS+2]), // input wire [32 : 0] A
                .B(add1_wire[(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*(mm+1)-1:(3*(2*BITS+1)+(2*BITS+OVERHEAD_BITS))*(mm+1)-(2*BITS+OVERHEAD_BITS)]), // input wire [43 : 0] B
                .CLK(clk),  // input wire CLK
                .S(add2_wire[(2*BITS+2+2*BITS+OVERHEAD_BITS)*(mm+1)-1:(2*BITS+2+2*BITS+OVERHEAD_BITS)*(mm+1)-(2*BITS+OVERHEAD_BITS)]) // output wire [43 : 0] S
            );
        end
    endgenerate

    // Adders layer 3
    genvar nn;
    generate
        for (nn=0; nn<FEATURES-KERNEL+1; nn=nn+1)
        begin
            c_addsub_4 add4 (
                .A(add2_wire[(2*BITS+2+2*BITS+OVERHEAD_BITS)*nn+2*BITS+1:(2*BITS+2+2*BITS+OVERHEAD_BITS)*nn]), // input wire [33 : 0] A
                .B(add2_wire[(2*BITS+2+2*BITS+OVERHEAD_BITS)*(nn+1)-1:(2*BITS+2+2*BITS+OVERHEAD_BITS)*(nn+1)-(2*BITS+OVERHEAD_BITS)]), // input wire [43 : 0] B
                .CLK(clk),  // input wire CLK
                .S(sums[(2*BITS+OVERHEAD_BITS)*(nn+1)-1:(2*BITS+OVERHEAD_BITS)*nn]) // output wire [43 : 0] S
            );
        end
    endgenerate




    always @(posedge clk)
    begin
        //temp_results_reg <= temp_results_wire;
       // add1_reg <= add1_wire;
        //add2_reg <= add2_wire;
       // results_reg <= results_wire;
    end

    //assign sums = results_reg; 
endmodule
