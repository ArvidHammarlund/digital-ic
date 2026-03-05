library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.chacc_pkg.all;

entity proc_controller is
    port (
        clk: in std_logic;
        resetn: in std_logic;
        master_load_enable: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        e_flag: in std_logic;
        z_flag: in std_logic;
        inValid: in std_logic;
        outReady: in std_logic;

       	busSel: out std_logic_vector(3 downto 0);
        pcSel: out std_logic;
        pcLd: out std_logic;
        imRead: out std_logic;
        dmRead: out std_logic;
        dmWrite: out std_logic;
        aluOp: out std_logic_vector(1 downto 0);
        flagLd: out std_logic;
        accSel: out std_logic;
        accLd: out std_logic;
        inReady: out std_logic;
        outValid: out std_logic
    );
end proc_controller;