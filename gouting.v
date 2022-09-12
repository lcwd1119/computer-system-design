module CPU (
    input clk,reset,
    output [7:0] w_output, //alu的輸出後存的值(本次作業的輸出)
    output [7:0] b_output //alu的輸出後存的值(本次作業的輸出)
);

reg[2:0] current_state,next_state; //狀態

//六個state
parameter T0 = 0;
parameter T1 = 1;
parameter T2 = 2;
parameter T3 = 3;
parameter T4 = 4;
parameter T5 = 5;
parameter T6 = 6;

//Instruction Fetch相關
reg[10:0] pc_out;  //PC暫存器
reg[10:0] pc_in;  //PC的輸入
reg [10:0] mar_out; //Memory Address Register
reg load_pc, load_mar, load_ir; //控制pc,mar,ir的存入


//指令(IR)相關
wire[13:0] ir_in;  //instruction register的輸入
reg [13:0] ir_out; //instruction存的值
reg reset_ir; //控制IR的reset
Program_Rom u_rom(.Rom_addr_in(mar_out),.Rom_data_out(ir_in));  //從ROM取DATA

//W相關
reg load_w; //控制ALU之後的結果儲存
reg[7:0] w_out; //alu的輸出後的暫存器值

//ALU相關
reg[7:0] alu_out; //alu的輸出
reg[5:0] op;  //給ALU看的OPCODE

wire aluout_zero; //alu的輸出是否為0
assign aluout_zero = (alu_out == 0); //alu的輸出是否為0

assign w_output = w_out;  //alu的輸出後存的值(本次作業的輸出)

//RAM相關
wire[7:0] databus; //RAM的輸入
reg ram_en; //控制RAM的存入
wire[7:0] ram_out; //RAM的輸出
single_port_ram_128x8 u_ram(.data(databus),.addr(ir_out[6:0]),.en(ram_en),.clk(clk),.q(ram_out));



//決定RAM OUT以後要送入mux前要進行的bit運算
wire[2:0] sel_bit = ir_out[9:7];
reg[1:0] sel_RAM_mux; 
reg[7:0] RAM_mux;


//Stack operation
reg push,pop; //控制push,pop
wire[10:0] stack_out; //stack的輸出
Stack u_stack(.stack_out(stack_out),.stack_in(pc_out),.push(push),.pop(pop),.reset(reset),.clk(clk));


//決定ALU的輸入
reg sel_alu; //決定ALU的輸入來自哪裡
wire[7:0] mux1_out;
assign mux1_out = (sel_alu) ? RAM_mux : ir_out[7:0];  //ALU的輸入來自指令或RAM

