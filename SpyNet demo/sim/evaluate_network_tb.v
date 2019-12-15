`timescale 1ns / 1ps


module evaluate_network_tb(

    );

    reg clk = 0;
    reg [111:0] data;
    wire [43:0] result;
    reg [43:0] result_reg;

    evaluate_network #(.BITS(16),.KERNEL(7),.FEATURES(12),.OVERHEAD_BITS(12)) evaluate_network_inst (
        .clk(clk),
        .data(data),
        .result(result)
    );

    initial
        begin
        #5
        data <= 112'b0000000000000001000000000000001000000000000000110000000000000100000000000000010100000000000001100000000000000111;
        #10
        data <= 112'b0000000000000001000000000000011100000000000000110000000000000101000000000000100000000000000010100000000000001101;
        #10
        data <= 112'b0000000000000010000000000000100100000000000001110000000000000110000000000000101100000000000000000000000000000000;
        #200
        $finish;
    end
    
    always begin
        #5 clk = ~clk;
    end
    
    always @(posedge clk)
    begin
        result_reg <= result;
    end
endmodule 