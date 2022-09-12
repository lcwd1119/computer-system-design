library verilog;
use verilog.vl_types.all;
entity pipeline_ALU is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        A               : in     vl_logic_vector(4 downto 0);
        B               : in     vl_logic_vector(4 downto 0);
        C               : in     vl_logic_vector(4 downto 0);
        D               : in     vl_logic_vector(4 downto 0);
        E               : in     vl_logic_vector(4 downto 0);
        S               : out    vl_logic_vector(4 downto 0)
    );
end pipeline_ALU;
