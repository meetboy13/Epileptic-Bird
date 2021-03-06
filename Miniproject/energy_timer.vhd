library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;


entity energy_timer is
	port(clock, reset,enable : in std_logic;
			item_picked_up : out std_logic);
end entity;

architecture arch of energy_timer is
begin
process(clock, reset)
variable timer : std_logic_vector(23 downto 0) := "000000000000000000000000";

begin
	if (reset ='1') then
		item_picked_up <= '0';
	elsif(rising_edge(clock)) then
		if(timer >= "111111111111110000000000" and enable = '1') then
			timer := "000000000000000000000000";
			item_picked_up <= '1';
		else
			if (timer < "111111111111111110000000" and enable = '0') then
				timer := timer + 1;
			end if;
			item_picked_up <= '0';
		end if;
	end if;
end process;
end arch;