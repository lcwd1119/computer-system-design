module Program_Rom(Rom_data_out, Rom_addr_in);

//---------
    output [13:0] Rom_data_out;
    input [10:0] Rom_addr_in; 
//---------
    
    reg   [13:0] data;
    wire  [13:0] Rom_data_out;
    
    always @(Rom_addr_in)
        begin
            case (Rom_addr_in)	
                11'h0 : data = 14'h30FE;		//MOVLW W<=8'hFE					W = 0xFE	
                11'h1 : data = 14'h00A5;		//MOVWF ram[37]<=8'hFE              ram[37] = 0xFE
                11'h2 : data = 14'h3002;		//MOVLW W<=2                        W = 0x02
                11'h3 : data = 14'h0725;		//ADDWF W <= W + ram[37]			W = 0x00  carry = 1	
                11'h4 : data = 14'h3D25;		//ADDWFC W <= W + ram[37] + carry   W = 0xFF  carry = 0
				11'h5 : data = 14'h3E01;		//ADDLW W <= W + 1                  W = 0x00  carry = 1
				11'h6 : data = 14'h0003;		//CSS carry_flag為1，會跳過兩個指令
				11'h7 : data = 14'h3E01;		//跳過
				11'h8 : data = 14'h3E01;		//跳過
				11'h9 : data = 14'h3E01;		//ADDLW W<=W+1						W = 0x01  carry = 0
				11'hA : data = 14'h0003;		//CSS carry_flag為0，正常執行
				11'hB : data = 14'h3000;		//MOVLW W<=1
				11'hC : data = 14'h3001;		//MOVLW W<=2
				11'hD : data = 14'h3002;		//MOVLW W<=3
				11'hE : data = 14'h280E;		//goto $
                11'hF : data = 14'h3400;		
                11'h10 : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule


