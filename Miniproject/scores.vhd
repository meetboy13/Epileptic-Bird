library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use ieee.std_logic_arith.all;
use ieee.STD_LOGIC_unsigned.all;

ENTITY Scores IS
	PORT(	clock_25Mhz, reset, mode		: IN	STD_LOGIC;
			score : in std_LOGIC_VECTOR(7 downto 0);
			difficulty	: OUT	STD_LOGIC_VECTOR(1 downto 0);
			highscore : out std_LOGIC_VECTOR(7 dowNTO 0);
			leds : out std_logic_vector(2 downto 0)
			);
END Scores;

ARCHITECTURE a OF Scores IS
	
BEGIN

process(reset, score, mode)
variable highs : std_LOGIC_VECTOR(7 downto 0) := "00000010";
variable hard : std_LOGIC_VECTOR(1 downto 0) := "00";
variable ssdps : std_LOGIC_VECTOR(2 downto 0) := "111";
begin
	if (reset= '1') then
		highs := "00000010";
		hard := "00";
		ssdps := "111";
	elsif (mode = '0') then
		if (unsigned(score) >  conv_unsigned (56,8)) then
			hard := "10";
			ssdps := "000";
		elsif (unsigned(score) >  conv_unsigned (19,8)) then
			hard := "01";
			ssdps := "100";
		else
			hard := "00";
			ssdps := "110";
		end if;
		if (unsigned(score) > unsigned(highs)) then
			highs := score;
		end if;
	else
		ssdps := "110";
	end if;
	highscore<=highs;
	difficulty<=hard;
	leds <= ssdps;
end process;
END a;