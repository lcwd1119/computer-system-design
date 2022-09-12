module FSM_counter (
    input clk,reset,
    output reg [7:0] port_A,port_B
);
    wire [7:0] S;
    reg [7:0] B,W,present_state,next_state;
    reg cnt,load_w,load_A,load_B;

    //counter
    always @(posedge clk) begin
        if(reset)
            B <= 7'b0000000;
        else
            if(cnt) B <= B+1;
    end

    //adder
    assign S = W + B;

    //w register
    always @(posedge clk) begin
        if(reset)
            W <= 7'b0000000;
        else
            if (load_w) W <= S;
    end

    //D0 flip flop output to A and B
    always @(posedge clk) begin
        if(reset)
            {port_A,port_B} <= 0;
        else 
            port_A=(load_A)?W:port_A;
            port_B=(load_B)?W:port_B;
    end


    //update present_state
    always @(posedge clk) begin
        if(reset)
            present_state <= 0;
        else
            present_state <= next_state;
    end

    //controller
    always @(*) begin
        next_state = 0;
        cnt = 0;
        load_w = 0;
        load_A = 0;
        load_B = 0;
        case (present_state)
            0:
            begin
                next_state = 1;
                cnt = 1;
                load_w = 1;
            end 
            1:
            begin
                next_state = 2;
                cnt = 1;
                load_w = 1;
            end
            2:
            begin
                next_state = 3;
                cnt = 1;
                load_w = 1;
            end
            3:
            begin
                next_state = 4;
                cnt = 1;
                load_w = 1;
            end
            4:
            begin
                next_state = 5;
                cnt = 1;
                load_w = 1;
            end
            5:
            begin
                next_state = 6;
                cnt = 1;
                load_w = 1;
            end
            6:
            begin
                next_state = 7;
                cnt = 1;
                load_w = 1;
            end
            7:
            begin
                next_state = 8;
                cnt = 1;
                load_w = 1;
            end
            8:
            begin
                next_state = 9;
                cnt = 1;
                load_w = 1;
            end
            9:
            begin
                next_state = 10;
                cnt = 1;
                load_w = 1;
            end
            10:
            begin
                next_state = 11;
                cnt = 1;
                load_w = 1;
            end
            11:
            begin
                next_state = 12;
                cnt = 1;
                load_w = 1;
                //將值load到port_A
                load_A = 1;
            end
            12:
            begin
                next_state = 13;
                cnt = 1;
                load_w = 1;
            end
            13:
            begin
                next_state = 14;
                cnt = 1;
                load_w = 1;
            end
            14:
            begin
                next_state = 15;
                cnt = 1;
                load_w = 1;
            end
            15:
            begin
                next_state = 16;
                cnt = 1;
                load_w = 1;
            end
            16:
            begin
                next_state = 17;
                cnt = 1;
                load_w = 1;
            end
            17:
            begin
                next_state = 18;
                cnt = 1;
                load_w = 1;
            end
            18:
            begin
                next_state = 19;
                cnt = 1;
                load_w = 1;
            end
            19:
            begin
                next_state = 20;
                cnt = 1;
                load_w = 1;
            end
            20:
            begin
                next_state = 21;
                load_w = 1;
            end
            21:
            begin
                next_state = 22;
                 //將值load到port_B
                load_B = 1;
            end
            22:
            begin
                next_state = 22;
            end
        endcase
    end
   
endmodule
