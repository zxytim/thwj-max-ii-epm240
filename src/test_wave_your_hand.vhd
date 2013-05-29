
LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


entity test_wave_your_hand is
end test_wave_your_hand;

architecture arch_test_wave_your_hand of test_wave_your_hand is
	component uss is
			port(
			clk: in std_logic;
			
			dist: out integer range 0 to 15;
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
			
			
			dist: in integer range 0 to 15;
			screen_trig: in std_logic;
			screen_row: in integer range 0 to 7;
			screen_col: in integer range 0 to 15;
			screen_data: out std_logic
		);
	end component;
	
	component wave_your_hand is
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
	end component;
	
	

	signal clk: std_logic := '0';
	signal rst: std_logic := '1';

	signal uss_echo: std_logic := '0';
	signal uss_trig: std_logic;
begin
	clock: process
	begin
		wait for 5 ns;
		clk <= not clk;
	end process;

	test: wave_your_hand port map(clk => clk, rst => rst, uss_echo_0 => uss_echo, uss_echo_1 => uss_echo);

end arch_test_wave_your_hand;
