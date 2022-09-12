`timescale 100ns / 10ns

module testALU;
   
    reg [7:0]A,B;
    reg [2:0]op;
    wire [7:0]S;

ALU ALU1(
    .A(A),
    .B(B),
    .op(op),
    .S(S)
);

initial 
  begin
        A = 8'h95; B = 8'h27; op = 3'b000;
    #10 A = 8'h0A; B = 8'hD0; op = 3'b000;
    #10 $stop;
    
  end
endmodule