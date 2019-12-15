`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 04/07/2019 10:41:45 AM
// Design Name:
// Module Name: evaluate_network
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

module evaluate_network #(parameter BITS = 16, parameter KERNEL = 7, parameter FEATURES = 21, parameter OVERHEAD_BITS = 12, parameter WIDTH = 720, 
    parameter LAYER0 = 8, parameter LAYER1 = 32, parameter LAYER2 = 64, parameter LAYER3 = 32, parameter LAYER4 = 16, parameter LAYER5 = 2,
    parameter NB_LAYERS = 5, parameter OVERHEAD_FEATURES_EACH_LAYER = 6, parameter NB_BASE_BLOCKS = 8, 
    parameter NB_BLOCK_RAMS = 487, parameter WIDTH_RAM = 72, parameter HALF_BITS = 8, parameter PADDING = 3, 
    parameter STAGE0 = 1440, parameter STAGE1 = 2880, parameter STAGE2 = 5760, parameter STAGE3 = 11520) (
    input clk,
    input start,
    input [31:0] input_channels,
    input [2:0] stage,
    input type,                                               // 0 for left block, 1 for right block
    input [7:0] iterations_each_row,
    input last_row,
    input [8:0] input_features,
    output [31:0] output_channels,
    output done
    );

    // Communication with the give_filter_weights block to obtain the filters and biases.
    wire [BITS*KERNEL*NB_BASE_BLOCKS-1:0] filter_weights;
    reg  [BITS*KERNEL*NB_BASE_BLOCKS-1:0] filter_weights_reg;
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters1 = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters2 = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters3 = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters4 = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters1_temp = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters2_temp = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters3_temp = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg  [HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS-1:0] all_filters4_temp = {(HALF_BITS*KERNEL*KERNEL*NB_BASE_BLOCKS){1'b0}};
    wire [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] biases;
    reg  [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] biases_reg = {(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1){1'b0}};
    wire change;
    reg  change_reg = 1'b0;
    wire [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] temp_result;
    reg  [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] temp_result_reg = {(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1){1'b0}};

    // Input and output features for the base blocks
    wire [BITS*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] features;
    wire [56*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums1;                 // Not used.
    wire [18*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums3;                 // Not used.
    wire [11*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums5;                 // Not used.
    wire [NB_BASE_BLOCKS*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums7;
    wire [6*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums9;                  // Not used.
    wire [5*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums11;                 // Not used.
    wire [4*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] sums13;                 // Not used.
    wire [2*(FEATURES-KERNEL+1)*(2*BITS+OVERHEAD_BITS)-1:0] results;
    
    reg [1319:0] output_channels_reg = {1320{1'b0}};
    
    
    
    // Counters and help bits for the FSM
    reg  start1 = 1'b1;
    reg  start2 = 1'b0;
    reg  start3 = 1'b0;
    reg  start4 = 1'b0;
    reg  start5 = 1'b0;
    reg  start6 = 1'b0;
    reg  start7 = 1'b0;
    reg  start8 = 1'b0;
    reg  start9 = 1'b0;
    reg  start10 = 1'b0;
    reg  start11 = 1'b0;
    reg  start12 = 1'b0;
    reg  start13 = 1'b0;
    reg  start14 = 1'b0;
    reg  start15 = 1'b0;
    reg  start16 = 1'b0;
    reg  startFSM = 1'b0;
    reg  startUseful = 1'b0;
    reg  continue = 1'b1;
    reg  [8:0] counter_first_phase = 9'b00000000;
    reg  [7:0] counter_internal_phase = 8'b00000000;
    reg  [7:0] counter_internal_phase_1 = 8'b00000000;
    reg  [7:0] counter_internal_phase_2 = 8'b00000000;
    reg  [7:0] counter_internal_phase_3 = 8'b00000000;
    reg  [7:0] counterFSM = 8'b00000000;
    reg  [8:0] first_row_data = 9'b000000000;
    reg  [8:0] first_row_data_temp = 9'b000000000;
    reg  [8:0] first_row_weights = 9'b000000000;
    reg  [8:0] next_row_weights = 9'b000000000;
    reg  [1:0] block_row_data = 2'b00;
    reg  [1:0] block_row_weights = 2'b00;
    reg  [2:0] pointer = 3'b000;
    reg  [2:0] pointer1 = 3'b000;
    reg  [2:0] pointer2 = 3'b000;
    reg  [2:0] pointer3 = 3'b000;
    reg  [2:0] pointer4 = 3'b000;
    reg  [2:0] pointer5 = 3'b000;
    reg  [2:0] layer = 3'b000;
    reg  [4:0] number_four_inputs = 5'b00000;
    reg  [4:0] number_four_outputs = 5'b00000;
    
    
    
    reg [3:0] counteromtetesten = 4'b0000;
    
    // Inputs and outputs of base blocks
    reg  [164*WIDTH_RAM-1:0]   temp_in_1 = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_2 = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_3 = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_4 = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_1_temp = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_2_temp = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_3_temp = {(164*WIDTH_RAM){1'b0}};
    reg  [164*WIDTH_RAM-1:0]   temp_in_4_temp = {(164*WIDTH_RAM){1'b0}};
    
    reg  [735*(2*BITS+OVERHEAD_BITS)-1:0]   temp_out_1 = {735*(2*BITS+OVERHEAD_BITS){1'b0}};
    reg  [735*(2*BITS+OVERHEAD_BITS)-1:0]   temp_out_2 = {735*(2*BITS+OVERHEAD_BITS){1'b0}};
    reg  [735*(2*BITS+OVERHEAD_BITS)-1:0]   temp_out_3 = {735*(2*BITS+OVERHEAD_BITS){1'b0}};
    reg  [735*(2*BITS+OVERHEAD_BITS)-1:0]   temp_out_4 = {735*(2*BITS+OVERHEAD_BITS){1'b0}};

    
    
    // Generation of the base_blocks
    base_block_extended #(.BITS(BITS),.OVERHEAD_BITS(OVERHEAD_BITS),.OUTPUTS(FEATURES-KERNEL+1)) base_block_extended(
        .clk(clk),
        .filters(filter_weights),
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
        
    adder_base_block_extended #(.BITS(BITS),.OVERHEAD_BITS(OVERHEAD_BITS),.NB_BASE_BLOCKS(NB_BASE_BLOCKS), 
    .FEATURES(FEATURES),.KERNEL(KERNEL)) adder_base_block_extended(
            .clk(clk),
            .sums7(sums7),
            .results(results)
            );
    
    
    // Obtain the filters and biases
    //give_filter_weights #(.BITS(BITS),.KERNEL(KERNEL),.NB_BASE_BLOCKS(NB_BASE_BLOCKS),.OVERHEAD_BITS(OVERHEAD_BITS),.FEATURES(FEATURES)) give_filter_weights (
    //    .clk(clk),
    //    .start(start),
    //    .done(done),
    //    .stage(stage),
    //    .change(change),
    //    .temp_result(temp_result),
    //    .filter_weights(filter_weights),
    //    .biases(biases)
    // );
    ///
    reg en_reg                                      = 1'b1;                 
    reg [NB_BLOCK_RAMS-1:0] write_reg               = {(NB_BLOCK_RAMS){1'b0}};
    reg [26:0]              read_addr_reg           = {27{1'b0}};
    reg [26:0]              write_addr_reg          = {27{1'b0}};
    reg [NB_BLOCK_RAMS*WIDTH_RAM-1:0]   input_RAMS_reg  = {(NB_BLOCK_RAMS*WIDTH_RAM){1'b0}};
    wire en;   
    wire [NB_BLOCK_RAMS-1:0] write;
    wire [26:0]              read_addr;
    wire [26:0]              write_addr;
    wire [NB_BLOCK_RAMS*WIDTH_RAM-1:0]   input_RAMS;
    wire [NB_BLOCK_RAMS*WIDTH_RAM-1:0]   output_RAMS;
    assign en = en_reg;
    assign write = write_reg;
    assign read_addr = read_addr_reg;
    assign write_addr = write_addr_reg;
    assign input_RAMS = input_RAMS_reg;
    genvar bb;
    generate
    for (bb=323; bb<NB_BLOCK_RAMS; bb=bb+1)
        begin
        blk_mem_gen_1 memUpperRow (
          .clka(clk),    // input wire clka
          .ena(en),      // input wire ena
          .wea(write[bb]),      // input wire [0 : 0] wea
          .addra(write_addr[26:18]),  // input wire [8 : 0] addra
          .dina(input_RAMS[(bb+1)*WIDTH_RAM-1:bb*WIDTH_RAM]),    // input wire [71 : 0] dina
          .clkb(clk),    // input wire clkb
          .enb(en),      // input wire enb
          .addrb(read_addr[26:18]),  // input wire [8 : 0] addrb
          .doutb(output_RAMS[(bb+1)*WIDTH_RAM-1:bb*WIDTH_RAM])  // output wire [71 : 0] doutb
        );
        end
    for (bb=161; bb<323; bb=bb+1)
        begin
        blk_mem_gen_1 memMiddleRow (
          .clka(clk),    // input wire clka
          .ena(en),      // input wire ena
          .wea(write[bb]),      // input wire [0 : 0] wea
          .addra(write_addr[17:9]),  // input wire [8 : 0] addra
          .dina(input_RAMS[(bb+1)*WIDTH_RAM-1:bb*WIDTH_RAM]),    // input wire [71 : 0] dina
          .clkb(clk),    // input wire clkb
          .enb(en),      // input wire enb
          .addrb(read_addr[17:9]),  // input wire [8 : 0] addrb
          .doutb(output_RAMS[(bb+1)*WIDTH_RAM-1:bb*WIDTH_RAM])  // output wire [71 : 0] doutb
        );
        end
    for (bb=0; bb<161; bb=bb+1)
        begin
        blk_mem_gen_1 memUnderRow (
          .clka(clk),    // input wire clka
          .ena(en),      // input wire ena
          .wea(write[bb]),      // input wire [0 : 0] wea
          .addra(write_addr[8:0]),  // input wire [8 : 0] addra
          .dina(input_RAMS[(bb+1)*WIDTH_RAM-1:bb*WIDTH_RAM]),    // input wire [71 : 0] dina
          .clkb(clk),    // input wire clkb
          .enb(en),      // input wire enb
          .addrb(read_addr[8:0]),  // input wire [8 : 0] addrb
          .doutb(output_RAMS[(bb+1)*WIDTH_RAM-1:bb*WIDTH_RAM])  // output wire [71 : 0] doutb
        );
        end
    endgenerate
    

    always @(posedge clk)
    begin
    if (start == 1'b1)
        begin
            if (start1 == 1'b1)
                begin
                    input_RAMS_reg[23255:16952] <= {input_RAMS_reg[23223:16952],input_channels};
                    if (counter_first_phase == 9'b011000100)
                        begin
                            if (counter_internal_phase == 8'b00011111)
                                begin
                                    start1 <= 1'b0;
                                    start2 <= 1'b1;
                                    counter_internal_phase <= 8'b00000000;
                                    counter_first_phase <= 9'b000000000;
                                end
                            else
                                begin
                                    counter_first_phase <= 9'b000000000;
                                    counter_internal_phase <= counter_internal_phase + 1;
                                end
                        end
                    else if (counter_first_phase == 9'b000000000)
                        begin
                            write_reg[322:235] <= {88{1'b1}};
                            write_addr_reg[17:9] <= 9'b110111111 + {1'b0,counter_internal_phase};
                            counter_first_phase <= counter_first_phase + 1;
                        end
                    else if (counter_first_phase == 9'b000000001)
                        begin
                            write_reg[322:235] <= {88{1'b0}};
                            counter_first_phase <= counter_first_phase + 1;
                        end
                    else
                        begin
                            counter_first_phase <= counter_first_phase + 1;
                        end
                end
        end
    else
        begin
            start1 <= 1'b1;
        end
    if (start2 == 1'b1)
        begin
            input_RAMS_reg[11591:72] <= {input_RAMS_reg[11559:72],input_channels};
            if (counter_first_phase == 9'b101100111)
                begin
                    if (counter_internal_phase == 8'b01111111)
                        begin
                            start2 <= 1'b0;
                            start3 <= 1'b1;
                            counter_internal_phase <= 8'b00000000;
                            counter_first_phase <= 9'b000000000;
                        end
                    else
                        begin
                            counter_first_phase <= 9'b000000000;
                            counter_internal_phase <= counter_internal_phase + 1;
                        end
                end
            else if (counter_first_phase == 9'b000000000)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[322:235] <= {88{1'b1}};
                        write_addr_reg[17:9] <= 9'b111011111;
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:1] <= {160{1'b1}};
                        write_addr_reg[8:0] <= 9'b001101111 + {1'b0,counter_internal_phase};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else if (counter_first_phase == 9'b000000001)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[322:235] <= {88{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:1] <= {160{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else
                begin
                    counter_first_phase <= counter_first_phase + 1;
                end
        end
  if (start3 == 1'b1)
        begin
            input_RAMS_reg[11591:10664] <= {input_RAMS_reg[11559:10664],input_channels};
            if (counter_first_phase == 9'b001000000)
                begin
                    if (counter_internal_phase == 8'b00111111)
                        begin
                            start3 <= 1'b0;
                            start8 <= 1'b1;
                            counter_internal_phase <= 8'b00000000;
                            counter_first_phase <= 9'b000000000;
                        end
                    else
                        begin
                            counter_first_phase <= 9'b000000000;
                            counter_internal_phase <= counter_internal_phase + 1;
                        end
                end
            else if (counter_first_phase == 9'b000000000)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:1] <= {160{1'b1}};
                        write_addr_reg[8:0] <= 9'b011101111;
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:132] <= {29{1'b1}};
                        write_addr_reg[8:0] <= 9'b011101111 + {1'b0,counter_internal_phase};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else if (counter_first_phase == 9'b000000001)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:1] <= {160{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:132] <= {29{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else
                begin
                    counter_first_phase <= counter_first_phase + 1;
                end
        end
  
    if (start8 == 1'b1)
        begin
            input_RAMS_reg[11591:72] <= {input_RAMS_reg[11559:72],input_channels};
            if (counter_first_phase == 9'b101100111)
                begin
                    if (counter_internal_phase == 8'b01111111)
                        begin
                            start8 <= 1'b0;
                            start10 <= 1'b1;
                            counter_internal_phase <= 8'b00000000;
                            counter_first_phase <= 9'b000000000;
                        end
                    else
                        begin
                            counter_first_phase <= 9'b000000000;
                            counter_internal_phase <= counter_internal_phase + 1;
                        end
                end
            else if (counter_first_phase == 9'b000000000)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:132] <= {29{1'b1}};
                        write_addr_reg[8:0] <= 9'b100101111;
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:1] <= {160{1'b1}};
                        write_addr_reg[8:0] <= 9'b100101111 + {1'b0,counter_internal_phase};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else if (counter_first_phase == 9'b000000001)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:132] <= {29{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:1] <= {160{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else
                begin
                    counter_first_phase <= counter_first_phase + 1;
                end
        end
  if (start10 == 1'b1)
        begin
            input_RAMS_reg[11591:7416] <= {input_RAMS_reg[11559:7416],input_channels};
            if (counter_first_phase == 9'b010000000)
                begin
                    if (counter_internal_phase == 8'b00011111)
                        begin
                            start10 <= 1'b0;
                            start11 <= 1'b1;
                            counter_internal_phase <= 8'b00000000;
                            counter_first_phase <= 9'b000000000;
                        end
                    else
                        begin
                            counter_first_phase <= 9'b000000000;
                            counter_internal_phase <= counter_internal_phase + 1;
                        end
                end
            else if (counter_first_phase == 9'b000000000)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:1] <= {160{1'b1}};
                        write_addr_reg[8:0] <= 9'b110101111;
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:103] <= {58{1'b1}};
                        write_addr_reg[8:0] <= 9'b110101111 + {1'b0,counter_internal_phase};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else if (counter_first_phase == 9'b000000001)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:1] <= {160{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:103] <= {58{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else
                begin
                    counter_first_phase <= counter_first_phase + 1;
                end
        end
    if (start11 == 1'b1)
          begin
              input_RAMS_reg[11591:72] <= {input_RAMS_reg[11559:72],input_channels};
              if (counter_first_phase == 9'b101100111)
                  begin
                      if (counter_internal_phase == 8'b00011111)
                          begin
                              start11 <= 1'b0;
                              start13 <= 1'b1;
                              counter_internal_phase <= 8'b00000000;
                              counter_first_phase <= 9'b000000000;
                          end
                      else
                          begin
                              counter_first_phase <= 9'b000000000;
                              counter_internal_phase <= counter_internal_phase + 1;
                          end
                  end
              else if (counter_first_phase == 9'b000000000)
                  if (counter_internal_phase == 8'b00000000)
                      begin
                          write_reg[160:103] <= {58{1'b1}};
                          write_addr_reg[8:0] <= 9'b111001111;
                          counter_first_phase <= counter_first_phase + 1;
                      end
                  else
                      begin
                          write_reg[160:1] <= {160{1'b1}};
                          write_addr_reg[8:0] <= 9'b111001111 + {1'b0,counter_internal_phase};
                          counter_first_phase <= counter_first_phase + 1;
                      end
              else if (counter_first_phase == 9'b000000001)
                  if (counter_internal_phase == 8'b00000000)
                      begin
                          write_reg[160:103] <= {58{1'b0}};
                          counter_first_phase <= counter_first_phase + 1;
                      end
                  else
                      begin
                          write_reg[160:1] <= {160{1'b0}};
                          counter_first_phase <= counter_first_phase + 1;
                      end
              else
                  begin
                      counter_first_phase <= counter_first_phase + 1;
                  end
          end

   if (start13 == 1'b1)
        begin
            input_RAMS_reg[11591:10664] <= {input_RAMS_reg[11559:10664],input_channels};
            if (counter_first_phase == 9'b001000000)
                begin
                    if (counter_internal_phase == 8'b00001111)
                        begin
                            start13 <= 1'b0;
                            start14 <= 1'b1;
                            counter_internal_phase <= 8'b00000000;
                            counter_first_phase <= 9'b000000000;
                        end
                    else
                        begin
                            counter_first_phase <= 9'b000000000;
                            counter_internal_phase <= counter_internal_phase + 1;
                        end
                end
            else if (counter_first_phase == 9'b000000000)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:1] <= {160{1'b1}};
                        write_addr_reg[8:0] <= 9'b111101111;
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:132] <= {29{1'b1}};
                        write_addr_reg[8:0] <= 9'b111101111 + {1'b0,counter_internal_phase};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else if (counter_first_phase == 9'b000000001)
                if (counter_internal_phase == 8'b00000000)
                    begin
                        write_reg[160:1] <= {160{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
                else
                    begin
                        write_reg[160:132] <= {29{1'b0}};
                        counter_first_phase <= counter_first_phase + 1;
                    end
            else
                begin
                    counter_first_phase <= counter_first_phase + 1;
                end
        end
     if (start14 == 1'b1)
         begin
             input_RAMS_reg[35063:23544] <= {input_RAMS_reg[35031:23544],input_channels};
             if (counter_first_phase == 9'b101100111)
                 begin
                     if (counter_internal_phase == 8'b00000001)
                         begin
                             start14 <= 1'b0;
                             start15 <= 1'b1;
                             counter_internal_phase <= 8'b00000000;
                             counter_first_phase <= 9'b000000000;
                         end
                     else
                         begin
                             counter_first_phase <= 9'b000000000;
                             counter_internal_phase <= counter_internal_phase + 1;
                         end
                 end
             else if (counter_first_phase == 9'b000000000)
                 if (counter_internal_phase == 8'b00000000)
                     begin
                         write_reg[160:132] <= {29{1'b1}};
                         write_addr_reg[8:0] <= 9'b111111111;
                         counter_first_phase <= counter_first_phase + 1;
                     end
                 else
                     begin
                         write_reg[486:327] <= {160{1'b1}};
                         write_addr_reg[26:18] <= 9'b111110111 + {1'b0,counter_internal_phase};
                         counter_first_phase <= counter_first_phase + 1;
                     end
             else if (counter_first_phase == 9'b000000001)
                 if (counter_internal_phase == 8'b00000000)
                     begin
                         write_reg[160:132] <= {29{1'b0}};
                         counter_first_phase <= counter_first_phase + 1;
                     end
                 else
                     begin
                         write_reg[486:327] <= {160{1'b0}};
                         counter_first_phase <= counter_first_phase + 1;
                     end
             else
                 begin
                     counter_first_phase <= counter_first_phase + 1;
                 end
         end
      if (start15 == 1'b1)
         begin
             input_RAMS_reg[35063:34008] <= {input_RAMS_reg[35031:34008],input_channels};
             if (counter_first_phase == 9'b000100000)
                 begin
                     if (counter_internal_phase == 8'b00000001)
                         begin
                             start15 <= 1'b0;
                             start16 <= 1'b1;
                             counter_internal_phase <= 8'b00000000;
                             counter_first_phase <= 9'b000000000;
                         end
                     else
                         begin
                             counter_first_phase <= 9'b000000000;
                             counter_internal_phase <= counter_internal_phase + 1;
                         end
                 end
             else if (counter_first_phase == 9'b000000000)
                 if (counter_internal_phase == 8'b00000000)
                     begin
                         write_reg[486:327] <= {160{1'b1}};
                         write_addr_reg[26:18] <= 9'b111111001;
                         counter_first_phase <= counter_first_phase + 1;
                     end
                 else
                     begin
                         write_reg[486:472] <= {15{1'b1}};
                         write_addr_reg[26:18] <= 9'b111111001 + {1'b0,counter_internal_phase};
                         counter_first_phase <= counter_first_phase + 1;
                     end
             else if (counter_first_phase == 9'b000000001)
                 if (counter_internal_phase == 8'b00000000)
                     begin
                         write_reg[486:327] <= {160{1'b0}};
                         counter_first_phase <= counter_first_phase + 1;
                     end
                 else
                     begin
                         write_reg[486:472] <= {15{1'b0}};
                         counter_first_phase <= counter_first_phase + 1;
                     end
             else
                 begin
                     counter_first_phase <= counter_first_phase + 1;
                 end
         end
     if (start16 == 1'b1)
        begin
        case(stage)
        3'b000  : input_RAMS_reg[35063:35064-90*16] <= {input_RAMS_reg[35031:35064-90*16],input_channels};
        3'b001  : input_RAMS_reg[35063:35064-180*16] <= {input_RAMS_reg[35031:35064-180*16],input_channels};
        3'b010  : input_RAMS_reg[35063:35064-360*16] <= {input_RAMS_reg[35031:35064-360*16],input_channels};
        3'b011  : input_RAMS_reg[35063:35064-720*16] <= {input_RAMS_reg[35031:35064-720*16],input_channels};
        3'b100  : input_RAMS_reg[35063:35064-735*16] <= {input_RAMS_reg[35031:35064-735*16],input_channels};
        endcase
             if (counter_first_phase == {1'b0,input_features[8:1]} - 1)
                 begin
                     if (counter_internal_phase == 8'b00000111)
                         begin
                             start16 <= 1'b0;
                             start4 <= 1'b1;
                             counter_internal_phase <= 8'b00000000;
                             counter_first_phase <= 9'b000000000;
                         end
                     else
                         begin
                             counter_first_phase <= 9'b000000000;
                             counter_internal_phase <= counter_internal_phase + 1;
                         end
                 end
             else if (counter_first_phase == 9'b000000000)
                 if (counter_internal_phase == 8'b00000000)
                     begin
                         write_reg[486:472] <= {15{1'b1}};
                         write_addr_reg[26:18] <= 9'b111111011;
                         counter_first_phase <= counter_first_phase + 1;
                     end
                 else
                     begin
                         write_reg[486:323] <= {164{1'b1}};
                         write_addr_reg[26:18] <= 9'b000000011 + (counter_internal_phase - 1)*7;
                         counter_first_phase <= counter_first_phase + 1;
                     end
             else if (counter_first_phase == 9'b000000001)
                 if (counter_internal_phase == 8'b00000000)
                     begin
                         write_reg[486:472] <= {15{1'b0}};
                         counter_first_phase <= counter_first_phase + 1;
                     end
                 else
                     begin
                         write_reg[486:323] <= {164{1'b0}};
                         counter_first_phase <= counter_first_phase + 1;
                     end
             else
                 begin
                     counter_first_phase <= counter_first_phase + 1;
                 end
         end
    if (start4 == 1'b1)
         begin
         case(stage)
         3'b000  : input_RAMS_reg[35063:35064-90*16] <= {input_RAMS_reg[35031:35064-90*16],input_channels};
         3'b001  : input_RAMS_reg[35063:35064-180*16] <= {input_RAMS_reg[35031:35064-180*16],input_channels};
         3'b010  : input_RAMS_reg[35063:35064-360*16] <= {input_RAMS_reg[35031:35064-360*16],input_channels};
         3'b011  : input_RAMS_reg[35063:35064-720*16] <= {input_RAMS_reg[35031:35064-720*16],input_channels};
         3'b100  : input_RAMS_reg[35063:35064-735*16] <= {input_RAMS_reg[35031:35064-735*16],input_channels};
         endcase
              if (counter_first_phase == {1'b0,input_features[8:1]} - 1)
                  begin
                      if (counter_internal_phase == 8'b00000111)
                          begin
                              start4 <= 1'b0;
                              start5 <= 1'b1;
                              counter_internal_phase <= 8'b00000000;
                              counter_first_phase <= 9'b000000000;
                          end
                      else
                          begin
                              counter_first_phase <= 9'b000000000;
                              counter_internal_phase <= counter_internal_phase + 1;
                          end
                  end
              else if (counter_first_phase == 9'b000000000)
                  if (counter_internal_phase == 8'b00000000)
                      begin
                          write_reg[486:323] <= {164{1'b1}};
                          write_addr_reg[26:18] <= 9'b000110100;
                          counter_first_phase <= counter_first_phase + 1;
                      end
                  else
                      begin
                          write_reg[486:323] <= {164{1'b1}};
                          write_addr_reg[26:18] <= 9'b000000100 + (counter_internal_phase - 1)*7;
                          counter_first_phase <= counter_first_phase + 1;
                      end
              else if (counter_first_phase == 9'b000000001)
                  if (counter_internal_phase == 8'b00000000)
                      begin
                          write_reg[486:323] <= {164{1'b0}};
                          counter_first_phase <= counter_first_phase + 1;
                      end
                  else
                      begin
                          write_reg[486:323] <= {164{1'b0}};
                          counter_first_phase <= counter_first_phase + 1;
                      end
              else
                  begin
                      counter_first_phase <= counter_first_phase + 1;
                  end
          end
    if (start5 == 1'b1)
               begin
               case(stage)
               3'b000  : input_RAMS_reg[35063:35064-90*16] <= {input_RAMS_reg[35031:35064-90*16],input_channels};
               3'b001  : input_RAMS_reg[35063:35064-180*16] <= {input_RAMS_reg[35031:35064-180*16],input_channels};
               3'b010  : input_RAMS_reg[35063:35064-360*16] <= {input_RAMS_reg[35031:35064-360*16],input_channels};
               3'b011  : input_RAMS_reg[35063:35064-720*16] <= {input_RAMS_reg[35031:35064-720*16],input_channels};
               3'b100  : input_RAMS_reg[35063:35064-735*16] <= {input_RAMS_reg[35031:35064-735*16],input_channels};
               endcase
                    if (counter_first_phase == {1'b0,input_features[8:1]} - 1)
                        begin
                            if (counter_internal_phase == 8'b00000111)
                                begin
                                    start5 <= 1'b0;
                                    start6 <= 1'b1;
                                    counter_internal_phase <= 8'b00000000;
                                    counter_first_phase <= 9'b000000000;
                                end
                            else
                                begin
                                    counter_first_phase <= 9'b000000000;
                                    counter_internal_phase <= counter_internal_phase + 1;
                                end
                        end
                    else if (counter_first_phase == 9'b000000000)
                        if (counter_internal_phase == 8'b00000000)
                            begin
                                write_reg[486:323] <= {164{1'b1}};
                                write_addr_reg[26:18] <= 9'b000110101;
                                counter_first_phase <= counter_first_phase + 1;
                            end
                        else
                            begin
                                write_reg[486:323] <= {164{1'b1}};
                                write_addr_reg[26:18] <= 9'b000000101 + (counter_internal_phase - 1)*7;
                                counter_first_phase <= counter_first_phase + 1;
                            end
                    else if (counter_first_phase == 9'b000000001)
                        if (counter_internal_phase == 8'b00000000)
                            begin
                                write_reg[486:323] <= {164{1'b0}};
                                counter_first_phase <= counter_first_phase + 1;
                            end
                        else
                            begin
                                write_reg[486:323] <= {164{1'b0}};
                                counter_first_phase <= counter_first_phase + 1;
                            end
                    else
                        begin
                            counter_first_phase <= counter_first_phase + 1;
                        end
                end
    if (start6 == 1'b1)
         begin
         case(stage)
         3'b000  : input_RAMS_reg[35063:35064-90*16] <= {input_RAMS_reg[35031:35064-90*16],input_channels};
         3'b001  : input_RAMS_reg[35063:35064-180*16] <= {input_RAMS_reg[35031:35064-180*16],input_channels};
         3'b010  : input_RAMS_reg[35063:35064-360*16] <= {input_RAMS_reg[35031:35064-360*16],input_channels};
         3'b011  : input_RAMS_reg[35063:35064-720*16] <= {input_RAMS_reg[35031:35064-720*16],input_channels};
         3'b100  : input_RAMS_reg[35063:35064-735*16] <= {input_RAMS_reg[35031:35064-735*16],input_channels};
         endcase
              if (counter_first_phase == {1'b0,input_features[8:1]} - 1)
                  begin
                      if (counter_internal_phase == 8'b00000111)
                          begin
                              start6 <= 1'b0;
                              start7 <= 1'b1;
                              counter_internal_phase <= 8'b00000000;
                              counter_first_phase <= 9'b000000000;
                          end
                      else
                          begin
                              counter_first_phase <= 9'b000000000;
                              counter_internal_phase <= counter_internal_phase + 1;
                          end
                  end
              else if (counter_first_phase == 9'b000000000)
                  if (counter_internal_phase == 8'b00000000)
                      begin
                          write_reg[486:323] <= {164{1'b1}};
                          write_addr_reg[26:18] <= 9'b000110110;
                          counter_first_phase <= counter_first_phase + 1;
                      end
                  else
                      begin
                          write_reg[486:323] <= {164{1'b1}};
                          write_addr_reg[26:18] <= 9'b000000110 + (counter_internal_phase - 1)*7;
                          counter_first_phase <= counter_first_phase + 1;
                      end
              else if (counter_first_phase == 9'b000000001)
                  if (counter_internal_phase == 8'b00000000)
                      begin
                          write_reg[486:323] <= {164{1'b0}};
                          counter_first_phase <= counter_first_phase + 1;
                      end
                  else
                      begin
                          write_reg[486:323] <= {164{1'b0}};
                          counter_first_phase <= counter_first_phase + 1;
                      end
              else
                  begin
                      counter_first_phase <= counter_first_phase + 1;
                  end
          end
    if (start7 == 1'b1)
        begin
        if (counter_first_phase == 9'b000000000)
            begin
                write_reg[486:323] <= {164{1'b1}};
                write_addr_reg[26:18] <= 9'b000110111;
                counter_first_phase <= counter_first_phase + 1;
            end
        else 
            
            begin
                start7 <= 1'b0;
                start12 <= 1'b1;
                counter_internal_phase <= 8'b00000000;
                counter_first_phase <= 9'b000000000;
                write_reg[486:323] <= {164{1'b0}};
            end
        end
    if (start12 == 1'b1)
        begin
        if (counter_first_phase == 9'b000000111)
          begin
              if (counter_internal_phase == 8'b00000110)
                  begin
                      start12 <= 1'b0;
                      startFSM <= 1'b1;
                      counter_internal_phase <= 8'b00000000;
                      counter_first_phase <= 9'b000000000;
                  end
              else
                  begin
                      counter_first_phase <= 9'b000000000;
                      counter_internal_phase <= counter_internal_phase + 1;
                  end
          end
         else if (counter_first_phase == 9'b000000000)
            begin
                write_reg[486:323] <= {164{1'b0}};
                read_addr_reg[26:18] <= 7*counter_internal_phase + 6;
                counter_first_phase <= counter_first_phase + 1;
            end
         else if (counter_first_phase == 9'b000000001)
            begin
                write_reg[486:323] <= {164{1'b0}};
                read_addr_reg[26:18] <= 7*counter_internal_phase + 5;
                counter_first_phase <= counter_first_phase + 1;
            end
         else if (counter_first_phase == 9'b000000010)
            begin
                write_reg[486:323] <= {164{1'b0}};
                input_RAMS_reg[35063:23256] <= output_RAMS[35063:23256];
                read_addr_reg[26:18] <= 7*counter_internal_phase + 4;
                counter_first_phase <= counter_first_phase + 1;
            end
         else if (counter_first_phase == 9'b000000011)
            begin
                write_reg[486:323] <= {164{1'b1}};
                write_addr_reg[26:18] <= 7*counter_internal_phase;
                input_RAMS_reg[35063:23256] <= output_RAMS[35063:23256];
                counter_first_phase <= counter_first_phase + 1;
            end
         else if (counter_first_phase == 9'b000000100)
            begin
                write_reg[486:323] <= {164{1'b1}};
                write_addr_reg[26:18] <= 7*counter_internal_phase + 1;
                input_RAMS_reg[35063:23256] <= output_RAMS[35063:23256];
                counter_first_phase <= counter_first_phase + 1;
            end
         else if (counter_first_phase == 9'b000000101)
            begin
                write_reg[486:323] <= {164{1'b1}};
                write_addr_reg[26:18] <= 7*counter_internal_phase + 2;
                counter_first_phase <= counter_first_phase + 1;
            end
         else if (counter_first_phase == 9'b000000110)
            begin
                write_reg[486:323] <= {164{1'b0}};
                counter_first_phase <= counter_first_phase + 1;
            end
        
        end
    if (startFSM == 1'b1)
        begin
        // Hier komt het feitelijke FSM-schema
        case(counterFSM)
        8'b00000000 :   begin
                        startUseful <= 1'b1;
                        counter_first_phase <= 9'b000000000;
                        counter_internal_phase <= 8'b00000000;
                        counter_internal_phase_1 <= 8'b00000000;
                        counter_internal_phase_2 <= 8'b00000000;
                        counter_internal_phase_3 <= 8'b00000000;
                        number_four_inputs <= 5'b00010;
                        number_four_outputs <= 5'b01000;
                        pointer <= 3'b000;
                        block_row_data <= 2'b00;
                        first_row_data <= 9'b000000000;
                        block_row_weights <= 2'b01;
                        first_row_weights <= 9'b111000000;
                        next_row_weights <= 9'b000000000;
                        counterFSM <= 8'b00000001;
                        end
        
        
        
        endcase
        
        
        end
    if (startUseful == 1'b1)
         begin
             case(counter_first_phase)
                         9'b000000000 :   begin  
                                             if (block_row_data == 2'b00)
                                                begin
                                                    if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                        begin
                                                            read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} - 9'b000000111;
                                                        end
                                                    else
                                                        begin
                                                            read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                        end
                                                end
                                             else if (block_row_data == 2'b01)
                                                begin
                                                    if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                        begin
                                                            read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} - 9'b000000111;
                                                        end
                                                    else
                                                        begin
                                                            read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                        end
                                                end
                                             else
                                                begin
                                                    if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                        begin
                                                            read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} - 9'b000000111;
                                                        end
                                                    else
                                                        begin
                                                            read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                        end
                                                end
                                             if (block_row_weights == 2'b00)
                                                begin
                                                    read_addr_reg[26:18] <= first_row_weights;
                                                end
                                             else if (block_row_weights == 2'b01)
                                                begin
                                                    read_addr_reg[17:9] <= first_row_weights;
                                                end
                                             else
                                                begin
                                                    read_addr_reg[8:0] <= first_row_weights;
                                                end
                                           
                                          
                                             
                                             counter_first_phase <= 9'b000000001;
                                             counter_internal_phase <= 8'b00000000;
                                         end
                         9'b000000001 :   begin  
                                              if (block_row_data == 2'b00)
                                                 begin
                                                     if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                         begin
                                                             read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                         end
                                                     else
                                                         begin
                                                             read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                         end
                                                 end
                                              else if (block_row_data == 2'b01)
                                                 begin
                                                     if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                         begin
                                                             read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                         end
                                                     else
                                                         begin
                                                             read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                         end
                                                 end
                                              else
                                                 begin
                                                     if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                         begin
                                                             read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                         end
                                                     else
                                                         begin
                                                             read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                         end
                                                 end
                                              if (block_row_weights == 2'b00)
                                                 begin
                                                     read_addr_reg[26:18] <= first_row_weights + 1;
                                                 end
                                              else if (block_row_weights == 2'b01)
                                                 begin
                                                     read_addr_reg[17:9] <= first_row_weights + 1;
                                                 end
                                              else
                                                 begin
                                                     read_addr_reg[8:0] <= first_row_weights + 1;
                                                 end
                                              
                                              counter_first_phase <= 9'b000000010;
                                              counter_internal_phase <= 8'b00000000;
                                          end
                          9'b000000010 :   begin  
                                            if (block_row_data == 2'b00)
                                               begin
                                                   if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                       begin
                                                           read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                       end
                                                   else
                                                       begin
                                                           read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                       end
                                               end
                                            else if (block_row_data == 2'b01)
                                               begin
                                                   if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                       begin
                                                           read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                       end
                                                   else
                                                       begin
                                                           read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                       end
                                               end
                                            else
                                               begin
                                                   if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                       begin
                                                           read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                       end
                                                   else
                                                       begin
                                                           read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                       end
                                               end
                                            if (block_row_weights == 2'b00)
                                               begin
                                                   read_addr_reg[26:18] <= first_row_weights + 2;
                                               end
                                            else if (block_row_weights == 2'b01)
                                               begin
                                                   read_addr_reg[17:9] <= first_row_weights + 2;
                                               end
                                            else
                                               begin
                                                   read_addr_reg[8:0] <= first_row_weights + 2;
                                               end
                                            
                                            counter_first_phase <= 9'b000000011;
                                            counter_internal_phase <= 8'b00000000;
                                        end
                        9'b000000011 :   begin  
                                            if (block_row_data == 2'b00)
                                               begin
                                                   case(stage)
                                                  3'b000   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                                  3'b001   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                                  3'b010   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                                  3'b011   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                                  3'b100   :   begin
                                                               case(type)
                                                               1'b0    :   begin
                                                                           case(layer)
                                                                           3'b000  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                           3'b001  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                           //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                           3'b011  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                           //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                           endcase
                                                                           end
                                                               1'b1    :   begin
                                                                           case(layer)
                                                                           3'b000  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                           3'b001  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                           //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                           3'b011  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                           //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                           endcase
                                                                           end
                                                               endcase
                                                               end
                                                  endcase
                                                   if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                       begin
                                                           read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                       end
                                                   else
                                                       begin
                                                           read_addr_reg[26:18] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000010101;
                                                       end
                                               end
                                            else if (block_row_data == 2'b01)
                                               begin
                                                   case(stage)
                                                     3'b000   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                     3'b001   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                     3'b010   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                     3'b011   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                     3'b100   :   begin
                                                                  case(type)
                                                                  1'b0    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                              3'b010  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                              //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                              endcase
                                                                              end
                                                                  1'b1    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                              3'b010  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                              //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                              endcase
                                                                              end
                                                                  endcase
                                                                  end
                                                 endcase
                                                   if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                       begin
                                                           read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                       end
                                                   else
                                                       begin
                                                           read_addr_reg[17:9] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000010101;
                                                       end
                                               end
                                            else
                                               begin
                                                   case(stage)
                                                     3'b000   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                     3'b001   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                     3'b010   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                     3'b011   :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                     3'b100   :   begin
                                                                  case(type)
                                                                  1'b0    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                              3'b100  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                              endcase
                                                                              end
                                                                  1'b1    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                              3'b100  :   temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                              endcase
                                                                              end
                                                                  endcase
                                                                  end
                                                 endcase
                                                   if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                       begin
                                                           read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                       end
                                                   else
                                                       begin
                                                           read_addr_reg[8:0] <= first_row_data + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000010101;
                                                       end
                                               end
                                            if (block_row_weights == 2'b00)
                                              begin
                                                  all_filters1 <= output_RAMS[35063-BITS:35064-197*BITS];
                                                  read_addr_reg[26:18] <= first_row_weights + 3;
                                              end
                                           else if (block_row_weights == 2'b01)
                                              begin
                                                  all_filters1 <= output_RAMS[23255-BITS:23256-197*BITS];
                                                  read_addr_reg[17:9] <= first_row_weights + 3;
                                              end
                                           else
                                              begin
                                                  all_filters1 <= output_RAMS[11591-BITS:11592-197*BITS];
                                                  read_addr_reg[8:0] <= first_row_weights + 3;
                                              end
                                            counter_first_phase <= 9'b000000100;
                                            counter_internal_phase <= 8'b00000000;
                                        end
                        9'b000000100 :   begin
                                        if (block_row_data == 2'b00)
                                            begin
                                            case(stage)
                                              3'b000   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                              3'b001   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                              3'b010   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                              3'b011   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                              3'b100   :   begin
                                                           case(type)
                                                           1'b0    :   begin
                                                                       case(layer)
                                                                       3'b000  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                       3'b001  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                       3'b011  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                       endcase
                                                                       end
                                                           1'b1    :   begin
                                                                       case(layer)
                                                                       3'b000  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                       3'b001  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                       3'b011  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                       endcase
                                                                       end
                                                           endcase
                                                           end
                                              endcase
                                            end
                                        else if (block_row_data == 2'b01)
                                            begin
                                            case(stage)
                                                 3'b000   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                 3'b001   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                 3'b010   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                 3'b011   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                 3'b100   :   begin
                                                              case(type)
                                                              1'b0    :   begin
                                                                          case(layer)
                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                          3'b010  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                          endcase
                                                                          end
                                                              1'b1    :   begin
                                                                          case(layer)
                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                          3'b010  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                          endcase
                                                                          end
                                                              endcase
                                                              end
                                             endcase
                                            end
                                        else
                                            begin
                                                case(stage)
                                                     3'b000   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                     3'b001   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                     3'b010   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                     3'b011   :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                     3'b100   :   begin
                                                                  case(type)
                                                                  1'b0    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                              3'b100  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                              endcase
                                                                              end
                                                                  1'b1    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                              3'b100  :   temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                              endcase
                                                                              end
                                                                  endcase
                                                                  end
                                                 endcase
                                            end
                                        if (block_row_weights == 2'b00)
                                           begin
                                               all_filters2 <= output_RAMS[35063-BITS:35064-197*BITS];
                                           end
                                        else if (block_row_weights == 2'b01)
                                           begin
                                               all_filters2 <= output_RAMS[23255-BITS:23256-197*BITS];
                                           end
                                        else
                                           begin
                                               all_filters2 <= output_RAMS[11591-BITS:11592-197*BITS];
                                           end
                                        counter_first_phase <= 9'b000001111;
                                        counter_internal_phase <= 8'b00000000;
                        
                                        end
                        9'b000001111 :   begin
                                            if (block_row_data == 2'b00)
                                                begin
                                                case(stage)
                                                  3'b000   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                                  3'b001   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                                  3'b010   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                                  3'b011   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                                  3'b100   :   begin
                                                               case(type)
                                                               1'b0    :   begin
                                                                           case(layer)
                                                                           3'b000  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                           3'b001  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                           //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                           3'b011  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                           //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                           endcase
                                                                           end
                                                               1'b1    :   begin
                                                                           case(layer)
                                                                           3'b000  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                           3'b001  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                           //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                           3'b011  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                           //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                           endcase
                                                                           end
                                                               endcase
                                                               end
                                                  endcase
                                                end
                                            else if (block_row_data == 2'b01)
                                                begin
                                                case(stage)
                                                     3'b000   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                     3'b001   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                     3'b010   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                     3'b011   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                     3'b100   :   begin
                                                                  case(type)
                                                                  1'b0    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                              3'b010  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                              //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                              endcase
                                                                              end
                                                                  1'b1    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                              3'b010  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                              //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                              endcase
                                                                              end
                                                                  endcase
                                                                  end
                                                 endcase
                                                end
                                            else
                                                begin
                                                    case(stage)
                                                         3'b000   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                         3'b001   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                         3'b010   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                         3'b011   :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                         3'b100   :   begin
                                                                      case(type)
                                                                      1'b0    :   begin
                                                                                  case(layer)
                                                                                  //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                                  //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                                  //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                                  //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                                  3'b100  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                                  endcase
                                                                                  end
                                                                      1'b1    :   begin
                                                                                  case(layer)
                                                                                  //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                                  //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                                  //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                                  //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                                  3'b100  :   temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                                  endcase
                                                                                  end
                                                                      endcase
                                                                      end
                                                     endcase
                                                end
                                            if (block_row_weights == 2'b00)
                                               begin
                                                   all_filters3 <= output_RAMS[35063-BITS:35064-197*BITS];
                                               end
                                            else if (block_row_weights == 2'b01)
                                               begin
                                                   all_filters3 <= output_RAMS[23255-BITS:23256-197*BITS];
                                               end
                                            else
                                               begin
                                                   all_filters3 <= output_RAMS[11591-BITS:11592-197*BITS];
                                               end
                                            counter_first_phase <= 9'b000000101;
                                            counter_internal_phase <= 8'b00000000;
                                            first_row_data_temp <= first_row_data;
                                            end
                        9'b000000101 :   begin
                                        if (block_row_data == 2'b00)
                                            begin
                                            case(stage)
                                              3'b000   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                              3'b001   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                              3'b010   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                              3'b011   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                              3'b100   :   begin
                                                           case(type)
                                                           1'b0    :   begin
                                                                       case(layer)
                                                                       3'b000  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                       3'b001  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                       3'b011  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                       endcase
                                                                       end
                                                           1'b1    :   begin
                                                                       case(layer)
                                                                       3'b000  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                       3'b001  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                       3'b011  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                       endcase
                                                                       end
                                                           endcase
                                                           end
                                              endcase
                                            end
                                        else if (block_row_data == 2'b01)
                                            begin
                                            case(stage)
                                                 3'b000   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                 3'b001   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                 3'b010   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                 3'b011   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                 3'b100   :   begin
                                                              case(type)
                                                              1'b0    :   begin
                                                                          case(layer)
                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                          3'b010  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                          endcase
                                                                          end
                                                              1'b1    :   begin
                                                                          case(layer)
                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                          3'b010  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                          endcase
                                                                          end
                                                              endcase
                                                              end
                                             endcase
                                            end
                                        else
                                            begin
                                                case(stage)
                                                     3'b000   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                     3'b001   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                     3'b010   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                     3'b011   :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                     3'b100   :   begin
                                                                  case(type)
                                                                  1'b0    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                              3'b100  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                              endcase
                                                                              end
                                                                  1'b1    :   begin
                                                                              case(layer)
                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                              3'b100  :   temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                              endcase
                                                                              end
                                                                  endcase
                                                                  end
                                                 endcase
                                            end
                                        if (block_row_weights == 2'b00)
                                           begin
                                               all_filters4 <= output_RAMS[35063-BITS:35064-197*BITS];
                                           end
                                        else if (block_row_weights == 2'b01)
                                           begin
                                               all_filters4 <= output_RAMS[23255-BITS:23256-197*BITS];
                                           end
                                        else
                                           begin
                                               all_filters4 <= output_RAMS[11591-BITS:11592-197*BITS];
                                           end
                                        counter_first_phase <= 9'b111111111;
                                        counter_internal_phase <= 8'b00000000;
                                        first_row_data_temp <= first_row_data;
                                        end
                        9'b111111111 :  begin
                                        counter_first_phase <= 9'b000000110;
                                        case(counter_internal_phase_1)
                                        8'b00000000 :   filter_weights_reg <= {all_filters1[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                all_filters1[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                all_filters1[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                all_filters1[(49-7*0)*BITS-1:(42-7*0)*BITS],
                                                                all_filters2[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                all_filters2[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                all_filters2[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                all_filters2[(49-7*0)*BITS-1:(42-7*0)*BITS]};
                                        8'b00000001 :   filter_weights_reg <= {all_filters1[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                all_filters1[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                all_filters1[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                all_filters1[(49-7*1)*BITS-1:(42-7*1)*BITS],
                                                                all_filters2[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                all_filters2[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                all_filters2[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                all_filters2[(49-7*1)*BITS-1:(42-7*1)*BITS]};
                                        8'b00000010 :   filter_weights_reg <= {all_filters1[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                all_filters1[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                all_filters1[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                all_filters1[(49-7*2)*BITS-1:(42-7*2)*BITS],
                                                                all_filters2[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                all_filters2[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                all_filters2[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                all_filters2[(49-7*2)*BITS-1:(42-7*2)*BITS]};
                                        8'b00000011 :   filter_weights_reg <= {all_filters1[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                all_filters1[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                all_filters1[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                all_filters1[(49-7*3)*BITS-1:(42-7*3)*BITS],
                                                                all_filters2[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                all_filters2[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                all_filters2[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                all_filters2[(49-7*3)*BITS-1:(42-7*3)*BITS]};
                                        8'b00000100 :   filter_weights_reg <= {all_filters1[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                all_filters1[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                all_filters1[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                all_filters1[(49-7*4)*BITS-1:(42-7*4)*BITS],
                                                                all_filters2[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                all_filters2[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                all_filters2[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                all_filters2[(49-7*4)*BITS-1:(42-7*4)*BITS]};
                                        8'b00000101 :   filter_weights_reg <= {all_filters1[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                all_filters1[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                all_filters1[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                all_filters1[(49-7*5)*BITS-1:(42-7*5)*BITS],
                                                                all_filters2[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                all_filters2[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                all_filters2[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                all_filters2[(49-7*5)*BITS-1:(42-7*5)*BITS]};
                                        8'b00000110 :   filter_weights_reg <= {all_filters1[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                all_filters1[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                all_filters1[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                all_filters1[(49-7*6)*BITS-1:(42-7*6)*BITS],
                                                                all_filters2[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                all_filters2[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                all_filters2[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                all_filters2[(49-7*6)*BITS-1:(42-7*6)*BITS]};
                                        endcase
                                        end
                        9'b000000110 :   begin
                                            if (continue == 1'b1)
                                            begin
                                            if (counter_internal_phase_1 == 8'b00000000)
                                                begin
                                                if (counter_internal_phase_2 == number_four_inputs - 1)
                                                    begin
                                                    case(counter_internal_phase)
                                                    9'b000000000 :  begin
                                                                    if (block_row_weights == 2'b00)
                                                                        begin
                                                                            read_addr_reg[26:18] <= first_row_weights + 4;
                                                                        end
                                                                     else if (block_row_weights == 2'b01)
                                                                        begin
                                                                            read_addr_reg[17:9] <= first_row_weights + 4;
                                                                        end
                                                                     else
                                                                        begin
                                                                            read_addr_reg[8:0] <= first_row_weights + 4;
                                                                        end
                                                                     first_row_weights <= first_row_weights + 4;
                                                                    end
                                                    9'b000000001 :  begin
                                                                    if (block_row_weights == 2'b00)
                                                                         begin
                                                                             read_addr_reg[26:18] <= first_row_weights + 1;
                                                                         end
                                                                      else if (block_row_weights == 2'b01)
                                                                         begin
                                                                             read_addr_reg[17:9] <= first_row_weights + 1;
                                                                         end
                                                                      else
                                                                         begin
                                                                             read_addr_reg[8:0] <= first_row_weights + 1;
                                                                         end
                                                    
                                                                    end
                                                    9'b000000010 :  begin
                                                                    if (block_row_weights == 2'b00)
                                                                           begin
                                                                               read_addr_reg[26:18] <= first_row_weights + 2;
                                                                           end
                                                                        else if (block_row_weights == 2'b01)
                                                                           begin
                                                                               read_addr_reg[17:9] <= first_row_weights + 2;
                                                                           end
                                                                        else
                                                                           begin
                                                                               read_addr_reg[8:0] <= first_row_weights + 2;
                                                                           end
                                                                    end
                                                    9'b000000011 :  begin
                                                                    if (block_row_weights == 2'b00)
                                                                          begin
                                                                              all_filters1_temp <= output_RAMS[35063-BITS:35064-197*BITS];
                                                                              read_addr_reg[26:18] <= first_row_weights + 3;
                                                                          end
                                                                       else if (block_row_weights == 2'b01)
                                                                          begin
                                                                              all_filters1_temp <= output_RAMS[23255-BITS:23256-197*BITS];
                                                                              read_addr_reg[17:9] <= first_row_weights + 3;
                                                                          end
                                                                       else
                                                                          begin
                                                                              all_filters1_temp <= output_RAMS[11591-BITS:11592-197*BITS];
                                                                              read_addr_reg[8:0] <= first_row_weights + 3;
                                                                          end
                                                                    end
                                                    9'b000000100 :  begin
                                                                        if (block_row_weights == 2'b00)
                                                                               begin
                                                                                   all_filters2_temp <= output_RAMS[35063-BITS:35064-197*BITS];
                                                                               end
                                                                            else if (block_row_weights == 2'b01)
                                                                               begin
                                                                                   all_filters2_temp <= output_RAMS[23255-BITS:23256-197*BITS];
                                                                               end
                                                                            else
                                                                               begin
                                                                                   all_filters2_temp <= output_RAMS[11591-BITS:11592-197*BITS];
                                                                               end
                                                                    end
                                                    9'b000000101 :  begin
                                                                    if (block_row_weights == 2'b00)
                                                                       begin
                                                                           all_filters3_temp <= output_RAMS[35063-BITS:35064-197*BITS];
                                                                       end
                                                                    else if (block_row_weights == 2'b01)
                                                                       begin
                                                                           all_filters3_temp <= output_RAMS[23255-BITS:23256-197*BITS];
                                                                       end
                                                                    else
                                                                       begin
                                                                           all_filters3_temp <= output_RAMS[11591-BITS:11592-197*BITS];
                                                                       end
                                                                    end
                                                    9'b000000110 :  begin
                                                                    if (block_row_weights == 2'b00)
                                                                       begin
                                                                           all_filters4_temp <= output_RAMS[35063-BITS:35064-197*BITS];
                                                                       end
                                                                    else if (block_row_weights == 2'b01)
                                                                       begin
                                                                           all_filters4_temp <= output_RAMS[23255-BITS:23256-197*BITS];
                                                                       end
                                                                    else
                                                                       begin
                                                                           all_filters4_temp <= output_RAMS[11591-BITS:11592-197*BITS];
                                                                       end
                                                                    end
                                                    endcase
                                                    end
                                                else
                                                    case(counter_internal_phase_2)
                                                    8'b00000000 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   begin
                                                                                            if (block_row_weights == 2'b00)
                                                                                                begin
                                                                                                    read_addr_reg[26:18] <= first_row_weights;
                                                                                                end
                                                                                             else if (block_row_weights == 2'b01)
                                                                                                begin
                                                                                                    read_addr_reg[17:9] <= first_row_weights;
                                                                                                end
                                                                                             else
                                                                                                begin
                                                                                                    read_addr_reg[8:0] <= first_row_weights;
                                                                                                end
                                                                                        end
                                                                    9'b000000001    :   begin
                                                                                            if (block_row_weights == 2'b00)
                                                                                                begin
                                                                                                    read_addr_reg[26:18] <= first_row_weights + 1;
                                                                                                end
                                                                                             else if (block_row_weights == 2'b01)
                                                                                                begin
                                                                                                    read_addr_reg[17:9] <= first_row_weights + 1;
                                                                                                end
                                                                                             else
                                                                                                begin
                                                                                                    read_addr_reg[8:0] <= first_row_weights + 1;
                                                                                                end
                                                                                        end
                                                                    9'b000000010 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                           begin
                                                                                               read_addr_reg[26:18] <= first_row_weights + 2;
                                                                                           end
                                                                                        else if (block_row_weights == 2'b01)
                                                                                           begin
                                                                                               read_addr_reg[17:9] <= first_row_weights + 2;
                                                                                           end
                                                                                        else
                                                                                           begin
                                                                                               read_addr_reg[8:0] <= first_row_weights + 2;
                                                                                           end
                                                                                    end
                                                                    9'b000000011 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                          begin
                                                                                              all_filters1_temp <= output_RAMS[35063-3152:35064-6288];
                                                                                              read_addr_reg[26:18] <= first_row_weights + 3;
                                                                                          end
                                                                                       else if (block_row_weights == 2'b01)
                                                                                          begin
                                                                                              all_filters1_temp <= output_RAMS[23255-3152:23256-6288];
                                                                                              read_addr_reg[17:9] <= first_row_weights + 3;
                                                                                          end
                                                                                       else
                                                                                          begin
                                                                                              all_filters1_temp <= output_RAMS[11591-3152:11592-6288];
                                                                                              read_addr_reg[8:0] <= first_row_weights + 3;
                                                                                          end
                                                                                    end
                                                                    9'b000000100 :  begin
                                                                                        if (block_row_weights == 2'b00)
                                                                                               begin
                                                                                                   all_filters2_temp <= output_RAMS[35063-3152:35064-6288];
                                                                                               end
                                                                                            else if (block_row_weights == 2'b01)
                                                                                               begin
                                                                                                   all_filters2_temp <= output_RAMS[23255-3152:23256-6288];
                                                                                               end
                                                                                            else
                                                                                               begin
                                                                                                   all_filters2_temp <= output_RAMS[11591-3152:11592-6288];
                                                                                               end
                                                                                    end
                                                                    9'b000000101 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters3_temp <= output_RAMS[35063-3152:35064-6288];
                                                                                       end
                                                                                    else if (block_row_weights == 2'b01)
                                                                                       begin
                                                                                           all_filters3_temp <= output_RAMS[23255-3152:23256-6288];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters3_temp <= output_RAMS[11591-3152:11592-6288];
                                                                                       end
                                                                                    end
                                                                    9'b000000110 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters4_temp <= output_RAMS[35063-3152:35064-6288];
                                                                                       end
                                                                                    else if (block_row_weights == 2'b01)
                                                                                       begin
                                                                                           all_filters4_temp <= output_RAMS[23255-3152:23256-6288];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters4_temp <= output_RAMS[11591-3152:11592-6288];
                                                                                       end
                                                                                    end
                                                                    endcase
                                                                    end
                                                    8'b00000001 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   begin
                                                                                            if (block_row_weights == 2'b00)
                                                                                                begin
                                                                                                    read_addr_reg[26:18] <= first_row_weights;
                                                                                                end
                                                                                             else
                                                                                                begin
                                                                                                    read_addr_reg[8:0] <= first_row_weights;
                                                                                                end
                                                                                        end
                                                                    9'b000000001    :   begin
                                                                                            if (block_row_weights == 2'b00)
                                                                                                begin
                                                                                                    read_addr_reg[26:18] <= first_row_weights + 1;
                                                                                                end
                                                                                             else
                                                                                                begin
                                                                                                    read_addr_reg[8:0] <= first_row_weights + 1;
                                                                                                end
                                                                                        end
                                                                    9'b000000010 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                           begin
                                                                                               read_addr_reg[26:18] <= first_row_weights + 2;
                                                                                           end
                                                                                        else
                                                                                           begin
                                                                                               read_addr_reg[8:0] <= first_row_weights + 2;
                                                                                           end
                                                                                    end
                                                                    9'b000000011 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                          begin
                                                                                              all_filters1_temp <= output_RAMS[35063-6288:35064-9424];
                                                                                              read_addr_reg[26:18] <= first_row_weights + 3;
                                                                                          end
                                                                                       else
                                                                                          begin
                                                                                              all_filters1_temp <= output_RAMS[11591-6288:11592-9424];
                                                                                              read_addr_reg[8:0] <= first_row_weights + 3;
                                                                                          end
                                                                                    end
                                                                    9'b000000100 :  begin
                                                                                        if (block_row_weights == 2'b00)
                                                                                               begin
                                                                                                   all_filters2_temp <= output_RAMS[35063-6288:35064-9424];
                                                                                               end
                                                                                            else
                                                                                               begin
                                                                                                   all_filters2_temp <= output_RAMS[11591-6288:11592-9424];
                                                                                               end
                                                                                    end
                                                                    9'b000000101 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters3_temp <= output_RAMS[35063-6288:35064-9424];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters3_temp <= output_RAMS[11591-6288:11592-9424];
                                                                                       end
                                                                                    end
                                                                    9'b000000110 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters4_temp <= output_RAMS[35063-6288:35064-9424];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters4_temp <= output_RAMS[11591-6288:11592-9424];
                                                                                       end
                                                                                    end
                                                                    endcase
                                                                    end
                                                    8'b00000010 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   begin
                                                                                            if (block_row_weights == 2'b00)
                                                                                                begin
                                                                                                    read_addr_reg[26:18] <= first_row_weights;
                                                                                                end
                                                                                             else
                                                                                                begin
                                                                                                    read_addr_reg[8:0] <= first_row_weights;
                                                                                                end
                                                                                        end
                                                                    9'b000000001    :   begin
                                                                                            if (block_row_weights == 2'b00)
                                                                                                begin
                                                                                                    read_addr_reg[26:18] <= first_row_weights + 1;
                                                                                                end
                                                                                             else
                                                                                                begin
                                                                                                    read_addr_reg[8:0] <= first_row_weights + 1;
                                                                                                end
                                                                                        end
                                                                    9'b000000010 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                           begin
                                                                                               read_addr_reg[26:18] <= first_row_weights + 2;
                                                                                           end
                                                                                        else
                                                                                           begin
                                                                                               read_addr_reg[8:0] <= first_row_weights + 2;
                                                                                           end
                                                                                    end
                                                                    9'b000000011 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                          begin
                                                                                              all_filters1_temp[3135:3136-(11520-9424)] <= output_RAMS[35063-9424:35064-11520];
                                                                                              read_addr_reg[26:18] <= first_row_weights + 3;
                                                                                          end
                                                                                       else
                                                                                          begin
                                                                                              all_filters1_temp[3135:3136-(11520-9424)] <= output_RAMS[11591-9424:11592-11520];
                                                                                              read_addr_reg[8:0] <= first_row_weights + 3;
                                                                                          end
                                                                                    end
                                                                    9'b000000100 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                           begin
                                                                                               all_filters2_temp[3135:3136-(11520-9424)] <= output_RAMS[35063-9424:35064-11520];
                                                                                               read_addr_reg[26:18] <= first_row_weights + next_row_weights;
                                                                                           end
                                                                                        else
                                                                                           begin
                                                                                               all_filters2_temp[3135:3136-(11520-9424)] <= output_RAMS[11591-9424:11592-11520];
                                                                                               read_addr_reg[8:0] <= first_row_weights + next_row_weights;
                                                                                           end
                                                                                    end
                                                                    9'b000000101 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters3_temp[3135:3136-(11520-9424)] <= output_RAMS[35063-9424:35064-11520];
                                                                                           read_addr_reg[26:18] <= first_row_weights + next_row_weights + 1;
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters3_temp[3135:3136-(11520-9424)] <= output_RAMS[11591-9424:11592-11520];
                                                                                           read_addr_reg[8:0] <= first_row_weights + next_row_weights + 1;
                                                                                       end
                                                                                    end
                                                                    9'b000000110 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters4_temp[3135:3136-(11520-9424)] <= output_RAMS[35063-9424:35064-11520];
                                                                                           read_addr_reg[26:18] <= first_row_weights + next_row_weights + 2;
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters4_temp[3135:3136-(11520-9424)] <= output_RAMS[11591-9424:11592-11520];
                                                                                           read_addr_reg[8:0] <= first_row_weights + next_row_weights + 2;
                                                                                       end
                                                                                    end
                                                                    9'b000000111 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters1_temp[3135-(11520-9424):0] <= output_RAMS[35063:35064-1040];
                                                                                           read_addr_reg[26:18] <= first_row_weights + next_row_weights + 3;
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters1_temp[3135-(11520-9424):0] <= output_RAMS[11591:11592-1040];
                                                                                           read_addr_reg[8:0] <= first_row_weights + next_row_weights + 3;
                                                                                       end
                                                                                    end
                                                                    9'b000001000 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters2_temp[3135-(11520-9424):0] <= output_RAMS[35063:35064-1040];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters2_temp[3135-(11520-9424):0] <= output_RAMS[11591:11592-1040];
                                                                                       end
                                                                                    end
                                                                    9'b000001001 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters3_temp[3135-(11520-9424):0] <= output_RAMS[35063:35064-1040];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters3_temp[3135-(11520-9424):0] <= output_RAMS[11591:11592-1040];
                                                                                       end
                                                                                    end
                                                                    9'b000001010 :  begin
                                                                                    if (block_row_weights == 2'b00)
                                                                                       begin
                                                                                           all_filters4_temp[3135-(11520-9424):0] <= output_RAMS[35063:35064-1040];
                                                                                       end
                                                                                    else
                                                                                       begin
                                                                                           all_filters4_temp[3135-(11520-9424):0] <= output_RAMS[11591:11592-1040];
                                                                                       end
                                                                                    end
                                                                    endcase
                                                                    end
                                                    8'b00000011 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-1040:11592-4176];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-1040:11592-4176];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-1040:11592-4176];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-1040:11592-4176];
                                                                    endcase
                                                                    end
                                                    8'b00000100 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-4176:11592-7312];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-4176:11592-7312];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-4176:11592-7312];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-4176:11592-7312];
                                                                    endcase
                                                                    end
                                                    8'b00000101 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-7312:11592-10448];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-7312:11592-10448];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-7312:11592-10448];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-7312:11592-10448];
                                                                    endcase
                                                                    end
                                                    8'b00000110 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp[3135:3136-(11520-10448)] <= output_RAMS[11591-10448:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   begin
                                                                                            all_filters2_temp[3135:3136-(11520-10448)] <= output_RAMS[11591-10448:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000101    :   begin
                                                                                            all_filters3_temp[3135:3136-(11520-10448)] <= output_RAMS[11591-10448:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 1 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000110    :   begin
                                                                                            all_filters4_temp[3135:3136-(11520-10448)] <= output_RAMS[11591-10448:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 2 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000111    :   begin
                                                                                            all_filters1_temp[2063:0] <= output_RAMS[11591:11592-2064];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000001000    :   all_filters2_temp[2063:0] <= output_RAMS[11591:11592-2064];
                                                                    9'b000001001    :   all_filters3_temp[2063:0] <= output_RAMS[11591:11592-2064];
                                                                    9'b000001010    :   all_filters4_temp[2063:0] <= output_RAMS[11591:11592-2064];
                                                                    endcase
                                                                    end
                                                    8'b00000111 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 2*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 2*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 2*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-2064:11592-5200];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-2064:11592-5200];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-2064:11592-5200];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-2064:11592-5200];
                                                                    endcase
                                                                    end
                                                    8'b00001000 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 2*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 2*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 2*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-5200:11592-8336];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-5200:11592-8336];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-5200:11592-8336];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-5200:11592-8336];
                                                                    endcase
                                                                    end
                                                    8'b00001001 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 2*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 2*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 2*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-8336:11592-11472];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-8336:11592-11472];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-8336:11592-11472];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-8336:11592-11472];
                                                                    endcase
                                                                    end
                                                    8'b00001010 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 2*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 2*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 2*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp[3135:3136-(11520-11472)] <= output_RAMS[11591-11472:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 2*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   begin
                                                                                            all_filters2_temp[3135:3136-(11520-11472)] <= output_RAMS[11591-11472:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3*next_row_weights;
                                                                                        end
                                                                    9'b000000101    :   begin
                                                                                            all_filters3_temp[3135:3136-(11520-11472)] <= output_RAMS[11591-11472:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 1 + 3*next_row_weights;
                                                                                        end
                                                                    9'b000000110    :   begin
                                                                                            all_filters4_temp[3135:3136-(11520-11472)] <= output_RAMS[11591-11472:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 2 + 3*next_row_weights;
                                                                                        end
                                                                    9'b000000111    :   begin
                                                                                            all_filters1_temp[3087:0] <= output_RAMS[11591:11592-3088];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 3*next_row_weights;
                                                                                        end
                                                                    9'b000001000    :   all_filters2_temp[3087:0] <= output_RAMS[11591:11592-3088];
                                                                    9'b000001001    :   all_filters3_temp[3087:0] <= output_RAMS[11591:11592-3088];
                                                                    9'b000001010    :   all_filters4_temp[3087:0] <= output_RAMS[11591:11592-3088];
                                                                    endcase
                                                                    end
                                                    8'b00001011 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 3*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 3*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 3*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-3088:11592-6224];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 3*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-3088:11592-6224];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-3088:11592-6224];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-3088:11592-6224];
                                                                    endcase
                                                                    end
                                                    8'b00001100 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 3*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 3*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 3*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-6224:11592-9360];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 3*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-6224:11592-9360];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-6224:11592-9360];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-6224:11592-9360];
                                                                    endcase
                                                                    end
                                                    8'b00001101 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 3*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 3*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 3*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp[3135:3136-(11520-9360)] <= output_RAMS[11591-9360:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 3*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   begin
                                                                                            all_filters2_temp[3135:3136-(11520-9360)] <= output_RAMS[11591-9360:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 4*next_row_weights;
                                                                                        end
                                                                    9'b000000101    :   begin
                                                                                            all_filters3_temp[3135:3136-(11520-9360)] <= output_RAMS[11591-9360:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 1 + 4*next_row_weights;
                                                                                        end
                                                                    9'b000000110    :   begin
                                                                                            all_filters4_temp[3135:3136-(11520-9360)] <= output_RAMS[11591-9360:0];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 2 + 4*next_row_weights;
                                                                                        end
                                                                    9'b000000111    :   begin
                                                                                            all_filters1_temp[975:0] <= output_RAMS[11591:11592-976];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 4*next_row_weights;
                                                                                        end
                                                                    9'b000001000    :   all_filters2_temp[975:0] <= output_RAMS[11591:11592-976];
                                                                    9'b000001001    :   all_filters3_temp[975:0] <= output_RAMS[11591:11592-976];
                                                                    9'b000001010    :   all_filters4_temp[975:0] <= output_RAMS[11591:11592-976];
                                                                    endcase
                                                                    end
                                                    8'b00001110 :   begin
                                                                    case(counter_internal_phase)
                                                                    9'b000000000    :   read_addr_reg[8:0] <= first_row_weights + 4*next_row_weights;
                                                                    9'b000000001    :   read_addr_reg[8:0] <= first_row_weights + 1 + 4*next_row_weights;
                                                                    9'b000000010    :   read_addr_reg[8:0] <= first_row_weights + 2 + 4*next_row_weights;
                                                                    9'b000000011    :   begin
                                                                                            all_filters1_temp <= output_RAMS[11591-976:11592-4112];
                                                                                            read_addr_reg[8:0] <= first_row_weights + 3 + 4*next_row_weights;
                                                                                        end
                                                                    9'b000000100    :   all_filters2_temp <= output_RAMS[11591-976:11592-4112];
                                                                    9'b000000101    :   all_filters3_temp <= output_RAMS[11591-976:11592-4112];
                                                                    9'b000000110    :   all_filters4_temp <= output_RAMS[11591-976:11592-4112];
                                                                    endcase
                                                                    end
                                                    endcase
                                                end
                                            if (counter_internal_phase == 8'b00000000)
                                                begin
                                                    if (block_row_data == 2'b00)
                                                        begin
                                                            if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                                begin
                                                                    read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} - 9'b000000111;
                                                                end
                                                            else
                                                                begin
                                                                    read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                                end
                                                        end
                                                     else if (block_row_data == 2'b01)
                                                        begin
                                                            if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                                begin
                                                                    read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} - 9'b000000111;
                                                                end
                                                            else
                                                                begin
                                                                    read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                                end
                                                        end
                                                     else
                                                        begin
                                                            if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                                begin
                                                                    read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} - 9'b000000111;
                                                                end
                                                            else
                                                                begin
                                                                    read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                                end
                                                        end
                                                     
                                                end
                                            else if (counter_internal_phase == 8'b00000001)
                                                begin
                                                    if (block_row_data == 2'b00)
                                                         begin
                                                             if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                                 begin
                                                                     read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                                 end
                                                             else
                                                                 begin
                                                                     read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                                 end
                                                         end
                                                      else if (block_row_data == 2'b01)
                                                         begin
                                                             if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                                 begin
                                                                     read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                                 end
                                                             else
                                                                 begin
                                                                     read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                                 end
                                                         end
                                                      else
                                                         begin
                                                             if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                                 begin
                                                                     read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1};
                                                                 end
                                                             else
                                                                 begin
                                                                     read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                                 end
                                                         end
                                                end
                                            else if (counter_internal_phase == 8'b00000010)
                                                begin
                                                    if (block_row_data == 2'b00)
                                                       begin
                                                           if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                               begin
                                                                   read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                               end
                                                           else
                                                               begin
                                                                   read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                               end
                                                       end
                                                    else if (block_row_data == 2'b01)
                                                       begin
                                                           if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                               begin
                                                                   read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                               end
                                                           else
                                                               begin
                                                                   read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                               end
                                                       end
                                                    else
                                                       begin
                                                           if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                               begin
                                                                   read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000000111;
                                                               end
                                                           else
                                                               begin
                                                                   read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                               end
                                                       end
                                                end
                                            else if (counter_internal_phase == 8'b00000011)
                                                begin
                                                    if (block_row_data == 2'b00)
                                                       begin
                                                           case(stage)
                                                          3'b000   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                                          3'b001   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                                          3'b010   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                                          3'b011   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                                          3'b100   :   begin
                                                                       case(type)
                                                                       1'b0    :   begin
                                                                                   case(layer)
                                                                                   3'b000  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                                   3'b001  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                                   //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                                   3'b011  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                                   //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                                   endcase
                                                                                   end
                                                                       1'b1    :   begin
                                                                                   case(layer)
                                                                                   3'b000  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                                   3'b001  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                                   //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                                   3'b011  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                                   //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                                   endcase
                                                                                   end
                                                                       endcase
                                                                       end
                                                          endcase
                                                           if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                               begin
                                                                   read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                               end
                                                           else
                                                               begin
                                                                   read_addr_reg[26:18] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000010101;
                                                               end
                                                       end
                                                    else if (block_row_data == 2'b01)
                                                       begin
                                                           case(stage)
                                                             3'b000   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                             3'b001   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                             3'b010   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                             3'b011   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                             3'b100   :   begin
                                                                          case(type)
                                                                          1'b0    :   begin
                                                                                      case(layer)
                                                                                      //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                                      //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                                      3'b010  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                                      //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                                      //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                                      endcase
                                                                                      end
                                                                          1'b1    :   begin
                                                                                      case(layer)
                                                                                      //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                                      //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                                      3'b010  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                                      //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                                      //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                                      endcase
                                                                                      end
                                                                          endcase
                                                                          end
                                                         endcase
                                                           if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                               begin
                                                                   read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                               end
                                                           else
                                                               begin
                                                                   read_addr_reg[17:9] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000010101;
                                                               end
                                                       end
                                                    else
                                                       begin
                                                           case(stage)
                                                             3'b000   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                             3'b001   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                             3'b010   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                             3'b011   :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                             3'b100   :   begin
                                                                          case(type)
                                                                          1'b0    :   begin
                                                                                      case(layer)
                                                                                      //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                                      //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                                      //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                                      //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                                      3'b100  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                                      endcase
                                                                                      end
                                                                          1'b1    :   begin
                                                                                      case(layer)
                                                                                      //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                                      //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                                      //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                                      //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                                      3'b100  :   temp_in_1_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                                      endcase
                                                                                      end
                                                                          endcase
                                                                          end
                                                         endcase
                                                           if ({5'b0,pointer} + counter_internal_phase_1 >= 8'b00000111)
                                                               begin
                                                                   read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000001110;
                                                               end
                                                           else
                                                               begin
                                                                   read_addr_reg[8:0] <= first_row_data_temp + {6'b0,pointer} + {1'b0,counter_internal_phase_1} + 9'b000010101;
                                                               end
                                                       end
                                                
                                                end
                                            else if (counter_internal_phase == 8'b00000100)
                                                begin
                                                if (block_row_data == 2'b00)
                                                    begin
                                                    case(stage)
                                                      3'b000   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                                      3'b001   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                                      3'b010   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                                      3'b011   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                                      3'b100   :   begin
                                                                   case(type)
                                                                   1'b0    :   begin
                                                                               case(layer)
                                                                               3'b000  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                               3'b001  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                               //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                               3'b011  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                               //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                               endcase
                                                                               end
                                                                   1'b1    :   begin
                                                                               case(layer)
                                                                               3'b000  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                               3'b001  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                               //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                               3'b011  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                               //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                               endcase
                                                                               end
                                                                   endcase
                                                                   end
                                                      endcase
                                                    end
                                                else if (block_row_data == 2'b01)
                                                    begin
                                                    case(stage)
                                                         3'b000   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                         3'b001   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                         3'b010   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                         3'b011   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                         3'b100   :   begin
                                                                      case(type)
                                                                      1'b0    :   begin
                                                                                  case(layer)
                                                                                  //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                                  //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                                  3'b010  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                                  //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                                  //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                                  endcase
                                                                                  end
                                                                      1'b1    :   begin
                                                                                  case(layer)
                                                                                  //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                                  //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                                  3'b010  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                                  //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                                  //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                                  endcase
                                                                                  end
                                                                      endcase
                                                                      end
                                                     endcase
                                                    end
                                                else
                                                    begin
                                                        case(stage)
                                                             3'b000   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                             3'b001   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                             3'b010   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                             3'b011   :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                             3'b100   :   begin
                                                                          case(type)
                                                                          1'b0    :   begin
                                                                                      case(layer)
                                                                                      //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                                      //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                                      //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                                      //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                                      3'b100  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                                      endcase
                                                                                      end
                                                                          1'b1    :   begin
                                                                                      case(layer)
                                                                                      //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                                      //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                                      //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                                      //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                                      3'b100  :   temp_in_2_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                                      endcase
                                                                                      end
                                                                          endcase
                                                                          end
                                                         endcase
                                                    end
                                                end
                                            else if (counter_internal_phase == 8'b00000101)
                                                begin
                                                    
                                                    if (block_row_data == 2'b00)
                                                        begin
                                                            case(stage)
                                                              3'b000   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                                              3'b001   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                                              3'b010   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                                              3'b011   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                                              3'b100   :   begin
                                                                           case(type)
                                                                           1'b0    :   begin
                                                                                       case(layer)
                                                                                       3'b000  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                                       3'b001  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                                       3'b011  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                                       endcase
                                                                                       end
                                                                           1'b1    :   begin
                                                                                       case(layer)
                                                                                       3'b000  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                                       3'b001  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                                       3'b011  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                                       endcase
                                                                                       end
                                                                           endcase
                                                                           end
                                                              endcase
                                                            end
                                                        else if (block_row_data == 2'b01)
                                                            begin
                                                            case(stage)
                                                                 3'b000   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                                 3'b001   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                                 3'b010   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                                 3'b011   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                                 3'b100   :   begin
                                                                              case(type)
                                                                              1'b0    :   begin
                                                                                          case(layer)
                                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                                          3'b010  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                                          endcase
                                                                                          end
                                                                              1'b1    :   begin
                                                                                          case(layer)
                                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                                          3'b010  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                                          endcase
                                                                                          end
                                                                              endcase
                                                                              end
                                                             endcase
                                                            end
                                                        else
                                                            begin
                                                                case(stage)
                                                                     3'b000   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                                     3'b001   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                                     3'b010   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                                     3'b011   :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                                     3'b100   :   begin
                                                                                  case(type)
                                                                                  1'b0    :   begin
                                                                                              case(layer)
                                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                                              3'b100  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                                              endcase
                                                                                              end
                                                                                  1'b1    :   begin
                                                                                              case(layer)
                                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                                              3'b100  :   temp_in_3_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                                              endcase
                                                                                              end
                                                                                  endcase
                                                                                  end
                                                                 endcase
                                                            end
                                                    
                                                end
                                            end
                                            else if (counter_internal_phase == 8'b00000110)
                                                begin
                                                    
                                                    if (block_row_data == 2'b00)
                                                        begin
                                                            case(stage)
                                                              3'b000   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE0],output_RAMS[35064-STAGE0+31:35064-STAGE0+16],output_RAMS[35064-STAGE0+47:35064-STAGE0+32],output_RAMS[35064-STAGE0+63:35064-STAGE0+48]};
                                                              3'b001   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE1],output_RAMS[35064-STAGE1+31:35064-STAGE1+16],output_RAMS[35064-STAGE1+47:35064-STAGE1+32],output_RAMS[35064-STAGE1+63:35064-STAGE1+48]};
                                                              3'b010   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE2],output_RAMS[35064-STAGE2+31:35064-STAGE2+16],output_RAMS[35064-STAGE2+47:35064-STAGE2+32],output_RAMS[35064-STAGE2+63:35064-STAGE2+48]};
                                                              3'b011   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3],output_RAMS[35064-STAGE3+31:35064-STAGE3+16],output_RAMS[35064-STAGE3+47:35064-STAGE3+32],output_RAMS[35064-STAGE3+63:35064-STAGE3+48]};
                                                              3'b100   :   begin
                                                                           case(type)
                                                                           1'b0    :   begin
                                                                                       case(layer)
                                                                                       3'b000  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-5*PADDING*BITS]};
                                                                                       3'b001  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-4*PADDING*BITS]};
                                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-3*PADDING*BITS]};
                                                                                       3'b011  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-2*PADDING*BITS]};
                                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35015:35000],output_RAMS[35031:35016],output_RAMS[35047:35032],output_RAMS[35063:35064-STAGE3-1*PADDING*BITS]};
                                                                                       endcase
                                                                                       end
                                                                           1'b1    :   begin
                                                                                       case(layer)
                                                                                       3'b000  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-738*16] <= {output_RAMS[35063:35064-STAGE3-5*PADDING*BITS],output_RAMS[35064-STAGE3-5*PADDING*BITS+31:35064-STAGE3-5*PADDING*BITS+16],output_RAMS[35064-STAGE3-5*PADDING*BITS+47:35064-STAGE3-5*PADDING*BITS+32],output_RAMS[35064-STAGE3-5*PADDING*BITS+63:35064-STAGE3-5*PADDING*BITS+48]};
                                                                                       3'b001  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-735*16] <= {output_RAMS[35063:35064-STAGE3-4*PADDING*BITS],output_RAMS[35064-STAGE3-4*PADDING*BITS+31:35064-STAGE3-4*PADDING*BITS+16],output_RAMS[35064-STAGE3-4*PADDING*BITS+47:35064-STAGE3-4*PADDING*BITS+32],output_RAMS[35064-STAGE3-4*PADDING*BITS+63:35064-STAGE3-4*PADDING*BITS+48]};
                                                                                       //3'b010  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-3*PADDING*BITS],output_RAMS[35064-STAGE3-3*PADDING*BITS+31:35064-STAGE3-3*PADDING*BITS+16],output_RAMS[35064-STAGE3-3*PADDING*BITS+47:35064-STAGE3-3*PADDING*BITS+32],output_RAMS[35064-STAGE3-3*PADDING*BITS+63:35064-STAGE3-3*PADDING*BITS+48]};
                                                                                       3'b011  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-729*16] <= {output_RAMS[35063:35064-STAGE3-2*PADDING*BITS],output_RAMS[35064-STAGE3-2*PADDING*BITS+31:35064-STAGE3-2*PADDING*BITS+16],output_RAMS[35064-STAGE3-2*PADDING*BITS+47:35064-STAGE3-2*PADDING*BITS+32],output_RAMS[35064-STAGE3-2*PADDING*BITS+63:35064-STAGE3-2*PADDING*BITS+48]};
                                                                                       //3'b100  :   temp_in_1 <= {output_RAMS[35063:35064-STAGE3-1*PADDING*BITS],output_RAMS[35064-STAGE3-1*PADDING*BITS+31:35064-STAGE3-1*PADDING*BITS+16],output_RAMS[35064-STAGE3-1*PADDING*BITS+47:35064-STAGE3-1*PADDING*BITS+32],output_RAMS[35064-STAGE3-1*PADDING*BITS+63:35064-STAGE3-1*PADDING*BITS+48]};
                                                                                       endcase
                                                                                       end
                                                                           endcase
                                                                           end
                                                              endcase
                                                            end
                                                        else if (block_row_data == 2'b01)
                                                            begin
                                                            case(stage)
                                                                 3'b000   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE0],output_RAMS[23256-STAGE0+31:23256-STAGE0+16],output_RAMS[23256-STAGE0+47:23256-STAGE0+32],output_RAMS[23256-STAGE0+63:23256-STAGE0+48]};
                                                                 3'b001   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE1],output_RAMS[23256-STAGE1+31:23256-STAGE1+16],output_RAMS[23256-STAGE1+47:23256-STAGE1+32],output_RAMS[23256-STAGE1+63:23256-STAGE1+48]};
                                                                 3'b010   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE2],output_RAMS[23256-STAGE2+31:23256-STAGE2+16],output_RAMS[23256-STAGE2+47:23256-STAGE2+32],output_RAMS[23256-STAGE2+63:23256-STAGE2+48]};
                                                                 3'b011   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3],output_RAMS[23256-STAGE3+31:23256-STAGE3+16],output_RAMS[23256-STAGE3+47:23256-STAGE3+32],output_RAMS[23256-STAGE3+63:23256-STAGE3+48]};
                                                                 3'b100   :   begin
                                                                              case(type)
                                                                              1'b0    :   begin
                                                                                          case(layer)
                                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-5*PADDING*BITS]};
                                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-4*PADDING*BITS]};
                                                                                          3'b010  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-3*PADDING*BITS]};
                                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-2*PADDING*BITS]};
                                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23207:23192],output_RAMS[23223:23208],output_RAMS[23239:23224],output_RAMS[23255:23256-STAGE3-1*PADDING*BITS]};
                                                                                          endcase
                                                                                          end
                                                                              1'b1    :   begin
                                                                                          case(layer)
                                                                                          //3'b000  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-5*PADDING*BITS],output_RAMS[23256-STAGE3-5*PADDING*BITS+31:23256-STAGE3-5*PADDING*BITS+16],output_RAMS[23256-STAGE3-5*PADDING*BITS+47:23256-STAGE3-5*PADDING*BITS+32],output_RAMS[23256-STAGE3-5*PADDING*BITS+63:23256-STAGE3-5*PADDING*BITS+48]};
                                                                                          //3'b001  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-4*PADDING*BITS],output_RAMS[23256-STAGE3-4*PADDING*BITS+31:23256-STAGE3-4*PADDING*BITS+16],output_RAMS[23256-STAGE3-4*PADDING*BITS+47:23256-STAGE3-4*PADDING*BITS+32],output_RAMS[23256-STAGE3-4*PADDING*BITS+63:23256-STAGE3-4*PADDING*BITS+48]};
                                                                                          3'b010  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-732*16] <= {output_RAMS[23255:23256-STAGE3-3*PADDING*BITS],output_RAMS[23256-STAGE3-3*PADDING*BITS+31:23256-STAGE3-3*PADDING*BITS+16],output_RAMS[23256-STAGE3-3*PADDING*BITS+47:23256-STAGE3-3*PADDING*BITS+32],output_RAMS[23256-STAGE3-3*PADDING*BITS+63:23256-STAGE3-3*PADDING*BITS+48]};
                                                                                          //3'b011  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-2*PADDING*BITS],output_RAMS[23256-STAGE3-2*PADDING*BITS+31:23256-STAGE3-2*PADDING*BITS+16],output_RAMS[23256-STAGE3-2*PADDING*BITS+47:23256-STAGE3-2*PADDING*BITS+32],output_RAMS[23256-STAGE3-2*PADDING*BITS+63:23256-STAGE3-2*PADDING*BITS+48]};
                                                                                          //3'b100  :   temp_in_1 <= {output_RAMS[23255:23256-STAGE3-1*PADDING*BITS],output_RAMS[23256-STAGE3-1*PADDING*BITS+31:23256-STAGE3-1*PADDING*BITS+16],output_RAMS[23256-STAGE3-1*PADDING*BITS+47:23256-STAGE3-1*PADDING*BITS+32],output_RAMS[23256-STAGE3-1*PADDING*BITS+63:23256-STAGE3-1*PADDING*BITS+48]};
                                                                                          endcase
                                                                                          end
                                                                              endcase
                                                                              end
                                                             endcase
                                                            end
                                                        else
                                                            begin
                                                                case(stage)
                                                                     3'b000   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-96*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE0],output_RAMS[11592-STAGE0+31:11592-STAGE0+16],output_RAMS[11592-STAGE0+47:11592-STAGE0+32],output_RAMS[11592-STAGE0+63:11592-STAGE0+48]};
                                                                     3'b001   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-186*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE1],output_RAMS[11592-STAGE1+31:11592-STAGE1+16],output_RAMS[11592-STAGE1+47:11592-STAGE1+32],output_RAMS[11592-STAGE1+63:11592-STAGE1+48]};
                                                                     3'b010   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-366*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE2],output_RAMS[11592-STAGE2+31:11592-STAGE2+16],output_RAMS[11592-STAGE2+47:11592-STAGE2+32],output_RAMS[11592-STAGE2+63:11592-STAGE2+48]};
                                                                     3'b011   :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3],output_RAMS[11592-STAGE3+31:11592-STAGE3+16],output_RAMS[11592-STAGE3+47:11592-STAGE3+32],output_RAMS[11592-STAGE3+63:11592-STAGE3+48]};
                                                                     3'b100   :   begin
                                                                                  case(type)
                                                                                  1'b0    :   begin
                                                                                              case(layer)
                                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-5*PADDING*BITS]};
                                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-4*PADDING*BITS]};
                                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-3*PADDING*BITS]};
                                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-2*PADDING*BITS]};
                                                                                              3'b100  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11543:11528],output_RAMS[11559:11544],output_RAMS[11575:11560],output_RAMS[11591:11592-STAGE3-1*PADDING*BITS]};
                                                                                              endcase
                                                                                              end
                                                                                  1'b1    :   begin
                                                                                              case(layer)
                                                                                              //3'b000  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-5*PADDING*BITS],output_RAMS[11592-STAGE3-5*PADDING*BITS+31:11592-STAGE3-5*PADDING*BITS+16],output_RAMS[11592-STAGE3-5*PADDING*BITS+47:11592-STAGE3-5*PADDING*BITS+32],output_RAMS[11592-STAGE3-5*PADDING*BITS+63:11592-STAGE3-5*PADDING*BITS+48]};
                                                                                              //3'b001  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-4*PADDING*BITS],output_RAMS[11592-STAGE3-4*PADDING*BITS+31:11592-STAGE3-4*PADDING*BITS+16],output_RAMS[11592-STAGE3-4*PADDING*BITS+47:11592-STAGE3-4*PADDING*BITS+32],output_RAMS[11592-STAGE3-4*PADDING*BITS+63:11592-STAGE3-4*PADDING*BITS+48]};
                                                                                              //3'b010  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-3*PADDING*BITS],output_RAMS[11592-STAGE3-3*PADDING*BITS+31:11592-STAGE3-3*PADDING*BITS+16],output_RAMS[11592-STAGE3-3*PADDING*BITS+47:11592-STAGE3-3*PADDING*BITS+32],output_RAMS[11592-STAGE3-3*PADDING*BITS+63:11592-STAGE3-3*PADDING*BITS+48]};
                                                                                              //3'b011  :   temp_in_1 <= {output_RAMS[11591:11592-STAGE3-2*PADDING*BITS],output_RAMS[11592-STAGE3-2*PADDING*BITS+31:11592-STAGE3-2*PADDING*BITS+16],output_RAMS[11592-STAGE3-2*PADDING*BITS+47:11592-STAGE3-2*PADDING*BITS+32],output_RAMS[11592-STAGE3-2*PADDING*BITS+63:11592-STAGE3-2*PADDING*BITS+48]};
                                                                                              3'b100  :   temp_in_4_temp[164*WIDTH_RAM-1:164*WIDTH_RAM-726*16] <= {output_RAMS[11591:11592-STAGE3-1*PADDING*BITS],output_RAMS[11592-STAGE3-1*PADDING*BITS+31:11592-STAGE3-1*PADDING*BITS+16],output_RAMS[11592-STAGE3-1*PADDING*BITS+47:11592-STAGE3-1*PADDING*BITS+32],output_RAMS[11592-STAGE3-1*PADDING*BITS+63:11592-STAGE3-1*PADDING*BITS+48]};
                                                                                              endcase
                                                                                              end
                                                                                  endcase
                                                                                  end
                                                                 endcase
                                                            end
                                                    
                                                end
                                            
                                            if (counter_internal_phase == iterations_each_row - 2)
                                                begin
                                                if (layer == 3'b00)
                                                    begin
                                                    if (counter_internal_phase_1 == 8'b00000110)
                                                        begin
                                                        all_filters1 <= all_filters1_temp;
                                                        all_filters2 <= all_filters2_temp;
                                                        all_filters3 <= all_filters3_temp;
                                                        all_filters4 <= all_filters4_temp;
                                                        end
                                                    end
                                                end
                                            if (counter_internal_phase == 2*iterations_each_row - 3)
                                                begin
                                                if (counter_internal_phase_1 == 8'b00000110)
                                                    begin
                                                    all_filters1 <= all_filters1_temp;
                                                    all_filters2 <= all_filters2_temp;
                                                    all_filters3 <= all_filters3_temp;
                                                    all_filters4 <= all_filters4_temp;
                                                    end
                                                    
                                                end
                                            if (counter_internal_phase == iterations_each_row - 1)
                                                begin
                                                    if (layer == 3'b100)
                                                        begin
                                                            temp_in_1 <= temp_in_1_temp;
                                                            temp_in_2 <= temp_in_2_temp;
                                                            temp_in_3 <= temp_in_3_temp;
                                                            if (stage != 3'b000)        // Hier stond eerst 100
                                                                begin
                                                                    temp_in_4 <= temp_in_4_temp;
                                                                end
                                                            counter_internal_phase <= 9'b000000000;
                                                            if (counter_internal_phase_1 == 8'b00000110)
                                                                begin
                                                                    counter_internal_phase_1 <= 8'b00000000;
                                                                    if (counter_internal_phase_2 == number_four_inputs - 2)
                                                                        begin
                                                                            if (counter_internal_phase_3 == number_four_outputs - 1)
                                                                                begin
                                                                                    counter_first_phase <= 9'b000000111;
                                                                                end
                                                                            else
                                                                                begin
                                                                                    first_row_data_temp <= first_row_data;
                                                                                    counter_internal_phase_3 <= counter_internal_phase_3 + 1;
                                                                                end
                                                                        end
                                                                    else if (counter_internal_phase_2 == number_four_inputs - 1)
                                                                        begin
                                                                            counter_internal_phase_2 <= 8'b00000000;
                                                                        end
                                                                    else
                                                                        begin
                                                                            first_row_data_temp <= first_row_data_temp + 9'b000011100;
                                                                            counter_internal_phase_2 <= counter_internal_phase_2 + 1;
                                                                        end
                                                                end
                                                            else
                                                                begin
                                                                    counter_internal_phase_1 <= counter_internal_phase_1 + 1;
                                                                end
                                                        case(counter_internal_phase_1)
                                                        8'b00000110 :   filter_weights_reg <= {all_filters1[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                                all_filters1[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                                all_filters1[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                                all_filters1[(49-7*0)*BITS-1:(42-7*0)*BITS],
                                                                                all_filters2[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                                all_filters2[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                                all_filters2[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                                all_filters2[(49-7*0)*BITS-1:(42-7*0)*BITS]};
                                                        8'b00000000 :   filter_weights_reg <= {all_filters1[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                                all_filters1[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                                all_filters1[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                                all_filters1[(49-7*1)*BITS-1:(42-7*1)*BITS],
                                                                                all_filters2[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                                all_filters2[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                                all_filters2[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                                all_filters2[(49-7*1)*BITS-1:(42-7*1)*BITS]};
                                                        8'b00000001 :   filter_weights_reg <= {all_filters1[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                                all_filters1[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                                all_filters1[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                                all_filters1[(49-7*2)*BITS-1:(42-7*2)*BITS],
                                                                                all_filters2[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                                all_filters2[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                                all_filters2[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                                all_filters2[(49-7*2)*BITS-1:(42-7*2)*BITS]};
                                                        8'b00000010 :   filter_weights_reg <= {all_filters1[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                                all_filters1[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                                all_filters1[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                                all_filters1[(49-7*3)*BITS-1:(42-7*3)*BITS],
                                                                                all_filters2[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                                all_filters2[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                                all_filters2[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                                all_filters2[(49-7*3)*BITS-1:(42-7*3)*BITS]};
                                                        8'b00000011 :   filter_weights_reg <= {all_filters1[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                                all_filters1[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                                all_filters1[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                                all_filters1[(49-7*4)*BITS-1:(42-7*4)*BITS],
                                                                                all_filters2[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                                all_filters2[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                                all_filters2[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                                all_filters2[(49-7*4)*BITS-1:(42-7*4)*BITS]};
                                                        8'b00000100 :   filter_weights_reg <= {all_filters1[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                                all_filters1[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                                all_filters1[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                                all_filters1[(49-7*5)*BITS-1:(42-7*5)*BITS],
                                                                                all_filters2[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                                all_filters2[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                                all_filters2[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                                all_filters2[(49-7*5)*BITS-1:(42-7*5)*BITS]};
                                                        8'b00000101 :   filter_weights_reg <= {all_filters1[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                                all_filters1[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                                all_filters1[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                                all_filters1[(49-7*6)*BITS-1:(42-7*6)*BITS],
                                                                                all_filters2[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                                all_filters2[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                                all_filters2[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                                all_filters2[(49-7*6)*BITS-1:(42-7*6)*BITS]};
                                                        endcase
                                                        end
                                                    else
                                                        begin
                                                            counter_internal_phase <= counter_internal_phase + 1;
                                                            case(stage)
                                                            3'b000  :   begin
                                                                        temp_in_1 <= {temp_in_1[5*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-5*(FEATURES-KERNEL+1)]};
                                                                        temp_in_2 <= {temp_in_2[5*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-5*(FEATURES-KERNEL+1)]};
                                                                        temp_in_3 <= {temp_in_3[5*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-5*(FEATURES-KERNEL+1)]};
                                                                        temp_in_4 <= {temp_in_4[5*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-5*(FEATURES-KERNEL+1)]};
                                                                        end
                                                            3'b001  :   begin
                                                                        temp_in_1 <= {temp_in_1[11*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-11*(FEATURES-KERNEL+1)]};
                                                                        temp_in_2 <= {temp_in_2[11*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-11*(FEATURES-KERNEL+1)]};
                                                                        temp_in_3 <= {temp_in_3[11*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-11*(FEATURES-KERNEL+1)]};
                                                                        temp_in_4 <= {temp_in_4[11*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-11*(FEATURES-KERNEL+1)]};
                                                                        end
                                                            3'b010  :   begin
                                                                        temp_in_1 <= {temp_in_1[23*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-23*(FEATURES-KERNEL+1)]};
                                                                        temp_in_2 <= {temp_in_2[23*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-23*(FEATURES-KERNEL+1)]};
                                                                        temp_in_3 <= {temp_in_3[23*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-23*(FEATURES-KERNEL+1)]};
                                                                        temp_in_4 <= {temp_in_4[23*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-23*(FEATURES-KERNEL+1)]};
                                                                        end
                                                            3'b011  :   begin
                                                                        temp_in_1 <= {temp_in_1[47*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-47*(FEATURES-KERNEL+1)]};
                                                                        temp_in_2 <= {temp_in_2[47*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-47*(FEATURES-KERNEL+1)]};
                                                                        temp_in_3 <= {temp_in_3[47*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-47*(FEATURES-KERNEL+1)]};
                                                                        temp_in_4 <= {temp_in_4[47*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-47*(FEATURES-KERNEL+1)]};
                                                                        end
                                                            3'b100  :   begin
                                                                        temp_in_1 <= {temp_in_1[48*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-48*(FEATURES-KERNEL+1)]};
                                                                        temp_in_2 <= {temp_in_2[48*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-48*(FEATURES-KERNEL+1)]};
                                                                        temp_in_3 <= {temp_in_3[48*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-48*(FEATURES-KERNEL+1)]};
                                                                        temp_in_4 <= {temp_in_4[48*(FEATURES-KERNEL+1)*BITS-1:0],temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-48*(FEATURES-KERNEL+1)]};
                                                                        end                                                                    
                                                            
                                                            endcase
                                                            case(counter_internal_phase_1)
                                                            8'b00000000 :   filter_weights_reg <= {all_filters3[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                                    all_filters3[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                                    all_filters3[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                                    all_filters3[(49-7*0)*BITS-1:(42-7*0)*BITS],
                                                                                    all_filters4[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                                    all_filters4[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                                    all_filters4[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                                    all_filters4[(49-7*0)*BITS-1:(42-7*0)*BITS]};
                                                            8'b00000001 :   filter_weights_reg <= {all_filters3[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                                    all_filters3[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                                    all_filters3[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                                    all_filters3[(49-7*1)*BITS-1:(42-7*1)*BITS],
                                                                                    all_filters4[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                                    all_filters4[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                                    all_filters4[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                                    all_filters4[(49-7*1)*BITS-1:(42-7*1)*BITS]};
                                                            8'b00000010 :   filter_weights_reg <= {all_filters3[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                                    all_filters3[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                                    all_filters3[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                                    all_filters3[(49-7*2)*BITS-1:(42-7*2)*BITS],
                                                                                    all_filters4[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                                    all_filters4[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                                    all_filters4[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                                    all_filters4[(49-7*2)*BITS-1:(42-7*2)*BITS]};
                                                            8'b00000011 :   filter_weights_reg <= {all_filters3[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                                    all_filters3[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                                    all_filters3[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                                    all_filters3[(49-7*3)*BITS-1:(42-7*3)*BITS],
                                                                                    all_filters4[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                                    all_filters4[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                                    all_filters4[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                                    all_filters4[(49-7*3)*BITS-1:(42-7*3)*BITS]};
                                                            8'b00000100 :   filter_weights_reg <= {all_filters3[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                                    all_filters3[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                                    all_filters3[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                                    all_filters3[(49-7*4)*BITS-1:(42-7*4)*BITS],
                                                                                    all_filters4[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                                    all_filters4[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                                    all_filters4[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                                    all_filters4[(49-7*4)*BITS-1:(42-7*4)*BITS]};
                                                            8'b00000101 :   filter_weights_reg <= {all_filters3[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                                    all_filters3[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                                    all_filters3[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                                    all_filters3[(49-7*5)*BITS-1:(42-7*5)*BITS],
                                                                                    all_filters4[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                                    all_filters4[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                                    all_filters4[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                                    all_filters4[(49-7*5)*BITS-1:(42-7*5)*BITS]};
                                                            8'b00000110 :   filter_weights_reg <= {all_filters3[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                                    all_filters3[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                                    all_filters3[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                                    all_filters3[(49-7*6)*BITS-1:(42-7*6)*BITS],
                                                                                    all_filters4[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                                    all_filters4[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                                    all_filters4[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                                    all_filters4[(49-7*6)*BITS-1:(42-7*6)*BITS]};
                                                            endcase
                                                        end
                                                end
                                            else if (counter_internal_phase == 2*(iterations_each_row - 1))
                                                begin
                                                    // Nieuwe gewichten en nieuwe data inlezen.
                                                    temp_in_1 <= temp_in_1_temp;
                                                    temp_in_2 <= temp_in_2_temp;
                                                    temp_in_3 <= temp_in_3_temp;
                                                    temp_in_4 <= temp_in_4_temp;
                                                    counter_internal_phase <= 9'b000000000;
                                                    if (counter_internal_phase_1 == 8'b00000110)
                                                            begin
                                                                counter_internal_phase_1 <= 8'b00000000;
                                                                if (counter_internal_phase_2 == number_four_inputs - 2)
                                                                    begin
                                                                        if (counter_internal_phase_3 == number_four_outputs - 1)
                                                                            begin
                                                                                counter_first_phase <= 9'b000000111;
                                                                            end
                                                                        else
                                                                            begin
                                                                                first_row_data_temp <= first_row_data;
                                                                                counter_internal_phase_3 <= counter_internal_phase_3 + 1;
                                                                            end
                                                                    end
                                                                else if (counter_internal_phase_2 == number_four_inputs - 1)
                                                                    begin
                                                                        counter_internal_phase_2 <= 8'b00000000;
                                                                    end
                                                                else
                                                                    begin
                                                                        first_row_data_temp <= first_row_data_temp + 9'b000011100;
                                                                        counter_internal_phase_2 <= counter_internal_phase_2 + 1;
                                                                    end
                                                            end
                                                        else
                                                            begin
                                                                counter_internal_phase_1 <= counter_internal_phase_1 + 1;
                                                            end
                                                    case(counter_internal_phase_1)
                                                    8'b00000110 :   filter_weights_reg <= {all_filters1[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                            all_filters1[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                            all_filters1[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                            all_filters1[(49-7*0)*BITS-1:(42-7*0)*BITS],
                                                                            all_filters2[(196-7*0)*BITS-1:(189-7*0)*BITS],
                                                                            all_filters2[(147-7*0)*BITS-1:(140-7*0)*BITS],
                                                                            all_filters2[(98-7*0)*BITS-1:(91-7*0)*BITS],
                                                                            all_filters2[(49-7*0)*BITS-1:(42-7*0)*BITS]};
                                                    8'b00000000 :   filter_weights_reg <= {all_filters1[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                            all_filters1[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                            all_filters1[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                            all_filters1[(49-7*1)*BITS-1:(42-7*1)*BITS],
                                                                            all_filters2[(196-7*1)*BITS-1:(189-7*1)*BITS],
                                                                            all_filters2[(147-7*1)*BITS-1:(140-7*1)*BITS],
                                                                            all_filters2[(98-7*1)*BITS-1:(91-7*1)*BITS],
                                                                            all_filters2[(49-7*1)*BITS-1:(42-7*1)*BITS]};
                                                    8'b00000001 :   filter_weights_reg <= {all_filters1[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                            all_filters1[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                            all_filters1[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                            all_filters1[(49-7*2)*BITS-1:(42-7*2)*BITS],
                                                                            all_filters2[(196-7*2)*BITS-1:(189-7*2)*BITS],
                                                                            all_filters2[(147-7*2)*BITS-1:(140-7*2)*BITS],
                                                                            all_filters2[(98-7*2)*BITS-1:(91-7*2)*BITS],
                                                                            all_filters2[(49-7*2)*BITS-1:(42-7*2)*BITS]};
                                                    8'b00000010 :   filter_weights_reg <= {all_filters1[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                            all_filters1[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                            all_filters1[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                            all_filters1[(49-7*3)*BITS-1:(42-7*3)*BITS],
                                                                            all_filters2[(196-7*3)*BITS-1:(189-7*3)*BITS],
                                                                            all_filters2[(147-7*3)*BITS-1:(140-7*3)*BITS],
                                                                            all_filters2[(98-7*3)*BITS-1:(91-7*3)*BITS],
                                                                            all_filters2[(49-7*3)*BITS-1:(42-7*3)*BITS]};
                                                    8'b00000011 :   filter_weights_reg <= {all_filters1[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                            all_filters1[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                            all_filters1[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                            all_filters1[(49-7*4)*BITS-1:(42-7*4)*BITS],
                                                                            all_filters2[(196-7*4)*BITS-1:(189-7*4)*BITS],
                                                                            all_filters2[(147-7*4)*BITS-1:(140-7*4)*BITS],
                                                                            all_filters2[(98-7*4)*BITS-1:(91-7*4)*BITS],
                                                                            all_filters2[(49-7*4)*BITS-1:(42-7*4)*BITS]};
                                                    8'b00000100 :   filter_weights_reg <= {all_filters1[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                            all_filters1[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                            all_filters1[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                            all_filters1[(49-7*5)*BITS-1:(42-7*5)*BITS],
                                                                            all_filters2[(196-7*5)*BITS-1:(189-7*5)*BITS],
                                                                            all_filters2[(147-7*5)*BITS-1:(140-7*5)*BITS],
                                                                            all_filters2[(98-7*5)*BITS-1:(91-7*5)*BITS],
                                                                            all_filters2[(49-7*5)*BITS-1:(42-7*5)*BITS]};
                                                    8'b00000101 :   filter_weights_reg <= {all_filters1[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                            all_filters1[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                            all_filters1[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                            all_filters1[(49-7*6)*BITS-1:(42-7*6)*BITS],
                                                                            all_filters2[(196-7*6)*BITS-1:(189-7*6)*BITS],
                                                                            all_filters2[(147-7*6)*BITS-1:(140-7*6)*BITS],
                                                                            all_filters2[(98-7*6)*BITS-1:(91-7*6)*BITS],
                                                                            all_filters2[(49-7*6)*BITS-1:(42-7*6)*BITS]};
                                                    endcase
                                                    
                                                end
                                            else
                                                begin
                                                    counter_internal_phase <= counter_internal_phase + 1;
                                                    temp_in_1 <= {temp_in_1[164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS-1:0],temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS]};
                                                    temp_in_2 <= {temp_in_2[164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS-1:0],temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS]};
                                                    temp_in_3 <= {temp_in_3[164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS-1:0],temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS]};
                                                    temp_in_4 <= {temp_in_4[164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS-1:0],temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS]};
                                                end
                                                  
                                        end
                         
           endcase              
        end
  end



assign features = 
{temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_1[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_1[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_1[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_1[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_1[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_1[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_2[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_2[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_2[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_2[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_2[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_2[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_3[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_3[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_3[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_3[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_3[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_3[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_4[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_4[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_4[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_4[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_4[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_4[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_1[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_1[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_1[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_1[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_1[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_1[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_1[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_2[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_2[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_2[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_2[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_2[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_2[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_2[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_3[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_3[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_3[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_3[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_3[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_3[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_3[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS],
temp_in_4[164*WIDTH_RAM-1:164*WIDTH_RAM-(FEATURES-KERNEL+1)*BITS],
temp_in_4[164*WIDTH_RAM-BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+2)*BITS],
temp_in_4[164*WIDTH_RAM-2*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+3)*BITS],
temp_in_4[164*WIDTH_RAM-3*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+4)*BITS],
temp_in_4[164*WIDTH_RAM-4*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+5)*BITS],
temp_in_4[164*WIDTH_RAM-5*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+6)*BITS],
temp_in_4[164*WIDTH_RAM-6*BITS-1:164*WIDTH_RAM-(FEATURES-KERNEL+7)*BITS]
    };

    assign output_channels = output_channels_reg;
    assign biases = biases_reg;
    assign filter_weights = filter_weights_reg;
endmodule 
