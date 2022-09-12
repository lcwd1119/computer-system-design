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

    reg load_pc,load_mar,load_ir,load_w,sel_pc,
        sel_alu,ram_en,sel_bus;
    wire[2:0] sel_bit;
    wire [13:0] ir_in;
    reg [13:0] ir_q;
    reg [10:0] pc_out,mar_q,pc_next;
    reg [3:0] ps,ns,op,sel_RAM_mux;
    wire [7:0] ram_out;
    reg [7:0] alu_q,mux1_out,databus,bcf_mux,bsf_mux,RAM_mux;
    
    //設置opcode狀態(如果直接assign預設是wire=>1'b)
    assign MOVLW = 6'b110000 == ir_q[13:8];
    assign ADDLW = 6'b111110 == ir_q[13:8];
    assign SUBLW = 6'b111100 == ir_q[13:8];
    assign ANDLW = 6'b111001 == ir_q[13:8];
    assign IORLW = 6'b111000 == ir_q[13:8];
    assign XORLW = 6'b111010 == ir_q[13:8];
    assign CLRF  = 7'b0000011 == ir_q[13:7];
    assign CLRW  = 7'b0000010 == ir_q[13:7];
    assign ADDWF = 6'b000111 == ir_q[13:8];
    assign ANDWF = 6'b000101 == ir_q[13:8];
    assign DECF  = 6'b000011 == ir_q[13:8];
    assign COMF  = 6'b001001 == ir_q[13:8];
    assign GOTO  = 3'b101    == ir_q[13:11];
    assign d     = ir_q[7];
    assign INCF  = 6'b001010 == ir_q[13:8];
    assign IORWF = 6'b000100 == ir_q[13:8];
    assign MOVF  = 6'b001000 == ir_q[13:8];
    assign MOVWF = 7'b0000001 == ir_q[13:7];
    assign SUBWF = 6'b000010 == ir_q[13:8];
    assign XORWF = 6'b000110 == ir_q[13:8];
    assign DECFSZ = 6'b001011 == ir_q[13:8];
    assign INCFSZ = 6'b001111 == ir_q[13:8];
    assign BCF = 4'b0100 == ir_q[13:10];
    assign BSF = 4'b0101 == ir_q[13:10];
    assign BTFSC = 4'b0110 == ir_q[13:10];
    assign BTFSS = 4'b0111 == ir_q[13:10];
    assign alu_zero = (alu_q == 0)? 1'b1: 1'b0;
    assign sel_bit = ir_q[9:7];
    //PC mux,選擇PC的input
    always @(*) begin
        if(sel_pc)
            pc_next = ir_q[10:0];
        else
            pc_next = pc_out + 1; //做PC+1算下一個PC
    end

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
        if(reset)
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

    //ALU
    always @(*) begin
        case (op)
            0:  alu_q = mux1_out + w_q;     //ADD
            1:  alu_q = mux1_out - w_q;     //SUB
            2:  alu_q = mux1_out & w_q;     //AND
            3:  alu_q = mux1_out | w_q;     //OR
            4:  alu_q = mux1_out ^ w_q;     //XOR
            5:  alu_q = mux1_out;           //copy
            6:  alu_q = mux1_out + 1;       //+1
            7:  alu_q = mux1_out - 1;       //-1
            8:  alu_q = 0;                  //reset
            9:  alu_q = ~mux1_out;          //反向
			default: alu_q = 8'bX;          //default
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
        op = 1'bx;
        sel_RAM_mux = 0;
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
            //看控制訊號,決定alu要做啥
            T4:begin
                ns = T5;
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
                    sel_pc = 1;
                    load_pc = 1;
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
                    ram_en = 1;
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
                    ram_en = 1;
                    sel_bus = 1;
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
                    op = 7;
                    sel_alu = 1;
                    if(alu_zero)begin
                        load_pc = 1;
                        sel_pc = 0;
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
                        load_pc = 1;
                        sel_pc = 0;
                    end
                    if(d)begin
                        ram_en = 1;
                        sel_bus = 0;
                    end
                    else
                        load_w = 1;
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
                    if(btfsc_btfss_skip_bit==1)begin
                        load_pc = 1;
                        sel_pc = 0;
                    end
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
