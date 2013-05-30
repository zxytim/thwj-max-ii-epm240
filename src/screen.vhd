LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


--
-- LED clock frequency: 2M
-- 
entity screen is
	port(
		clk: in std_logic;
		
		trig: out std_logic;
		row_out: out integer range 0 to 7;
		col_out: out integer range 0 to 15;
		led_data: in std_logic;

		output: out std_logic_vector(0 to 47)
	);
end screen;

architecture arch_screen of screen is
	component LED is
		port(
			clk: in std_logic;

			enable: in std_logic;
			row: in integer range 0 to 7 := 0;
			col: in integer range 0 to 7 := 0;
			led_data: in std_logic;

			output: out std_logic_vector(0 to 23)
		);
	end component;
	
	signal position_inner: integer range 0 to 63;
	
	signal row: integer range 0 to 7 := 0;
	signal col: integer range 0 to 15 := 0;
	signal col_led: integer range 0 to 7;
	signal enable_left: std_logic := '1';
	signal enable_right: std_logic;
	signal led_clk: std_logic;
begin
	
	row_out <= row;
	col_out <= col;
	
	enable_right <= not enable_left;

	LED_left: LED port map(led_clk, enable_left, row, col, led_data, output(0 to 23));
	LED_right: LED port map(led_clk, enable_right, row, col, led_data, output(24 to 47)); -- col is overflowed to the right value;
	
	process (clk)
		variable cnt: integer range 0 to 3 := 0;
	begin
		if clk'EVENT and clk = '0' then
			if col < 8 then
				enable_left <= '1';
			else
				enable_left <= '0';
			end if;
			
			case cnt is
				when 0 => -- logic compute data
					trig <= '1';
				when 1 => -- led read data
					led_clk <= '1';
				when 2 =>
				
--					-- LET-IT-OVERFLOW
--					if col = 15 then
--						row <= row + 1;
--					end if;
--					col <= col + 1;
					-- DO-NOT-LET-IT-OVERFLOW
					if col = 15 then
						col <= 0;
						if row = 7 then
							row <= 0;
						else
							row <= row + 1;
						end if;
					else
						col <= col + 1;
					end if;
					
					trig <= '0';
				when 3 =>
					led_clk <= '0';
			end case;
			
--			cnt := cnt + 1;
			if cnt = 3 then
				cnt := 0;
			else
				cnt := cnt + 1;
			end if;
		end if;
	end process;
end arch_screen;