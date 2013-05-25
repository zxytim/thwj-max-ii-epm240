LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


entity wave_your_hand is
	port(
		clk: in std_logic;
		uss_trig: out std_logic;
		uss_echo: in std_logic;
		
		-- below are test
		dist: out std_logic_vector(7 downto 0)
	);
end wave_your_hand;

architecture arch_wave_your_hand of wave_your_hand is
	component uss is
		port(
			clk: in std_logic;
			dist: out std_logic_vector(7 downto 0);
			
			uss_trig: out std_logic := '0';
			uss_echo: in std_logic
		);
	end component;
	
begin	
	uss_comp: uss port map(clk, dist, uss_trig, uss_echo);
end arch_wave_your_hand;