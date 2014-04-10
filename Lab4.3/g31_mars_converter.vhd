library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.lpm_components.all;

entity g31_mars_converter is
 port(
	JDEarth: 		in std_logic_vector(29 downto 0);
	MHours:			out std_logic_vector(4 downto 0);
	MMinutes:		out std_logic_vector(5 downto 0);
	MSeconds:		out std_logic_vector(5 downto 0);
	days_out: 		out std_logic_vector(12 downto 0);
	MTC_out:		out std_logic_vector(26 downto 0);
	JDMars_out: 	out std_logic_vector(61 downto 0)
 );
end g31_mars_converter;

architecture a of g31_mars_converter is
	signal JDMars: 			std_logic_vector(61 downto 0);
	signal JDMars2: 		std_logic_vector(61 downto 0);
	signal days: 			std_logic_vector(12 downto 0);
	
	signal bin1:			std_logic_vector(27 downto 0);
	signal MTC:				std_logic_vector(26 downto 0);
	signal MTC2:			std_logic_vector(31 downto 0);
	signal MTC3:			std_logic_vector(32 downto 0);
	signal MTC4:			std_logic_vector(32 downto 0);
begin	
	days_out <= days;
	MTC_out <= MTC;
	jdmars_out <= jdmars;
	
	conversionMult: lpm_mult
	GENERIC MAP(
		LPM_WIDTHA => 30,
		LPM_WIDTHB => 32,
		LPM_WIDTHP => 62
	)
	PORT MAP(
		dataa => JDEarth,
		datab => "11111001001001101000100111001010",
		result => JDMars2
	);
	
	JDMars <= JDMars2 - 3092376; -- value * 2^32
	days <= JDMars(61 downto 49);
	MTC <= JDMars(48 downto 22);
	
	-- Getting HMS --

	-- GETTING HOURS --
	hourMult: lpm_mult
	GENERIC MAP(
		LPM_WIDTHA => 27,
		LPM_WIDTHB => 5,
		LPM_WIDTHP => 32
	)
	PORT MAP(
		dataa => MTC,
		datab => "11000",
		result => MTC2
	);
	MHours <= MTC2(31 downto 27);
	
	-- GETTING MINUTES --
	minuteMult: lpm_mult
	GENERIC MAP(
		LPM_WIDTHA => 27,
		LPM_WIDTHB => 6,
		LPM_WIDTHP => 33
	)
	PORT MAP(
		dataa => MTC2(26 downto 0),
		datab => "111100",
		result => MTC3
	);
	MMinutes <= MTC3(32 downto 27);
	
	-- GETTING SECONDS --
	secondMult: lpm_mult
	GENERIC MAP(
		LPM_WIDTHA => 27,
		LPM_WIDTHB => 6,
		LPM_WIDTHP => 33
	)
	PORT MAP(
		dataa => MTC3(26 downto 0),
		datab => "111100",
		result => MTC4
	);
	MSeconds <= MTC4(32 downto 27);	
end a;