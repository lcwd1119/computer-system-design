module RYG_FSM (
    input rst,clk,
    output reg [1:0]R,Y,G
);

reg [3:0] present_state,next_state;
//update present_state
always @(negedge clk) begin
    if(rst)
        present_state <= 0;
    else
        present_state <= next_state;
end

//RYG_FSM
always @(*) begin
    next_state = 0;
    case (present_state)
         0:
        begin
            R = 2'b01;
            Y = 0;
            G = 2'b10;
            next_state = 1;
        end
        1:
        begin
            R = 2'b01;
            Y = 0;
            G = 2'b10;
            next_state = 2;
        end
        2:
        begin
            R = 2'b01;
            Y = 0;
            G = 2'b10;
            next_state = 3;
        end
        3:
        begin
            R = 2'b01;
            Y = 0;
            G = 2'b10;
            next_state = 4;
        end
        4:
        begin
            R = 2'b01;
            Y = 0;
            G = 2'b10;
            next_state = 5;
        end
        5:
        begin
            R = 2'b01;
            Y = 0;
            G = 2'b10;
            next_state = 6;
        end
        6:
        begin
            R = 2'b01;
            Y = 2'b10;
            G = 0;
            next_state = 7;
        end
        7:
        begin
            R = 2'b01;
            Y = 2'b10;
            G = 0;
            next_state = 8;
        end
        8:
        begin
            R = 2'b10;
            Y = 0;
            G = 2'b01;
            next_state = 9;
        end
        9:
        begin
            R = 2'b10;
            Y = 0;
            G = 2'b01;
            next_state = 10;
        end
        10:
        begin
            R = 2'b10;
            Y = 0;
            G = 2'b01;
            next_state = 11;
        end
        11:
        begin
            R = 2'b10;
            Y = 0;
            G = 2'b01;
            next_state = 12;
        end
        12:
        begin
            R = 2'b10;
            Y = 0;
            G = 2'b01;
            next_state = 13;
        end
        13:
        begin
            R = 2'b10;
            Y = 0;
            G = 2'b01;
            next_state = 14;
        end
        14:
        begin
            R = 2'b10;
            Y = 2'b01;
            G = 0;
            next_state = 15;
        end  
        15:
        begin
            R = 2'b10;
            Y = 2'b01;
            G = 0;
            next_state = 0;
        end  
    endcase
end

endmodule


