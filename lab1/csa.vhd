LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY csa IS

    generic (
        N : integer := 8
    );

	PORT(
	     op1: IN STD_LOGIC_VECTOR(N-1 downto 0);
	     op2: IN STD_LOGIC_VECTOR(N-1 downto 0);
	     carry_in: IN STD_LOGIC;
	     result: OUT STD_LOGIC_VECTOR(N-1 downto 0);
	     carry_out: OUT STD_LOGIC
	);

END csa;

ARCHITECTURE structural OF csa IS

    COMPONENT rca_4bit
        PORT (
            a    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            b    : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            cin  : IN  STD_LOGIC;
            sum  : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            cout : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Intermediate signals
    signal c_low : std_logic;
    signal sum_u0, sum_u1 : std_logic_vector(3 downto 0);
    signal cout_u0, cout_u1 : std_logic;

BEGIN
	-- 1. Lower 4 bits (always uses actual cin)
    RCAL: rca_4bit PORT MAP (
        a   => a(3 downto 0), 
		b   => b(3 downto 0), 
		cin => cin,
        sum => sum(3 downto 0), 
		cout => c_low
    );

    -- 2. Upper 4 bits assuming Carry-in is 0
    RCAU0: rca_4bit PORT MAP (
        a   => a(7 downto 4), 
		b   => b(7 downto 4), 
		cin => '0',
        sum => sum_u0, 
		cout => cout_u0
    );

    -- 3. Upper 4 bits assuming Carry-in is 1
    RCAU1: rca_4bit PORT MAP (
        a   => a(7 downto 4), 
		b   => b(7 downto 4), 
		cin => '1',
        sum => sum_u1, cout => cout_u1
    );

    -- 4. Multiplexers (Muxes) to select correct upper sum and cout
    sum(7 downto 4) <= sum_u0 WHEN (c_low = '0') ELSE sum_u1;
    cout            <= cout_u0 WHEN (c_low = '0') ELSE cout_u1;

END structural;