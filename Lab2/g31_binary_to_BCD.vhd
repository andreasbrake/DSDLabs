library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_binary_to_BCD is
	port(	clock	: in std_logic;
			bin		: in unsigned(5 downto 0);
			BCD		: out std_logic_vector(7 downto 0));
end g31_binary_to_BCD;

Architecture a of g31_binary_to_BCD is

begin
	
	crc_rom: lpm_rom
	GENERIC MAP (
		lpm_address_control => "REGISTERED",
		lpm_file => "crc_rom.mif",
		lpm_numwords => 64,
		lpm_outdata => "UNREGISTERED",
		lpm_widthad => 6,
		lpm_width => 8
	)
	PORT MAP (
		address => std_logic_vector(bin),
		inclock => clock,
		q => BCD
	);
	
	
end a;