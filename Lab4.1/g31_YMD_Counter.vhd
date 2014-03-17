library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g31_YMD_Counter is 
	PORT(	clock			: in std_logic; -- master clock
			reset			: in std_logic; -- master reset
			day_count_en	: in std_logic; -- pulse from HMS
			load_enable		: in std_logic; -- master load_enable
			M_Set			: in std_logic_vector(3 downto 0);
			Y_Set			: in std_logic_vector(11 downto 0);
			D_Set			: in std_logic_vector(4 downto 0);
			Months			: out std_logic_vector(3 downto 0);
			Years			: out std_logic_vector(11 downto 0);
			Days			: out std_logic_vector(4 downto 0)
		);

end g31_YMD_Counter;

architecture behaviour of g31_YMD_Counter is 
	component g31_Day_Block 
		PORT(	clock			: in std_logic; -- master clock
				reset			: in std_logic; -- master reset
				day_count_en	: in std_logic; -- pulse from HMS
				load_enable		: in std_logic; -- master load_enable
				max_day_set		: in std_logic_vector(1 downto 0);
				D_Set			: in std_logic_vector(4 downto 0);
				day_pulse		: out std_logic;
				Days			: out std_logic_vector(4 downto 0));
	end component;
	component g31_Month_Block 
		PORT(	clock			: in std_logic; -- master clock
				reset			: in std_logic; -- master reset
				load_enable		: in std_logic; -- master load_enable
				month_count_en	: in std_logic;
				leap_year_set	: in std_logic;
				M_Set			: in std_logic_vector(3 downto 0);
				month_pulse		: out std_logic;
				max_day_set		: out std_logic_vector(1 downto 0);
				Months			: out std_logic_vector(3 downto 0));
	end component;
	component g31_Year_Block 
		PORT(	clock			: in std_logic; -- master clock
				reset			: in std_logic; -- master reset
				load_enable		: in std_logic; -- master load_enable
				Y_Set			: in std_logic_vector(11 downto 0);
				month_pulse		: in std_logic;
				leap_year_set	: out std_logic;
				Years			: out std_logic_vector(11 downto 0));
	end component;
	
	signal max_day_set : std_logic_vector(1 downto 0);
	signal leap_year_set : std_logic;
	signal day_pulse : std_logic;
	signal month_pulse: std_logic;
	signal day_signal : std_logic_vector(4 downto 0);
	signal month_signal: std_logic_vector(3 downto 0);
	signal year_signal: std_logic_vector(11 downto 0);
	
begin

	day_block : g31_Day_Block
	PORT MAP(
				reset 			=> reset,
				load_enable		=> load_enable,
				clock 			=> clock,
				day_count_en	=> day_count_en,
				D_Set			=> D_Set,
				max_day_set		=> max_day_set,
				day_pulse 		=> day_pulse,
				Days			=> day_signal
	);
	
	month_block : g31_Month_Block
	PORT MAP(
				reset 			=> reset,
				load_enable		=> load_enable,
				month_count_en 	=> day_pulse,
				clock 			=> clock,
				M_Set			=> M_Set,
				max_day_set		=> max_day_set,
				leap_year_set	=> leap_year_set,
				Months			=> month_signal,
				month_pulse		=> month_pulse
	);
	
	year_block : g31_Year_Block
	PORT MAP(
				reset 			=> reset,
				load_enable		=> load_enable,
				clock 			=> clock,
				Y_Set			=> Y_Set,
				leap_year_set	=> leap_year_set,
				Years			=> year_signal,
				month_pulse		=> month_pulse
	);
	
	Years <= year_signal;
	Months <= month_signal;
	Days <= day_signal;
	
end behaviour;