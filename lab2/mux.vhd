library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.chacc_pkg.all;

entity mux is
    generic (d_width: integer := 8);
    port (
        s : in std_logic;
        i0 : in std_logic_vector(d_width-1 downto 0);
        i1 : in std_logic_vector(d_width-1 downto 0);
        o : out std_logic_vector(d_width-1 downto 0)
    );
end mux;