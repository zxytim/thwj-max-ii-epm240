
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
			dist: out std_logic_vector(7 downto 0);
			
			uss_trig: out std_logic := '0';
			uss_echo: in std_logic
		);
	end component;
	
	component screen is
		port(
			clk: in std_logic;
			red: in std_logic_vector(0 to 127);
			green: in std_logic_vector(0 to 127);
			output: out std_logic_vector(0 to 47)
		);
	end component;
	
	component light is
		port(
			clk: in std_logic ;
			red: in std_logic_vector(0 to 63);
			green: in std_logic_vector(0 to 63);
			output: out std_logic_vector(0 to 23) -- low 8 bits are row
			-- from low to high:
			-- row(0-7), red(8-15), green(16-23)
		);
	end component;
	
	
	component wave_your_hand is
		port(
			clk: in std_logic;
			uss_trig: out std_logic;
			uss_echo: in std_logic;
			screen_output: out std_logic_vector(0 to 47) := x"00FFFF00FFFF";
			
			-- below are test
			dist: out std_logic_vector(7 downto 0)
		);
	end component;
		

	signal clk	: std_logic := '0';

	signal uss_echo: std_logic := '0';
begin
	clock: process
	begin
		wait for 500 ns;
		clk <= not clk;
	end process;

	test: wave_your_hand port map(clk => clk, uss_echo => uss_echo);

end arch_test_wave_your_hand;
