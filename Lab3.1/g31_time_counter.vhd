library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_time_counter is
	PORT(	reset	: in std_logic;
			clock	: in std_logic;
			pulseIn	: in std_logic;
			oneSeg	: out std_logic_vector(6 downto 0);
			tenSeg	: out std_logic_vector(6 downto 0));
end g31_time_counter;

architecture a of g31_time_counter is	
	component g31_seven_segment_decoder
	port( 	code			: in std_logic_vector(3 downto 0);
			RippleBlank_In	: in std_logic;
			RippleBlank_Out	: out std_logic;
			segments		: out std_logic_vector(6 downto 0));
	end component;

	signal secOut	: std_logic_vector(3 downto 0);
	signal secReset	: std_logic;
	
	signal tenOut	: std_logic_vector(3 downto 0);
	signal tenReset	: std_logic;

	signal ripOut1	: std_logic;
	signal ripOut2 	: std_logic;
	
begin			
	-- SECOND COUNTER
	seecCounter: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "UP",
		LPM_WIDTH => 4
	)
	PORT MAP (
		clock => clock,
		cnt_en => pulseIn,
		sload => reset or secReset,
		q => secOut
	);
	-- SECOND OUTPUTS
	with secOut select
		secReset <= '1' when "1010",
					'0' when others;
	
	sevenSeg1	: g31_seven_segment_decoder
	PORT MAP(	code 			=> secOut,
				RippleBlank_In 	=> ripOut1,
				RippleBlank_Out => ripOut2,
				segments		=> oneSeg);
				
	-- TENs COUNTER
	tenCounter: lpm_counter
	GENERIC MAP	(
		LPM_DIRECTION => "UP",
		LPM_WIDTH => 4
	)
	PORT MAP (
		clock => clock,
		cnt_en => secReset,
		sload => reset or tenReset,
		q => tenOut
	);
	-- TENs OUTPUTS
	with tenOut select
		tenReset <= '1' when "0110",
					'0' when others;
	
	sevenSeg2	: g31_seven_segment_decoder
	PORT MAP(	code 			=> tenOut,
				RippleBlank_In 	=> '1',
				RippleBlank_Out	=> ripOut1,
				segments		=> tenSeg);
end a;