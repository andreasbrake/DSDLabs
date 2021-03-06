library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity g31_Year_Block is 
	PORT(	clock			: in std_logic; -- master clock
			reset			: in std_logic; -- master reset
			load_enable		: in std_logic; -- master load_enable
			Y_Set			: in std_logic_vector(11 downto 0);
			month_pulse		: in std_logic;
			leap_year_set	: out std_logic;
			Years			: out std_logic_vector(11 downto 0)
		);

end g31_Year_Block;

architecture behaviour of g31_Year_Block is 
	signal years_out : std_logic_vector(11 downto 0);
begin
	
	Years <= years_out;
	
	-- Determines if this year is a leap year (signal sent to month block for analysis)
	process_leap_year: process(years_out)
	begin
	leap_year_set <= '0';
		if years_out(1 downto 0) = "00" then leap_year_set <= '1';
		end if;
	end process;
	
	-- Either increments the year, keeps the year the same, or sets the year to the pre-defined value based on the inputs
	process_counter: process(load_enable, reset, years_out, clock)
	begin
		if clock = '1' and clock'event then
			if reset = '1' then years_out <= "000000000000";
				elsif month_pulse = '1' and load_enable = '0' then years_out <= years_out + 1;
				elsif load_enable = '1' then years_out <= Y_set;
				else years_out <= years_out;
			end if;
			else years_out <= years_out;
		end if;
	end process;

end behaviour;