LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;


entity man is
	port(
		clk: in std_logic;
		rst: in std_logic; -- '0' trigger

		dist: in integer range 0 to 15;
		screen_trig: in std_logic;
		screen_row: in integer range 0 to 7;
		screen_col: in integer range 0 to 15;
		screen_data: out std_logic
	);
end man;

architecture arch_man of man is
	constant CLOCK_FREQ: integer := 2000000;
	constant CNT_MAN_FALL: integer := CLOCK_FREQ / 4;
	constant CNT_SCREEN_ROLL: integer := CLOCK_FREQ;
	
	constant N_PLAT_MAX: integer := 3;
	signal man_x: integer range 0 to 7;
	
	signal man_x_left: integer range 0 to 7;
	signal man_x_right: integer range 0 to 7;
	
	signal man_y: integer range 0 to 15;
	signal man_x_sense: integer range 0 to 7;
	
	type PLAT_X_VEC_T is array (0 to N_PLAT_MAX - 1) of integer range 0 to 7;
	type PLAT_Y_VEC_T is array (0 to N_PLAT_MAX - 1) of integer range 0 to 15;
	subtype INT8 is integer range 0 to 7;
	subtype INT16 is integer range 0 to 15;
	subtype INTNPLAT is integer range 0 to N_PLAT_MAX - 1;
	
	signal plat_x: PLAT_X_VEC_T;
	signal plat_y: PLAT_Y_VEC_T;
	
	
	signal game_status: integer range 0 to 3;
	constant GS_RESET: integer := 0;
	constant GS_GAMING: integer := 1;
	constant GS_GAME_OVER: integer := 2;
	constant GS_INIT: integer := 3;
	-- 0 reset
	-- 1 gaming
	-- 2 win
	-- 3 lose
	
	-- cache to use less logic unit
	signal row_has_plat: std_logic_vector(0 to 15);
	type ROW_PLAT_Y_ARR is array (0 to 15) of integer range 0 to 15;
	signal row_plat_y: ROW_PLAT_Y_ARR;
	signal col_has_man: std_logic_vector(0 to 7);
	
	
	type PLAT_SCENE_T is array(0 to 7, 0 to 15) of std_logic;
	signal plat_scene: PLAT_SCENE_T;
	
	function a_plat_is_below(
		man_x: INT8;
		man_y: INT16; 
		plat_x: INT8;
		plat_y: INT16)
		return std_logic is
	begin
		if (plat_y = man_y + 1) and abs(plat_x - man_x) <= 1 then
			return '1';
		else
			return '0';
		end if;
	end function;
	
	function plat_is_below(
		man_x: INT8;
		man_y: INT16;
		col_has_man: std_logic_vector(0 to 7);
		plat_x: PLAT_X_VEC_T;
		plat_y: PLAT_Y_VEC_T)
		return std_logic is
		variable i: integer range 0 to N_PLAT_MAX;
	begin
		if (plat_y(0) = man_y + 1) and col_has_man(plat_x(0)) = '1' then
			return '1';
		end if;
	 
		if (plat_y(1) = man_y + 1) and col_has_man(plat_x(1)) = '1' then
			return '1';
		end if;
	 
		if (plat_y(2) = man_y + 1) and col_has_man(plat_x(2)) = '1' then
			return '1';
		end if;

		return '0';
	end function;
	
		
