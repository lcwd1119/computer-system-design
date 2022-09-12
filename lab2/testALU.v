module testALU;
   
    reg [7:0]A,B; //input
    reg [2:0]op;  //input
    wire [7:0]S;  //output 

ALU ALU1(
    .A(A),
    .B(B),
    .op(op),
    .S(S)
);

initial 
  begin
        A = 8'h95; B = 8'h27; op = 3'b000;//(95)hex + (27)hex
    #10 A = 8'h0A; B = 8'hD0; op = 3'b000;//(0A)hex + (D0)hex
    #10 $stop;
    
  end
endmodule