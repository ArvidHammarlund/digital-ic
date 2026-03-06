library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic (width: integer := 8);
    port (
        
        clk, rstn, en: in std_logic;
        d: in std_logic_vector(width-1 downto 0);
        q: out std_logic_vector(width-1 downto 0)
    );
end entity reg;

architecture behavorial of reg is
begin
    process(clk, rstn)
    begin
	if rstn = '0' then
	    q <= "00000000";

	elsif rising_edge(clk) then
	    if en = '1' then
		q <= d;
	    end if;
	end if;
    end process;
end behavorial;