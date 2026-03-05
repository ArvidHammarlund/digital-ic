library IEEE;
use IEEE.std_logic_1164.all;

entity rca_testbench is
end rca_testbench;

architecture behavorial of rca_testbench is

    generic (width: integer := 4);

    signal A, B: std_logic_vector(width-1 downto 0);
    signal cin: std_logic;
    signal O: std_logic_vector(width-1 downto 0);
    signal cout: std_logic;

begin

end architecture;
