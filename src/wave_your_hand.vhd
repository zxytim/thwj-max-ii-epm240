LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


entity wave_your_hand is
	port(
		clk: in std_logic;
		rst: in std_logic;
		
		uss_trig_0: out std_logic;
		uss_echo_0: in std_logic;
		
		uss_trig_1: out std_logic;
		uss_echo_1: in std_logic;
		screen_output: out std_logic_vector(0 to 47);
		
		dist_out: out std_logic_vector(0 to 3)
	);
end wave_your_hand;

architecture arch_wave_your_hand of wave_your_hand is
	component uss is
		port(
			clk: in std_logic;
			man_x_speed_out: out integer range -1 to 1;
			--dist: out integer range 0 to 15;
			uss_trig: out std_logic := '0';
			uss_echo: in std_logic
		);
	end component;
	
	component screen is
		port(
			clk: in std_logic;
			
			trig: out std_logic;
			row_out: out integer range 0 to 7;
			col_out: out integer range 0 to 15;
			led_data: in std_logic;

			output: out std_logic_vector(0 to 47)
		);
	end component;
	
	
	component Dot is
		port(
			clk: in std_logic;

			screen_trig: in std_logic;
			screen_row: in integer range 0 to 7;
			screen_col: in integer range 0 to 15;
			screen_data: out std_logic
		);
	end component;
	
	component man is
		port(
			clk: in std_logic;
			rst: in std_logic; -- '0' trigger
			
			man_x_speed: in integer range -1 to 1;
			
			--dist: in integer range 0 to 15;
--			output: out std_logic_vector(0 to 47)
			
			screen_trig: in std_logic;
			screen_row: in integer range 0 to 7;
			screen_col: in integer range 0 to 15;
			screen_data: out std_logic
		);
	end component;
	
	signal screen_trig: std_logic := '0';
	signal screen_led_data: std_logic;
	signal screen_row: integer range 0 to 7;
	signal screen_col: integer range 0 to 15;
	
	signal dist_0: integer range 0 to 15;
	signal dist_1: integer range 0 to 15;
	
	signal man_x_speed: integer range -2 to 2;
	
	signal game_status: integer range 0 to 3;
begin
	--uss_comp_0: uss port map(clk, dist_0, uss_trig_0, uss_echo_0);
	uss_comp_1: uss port map(clk, man_x_speed, uss_trig_1, uss_echo_1);
	screen_comp: screen port map(clk, screen_trig, screen_row, screen_col, screen_led_data, screen_output);
	man_comp: man port map(clk, rst, man_x_speed, screen_trig, screen_row, screen_col, screen_led_data);
	--man_comp: man port map(clk, rst, dist_1, screen_output);
	
end arch_wave_your_hand;
