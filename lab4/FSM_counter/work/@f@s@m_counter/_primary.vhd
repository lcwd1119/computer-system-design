library verilog;
use verilog.vl_types.all;
entity FSM_counter is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        port_A          : out    vl_logic_vector(7 downto 0);
        port_B          : out    vl_logic_vector(7 downto 0)
    );
end FSM_counter;
