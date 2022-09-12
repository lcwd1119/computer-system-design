module test_FSM_counter ();
    wire [7:0] port_A,port_B;
    reg clk,reset;

    FSM_counter test(
    .clk(clk),
    .reset(reset),
    .port_A(port_A),
    .port_B(port_B)
);
    //create clock
    always #5 clk = ~clk;
    initial begin
        clk = 0;reset = 1;//initialize
    #10 reset = 0;//start counter
    #250 $stop;
    end
    initial begin
        //輸出結果
        #50 $monitor($time,"   port_A=%d port_B=%d",port_A,port_B);
    end
endmodule

