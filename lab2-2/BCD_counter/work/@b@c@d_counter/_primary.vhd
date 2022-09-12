library verilog;
use verilog.vl_types.all;
entity BCD_counter is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic
    );
end BCD_counter;
