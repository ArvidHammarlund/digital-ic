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

architecture dataflow of proc_bus is
begin

    busOut <= imDataOut when busSel(0) = '1' else (others => 'Z');
    busOut <= dmDataOut when busSel(1) = '1' else (others => 'Z');
    busOut <= accOut when busSel(2) = '1' else (others => 'Z');
    busOut <= extIn when busSel(3) = '1' else (others => 'Z');

end architecture dataflow;
