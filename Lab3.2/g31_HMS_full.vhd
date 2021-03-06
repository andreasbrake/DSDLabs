library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_HMS_Full is
	PORT(	clock			: in std_logic; --master clock
			reset			: in std_logic; --master reset
			count_enabled	: in std_logic; --master enable
			load_enabled	: in std_logic; --
			H_Set			: in std_logic_vector(4 downto 0);
			M_Set			: in std_logic_vector(5 downto 0);
			S_Set			: in std_logic_vector(5 downto 0);
			eHours			: out std_logic_vector(4 downto 0);
			eMinutes		: out std_logic_vector(5 downto 0);
			eSeconds		: out std_logic_vector(5 downto 0);
			e_end_of_day	: out std_logic;
			mHours			: out std_logic_vector(4 downto 0);
			mMinutes		: out std_logic_vector(5 downto 0);
			mSeconds		: out std_logic_vector(5 downto 0);
			m_end_of_day	: out std_logic);
			
end g31_HMS_Full;

architecture a of g31_HMS_Full is
	component g31_basic_timer 
		PORT(	reset	: in std_logic;
				clock	: in std_logic;
				enable	: in std_logic;
				EPULSE	: out std_logic;
				MPULSE	: out std_logic);
	end component;

	component g31_HMS_Counter 
		PORT(	clock			: in std_logic; --master clock
			reset			: in std_logic; --master reset
			sec_clock		: in std_logic; --second clock
			count_enabled	: in std_logic; --master enable
			load_enabled	: in std_logic; --
			H_Set			: in std_logic_vector(4 downto 0);
			M_Set			: in std_logic_vector(5 downto 0);
			S_Set			: in std_logic_vector(5 downto 0);
			Hours			: out std_logic_vector(4 downto 0);
			Minutes			: out std_logic_vector(5 downto 0);
			Seconds			: out std_logic_vector(5 downto 0);
			end_of_day		: out std_logic);
			
	end component;
	
	signal epulse: std_logic;
	signal mpulse: std_logic;
begin
	timer: g31_basic_timer
	PORT MAP(	reset => not reset,
				clock => clock,
				enable=>count_enabled,
				EPULSE => epulse,
				MPULSE => mpulse);
	
	counter1: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => epulse,
		count_enabled => count_enabled,
		load_enabled => load_enabled,
		H_Set => H_Set,
		M_Set => M_Set,
		S_Set => S_Set,
		Hours => eHours,
		Minutes => eMinutes,
		Seconds => eSeconds,
		end_of_day => e_end_of_day);
	
	counter2: g31_HMS_Counter
	PORT MAP(
		clock => clock,
		reset => not reset,
		sec_clock => mpulse,
		count_enabled => count_enabled,
		load_enabled => load_enabled,
		H_Set => H_Set,
		M_Set => M_Set,
		S_Set => S_Set,
		Hours => mHours,
		Minutes => mMinutes,
		Seconds => mSeconds,
		end_of_day => m_end_of_day);
end a;