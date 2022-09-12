module cpu (
    input reset,clk,
    output reg [7:0] port_b_out
);
    //設置狀態
    parameter T0 = 0;
    parameter T1 = 1;
    parameter T2 = 2;
    parameter T3 = 3;
    parameter T4 = 4;
    parameter T5 = 5;
    parameter T6 = 6;

    reg load_pc,load_mar,load_ir,load_w,load_port_b,
        sel_alu,ram_en,sel_bus,push,pop,reset_ir,carry;
    wire[2:0] sel_bit;
    wire [13:0] ir_in;
    reg [13:0] ir_q;
    reg [10:0] pc_out,mar_q,pc_next;
    wire [10:0] w_change,k_change,Stack_q;
    reg [4:0] ps,ns,op,sel_RAM_mux,sel_pc;
    wire [7:0] ram_out;
    reg [7:0] alu_q,mux1_out,databus,bcf_mux,bsf_mux,RAM_mux,w_q;
    
    //設置opcode狀態(如果直接assign預設是wire=>1'b)
    assign MOVLW       = 6'b110000  == ir_q[13:8];
    assign ADDLW       = 6'b111110  == ir_q[13:8];
    assign SUBLW       = 6'b111100  == ir_q[13:8];
    assign ANDLW       = 6'b111001  == ir_q[13:8];
    assign IORLW       = 6'b111000  == ir_q[13:8];
    assign XORLW       = 6'b111010  == ir_q[13:8];
    assign CLRF        = 7'b0000011 == ir_q[13:7];
    assign CLRW        = 12'b000001000000 == ir_q[13:2];
    assign ADDWF       = 6'b000111  == ir_q[13:8];
    assign ANDWF       = 6'b000101  == ir_q[13:8];
    assign DECF        = 6'b000011  == ir_q[13:8];
    assign COMF        = 6'b001001  == ir_q[13:8];
    assign GOTO        = 3'b101     == ir_q[13:11];
    assign INCF        = 6'b001010  == ir_q[13:8];
    assign IORWF       = 6'b000100  == ir_q[13:8];
    assign MOVF        = 6'b001000  == ir_q[13:8];
    assign MOVWF       = 7'b0000001 == ir_q[13:7];
    assign SUBWF       = 6'b000010  == ir_q[13:8];
    assign XORWF       = 6'b000110  == ir_q[13:8];
    assign DECFSZ      = 6'b001011  == ir_q[13:8];
    assign INCFSZ      = 6'b001111  == ir_q[13:8];
    assign BCF         = 4'b0100    == ir_q[13:10];
    assign BSF         = 4'b0101    == ir_q[13:10];
    assign BTFSC       = 4'b0110    == ir_q[13:10];
    assign BTFSS       = 4'b0111    == ir_q[13:10];
    assign ASRF        = 6'b110111  == ir_q[13:8];
    assign LSLF        = 6'b110101  == ir_q[13:8];
    assign LSRF        = 6'b110110  == ir_q[13:8];
    assign RLF         = 6'b001101  == ir_q[13:8];
    assign RRF         = 6'b001100  == ir_q[13:8];
    assign SWARF       = 6'b001110  == ir_q[13:8];
    assign CALL        = 3'b100     == ir_q[13:11];
    assign RETURN      = 14'b00000000001000  == ir_q[13:0];
    assign BRA         = 5'b11001   == ir_q[13:9];
    assign BRW         = 14'b00000000001011  == ir_q[13:0];
    assign NOP         = 14'b00000000000000  == ir_q[13:0];
    assign ADDWFC      = 6'b111101  ==  ir_q[13:8];
    assign CSS         = 14'b00000000000011  == ir_q[13:0];
    
    assign d           = ir_q[7];
    assign alu_zero    = (alu_q == 0)? 1'b1: 1'b0;
    assign sel_bit     = ir_q[9:7];
    assign addr_port_b = (ir_q[6:0] == 7'h0d);
    assign w_change    = {3'b0,w_q}-1;
    assign k_change    = {ir_q[8],ir_q[8],ir_q[8:0]}-1;

    //PC mux,選擇PC的input
    always @(*) begin
        case (sel_pc)
            0: pc_next = pc_out + 1; //做PC+1算下一個PC
            1: pc_next = ir_q[10:0];
            2: pc_next = Stack_q;
            3: pc_next = pc_out + k_change;
            4: pc_next = pc_out + w_change;
            default: pc_next = pc_out + 1; //做PC+1算下一個PC
        endcase
    end

    //PC,clock發生時把PC值copy到下一個
    always @(posedge clk) begin
        if(reset)
            pc_out <= 0;
        else
            if(load_pc)
                pc_out <= pc_next;
    end

    //Stack,clock發生時把跳躍時的PC值存進去
    stack Stack(.stack_out(Stack_q),
                .stack_in(pc_out),
                .push(push),.pop(pop),.reset(reset),.clk(clk));

    //MAR,clock發生時把data address傳到ROM
    always @(posedge clk) begin
        if(reset)
            mar_q <= 0;
        else
            if(load_mar)
                mar_q <= pc_out;
    end

    //用位址在Program_Rom裡面讀出DATA
    Program_Rom rom(.Rom_data_out(ir_in),
            .Rom_addr_in(mar_q));

    //IR,clock發生時把讀到的data copy到下一個
    always @(posedge clk) begin
        if(reset_ir)
            ir_q <= 0;
        else if (load_ir) begin
            ir_q <= ir_in;
        end
    end

    //update ps
    always @(posedge clk) begin
        if(reset)
            ps <= 0;
        else
            ps <= ns;
    end

    //ram MUX,選擇寫入的data
    always @(*) begin
        if(sel_bus)
            databus = w_q;
        else
            databus = alu_q;
    end

    //PORTB,對外的I/O port
    always @(posedge clk ) begin
        if(reset) port_b_out <= 0;
        else if(load_port_b) port_b_out <= databus;
    end

    //ram 可以做read&write
    single_port_ram_128x8 ram(
	.data(databus),
	.addr(ir_q[6:0]),
	.en(ram_en),
	.clk(clk),
	.q(ram_out)
);

    //btfss & btfsc mux,判斷要不要做btfss & btfsc的skip
    assign btfsc_skip_bit = ram_out[ir_q[9:7]]==0;
    assign btfss_skip_bit = ram_out[ir_q[9:7]]==1;
    assign btfsc_btfss_skip_bit = (BTFSC&btfsc_skip_bit)|(BTFSS&btfss_skip_bit);

    //bcf mux,輸出對指定的bit做clear的結果
    always @(*) begin
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

    //bsf mux,,輸出對指定的bit做set的結果   
    always @(*) begin
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

    //ram MUX,選擇輸出的data
    always @(*) begin
        case (sel_RAM_mux)
            0: RAM_mux = ram_out;
            1: RAM_mux = bcf_mux;
            2: RAM_mux = bsf_mux;
            default: RAM_mux = 8'bx;
        endcase
    end
    //ALU MUX,選擇input
    always @(*) begin
       if(sel_alu)
            mux1_out = RAM_mux;
        else
            mux1_out = ir_q[7:0];
    end

    //ALU carry flag,顯示有無carry
    always @(*) begin
        if(reset)
            carry = 0;
        else 
            if(d)
                carry = alu_zero;
            else
                carry = (w_q == 0);
    end

    //ALU
    always @(*) begin
        case (op)
            0:   alu_q = mux1_out + w_q;                //ADD
            1:   alu_q = mux1_out - w_q;                //SUB
            2:   alu_q = mux1_out & w_q;                //AND
            3:   alu_q = mux1_out | w_q;                //OR
            4:   alu_q = mux1_out ^ w_q;                //XOR
            5:   alu_q = mux1_out;                      //copy
            6:   alu_q = mux1_out + 1;                  //+1
            7:   alu_q = mux1_out - 1;                  //-1
            8:   alu_q = 0;                             //reset
            9:   alu_q = ~mux1_out;                     //反向
            10:  alu_q = {mux1_out[7],mux1_out[7:1]};   //右移,copy sign bit
            11:  alu_q = {mux1_out[6:0],1'b0};          //左移,補0
            12:  alu_q = {1'b0,mux1_out[7:1]};          //右移,補0
            13:  alu_q = {mux1_out[6:0],mux1_out[7]};   //循環左移
            14:  alu_q = {mux1_out[0],mux1_out[7:1]};   //循環右移
            15:  alu_q = {mux1_out[3:0],mux1_out[7:4]}; //高位組互換低位組
            16:  alu_q = mux1_out + w_q + carry;        //ADDC
			default: alu_q = 8'bx;                     //default
        endcase
    end

    //w_register, clock發生時把alu的結果copy到w_register
    always @(posedge clk) begin
        if(load_w)
            w_q <= alu_q;
    end

    //fetch cycle FSM
    always @(*) begin
        //defult
        ns = T0;
        load_pc = 0;
        load_mar = 0;
        load_ir = 0;
        load_w = 0;
        sel_pc = 0;
        sel_alu = 0;
        ram_en = 0;
        sel_bus = 0;
        op = 4'bx;
        sel_RAM_mux = 0;
        load_port_b = 0;
        pop = 0;
        push = 0;
        reset_ir = 0;
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
            //看控制訊號,決定alu要做啥，並且load MAR,load PC,load IR
            T4:begin
                ns = T5;
                load_mar = 1;
                load_pc = 1;    
                if(MOVLW)begin
                    op = 5;
                    load_w = 1;
                end
                else if(ADDLW)begin
                    op = 0;
                    load_w = 1;
                end
                else if(SUBLW)begin
                    op = 1;
                    load_w = 1;
                end
                else if(IORLW)begin
                    op = 3;
                    load_w = 1;
                end
                else if(XORLW)begin
                    op = 4;
                    load_w = 1;
                end
                else if(ANDLW)begin
                    op = 2;
                    load_w = 1;
                end
                else if(GOTO)begin
                    //NONE
                end
                else if(ADDWF)begin
                    op = 0;
                    sel_alu = 1;
                    if(d)
                        ram_en = 1;
                    else
                        load_w = 1;
                end
                else if(ANDWF)begin
                    op = 2;
                    sel_alu = 1;
                    case (d)
                        0:load_w = 1;
                        1:ram_en = 1;
                    endcase
                end
                else if(CLRF)begin
                    op = 8;
                    ram_en = 1;
                end
                else if(CLRW)begin
                    op = 8;
                    sel_alu = 1;
                    load_w = 1;
                end
                else if(COMF)begin
                    op = 9;
                    sel_alu = 1;
                    ram_en = 1;
                end
                else if(DECF)begin
                    op = 7;
                    sel_alu = 1;
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(INCF)begin
                    op = 6;
                    sel_alu = 1;
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(IORWF)begin
                    op = 3;
                    sel_alu = 1;
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(MOVF)begin
                    op = 5;
                    sel_alu = 1;
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(MOVWF)begin
                    sel_bus = 1;
                    if(addr_port_b)
                        load_port_b = 1;
                    else
                        ram_en = 1;
                    
                end
                else if(SUBWF)begin
                    op = 1;
                    sel_alu = 1;
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(XORWF)begin
                    op = 4;
                    sel_alu = 1;
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(DECFSZ)begin
                    //NONE
                end
                else if(INCFSZ)begin
                    //NONE
                end
                else if(BCF)begin
                    sel_alu = 1;
                    sel_RAM_mux = 1;
                    op = 5;
                    ram_en = 1;
                    sel_bus = 00;
                end
                else if(BSF)begin
                    sel_alu = 1;
                    sel_RAM_mux = 2;
                    op = 5;
                    ram_en = 1;
                    sel_bus = 0;
                end
                else if(BTFSC|BTFSS)begin
                    //NONE
                end
                else if(ASRF|LSLF|LSRF|RLF|RRF|SWARF)begin
                    sel_alu = 1;
                    sel_RAM_mux = 0;
                    if(d)begin
                        sel_bus = 0;
                        ram_en = 1;
                    end
                    else
                        load_w = 1;
                    if(ASRF)       op = 10;
                    else if(LSLF)  op = 11;
                    else if(LSRF)  op = 12;
                    else if(RLF)   op = 13;
                    else if(RRF)   op = 14;
                    else if(SWARF) op = 15;
                end
                else if(CALL)begin
                    push = 1;
                end
                else if(RETURN)begin
                    //NONE
                end
                else if(BRA)begin
                    //NONE
                end
                else if(BRW)begin
                    //NONE
                end
                else if(NOP)begin
                    //NONE
                end
                else if(ADDWFC)begin
                        op = 6;
                    sel_alu = 1;
                    if(d)
                        ram_en = 1;
                    else
                        load_w = 1;
                end
                else if(CSS)begin
                    if(carry)begin
                        load_pc = 1;
                    end
                    
                end
            end 
            //執行會跟下一個PC衝突的指令
            T5:begin
                ns = T6;
                if(GOTO)begin
                    sel_pc = 1;
                    load_pc = 1;
                end
                else if(CALL)begin
                    sel_pc = 1;
                    load_pc = 1;
                end
                else if(RETURN)begin
                    sel_pc = 2;
                    load_pc = 1;
                    pop = 1;
                end
                else if(BRA)begin
                    sel_pc = 3;
                    load_pc = 1;
                end
                else if(BRW)begin
                    sel_pc = 4;
                    load_pc = 1;
                end
                else if(ADDWFC)begin
                    if(carry)begin
                        op = 16;
                    sel_alu = 1;
                    if(d)
                        ram_en = 1;
                    else
                        load_w = 1;
                    end
                end
                else if(CSS)begin
                    if(carry)begin
                        load_pc = 1;
                    end   
                end
            end
            //跳回T4
            T6:begin
                ns = T4;
                load_ir = 1;
                if(GOTO|CALL|RETURN|BRA|BRW)begin
                    reset_ir = 1;
                end
                else if(DECFSZ)begin
                    op = 7;
                    sel_alu = 1;
                    if(alu_zero)begin
                       reset_ir = 1;
                    end
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(INCFSZ)begin
                    op = 6;
                    sel_alu = 1;
                    if(alu_zero)begin
                        reset_ir = 1;
                    end
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
                end
                else if(BTFSC|BTFSS)begin
                    if(btfsc_btfss_skip_bit==1)begin
                        reset_ir = 1;
                    end
                end
                 else if(CSS)begin
                    if(carry)begin
                        load_pc = 1;
                    end   
                end
            end
        endcase
    end
endmodule
