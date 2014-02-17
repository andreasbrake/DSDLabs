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
	--type array_type_2 is array (0 to 25) of std_logic_vector(0 downto 0);
	signal constSig	: std_logic_vector(26 downto 0);
	signal countOut	: std_logic_vector(26 downto 0);
	signal orIn		: std_logic_2d(26 downto 0, 0 downto 0);
	signal orOut	: std_logic_vector(0 downto 0);

begin
	const: lpm_constant
	GENERIC MAP (
		LPM_WIDTH => 27,
		LPM_CVALUE => 49999999
	)
	PORT MAP (
		result => constSig
	);
	
	counter: lpm_counter
	GENERIC MAP	(
		LPM_WIDTH => 27
	)
	PORT MAP (
		clock => clock,
		data => constSig,
		cnt_en => enable,
		sload => (not orOut(0)) or reset,
		q => countOut
	);
	
	orGate: lpm_or
	GENERIC MAP (
		LPM_WIDTH => 1,
		LPM_SIZE => 27
	)
	PORT MAP (
		data => orIn,
		result => orOut
	);
	
	PROCESS(countOut)
    BEGIN
        FOR i IN 0 TO 26 LOOP
            orIn(i,0) <= countOut(i);
        END LOOP;
    END PROCESS;
    
	EPULSE <= not orOut(0);
end a;