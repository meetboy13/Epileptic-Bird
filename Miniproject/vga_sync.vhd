library IEEE;
use  IEEE.STD_LOGIC_1164.all;
use  IEEE.STD_LOGIC_ARITH.all;
use  IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY VGA_SYNC IS
	PORT(	clock_25Mhz		: IN	STD_LOGIC;
			Ball_on,pipe_on, paused : IN std_LOGIC;
			rom_mux_output : in std_logic;
			display : in std_LOGIC_VECTOR(1 downto 0);
			signal sred,sblue,sgreen : in std_LOGIC_VECTOR(2 downto 0);
			score : in std_logic_vector(7 downto 0);
			energy : in std_LOGIC_VECTOR(6 downto 0);
			health : in std_LOGIC_VECTOR(1 downto 0);
			item_on, mode : in std_logic;
			bird_colour : in std_logic_vector(11 downto 0);
			--bird_position : in std_logic_vector(19 downto 0);
			red_out, green_out, blue_out : out std_logic_vector(3 downto 0);
			signal char_select : out std_LOGIC_VECTOR(5 downto 0);
			horiz_sync_out, vert_sync_out,pipe_collide	: OUT	STD_LOGIC;
			pixel_row, pixel_column: OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
			rowp, colp : out std_logic_vector(2 downto 0);
			item_collide : out std_logic
			);
			--bird_address : out std_logic_vector(7 downto 0));
END VGA_SYNC;

ARCHITECTURE a OF VGA_SYNC IS
	constant sixteen : unsigned (9 downto 0) := "0000010000";
	SIGNAL horiz_sync, vert_sync : STD_LOGIC;
	SIGNAL video_on, video_on_v, video_on_h : STD_LOGIC;
	SIGNAL h_count, v_count,coloffset :STD_LOGIC_VECTOR(9 DOWNTO 0);
	signal red, blue, green : std_logic_vector(3 downto 0); 
	
BEGIN
-- video_on is high only when RGB data is displayed
video_on <= video_on_H AND video_on_V;

