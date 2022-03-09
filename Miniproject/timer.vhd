library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all;


entity timer is
	port(clock, reset,enable : in std_logic;
			die : out std_logic;
			health_out : out std_logic_vector(1 downto 0));
end entity;

architecture arch of timer is
begin
process(clock, reset)
variable timer : std_logic_vector(22 downto 0) := "00000000000000000000000";
variable health : std_logic_vector (1 downto 0) := "11";
variable dead : std_logic := '0';
begin
	if (reset ='1') then
		health := "11";
		dead := '0';
	elsif(rising_edge(clock)) then
		if(timer >= "11111111111110000000000" and enable = '1') then
			timer := "00000000000000000000000";
			if (health > "00") then
				health := health -1;
				if (health = "00") then
				dead := '1';
				end if;
			end if;
		else
			if (timer < "11111111111111110000000" and enable = '0') then
				timer := timer + 1;
			end if;
			
		end if;
	end if;
	health_out <= health;
	die <= dead;
end process;
end arch;