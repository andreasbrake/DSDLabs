library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_dayseconds is
	port(	Hours			: in unsigned(4 downto 0);
			Minutes, Seconds: in unsigned(5 downto 0);
			DaySeconds		: out unsigned(16 downto 0));
end g31_dayseconds;

Architecture a of g31_dayseconds is
	signal minMult				: std_logic_vector(10 downto 0);
	signal hoursMinAdd			: std_logic_vector(10 downto 0);
	signal secondsMult			: std_logic_vector(16 downto 0);
	signal secondsHoursMinAdd	: std_logic_vector(16 downto 0);
	signal ROM					: std_logic_vector(5 downto 0) := "111100";
	
begin
	mult1 : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 5,
		lpm_widthb => 6,
		lpm_widthp => 11
	)
	PORT MAP (
		dataa => std_logic_vector(Hours),
		datab => ROM,
		result => minMult
	);
	
	add1 : lpm_add_sub
	GENERIC MAP(
		LPM_WIDTH => 11
		)
	PORT MAP(
		dataa => minMult,
		datab => ("00000" & std_logic_vector(Minutes)),
		result => hoursMinAdd
		);
	
	mult2 : lpm_mult
	GENERIC MAP (
		lpm_hint => "MAXIMIZE_SPEED=5",
		lpm_representation => "UNSIGNED",
		lpm_type => "LPM_MULT",
		lpm_widtha => 11,
		lpm_widthb => 6,
		lpm_widthp => 17
	)
	PORT MAP (
		dataa => hoursMinAdd,
		datab => ROM,
		result => secondsMult
	);
	
	add2 : lpm_add_sub
	GENERIC MAP(
		LPM_WIDTH => 17
		)
	PORT MAP(
		dataa => secondsMult,
		datab => ("00000000000" & std_logic_vector(Seconds)),
		result => secondsHoursMinAdd
		);
		
	DaySeconds <= unsigned(secondsHoursMinAdd);
end a;
			