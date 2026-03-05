library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity EDA322_processor is
    generic (dInitFile : string := "d_memory_lab2.mif";
             iInitFile : string := "i_memory_lab2.mif");
    port(
        clk                : in  std_logic;
        resetn             : in  std_logic;
        master_load_enable : in  std_logic;
        extIn              : in  std_logic_vector(7 downto 0);
        inValid            : in  std_logic;
        outReady           : in  std_logic;
        pc2seg             : out std_logic_vector(7 downto 0);
        imDataOut2seg      : out std_logic_vector(11 downto 0);
        dmDataOut2seg      : out std_logic_vector(7 downto 0);
        aluOut2seg         : out STD_LOGIC_VECTOR(7 downto 0);
        acc2seg            : out std_logic_vector(7 downto 0);
        busOut2seg         : out std_logic_vector(7 downto 0);
        extOut             : out std_logic_vector(7 downto 0);
        inReady            : out std_logic;
        outValid           : out std_logic
    );
end EDA322_processor;