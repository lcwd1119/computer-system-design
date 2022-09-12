module test_cpu;
    reg clk,reset;
    wire [7:0] out;
    cpu cpu1(
        .clk(clk),
        .reset(reset),
        .port_b_out(out)
    );

    always #5 clk = ~clk;

    initial begin
        reset = 1;clk = 0;//initialize
        #10 reset = 0;
        #350000 $stop;
    end
endmodule