//相對定址用的位移
wire[10:0] w_change,k_change;
assign w_change = {3'b0, w_out}-1;  //減一
assign k_change = {ir_out[8],ir_out[8],ir_out[8:0]}-1;

//決定PC的輸入來自哪裡
reg[2:0] sel_pc; //決定PC的輸入來自哪裡
//assign pc_in = (sel_pc)? ir_out[10:0] : (pc_out + 1);  //PC每次加一
always @(*) begin
    case (sel_pc)
        0: pc_in = pc_out+1;
        1: pc_in = ir_out[10:0]; 
        2: pc_in = stack_out;
        3: pc_in = pc_out+k_change;
        4: pc_in = pc_out+w_change;
        default: pc_in = pc_out+1;
    endcase
end

//決定RAM的輸入
reg sel_bus; //決定RAM的輸入來自哪裡
assign databus = (sel_bus) ? w_out : alu_out;  //RAM的輸入來自指令或ALU

//BCF,BSF結果
reg[7:0] bcf_mux;
reg[7:0] bsf_mux;

//bit conditional jump相關
wire btfsc_skip_bit;
wire btfss_skip_bit;
wire btfsc_btfss_skip_bit; //最後要不要跳


//port B
wire addr_port_b = (ir_out[6:0] == 7'h0d);
reg load_port_b;
reg[7:0] port_b_out;

assign b_output = port_b_out;  //b的輸出後存的值(本次作業的輸出)


//RAM的輸出有沒有經過bit運算
always @(*) begin
    case(sel_RAM_mux)
        0: RAM_mux = ram_out;
        1: RAM_mux = bcf_mux;
        2: RAM_mux = bsf_mux;
        default: RAM_mux = 8'bx;
    endcase
end

always @(posedge clk or posedge reset) begin
    if(reset || reset_ir)
    begin
        ir_out <= 14'b0;   //IR歸零
    end
    else
    begin
        if(load_ir) ir_out <= ir_in; //存入新的instruction
    end
end

always @(posedge clk or posedge reset) begin
    if(reset)
    begin
        current_state <= T0;  //狀態設回T0
        pc_out <= 11'b0; //PC設回零
        mar_out <= 11'b0;  //MAR歸零
        //alu_out <= 8'h0;  //ALU輸出歸零
        w_out <=  8'h0; //W暫存器輸出歸零
        port_b_out <= 8'h0; //port B輸出歸零
    end
    else
    begin
        if(load_pc) pc_out <= pc_in;  //把新的PC值存入
        if(load_mar) mar_out <= pc_out;  //PC值傳給MAR
        if(load_w)  w_out <= alu_out;  //alu的輸出給W
        if(load_port_b) port_b_out <= databus;  //port B的輸出
        current_state <= next_state; //下一個state
    end
end

//opcode解碼部分
wire MOVLW, ADDLW, SUBLW, ANDLW, IORLW, XORLW; //立即定址的指令
wire ADDWF, ANDWF, CLRF, CLRW, COMF, DECF; //暫存器定址的指令
wire INCF,IORWF,MOVF,MOVWF,SUBWF,XORWF; //更多暫存器定址的指令
wire DECFSZ,INCFSZ; //conditional jump的指令
wire BCF,BSF; //bit指令
wire BTFSC,BTFSS; //bit 跳躍指令
wire ASRF,LSLF,LSRF,RLF,RRF; //shift指令
wire SWAPF; //交換指令
wire CALL,RETURN; //subroutine 相關指令
wire BRA,BRW; //相對位移定址的指令
wire NOP; //空指令



wire GOTO; //跳躍指令
assign MOVLW = (ir_out[13:8]==6'h30);  //w = IR_out[7:0]
assign ADDLW = (ir_out[13:8]==6'h3E);  //w = IR_out[7:0] + w
assign SUBLW = (ir_out[13:8]==6'h3C);  //w = IR_out[7:0] - w
assign ANDLW = (ir_out[13:8]==6'h39);  //w = IR_out[7:0] and w
assign IORLW = (ir_out[13:8]==6'h38);  //w = IR_out[7:0] or w
assign XORLW = (ir_out[13:8]==6'h3A);  //PC = 指定的地方(IR的第10~0位)
assign ADDWF = (ir_out[13:8]==6'h07); //(if d=0) w = f + w, (if d=1) f = f + w
assign ANDWF = (ir_out[13:8]==6'h05); //(if d=0) w = f and w, (if d=1) f = f and w
assign CLRF = (ir_out[13:8]==6'h01 && ir_out[7]==1'b1); //f = 0
assign CLRW = (ir_out[13:4]==10'h010 && ir_out[3:2]==2'b00); //w = 0
assign COMF = (ir_out[13:8]==6'h09); //f = ~f (取補數)
assign DECF = (ir_out[13:8]==6'h03); //(if d=0)w = f - 1,(if d=1) f = f - 1
assign GOTO = (ir_out[13:11]==3'b101); //
assign INCF = (ir_out[13:8]==6'h0A); //(if d=0) w = f + 1, (if d=1) f = f + 1
assign IORWF = (ir_out[13:8]==6'h04); //(if d=0) w = f or w, (if d=1) f = f or w
assign MOVF = (ir_out[13:8]==6'h08);  //(if d=0) w = f, (if d=1) f = f
assign MOVWF = (ir_out[13:8]==6'h00 && ir_out[7]==1'b1);  //將w的值存入f
assign SUBWF = (ir_out[13:8]==6'h02);  //(if d=0) w = f - w,(if d=1) f = f - w
assign XORWF = (ir_out[13:8]==6'h06);   //(if d=0) w = f xor w ,(if d=1) f = f xor w
assign DECFSZ = (ir_out[13:8]==6'h0B);   //decrement(f=f-1) and skip if zero (if d=0) 存到W, (if d=1) 存到f
assign INCFSZ = (ir_out[13:8]==6'h0F);  //increment(a=f+1) and skip if zero (if d=0) 存到W, (if d=1) 存到f
assign BCF = (ir_out[13:10]==4'b0100);  //bit clear
assign BSF = (ir_out[13:10]==4'b0101);  //bit set
assign BTFSC = (ir_out[13:10]==4'b0110);  //bit test and skip if clear
assign BTFSS = (ir_out[13:10]==4'b0111);  //bit test and skip if set
assign ASRF = (ir_out[13:8]==6'h37);  //arithmetic shift right (if d=0) 存到W, (if d=1) 存到f
assign LSLF = (ir_out[13:8]==6'h35);  //logical shift left (if d=0) 存到W, (if d=1) 存到f
assign LSRF = (ir_out[13:8]==6'h36);  //logical  shift right (if d=0) 存到W, (if d=1) 存到f
assign RLF = (ir_out[13:8]==6'h0D);  //rotate left (if d=0) 存到W, (if d=1) 存到f
assign RRF = (ir_out[13:8]==6'h0C);  //rotate right  (if d=0) 存到W, (if d=1) 存到f
assign SWAPF = (ir_out[13:8]==6'h0E);  //swap nibbles in  f (if d=0) 存到W, (if d=1) 存到f
assign CALL = (ir_out[13:11]==3'b100);  //call subroutine
assign RETURN = (ir_out==14'b00_0000_0000_1000);  //return from subroutine
assign BRA = (ir_out[13:9]==5'b11001);  //relative branch
assign BRW = (ir_out==14'b00_0000_0000_1011);  //relative branch with W register
assign NOP = (ir_out==14'b00_0000_0000_0000);  //no operation

//BTFSC,BTFSS的跳躍
assign btfsc_skip_bit = (ram_out[sel_bit] == 0);
assign btfss_skip_bit = (ram_out[sel_bit] == 1);

//btfsc: 如過選擇的bit=0,就跳躍
//btfss: 如過選擇的bit=1,就跳躍
//以上兩種只要符合一個就跳躍
assign btfsc_btfss_skip_bit = (btfsc_skip_bit & BTFSC) | (btfss_skip_bit & BTFSS);


//ALU的運作
always @(*) begin
    case(op)
        6'h0: alu_out = mux1_out + w_out;
        6'h1: alu_out = mux1_out - w_out;
        6'h2: alu_out = mux1_out & w_out;
        6'h3: alu_out = mux1_out | w_out;
        6'h4: alu_out = mux1_out ^ w_out;
        6'h5: alu_out = mux1_out;
        6'h6: alu_out = mux1_out+1;
        6'h7: alu_out = mux1_out-1;
        6'h8: alu_out = 0;
        6'h9: alu_out = ~mux1_out;
        6'hA: alu_out = {mux1_out[7],mux1_out[7:1]};
        6'hB: alu_out = {mux1_out[6:0],1'b0};
        6'hC: alu_out = {1'b0,mux1_out[7:1]};
        6'hD: alu_out = {mux1_out[6:0],mux1_out[7]};
        6'hE: alu_out = {mux1_out[0],mux1_out[7:1]};
        6'hF: alu_out = {mux1_out[3:0],mux1_out[7:4]};
        default: alu_out = 8'hx;
    endcase 
end

//BCF MUX
always @(*) begin
    //讓第sel_bit個bit變成0
    case (sel_bit)
        3'b000: bcf_mux = ram_out & 8'hFE;
        3'b001: bcf_mux = ram_out & 8'hFD;
        3'b010: bcf_mux = ram_out & 8'hFB;
        3'b011: bcf_mux = ram_out & 8'hF7;
        3'b100: bcf_mux = ram_out & 8'hEF;
        3'b101: bcf_mux = ram_out & 8'hDF;
        3'b110: bcf_mux = ram_out & 8'hBF;
        3'b111: bcf_mux = ram_out & 8'h7F;
    endcase
end

//BSF MUX
always @(*) begin
    //讓第sel_bit個bit變成1
    case (sel_bit)
        3'b000: bsf_mux = ram_out | 8'h01;
        3'b001: bsf_mux = ram_out | 8'h02;
        3'b010: bsf_mux = ram_out | 8'h04;
        3'b011: bsf_mux = ram_out | 8'h08;
        3'b100: bsf_mux = ram_out | 8'h10;
        3'b101: bsf_mux = ram_out | 8'h20;
        3'b110: bsf_mux = ram_out | 8'h40;
        3'b111: bsf_mux = ram_out | 8'h80;
    endcase
end

//FSM
always @(*) begin
    //default值
    //****控制訊號記得歸零
    load_pc = 0;    //下一個clk要不要更新PC
    load_mar = 0;   //下一個clk要步要把PC的值存入MAR
    load_ir =0;     //下要不要把ROM輸出的指令存入IR
    load_w = 0;     //下一個clk要不要把alu_out的值存入w暫存器
    next_state = 0; //下一個state
    sel_pc = 0;   //下一個PC來自哪裡 (0:PC=PC+1, 1:PC=IR_out[10:0])
    sel_alu = 0;    //alu的輸入是哪裡 (0:IR_out[7:0], 1:ram_mux的輸出)
    op = 0;       //控制alu的op
    ram_en=0;       //下一個clk要不要把data_bus上的值存入ram
    sel_RAM_mux = 0;  //ram_mux的輸出是什麼 (0:ram_out, 1:ram_out經過BCF, 2:ram_out經過BSF)
    sel_bus=0;  //決定RAM的輸入來自哪裡(預設來自ALU)
    load_port_b=0; //下一個clk要不要把port_b
    push = 0; //下一個clk要不要push
    pop = 0; //下一個clk要不要pop
    reset_ir = 0; //下一個clk要不要把IRreset
    case (current_state)    
        T0: 
        begin
            next_state = T1;  //reset時的state
        end
        T1:
        begin
            load_mar = 1;  //下一個CLK時把現在的PC值存入MAR
            load_pc = 1;   //下一個clk把PC值更新為現在的PC值+1
            sel_pc = 0; //PC輸入來自PC+1
            next_state = T2;
        end
        T2:
        begin
            next_state = T3;
        end
        T3:
        begin
            load_ir = 1;  //下一個clk把ROM的輸出DATA(instruction)存入IR
            next_state = T4;  
        end
        T4:
        begin
            if(MOVLW)
            begin
                op = 6'h5;
                load_w = 1;
            end
            else if(ADDLW)
            begin
                op = 6'h0;
                load_w = 1;
            end
            else if(SUBLW)
            begin
                op = 6'h1;
                load_w = 1;
            end
            else if(ANDLW)
            begin
                op = 6'h2;
                load_w = 1;
            end
            else if(IORLW)
            begin
                op = 6'h3;
                load_w = 1;
            end
            else if(XORLW)
            begin
                op = 6'h4;
                load_w = 1;
            end
            else if(ADDWF)
            begin
                op = 6'h0;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                    ram_en=1;
            end
            else if(ANDWF)
            begin
                op = 6'h2;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                    ram_en=1;
            end
            else if(CLRF)
            begin
                op = 6'h8;
                ram_en=1;
            end
            else if(CLRW)
            begin
                op = 6'h8;
                sel_alu = 1;
                load_w=1;
            end
            else if(COMF)
            begin
                op = 6'h9;
                sel_alu = 1;
                ram_en = 1;
            end
            else if(DECF)
            begin
                op = 6'h7;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(INCF)
            begin
                op = 6'h6;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
                   
            end
            else if(IORWF)
            begin
                op = 6'h3;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
                   
            end
            else if(MOVF)
            begin
                op = 6'h5;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
                   
            end
            else if(MOVWF)
            begin
                sel_bus=1;
                if(addr_port_b==1'b1)
                    load_port_b = 1;
                else
                    ram_en=1;
            end
            if(SUBWF)
            begin
                op = 6'h1;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
                   
            end
            else if(XORWF)
            begin
                op = 6'h4;
                sel_alu = 1;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end    
            end
            else if(BCF)
            begin
                sel_alu=1;
                sel_RAM_mux=1;
                op = 6'h5;
                sel_bus=0;
                ram_en=1;
            end
            else if(BSF)
            begin
                sel_alu=1;
                sel_RAM_mux=2;
                op = 6'h5;
                sel_bus=0;
                ram_en=1;
            end
            else if(ASRF)
            begin
                sel_alu=1;
                sel_RAM_mux=0;
                op = 6'hA;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(LSLF)
            begin
                sel_alu=1;
                sel_RAM_mux=0;
                op = 6'hB;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(LSRF)
            begin
                sel_alu=1;
                sel_RAM_mux=0;
                op = 6'hC;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(RLF)
            begin
                sel_alu=1;
                sel_RAM_mux=0;
                op = 6'hD;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(RRF)
            begin
                sel_alu=1;
                sel_RAM_mux=0;
                op = 6'hE;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(SWAPF)
            begin
                sel_alu=1;
                sel_RAM_mux=0;
                op = 6'hF;
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end
            end
            else if(CALL)
            begin
                push = 1;
            end
            else if(NOP)
            begin
                //DO NOTHING
            end
            

            load_mar = 1;  //下一個CLK時把現在的PC值存入MAR
            load_pc = 1;   //下一個clk把PC值更新為現在的PC值+1
            sel_pc = 0; //PC輸入來自PC+1
            next_state = T5; 
        end
        T5:
        begin
            if(GOTO)
            begin
                sel_pc=1;
                load_pc=1;
            end
            else if(RETURN)
            begin
                sel_pc = 2;
                load_pc = 1;
                pop = 1;
            end
            else if(BRA)
            begin
                load_pc = 1;
                sel_pc = 3;
            end
            else if(BRW)
            begin
                load_pc = 1;
                sel_pc = 4;
            end
            else if(CALL)
            begin
                sel_pc = 1;
                load_pc = 1;
            end
            next_state = T6;  
        end
        T6:
        begin
            if(GOTO)
            begin
                reset_ir=1;
            end
            else if(RETURN)
            begin
                reset_ir=1;
            end
            else if(DECFSZ)
            begin
                sel_alu = 1;
                op = 6'h7;  //減一
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end   
                //如果減一後(alu_out) 等於0,則再跳到下一個instruction
                if(aluout_zero==1)
                begin
                    reset_ir=1;
                end
            end
            else if(INCFSZ)
            begin
                sel_alu = 1;
                op = 6'h6; //加一
                if(ir_out[7]==1'b0)
                    load_w=1;
                else
                begin
                    ram_en=1;
                    sel_bus=0;
                end  
                if(aluout_zero==1)
                begin
                    reset_ir=1;
                end
            end
            else if(BTFSS || BTFSC)
            begin
                if(btfsc_btfss_skip_bit==1)  
                begin
                    reset_ir=1;
                end
            end
            else if(BRA)
            begin
                reset_ir=1;
            end
            else if(BRW)
            begin
                reset_ir=1;
            end
            else if(CALL)
            begin
                reset_ir=1;
            end
               
            load_ir = 1;
            next_state = T4;  //T6之後會再跳回T4
        end
    endcase 
end 
endmodule
