-- Bouncing bird Video 
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE  IEEE.STD_LOGIC_ARITH.all;
USE  IEEE.STD_LOGIC_UNSIGNED.all;
LIBRARY lpm;
USE lpm.lpm_components.ALL;

PACKAGE de0core IS
	COMPONENT vga_sync
	PORT(	clock_25Mhz		: IN	STD_LOGIC;
			bird_on : IN std_LOGIC;
			rom_mux_output : in std_logic;
			signal sred,sblue,sgreen : in std_LOGIC_VECTOR(2 downto 0);
			red_out, green_out, blue_out : out std_logic_vector(3 downto 0);
			signal char_select : out std_LOGIC_VECTOR(5 downto 0);
			horiz_sync_out, vert_sync_out	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			rowp, colp : out std_logic_vector(2 downto 0)
			);
	END COMPONENT;
END de0core;

			--bird Video 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
LIBRARY work;
USE work.de0core.all;

ENTITY bird IS
Generic(ADDR_WIDTH: integer := 12; DATA_WIDTH: integer := 1);

   PORT(SIGNAL vert_sync_int,start, pause, left_click, clk, reset, pipe_collide 			: IN std_logic;
	--item_collide
		signal mouse_col					: in std_logic_vector(7 downto 0);		
		SIGNAL pixel_row, pixel_column				:in std_logic_vector(9 DOWNTO 0);
		item_pickup		: in std_logic;
		energy									: out std_LOGIC_VECTOR(6 downto 0);
      bird_on,die, collide_ready		: OUT std_logic;
		leds : out std_LOGIC_VECTOR(4 downto 0);
		bird_address : out std_logic_vector(7 downto 0)
		);	
END bird;

architecture behavior of bird is

			-- Video Display Signals   
SIGNAL horiz_sync_int			: std_logic;
signal left_click_pre,grounded,item_picked					: std_logic :='0';
SIGNAL Size 								: std_logic_vector(9 DOWNTO 0);  
SIGNAL bird_Y_motion, bird_x_motion				: std_logic_vector(9 DOWNTO 0);
SIGNAL bird_Y_pos				: std_logic_vector(9 DOWNTO 0) := conV_STD_LOGIC_VECTOR(240,10);
signal bird_X_pos				: std_logic_vector(9 DOWNTO 0) := conV_STD_LOGIC_VECTOR(170,10);

BEGIN    

Size <= CONV_STD_LOGIC_VECTOR(8,10);
		-- need internal copy of vert_sync to read

RGB_Display: Process (bird_X_pos, bird_Y_pos, pixel_column, pixel_row, Size)
variable temp_bird_address : std_logic_vector(13 downto 0);
BEGIN
			-- Set bird_on ='1' to display bird
	IF (unsigned(bird_X_pos) <= unsigned(pixel_column + Size)) AND
 			-- compare positive numbers only
 	(unsigned(bird_X_pos + Size) >= unsigned(pixel_column)) AND
 	('0' & bird_Y_pos <= pixel_row + Size) AND
 	(bird_Y_pos + Size >= '0' & pixel_row ) THEN
 		bird_on <= '1';
 	ELSE
 		bird_on <= '0';
	END IF;
	
	temp_bird_address := ((unsigned(pixel_column - bird_x_pos - size)& "0000") + unsigned(pixel_row - bird_y_pos - size));
	bird_address <= temp_bird_address(7 downto 0);

END process RGB_Display;

Move_bird: process(reset,vert_sync_int, item_pickup)
variable flap	: std_logic_vector(3 downto 0):= "0000";
variable energy_count : std_logic_VECTOR(9 downto 0):= "1100100000";

