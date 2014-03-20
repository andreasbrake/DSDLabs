-- This deconder takes in a BCD value and converts it into an
-- input for a seven-segment display.
--
-- entity name: g31_seven_segment_decoder
--
-- Copyright (C) 2014 Andreas Brake, Hadi Sayar
-- Vesion 1.0
-- Author: Andreas Brake, Hadi Sayar
-- Date: 2014-03-20

library ieee;
use ieee.std_logic_1164.all;

entity g31_seven_segment_decoder is
	port( 	code			: in std_logic_vector(3 downto 0);
			RippleBlank_In	: in std_logic;
			RippleBlank_Out	: out std_logic;
			segments		: out std_logic_vector(6 downto 0));
end g31_seven_segment_decoder;

architecture a of g31_seven_segment_decoder is
	signal intermediate : std_logic_vector (7 downto 0);
begin
	
	with (RippleBlank_In & code) select intermediate <=
		"01000000" when "00000", -- 0
		"01111001" when "00001", -- 1
		"00100100" when "00010", -- 2
		"00110000" when "00011", -- 3
		"00011001" when "00100", -- 4
		"00010010" when "00101", -- 5
		"00000010" when "00110", -- 6
		"01111000" when "00111", -- 7
		"00000000" when "01000", -- 8
		"00010000" when "01001", -- 9
		"00001000" when "01010", -- A
		"00000011" when "01011", -- B
		"01000110" when "01100", -- C
		"00100001" when "01101", -- D
		"00000110" when "01110", -- E
		"00001110" when "01111", -- F
		
		"11111111" when "10000", -- 0
		"01111001" when "10001", -- 1
		"00100100" when "10010", -- 2
		"00110000" when "10011", -- 3
		"00011001" when "10100", -- 4
		"00010010" when "10101", -- 5
		"00000010" when "10110", -- 6
		"01111000" when "10111", -- 7
		"00000000" when "11000", -- 8
		"00010000" when "11001", -- 9
		"00001000" when "11010", -- A
		"00000011" when "11011", -- B
		"01000110" when "11100", -- C
		"00100001" when "11101", -- D
		"00000110" when "11110", -- E
		"00001110" when "11111"; -- F
	
	RippleBlank_Out <= intermediate(7);
	segments <= intermediate(6 downto 0);
	
end a;
