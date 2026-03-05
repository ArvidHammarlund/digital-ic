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