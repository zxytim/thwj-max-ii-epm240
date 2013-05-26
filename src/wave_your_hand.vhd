LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


entity wave_your_hand is
	port(
		clk: in std_logic;
		uss_trig: out std_logic;
		uss_echo: in std_logic;
		screen_output: out std_logic_vector(0 to 47) := x"00FFFF00FFFF";
		
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
	
	
	signal red: std_logic_vector(0 to 127);--:= "10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
	signal green: std_logic_vector(0 to 127);
	--signal red: std_logic_vector(0 to 63);
	--signal green: std_logic_vector(0 to 63);
	
	signal cnt: integer range 0 to 65535 := 0;
begin
	green <= red;
	--red <= "0101010110101010010101011010101001010101101010100101010110101010";
	--green <= "1010101001010101101010100101010110101010010101011010101001010101";
	uss_comp: uss port map(clk, dist, uss_trig, uss_echo);
	--screen_output(0) <= '1';
	--screen_output(8) <= '0';
	--light_comp: light port map(clk, red, green, screen_output(0 to 23));
	screen_comp: screen port map(clk, red, green, screen_output);
	
	process (clk)
		variable red_cnt : integer range 0 to 127 := 0;
		variable red_inner: std_logic_vector(0 to 127);
	begin
		if clk'EVENT and clk = '0' then
			if cnt = 500000 then
				if red_cnt = 0 then
					red_inner(127) := '0';
					red_inner(0) := '1';
					red_cnt := red_cnt + 1;
				elsif red_cnt = 127 then
					red_inner(126) := '0';
					red_inner(127) := '1';
					red_cnt := 0;
				else
					red_inner(red_cnt - 1) := '0';
					red_inner(red_cnt) := '1';
					red_cnt := red_cnt + 1;
				end if;
				
				cnt <= 0;
			else
				cnt <= cnt + 1; 
			end if;
			
			red <= red_inner;
		end if;
	end process;
end arch_wave_your_hand;
