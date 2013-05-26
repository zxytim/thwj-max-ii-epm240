LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;


entity light is
	port(
		clk: in std_logic ;
		red: in std_logic_vector(0 to 63);
		green: in std_logic_vector(0 to 63);
		output: out std_logic_vector(0 to 23) -- low 8 bits are row
		-- from low to high:
		-- row(0-7), red(8-15), green(16-23)
	);
end light;

architecture arch_light of light is
	signal row_id: integer range 0 to 7 := 0;
	signal one: std_logic_vector(0 to 7) := "00000001";
	-- signal position: integer range 0 to 63 := 0;
begin
	
	process(clk)
	begin
		if clk'EVENT and clk = '0' then
		-- value table is the most efficient way of using logic unit.
			case row_id is
				when 0 =>
					 output(0 to 7) <= "00000001";
					 output(8 to 15) <= not red(0 to 7);
					 output(16 to 23) <= not green(0 to 7);
				when 1 =>
					 output(0 to 7) <= "00000010";
					 output(8 to 15) <= not red(8 to 15);
					 output(16 to 23) <= not green(8 to 15);
				when 2 =>
					 output(0 to 7) <= "00000100";
					 output(8 to 15) <= not red(16 to 23);
					 output(16 to 23) <= not green(16 to 23);
				when 3 =>
					 output(0 to 7) <= "00001000";
					 output(8 to 15) <= not red(24 to 31);
					 output(16 to 23) <= not green(24 to 31);
				when 4 =>
					 output(0 to 7) <= "00010000";
					 output(8 to 15) <= not red(32 to 39);
					 output(16 to 23) <= not green(32 to 39);
				when 5 =>
					 output(0 to 7) <= "00100000";
					 output(8 to 15) <= not red(40 to 47);
					 output(16 to 23) <= not green(40 to 47);
				when 6 =>
					 output(0 to 7) <= "01000000";
					 output(8 to 15) <= not red(48 to 55);
					 output(16 to 23) <= not green(48 to 55);
				when 7 =>
					 output(0 to 7) <= "10000000";
					 output(8 to 15) <= not red(56 to 63);
					 output(16 to 23) <= not green(56 to 63);


			end case;	

			if row_id = 7 then
				row_id <= 0;
			else
				row_id <= row_id + 1;
			end if;
			--one <= SHL(one, "1");
			-- or
			--output(8 to 15) <= red((position + 7) downto position);
			--output(16 to 23) <= green((position + 7) downto position);
			--position <= position + 7;
		end if;
	end process;
	
end arch_light;
