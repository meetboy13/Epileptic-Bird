--Debouncer.vhdl
--This is a generic debouncer

library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 

entity Debouncer is 
	port (
				clk				: in std_logic;
				button_press 	: in std_logic;
				button 			: out std_logic
	);
end entity;

architecture debounce of Debouncer is 
begin
	process(clk)
		variable cnt : unsigned(20 downto 0) := "000000000000000000000";
		
	begin
			--when button hasn't been pressed for , output low
			if (rising_edge(clk)) then 
				if (button_press='1') then
					cnt := cnt + 1;
				else
					cnt := "000000000000000000000";
					button <= '0';
				end if;
		
				--when button is pressed long enough, output high
				if cnt = "010011000100101101000" then
					cnt := "010011000100101100111";
					button <= '1';
					
				end if;
			end if;
	end process;
end architecture;

