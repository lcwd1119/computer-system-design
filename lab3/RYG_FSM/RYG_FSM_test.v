module RYG_FSM_test;

    reg clk,rst;
    wire [1:0]R,Y,G;
    RYG_FSM test1(
    .rst(rst),
    .clk(clk),
    .R(R),
    .Y(Y),
    .G(G)
);

always #5 clk=~clk;    
initial begin
        clk = 0;rst = 1;//initialize
    #5 rst = 0;//start RYG_FSM
    #200 $stop;
end
endmodule