BEGIN
	if reset = '1' then
		bird_y_pos <= conV_STD_LOGIC_VECTOR(240,10);
		bird_x_pos <=conV_STD_LOGIC_VECTOR(170,10);
		energy_count := "1100100000";
		grounded <= '0';
			-- Move bird once every vertical sync
	elsif item_pickup = '1' then
		energy_count := "1100100000";
		--energy_count := energy_count + 1;
		--if (unsigned(energy_count) > conv_unsigned(800,10)) then
		--	energy_count := "1100100000";
		--end if;
	elsif(rising_edge(vert_sync_int)) then
			-- check if paused
			if (pause = '0' and start = '1') then
				if (unsigned(energy_count) > 0) then
					energy_count := energy_count - 1;
				end if;
				
				if (pipe_collide = '0') then
				--deincrement energy
				--flap on click
					if(left_click = '1' and left_click_pre = '0'and (unsigned(energy_count) > 0) ) then
						flap := "1111";
						left_click_pre <= '1';
					elsif (left_click = '0') then
						left_click_pre <= '0';
					end if;
					--flapping motion
					case flap is
						when "0000" =>
							bird_Y_motion <= CONV_STD_LOGIC_VECTOR(4,10);
						when "0001" =>
							bird_Y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
						when "0010" =>
							bird_Y_motion <= CONV_STD_LOGIC_VECTOR(1,10);
						when "0011" =>
							bird_Y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
						when "0100" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(1,10);
						when "0101" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(1,10);
						when "0110" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(2,10);
						when "0111" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(2,10);
						when "1000" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(3,10);
						when "1001" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(3,10);
						when "1010" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(4,10);
						when "1011" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(4,10);
						when "1100" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(6,10);
						when "1101" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(6,10);
						when "1110" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(8,10);
						when "1111" =>
							bird_Y_motion <= -CONV_STD_LOGIC_VECTOR(8,10);
					end case;
					
					if (unsigned(flap) > 0) then
						flap := flap - 1;
					end if;
					
					-- if at the edge
					IF (unsigned(bird_Y_pos) >= CONV_unsigned(452,10)) THEN
						bird_Y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
						grounded <= '1';
					ELSIF (unsigned(bird_Y_pos) <= conv_unsigned(26,10)) THEN
						bird_Y_motion <= CONV_STD_LOGIC_VECTOR(4,10);
					END IF;
					-- Compute next bird Y position
					bird_Y_pos <= bird_Y_pos + bird_Y_motion;
					
					--horizontal motion
					if (unsigned(mouse_col & "00")<conV_unsigned(100,10))  and (unsigned(bird_x_pos) >= (CONV_unsigned(80,10))) THEN
						bird_x_motion <= -conv_STD_LOGIC_VECTOR(4,10);
					elsif (unsigned(mouse_col& "00")<conV_unsigned(200,10)) and (unsigned(bird_x_pos) >= (CONV_unsigned(80,10))) THEN
						bird_x_motion <= -CONV_STD_LOGIC_VECTOR(2,10);
					elsIF (unsigned(mouse_col& "00")>conV_unsigned(540,10)) and (unsigned(bird_x_pos) <= (CONV_unsigned(220,10))) THEN
						bird_x_motion <= CONV_STD_LOGIC_VECTOR(4,10);
					elsif (unsigned(mouse_col& "00")>conV_unsigned(440,10)) and (unsigned(bird_x_pos) <= (CONV_unsigned(220,10))) THEN
						bird_x_motion <= CONV_STD_LOGIC_VECTOR(2,10);
					else
						bird_x_motion <= CONV_STD_LOGIC_VECTOR(0,10);
					END IF;
					--compute next bird x motion
					bird_x_pos <= bird_x_motion + bird_X_pos;
					else
						left_click_pre <= '0';
					end if;
			else
			end if;
	end if;
	energy <= energy_count(9 downto 3);
END process Move_bird;

process(reset,pipe_collide,grounded)
variable dead : std_LOGIC := '0';
begin
	if(reset = '1') then
		collide_ready <= '0';
		dead := '0';
	elsif(grounded = '1') then
		dead := '1';
	end if;
	if(pipe_collide = '1') then
		collide_ready <= '1';
	else
		collide_ready <= '0';
	end if;
die <= dead;
end process;

process (mouse_col)
begin
	if (unsigned(mouse_col & "00")<conV_unsigned(100,10))  and (unsigned(bird_x_pos) >= (CONV_unsigned(80,10))) THEN
		leds <= "01111";
	elsif (unsigned(mouse_col& "00")<conV_unsigned(200,10)) and (unsigned(bird_x_pos) >= (CONV_unsigned(80,10))) THEN
		leds <= "10111";
	elsIF (unsigned(mouse_col& "00")>conV_unsigned(540,10)) and (unsigned(bird_x_pos) <= (CONV_unsigned(220,10))) THEN
		leds <= "11110";
	elsif (unsigned(mouse_col& "00")>conV_unsigned(440,10)) and (unsigned(bird_x_pos) <= (CONV_unsigned(220,10))) THEN
		leds <= "11101";
	else
		leds <= "11011";
	END IF;
end process;

END behavior;

