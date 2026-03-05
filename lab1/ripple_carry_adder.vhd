LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ripple_carry_adder IS

    generic (
        N : integer := 8
    );

	PORT(
	     op1         : IN  STD_LOGIC_VECTOR(N-1 downto 0);
	     op2         : IN  STD_LOGIC_VECTOR(N-1 downto 0);
	     carry_in    : IN  STD_LOGIC;
	     result      : OUT STD_LOGIC_VECTOR(N-1 downto 0);
	     carry_out   : OUT STD_LOGIC
	);

END ripple_carry_adder;

ARCHITECTURE structural OF ripple_carry_adder IS

    SIGNAL carry_buffer : STD_LOGIC_VECTOR(N downto 0);

    component full_adder is
        PORT (
            op1       : IN  STD_LOGIC;
            op2       : IN  STD_LOGIC;
            carry_in  : IN  STD_LOGIC;
            carry_out : OUT STD_LOGIC;
            result    : OUT STD_LOGIC;
        );
    END COMPONENT;

BEGIN

    carry_buffer(0) <= carry_in;
    carry_out <= carry_buffer(N);

    gen_adder: FOR i IN 0 TO N-1 GENERATE
        inst_full_adder: full_adder PORT MAP(
            op1         => op1(i),
            op2         => op2(i),
            carry_in    => carry_buffer(i),
            carry_out   => carry_buffer(i+1),
            result      => result(i)
        );
    END GENERATE gen_adder;

END structural;