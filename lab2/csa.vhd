
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

entity csa is
    port(
        A, B: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        O: out std_logic_vector(7 downto 0)
    );
end csa;