library verilog;
use verilog.vl_types.all;
entity clock is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic
    );
end clock;
