module seven_seg_decoder (
    input wire[3:0] data_in,
    output reg[6:0] hex_out
);

    always @(data_in) begin
        case (data_in)
            4'h0:  hex_out = 8'b11000000;
            4'h1:  hex_out = 8'b11111001;
            4'h2:  hex_out = 8'b10100100;
            4'h3:  hex_out = 8'b10110000;
            4'h4:  hex_out = 8'b10011001;
            4'h5:  hex_out = 8'b10010010;
            4'h6:  hex_out = 8'b10000010;
            4'h7:  hex_out = 8'b11111000;
            4'h8:  hex_out = 8'b10000000;
            4'h9:  hex_out = 8'b10010000;
            4'hA:  hex_out = 8'b10001000;
            4'hB:  hex_out = 8'b10000011;
            4'hC:  hex_out = 8'b11000110;
            4'hD:  hex_out = 8'b10100001; 
            4'hE:  hex_out = 8'b10000110; 
            4'hF:  hex_out = 8'b10001110; 
            default: hex_out = 8'h00;
        endcase
    end
    
endmodule
