library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_misc.all;

entity controller_tb is
end controller_tb;

architecture tb of controller_tb is
    component controller_golden is
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
    end component;
    component proc_controller is
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
    end component;

    constant CLK_PERIOD : time := 10 ns;


    signal clk: std_logic := '0';
    signal resetn: std_logic := '0';
    signal master_load_enable: std_logic := '0';
    signal opcode: std_logic_vector(3 downto 0) := (others => '0');
    signal e_flag, z_flag, inValid, outReady: std_logic := '0';

    signal busSel, g_busSel: std_logic_vector(3 downto 0);
    signal pcSel, g_pcSel: std_logic;
    signal pcLd, g_pcLd: std_logic;
    signal imRead, g_imRead: std_logic;
    signal dmRead, g_dmRead: std_logic;
    signal dmWrite, g_dmWrite: std_logic;
    signal aluOp, g_aluOp: std_logic_vector(1 downto 0);
    signal flagLd, g_flagLd: std_logic;
    signal accSel, g_accSel: std_logic;
    signal accLd, g_accLd: std_logic;
    signal inReady, g_inReady: std_logic;
    signal outValid, g_outValid: std_logic;

    signal check : std_logic_vector(11 downto 0);
    type op_enum is (op_NOOP,op_IN,op_OUT,op_MOV,op_J,op_JE,op_JNZ,op_CMP,op_XOR,op_AND,op_ADD,op_SUB,op_LB,op_SB,op_LBI,op_SBI);
    signal current_op : op_enum;

begin

current_op <= op_enum'val(to_integer(unsigned(opcode)));

golden_ref: controller_golden port map (
    clk => clk,
    resetn => resetn,
    master_load_enable => master_load_enable,
    opcode => opcode,
    e_flag => e_flag,
    z_flag => z_flag,
    inValid => inValid,
    outReady => outReady,

    busSel => g_busSel,
    pcSel => g_pcSel,
    pcLd => g_pcLd,
    imRead => g_imRead,
    dmRead => g_dmRead,
    dmWrite => g_dmWrite,
    aluOp => g_aluOp,
    flagLd => g_flagLd,
    accSel => g_accSel,
    accLd => g_accLd,
    inReady => g_inReady,
    outValid => g_outValid
);

DUT: proc_controller port map (
    clk => clk,
    resetn => resetn,
    master_load_enable => master_load_enable,
    opcode => opcode,
    e_flag => e_flag,
    z_flag => z_flag,
    inValid => inValid,
    outReady => outReady,

    busSel => busSel,
    pcSel => pcSel,
    pcLd => pcLd,
    imRead => imRead,
    dmRead => dmRead,
    dmWrite => dmWrite,
    aluOp => aluOp,
    flagLd => flagLd,
    accSel => accSel,
    accLd => accLd,
    inReady => inReady,
    outValid => outValid
);

`protect begin_protected
`protect version = 1
`protect encrypt_agent = "ModelSim" , encrypt_agent_info = "2020.1"
`protect key_keyowner = "Mentor Graphics Corporation" , key_keyname = "MGC-VERIF-SIM-RSA-2"
`protect key_method = "rsa"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 256 )
`protect key_block
hzXHaqjCK1J8BDZG4ennPfe+pKD4I0hqDrEn7YC8+Qv6NR/tiWFA2glo1WolW5ph
g909+kJ97dLeTrkM0AwK9Z/K4/t0dOmNfer+C54EsM0vLg9LfNvcZtZ/bsptKXqz
XWzvPqC3FVhifFEcoMrxKwnHfTrZrVJND2mVc9CMsZXOXRBJ/RQe/29pYgBs0gI5
7nYP1n8yMBrffR/vjFHj1FRMSdupXXDqF3Shq7aNpcr01RG7ZloA8VksBF5HAlZz
DmQK8Yq5Vv2j/r/m+wvR6uQ0CNAN7c7k1KSjHY3UfaRO2YIfy4xgrp1I7a/hpMxi
RNMIE+YEiaXMT+2pWg5MXA==
`protect data_method = "aes128-cbc"
`protect encoding = ( enctype = "base64" , line_length = 64 , bytes = 2720 )
`protect data_block
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
`protect end_protected

end architecture tb;