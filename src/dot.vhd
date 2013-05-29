LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;
use ieee.numeric_std.all;


entity Dot is
	port(
		clk: in std_logic;

		screen_trig: in std_logic;
		screen_row: in integer range 0 to 7;
		screen_col: in integer range 0 to 15;
		screen_data: out std_logic
	);
end Dot;

architecture arch_Dot of Dot is
	signal row: integer range 0 to 7;
	signal col: integer range 0 to 15;
	signal position: integer range 0 to 127 := 0;

	component ram is
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			inclock		: IN STD_LOGIC ;
			outclock		: IN STD_LOGIC ;
			we		: IN STD_LOGIC  := '1';
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	end component;
	
	signal dummy_data: std_logic_vector(7 downto 0) := "00000000";
	signal dummy_inclock: std_logic := '0';
	
	signal ram_read_clock: std_logic;
	signal ram_read_address: std_logic_vector(7 downto 0) := "00000000";
	signal ram_read_data: std_logic_vector(7 downto 0);
	
	signal ram_data: std_logic_vector(0 to 127);
	
begin

	ram_comp: ram port map(
		address => ram_read_address,
		data => dummy_data,
		inclock => dummy_inclock,
		outclock => ram_read_clock,
		we => '1',
		q => ram_read_data);
	
	logic: process(clk)
		variable cnt: integer range 0 to 4 := 0;		
		variable block_to_read: integer range 0 to 15 := 0;
	begin
		if clk'EVENT and clk = '0' then
			if cnt = 0 then
				if ram_read_address = 15 then
					block_to_read := 0;
					ram_read_address <= x"00";
				else
					ram_read_address <= ram_read_address + 1;
					block_to_read := block_to_read + 1;
				end if;
				
				cnt := 1;
			elsif cnt = 1 then
				ram_read_clock <= '1';
				cnt := 2;
			elsif cnt = 2 then
				ram_read_clock <= '0';
				case block_to_read is
					when 0 =>
						ram_data(0 to 7) <= ram_read_data;
					when 1 =>
						ram_data(8 to 15) <= ram_read_data;
					when 2 =>
						ram_data(16 to 23) <= ram_read_data;
					when 3 =>
						ram_data(24 to 31) <= ram_read_data;
					when 4 =>
						ram_data(32 to 39) <= ram_read_data;
					when 5 =>
						ram_data(40 to 47) <= ram_read_data;
					when 6 =>
						ram_data(48 to 55) <= ram_read_data;
					when 7 =>
						ram_data(56 to 63) <= ram_read_data;
					when 8 =>
						ram_data(64 to 71) <= ram_read_data;
					when 9 =>
						ram_data(72 to 79) <= ram_read_data;
					when 10 =>
						ram_data(80 to 87) <= ram_read_data;
					when 11 =>
						ram_data(88 to 95) <= ram_read_data;
					when 12 =>
						ram_data(96 to 103) <= ram_read_data;
					when 13 =>
						ram_data(104 to 111) <= ram_read_data;
					when 14 =>
						ram_data(112 to 119) <= ram_read_data;
					when 15 =>
						ram_data(120 to 127) <= ram_read_data;
				end case;

				cnt := 3;
			elsif cnt = 3 then
			
				cnt := 0;
			end if;
		end if;
	end process;
	
	screen: process(screen_trig)
		variable position: integer range 0 to 127;
	begin
		if screen_trig'EVENT and screen_trig = '1' then
			position := screen_row * 15 + screen_col;
			screen_data <= ram_data(position);
		end if;
	end process;
end arch_Dot;
