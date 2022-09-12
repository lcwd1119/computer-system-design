module CounterWithController_test;

wire [3:0]out;//output
reg clk,rst,loadw;//input
CounterWithController test1(
    .clk(clk),
    .rst(rst),
    .loadw(loadw),
    .finalout(out)
);

always #5 clk=~clk;
initial begin
        clk = 0;rst = 1;loadw = 1;//initialize
    #15 rst = 0;//start counter
    #200 $stop;
end
endmodule
