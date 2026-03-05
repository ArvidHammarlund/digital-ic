library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.ALL;

library work;
use work.chacc_pkg.all;

entity memory is
    generic (DATA_WIDTH : integer := 8;
             ADDR_WIDTH : integer := 8;
             INIT_FILE : string := "memory.mif");
     port (
        clk     : in std_logic;
        readEn    : in std_logic;
        writeEn   : in std_logic;
        address : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dataIn  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        dataOut : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;