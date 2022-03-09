LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.STD_LOGIC_ARITH.all;
USE IEEE.STD_LOGIC_SIGNED.all;
LIBRARY work;
USE work.de0core.all;

ENTITY item IS
Generic(ADDR_WIDTH: integer := 12;
		DATA_WIDTH: integer := 1;
		Start_POS: STD_LOGIC_VECTOR(9 downto 0) := conV_STD_LOGIC_VECTOR(900,10));
   PORT(SIGNAL vert_sync_int, clk, start			: IN std_logic	;
		random_number :in std_logic_vector(7 downto 0);
		SIGNAL pixel_row, pixel_column				:in std_logic_vector(9 DOWNTO 0);
		item_collide, pause, reset : in std_logic;
		item_on		: OUT std_logic);		
END item;

architecture behavior of item is
			-- Video Display Signals   
SIGNAL horiz_sync_int			: std_logic;
SIGNAL Size 								: std_logic_vector(9 DOWNTO 0);  
SIGNAL item_motion : std_logic_vector(9 DOWNTO 0);
SIGNAL item_pos		: std_logic_vector(9 DOWNTO 0) := Start_POS;
signal item_y_pos : std_logic_vector(9 downto 0) := "00" & random_number;
signal offset : std_logic_vector(9 downto 0);


BEGIN    
Size <= CONV_STD_LOGIC_VECTOR(20,10);
offset <= CONV_STD_LOGIC_VECTOR(112,10);

RGB_Display: Process (item_pos,item_y_pos,pixel_column, pixel_row, clk)
BEGIN
	IF (unsigned(item_pos) <= unsigned(pixel_column + Size)) AND
 			-- compare positive numbers only
		(unsigned(item_pos + Size) >= unsigned(pixel_column)) and
		(unsigned(item_y_pos + offset) <= unsigned(pixel_row + Size)) AND
		(unsigned(item_y_pos+ offset + Size) >= unsigned(pixel_row) )
		THEN
		item_on <= '1';
	ELSE
		item_on <= '0';
	END IF;
END process RGB_Display;

Move_item: process(reset,vert_sync_int)
BEGIN
		if (reset = '1') then
			item_pos <= Start_POS;
			item_y_pos <= "00" & random_number;
		elsif (rising_edge(vert_sync_int)) then
			if (start = '1' and pause = '0') then
				item_motion <= -CONV_STD_LOGIC_VECTOR(4,10);
				item_pos <= item_pos + item_motion;
				if(unsigned(item_pos + 40) > 950) then
					item_y_pos <= "00" & random_number;
					item_pos <= conv_std_logic_vector(640,10);
				end if;
			end if;
		end if;
END process Move_item;

END behavior;