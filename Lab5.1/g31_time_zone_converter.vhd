library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity g31_time_zone_converter is
	port (
		clock				: in std_logic;
		dst					: in std_logic;
		
		earth_time_zone		: in std_logic_vector(4 downto 0);
		mars_time_zone		: in std_logic_vector(4 downto 0);
		
		earth_local_days	: in std_logic_vector(4 downto 0);
		earth_local_hours	: in std_logic_vector(4 downto 0);
		
		earth_utc_days		: in std_logic_vector(4 downto 0);
		earth_utc_hours		: in std_logic_vector(4 downto 0);
		
		mars_MTC_hours  	: in std_logic_vector(4 downto 0);
		
		earth_utc_days_out	: out std_logic_vector(4 downto 0);
		earth_utc_hours_out	: out std_logic_vector(4 downto 0);

		earth_tz_days_out	: out std_logic_vector(4 downto 0);
		earth_tz_hours_out	: out std_logic_vector(4 downto 0);
		
		mars_tz_hours_out	: out std_logic_vector(4 downto 0)
	);
end g31_time_zone_converter;

architecture behaviour of g31_time_zone_converter is
	signal dst_vector: std_logic_vector(0 downto 0);
	
	signal earth_utc_hours_out_internal:	std_logic_vector(5 downto 0);
	signal earth_utc_days_out_internal:		std_logic_vector(5 downto 0);
	
	signal earth_tz_hours_out_internal:		std_logic_vector(5 downto 0);
	signal earth_tz_days_out_internal:		std_logic_vector(5 downto 0);

	signal mars_tz_hours_out_internal:		std_logic_vector(5 downto 0);
	signal mars_tz_days_out_internal:		std_logic_vector(5 downto 0);
		
	begin
		dst_vector <= "0" + dst;
		
		earth_utc_hours_out <= earth_utc_hours_out_internal(4 downto 0);
		earth_utc_days_out 	<= earth_utc_days_out_internal(4 downto 0);
		
		earth_tz_hours_out 	<= earth_tz_hours_out_internal(4 downto 0);
		earth_tz_days_out 	<= earth_tz_days_out_internal(4 downto 0);
		
		mars_tz_hours_out 	<= mars_tz_hours_out_internal(4 downto 0);
		
		earth_local_to_utc: process(earth_local_hours, earth_time_zone, earth_local_days)
		begin
			if earth_time_zone > 11 then
				if earth_local_hours < (earth_time_zone - 12) then
					earth_utc_hours_out_internal	<= ('0' & earth_local_hours) - (earth_time_zone - 12) + 24; -- Roll over the hours to the previous day
					earth_utc_days_out_internal		<= ('0' & earth_local_days) - 1; -- plus a day
				else
					earth_utc_hours_out_internal 	<= ('0' & earth_local_hours) - (earth_time_zone - 12); -- Less the time shift amount
					earth_utc_days_out_internal 	<= ('0' & earth_local_days); -- same day
				end if;
			else
				if (('0' & earth_local_hours) + (12 - earth_time_zone) - dst_vector) > 23 then
					earth_utc_hours_out_internal 	<= ('0' & earth_local_hours) + (12 - earth_time_zone) - 24; -- Roll over the hours to the previous day
					earth_utc_days_out_internal 	<= ('0' & earth_local_days) + 1; -- plus a day
				else
					earth_utc_hours_out_internal 	<= ('0' & earth_local_hours) + (12 - earth_time_zone); -- Less the time shift amount
					earth_utc_days_out_internal 	<= ('0' & earth_local_days); -- same day
				end if;						
			end if;
		end process;
		
		earth_utc_to_tz: process(earth_utc_hours, dst_vector, earth_time_zone, earth_utc_days)
		begin 
			if earth_time_zone > 11 then
				if (('0' & earth_utc_hours) + (earth_time_zone - 12) + dst_vector) > 23 then
					earth_tz_hours_out_internal <= ('0' & earth_utc_hours) + (earth_time_zone - 12) + dst_vector - 24; -- Roll over upwards
					earth_tz_days_out_internal 	<= ('0' & earth_utc_days) + 1; -- plus a day
				else
					earth_tz_hours_out_internal	<= ('0' & earth_utc_hours) + (earth_time_zone - 12) + dst_vector; -- Add time shift
					earth_tz_days_out_internal	<= ('0' & earth_utc_days); -- same day
				end if;
			else
				if earth_utc_hours < ((12 - earth_time_zone) + dst_vector) then
					earth_tz_hours_out_internal <= ('0' & earth_utc_hours) - (12 - earth_time_zone) + dst_vector + 24; -- Roll over downwards
					earth_tz_days_out_internal 	<= ('0' & earth_utc_days) - 1; -- less a day
				else
					earth_tz_hours_out_internal <= ('0' & earth_utc_hours) - (12 - earth_time_zone) + dst_vector; -- less the time shift
					earth_tz_days_out_internal 	<= ('0' & earth_utc_days); -- same day
				end if;
			end if;
		end process;
		
		mars_mtc_to_tz: process(mars_mtc_hours, mars_time_zone)
		begin
			if mars_time_zone > 11 then
				if (('0' & mars_mtc_hours) + mars_time_zone - 12) > 23 then
					mars_tz_hours_out_internal 	<= ('0' & mars_mtc_hours) + (mars_time_zone - 12) - 24; -- Roll over upwards
				else
					mars_tz_hours_out_internal 	<= ('0' & mars_mtc_hours) + (mars_time_zone - 12); -- Add time shift
				end if;
			else
				if mars_mtc_hours < (12 - mars_time_zone) then
					mars_tz_hours_out_internal 	<= ('0' & mars_mtc_hours) - (12 - mars_time_zone) + 24; -- Roll over downwards
				else
					mars_tz_hours_out_internal 	<= ('0' & mars_mtc_hours) - (12 - mars_time_zone); -- less the time shif
				end if;
			end if;	
		end process;
		
end behaviour;