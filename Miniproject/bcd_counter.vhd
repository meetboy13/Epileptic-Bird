library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

entity bcd_counter is 
	port( direction,reset,clk : in std_logic;
			overflow :out std_logic;
			count : out std_logic_vector(3 downto 0));
end bcd_counter;

architecture beh of bcd_counter is
begin
process (clk,reset)
variable temp_count : std_logic_vector(3 downto 0) := "0000";
begin
	if (reset = '1') then
		overflow <= '0';
		if (direction = '1') then
			temp_count := "0000";
		else
			temp_count := "1001";
		end if;
	elsif (rising_edge(clk)) then
		overflow <= '0';
		if (direction = '1') then
			if (temp_count = "1001") then
				temp_count := "0000";
				overflow <= '1';
			else
				temp_count := temp_count + 1;
			end if;
		else
			if (temp_count = "0000") then
				temp_count := "1001";
				overflow <= '1';
			else
				temp_count := temp_count - 1;
			end if;
		end if;
	end if;
	count <= temp_count;
end process;
end beh;