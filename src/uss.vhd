LIBRARY IEEE ; 
USE IEEE.STD_LOGIC_1164.ALL ; 
USE IEEE.STD_LOGIC_UNSIGNED.ALL ; 
USE IEEE.STD_LOGIC_ARITH.ALL;


-- assume a 2M pulse (0.5us) via @clk
-- uss constantly report distance
entity uss is
	port(
		clk: in std_logic;
		--dist: out integer range 0 to 15; -- in cm
		man_x_speed_out: out integer range -2 to 2;
		
		uss_trig: out std_logic := '0';
		uss_echo: in std_logic
	);
end uss;

architecture arch_uss of uss is
	constant CLK_FREQ: integer := 2000000;
	constant TRIG_INTERVAL_CNT: integer := CLK_FREQ / 40; -- 1/40 sec = 25 ms
	constant TRIG_TIME_CNT: integer := CLK_FREQ / 100000; -- 1/100000 sec = 10 us
	
	constant ONE_CM_PER_CNT: integer := CLK_FREQ / 34000 * 2;
	constant HALF_CM_PER_CNT: integer := ONE_CM_PER_CNT / 2;
	
	constant ONE_DIGIT_PER_CNT: integer := ONE_CM_PER_CNT * 5 * 3 / 8;
	constant HALF_DIGIT_PER_CNT: integer := ONE_DIGIT_PER_CNT / 2;
	
	constant DIST_MIN: integer := 6;
	constant DIST_MAX: integer := 20;
	
	signal echo_cnt: std_logic_vector(7 downto 0); -- 65.536ms -> 22m
	signal trig_cnt: std_logic_vector(15 downto 0);
	signal working: std_logic := '0';
	signal dist_buf: integer range 0 to DIST_MAX;
	signal man_x_speed: integer range -4 to 2;
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
				if echo_cnt = ONE_DIGIT_PER_CNT then
					if man_x_speed	/= 2 then
						man_x_speed <= man_x_speed + 1;
					end if;
					echo_cnt <= x"00";
				end if;
				if uss_echo = '0' then -- end of one working cycle
					working <= '0';
					if man_x_speed < -2 then
						man_x_speed_out <= -2;
					else
						man_x_speed_out <= man_x_speed;
					end if;
					
					-- round
--					if echo_cnt >= HALF_DIGIT_CM_PER_CNT then
--						if dist_buf /= 15 then
--							dist <= dist_buf + 1;
--						end if;
--					else
--						dist <= dist_buf;
--					end if;
				end if;
			else -- when not working
				if uss_echo = '1' then -- start working
					echo_cnt <= x"00";
					man_x_speed <= -4;
					working <= '1';	
				elsif trig_cnt = TRIG_INTERVAL_CNT then
					uss_trig <= '1';
				elsif trig_cnt = TRIG_INTERVAL_CNT + TRIG_TIME_CNT then
					uss_trig <= '0';
					trig_cnt <= x"0000";
				end if;
			end if;
		end if;
	end process;
	
end arch_uss;
