library IEEE;
use IEEE.std_logic_1164.all;

entity tb_csa is
end entity tb_csa;

architecture BEHAVORIAL of tb_csa is

component csa_tb

    port(A, B: in std_logic_vector(7 downto 0);
        cin: in std_logic;
        cout: out std_logic;
        O: out std_logic_vector(7 downto 0)
    );
end component;

signal a_tb: std_logic_vector(7 downto 0):= (others => '0');
signal b_tb: std_logic_vector(7 downto 0):= (others => '0');
signal cin_tb: std_logic := '0';
signal cout_tb: std_logic := '0';
signal o_tb: std_logic_vector(7 downto 0) := (others => '0');

begin
DUT: entity work.csa
    port map (
        A => a_tb,  
        B => b_tb,
	cin => cin_tb,
        cout => cout_tb,
        O => o_tb);

Testing: PROCESS
 BEGIN
 
    a_tb <= "00000001";
    b_tb <= "00000001";
    cin_tb <= '0';
    wait for 10 ns;

    a_tb <= "01010101";
    b_tb <= "10101010";
    cin_tb <= '1';
    wait for 10 ns;

    a_tb <= "11111111";
    b_tb <= "11111111";
    cin_tb <= '0';
    wait for 10 ns;

    a_tb <= "11111111";
    b_tb <= "11111111";
    cin_tb <= '1';
    wait for 10 ns;

 END PROCESS;
END architecture BEHAVORIAL;