module test_BCD_counter;
  reg clk, reset;
  BCD_counter counter1(
    .clk(clk),
    .reset(reset)
  );

always #5 clk = ~clk;//?5????clk???

initial
  begin
    clk = 0;reset = 1;//?????
    #10 reset = 0;//10?????????
    #1000 $stop;//1000???????
  end
endmodule