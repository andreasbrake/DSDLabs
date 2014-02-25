library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_test_bed is
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			eOneSeg	: out std_logic_vector(6 downto 0);
			eTenSeg	: out std_logic_vector(6 downto 0);
			mOneSeg	: out std_logic_vector(6 downto 0);
			mTenSeg	: out std_logic_vector(6 downto 0));
end g31_test_bed;

architecture a of g31_test_bed is
	component g31_basic_timer
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic;
			MPULSE	: out std_logic);
	end component;
	
	component g31_time_counter
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			pulseIn	: in std_logic;
			oneSeg	: out std_logic_vector(6 downto 0);
			tenSeg	: out std_logic_vector(6 downto 0));
	end component;
	
	signal epulse	: std_logic;
	signal mpulse	: std_logic;
	
begin	
	timer		: g31_basic_timer
	PORT MAP(	reset 	=> not reset,
				clock 	=> clock,
				enable 	=> enable,
				EPULSE 	=> epulse,
				MPULSE 	=> mpulse);
			
	counter1	: g31_time_counter
	PORT MAP(	reset	=> not reset,
				clock	=> clock,
				pulseIn	=> epulse,
				oneSeg	=> eOneSeg,
				tenSeg	=> eTenSeg);
				
	counter2	: g31_time_counter
	PORT MAP(	reset	=> not reset,
				clock	=> clock,
				pulseIn	=> mpulse,
				oneSeg	=> mOneSeg,
				tenSeg	=> mTenSeg);
end a;