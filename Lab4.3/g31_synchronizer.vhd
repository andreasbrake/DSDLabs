library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity g31_synchronizer is
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
	done_out_d:			out std_logic;
	done_out_s:			out std_logic;
	day_count:			out std_logic_vector(12 downto 0);
	second_count:		out std_logic_vector(16 downto 0);
	out_years: 		out std_logic_vector(11 downto 0);
	out_months: 	out std_logic_vector(3 downto 0);
	out_days: 		out std_logic_vector(4 downto 0);
	out_hours: 		out std_logic_vector(4 downto 0);
	out_minutes:	out std_logic_vector(5 downto 0);
	out_seconds:	out std_logic_vector(5 downto 0);
	epulseOut:			out std_logic
 );
end g31_synchronizer;

architecture a of g31_synchronizer is
	component g31_short_timer
		PORT(	reset	: in std_logic;
				clock	: in std_logic;
				enable	: in std_logic;
				EPULSE	: out std_logic);
	end component;
	
	component g31_HMS_Counter
		PORT(	clock			: in std_logic; --master clock
				reset			: in std_logic; --master reset
				sec_clock		: in std_logic; --second clock
				load_enabled	: in std_logic; --
				H_Set			: in std_logic_vector(4 downto 0);
				M_Set			: in std_logic_vector(5 downto 0);
				S_Set			: in std_logic_vector(5 downto 0);
				Hours			: out std_logic_vector(4 downto 0);
				Minutes			: out std_logic_vector(5 downto 0);
				Seconds			: out std_logic_vector(5 downto 0));		
	end component;

	component g31_YMD_Counter 
		PORT(	clock			: in std_logic; -- master clock
				reset			: in std_logic; -- master reset
				day_count_en	: in std_logic; -- pulse from HMS
				load_enable		: in std_logic; -- master load_enable
				Y_Set			: in std_logic_vector(11 downto 0);
				M_Set			: in std_logic_vector(3 downto 0);
				D_Set			: in std_logic_vector(4 downto 0);
				Months			: out std_logic_vector(3 downto 0);
				Years			: out std_logic_vector(11 downto 0);
				Days			: out std_logic_vector(4 downto 0)
			);
	end component;
	
	component g31_Seconds_to_Days
		port( 	seconds			: in unsigned(16 downto 0);
				day_fractions	: out unsigned(39 downto 0) );
	end component;

	signal years: 		std_logic_vector(11 downto 0);
	signal months: 		std_logic_vector(3 downto 0);
	signal days: 		std_logic_vector(4 downto 0);
	signal hours: 		std_logic_vector(4 downto 0);
	signal minutes: 	std_logic_vector(5 downto 0);
	signal seconds:	 	std_logic_vector(5 downto 0);
	
	signal epulse:		std_logic;
	signal doneD:		std_logic;
	signal doneS:		std_logic;
	
	signal Nsec:		std_logic_vector(16 downto 0);
	signal Nday:		std_logic_vector(12 downto 0);
	signal dayFrac:		std_logic_vector(39 downto 0);
begin
	epulseOut <= epulse;
	day_count <= Nday;
	second_count <= Nsec;
	
	done_out_d <= doneD;
	done_out_s <= doneS;
	
	out_years <= years;
	out_months <= months;
	out_days <= days;
	out_hours <= hours;
	out_minutes <= minutes;
	out_seconds <= seconds;
	
	-- Sets the done value if the conditions are met
	process_done_days: process(years, months, days, desired_years, desired_months, desired_days, doneD)
	begin
		if years >= desired_years and months >= desired_months and days >= desired_days then doneD <= '1';
		else doneD <= '0';
		end if;
	end process;
	process_done_seconds: process(hours, minutes, seconds, desired_hours, desired_minutes, desired_seconds, doneS)
	begin
		if hours >= desired_hours and minutes >= desired_minutes and seconds >= desired_seconds then doneS <= '1';
		else doneS <= '0';
		end if;
	end process;
	
	-- increments the Nday counter on the epulse when doneD = '0'
	process_coun_d: process(epulse, doneD, clock)
	begin
		if clock = '1' and clock'event then
			if doneD = '0' and epulse = '1' then Nday <=Nday  + 1;
			else Nday <= Nday;
			end if;
		end if;
	end process;
	
	-- increments the Nsec counter on the epulse and the Nday counter on the eod pulse
	process_count_s: process(epulse, doneS, clock)
	begin
		if clock = '1' and clock'event then
			if doneS = '0'  and epulse = '1' then Nsec <= Nsec + 1;
			else Nsec <= Nsec;
			end if;
		end if;
	end process;
	
-- COMPONENT CREATION / PORT MAPS --
	timer: g31_short_timer
	PORT MAP(	
		reset	=> reset,
		clock	=> clock,
		enable	=> count_enabled and not (doneD and doneS),
		EPULSE	=> epulse);
		
	HMSCounter: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => reset,
		sec_clock => epulse and not doneS,
		load_enabled => load_enabled,
		H_Set => "00000",
		M_Set => "000000",
		S_Set => "000000",
		Hours => hours,
		Minutes => minutes,
		Seconds => seconds);

	YMDCounter : g31_YMD_Counter
	PORT MAP(
		clock => clock,
		reset => reset,
		day_count_en  => epulse and not doneD,
		load_enable => load_enabled,
		M_Set => "0001",
		Y_Set => "011111010000",
		D_Set => "00110",
		Months => months,
		Years => years,
		Days => days
	);
end a;