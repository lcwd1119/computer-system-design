library verilog;
use verilog.vl_types.all;
entity RYG_FSM is
    port(
        rst             : in     vl_logic;
        clk             : in     vl_logic;
        R               : out    vl_logic_vector(1 downto 0);
        Y               : out    vl_logic_vector(1 downto 0);
        G               : out    vl_logic_vector(1 downto 0)
    );
end RYG_FSM;
