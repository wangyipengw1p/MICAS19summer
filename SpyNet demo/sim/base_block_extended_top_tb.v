`timescale 1ns / 1ps


module base_block_extended_top_tb(

    );
    
    reg clk = 1'b0;
    
    base_block_extended_top base_block_extended_top(
        .clk(clk)
    );
    
    initial
        begin
            #300
            $finish;
        end
    
        always begin
            #5 clk = ~clk;
        end
endmodule
