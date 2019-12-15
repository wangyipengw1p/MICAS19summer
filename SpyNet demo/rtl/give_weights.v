`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2019 09:04:23 AM
// Design Name: 
// Module Name: give_filter_weights
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


module give_filter_weights #(parameter BITS = 16, parameter KERNEL = 7, parameter NB_BASE_BLOCKS = 8, parameter OVERHEAD_BITS = 12, parameter FEATURES = 21)(
    input clk,
    input start,
    input done,
    input [2:0] stage,
    input change,
    input [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] temp_result,
    output [BITS*KERNEL*NB_BASE_BLOCKS-1:0] filter_weights,
    output [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] biases
    );
    
    reg [19:0] counter = {20{1'b0}};
    reg [BITS*KERNEL*NB_BASE_BLOCKS-1:0] filter_weights_reg = {(BITS*KERNEL*NB_BASE_BLOCKS){1'b0}};
    reg [(2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)-1:0] biases_reg = {((2*BITS+OVERHEAD_BITS)*NB_BASE_BLOCKS*KERNEL*(FEATURES-KERNEL+1)){1'b0}};
    
    
    always @(posedge clk)
    begin
        //if (done == 1'b1)
      //  begin
      //      counter <= {20*{1'b0}};
      //  end
        case (counter)
            20'b00000000000000000000    :   begin
                                                filter_weights_reg <= {16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000000111,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000001111,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000010001,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000010011,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000001110,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000010000,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000010010,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010,
                                                16'b0000000000000100,16'b0000000000000101,16'b0000000000000110,16'b0000000000010100,16'b0000000000001000,16'b0000000000001001,16'b0000000000001010}; 
                                                if (change == 1'b1)
                                                begin
                                                    counter <= counter + 1;
                                                end
                                            end
            20'b00000000000000000001    :   begin
                                                biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000101}};
                                                biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000001010}};
                                                biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                if (change == 1'b1)
                                                begin
                                                counter <= counter + 1;
                                                // In dit deeltje altijd nieuwe filters toekennen.
                                                end
                                            end
            20'b00000000000000000010    :   begin
                                                biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000101}};
                                                biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000001010}};
                                                biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {15{44'b00000000000000000000000000000000000000000000}};
                                                if (change == 1'b1)
                                                begin
                                                counter <= counter + 1;
                                                end
                                            end
            20'b00000000000000000011    :   begin
                                                biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                                biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                                biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                                biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                                biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                                biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                                biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                                biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                                if (change == 1'b1)
                                                begin
                                                counter <= counter + 1;
                                                end
                                            end
            20'b00000000000000000100    :   begin
                                               biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                               biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                               biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               if (change == 1'b1)
                                               begin
                                               counter <= counter + 1;
                                               end
                                           end
            20'b00000000000000000101    :   begin
                                               biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                               biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                               biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                               if (change == 1'b1)
                                               begin
                                               counter <= counter + 1;
                                               end
                                           end
           20'b00000000000000000110    :   begin
                                              biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                              biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                              biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              if (change == 1'b1)
                                              begin
                                              counter <= counter + 1;
                                              end
                                          end
            20'b00000000000000000111    :   begin
                                              biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                              biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                              biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                              if (change == 1'b1)
                                              begin
                                              counter <= counter + 1;
                                              end
                                          end
          20'b00000000000000001000    :   begin
                                             biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                             biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                             biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             if (change == 1'b1)
                                             begin
                                             counter <= counter + 1;
                                             end
                                         end
          20'b00000000000000001001    :   begin
                                             biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                             biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                             biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                             if (change == 1'b1)
                                             begin
                                             counter <= counter + 1;
                                             end
                                         end
         20'b00000000000000001010    :   begin
                                            biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                            biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                            biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            if (change == 1'b1)
                                            begin
                                            counter <= counter + 1;
                                            end
                                        end
         20'b00000000000000001011    :   begin
                                            biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                            biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                            biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                            if (change == 1'b1)
                                            begin
                                            counter <= counter + 1;
                                            end
                                        end
        20'b00000000000000001100    :   begin
                                           biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                           biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                           biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           if (change == 1'b1)
                                           begin
                                           counter <= counter + 1;
                                           end
                                       end
        20'b00000000000000001101    :   begin
                                           biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                           biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                           biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                           if (change == 1'b1)
                                           begin
                                           counter <= counter + 1;
                                           end
                                       end
       20'b00000000000000001110    :   begin
                                          biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                          biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                          biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                          biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                          biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                          biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                          biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                          biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                          if (change == 1'b1)
                                          begin
                                          counter <= counter + 1;
                                          end
                                      end
       20'b00000000000000001111    :   begin
                                   biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                   biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                   biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                   biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                   biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                   biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                   biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                   biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  if (change == 1'b1)
                                  begin
                                  counter <= counter + 1;
                                  // In dit deeltje altijd nieuwe filters toekennen.
                                  end
                              end
20'b00000000000000010000    :   begin
                                   biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                            biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                            biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  if (change == 1'b1)
                                  begin
                                  counter <= counter + 1;
                                  end
                              end
20'b00000000000000010001    :   begin
                                  biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                  biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                  biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                  if (change == 1'b1)
                                  begin
                                  counter <= counter + 1;
                                  end
                              end
20'b00000000000000010010    :   begin
                                 biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                 biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                 biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 if (change == 1'b1)
                                 begin
                                 counter <= counter + 1;
                                 end
                             end
20'b00000000000000010011    :   begin
                                 biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                 biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                 biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                 if (change == 1'b1)
                                 begin
                                 counter <= counter + 1;
                                 end
                             end
20'b00000000000000010100    :   begin
                                biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                if (change == 1'b1)
                                begin
                                counter <= counter + 1;
                                end
                            end
20'b00000000000000010101    :   begin
                                biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                                biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                                if (change == 1'b1)
                                begin
                                counter <= counter + 1;
                                end
                            end
20'b00000000000000010110    :   begin
                               biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                               biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                               biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               if (change == 1'b1)
                               begin
                               counter <= counter + 1;
                               end
                           end
20'b00000000000000010111    :   begin
                               biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                               biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                               biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                               if (change == 1'b1)
                               begin
                               counter <= counter + 1;
                               end
                           end
20'b00000000000000011000    :   begin
                              biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                              biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                              biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              if (change == 1'b1)
                              begin
                              counter <= counter + 1;
                              end
                          end
20'b00000000000000011001    :   begin
                              biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                              biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                              biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                              if (change == 1'b1)
                              begin
                              counter <= counter + 1;
                              end
                          end
20'b00000000000000011010    :   begin
                             biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                             biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                             biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             if (change == 1'b1)
                             begin
                             counter <= counter + 1;
                             end
                         end
20'b00000000000000011011    :   begin
                             biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                             biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                             biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                             if (change == 1'b1)
                             begin
                             counter <= counter + 1;
                             end
                         end
20'b00000000000000011100    :   begin
                            biases_reg[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[54*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:53*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                            biases_reg[47*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:46*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[36*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[35*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:34*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= temp_result[26*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:25*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)];
                            biases_reg[19*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:18*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[8*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            biases_reg[7*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)-1:6*(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1)] <= {(2*BITS+OVERHEAD_BITS)*(FEATURES-KERNEL+1){1'b0}};
                            if (change == 1'b1)
                            begin
                            counter <= 20'b00000000000000000001;
                            end
                        end
            
            
    endcase
    
    end
    
    assign filter_weights = filter_weights_reg;
    assign biases = biases_reg;
    
endmodule
