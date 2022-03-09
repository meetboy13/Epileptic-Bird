-- game_fsm.vhdl 
-- A Mealy machine responsible for the control of the game process 
 
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
 
entity game_fsm is 
 
	port  
	(   
		clk,pause,mode_switch,sel,menu,reset_in,die,flap         : in std_logic;
		reset_out, mode, paused, start: out std_logic;
		debug_fsm: out std_logic_vector(4 downto 0);
		display: out std_logic_vector(1 downto 0);
		ssdp0, ssdp: out std_logic
	); 
end entity; 
 
architecture rtl of game_fsm is 
 
	-- Build an enumerated type for the state machine  
	type state_type is (s_start,s_init, s_game, s_paused, s_dead); 
 
	-- Register (and signal) to hold the current (and next) state  
	signal state, next_state : state_type := s_start; 
 
begin 
 
	state_reg: process (clk,reset_in)  
	begin   
		if reset_in = '1' then -- reset logic    
			state <= s_start; 
		elsif (rising_edge(clk)) then -- next state register: 
			state <= next_state;   
		end if;  
	end process; 
 
	 -- Determine the next state based only on the current state  
	 -- and the input (do not wait for a clock edge).  
	 next_state_fn: process(clk)  
	 begin   
		case state is    
			when s_start =>     
				if sel = '0' then
					next_state <= s_start;
				else
					if mode_switch = '0' then
						mode <= '0';
					else	
						mode <='1';
					end if;
					next_state <= s_init;
				end if;
			when s_init =>
				if flap = '1' then
					next_state <= s_game;
				else
					next_state <= s_init;
				end if;
			when s_game =>     
				if die = '1' then
					next_state <= s_dead;
				elsif pause = '1' then
					next_state <= s_paused;
				else
					next_state <= s_game;
				end if;
			when s_paused =>      
				if  menu = '1' then
					next_state <= s_start;
				elsif pause = '0' then 
					next_state <= s_game;
				else
					next_state <= s_paused;
				end if;
			when s_dead =>      
				if menu = '1' then
					next_state <= s_start;
				elsif sel = '1' then
					next_state <= s_init;
				else
					next_state <= s_dead;
				end if;
		end case;   
	 end process;
	 
--Determine the output based only on the current state
--and the input (do not wait for a clock edge).

output_fn: process (clk) -- output logic
begin
	--default output values
	reset_out <= '0';
	paused <= '0';
	start <= '0';
	display <= "00";
	debug_fsm <= "00000";--useful for LED debugging
	ssdp0<='1';
	ssdp<='1';
	case state is
		when s_start =>
			debug_fsm(0) <= '1';	
			display<= "00";
		when s_init =>
			reset_out <= '1';
			debug_fsm(1) <= '1';
			display<= "01";
		when s_game=>
			start <= '1';
			debug_fsm(2) <= '1';
			display<= "01";
			ssdp0<='0';
			ssdp<='0';
		when s_paused=>
			paused<='1';
			debug_fsm(3) <= '1';
			display<= "10";
			ssdp0<='1';
			ssdp<='0';
		when s_dead=>
			debug_fsm(4) <= '1';
			display<= "11";
			ssdp<='0';
	end case;
	end process;
end rtl;