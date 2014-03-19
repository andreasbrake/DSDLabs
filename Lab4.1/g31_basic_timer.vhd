library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_basic_timer is
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic;
			MPULSE	: out std_logic);
end g31_basic_timer;

architecture a of g31_basic_timer is
	signal constSig1: std_logic_vector(25 downto 0);
	signal countOut1: std_logic_vector(25 downto 0);
	signal orOut1	: std_logic;
	
	signal constSig2: std_logic_vector(25 downto 0);
	signal countOut2: std_logic_vector(25 downto 0);
	signal orOut2	: std_logic;

begin
	-- EARTH TIME
	const: lpm_constant
	GENERIC MAP (
		LPM_WIDTH => 26,
		LPM_CVALUE => 499999--99
	)
	PORT MAP (
		result => constSig1
	);
	
	counter: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "DOWN",
		LPM_WIDTH => 26
	)
	PORT MAP (
		clock => clock,
		data => constSig1,
		cnt_en => enable,
		sload => orOut1 or reset,
		q => countOut1
	);
	with countOut1 select
		orOut1 <= 	'1' when "00000000000000000000000000",
					'0' when others;

	EPULSE <= orOut1;
	
	-- MARTIAN TIME
	
	const2: lpm_constant
	GENERIC MAP (
		LPM_WIDTH => 26,
		LPM_CVALUE => 51374562
	)
	PORT MAP (
		result => constSig2
	);
	
	counter2: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "DOWN",
		LPM_WIDTH => 26
	)
	PORT MAP (
		clock => clock,
		data => constSig2,
		cnt_en => enable,
		sload => orOut2 or reset,
		q => countOut2
	);
	
	with countOut2 select
		orOut2 <= 	'1' when "00000000000000000000000000",
					'0' when others;

	MPULSE <= orOut2;
end a;