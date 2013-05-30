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
--		output: out std_logic_vector(0 to 47)
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
	
	subtype PLAT_SCENE_T is std_logic_vector(0 to 127);
	
	signal plat_scene: PLAT_SCENE_T;
	
	function count_ones(s : std_logic_vector) return integer is
		variable temp : natural := 0;
	begin
		for i in s'range loop
			if s(i) = '1' then temp := temp + 1; 
			end if;
		end loop;
		return temp;
	end function count_ones;
	
	function pos_id(x: integer range 0 to 7; y: integer range 0 to 15) return integer is
	begin
		return y * 8 + x;
	end function;
	
	component  mem_spi_altufm_spi_5bl IS 
	 PORT 
	 ( 
		 ncs	:	IN  STD_LOGIC;
		 osc	:	OUT  STD_LOGIC;
		 sck	:	IN  STD_LOGIC;
		 si	:	IN  STD_LOGIC;
		 so	:	OUT  STD_LOGIC
	 ); 
	END component;

	signal mem_ncs: std_logic := '1';
	signal mem_sck, mem_si, mem_so: std_logic;
	
	signal screen_pos: integer range 0 to 127;
	
	begin
	screen_pos <= screen_col * 8 + screen_row;
	
	
	
	--mem_comp: mem_spi_altufm_spi_5bl port map(ncs => mem_ncs, sck => mem_sck, si => mem_si, so => mem_so);
	
	logic: process(clk, rst, dist)
		variable clk_man_fall: integer range 0 to CNT_MAN_FALL := CNT_MAN_FALL / 2;
		variable clk_screen_roll: integer range 0 to CNT_SCREEN_ROLL := 0;
		variable cnt_screen_roll_new_plat: integer range 0 to 3;
		
		--variable man_pos: integer range 0 to 127;
		--variable screen_pos: integer range 0 to 127;
		
		variable cnt_screen_row: integer range 0 to 7;
		variable cnt_screen_col: integer range 0 to 7;
		variable output_inner: std_logic_vector(0 to 47);
		
		variable random: integer range 0 to 7 := 0;
		variable i: integer range 0 to N_PLAT_MAX;
		
		variable plat_scene_var: PLAT_SCENE_T;
		variable temp_slv_8: std_logic_vector(0 to 7);
		
		variable plat_template_int: integer range 0 to 255 := 7;
		variable plat_template_slv: std_logic_vector(0 to 7) := "11100000";
		
		type PLAT_TEMPLATE_T is array(0 to 5) of std_logic_vector(0 to 7);
		constant new_plat_template: PLAT_TEMPLATE_T := (
			"11100000",
			"01110000",
			"00111000",
			"00011100",
			"00001110",
			"00000111"
		);
	begin
		
		if clk'EVENT and clk = '1' then	
			plat_scene <= plat_scene_var;
			if rst = '0' then
				game_status <= GS_RESET;
			else
				case game_status is
					when GS_RESET => -- initialize game
						
						game_status <= GS_INIT;
					when GS_INIT =>
						man_x <= 4;
						man_y <= 10;
						clk_man_fall := CNT_MAN_FALL / 2;
						clk_screen_roll := 0;
						cnt_screen_roll_new_plat := 0;
						plat_scene_var := x"00000000000000000000000000000000";
						game_status <= GS_GAMING;
					when GS_GAMING => -- gaming
						if clk_man_fall = 0 then
							if man_y = 0 then
								game_status <= GS_GAME_OVER;
							elsif plat_scene_var(pos_id(man_x, man_y - 1)) = '0' then
								-- man fall
								man_y <= man_y - 1;
							end if;
						elsif clk_screen_roll = 0 then -- platform roll up, shall not occur at the same time as man fall
							if plat_scene_var(pos_id(man_x, man_y - 1)) = '1' then
								-- move the man up
								man_y <= man_y + 1;
							end if;
							
							--plat_scene_var(8 to 127) := plat_scene_var(0 to 119);
							plat_scene_var := SHR(plat_scene_var, "1000");
							if cnt_screen_roll_new_plat = 0 then
								-- FIXME: logic unit consuming 
								--plat_scene_var(0 to 7) := new_plat_template(random);
								plat_scene_var(0 to 7) := SHR(plat_template_slv, conv_std_logic_vector(random, 3));
--								temp_slv_8 := "00000000";
--								temp_slv_8(random) := '1';
--								temp_slv_8(random - 1) := '1';
--								temp_slv_8(random + 1) := '1';
--								plat_scene_var(0 to 7) := temp_slv_8;
							end if;

							cnt_screen_roll_new_plat := cnt_screen_roll_new_plat + 1;
--							-- no random x
						end if;
					when GS_GAME_OVER => -- game over
				end case;
				
			end if;
			
			clk_man_fall := clk_man_fall + 1;
			clk_screen_roll := clk_screen_roll + 1;
			random := random + dist;
			--plat_scene <= plat_scene_var;
			
			--man_pos := man_y * 8 + man_x;
			--screen_pos := cnt_screen_col * 8 + cnt_screen_row;
			
--			-- draw screen
--			if cnt_screen_col = 7 then
--				cnt_screen_row := cnt_screen_row + 1;
--			end if;
--			cnt_screen_col := cnt_screen_col + 1;
--			
--			
--			
--			output_inner := "000000001111111111111111000000001111111111111111";
--			output_inner(8 + cnt_screen_col) := not plat_scene_var(screen_pos);
--			output_inner(32 + cnt_screen_col) := not plat_scene_var(screen_pos + 64);
--			case cnt_screen_row is
--				when 0 =>
--					 output_inner(0 to 7) := "00000001";
--					 output_inner(24 to 31) := "00000001";
--				when 1 =>
--					 output_inner(0 to 7) := "00000010";
--					 output_inner(24 to 31) := "00000010";
--				when 2 =>
--					 output_inner(0 to 7) := "00000100";
--					 output_inner(24 to 31) := "00000100";
--				when 3 =>
--					 output_inner(0 to 7) := "00001000";
--					 output_inner(24 to 31) := "00001000";
--				when 4 =>
--					 output_inner(0 to 7) := "00010000";
--					 output_inner(24 to 31) := "00010000";
--				when 5 =>
--					 output_inner(0 to 7) := "00100000";
--					 output_inner(24 to 31) := "00100000";
--				when 6 =>
--					 output_inner(0 to 7) := "01000000";
--					 output_inner(24 to 31) := "01000000";
--				when 7 =>
--					 output_inner(0 to 7) := "10000000";
--					 output_inner(24 to 31) := "10000000";
--			end case;
--			
--			output_inner(16 to 23) := output_inner(8 to 15);
--			output_inner(40 to 47) := output_inner(32 to 39);
--			
--			output <= output_inner;
		end if;
	end process;

	screen: process(screen_trig)
		variable i: integer range 0 to N_PLAT_MAX;
		variable screen_output_inner: std_logic;
	begin
		if screen_trig'EVENT and screen_trig = '1' then
			screen_output_inner := plat_scene(screen_pos);
			
			-- draw man
			if screen_row = man_x and (screen_col = man_y or screen_col = man_y + 1) then
				screen_output_inner := '1';
			end if;
			
			screen_data <= screen_output_inner;
		end if;
	end process;
end arch_man;
