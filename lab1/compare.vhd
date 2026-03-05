LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY cmp IS
    generic (
        N : integer := 8
    );
	PORT (
		op1       : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		op2       : IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		result  : OUT STD_LOGIC;
	);
END cmp;

ARCHITECTURE dataflow OF cmp IS
    SIGNAL res : STD_LOGIC_VECTOR (N-1 DOWNTO 0);
    SIGNAL neq_int : STD_LOGIC; 
BEGIN
	res <= (op1 XOR op2);
	neq_int <= res(N-1) OR res(N-2) OR res(N-3) OR res(N-4) OR res(N-5) OR res(N-6) OR res(N-7) OR res(0);
	neq <= neq_int;
	eq <= NOT neq_int;
END dataflow;