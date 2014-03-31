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
		last_seven_seg: 	out std_logic_vector(6 downto 0)	--msb
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
			MHours:				out std_logic_vector(16 downto 0);
			MMinutes:			out std_logic_vector(11 downto 0);
			MSeconds:			out std_logic_vector(5 downto 0)
		);
	end component;

	-- load/enable signals
	signal count_en:	std_logic;
	signal synch_en:	std_logic;
	signal DST_enable:	std_logic;
	
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
	
	-- Current value signals
	signal years: 		std_logic_vector(11 downto 0);
	signal months: 		std_logic_vector(3 downto 0);
	signal days: 		std_logic_vector(4 downto 0);
	signal hours: 		std_logic_vector(4 downto 0);
	signal minutes: 	std_logic_vector(5 downto 0);
	signal seconds: 	std_logic_vector(5 downto 0);
	signal eod: 		std_logic;
	
	signal Mhours: 		std_logic_vector(4 downto 0);
	signal Mminutes: 	std_logic_vector(5 downto 0);
	signal Mseconds: 	std_logic_vector(5 downto 0);
	
	signal timeZone: 	std_logic_vector(4 downto 0);
	signal load_value: 	std_logic_vector(7 downto 0);
	
	-- State signals
	signal stateA:		std_logic; -- View
	signal stateB:		std_logic; -- Set date/time
	signal stateC:		std_logic; -- Set time zone
	signal stateD:		std_logic; -- synchronize
	
begin
	load_type <= view_select_two & view_select_one;
	
	-- State determiner -- 
	state_values: process(stateSelectors)
	begin
		if clock = '1' and clock'event then
			stateA <= '0';
			stateB <= '0';
			stateC <= '0';
			stateD <= '0';
			
			if stateSelectors = "001" then 
				stateB <= '1';
			elsif stateSelectors = "010" then
				stateC <= '1';
			elsif stateSelectors = "100" then
				stateD <= '1';
			else
				stateA <= '1';
			end if;
		end if;
	end process;
	
	-- State A -- View date/time value --
	stateA_process: process(stateA, inputs)
	begin
		if clock = '1' and clock'event then
			if stateA = '1' then
				count_en <= inputs(0);
				TorD <= inputs(1);
				EorM <= inputs(2);
				DST_enable <= inputs(3);
			else
				count_enable <= '0';
			end if;
		end if;
	end process;
	
	-- State B -- Set date/time value --
	stateB_process: process(stateB, inputs, yearHour, monthMinute, daySecond)
	begin
		if clock = '1' and clock'event then
			if stateB = '1' then 
				TorD <= inputs(5);
				DST_enable <= inputs(6);
				
				load_dt = '1';
				
				-- set load value
				if inputs(4) = '0' then
					load_value(3 downto 0) <= inputs(3 downto 0);
				else
					load_value(7 downto 4) <= inputs(3 downto 0);
				end if;
				
				-- set load type
				if daySecond = '1' then
					if time_or_day = '0' then second_set <= load_value(5 downto 0);
					else day_set <= load_value(4 downto 0);
					end if;
				elsif monthMinute = '1' then
					if time_or_day = '0' then minute_set <= load_value(5 downto 0);
					else month_set <= load_value(3 downto 0);
					end if;
				elsif yearHour = '1' then
					if time_or_day = '0' then hour_set <= load_value(4 downto 0);
					else year_set <= load_value(6 downto 0) + 2000;
					end if;
				end if;
			else
				load_dt = '0';
			end if;
		end if;
	end process;
	
	-- State C -- Set time zone value --
	stateC_process: process(stateC, upper_lower, load_type)
	begin
		if clock = '1' and clock'event then
			if stateC = '1' then 
				load_tz <= '1';
				earth_mars <= inputs(6);
				-- time zone module
			else
				load_tz <= '0';
			end if;
		end if;
	end process;

	-- State D -- Synchronize mars clock --
	stateD_process: process(stateD)
	begin
		if clock = '1' and clock'event then
			if stateD = '1' then 
				synch_enable <= '1';
				load_sync <= '1';
			else
				synch_enable <= '0';
			end if;
		end if;
	end process;	
	stateD2_process: process(load_sync)
	begin
		if clock = '1' and clock'event then
			if load_sync = '1' then
				load_sync <= '0';
			end if;
		end if;
	end process;
	
	
	timer : g31_basic_timer
	PORT MAP(
		reset => not reset,
		clock => clock,
		enable => count_enable,
		EPULSE => epulse);
	
	YMDCounter : g31_YMD_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		day_count_en => eod,
		load_enable => load_dt,
		M_Set => month_set,
		Y_Set => year_set,
		D_Set => day_set,
		Years => years,
		Months => months,
		Days => days);
	
	HMSCounter: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => epulse,
		load_enabled => load_EDT,
		H_Set => "00000",
		M_Set => "000000",
		S_Set => "000000",
		Hours => hours,
		Minutes => minutes,
		Seconds => seconds,
		end_of_day => eod);
	
	synchronizer: g31_UTC_to_MTC
	PORT MAP(
		clock => clock,
		reset => not reset,
		load_enabled => load_sync,
		count_enabled => synch_en,
		desired_years => years,
		desired_months => months,
		desired_days => months,
		desired_hours => hours,
		desired_minutes => minutes,
		desired_seconds => seconds,
		MHours => Mhours,
		MMinutes => Mminutes,
		MSeconds => Mseconds);
end a;