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
                10'h0 : data = 14'h01A5;        //CLRF          ram[25]=0
                10'h1 : data = 14'h0103;        //CLRW          w=0
                10'h2 : data = 14'h3007;        //MOVLW 7       w<=7
                10'h3 : data = 14'h07A5;        //ADDWF 0x25,1  ram[25]<=ram[25]+w ram[25]=7
                10'h4 : data = 14'h3005;        //MOVLW 5       w<=5
                10'h5 : data = 14'h0AA5;        //INCF  0x25,1  ram[25]=8
                10'h6 : data = 14'h04A5;        //IORWF 0x25,1  ram[25]=D
                10'h7 : data = 14'h00A4;        //MOVWF 0x24    ram[24]=5
                10'h8 : data = 14'h0225;        //SUBWF 0x25,0  w<=8
                10'h9 : data = 14'h0825;        //MOVF  0x25,0  w<=D
                10'ha : data = 14'h06A4;        //XORWF 0x24,1  ram[24]=8
                10'hb : data = 14'h280B;        //GOTO
                //這兩行為MPLAB清除暫存器的指令，不用管
                10'hc : data = 14'h3400;
                10'hd : data = 14'h3400;
                default: data = 14'h0;   
            endcase
        end

     assign Rom_data_out = data;

endmodule
