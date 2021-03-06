library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_selector is
	PORT(	countOut	: in std_logic_vector(25 downto 0);
			orOut		: out std_logic);
end g31_selector;

architecture a of g31_selector is

begin
	with countOut select
		orOut <= 	'1' when "00000000000000000000000000",
					'0' when others;
end a;