process(v_count, h_count, display, score, mode, health)
variable health_display : unsigned(1 downto 0) := unsigned(health);
begin
	char_select <= "100000";
	rowp <= v_count(3 downto 1);
	colp <= h_count(3 downto 1);
	case display is
		when "00" =>
			rowp <= v_count(4 downto 2) - "001";
			colp <= h_count(4 downto 2);
			if (v_count < "0001000000" and v_count > "0000100000") then
				if (h_count > conv_unsigned(6,10)*sixteen and h_count < conv_unsigned(8,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(8,10)*sixteen and h_count < conv_unsigned(10,10)*sixteen) then
					char_select <= "010000";
				elsif (h_count > conv_unsigned(10,10)*sixteen and h_count < conv_unsigned(12,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(12,10)*sixteen and h_count < conv_unsigned(14,10)*sixteen) then
					char_select <= "001100";
				elsif (h_count > conv_unsigned(14,10)*sixteen and h_count < conv_unsigned(16,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(16,10)*sixteen and h_count < conv_unsigned(18,10)*sixteen) then
					char_select <= "010000";
				elsif (h_count > conv_unsigned(18,10)*sixteen and h_count < conv_unsigned(20,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(20,10)*sixteen and h_count < conv_unsigned(22,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(22,10)*sixteen and h_count < conv_unsigned(24,10)*sixteen) then
					char_select <= "000011";
				elsif (h_count > conv_unsigned(26,10)*sixteen and h_count < conv_unsigned(28,10)*sixteen) then
					char_select <= "000010";
				elsif (h_count > conv_unsigned(28,10)*sixteen and h_count < conv_unsigned(30,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(30,10)*sixteen and h_count < conv_unsigned(32,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(32,10)*sixteen and h_count < conv_unsigned(34,10)*sixteen) then
					char_select <= "000100";
				end if;
			elsif (v_count < "0011000000" and v_count > "0010110000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "000001";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(5,10)*sixteen and h_count < conv_unsigned(6,10)*sixteen) then
					char_select <= "001110";
				elsif (h_count > conv_unsigned(6,10)*sixteen and h_count < conv_unsigned(7,10)*sixteen and mode = '1') then
					char_select <= "011111";
				end if;
			elsif (v_count < "0011010000" and v_count > "0011000000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "000111";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "000001";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "001101";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(6,10)*sixteen and h_count < conv_unsigned(7,10)*sixteen and mode = '0') then
					char_select <= "011111";
				end if;
			end if;
		when "01" =>
			rowp <= v_count(3 downto 1) - "010";
			colp <= h_count(3 downto 1);
			if (v_count < "0000010011" and v_count > "0000000011") then
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "010011";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "000011";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "001111";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(5,10)*sixteen and h_count < conv_unsigned(6,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(6,10)*sixteen and h_count < conv_unsigned(7,10)*sixteen) then
					char_select <= "111010";
				elsif (h_count > conv_unsigned(7,10)*sixteen and h_count < conv_unsigned(8,10)*sixteen) then
					char_select <= "110000" + score(7 downto 4);
				elsif (h_count > conv_unsigned(8,10)*sixteen and h_count < conv_unsigned(9,10)*sixteen) then
					char_select <= "110000" + score(3 downto 0);
				elsif (h_count > conv_unsigned(12,10)*sixteen and h_count < conv_unsigned(13,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(13,10)*sixteen and h_count < conv_unsigned(14,10)*sixteen) then
					char_select <= "001110";
				elsif (h_count > conv_unsigned(14,10)*sixteen and h_count < conv_unsigned(15,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(15,10)*sixteen and h_count < conv_unsigned(16,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(16,10)*sixteen and h_count < conv_unsigned(17,10)*sixteen) then
					char_select <= "000111";
				elsif (h_count > conv_unsigned(17,10)*sixteen and h_count < conv_unsigned(18,10)*sixteen) then
					char_select <= "011001";
				elsif (h_count > conv_unsigned(34,10)*sixteen and h_count < conv_unsigned(35,10)*sixteen) then
					char_select <= "001000";
				elsif (h_count > conv_unsigned(35,10)*sixteen and h_count < conv_unsigned(36,10)*sixteen) then
					char_select <= "010000";
				elsif (h_count > conv_unsigned(36,10)*sixteen and h_count < (conv_unsigned(36,10) + health_display)*sixteen) then
					char_select <= "111011";
				else
					char_select <= "100000";
				end if;
			end if;
		when "10" =>
			rowp <= v_count(4 downto 2) - "001";
			colp <= h_count(4 downto 2);
			if (v_count < "0001000000" and v_count > "0000100000") then
				if (h_count > conv_unsigned(16,10)*sixteen and h_count < conv_unsigned(18,10)*sixteen) then
					char_select <= "010000";
				elsif (h_count > conv_unsigned(18,10)*sixteen and h_count < conv_unsigned(20,10)*sixteen) then
					char_select <= "000001";
				elsif (h_count > conv_unsigned(20,10)*sixteen and h_count < conv_unsigned(22,10)*sixteen) then
					char_select <= "010101";
				elsif (h_count > conv_unsigned(22,10)*sixteen and h_count < conv_unsigned(24,10)*sixteen) then
					char_select <= "010011";
				elsif (h_count > conv_unsigned(24,10)*sixteen and h_count < conv_unsigned(26,10)*sixteen) then
					char_select <= "000101";
				end if;
			elsif (v_count < "0011000000" and v_count > "0010110000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "010101";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "001110";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "010000";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "000001";
				elsif (h_count > conv_unsigned(5,10)*sixteen and h_count < conv_unsigned(6,10)*sixteen) then
					char_select <= "010101";
				elsif (h_count > conv_unsigned(6,10)*sixteen and h_count < conv_unsigned(7,10)*sixteen) then
					char_select <= "010011";
				elsif (h_count > conv_unsigned(7,10)*sixteen and h_count < conv_unsigned(8,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(9,10)*sixteen and h_count < conv_unsigned(10,10)*sixteen) then
					char_select <= "101000";
				elsif (h_count > conv_unsigned(10,10)*sixteen and h_count < conv_unsigned(11,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(11,10)*sixteen and h_count < conv_unsigned(12,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(12,10)*sixteen and h_count < conv_unsigned(13,10)*sixteen) then
					char_select <= "000111";
				elsif (h_count > conv_unsigned(13,10)*sixteen and h_count < conv_unsigned(14,10)*sixteen) then
					char_select <= "001000";
				elsif (h_count > conv_unsigned(14,10)*sixteen and h_count < conv_unsigned(15,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(16,10)*sixteen and h_count < conv_unsigned(17,10)*sixteen) then
					char_select <= "000011";
				elsif (h_count > conv_unsigned(17,10)*sixteen and h_count < conv_unsigned(18,10)*sixteen) then
					char_select <= "001100";
				elsif (h_count > conv_unsigned(18,10)*sixteen and h_count < conv_unsigned(19,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(19,10)*sixteen and h_count < conv_unsigned(20,10)*sixteen) then
					char_select <= "000011";
				elsif (h_count > conv_unsigned(20,10)*sixteen and h_count < conv_unsigned(21,10)*sixteen) then
					char_select <= "001011";
				elsif (h_count > conv_unsigned(21,10)*sixteen and h_count < conv_unsigned(22,10)*sixteen) then
					char_select <= "101001";
				end if;
			elsif (v_count < "0011010000" and v_count > "0011000000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "001100";
				elsif (h_count > conv_unsigned(5,10)*sixteen and h_count < conv_unsigned(6,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(7,10)*sixteen and h_count < conv_unsigned(8,10)*sixteen) then
					char_select <= "101000";
				elsif (h_count > conv_unsigned(8,10)*sixteen and h_count < conv_unsigned(9,10)*sixteen) then
					char_select <= "000010";
				elsif (h_count > conv_unsigned(9,10)*sixteen and h_count < conv_unsigned(10,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(10,10)*sixteen and h_count < conv_unsigned(11,10)*sixteen) then
					char_select <= "110001";
				elsif (h_count > conv_unsigned(11,10)*sixteen and h_count < conv_unsigned(12,10)*sixteen) then
					char_select <= "101001";
				
				end if;
			end if;
		when "11" =>
			rowp <= v_count(4 downto 2) - "001";
			colp <= h_count(4 downto 2);
			if (v_count < "0001000000" and v_count > "0000100000") then
				if (h_count > conv_unsigned(12,10)*sixteen and h_count < conv_unsigned(14,10)*sixteen) then
					char_select <= "000111";
				elsif (h_count > conv_unsigned(14,10)*sixteen and h_count < conv_unsigned(16,10)*sixteen) then
					char_select <= "000001";
				elsif (h_count > conv_unsigned(16,10)*sixteen and h_count < conv_unsigned(18,10)*sixteen) then
					char_select <= "001101";
				elsif (h_count > conv_unsigned(18,10)*sixteen and h_count < conv_unsigned(20,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(20,10)*sixteen and h_count < conv_unsigned(22,10)*sixteen) then
					char_select <= "001111";
				elsif (h_count > conv_unsigned(22,10)*sixteen and h_count < conv_unsigned(24,10)*sixteen) then
					char_select <= "010110";
				elsif (h_count > conv_unsigned(24,10)*sixteen and h_count < conv_unsigned(26,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(26,10)*sixteen and h_count < conv_unsigned(28,10)*sixteen) then
					char_select <= "010010";
				end if;
			elsif (v_count < "0001010000" and v_count > "0001000000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(16,10)*sixteen and h_count < conv_unsigned(17,10)*sixteen) then
					char_select <= "010011";
				elsif (h_count > conv_unsigned(17,10)*sixteen and h_count < conv_unsigned(18,10)*sixteen) then
					char_select <= "000011";
				elsif (h_count > conv_unsigned(18,10)*sixteen and h_count < conv_unsigned(19,10)*sixteen) then
					char_select <= "001111";
				elsif (h_count > conv_unsigned(19,10)*sixteen and h_count < conv_unsigned(20,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(20,10)*sixteen and h_count < conv_unsigned(21,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(21,10)*sixteen and h_count < conv_unsigned(22,10)*sixteen) then
					char_select <= "111010";
				elsif (h_count > conv_unsigned(22,10)*sixteen and h_count < conv_unsigned(23,10)*sixteen) then
					char_select <= "110000" + score(7 downto 4);
				elsif (h_count > conv_unsigned(23,10)*sixteen and h_count < conv_unsigned(24,10)*sixteen) then
					char_select <= "110000" + score(3 downto 0);
				end if;
			elsif (v_count < "0011000000" and v_count > "0010110000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "010010";
				elsif (h_count > conv_unsigned(5,10)*sixteen and h_count < conv_unsigned(6,10)*sixteen) then
					char_select <= "011001";
				elsif (h_count > conv_unsigned(7,10)*sixteen and h_count < conv_unsigned(8,10)*sixteen) then
					char_select <= "101000";
				elsif (h_count > conv_unsigned(8,10)*sixteen and h_count < conv_unsigned(9,10)*sixteen) then
					char_select <= "000010";
				elsif (h_count > conv_unsigned(9,10)*sixteen and h_count < conv_unsigned(10,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(10,10)*sixteen and h_count < conv_unsigned(11,10)*sixteen) then
					char_select <= "110000";
				elsif (h_count > conv_unsigned(11,10)*sixteen and h_count < conv_unsigned(12,10)*sixteen) then
					char_select <= "101001";
				end if;
			elsif (v_count < "0011010000" and v_count > "0011000000") then
				rowp <= v_count(3 downto 1) - "001";
				colp <= h_count(3 downto 1);
				if (h_count > conv_unsigned(1,10)*sixteen and h_count < conv_unsigned(2,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(2,10)*sixteen and h_count < conv_unsigned(3,10)*sixteen) then
					char_select <= "001001";
				elsif (h_count > conv_unsigned(3,10)*sixteen and h_count < conv_unsigned(4,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(4,10)*sixteen and h_count < conv_unsigned(5,10)*sixteen) then
					char_select <= "001100";
				elsif (h_count > conv_unsigned(5,10)*sixteen and h_count < conv_unsigned(6,10)*sixteen) then
					char_select <= "000101";
				elsif (h_count > conv_unsigned(7,10)*sixteen and h_count < conv_unsigned(8,10)*sixteen) then
					char_select <= "101000";
				elsif (h_count > conv_unsigned(8,10)*sixteen and h_count < conv_unsigned(9,10)*sixteen) then
					char_select <= "000010";
				elsif (h_count > conv_unsigned(9,10)*sixteen and h_count < conv_unsigned(10,10)*sixteen) then
					char_select <= "010100";
				elsif (h_count > conv_unsigned(10,10)*sixteen and h_count < conv_unsigned(11,10)*sixteen) then
					char_select <= "110001";
				elsif (h_count > conv_unsigned(11,10)*sixteen and h_count < conv_unsigned(12,10)*sixteen) then
					char_select <= "101001";
				end if;
			end if;
	end case;
end process;

rightclick: process (paused, Ball_on, h_count, v_count,sblue,sred,sgreen,health,clock_25Mhz, pipe_on, item_on, rom_mux_output, score, energy, display)
variable energy_display : unsigned(6 downto 0) := unsigned(energy);

begin
	-- Colors for pixel data on video signal
	pipe_collide <= '0';
	item_collide <= '0';
	case display is
		when "00" =>
			if (rom_mux_output='1') then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
			else
				Red <= ('1' & sred(2 downto 0));
				Green <= ('1' & sgreen(2 downto 0));
				Blue <= ('1' & sblue(2 downto 0));
			end if;
		when "01" =>
			if (v_count < "0000010011" and v_count > "0000000011") then
				if (h_count > conv_unsigned(18,10)*sixteen and (h_count < conv_unsigned(18,10)*sixteen + energy_display)) then
					red <= "0000";
					blue <= "0001";
					green <= "0000";
				elsif (rom_mux_output='1') then
					red <= "0000";
					blue <= "0000";
					green <= "0000";
				else
					Red <= ('1' & sred(2 downto 0));
					Green <= ('1' & sgreen(2 downto 0));
					Blue <= ('1' & sblue(2 downto 0));
				end if;
			elsif (v_count < "0000010110") then
				Red <= '1' & sred(2 downto 0);
				Blue <= '1' & sblue(2 downto 0);
				Green <= '1' & sgreen(2 downto 0);
			elsif (v_count >= "0111001100") then
				red <= "0000";
				blue <= "0000";
				green <= "10" & sgreen(1 downto 0);
			elsif(Ball_on = '1' and pipe_on = '1') then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
				pipe_collide <= '1';
			elsif(pipe_on = '1') then
				red <= "0000";
				blue <= "0000";
				green <= "11" & sgreen(1 downto 0);
			elsif(Ball_on = '1' and item_on = '1') then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
				item_collide <= '1';
			elsif(item_on = '1') then
				red <= "0000";
				blue <= "1111";
				green <= "1111";
			elsif (Ball_on = '1') then
				red<= bird_colour(11) & sred(2 downto 0);
				green <= bird_colour(7) & sgreen(2 downto 0);
				blue <= bird_colour(3) & sblue(2 downto 0);
				--red <= '1' & sred(2 downto 0);
				--blue <= "0000";
				--green <= "0000";
				--1(rowpos-birdypos -size)
				--2(colpos -birdxpos -size)*16
				--1+2=3
				--romaddress <= 3
				--rgb<=romoutput
			else
				Red <=  "00" & sred(1 downto 0);
				-- Turn off Green and Blue when displaying ball
				Green <= "0000";
				Blue <= '1' & sblue(2 downto 0);
			end if;
		when "10" =>
			if (rom_mux_output='1') then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
			else
				Red <= ('1' & sred(2 downto 0));
				Green <= "0000";
				Blue <= ('1' & sblue(2 downto 0));
			end if;
		when "11" =>
			if (rom_mux_output='1') then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
			else
				Red <= ('1' & sred(2 downto 0));
				Green <= "0000";
				Blue <= "0000";
			end if;
		end case;
end process;


PROCESS
BEGIN
	WAIT UNTIL(clock_25Mhz'EVENT) AND (clock_25Mhz='1');

--Generate Horizontal and Vertical Timing Signals for Video Signal
-- H_count counts pixels (640 + extra time for sync signals)
-- 
--  Horiz_sync  ------------------------------------__________--------
--  H_count       0                640             659       755    799
--
	IF (h_count = 799) THEN
   		h_count <= "0000000000";
	ELSE
   		h_count <= h_count + 1;
	END IF;

--Generate Horizontal Sync Signal using H_count
	IF (h_count <= 755) AND (h_count >= 659) THEN
 	  	horiz_sync <= '0';
	ELSE
 	  	horiz_sync <= '1';
	END IF;

--V_count counts rows of pixels (480 + extra time for sync signals)
--  
--  Vert_sync      -----------------------------------------------_______------------
--  V_count         0                                      480    493-494          524
--
	IF (v_count >= 524) AND (h_count >= 699) THEN
   		v_count <= "0000000000";
	ELSIF (h_count = 699) THEN
   		v_count <= v_count + 1;
	END IF;

-- Generate Vertical Sync Signal using V_count
	IF (v_count <= 494) AND (v_count >= 493) THEN
   		vert_sync <= '0';
	ELSE
  		vert_sync <= '1';
	END IF;

-- Generate Video on Screen Signals for Pixel Data
	IF (h_count <= 639) THEN
   		video_on_h <= '1';
   		pixel_column <= h_count;
	ELSE
	   	video_on_h <= '0';
	END IF;

	IF (v_count <= 479) THEN
   		video_on_v <= '1';
   		pixel_row <= v_count;
	ELSE
   		video_on_v <= '0';
	END IF;

-- Put all video signals through DFFs to elminate any delays that cause a blurry image
		red_out <= red AND (video_on & video_on & video_on & video_on);
		green_out <= green AND (video_on & video_on & video_on & video_on);
		blue_out <= blue AND (video_on & video_on & video_on & video_on);
		horiz_sync_out <= horiz_sync;
		vert_sync_out <= vert_sync;

END PROCESS;
END a;