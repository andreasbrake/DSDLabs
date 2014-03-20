-- The test_bed is a simple circuit that uses the basic_time circuit along with two
-- instances of the time_counter to create timers for both martian and earth seconds
--
-- entity name: g31_test_bed
--
-- Copyright (C) 2014 Andreas Brake, Hadi Sayar
-- Vesion 1.0
-- Author: Andreas Brake, Hadi Sayar
-- Date: 2014-03-20

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_test_bed is
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			eOne	: out std_logic_vector(3 downto 0);
			eTen	: out std_logic_vector(3 downto 0);
			mOne	: out std_logic_vector(3 downto 0);
			mTen	: out std_logic_vector(3 downto 0);
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
			currSec : out std_logic_vector(3 downto 0);
			currTen : out std_logic_vector(3 downto 0);
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
				currSec	=> eOne,
				currTen	=> eTen,
				oneSeg	=> eOneSeg,
				tenSeg	=> eTenSeg);
				
	counter2	: g31_time_counter
	PORT MAP(	reset	=> not reset,
				clock	=> clock,
				pulseIn	=> mpulse,
				currSec	=> mOne,
				currTen	=> mTen,
				oneSeg	=> mOneSeg,
				tenSeg	=> mTenSeg);
end a;