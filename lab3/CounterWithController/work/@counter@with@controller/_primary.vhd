library verilog;
use verilog.vl_types.all;
entity CounterWithController is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        loadw           : in     vl_logic;
        finalout        : out    vl_logic_vector(3 downto 0)
    );
end CounterWithController;
