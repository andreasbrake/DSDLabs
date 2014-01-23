-- does stuff
--
-- entity name: g31_Seconds_to_Days
--
-- Copyright (C) 2014 Andreas Brake, Hadi Sayar
-- Vesion 1.0
-- Author: Andreas Brake, Hadi Sayar
-- Date: 2014-01-20

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g31_Seconds_to_Days is
	port( 	seconds			: in unsigned(16 downto 0);
			day_fractions	: out unsigned(39 downto 0) );
end g31_Seconds_to_Days;

architecture lab1 of g31_Seconds_to_Days is
	signal adder1	: unsigned(19 downto 0);
	signal adder2	: unsigned(23 downto 0);
	signal adder3	: unsigned(26 downto 0);
	signal adder4	: unsigned(27 downto 0);
	signal adder5	: unsigned(28 downto 0);
	signal adder6	: unsigned(30 downto 0);
	signal adder7	: unsigned(34 downto 0);
	signal adder8	: unsigned(39 downto 0);
	
begin
	adder1 <= ('0' & seconds) + ('0' & seconds & "00");
	adder2 <= ('0' & adder1) + ('0' & seconds & "000000");
	adder3 <= ('0' & adder2) + ('0' & seconds & "000000000");
	adder4 <= ('0' & adder3) + ('0' & seconds & "0000000000");
	adder5 <= ('0' & adder4) + ('0' & seconds & "00000000000");
	adder6 <= ('0' & adder5) + ('0' & seconds & "0000000000000");
	adder7 <= ('0' & adder6) + ('0' & seconds & "00000000000000000");
	adder8 <= ('0' & adder7) + ('0' & seconds & "0000000000000000000000");
	day_fractions <= adder8 + (seconds & "00000000000000000000000");
	
end lab1;