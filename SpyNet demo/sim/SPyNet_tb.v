`timescale 1ns / 1ps


module SPyNet_tb #(parameter BITS = 16, parameter KERNEL = 7, parameter FEATURES = 21, parameter OVERHEAD_BITS = 12, parameter NB_BASE_BLOCKS = 8, parameter HALF_WIDTH_RAM = 72,
    parameter WIDTH_WEIGHT = 4, parameter WIDTH_FIRST_SIX = 3, parameter WIDTH_OTHERS = 14, parameter BITS_ADDRESS_WEIGHTS = 14, parameter BITS_ADDRESS_BIASES = 9, parameter BITS_ADDRESS_FIRST_SIX = 10,
    parameter BITS_ADDRESS_OTHERS = 12, parameter HALF_CHANNELS_LAYER0 = 4, parameter HALF_CHANNELS_LAYER1 = 16, parameter HALF_CHANNELS_LAYER2 = 32, parameter HALF_CHANNELS_LAYER3 = 16, 
    parameter HALF_CHANNELS_LAYER4 = 8, parameter HALF_CHANNELS_LAYER5 = 1)(

    );
    
    reg clk = 0;
    reg [31:0] inputdata;
    wire start_SPyNet;
    reg  start_SPyNet_reg = 1'b0;
    wire [2:0] stage;
    reg  [2:0] stage_reg;
    wire [2:0] type;
    reg  [2:0] type_reg;
    wire [31:0] outputdata;
    reg [31:0] result_reg;
    
    SPyNet #(.BITS(BITS),.KERNEL(KERNEL),.FEATURES(FEATURES),.OVERHEAD_BITS(OVERHEAD_BITS),.NB_BASE_BLOCKS(NB_BASE_BLOCKS),
        .HALF_WIDTH_RAM(HALF_WIDTH_RAM),.WIDTH_WEIGHT(WIDTH_WEIGHT),.WIDTH_FIRST_SIX(WIDTH_FIRST_SIX),.WIDTH_OTHERS(WIDTH_OTHERS),
        .BITS_ADDRESS_WEIGHTS(BITS_ADDRESS_WEIGHTS),.BITS_ADDRESS_BIASES(BITS_ADDRESS_BIASES),.BITS_ADDRESS_FIRST_SIX(BITS_ADDRESS_FIRST_SIX),.BITS_ADDRESS_OTHERS(BITS_ADDRESS_OTHERS),
        .HALF_CHANNELS_LAYER0(HALF_CHANNELS_LAYER0),.HALF_CHANNELS_LAYER1(HALF_CHANNELS_LAYER1),.HALF_CHANNELS_LAYER2(HALF_CHANNELS_LAYER2),
        .HALF_CHANNELS_LAYER3(HALF_CHANNELS_LAYER3),.HALF_CHANNELS_LAYER4(HALF_CHANNELS_LAYER4)) SPyNet (
            .clk(clk),
            .start_SPyNet(start_SPyNet),
            .stage(stage),
            .type(type),
            .inputdata(inputdata),
            .outputdata(outputdata)
            );

    initial
    begin
        #105
        start_SPyNet_reg <= 1'b1;
        stage_reg <= 3'b100;
        type_reg <= 3'b000;
        // Gewichten oneven --> oneven
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 7;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 17;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 14;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 18;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*1 + 1;
        #684320
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 15;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 19;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 16;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*4 + 5;
        #10
        inputdata <= 65536*6 + 20;
        #10
        inputdata <= 65536*8 + 9;
        #10
        inputdata <= 65536*10 + 0;
        #10
        inputdata <= 65536*1 + 1;
        #684320
        inputdata <= 65536*5 + 1;
        #10
        inputdata <= 65536 + 1;
        #720
        inputdata <= 65536 + 1;
        #30
        inputdata <= 65536*8 + 8;
        #30
        inputdata <= 65536*15 + 15;
        #30
        inputdata <= 65536*22 + 22;
        #30
        inputdata <= 65536*57 + 57;
        #30
        inputdata <= 65536*64 + 64;
        #30
        inputdata <= 65536*71 + 71;
        #30
        inputdata <= 65536*78 + 78;
        #30 
        inputdata <= 65536*113 + 113;
        #30
        inputdata <= 65536*120 + 120;
        #30
        inputdata <= 65536*127 + 127;
        #30
        inputdata <= 65536*134 + 134;
        #30
        inputdata <= 65536*169 + 169;
        #30
        inputdata <= 65536*176 + 176;
        #30
        inputdata <= 65536*183 + 183;
        #30
        inputdata <= 65536*190 + 190;
        #30
        inputdata <= 65536*29 + 29;
        #30
        inputdata <= 65536*36 + 36;
        #30
        inputdata <= 65536*43 + 43;
        #30
        inputdata <= 65536*50 + 50;
        #30
        inputdata <= 65536*85 + 85;
        #30
        inputdata <= 65536*92 + 92;
        #30
        inputdata <= 65536*99 + 99;
        #30
        inputdata <= 65536*106 + 106;
        #30 
        inputdata <= 65536*141 + 141;
        #30
        inputdata <= 65536*148 + 148;
        #30
        inputdata <= 65536*155 + 155;
        #30
        inputdata <= 65536*162 + 162;
        #30
        inputdata <= 65536*197 + 197;
        #30
        inputdata <= 65536*204 + 204;
        #30
        inputdata <= 65536*211 + 211;
        #30
        inputdata <= 65536*218 + 218;
        #30
        inputdata <= 65536*1 + 1;
        #150
        inputdata <= 65536*2 + 2;
        #150
        inputdata <= 65536*3 + 3;
        #150
        inputdata <= 65536*4 + 4;
        #150
        inputdata <= 65536*5 + 5;
        #150
        inputdata <= 65536*6 + 6;
        #150
        inputdata <= 65536*7 + 7;
        #150
        inputdata <= 65536*8 + 8;
        #150
        inputdata <= 65536*9 + 9;
        #150
        inputdata <= 65536*10 + 10;
        #150
        inputdata <= 65536*11 + 11;
        #150
        inputdata <= 65536*12 + 12;
        #150
        inputdata <= 65536*13 + 13;
        #150
        inputdata <= 65536*14 + 14;
        #150
        inputdata <= 65536*15 + 15;
        #150
        inputdata <= 65536*16 + 16;
        #150
        inputdata <= 65536*17 + 17;
        #150
        inputdata <= 65536*18 + 18;
        #150
        inputdata <= 65536*19 + 19;
        #150
        inputdata <= 65536*20 + 20;
        #150
        inputdata <= 65536*21 + 21;
        #150
        inputdata <= 65536*22 + 22;
        #150
        inputdata <= 65536*23 + 23;
        #150
        inputdata <= 65536*24 + 24;
        #150
        inputdata <= 65536*25 + 25;
        #150
        inputdata <= 65536*26 + 26;
        #150
        inputdata <= 65536*27 + 27;
        #150
        inputdata <= 65536*28 + 28;
        #150
        inputdata <= 65536 + 1;
        #29400
        inputdata <= 0;
        #5000000
      
        $finish;
    end

    always begin
        #5 clk = ~clk;
    end
    
    always @(posedge clk)
    begin
        result_reg <= outputdata;
    end
    
    assign start_SPyNet = start_SPyNet_reg;
    assign stage = stage_reg;
    assign type = type_reg;
endmodule

