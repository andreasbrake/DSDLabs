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
		clock_enable_input_a => "BYPASS",
		clock_enable_output_a => "BYPASS",
		init_file => "crc_rom.mif",
		intended_device_family => "Cyclone II",
		lpm_hint => "ENABLE_RUNTIME_MOD=NO",
		lpm_type => "altsyncram",
		numwords_a => 64,
		operation_mode => "ROM",
		outdata_aclr_a => "NONE",
		outdata_reg_a => "CLOCK0",
		widthad_a => 6,
		width_a => 8,
		width_byteena_a => 1
	)
	PORT MAP (
		clock0 => clock,
		address_a => std_logic_vector(bin),
		q_a => BCD
	);
	
	
end a;