library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity g31_user_interface is
	
	port(
		clock: 				in std_logic;
		
		-- buttons --
		reset: 				in std_logic;
		yearHour:			in std_logic;
		monthMinute:		in std_logic;
		daySecond:			in std_logic;
		
		-- switches --
		stateSelectors:		in std_logic_vector(2 downto 0);
		inputs:				in std_logic_vector(6 downto 0);
				
		-- outputs --
		DST_value:			out std_logic; -- boolean LED
		first_seven_seg: 	out std_logic_vector(6 downto 0);	--lsb
		second_seven_seg: 	out std_logic_vector(6 downto 0);
		third_seven_seg: 	out std_logic_vector(6 downto 0);
		last_seven_seg: 	out std_logic_vector(6 downto 0);	--msb
		
		leds:				out std_logic_vector(5 downto 0);
		-- test outputs --
		year_out:			out std_logic_vector(11 downto 0);
		months_out:			out std_logic_vector(3 downto 0);
		days_utc_out:		out std_logic_vector(4 downto 0);
		days_tz_out:		out std_logic_vector(4 downto 0);
		hours_utc_out:		out std_logic_vector(4 downto 0);
		hours_tz_out:		out std_logic_vector(4 downto 0);
		minutes_out:		out std_logic_vector(5 downto 0);
		seconds_out:		out std_logic_vector(5 downto 0);
		Mhours_out:			out std_logic_vector(4 downto 0);
		Mminutes_out:		out std_logic_vector(5 downto 0);
		Mseconds_out:		out std_logic_vector(5 downto 0);
		load_sync_out:		out std_logic;
		
		state:				out std_logic_vector(3 downto 0)
	);

end g31_user_interface;

architecture behaviour of g31_user_interface is
	
	component g31_basic_timer
	PORT(
			reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic;
			MPULSE	: out std_logic
	);
	end component;
	
	component g31_YMD_Counter
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
			Seconds			: out std_logic_vector(5 downto 0);
			end_of_day		: out std_logic);
			
	end component;
	
	component g31_UTC_to_MTC
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
			MSeconds:			out std_logic_vector(5 downto 0)
		);
	end component;
	
	component g31_time_zone_converter
		port (
			clock		: in std_logic;
			dst			: in std_logic;
			
			earth_time_zone		: in std_logic_vector(4 downto 0);
			mars_time_zone		: in std_logic_vector(4 downto 0);
			
			earth_local_days	: in std_logic_vector(4 downto 0);
			earth_local_hours	: in std_logic_vector(4 downto 0);
			
			earth_utc_days		: in std_logic_vector(4 downto 0);
			earth_utc_hours		: in std_logic_vector(4 downto 0);
			
			mars_MTC_hours  	: in std_logic_vector(4 downto 0);
			
			earth_utc_days_out	: out std_logic_vector(4 downto 0);
			earth_utc_hours_out	: out std_logic_vector(4 downto 0);

			earth_tz_days_out	: out std_logic_vector(4 downto 0);
			earth_tz_hours_out	: out std_logic_vector(4 downto 0);
			
			mars_tz_hours_out	: out std_logic_vector(4 downto 0)
		);
	end component;

	component g31_binary_to_seven_segment
		port (
			clock		: in std_logic;
			bin			: in unsigned(11 downto 0);
			segments1	: out std_logic_vector(6 downto 0); -- lsb 7 seg
			segments2	: out std_logic_vector(6 downto 0);
			segments3	: out std_logic_vector(6 downto 0);
			segments4	: out std_logic_vector(6 downto 0) -- msb 7 seg
		);
	end component;

	-- load/enable signals
	signal count_en:	std_logic;
	signal sync_en:		std_logic;
	signal DST_enable:	std_logic;
	signal DST_en1:		std_logic;
	signal DST_en2:		std_logic;
	
	signal TorD:		std_logic;
	signal EorM:		std_logic;
	
	signal load_EDT:	std_logic;
	signal load_MDT:	std_logic;
	signal load_sync:	std_logic;
	
	-- Set signals
	signal year_set: 		std_logic_vector(11 downto 0);
	signal month_set: 		std_logic_vector(3 downto 0);
	signal day_local_set: 	std_logic_vector(4 downto 0);
	signal day_utc_set: 	std_logic_vector(4 downto 0);
	signal hour_local_set: 	std_logic_vector(4 downto 0);
	signal hour_utc_set: 	std_logic_vector(4 downto 0);
	signal minute_set: 		std_logic_vector(5 downto 0);
	signal second_set: 		std_logic_vector(5 downto 0);
	signal Mhours_set:		std_logic_vector(4 downto 0);
	signal Mminutes_set:	std_logic_vector(5 downto 0);
	signal Mseconds_set:	std_logic_vector(5 downto 0);
	
	-- Current value signals
	signal years: 		std_logic_vector(11 downto 0);
	signal months: 		std_logic_vector(3 downto 0);
	signal days_utc: 	std_logic_vector(4 downto 0);
	signal days_tz: 	std_logic_vector(4 downto 0);
	signal hours_utc:	std_logic_vector(4 downto 0);
	signal hours_tz:	std_logic_vector(4 downto 0);
	signal minutes: 	std_logic_vector(5 downto 0);
	signal seconds: 	std_logic_vector(5 downto 0);
	signal Eeod: 		std_logic;
	signal epulse:		std_logic;
	signal Meod:		std_logic;
	signal mpulse:		std_logic;
	
	signal Mhours_mtc:	std_logic_vector(4 downto 0);
	signal Mhours_tz:	std_logic_vector(4 downto 0);
	signal Mminutes: 	std_logic_vector(5 downto 0);
	signal Mseconds: 	std_logic_vector(5 downto 0);
	
	signal ETimeZone: 	std_logic_vector(4 downto 0);
	signal MTimeZone: 	std_logic_vector(4 downto 0);
	signal load_value: 	std_logic_vector(7 downto 0);
	
	-- State signals
	signal stateA:		std_logic; -- View
	signal stateB:		std_logic; -- Set date/time
	signal stateC:		std_logic; -- Set time zone
	signal stateD:		std_logic; -- synchronize
	
	-- Output signals
	signal seven_segment_in:	std_logic_vector(11 downto 0);
	
