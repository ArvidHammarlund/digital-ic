library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.chacc_pkg.all;

entity alu is
    generic (width: integer := 8);
    port(
        alu_inA, alu_inB: in std_logic_vector(width-1 downto 0);
        alu_op: in std_logic_vector(1 downto 0);
        E,Z: out std_logic;
        alu_out: out std_logic_vector(width-1 downto 0)
    );
end alu;

architecture dataflow of alu is
	signal alu_inB_greyBox : std_logic_vector(width-1 downto 0);
	signal mux_high : std_logic_vector(width-1 downto 0);
	signal mux_low : std_logic_vector(width-1 downto 0);
	signal xor_ab : std_logic_vector(width-1 downto 0);
	signal and_ab : std_logic_vector(width-1 downto 0);
	signal not_b : std_logic_vector(width-1 downto 0);
	signal alu_out_int : std_logic_vector(width-1 downto 0);
	begin

	xor_ab <= alu_inA xor alu_inB;
	and_ab <= alu_inA and alu_inB;
	not_b <= not alu_inB;

	MUX_greyBox : entity work.mux
		port map(
		s => alu_op(0),
		i0 => alu_inB,
		i1 => not_b,
		o => alu_inB_greyBox
	);

	ADD : entity work.csa
		port map(
		A => alu_inA,
		B => alu_inB_greyBox,
		cin => alu_op(0),
		O => mux_low,
		cout => open
	);

	MUX_OUT_HIGH : entity work.mux
		port map(
		s => alu_op(0),
		i0 => xor_ab,
		i1 => and_ab,
		o => mux_high
	);

	MUX_OUT_FINAL : entity work.mux
		port map(
		s => alu_op(1),
		i0 => mux_high,
		i1 => mux_low,
		o => alu_out_int
	);

	alu_out <= alu_out_int;
	Z <= not OR_REDUCE(alu_out_int);

	CMP : entity work.cmp
		port map(
		a => alu_inA,
		b => alu_inB,
		e => E
	);
end dataflow;

