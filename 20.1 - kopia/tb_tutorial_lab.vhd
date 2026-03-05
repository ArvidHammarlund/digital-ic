library IEEE;
use IEEE.std_logic_1164.all;

entity tb_tutorial_lab is
end entity tb_tutorial_lab;

architecture tb_tutorial_lab_arch of tb_tutorial_lab is

    -- Component Declaration for the Unit Under Test (UUT)
    -- Component name and port declaration must match the actual design
    component tutorial_lab
        port(a      : in  STD_LOGIC_VECTOR(2 DOWNTO 0);
             b       : in  STD_LOGIC_VECTOR(2 DOWNTO 0);
             c       : in  STD_LOGIC_VECTOR(2 DOWNTO 0);
             d       : in  STD_LOGIC_VECTOR(2 DOWNTO 0);
             clk     : in  STD_LOGIC;
             resetn  : in  STD_LOGIC;
             sel     : in  STD_LOGIC_VECTOR(1 downto 0);
             output  : out STD_LOGIC_VECTOR(2 DOWNTO 0));
    end component;

    -- Signals to connect to Design Under Test (DUT)
    signal tb_a : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_b : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_c : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_d : std_logic_vector(2 downto 0) := (others => '0');
    signal tb_clk : std_logic := '0';
    signal tb_resetn : std_logic := '0';
    signal tb_sel : std_logic_vector(1 downto 0) := (others => '0');
    signal tb_output : std_logic_vector(2 downto 0);

    -- Clock period definition
    constant c_CLK_PERIOD : time := 50 ns;
begin
    -- Instantiate the DUT. Assign signals to DUT inputs and outputs
    DUT: tutorial_lab
        port map (
            a      => tb_a,
            b      => tb_b,
            c      => tb_c,
            d      => tb_d,
            clk    => tb_clk,
            resetn => tb_resetn,
            sel    => tb_sel,
            output  => tb_output
        );

    -- Clock generation
    -- Process runs indefinitely to generate clock signal
    clk_process : process
    begin
        wait for c_CLK_PERIOD / 2;
        tb_clk <= not tb_clk;
    end process;


    -- Stimulus process
    test_process : process
    begin
        tb_resetn <= '0'; -- Apply reset
        wait for 150 ns;
        tb_resetn <= '1'; -- Release reset and start normal operation
        tb_a <= "000";
        tb_b <= "001";
        tb_c <= "111";
        tb_d <= "101";
        tb_sel <= "11";
        wait for 300 ns;
        tb_sel <= "10"; -- All other inputs remain unchanged
        wait for 300 ns;
        tb_sel <= "01";
        wait for 300 ns;
        tb_sel <= "00";
        wait;
    end process;
end architecture tb_tutorial_lab_arch;