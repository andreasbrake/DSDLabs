library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity g31_Day_Block is 
	PORT(	clock			: in std_logic; -- master clock
			reset			: in std_logic; -- master reset
			load_enable		: in std_logic; -- master load_enable
			D_Set			: in std_logic_vector(4 downto 0);
			day_count_en	: in std_logic; -- pulse from HMS
			max_day_set		: in std_logic_vector(1 downto 0);
			day_pulse		: out std_logic;
			Days			: out std_logic_vector(4 downto 0)
		);

end g31_Day_Block;

architecture behaviour of g31_Day_Block is 
	signal max_days_in	: std_logic_vector(4 downto 0);
	signal days_out	: std_logic_vector(4 downto 0);
	signal internal_reset : std_logic;
	signal pulse: std_logic;
begin

	internal_reset <= pulse or reset;
	Days <= days_out;
	day_pulse <= pulse;
	
	-- Sets the max number of days based on the input received from the month counter
	process_set : process(max_day_set)
	begin
		if max_day_set = "00" then max_days_in <= "11100";
			elsif max_day_set = "01" then max_days_in <= "11101";
			elsif max_day_set = "10" then max_days_in <= "11110";
			else max_days_in <= "11111";
		end if;
	end process;

	-- Either increments the day, keeps the day the same, or sets the day to the pre-defined value based on the inputs
	process_counter: process(load_enable, internal_reset, days_out, clock)
	begin
		if clock = '1' and clock'event then
			if internal_reset = '1' then days_out <= "00001";
			elsif day_count_en = '1' and load_enable = '0' then days_out <= (days_out) + 1;
			elsif load_enable = '1' then days_out <= D_set;
			else days_out <= days_out;
			end if;
		else days_out <= days_out;
		end if;
	end process;

	-- Determines if the day counter has reached the final day in the month
	process_pulse: process(max_days_in, days_out)
	begin
		if days_out < max_days_in then pulse <= '0';
		else pulse <= '1';
		end if;
	end process;

end behaviour;