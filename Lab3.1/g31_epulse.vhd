library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_epulse is
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic);
end g31_epulse;

architecture a of g31_epulse is
	signal constSig	: std_logic_vector(25 downto 0);
	signal countOut	: std_logic_vector(25 downto 0);
	signal orOut	: std_logic;

begin
	const: lpm_constant
	GENERIC MAP (
		LPM_WIDTH => 26,
		LPM_CVALUE => 49--999999
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

	EPULSE <= orOut;
end a;