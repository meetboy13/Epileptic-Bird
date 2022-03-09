-- seven_seg_decoder.vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity seven_seg_decoder is
port (
	clk : in std_logic;
	bcd : in	std_logic_vector (3 downto 0);
	ledsegment : out std_logic_vector(6 downto 0)
);
end entity;
architecture rtl of seven_seg_decoder is
begin
-- this process is a LUT which will drive the appropriate ledsegment bits
-- based on the contents of the intermediate bcd signal
-- (i.e. it is a BCD to 7seg decoder)
-- inputs: bcd
-- outputs: ledsegment
	disp_decode_fn: process(bcd)
	begin
		if(rising_edge(clk)) then
		case bcd is 
			when "0000" =>
				ledsegment <= "1000000"; --0 
			when "0001" => 
				ledsegment <= "1111001"; --1
			when "0010" =>
				ledsegment <= "0100100"; --2
			when "0011" =>
				ledsegment <= "0110000"; --3
			when "0100" =>
				ledsegment <= "0011001"; --4
			when "0101" =>
				ledsegment <= "0010010"; --5
			when "0110" =>
				ledsegment <= "0000010"; --6
			when "0111" =>
				ledsegment <= "1111000"; --7
			when "1000" =>
				ledsegment <= "0000000"; --8
			when "1001" =>
				ledsegment <= "0010000"; --9
			when "1010"=>
				ledsegment <= "0001000";--A
			when "1011"=>
				ledsegment <= "0000011";--b
			when "1100"=>
				ledsegment <= "1000110";--C
			when "1101"=>
				ledsegment <= "0100001";--d
			when "1110"=>
				ledsegment <= "0000110";--E
			when "1111"=>
				ledsegment <= "0001110";--F
			end case;	
			end if;
	end process;
end architecture;