module BCD_counter(
  input clk,
  input reset
  );
  
  reg [3:0] counter_one, counter_ten;//??????counter
  reg carry_bit;//??
  
  
  always @(negedge clk)//clk????
  begin
    if(counter_one == 0)
      carry_bit = 1;
    if(reset)//reset?counter????0
      {counter_ten,counter_one} <= 0;
    else if(counter_one == 9)//??9????carry??0????counter??
      {counter_one,carry_bit} <= 0;
    else//??clk??????
      counter_one <= counter_one + 1;
  end
  
  always @(negedge carry_bit)//carry_bit????
  begin
    if(counter_ten == 9)//??9?????0
      counter_ten <= 0;
    else//??carry_bit??????
      counter_ten <= counter_ten +1;
  end
  
  
  
endmodule   