library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library 1pm;
--use 1pm.1pm_components.all;

entity g31_dayseconds is
	port(	Hours			: in unsigned(4 downto 0);
			Minutes, Seconds: in unsigned(5 downto 0);
			DaySeconds		: out unsigned(16 downto 0));
end g31_dayseconds;

Architecture a of g31_dayseconds is
	signal adder1	: unsigned(8 downto 0);
	signal adder2	: unsigned(9 downto 0);
	signal adder3	: unsigned(10 downto 0);
	signal adder4	: unsigned(11 downto 0);
	signal adder5	: unsigned(15 downto 0);
	signal adder6	: unsigned(16 downto 0);
	signal adder7	: unsigned(16 downto 0);
	
begin
	DaySeconds 	<= Seconds 			+ adder7;
	
	adder7 		<= adder6 			+ (adder4 & "00000");
	adder6 		<= adder5 			+ ('0' & adder4 & "0000");
	adder5 		<= (adder4 & "00")	+ ('0' & adder4 & "000");
	
	adder4 		<= Minutes 			+ ('0' & adder3);
	
	adder3 		<= adder2			+ ('0' & Hours & "00000");
	adder2 		<= adder1			+ ('0' & Hours & "0000");
	adder1 		<= (Hours & "00")	+ ('0' & Hours & "000");
end a;
			