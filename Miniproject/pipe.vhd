-- Pipe
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;

ENTITY pipe IS
Generic(ADDR_WIDTH: integer := 12;
		DATA_WIDTH: integer := 1;
		Start_POS: STD_LOGIC_VECTOR(9 downto 0) := conV_STD_LOGIC_VECTOR(640,10));

   PORT(SIGNAL vert_sync_int, clk, start			: IN std_logic	;
		level : in std_logic_vector(1 downto 0);
		random_number :in std_logic_vector(7 downto 0);
		SIGNAL pixel_row, pixel_column				:in std_logic_vector(9 DOWNTO 0);
		pause, reset	:in std_logic;
		pipe_on,increment_score		: OUT std_logic);		
END pipe;

architecture behavior of pipe is
			-- Video Display Signals   
SIGNAL horiz_sync_int			: std_logic;
SIGNAL Size 		: std_logic_vector(9 DOWNTO 0):= CONV_STD_LOGIC_VECTOR(20,10);  
SIGNAL pipe_motion : std_logic_vector(9 DOWNTO 0);
SIGNAL pipe_pos		: std_logic_vector(9 DOWNTO 0) := Start_POS;
signal pipe_gap	: std_logic_vector(9 downto 0):=CONV_STD_LOGIC_VECTOR(120,10);
signal pipe_random_gap : std_logic_vector(9 downto 0) := "00" & random_number;
signal offset : std_logic_vector(9 downto 0) := CONV_STD_LOGIC_VECTOR(32,10);

BEGIN   
--	Size <= CONV_STD_LOGIC_VECTOR(20,10);
--	pipe_gap <= CONV_STD_LOGIC_VECTOR(120,10);
RGB_Display: Process (pipe_pos,pixel_column, pixel_row)
BEGIN
 IF (unsigned(pipe_pos) < unsigned(pixel_column + Size)) AND
 			-- compare positive numbers only
 	(unsigned(pipe_pos + Size) > unsigned(pixel_column)) and
	((unsigned(pixel_row) < unsigned(pipe_random_gap + offset)) or
	(unsigned(pixel_row) > unsigned(pipe_random_gap + offset + pipe_gap)))
	THEN
 		Pipe_on <= '1';
 	ELSE
 		Pipe_on <= '0';
	END IF;
	
END process RGB_Display;

Move_pipe: process(reset, vert_sync_int)
BEGIN
		if (reset = '1') then
			pipe_pos <= Start_POS;
			pipe_random_gap <= "0011110000";
			increment_score <= '0';
		elsif (rising_edge(vert_sync_int)) then
			if (pause = '0' and start = '1') then
				Pipe_motion <= -CONV_STD_LOGIC_VECTOR(4,10);
				Pipe_pos <= Pipe_pos + Pipe_motion;
				if(unsigned(pipe_pos + 40) > 1000) then
					pipe_random_gap <= "00" & random_number;
					increment_score <= '1';
					Pipe_pos <= conv_std_logic_vector(640,10);
					if(level = "10") then
						Size <= CONV_STD_LOGIC_VECTOR(40,10);
						pipe_gap <= CONV_STD_LOGIC_VECTOR(80,10);
						offset <= CONV_STD_LOGIC_VECTOR(112,10);
					elsif(level = "01") then
						Size <= CONV_STD_LOGIC_VECTOR(30,10);
						pipe_gap <= CONV_STD_LOGIC_VECTOR(100,10);
						offset <= CONV_STD_LOGIC_VECTOR(72,10);
					else
						Size <= CONV_STD_LOGIC_VECTOR(20,10);
						pipe_gap <= CONV_STD_LOGIC_VECTOR(120,10);
						offset <= CONV_STD_LOGIC_VECTOR(32,10);
					end if;
				else
					increment_score <= '0';
				end if;
			end if;
		end if;
END process Move_pipe;

END behavior;