begin
	--man_x_sense <= dist / 2;
	man_x_left <= man_x - 1;
	man_x_right <= man_x + 1;
	
	logic: process(clk, rst, dist)
		variable clk_man_fall: integer range 0 to CNT_MAN_FALL := CNT_MAN_FALL / 2;
		variable clk_screen_roll: integer range 0 to CNT_SCREEN_ROLL := 0;
		variable random: integer range 0 to 10000 := 0;
		variable i: integer range 0 to N_PLAT_MAX;
		
		variable row_has_plat_var: std_logic_vector(0 to 15);
		variable col_has_man_var: std_logic_vector(0 to 7);
		variable row_plat_y_var: ROW_PLAT_Y_ARR;
		variable plat_scene_var: PLAT_SCENE_T;
		
	begin

		if clk'EVENT and clk = '1' then
			plat_scene_var := (others => (others => '0'));
			
			row_has_plat_var := (others => '0');			
			row_has_plat_var(plat_y(0)) := '1';
			row_has_plat_var(plat_y(1)) := '1';
			row_has_plat_var(plat_y(2)) := '1';
			
			col_has_man_var := (others => '0');
			col_has_man_var(man_x) := '1';
			col_has_man_var(man_x - 1) := '1';
			col_has_man_var(man_x + 1) := '1';
			
			row_plat_y_var(plat_y(0)) := plat_x(0);
			row_plat_y_var(plat_y(1)) := plat_x(1);
			row_plat_y_var(plat_y(2)) := plat_x(2);
			
			row_has_plat <= row_has_plat_var;
			col_has_man <= col_has_man_var;
			row_plat_y <= row_plat_y_var;
			
			
			if rst = '0' then
				game_status <= GS_RESET;
			else
				case game_status is
					when GS_RESET => -- initialize game
						plat_x <= (1,4,7);
						plat_y <= (15, 10, 5);
						man_x <= 4;
						man_y <= 13;
						game_status <= GS_INIT;
					when GS_INIT =>
						game_status <= GS_GAMING;
					when GS_GAMING => -- gaming
					
						-- man fall
						if clk_man_fall = 0 then
							if man_y = 15 then
								game_status <= GS_GAME_OVER;
							elsif plat_is_below(man_x, man_y, col_has_man_var, plat_x, plat_y) = '0' then
								man_y <= man_y + 1;
							end if;
						elsif clk_screen_roll = 0 then -- platform roll up, shall not occur at the same time as man fall
							i := 0;
							
							-- original loop {
							while i < N_PLAT_MAX loop
								if a_plat_is_below(man_x, man_y, plat_x(i), plat_y(i)) = '1' then
									-- move the man
									man_y <= man_y - 1;
								end if;
								if plat_y(i) = 0 then
									plat_y(i) <= 15;
									plat_x(i) <= random;
								else
									plat_y(i) <= plat_y(i) - 1;
								end if;
								i := i + 1;
							end loop;
							-- }

						end if;
					when GS_GAME_OVER => -- game over
				end case;
			end if;
			clk_man_fall := clk_man_fall + 1;
			clk_screen_roll := clk_screen_roll + 1;
			random := random + dist;
		end if;
	end process;

	screen: process(screen_trig)
		variable i: integer range 0 to N_PLAT_MAX;
		variable screen_output: std_logic;
	begin
		if screen_trig'EVENT and screen_trig = '1' then
			i := 0;
			screen_output := '0';
			
			-- draw platform
			
if abs(screen_row - plat_x(0)) <= 1 and screen_col = plat_y(0) then
	screen_output := '1';
end if;


if abs(screen_row - plat_x(1)) <= 1 and screen_col = plat_y(1) then
	screen_output := '1';
end if;


if abs(screen_row - plat_x(2)) <= 1 and screen_col = plat_y(2) then
	screen_output := '1';
end if;

--			-- original loop {
--			while i < n_plat loop
--				if abs(screen_row - plat_x(i)) <= 1 and screen_col = plat_y(i) then
--					screen_output := '1';
--				end if;
--				i := i + 1;
--			end loop;
--			-- }
			
			-- draw man
			if screen_row = man_x and (screen_col = man_y or screen_col = man_y - 1) then
				screen_output := '1';
			end if;
			
			screen_data <= screen_output;
--			if screen_col <= dist then
--				screen_data <= '1';
--			else
--				screen_data <= '0';
--			end if;
		end if;
	end process;
end arch_man;
