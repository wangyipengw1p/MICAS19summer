`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/12/2019 04:47:59 PM
// Design Name: 
// Module Name: base_block_extended
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


module base_block_extended #(parameter BITS = 16, parameter OVERHEAD_BITS = 12, parameter OUTPUTS = 15)(
    input clk,
    input [56*BITS-1:0] filters,
    input [56*OUTPUTS*BITS-1:0] features,
    input [56*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] biases,
    output [56*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums1,
    output [18*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums3,
    output [11*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums5,
    output [8*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums7,
    output [6*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums9,
    output [5*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums11,
    output [4*OUTPUTS*(2*BITS+OVERHEAD_BITS)-1:0] sums13
    );
    
    wire [112*OUTPUTS*BITS-1:0]                         temp_results_wire;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb1and2;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb4and5;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb4and5reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb4and5delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb6and7;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb6and7reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb6and7delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb8and9;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb8and9reg;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb8and9reg2;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb8and9delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb11and12;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb13and14;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb15and16;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb17and18;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb19and20;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb19and20reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb19and20delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb21and22;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb23and24;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb25and26;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb27and28;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb29and30;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb32and33;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb32and33reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb32and33delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb34and35;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb34and35reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb34and35delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb36and37;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb36and37reg;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb36and37reg2;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb36and37delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb39and40;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb41and42;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb43and44;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb45and46;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb47and48;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb47and48reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb47and48delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb49and50;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb51and52;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb51and52reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb51and52delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb53and54;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb55and56;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb55and56reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb55and56delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb21and25;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb21and25reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb21and25delay;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb49and53;
    reg  [(2*BITS+1)*OUTPUTS-1:0]                       nb49and53reg;
    wire [(2*BITS+1)*OUTPUTS-1:0]                       nb49and53delay;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb4and5and6and7;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb11and12and13and14;
    reg  [(2*BITS+2)*OUTPUTS-1:0]                       nb11and12and13and14reg;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb11and12and13and14delay;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb15and16and17and18;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb21and22and23and24;
    reg  [(2*BITS+2)*OUTPUTS-1:0]                       nb21and22and23and24reg;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb21and22and23and24delay;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb25and26and27and28;
    reg  [(2*BITS+2)*OUTPUTS-1:0]                       nb25and26and27and28reg;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb25and26and27and28delay;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb32and33and34and35;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb39and40and41and42;
    reg  [(2*BITS+2)*OUTPUTS-1:0]                       nb39and40and41and42reg;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb39and40and41and42delay;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb43and44and45and46;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb49and50and51and52;
    reg  [(2*BITS+2)*OUTPUTS-1:0]                       nb49and50and51and52reg;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb49and50and51and52delay;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb53and54and55and56;
    reg  [(2*BITS+2)*OUTPUTS-1:0]                       nb53and54and55and56reg;
    wire [(2*BITS+2)*OUTPUTS-1:0]                       nb53and54and55and56delay;
    wire [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           sums1from15delay;
    reg  [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           sums1from15delayreg;
    wire [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           sums1from43delay;
    reg  [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           sums1from43delayreg;
    wire [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           nb8and9and10and15and16and17and18;
    wire [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           nb36and37and38and43and44and45and46;
    wire [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           nb19and20and21and22and23and24;
    wire [(2*BITS+OVERHEAD_BITS)*OUTPUTS-1:0]           nb47and48and49and51and52;
   
    
        genvar ii;
        genvar jj;
        generate
            for (ii=0; ii<56; ii=ii+1)
            begin
                for (jj=0; jj<OUTPUTS; jj=jj+1)
                begin
                    mult_gen_0 mul (
                        .CLK(clk),
                        .A(filters[(ii+1)*BITS-1:ii*BITS]),
                        .B(features[(OUTPUTS*ii+jj+1)*BITS-1:(OUTPUTS*ii+jj)*BITS]),
                        .P(temp_results_wire[2*(OUTPUTS*ii+jj+1)*BITS-1:2*(OUTPUTS*ii+jj)*BITS])
                    );
                end
            end
        endgenerate
        
        genvar aa;
        genvar bb;
        generate
        for (aa=0; aa<OUTPUTS; aa=aa+1)
        begin
            c_addsub_0 add (
               .A(temp_results_wire[(110*OUTPUTS+2*(aa+1))*BITS-1:(110*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(108*OUTPUTS+2*(aa+1))*BITS-1:(108*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb1and2[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add1 (
               .A(temp_results_wire[(104*OUTPUTS+2*(aa+1))*BITS-1:(104*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(102*OUTPUTS+2*(aa+1))*BITS-1:(102*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb4and5[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add2 (
               .A(temp_results_wire[(100*OUTPUTS+2*(aa+1))*BITS-1:(100*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(98*OUTPUTS+2*(aa+1))*BITS-1:(98*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb6and7[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add3 (
               .A(temp_results_wire[(96*OUTPUTS+2*(aa+1))*BITS-1:(96*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(94*OUTPUTS+2*(aa+1))*BITS-1:(94*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb8and9[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add4 (
               .A(temp_results_wire[(90*OUTPUTS+2*(aa+1))*BITS-1:(90*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(88*OUTPUTS+2*(aa+1))*BITS-1:(88*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb11and12[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add5 (
               .A(temp_results_wire[(86*OUTPUTS+2*(aa+1))*BITS-1:(86*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(84*OUTPUTS+2*(aa+1))*BITS-1:(84*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb13and14[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add6 (
               .A(temp_results_wire[(82*OUTPUTS+2*(aa+1))*BITS-1:(82*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(80*OUTPUTS+2*(aa+1))*BITS-1:(80*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb15and16[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add7 (
               .A(temp_results_wire[(78*OUTPUTS+2*(aa+1))*BITS-1:(78*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(76*OUTPUTS+2*(aa+1))*BITS-1:(76*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb17and18[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add9 (
               .A(temp_results_wire[(74*OUTPUTS+2*(aa+1))*BITS-1:(74*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(72*OUTPUTS+2*(aa+1))*BITS-1:(72*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb19and20[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add10 (
               .A(temp_results_wire[(70*OUTPUTS+2*(aa+1))*BITS-1:(70*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(68*OUTPUTS+2*(aa+1))*BITS-1:(68*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb21and22[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add11 (
               .A(temp_results_wire[(66*OUTPUTS+2*(aa+1))*BITS-1:(66*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(64*OUTPUTS+2*(aa+1))*BITS-1:(64*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb23and24[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add12 (
               .A(temp_results_wire[(62*OUTPUTS+2*(aa+1))*BITS-1:(62*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(60*OUTPUTS+2*(aa+1))*BITS-1:(60*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb25and26[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add13 (
               .A(temp_results_wire[(58*OUTPUTS+2*(aa+1))*BITS-1:(58*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(56*OUTPUTS+2*(aa+1))*BITS-1:(56*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb27and28[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add14 (
               .A(temp_results_wire[(54*OUTPUTS+2*(aa+1))*BITS-1:(54*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(52*OUTPUTS+2*(aa+1))*BITS-1:(52*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb29and30[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add15 (
               .A(temp_results_wire[(48*OUTPUTS+2*(aa+1))*BITS-1:(48*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(46*OUTPUTS+2*(aa+1))*BITS-1:(46*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb32and33[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add16 (
               .A(temp_results_wire[(44*OUTPUTS+2*(aa+1))*BITS-1:(44*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(42*OUTPUTS+2*(aa+1))*BITS-1:(42*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb34and35[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add17 (
               .A(temp_results_wire[(40*OUTPUTS+2*(aa+1))*BITS-1:(40*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(38*OUTPUTS+2*(aa+1))*BITS-1:(38*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb36and37[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add18 (
               .A(temp_results_wire[(34*OUTPUTS+2*(aa+1))*BITS-1:(34*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(32*OUTPUTS+2*(aa+1))*BITS-1:(32*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb39and40[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add19 (
               .A(temp_results_wire[(30*OUTPUTS+2*(aa+1))*BITS-1:(30*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(28*OUTPUTS+2*(aa+1))*BITS-1:(28*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb41and42[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add20 (
               .A(temp_results_wire[(26*OUTPUTS+2*(aa+1))*BITS-1:(26*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(24*OUTPUTS+2*(aa+1))*BITS-1:(24*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb43and44[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add21 (
               .A(temp_results_wire[(22*OUTPUTS+2*(aa+1))*BITS-1:(22*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(20*OUTPUTS+2*(aa+1))*BITS-1:(20*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb45and46[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add22 (
               .A(temp_results_wire[(18*OUTPUTS+2*(aa+1))*BITS-1:(18*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(16*OUTPUTS+2*(aa+1))*BITS-1:(16*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb47and48[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add23 (
               .A(temp_results_wire[(14*OUTPUTS+2*(aa+1))*BITS-1:(14*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(12*OUTPUTS+2*(aa+1))*BITS-1:(12*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb49and50[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add24 (
               .A(temp_results_wire[(10*OUTPUTS+2*(aa+1))*BITS-1:(10*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(8*OUTPUTS+2*(aa+1))*BITS-1:(8*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb51and52[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add25 (
               .A(temp_results_wire[(6*OUTPUTS+2*(aa+1))*BITS-1:(6*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(4*OUTPUTS+2*(aa+1))*BITS-1:(4*OUTPUTS+2*aa)*BITS]),
               .CLK(clk),
               .S(nb53and54[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            c_addsub_0 add26 (
               .A(temp_results_wire[(2*OUTPUTS+2*(aa+1))*BITS-1:(2*OUTPUTS+2*aa)*BITS]),
               .B(temp_results_wire[(2*(aa+1))*BITS-1:(2*aa)*BITS]),
               .CLK(clk),
               .S(nb55and56[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            );
            //for (bb=0; bb<56; bb=bb+1)
            //begin
            //c_addsub_1 add27 (
            //   .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
            //   .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
            //   .CLK(clk),
            //   .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            //);
            //end
            for (bb=6; bb<8; bb=bb+1)
            begin
            c_addsub_1 add27 (
               .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
               .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
               .CLK(clk),
               .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            );
            end
            for (bb=18; bb<19; bb=bb+1)
            begin
            c_addsub_1 add27 (
               .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
               .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
               .CLK(clk),
               .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            );
            end
            for (bb=25; bb<26; bb=bb+1)
            begin
            c_addsub_1 add27 (
               .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
               .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
               .CLK(clk),
               .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            );
            end
            for (bb=34; bb<36; bb=bb+1)
            begin
            c_addsub_1 add27 (
               .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
               .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
               .CLK(clk),
               .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            );
            end
            for (bb=46; bb<47; bb=bb+1)
            begin
            c_addsub_1 add27 (
               .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
               .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
               .CLK(clk),
               .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            );
            end
            for (bb=53; bb<54; bb=bb+1)
            begin
            c_addsub_1 add27 (
               .A(temp_results_wire[(2*bb*OUTPUTS+2*(aa+1))*BITS-1:(2*bb*OUTPUTS+2*aa)*BITS]),
               .B(biases[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)]),
               .CLK(clk),
               .S(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+bb*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+bb*OUTPUTS)])
            );
            end
            c_addsub_3 add28 (
                .A(nb1and2[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+53*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+53*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+17*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+17*OUTPUTS)]) 
            );
            //c_addsub_3 add29 (
            //    .A(nb4and5[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+42*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+42*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+16*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+16*OUTPUTS)]) 
            //);
            //c_addsub_3 add30 (
            //    .A(nb6and7[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+41*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+41*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+15*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+15*OUTPUTS)]) 
            //);
            c_addsub_3 add31 (
                .A(nb8and9[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+46*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+46*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+14*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+14*OUTPUTS)]) 
            );
            //c_addsub_3 add32 (
            //    .A(nb11and12[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+43*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+43*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+13*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+13*OUTPUTS)]) 
            //);
            //c_addsub_3 add33 (
            //    .A(nb17and18[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+40*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+40*OUTPUTS)]), 
            //    .CLK(clk),  
            //   .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+12*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+12*OUTPUTS)]) 
            //);
            c_addsub_3 add34 (
                .A(nb19and20[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+35*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+35*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+11*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+11*OUTPUTS)]) 
            );
            c_addsub_3 add35 (
                .A(nb23and24[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+34*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+34*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+10*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+10*OUTPUTS)]) 
            );
            //c_addsub_3 add36 (
            //    .A(nb27and28[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+30*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+30*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+9*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+9*OUTPUTS)]) 
            //);
            c_addsub_3 add39 (
                .A(nb29and30[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+25*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+25*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+8*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+8*OUTPUTS)]) 
            );
            //c_addsub_3 add40 (
            //    .A(nb32and33[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+14*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+14*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]) 
            //);
            //c_addsub_3 add41 (
            //    .A(nb34and35[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+13*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+13*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+6*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+6*OUTPUTS)]) 
            //);
            c_addsub_3 add42 (
                .A(nb36and37[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+18*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+18*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]) 
            );
            //c_addsub_3 add43 (
            //    .A(nb39and40[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+15*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+15*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+4*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+4*OUTPUTS)]) 
            //);
            //c_addsub_3 add44 (
            //    .A(nb45and46[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+12*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+12*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]) 
            //);
            c_addsub_3 add45 (
                .A(nb47and48[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]) 
            );
            c_addsub_3 add46 (
                .A(nb51and52[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+6*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+6*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]) 
            );
            //c_addsub_3 add47 (
            //    .A(nb55and56[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums1[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*(aa)]) 
            //);
            //c_addsub_3 add48 (
            //    .A(nb4and5delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+17*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+17*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+10*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+10*OUTPUTS)]) 
            //);
            //c_addsub_3 add49 (
            //    .A(nb6and7delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+14*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+14*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+9*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+9*OUTPUTS)]) 
            //);
            c_addsub_2 add50 (
                .A(nb11and12[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb13and14[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb11and12and13and14[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            //c_addsub_4 add51 (
            //    .A(nb11and12and13and14[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums1from15delay[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+8*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+8*OUTPUTS)]) 
            //);
            //c_addsub_3 add52 (
            //    .A(nb19and20delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+12*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+12*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]) 
            //);
            //c_addsub_0 add53 (
            //   .A(temp_results_wire[(70*OUTPUTS+2*(aa+1))*BITS-1:(70*OUTPUTS+2*aa)*BITS]),
            //   .B(temp_results_wire[(62*OUTPUTS+2*(aa+1))*BITS-1:(62*OUTPUTS+2*aa)*BITS]),
            //   .CLK(clk),
            //   .S(nb21and25[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            //);
            //c_addsub_3 add54 (
            //    .A(nb21and25delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+10*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+10*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+6*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+6*OUTPUTS)]) 
            //);
            //c_addsub_3 add55 (
            //    .A(nb32and33delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+8*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+8*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+4*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+4*OUTPUTS)]) 
            //);
            //c_addsub_3 add56 (
            //    .A(nb34and35delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]) 
            //);
            c_addsub_2 add57 (
                .A(nb39and40[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb41and42[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb39and40and41and42[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            //c_addsub_4 add58 (
            //    .A(nb39and40and41and42[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums1from43delay[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]) 
            //);
            //c_addsub_3 add59 (
            //    .A(nb47and48delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]) 
            //);
            //c_addsub_0 add60 (
            //   .A(temp_results_wire[(14*OUTPUTS+2*(aa+1))*BITS-1:(14*OUTPUTS+2*aa)*BITS]),
            //   .B(temp_results_wire[(6*OUTPUTS+2*(aa+1))*BITS-1:(6*OUTPUTS+2*aa)*BITS]),
            //   .CLK(clk),
            //   .S(nb49and53[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa])
            //);
            //c_addsub_3 add61 (
            //    .A(nb49and53delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*(aa)]) 
            //);
            //c_addsub_3 add62 (
            //    .A(nb55and56delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+9*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+9*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]) 
            //);
            c_addsub_2 add63 (
                .A(nb4and5[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb6and7[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb4and5and6and7[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            c_addsub_4 add64 (
                .A(nb4and5and6and7[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+17*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+17*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]) 
            );
            c_addsub_4 add65 (
                .A(nb11and12and13and14[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+14*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+14*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+6*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+6*OUTPUTS)]) 
            );
            c_addsub_2 add66 (
                .A(nb15and16[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb17and18[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb15and16and17and18[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            c_addsub_4 add67 (
                .A(nb15and16and17and18[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+11*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+11*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]) 
            );
            c_addsub_2 add68 (
                .A(nb25and26[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb27and28[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb25and26and27and28[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            c_addsub_4 add69 (
                .A(nb25and26and27and28[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+10*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+10*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+4*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+4*OUTPUTS)]) 
            );
            c_addsub_2 add70 (
                .A(nb32and33[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb34and35[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb32and33and34and35[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            c_addsub_4 add71 (
                .A(nb32and33and34and35[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+8*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+8*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]) 
            );
            c_addsub_4 add72 (
                .A(nb39and40and41and42[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]) 
            );
            c_addsub_2 add73 (
                .A(nb43and44[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb45and46[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb43and44and45and46[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            c_addsub_4 add74 (
                .A(nb43and44and45and46[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]) 
            );
            c_addsub_2 add75 (
                .A(nb53and54[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .B(nb55and56[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
                .CLK(clk),  
                .S(nb53and54and55and56[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            );
            c_addsub_4 add76 (
                .A(nb53and54and55and56[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
                .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]), 
                .CLK(clk),  
                .S(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            );
            //c_addsub_3 add77 (
            //    .A(nb8and9delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums9[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]) 
            //);
            //c_addsub_4 add78 (
            //    .A(nb25and26and27and28delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+8*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+8*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums9[(2*BITS+OVERHEAD_BITS)*(aa+1+4*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+4*OUTPUTS)]) 
            //);
            //c_addsub_2 add79 (
            //    .A(nb21and22[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(nb23and24[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .CLK(clk),  
            //    .S(nb21and22and23and24[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            //);
            //c_addsub_4 add80 (
            //    .A(nb21and22and23and24delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums9[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]) 
            //);
            //c_addsub_3 add81 (
            //    .A(nb36and37delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums9[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]) 
            //);
            //c_addsub_4 add82 (
            //    .A(nb53and54and55and56delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums9[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]) 
            //);
            //c_addsub_2 add83 (
            //    .A(nb49and50[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(nb51and52[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .CLK(clk),  
            //    .S(nb49and50and51and52[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]) 
            //);
            //c_addsub_4 add84 (
            //    .A(nb49and50and51and52delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums5[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums9[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
            //c_addsub_4 add85 (
            //    .A(nb11and12and13and14delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums11[(2*BITS+OVERHEAD_BITS)*(aa+1+4*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+4*OUTPUTS)]) 
            //);
            //c_addsub_4 add86 (
            //    .A(nb15and16and17and18[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+14*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+14*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(nb8and9and10and15and16and17and18[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
            //c_addsub_4 add87 (
            //    .A(nb25and26and27and28delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(nb8and9and10and15and16and17and18[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .CLK(clk),  
            //    .S(sums11[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]) 
            //);
            //c_addsub_4 add88 (
            //    .A(nb39and40and41and42delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums11[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]) 
            //);
            //c_addsub_4 add89 (
            //    .A(nb43and44and45and46[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(nb36and37and38and43and44and45and46[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
            //c_addsub_4 add90 (
            //    .A(nb53and54and55and56delay[(2*BITS+2)*(aa+1)-1:(2*BITS+2)*aa]), 
            //    .B(nb36and37and38and43and44and45and46[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .CLK(clk),  
            //    .S(sums11[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
            //c_addsub_5 add91 (
            //    .A(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+11*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+11*OUTPUTS)]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+10*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+10*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(nb19and20and21and22and23and24[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
            //c_addsub_3 add92 (
            //    .A(nb51and52delay[(2*BITS+1)*(aa+1)-1:(2*BITS+1)*aa]), 
            //    .B(sums3[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(nb47and48and49and51and52[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
            //c_addsub_5 add93 (
            //    .A(nb19and20and21and22and23and24[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .B(nb47and48and49and51and52[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .CLK(clk),  
            //    .S(sums11[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]) 
            //);
            //c_addsub_5 add94 (
            //    .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+7*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+7*OUTPUTS)]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+6*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+6*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums13[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]) 
            //);
            //c_addsub_5 add95 (
            //    .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+5*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+5*OUTPUTS)]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+4*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+4*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums13[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]) 
            //);
            //c_addsub_5 add96 (
            //    .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+3*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+3*OUTPUTS)]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+2*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+2*OUTPUTS)]), 
            //    .CLK(clk),  
            //    .S(sums13[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]) 
            //);
            //c_addsub_5 add97 (
            //    .A(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1+OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(aa+OUTPUTS)]), 
            //    .B(sums7[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]), 
            //    .CLK(clk),  
            //    .S(sums13[(2*BITS+OVERHEAD_BITS)*(aa+1)-1:(2*BITS+OVERHEAD_BITS)*aa]) 
            //);
                        
        end
        endgenerate
        
        always @(posedge clk)
        begin
            nb4and5reg <= nb4and5;
            nb6and7reg <= nb6and7;
            sums1from15delayreg <= sums1[(2*BITS+OVERHEAD_BITS)*(42*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(41*OUTPUTS)];              
            nb19and20reg <= nb19and20;
            nb21and25reg <= nb21and25;
            nb32and33reg <= nb32and33;
            nb34and35reg <= nb34and35;
            sums1from43delayreg <= sums1[(2*BITS+OVERHEAD_BITS)*(14*OUTPUTS)-1:(2*BITS+OVERHEAD_BITS)*(13*OUTPUTS)];  
            nb47and48reg <= nb47and48;
            nb49and53reg <= nb49and53;
            nb55and56reg <= nb55and56;
            nb8and9reg <= nb8and9;
            nb8and9reg2 <= nb8and9reg;
            nb25and26and27and28reg <= nb25and26and27and28;
            nb21and22and23and24reg <= nb21and22and23and24;
            nb36and37reg <= nb36and37;
            nb36and37reg2 <= nb36and37reg;
            nb53and54and55and56reg <= nb53and54and55and56;
            nb11and12and13and14reg <= nb11and12and13and14;
            nb39and40and41and42reg <= nb39and40and41and42;
            nb51and52reg <= nb51and52;
            nb49and50and51and52reg <= nb49and50and51and52;
        end
        
        assign nb4and5delay = nb4and5reg;
        assign nb6and7delay = nb6and7reg;
        assign sums1from15delay = sums1from15delayreg;
        assign nb19and20delay = nb19and20reg;
        assign nb21and25delay = nb21and25reg;
        assign nb32and33delay = nb32and33reg;
        assign nb34and35delay = nb34and35reg;
        assign sums1from43delay = sums1from43delayreg;
        assign nb47and48delay = nb47and48reg;
        assign nb49and53delay = nb49and53reg;
        assign nb55and56delay = nb55and56reg;
        assign nb8and9delay = nb8and9reg2;
        assign nb25and26and27and28delay = nb25and26and27and28reg;
        assign nb21and22and23and24delay = nb21and22and23and24reg;
        assign nb36and37delay = nb36and37reg2;
        assign nb53and54and55and56delay = nb53and54and55and56reg;
        assign nb11and12and13and14delay = nb11and12and13and14reg;
        assign nb39and40and41and42delay = nb39and40and41and42reg;
        assign nb51and52delay = nb51and52reg;
        assign nb49and50and51and52delay = nb49and50and51and52reg;
endmodule