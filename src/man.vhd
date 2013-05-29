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
	
	constant N_PLAT_MAX: integer := 8;
	signal man_x: integer range 0 to 7;
	signal man_y: integer range 0 to 15;
	signal man_x_sense: integer range 0 to 7;
	
	type PLAT_X_VEC_T is array (0 to N_PLAT_MAX - 1) of integer range 0 to 7;
	type PLAT_Y_VEC_T is array (0 to N_PLAT_MAX - 1) of integer range 0 to 15;
	subtype INT8 is integer range 0 to 7;
	subtype INT16 is integer range 0 to 15;
	subtype INTNPLAT is integer range 0 to N_PLAT_MAX - 1;
	
	signal plat_x: PLAT_X_VEC_T;
	signal plat_y: PLAT_Y_VEC_T;
	
	signal n_plat: integer range 0 to N_PLAT_MAX - 1;
	
	signal game_status: integer range 0 to 3;
	constant GS_RESET: integer := 0;
	constant GS_GAMING: integer := 1;
	constant GS_WIN: integer := 2;
	constant GS_LOSE: integer := 3;
	-- 0 reset
	-- 1 gaming
	-- 2 win
	-- 3 lose
	
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
		n_plat: INTNPLAT;
		plat_x: PLAT_X_VEC_T;
		plat_y: PLAT_Y_VEC_T)
		return std_logic is
		variable i: integer range 0 to N_PLAT_MAX;
	begin
		i := 0;
		while i < n_plat loop
			if (plat_y(i) = man_y + 1) and abs(plat_x(i) - man_x) <= 1 then
				return '1';
			end if;
			i := i + 1;
		end loop;
		return '0';
	end function;
	
		
begin
	man_x_sense <= dist / 2;
	
	logic: process(clk, rst, dist)
		variable clk_man_fall: integer range 0 to CNT_MAN_FALL := CNT_MAN_FALL / 2;
		variable clk_screen_roll: integer range 0 to CNT_SCREEN_ROLL := 0;
		variable random: integer range 0 to 10000 := 0;
		variable i: integer range 0 to N_PLAT_MAX;
	begin

		if clk'EVENT and clk = '1' then
			if rst = '0' then
				game_status <= GS_RESET;
			else
				case game_status is
					when GS_RESET => -- initialize game
						n_plat <= 1;
						plat_x(0) <= 5;
						plat_y(0) <= 15;
						man_x <= 4;
						man_y <= 0;
						game_status <= GS_GAMING;
					when GS_GAMING => -- gaming
					
						-- man fall
						if clk_man_fall = 0 then
							if man_y = 15 then
								game_status <= GS_LOSE;
							elsif plat_is_below(man_x, man_y, n_plat, plat_x, plat_y) = '0' then
								man_y <= man_y + 1;
							end if;
						elsif clk_screen_roll = 0 then -- platform roll up, shall not occur at the same time as man fall
							i := 0;
							while i < n_plat loop
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
						end if;
					when GS_WIN => -- win
					when GS_LOSE => --lose
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
			while i < n_plat loop
				if abs(screen_row - plat_x(i)) <= 1 and screen_col = plat_y(i) then
					screen_output := '1';
				end if;
				i := i + 1;
			end loop;
			
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
