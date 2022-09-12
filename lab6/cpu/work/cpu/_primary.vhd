library verilog;
use verilog.vl_types.all;
entity cpu is
    generic(
        T0              : integer := 0;
        T1              : integer := 1;
        T2              : integer := 2;
        T3              : integer := 3;
        T4              : integer := 4;
        T5              : integer := 5;
        T6              : integer := 6;
        T7              : integer := 7;
        MOVLW           : vl_logic_vector(0 to 5) := (Hi1, Hi1, Hi0, Hi0, Hi0, Hi0);
        ADDLW           : vl_logic_vector(0 to 5) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi0);
        SUBLW           : vl_logic_vector(0 to 5) := (Hi1, Hi1, Hi1, Hi1, Hi0, Hi0);
        ANDLW           : vl_logic_vector(0 to 5) := (Hi1, Hi1, Hi1, Hi0, Hi0, Hi1);
        IORLW           : vl_logic_vector(0 to 5) := (Hi1, Hi1, Hi1, Hi0, Hi0, Hi0);
        XORLW           : vl_logic_vector(0 to 5) := (Hi1, Hi1, Hi1, Hi0, Hi1, Hi0)
    );
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        w_q             : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of T0 : constant is 1;
    attribute mti_svvh_generic_type of T1 : constant is 1;
    attribute mti_svvh_generic_type of T2 : constant is 1;
    attribute mti_svvh_generic_type of T3 : constant is 1;
    attribute mti_svvh_generic_type of T4 : constant is 1;
    attribute mti_svvh_generic_type of T5 : constant is 1;
    attribute mti_svvh_generic_type of T6 : constant is 1;
    attribute mti_svvh_generic_type of T7 : constant is 1;
    attribute mti_svvh_generic_type of MOVLW : constant is 1;
    attribute mti_svvh_generic_type of ADDLW : constant is 1;
    attribute mti_svvh_generic_type of SUBLW : constant is 1;
    attribute mti_svvh_generic_type of ANDLW : constant is 1;
    attribute mti_svvh_generic_type of IORLW : constant is 1;
    attribute mti_svvh_generic_type of XORLW : constant is 1;
end cpu;
