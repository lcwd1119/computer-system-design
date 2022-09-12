module clock(
  input clk,
  input reset
  );
  reg [3:0] counter_min2, counter_min1;//??counter
  reg [3:0] counter_hour2, counter_hour1;//??counter
  reg carry_hour,carry_mtoh,carry_min;//??
  //??
  always @(negedge clk)//clk????
  begin
    if(counter_min1 == 0)
      carry_min = 1;
    if(reset)//reset?counter????0
      {counter_hour2, counter_hour1,counter_min2,counter_min1} <= 0;
    else if(counter_min1 == 9)//??9?carry??0??counter_min2??
      carry_min <= 0;
    else//??clk??????
      counter_min1 <= counter_min1 + 1;
  end
  always @(negedge carry_min)//carry_min????
  begin
    if(counter_min2 == 0)//hour1????carry????????
      carry_mtoh = 1;
    if(counter_min2 == 5 && counter_min1 == 9)//??59????0
      {carry_mtoh,counter_min2,counter_min1} <= 0;
    else//??carry_min??????
      {counter_min2,counter_min1} <= {counter_min2 +1,4'd0};
  end
  //??
  always @(negedge carry_mtoh)//carry_mtoh????
  begin
    if(counter_hour1 == 0)//hour2????carry????????
      carry_hour = 1;
    if(counter_hour1 == 9)//??9?hour1?carry??0??counter_hour2??
      {carry_hour,counter_hour1} <= 0;
    else if(counter_hour2 == 2 && counter_hour1 == 3)//??23?hour??0
      {counter_hour2,counter_hour1} <= 0;
    else//??carry_mtoh??????
      counter_hour1 <= counter_hour1 + 1;
  end
  always @(negedge carry_hour)//carry_hour????
  begin
    //??carry_hour??????
    counter_hour2 <= counter_hour2 + 1;
  end
endmodule   

