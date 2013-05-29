LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;


entity LED is
	port(
		clk: in std_logic;

		enable: in std_logic;
		row: in integer range 0 to 7 := 0;
		col: in integer range 0 to 7 := 0;
		led_data: in std_logic;

		output: out std_logic_vector(0 to 23)
	);
end LED;

architecture arch_LED of LED is
	-- signal position: integer range 0 to 63 := 0;
	signal output_inner: std_logic_vector(0 to 23);
begin
	
	output <= output_inner;
	output_inner(16 to 23) <= output_inner(8 to 15);
	
	draw_loop: process(clk)
		variable row_data: std_logic_vector(0 to 7);
		variable row_prev: integer range 0 to 7;
	begin
		if clk'EVENT and clk = '1' then
			if enable = '1' then 
				if row_prev /= row then
					row_data := x"FF";
				end if;
				row_prev := row;
				row_data(col) := not led_data;
				output_inner(8 to 15) <= row_data;
				case row is
					when 0 =>
						 output_inner(0 to 7) <= "00000001";
					when 1 =>
						 output_inner(0 to 7) <= "00000010";
					when 2 =>
						 output_inner(0 to 7) <= "00000100";
					when 3 =>
						 output_inner(0 to 7) <= "00001000";
					when 4 =>
						 output_inner(0 to 7) <= "00010000";
					when 5 =>
						 output_inner(0 to 7) <= "00100000";
					when 6 =>
						 output_inner(0 to 7) <= "01000000";
					when 7 =>
						 output_inner(0 to 7) <= "10000000";
				end case;
			end if;
		end if;
	end process;
end arch_LED;
