LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


-- assume a 2M pulse (0.5us) via @clk
-- uss constantly report distance
entity uss is
	port(
		clk: in std_logic;
		dist: out std_logic_vector(7 downto 0); -- in cm
		
		uss_trig: out std_logic := '0';
		uss_echo: in std_logic
	);
end uss;

architecture arch_uss of uss is
	signal echo_cnt: std_logic_vector(7 downto 0); -- 65.536ms -> 22m
	signal trig_cnt: std_logic_vector(15 downto 0);
	signal working: std_logic := '0';
	signal dist_buf: std_logic_vector(7 downto 0); -- hex FF or dec 99
begin	
	process(clk, uss_echo, working)
	begin
		if clk'EVENT and clk = '1' then
			trig_cnt <= trig_cnt + 1;
			echo_cnt <= echo_cnt + 1;
			if working = '1' then
				-- the unit of @echo_cnt is us
				-- so @dist = @echo_cnt / (2 * 10^6) * 34000 / 2
				--          = @echo_cnt / (2 * 10^6/34000*2)
				--          = @echo_cnt /  117.6470588235294
				-- when divide by 118, there is a approximately 0.3% error
				if echo_cnt = 118 then
					-- decimal
					if dist_buf(3 downto 0) = "1001" then
						dist_buf <= dist_buf + 7; -- (- 9 + 16)
					else
						dist_buf <= dist_buf + 1;
					end if;
					echo_cnt <= x"00";
				end if;
				if uss_echo = '0' then -- end of one working cycle
					working <= '0';
					if echo_cnt >= 59 then
						if dist_buf(3 downto 0) = "1001" then
							dist <= dist_buf + 7; -- (- 9 + 16)
						else
							dist <= dist_buf + 1;
						end if;
					else
						dist <= dist_buf;
					end if;
				end if;
			else -- when not working
				if uss_echo = '1' then
					echo_cnt <= x"00";
					dist_buf <= x"00";
					working <= '1';	
				elsif trig_cnt = 50000 then -- 25ms
					uss_trig <= '1';
				elsif trig_cnt = 50000 + 20 then -- 10us pulse
					uss_trig <= '0';
					trig_cnt <= x"0000";
				end if;
			end if;
		end if;
	end process;
	
end arch_uss;
