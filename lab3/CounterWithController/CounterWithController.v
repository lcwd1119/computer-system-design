module CounterWithController (
    input clk,
    input rst,
    input loadw,
    output reg[3:0] finalout
);
reg [3:0] counter1_out,counter2_out,present_state,next_state;
reg cp1,cp2;

//counter1
always @(negedge clk) begin
    if (rst)
        counter1_out <= 0;
    else if(cp1)
        counter1_out <= counter1_out+1;
end

//counter2
always @(negedge clk) begin
    if (rst)
        counter2_out <= 0;
    else if(cp2)
        counter2_out <= counter2_out+1;
end

//update and initialize present_state
always @(negedge clk) begin
    if (rst)
        present_state<=0;
    else
        present_state<=next_state;
end

//controller for two counters(FSM)
always @(*) begin
    //default case
    next_state = 0;
    cp1 = 0;
    cp2 = 0;
    case (present_state)
        0:
        begin
            cp1 = 1;
            cp2 = 1;
            next_state = 1;
        end
        1:
        begin
            cp1 = 1;
            cp2 = 1;
            next_state = 2;
        end
        2:
        begin
            cp1 = 1;
            cp2 = 1;
            next_state = 3;
        end
        3:
        begin
            cp1 = 1;
            cp2 = 1;
            next_state = 4;
        end
        4:begin
            cp1 = 1;
            next_state = 5;
        end
        5:begin
            cp1 = 1;
            next_state = 6;
        end
        6:begin
            cp1 = 1;
            next_state = 7;
        end
        7:begin
            cp1 = 1;
            next_state = 8;
        end
        8:
        begin
            cp1 = 1;
            next_state = 9;
        end
        9: 
        begin
            next_state = 9;
        end
    endcase
end

//adder
always @(*) begin
    //loadw:1相加 load:0 不變
    finalout=(loadw)?counter1_out+counter2_out:finalout;
end
    
endmodule
