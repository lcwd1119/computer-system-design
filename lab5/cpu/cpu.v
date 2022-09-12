module cpu (
    input reset,clk,
    output reg [13:0] ir_out
);
    //設置狀態
    parameter T0 = 0;
    parameter T1 = 1;
    parameter T2 = 2;
    parameter T3 = 3;

    reg load_pc,load_mar,load_ir;
    wire [13:0] ir_in;
    reg [10:0] pc_out,mar_out;
    reg [2:0] ps,ns;
    wire [10:0]pc_next;
    
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
        if(load_mar)
            mar_out <= pc_out;
    end

    //用位址在ROM裡面讀出DATA
    ROM rom(.Rom_data_out(ir_in), .Rom_addr_in(mar_out));

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

    //fetch cycle FSM
    always @(*) begin
        //defult
        ns = T0;
        load_pc = 0;
        load_mar = 0;
        load_ir = 0;
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
                ns = T1;
                load_ir = 1;
            end 
        endcase
    end
endmodule