begin	
	year_out <= years + "011111010000";
	months_out <= months;
	days_utc_out <= days_utc;
	days_tz_out <= days_tz;
	hours_utc_out <= hours_utc;
	hours_tz_out <= hours_tz;
	minutes_out <= minutes;
	seconds_out <= seconds;
	Mhours_out <= Mhours_mtc;
	Mminutes_out <= Mminutes;
	Mseconds_out <= Mseconds;
	state <= stateA & stateB & stateC & stateD;
	dst_value <= dst_enable;
	load_sync_out <= load_sync;
	
	-- State determiner -- 
	state_values: process(stateSelectors, sync_en, clock)
	begin
		if clock = '1' and clock'event then			
			if stateSelectors = "001" then -- Set B
				stateA <= '0';
				stateB <= '1';
				stateC <= '0';
				stateD <= '0';
			elsif stateSelectors = "010" then -- Set C
				stateA <= '0';
				stateB <= '0';
				stateC <= '1';
				stateD <= '0';
			elsif stateSelectors = "100" then -- Set D
				stateA <= '0';
				stateB <= '0';
				stateC <= '0';
				stateD <= '1';
			else -- Set A
				stateA <= '1';
				stateB <= '0';
				stateC <= '0';
				stateD <= '0';
			end if;
		end if;
	end process;
	
	-- State A -- View date/time value --
	-- switch value list
	-- 0) count enable
	-- 1) view time or date
	-- 2) view earth or mars
	-- 3) set DST
	-- 4-6) null
	stateA_process: process(stateA, inputs, clock)
	begin
		if clock = '1' and clock'event then
			if stateA = '1' then
				count_en <= inputs(0);
				TorD <= inputs(1);
				EorM <= inputs(2);
				DST_enable <= inputs(3);
				if TorD = '0' then
					if EorM = '0' then
						if daySecond = '0' then
							seven_segment_in <= "000000" & seconds;
						elsif monthMinute = '0' then
							seven_segment_in <= "000000" & minutes;
						elsif yearHour = '0' then
							seven_segment_in <= "0000000" & hours_tz;
						else 
							seven_segment_in <= "0000000" & ETimeZone;
						end if;
					else
						if daySecond = '0' then
							seven_segment_in <= "000000" & Mseconds;
						elsif monthMinute = '0' then
							seven_segment_in <= "000000" & Mminutes;
						elsif yearHour = '0' then
							seven_segment_in <= "0000000" & Mhours_tz;
						else 
							seven_segment_in <= "0000000" & MTimeZone;
						end if;
					end if;
				else 
					if EorM = '0' then
						if daySecond = '0' then
							seven_segment_in <= "0000000" & days_tz;
						elsif monthMinute = '0' then
							seven_segment_in <= "00000000" & months;
						elsif yearHour = '0' then
							seven_segment_in <= years + "011111010000";
						else 
							seven_segment_in <= "0000000" & ETimeZone;
						end if;
					else
						seven_segment_in <= "0000000" & MTimeZone;
					end if;
				end if;
			else
				count_en <= '0';
			end if;
		end if;
	end process;
	
	-- State B -- Set date/time value --
	-- switch value list
	-- 0-3) set bits
	-- 4) set upper/lower bits
	-- 5) set time or date
	-- 6) set DST
	stateB_process: process(stateB, inputs, yearHour, monthMinute, daySecond, clock)
	begin
		if clock = '1' and clock'event then
			if stateB = '1' then
				load_EDT <= '1';
				
				-- set load value
				if inputs(4) = '0' then
					load_value(3 downto 0) <= inputs(3 downto 0);
				else
					load_value(7 downto 4) <= inputs(3 downto 0);
				end if;
				
				-- set default set values (i.e. current values)

				second_set		<= seconds;
				minute_set		<= minutes;
				hour_local_set	<= hours_tz;
				day_local_set 	<= days_tz;
				month_set 		<= months;
				year_set 		<= years;				
				
				if daySecond = '1' and monthMinute = '1' and yearHour = '1' then
					leds <= "000000";
				end if;
				
				-- set load type
				if daySecond = '0' then
					if inputs(5) = '0' then 
						second_set <= load_value(5 downto 0);
						leds(0) <= '1';
					else 
						day_local_set <= load_value(4 downto 0);
						leds(3) <= '1';
					end if;
				elsif monthMinute = '0' then
					if inputs(5) = '0' then 
						minute_set <= load_value(5 downto 0);
						leds(1) <= '1';
					else 
						month_set <= load_value(3 downto 0);
						leds(4) <= '1';
					end if;
				elsif yearHour = '0' then
					if inputs(5) = '0' then 
						hour_local_set <= load_value(4 downto 0);
						leds(2) <= '1';
					else 
						year_set <= ("00000" & load_value(6 downto 0));
						leds(5) <= '1';
					end if;
				end if;
			else
				load_EDT <= '0';
			end if;
		end if;
	end process;
	
	-- State C -- Set time zone value --
	-- switch value list
	-- 0-4) time-zone bits
	-- 5) set earth or mars
	-- 6) null
	stateC_process: process(stateC, inputs, clock)
	begin
		if clock = '1' and clock'event then
			if stateC = '1' then
				if inputs(5) = '0' then -- earth vs. mars
					ETimeZone <= inputs(4 downto 0);
				else
					MTimeZone <= inputs(4 downto 0);
				end if;
			else
			end if;
		end if;
	end process;

	-- State D -- Synchronize mars clock --
	-- switch value list
	-- 0-6) null
	stateD_process: process(stateD, clock)
	begin
		if clock = '1' and clock'event then
			if stateD = '1' then 
				if sync_en <= '0' and load_sync <= '0' then
					load_sync <= '1';
				else
					load_sync <= '0';
				end if;
				
				sync_en <= '1';
			else
				sync_en <= '0';
			end if;
		end if;
	end process;
	
	--buttonsProcess : process()
	--begin
	
	--end process;	
	
	timer : g31_basic_timer
	PORT MAP(
		reset => not reset,
		clock => clock,
		enable => count_en,
		EPULSE => epulse,
		MPULSE => mpulse
	);
	
	YMDCounter : g31_YMD_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		day_count_en => Eeod,
		load_enable => load_EDT,
		M_Set => month_set,
		Y_Set => year_set,
		D_Set => day_utc_set,
		Years => years,
		Months => months,
		Days => days_utc
	);
	
	EarthHMSCounter: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => epulse,
		load_enabled => load_EDT,
		H_Set => hour_utc_set,
		M_Set => minute_set,
		S_Set => second_set,
		Hours => hours_utc,
		Minutes => minutes,
		Seconds => seconds,
		end_of_day => Eeod
	);
		
	MarsHMSCounter: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => mpulse,
		load_enabled => sync_en,
		H_Set => Mhours_set,
		M_Set => Mminutes_set,
		S_Set => Mseconds_set,
		Hours => Mhours_mtc,
		Minutes => Mminutes,
		Seconds => Mseconds,
		end_of_day => Meod
	);
		
	synchronizer: g31_UTC_to_MTC
	PORT MAP(
		clock => clock,
		reset => not reset,
		load_enabled => load_sync,
		count_enabled => sync_en,
		desired_years => years,
		desired_months => months,
		desired_days => days_utc,
		desired_hours => hours_utc,
		desired_minutes => minutes,
		desired_seconds => seconds,
		MHours => Mhours_set,
		MMinutes => Mminutes_set,
		MSeconds => Mseconds_set
	);
		
	time_zone_converter: g31_time_zone_converter
	PORT MAP(
		clock => clock,
		dst	=> DST_enable,
		
		earth_time_zone => ETimeZone,
		mars_time_zone => MTimeZone,
		
		earth_local_days => day_local_set,
		earth_local_hours => hour_local_set,
		
		earth_utc_days => days_utc,
		earth_utc_hours	=> hours_utc,
		
		mars_MTC_hours => Mhours_mtc,
		
		earth_utc_days_out => day_utc_set,
		earth_utc_hours_out	=> hour_utc_set,

		earth_tz_days_out => days_tz,
		earth_tz_hours_out => hours_tz,
		
		mars_tz_hours_out => Mhours_tz
	);
	
	display: g31_binary_to_seven_segment
	PORT MAP(
		
		clock		=> clock,
		bin			=> unsigned (seven_segment_in),
		segments1	=> first_seven_seg, -- lsb 7 seg
		segments2	=> second_seven_seg,
		segments3	=> third_seven_seg,
		segments4	=> last_seven_seg -- msb 7 seg
	
	);
	
end behaviour;