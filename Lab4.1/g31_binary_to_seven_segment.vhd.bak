library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.lpm_components.all;

entity g31_binary_to_seven_segment is
	port(	clock		: in std_logic;
			bin			: in unsigned(11 downto 0);
			segments1	: out std_logic_vector(6 downto 0); -- lsb 7 seg
			segments2	: out std_logic_vector(6 downto 0);
			segments3	: out std_logic_vector(6 downto 0);
			segments4	: out std_logic_vector(6 downto 0)); -- msb 7 seg
end g31_binary_to_seven_segment;

Architecture a of g31_binary_to_seven_segment is
	signal BCD1: std_logic_vector(7 downto 0);
	signal BCD2: std_logic_vector(7 downto 0);
	
	signal LCD1: std_logic_vector(3 downto 0);
	signal LCD2: std_logic_vector(3 downto 0);
	signal LCD3: std_logic_vector(3 downto 0);
	signal LCD4: std_logic_vector(3 downto 0);
	
	signal rb1: std_logic;
	signal rb2: std_logic;
	signal rb3: std_logic;
	signal rb4: std_logic;
	
	component g31_binary_to_BCD
		port(
			clock	: in std_logic;
			bin		: in unsigned(5 downto 0);
			BCD		: out std_logic_vector(7 downto 0));
	end component;
	
	component g31_seven_segment_decoder
		port( 	
			code			: in std_logic_vector(3 downto 0);
			RippleBlank_In	: in std_logic;
			RippleBlank_Out	: out std_logic;
			segments		: out std_logic_vector(6 downto 0));
	end component;
	
begin
-- BINARY TO BCD 
	bin_BCD_1 : g31_binary_to_BCD
	PORT MAP(
		clock => clock,
		bin => bin(5 downto 0),
		BCD => BCD1
	);
	bin_BCD_2 : g31_binary_to_BCD
	PORT MAP(
		clock => clock,
		bin => bin(11 downto 6),
		BCD => BCD2
	);
	
	LCD1 <= BCD1(3 downto 0);
	LCD2 <= BCD1(7 downto 4);
	LCD3 <= BCD2(3 downto 0);
	LCD4 <= BCD2(7 downto 4);
	
-- BCD TO 7SEG
	sevenseg1 : g31_seven_segment_decoder
	PORT MAP(
		code => LCD1,
		RippleBlank_In => '0',
		RippleBlank_Out => rb1,
		segments => segments1
	);
	sevenseg2 : g31_seven_segment_decoder
	PORT MAP(
		code => LCD2,
		RippleBlank_In => rb3,
		RippleBlank_Out => rb2,
		segments => segments2
	);
	sevenseg3 : g31_seven_segment_decoder
	PORT MAP(
		code => LCD3,
		RippleBlank_In => rb4,
		RippleBlank_Out => rb3,
		segments => segments3
	);
	sevenseg4 : g31_seven_segment_decoder
	PORT MAP(
		code => LCD4,
		RippleBlank_In => '1',
		RippleBlank_Out => rb4,
		segments => segments4
	);
end a;