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
                10'h0 : data = 14'h01A5;    //CLRF              ram[25]=0
                10'h1 : data = 14'h0103;    //CLRW              w=0
                10'h2 : data = 14'h3006;    //MOVLW 6           w=6
                10'h3 : data = 14'h07A5;    //ADDWF 0x25,1      ram[25]=6
                10'h4 : data = 14'h3005;    //ADDLW 5           w=5
                10'h5 : data = 14'h0725;    //ADDWF 0x25,0      w=11
                10'h6 : data = 14'h3E02;    //ADDLW 2           w=13
                10'h7 : data = 14'h05A5;    //ANDWF 0x25,1      ram[25]=4
                10'h8 : data = 14'h03A5;    //DECF  0x25        ram[25]=3
                10'h9 : data = 14'h09A5;    //COMF  0x25        ram[25]=252
                10'ha : data = 14'h280A;    //GOTO  8
                //這兩行為MPLAB清除暫存器的指令，不用管
                10'hb : data = 14'h3400;
                10'hc : data = 14'h3400;
                default: data = 14'h0;
            endcase
        end

     assign Rom_data_out = data;

endmodule
