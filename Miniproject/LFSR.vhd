library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
Generic( seed : std_logic_vector(7 downto 0) := "11100110"
);
Port( clk : in std_logic;
		rand : out std_logic_vector(7 downto 0)
);
end LFSR;

architecture behaviour of LFSR is
signal SR : std_logic_vector(7 downto 0) := seed;

begin
process(clk)
	begin
	if (rising_edge(clk)) then
		SR<=SR(6 downto 4) & (SR(7) XOR SR(3)) & (SR(7) XOR SR(2)) & (SR(7) XOR SR(1)) & SR(0) & SR(7) ;
	end if;
end process;
rand <= SR;	
end behaviour;