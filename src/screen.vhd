LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


entity screen is
	port(
		clk: in std_logic;
		red: in std_logic_vector(0 to 127);
		green: in std_logic_vector(0 to 127);
		output: out std_logic_vector(0 to 47)
	);
end screen;

architecture arch_screen of screen is
	component light is
		port(
			clk: in std_logic;
			red: in std_logic_vector(0 to 63);
			green: in std_logic_vector(0 to 63);
			output: out std_logic_vector(0 to 23)
		);
	end component;
	
	signal red_left: std_logic_vector(0 to 63);
	signal red_right: std_logic_vector(0 to 63);
	signal green_left: std_logic_vector(0 to 63);
	signal green_right: std_logic_vector(0 to 63);
begin
	--light_left: light port map(clk, red(0 to 63), green(0 to 63), output(0 to 23));
	--light_right: light port map(clk, red(64 to 127), green(64 to 127), output(24 to 47));
	red_left(0 to 7) <= red(0 to 7);
	red_right(0 to 7) <= red(8 to 15);
	red_left(8 to 15) <= red(16 to 23);
	red_right(8 to 15) <= red(24 to 31);
	red_left(16 to 23) <= red(32 to 39);
	red_right(16 to 23) <= red(40 to 47);
	red_left(24 to 31) <= red(48 to 55);
	red_right(24 to 31) <= red(56 to 63);
	red_left(32 to 39) <= red(64 to 71);
	red_right(32 to 39) <= red(72 to 79);
	red_left(40 to 47) <= red(80 to 87);
	red_right(40 to 47) <= red(88 to 95);
	red_left(48 to 55) <= red(96 to 103);
	red_right(48 to 55) <= red(104 to 111);
	red_left(56 to 63) <= red(112 to 119);
	red_right(56 to 63) <= red(120 to 127);
	green_left(0 to 7) <= green(0 to 7);
	green_right(0 to 7) <= green(8 to 15);
	green_left(8 to 15) <= green(16 to 23);
	green_right(8 to 15) <= green(24 to 31);
	green_left(16 to 23) <= green(32 to 39);
	green_right(16 to 23) <= green(40 to 47);
	green_left(24 to 31) <= green(48 to 55);
	green_right(24 to 31) <= green(56 to 63);
	green_left(32 to 39) <= green(64 to 71);
	green_right(32 to 39) <= green(72 to 79);
	green_left(40 to 47) <= green(80 to 87);
	green_right(40 to 47) <= green(88 to 95);
	green_left(48 to 55) <= green(96 to 103);
	green_right(48 to 55) <= green(104 to 111);
	green_left(56 to 63) <= green(112 to 119);
	green_right(56 to 63) <= green(120 to 127);

	light_left: light port map(clk, red_left, green_left, output(0 to 23));
	light_right: light port map(clk, red_right, green_right, output(24 to 47));
end arch_screen;