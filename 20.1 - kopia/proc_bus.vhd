library ieee;
use ieee.std_logic_1164.all;

library work;
use work.chacc_pkg.all;

entity proc_bus is
    port (
        busSel     : in std_logic_vector(3 downto 0);
        imDataOut  : in std_logic_vector(7 downto 0);
        dmDataOut  : in std_logic_vector(7 downto 0);
        accOut     : in std_logic_vector(7 downto 0);
        extIn      : in std_logic_vector(7 downto 0);
        busOut     : out std_logic_vector(7 downto 0)
    );
end proc_bus;