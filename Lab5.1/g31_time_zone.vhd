library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity g31_time_zone is
	port (
		clock		: in std_logic;
		--load_enable : in std_logic;
--		reset		: in std_logic;
		dst			: in std_logic;
		earth_mars	: in std_logic;
		
		earth_time_zone	: in std_logic_vector(4 downto 0);
		earth_hours	: in std_logic_vector(4 downto 0);
		mars_time_zone: in std_logic_vector(4 downto 0);
		mars_hours  : in std_logic_vector(4 downto 0);
		earth_days	: in std_logic_vector(4 downto 0);
		
		earth_time_zone_out: out integer range -12 to 11;
		mars_time_zone_out: out integer range -12 to 11;
		earth_hours_out : out integer range 0 to 23;
		mars_hours_out : out integer range 0 to 23;
		earth_days_out	: out std_logic_vector(4 downto 0)
	);
end g31_time_zone;

architecture behaviour of g31_time_zone is

	signal inner_earth_time_zone	: integer range -12 to 11;
	signal integer_dst : integer range 0 to 1;
	signal inner_mars_time_zone	: integer range -12 to 11;
	signal integer_earth_hours: integer range 0 to 23;
	signal integer_mars_hours: integer range 0 to 23;
	signal inner_earth_hours_out: integer range 0 to 23;
	signal inner_mars_hours_out: integer range 0 to 23;
	signal inner_earth_day	: std_logic_vector(4 downto 0);
	
	begin
		integer_earth_hours <= to_integer(unsigned(earth_hours));
		integer_mars_hours <= to_integer(unsigned(mars_hours));
		earth_time_zone_out <= inner_earth_time_zone;
		mars_time_zone_out <= inner_mars_time_zone;
		
		init_process: process(earth_time_zone, mars_time_zone)
		begin
			--if (clock = '1' and clock'event) then 
				inner_earth_time_zone <= to_integer(unsigned(earth_time_zone));
				inner_mars_time_zone <= to_integer(unsigned(mars_time_zone));
				if earth_time_zone > 11 then
					inner_earth_time_zone <= to_integer(unsigned(earth_time_zone)) - 24;
				end if;
				if mars_time_zone > 11 then
					inner_mars_time_zone <= to_integer(unsigned(mars_time_zone)) - 24;
				end if; 
			--end if;
		end process;
		
		dst_process: process(clock, dst, earth_mars)
		begin
			if dst = '1' and earth_mars = '1' then
				integer_dst <= 1;
			else 
				integer_dst <= 0;
			end if;
		end process;
		
		time_zone_process: process (clock, earth_mars, integer_dst, inner_earth_time_zone, mars_time_zone, integer_mars_hours, inner_mars_time_zone, integer_earth_hours)
		begin
--			if (clock = '1' and clock'event) then
				inner_earth_hours_out <= integer_earth_hours;
				inner_mars_hours_out <= integer_mars_hours;
				if earth_mars = '1' then
					inner_earth_hours_out <= integer_earth_hours + inner_earth_time_zone + integer_dst;
				elsif earth_mars = '0' then
					inner_mars_hours_out <= integer_mars_hours + inner_mars_time_zone;
				end if;
--			end if;
		end process;
		
		day_process: process(clock, inner_earth_hours_out, earth_hours, earth_days, inner_earth_time_zone, inner_mars_time_zone, inner_mars_hours_out, mars_hours)
		begin
			if (clock = '1' and clock'event) then
				earth_hours_out <= inner_earth_hours_out;
				mars_hours_out <= inner_mars_hours_out;
				earth_days_out <= earth_days;
				if inner_earth_hours_out > 23 then
					if earth_hours < 12 and inner_earth_time_zone < 0 then
						earth_hours_out <= inner_earth_hours_out - 8;
						earth_days_out <= earth_days - 1;
					elsif earth_hours >= 12 and inner_earth_time_zone > 0 then
						earth_hours_out <= inner_earth_hours_out + 8;
						earth_days_out <= earth_days + 1;
					else
						earth_hours_out <= inner_earth_hours_out;
						earth_days_out <= earth_days;
					end if;
				end if;
				if inner_mars_hours_out > 23 then
					if mars_hours < 12 and inner_mars_time_zone < 0 then
						mars_hours_out <= inner_mars_hours_out - 8;
					elsif mars_hours >= 12 and inner_mars_time_zone > 0 then
						mars_hours_out <= inner_mars_hours_out + 8;
					else
						mars_hours_out <= inner_mars_hours_out;
					end if;
				end if;
			end if;
		end process;	
end behaviour;