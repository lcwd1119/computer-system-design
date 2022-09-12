library verilog;
use verilog.vl_types.all;
entity ALU is
    port(
        A               : in     vl_logic_vector(7 downto 0);
        B               : in     vl_logic_vector(7 downto 0);
        op              : in     vl_logic_vector(2 downto 0);
        S               : out    vl_logic_vector(7 downto 0)
    );
end ALU;
