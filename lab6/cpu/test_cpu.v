module test_cpu;
    reg clk,reset;
    wire [13:0] out;
    cpu cpu1(
        .clk(clk),
        .reset(reset),
        .w_q(out)
    );

    always #5 clk = ~clk;

    initial begin
        reset = 1;clk = 0;//initialize
        #10 reset = 0;
        #600 $stop;
    end
endmodule
