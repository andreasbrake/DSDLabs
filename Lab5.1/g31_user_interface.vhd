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
		
		-- test outputs --
		year_out:			out std_logic_vector(11 downto 0);
		months_out:			out std_logic_vector(3 downto 0);
		days_out:			out std_logic_vector(4 downto 0);
		hours_out:			out std_logic_vector(4 downto 0);
		minutes_out:		out std_logic_vector(5 downto 0);
		seconds_out:		out std_logic_vector(5 downto 0);
		Mhours_out:			out std_logic_vector(4 downto 0);
		Mminutes_out:		out std_logic_vector(5 downto 0);
		Mseconds_out:		out std_logic_vector(5 downto 0);
		load_sync_out:		out std_logic;
		
		state:				out std_logic_vector(3 downto 0)
	);
end g31_user_interface;

architecture a of g31_user_interface is
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
	signal year_set: 	std_logic_vector(11 downto 0);
	signal month_set: 	std_logic_vector(3 downto 0);
	signal day_set: 	std_logic_vector(4 downto 0);
	signal hour_set: 	std_logic_vector(4 downto 0);
	signal minute_set: 	std_logic_vector(5 downto 0);
	signal second_set: 	std_logic_vector(5 downto 0);
	signal Mhours_set:	std_logic_vector(4 downto 0);
	signal Mminutes_set:std_logic_vector(5 downto 0);
	signal Mseconds_set:std_logic_vector(5 downto 0);
	
	-- Current value signals
	signal years: 		std_logic_vector(11 downto 0);
	signal months: 		std_logic_vector(3 downto 0);
	signal days: 		std_logic_vector(4 downto 0);
	signal hours: 		std_logic_vector(4 downto 0);
	signal minutes: 	std_logic_vector(5 downto 0);
	signal seconds: 	std_logic_vector(5 downto 0);
	signal Eeod: 		std_logic;
	signal epulse:		std_logic;
	signal Meod:		std_logic;
	signal mpulse:		std_logic;
	
	signal Mhours: 		std_logic_vector(4 downto 0);
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
	
begin	
	year_out <= years;
	months_out <= months;
	days_out <= days;
	hours_out <= hours;
	minutes_out <= minutes;
	seconds_out <= seconds;
	Mhours_out <= Mhours;
	Mminutes_out <= Mminutes;
	Mseconds_out <= Mseconds;
	state <= stateA & stateB & stateC & stateD;
	dst_value <= dst_enable;
	load_sync_out <= load_sync;
	
	DST_enable <= DST_en1 or DST_en2;
	-- State determiner -- 
	state_values: process(stateSelectors, sync_en)
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
	stateA_process: process(stateA, inputs)
	begin
		if clock = '1' and clock'event then
			if stateA = '1' then
				count_en <= inputs(0);
				TorD <= inputs(1);
				EorM <= inputs(2);
				DST_en1 <= inputs(3);
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
	stateB_process: process(stateB, inputs, yearHour, monthMinute, daySecond)
	begin
		if clock = '1' and clock'event then
			if stateB = '1' then 
				DST_en2 <= inputs(6);
				load_EDT <= '1';
				
				-- set load value
				if inputs(4) = '0' then
					load_value(3 downto 0) <= inputs(3 downto 0);
				else
					load_value(7 downto 4) <= inputs(3 downto 0);
				end if;
				
				-- set load type
				if daySecond = '1' then
					if inputs(5) = '0' then second_set <= load_value(5 downto 0);
					else day_set <= load_value(4 downto 0);
					end if;
				elsif monthMinute = '1' then
					if inputs(5) = '0' then minute_set <= load_value(5 downto 0);
					else month_set <= load_value(3 downto 0);
					end if;
				elsif yearHour = '1' then
					if inputs(5) = '0' then hour_set <= load_value(4 downto 0);
					else year_set <= ("00000" & load_value(6 downto 0)) + 2000;
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
	stateC_process: process(stateC, inputs)
	begin
		if clock = '1' and clock'event then
			if stateC = '1' then 
				EorM <= inputs(5);
				if EorM  = '1' then
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
	stateD_process: process(stateD)
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
	
	timer : g31_basic_timer
	PORT MAP(
		reset => not reset,
		clock => clock,
		enable => count_en,
		EPULSE => epulse,
		MPULSE => mpulse);
	
	YMDCounter : g31_YMD_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		day_count_en => Eeod,
		load_enable => load_EDT,
		M_Set => month_set,
		Y_Set => year_set,
		D_Set => day_set,
		Years => years,
		Months => months,
		Days => days);
	
	EarthHMSCounter: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => epulse,
		load_enabled => load_EDT,
		H_Set => hour_set,
		M_Set => minute_set,
		S_Set => second_set,
		Hours => hours,
		Minutes => minutes,
		Seconds => seconds,
		end_of_day => Eeod);
		
	MarsHMSCounter: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => mpulse,
		load_enabled => sync_en,
		H_Set => Mhours_set,
		M_Set => Mminutes_set,
		S_Set => Mseconds_set,
		Hours => Mhours,
		Minutes => Mminutes,
		Seconds => Mseconds,
		end_of_day => Meod);
		
	synchronizer: g31_UTC_to_MTC
	PORT MAP(
		clock => clock,
		reset => not reset,
		load_enabled => load_sync,
		count_enabled => sync_en,
		desired_years => years + 2000,
		desired_months => months,
		desired_days => days,
		desired_hours => hours,
		desired_minutes => minutes,
		desired_seconds => seconds,
		MHours => Mhours_set,
		MMinutes => Mminutes_set,
		MSeconds => Mseconds_set);
end a;