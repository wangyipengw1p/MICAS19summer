`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2019 11:42:16 AM
// Design Name: 
// Module Name: SPyNet
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


module SPyNet #(parameter BITS = 16, parameter KERNEL = 7, parameter FEATURES = 21, parameter OVERHEAD_BITS = 12, parameter NB_BASE_BLOCKS = 8, parameter HALF_WIDTH_RAM = 72,
    parameter WIDTH_WEIGHT = 4, parameter WIDTH_FIRST_SIX = 3, parameter WIDTH_OTHERS = 14, parameter BITS_ADDRESS_WEIGHTS = 14, parameter BITS_ADDRESS_BIASES = 9, parameter BITS_ADDRESS_FIRST_SIX = 10,
    parameter BITS_ADDRESS_OTHERS = 12, parameter HALF_CHANNELS_LAYER0 = 4, parameter HALF_CHANNELS_LAYER1 = 16, parameter HALF_CHANNELS_LAYER2 = 32, parameter HALF_CHANNELS_LAYER3 = 16, 
    parameter HALF_CHANNELS_LAYER4 = 8, parameter HALF_CHANNELS_LAYER5 = 1)(
    input clk, //
    input start_SPyNet,
    input [2:0] stage,
    input [2:0] type,
    input [31:0] inputdata,
    output [31:0] outputdata
    );
    
    wire start;
    reg  start_reg = 1'b0;
    wire [31:0] input_channels; 
    reg  [31:0] input_channels_reg = {32{1'b0}};
    wire last_row = 1'b0;
    wire [31:0] output_channels;
    wire done;
    
    
    evaluate_network #(.BITS(BITS),.KERNEL(KERNEL),.FEATURES(FEATURES),.OVERHEAD_BITS(OVERHEAD_BITS),.NB_BASE_BLOCKS(NB_BASE_BLOCKS),
    .HALF_WIDTH_RAM(HALF_WIDTH_RAM),.WIDTH_WEIGHT(WIDTH_WEIGHT),.WIDTH_FIRST_SIX(WIDTH_FIRST_SIX),.WIDTH_OTHERS(WIDTH_OTHERS),
    .BITS_ADDRESS_WEIGHTS(BITS_ADDRESS_WEIGHTS),.BITS_ADDRESS_BIASES(BITS_ADDRESS_BIASES),.BITS_ADDRESS_FIRST_SIX(BITS_ADDRESS_FIRST_SIX),.BITS_ADDRESS_OTHERS(BITS_ADDRESS_OTHERS),
    .HALF_CHANNELS_LAYER0(HALF_CHANNELS_LAYER0),.HALF_CHANNELS_LAYER1(HALF_CHANNELS_LAYER1),.HALF_CHANNELS_LAYER2(HALF_CHANNELS_LAYER2),
    .HALF_CHANNELS_LAYER3(HALF_CHANNELS_LAYER3),.HALF_CHANNELS_LAYER4(HALF_CHANNELS_LAYER4),.ROWS_FOR_TILE(7)) evaluate_network (
        //.clk(FCLK_CLK0_0),
        .clk(clk),
        .start(start),
        .input_channels(input_channels),
        .stage(stage),
        .type(type),                               
        .last_row(last_row),
        .output_channels(output_channels),
        .done(done),
        .shift_bias_layer0(0),  
        .shift_bias_layer1(0),  
        .shift_bias_layer2(0),  
        .shift_bias_layer3(0),  
        .shift_bias_layer4(0),  
        .shift_result_layer0(12),
        .shift_result_layer1(16),
        .shift_result_layer2(16),
        .shift_result_layer3(16),
        .shift_result_layer4(16)
        );
        
    //wire [14:0]DDR_0_addr;
    //wire [2:0]DDR_0_ba;
    //wire DDR_0_cas_n;
    //wire DDR_0_ck_n;
    //wire DDR_0_ck_p;
    //wire DDR_0_cke;
    //wire DDR_0_cs_n;
    //wire [3:0]DDR_0_dm;
    //wire [31:0]DDR_0_dq;
    //wire [3:0]DDR_0_dqs_n;
    //wire [3:0]DDR_0_dqs_p;
    //wire DDR_0_odt;
    //wire DDR_0_ras_n;
    //wire DDR_0_reset_n;
    //wire DDR_0_we_n;
    //wire FCLK_CLK0_0;
    //wire FIXED_IO_0_ddr_vrn;
    //wire FIXED_IO_0_ddr_vrp;
    //wire [53:0]FIXED_IO_0_mio;
    //wire FIXED_IO_0_ps_clk;
    //wire FIXED_IO_0_ps_porb;
    //wire FIXED_IO_0_ps_srstb;
    //
    //blockdesign blockdesign_i
    //     (.DDR_0_addr(DDR_0_addr),
    //      .DDR_0_ba(DDR_0_ba),
    //      .DDR_0_cas_n(DDR_0_cas_n),
    //      .DDR_0_ck_n(DDR_0_ck_n),
    //      .DDR_0_ck_p(DDR_0_ck_p),
    //      .DDR_0_cke(DDR_0_cke),
    //      .DDR_0_cs_n(DDR_0_cs_n),
    //      .DDR_0_dm(DDR_0_dm),
    //      .DDR_0_dq(DDR_0_dq),
    //      .DDR_0_dqs_n(DDR_0_dqs_n),
    //      .DDR_0_dqs_p(DDR_0_dqs_p),
    //      .DDR_0_odt(DDR_0_odt),
    //      .DDR_0_ras_n(DDR_0_ras_n),
    //      .DDR_0_reset_n(DDR_0_reset_n),
    //      .DDR_0_we_n(DDR_0_we_n),
    //      .FCLK_CLK0_0(FCLK_CLK0_0),
    //      .FIXED_IO_0_ddr_vrn(FIXED_IO_0_ddr_vrn),
    //      .FIXED_IO_0_ddr_vrp(FIXED_IO_0_ddr_vrp),
    //      .FIXED_IO_0_mio(FIXED_IO_0_mio),
    //      .FIXED_IO_0_ps_clk(FIXED_IO_0_ps_clk),
    //      .FIXED_IO_0_ps_porb(FIXED_IO_0_ps_porb),
    //      .FIXED_IO_0_ps_srstb(FIXED_IO_0_ps_srstb));
       
        
    always @(posedge clk)
    begin
        if (start_SPyNet == 1'b1)
        begin
        start_reg <= 1'b1;
        end
        input_channels_reg <= inputdata;
    end
    
    assign input_channels = input_channels_reg;
    assign start = start_reg;
    assign outputdata = output_channels;
        
endmodule
