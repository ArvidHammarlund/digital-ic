LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY full_adder IS
	PORT (
		op1       : IN  STD_LOGIC;
		op2       : IN  STD_LOGIC;
		carry_in  : IN  STD_LOGIC;
		carry_out : OUT STD_LOGIC;
		result    : OUT STD_LOGIC;
	);
END full_adder;

ARCHITECTURE dataflow OF full_adder IS
BEGIN
	result    <= (op1 XOR op2) XOR carry_in;
    carry_out <= (carry_in and (op1 xor op2)) or (op1 and op2);
END dataflow;