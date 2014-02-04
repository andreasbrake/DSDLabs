library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g31_binary_to_seven_segment is
	port(	BCD		: in std_logic_vector(7 downto 0);
			code1	: out std_logic_vector(3 downto 0);
			code2	: out std_logic_vector(3 downto 0));
end g31_binary_to_seven_segment;

Architecture a of g31_binary_to_seven_segment is

begin
	code1 <= BCD(7 downto 4);
	code2 <= BCD(3 downto 0);	
end a;