--button_toggle.vhdl
--Generic button toggle

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;
 
entity button_toggle is  
	port
   (
			button, reset	   : in std_logic;
			toggle		: out std_logic
			); 
end entity; 
 
 
architecture Toggle of button_toggle is  
		signal bcnt: std_logic := '0';

begin
	process (button, reset)
	begin
		if reset = '1' then
			toggle <= '0';
			bcnt <= '0';
		elsif (rising_edge(button)) then
			if bcnt='0' then
				bcnt <= '1';
				toggle <= '1';
				
			else
				bcnt <= '0';
				toggle <= '0';
			end if;
		end if;
	end process;
end architecture;