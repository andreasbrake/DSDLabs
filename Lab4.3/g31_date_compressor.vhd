library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library lpm;
use lpm.lpm_components.all;

entity g31_date_compressor is
 port(
	NDays: 	in std_logic_vector(12 downto 0);
	NSecs:	in std_logic_vector(16 downto 0);
	NDate:	out std_logic_vector(29 downto 0)
 );
end g31_date_compressor;

architecture a of g31_date_compressor is
	component g31_Seconds_to_Days
		port( 	seconds			: in unsigned(16 downto 0);
				day_fractions	: out unsigned(39 downto 0) );
	end component;

	signal frac: unsigned(39 downto 0);
begin	
	NDate <= (NDays & "00000000000000000") + std_logic_vector(frac(39 downto 23));
	
	fracMaker: g31_Seconds_to_Days
	PORT MAP(
		seconds => unsigned(NSecs),
		day_fractions => frac
	);
end a;