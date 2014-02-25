library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_second_counter is
	PORT(	reset	: in std_logic;
			loadEn	: in std_logic;
			clock	: in std_logic;
			pulseIn	: in std_logic;
			secIn	: in std_logic_vector(5 downto 0);
			secPulse: out std_logic; -- also reset
			seconds	: out std_logic_vector(5 downto 0));
			
end g31_second_counter;

architecture a of g31_second_counter is
	signal secOut	: std_logic_vector(5 downto 0);
	signal sec_Pulse: std_logic;
	signal dataIn: std_logic_vector(5 downto 0);
begin			
	-- SECOND COUNTER
	secCounter: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "UP",
		LPM_WIDTH => 6
	)
	PORT MAP (
		clock => clock,
		data => dataIn,
		cnt_en => pulseIn,
		sload => loadEn or reset or sec_Pulse,
		q => secOut
	);
	with secOut select
		sec_Pulse <= '1' when "111100",
					'0' when others;
	
	with loadEn select
		dataIn <= secIn when '1',
				"000000" when others;

	secPulse <= sec_Pulse;
	seconds <= 	secOut;
	
end a;