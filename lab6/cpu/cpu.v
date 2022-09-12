module cpu (
    input reset,clk,
    output reg [7:0] w_q
);
    //設置狀態
    parameter T0 = 0;
    parameter T1 = 1;
    parameter T2 = 2;
    parameter T3 = 3;
    parameter T4 = 4;
    parameter T5 = 5;
    parameter T6 = 6;
    parameter T7 = 7;

    //設置opcode狀態
    parameter MOVLW = 6'b110000;
    parameter ADDLW = 6'b111110;
    parameter SUBLW = 6'b111100;
    parameter ANDLW = 6'b111001;
    parameter IORLW = 6'b111000;
    parameter XORLW = 6'b111010;



    reg load_pc,load_mar,load_ir,load_w;
    wire [13:0] ir_in;
    reg [13:0] ir_out;
    reg [10:0] pc_out,mar_out;
    reg [2:0] ps,ns,op;
    wire [10:0]pc_next;
    wire [5:0] opcode;
    wire [7:0] operand;
    reg [7:0] alu_out;
    
    //做PC+1算下一個PC
    assign pc_next = pc_out + 1;

    //PC,clock發生時把PC值copy到下一個
    always @(posedge clk) begin
        if(reset)
            pc_out <= 0;
        else
            if(load_pc)
                pc_out <= pc_next;
    end

    //MAR,clock發生時把data address傳到ROM
    always @(posedge clk) begin
        if(reset)
            mar_out <= 0;
        else
            if(load_mar)
                mar_out <= pc_out;
    end

    //用位址在ROM裡面讀出DATA
    ROM rom(.Rom_data_out(ir_in),
            .Rom_addr_in(mar_out));

    //IR,clock發生時把讀到的data copy到下一個
    always @(posedge clk) begin
        if(reset)
            ir_out <= 0;
        else if (load_ir) begin
            ir_out <= ir_in;
        end
    end

    //update ps
    always @(posedge clk) begin
        if(reset)
            ps <= 0;
        else
            ps <= ns;
    end

    //分出opcode跟operand
    assign opcode = ir_out[13:8];
    assign operand = ir_out[7:0];

    //ALU
    always @(posedge clk) begin
        alu_out = 8'bX;
        case (op)
            0:  alu_out = operand + w_q; 
            1:  alu_out = operand - w_q; 
            2:  alu_out = operand & w_q; 
            3:  alu_out = operand | w_q; 
            4:  alu_out = operand ^ w_q; 
            5:  alu_out = operand; 
        endcase
    end

    //w_register
    always @(posedge clk) begin
        if(load_w)
            w_q <= alu_out;
    end

    //fetch cycle FSM
    always @(*) begin
        //defult
        ns = T0;
        load_pc = 0;
        load_mar = 0;
        load_ir = 0;
        load_w = 0;
        case (ps)
            //待機
            T0:begin
                ns = T1;
            end 
            //T1,load MAR
            T1:begin
                ns = T2;
                load_mar = 1;
            end
            //T2,load PC
            T2:begin
                ns = T3;
                load_pc = 1;    
            end
            //T3,load IR
            T3:begin
                ns = T4;
                load_ir = 1;
            end
            //決定控制訊號
            T4:begin
                ns = T5;
                if(opcode == MOVLW)begin
                    op = 5;
                    load_w = 1;
                end
                else if(opcode == ADDLW)begin
                    op = 0;
                    load_w = 1;
                end
                else if(opcode == SUBLW)begin
                    op = 1;
                    load_w = 1;
                end
                else if(opcode == IORLW)begin
                    op = 3;
                    load_w = 1;
                end
                else if(opcode == XORLW)begin
                    op = 4;
                    load_w = 1;
                end
                else if(opcode == ANDLW)begin
                    op = 2;
                    load_w = 1;
                end
            end 
            //等待執行
            T5:begin
                ns = T6;
            end
            //跳回T1
            T6:begin
                ns = T1;
            end
        endcase
    end
endmodule
