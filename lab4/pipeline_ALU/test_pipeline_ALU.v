module test_pipeline_ALU ();
    
    reg clk,reset;
    wire [4:0] S;
    reg [4:0]A,B,C,D,E;

    pipeline_ALU test(
    .clk(clk),
    .reset(reset),
    .A(A),
    .B(B),
    .C(C),
    .D(D),
    .E(E),
    .S(S)
);
    //create clock
    always #5 clk = ~clk;
    initial begin
        //initialize
        clk = 0;reset = 1;
        A=0;B=0;C=0;D=0;E=0;
    #10 reset = 0;//start
    @(posedge clk) A=6;     B=7;    C=8;    D=3;    E=10;
    @(posedge clk) A=4;     B=8;    C=7;    D=3;    E=1;
    @(posedge clk) A=1;     B=9;    C=6;    D=3;    E=5;
    @(posedge clk) A=8;     B=7;    C=3;    D=7;    E=2;
    @(posedge clk) A=6;     B=10;   C=3;    D=3;    E=10;
    @(posedge clk) A=11;    B=9;    C=6;    D=5;    E=6;
    @(posedge clk) A=6;     B=8;    C=2;    D=7;    E=1;
    @(posedge clk) A=11;    B=10;   C=4;    D=3;    E=2;
    @(posedge clk) A=7;     B=4;    C=10;   D=7;    E=9;
    @(posedge clk) A=2;     B=8;    C=11;   D=13;   E=5;
    #50 $stop;
    end
    
    always @(S) begin
        //輸出結果
        $monitor($time,"   S=%5d",S);
    end
endmodule
