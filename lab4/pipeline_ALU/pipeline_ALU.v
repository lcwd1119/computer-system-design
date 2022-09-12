module pipeline_ALU (
    input clk,reset,
    input [4:0]A,B,C,D,E,
    output [4:0] S
);
    reg [4:0] D01,D02,D03,D11,D12;
    wire [4:0] ABsum,CDsum;
    
    //使用pipeline做第一部分的運算
    assign ABsum = A + B;
    assign CDsum = C + D;
    //D0 flipflop
    always @(posedge clk) begin
        if(reset) {D01,D02,D03} <= 0;
        else {D01,D02,D03} <= {ABsum,CDsum,E};
    end
    //使用pipeline做第二部分的運算
    wire [4:0] D01subD02;
    assign D01subD02 = D01 - D02;
    //D0 flipflop
    always @(posedge clk) begin
        if(reset) {D11,D12} <= 0;
        else {D11,D12} <= {D01subD02,D03};
    end
    //output
    assign S = D11 & D12;

endmodule
