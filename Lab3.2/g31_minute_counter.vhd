library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_minute_counter is
	PORT(	reset	: in std_logic;
			loadEn	: in std_logic;
			clock	: in std_logic;
			pulseIn	: in std_logic;
			minIn	: in std_logic_vector(5 downto 0);
			minPulse: out std_logic;
			minutes	: out std_logic_vector(5 downto 0));
			
end g31_minute_counter;

architecture a of g31_minute_counter is
	signal minOut	: std_logic_vector(5 downto 0);
	signal min_Pulse	: std_logic;
	signal dataIn	: std_logic_vector(5 downto 0);
	
begin			
	-- MINUTE COUNTER
	minCounter: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "UP",
		LPM_WIDTH => 6
	)
	PORT MAP (
		clock => clock,
		data => dataIn,
		cnt_en => pulseIn,
		sload => loadEn or reset or min_Pulse,
		q => minOut
	);
	with minOut select
		min_Pulse <= '1' when "111100",
					'0' when others;
	with loadEn select
		dataIn	<= 	minIn when '1',
					"000000" when '0';
	minPulse <= min_Pulse;
	minutes <= minOut;
	
end a;