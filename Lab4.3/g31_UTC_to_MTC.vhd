library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.lpm_components.all;

entity g31_UTC_to_MTC is
	PORT(
		clock: 				in std_logic;
		reset:				in std_logic;
		load_enabled:		in std_logic;
		count_enabled:		in std_logic;
		desired_years: 		in std_logic_vector(11 downto 0);
		desired_months: 	in std_logic_vector(3 downto 0);
		desired_days: 		in std_logic_vector(4 downto 0);
		desired_hours: 		in std_logic_vector(4 downto 0);
		desired_minutes:	in std_logic_vector(5 downto 0);
		desired_seconds:	in std_logic_vector(5 downto 0);
		MHours:				out std_logic_vector(4 downto 0);
		MMinutes:			out std_logic_vector(5 downto 0);
		MSeconds:			out std_logic_vector(5 downto 0);
		dayCountOut:		out std_logic_vector(12 downto 0);
		secCountOut:		out std_logic_vector(16 downto 0);
		leaps:				out std_logic_vector(5 downto 0)
	);
end g31_UTC_to_MTC;

architecture a of g31_UTC_to_MTC is
	component g31_synchronizer
		port(
			clock: 				in std_logic;
			reset:				in std_logic;
			load_enabled:		in std_logic;
			count_enabled:		in std_logic;
			desired_years: 		in std_logic_vector(11 downto 0);
			desired_months: 	in std_logic_vector(3 downto 0);
			desired_days: 		in std_logic_vector(4 downto 0);
			desired_hours: 		in std_logic_vector(4 downto 0);
			desired_minutes:	in std_logic_vector(5 downto 0);
			desired_seconds:	in std_logic_vector(5 downto 0);
			day_count:			out std_logic_vector(12 downto 0);
			second_count:		out std_logic_vector(16 downto 0);
			out_leaps:			out std_logic_vector(5 downto 0)
		);
	end component;
	
	component g31_date_compressor is
		port(
			NDays: 	in std_logic_vector(12 downto 0);
			NSecs:	in std_logic_vector(16 downto 0);
			NDate:	out std_logic_vector(29 downto 0)
		);
	end component;

	component g31_mars_converter is
		port(
			JDEarth: 		in std_logic_vector(29 downto 0);
			MHours:			out std_logic_vector(4 downto 0);
			MMinutes:		out std_logic_vector(5 downto 0);
			MSeconds:		out std_logic_vector(5 downto 0)
		);
	end component;
	
	signal dayCount: 	std_logic_vector(12 downto 0);
	signal secCount: 	std_logic_vector(16 downto 0);
	signal dateCount:	std_logic_vector(29 downto 0);
	signal done:		std_logic;
	
	signal dayCount2: 	std_logic_vector(12 downto 0);
	signal secCount2: 	std_logic_vector(16 downto 0);
	signal dateCount2:	std_logic_vector(29 downto 0);
begin
	dayCountOut <= dayCount;
	secCountOut <= secCount;
	
	reset_process: process(reset, dayCount2, secCount2, dateCount2)
	begin
		if reset = '1' then
			dayCount <= "0000000000000";
			secCount <= "00000000000000000";
			dateCount <= "000000000000000000000000000000";
		else
			dayCount <= dayCount2;
			secCount <= secCount2;
			dateCount <= dateCount2;
		end if;	
	end process;
	
	sync: g31_synchronizer
	PORT MAP(
		clock => clock,
		reset => reset,
		load_enabled => load_enabled,
		count_enabled => count_enabled,
		desired_years => desired_years,
		desired_months => desired_months,
		desired_days => desired_days,
		desired_hours => desired_hours,
		desired_minutes => desired_minutes,
		desired_seconds => desired_seconds,
		day_count => dayCount2,
		second_count => secCount2,
		out_leaps => leaps
	);
	
	compressor: g31_date_compressor
	PORT MAP(
		NDays => dayCount,
		NSecs => secCount,
		NDate => dateCount2
	);
	
	converter: g31_mars_converter
	PORT MAP(
		JDEarth => dateCount,
		MHours => MHours,
		MMinutes => MMinutes,
		MSeconds => MSeconds
	);
end a;

