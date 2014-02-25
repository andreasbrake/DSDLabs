library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_mpulse is
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			MPULSE	: out std_logic);
end g31_mpulse;

architecture a of g31_mpulse is
	signal constSig	: std_logic_vector(25 downto 0);
	signal countOut	: std_logic_vector(25 downto 0);
	signal orOut	: std_logic;

begin
	const: lpm_constant
	GENERIC MAP (
		LPM_WIDTH => 26,
		LPM_CVALUE => 5137--4562
	)
	PORT MAP (
		result => constSig
	);
	
	counter: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "DOWN",
		LPM_WIDTH => 26
	)
	PORT MAP (
		clock => clock,
		data => constSig,
		cnt_en => enable,
		sload => orOut or reset,
		q => countOut
	);
	
	
	with countOut select
		orOut <= 	'1' when "00000000000000000000000000",
					'0' when others;

	MPULSE <= orOut;
end a;