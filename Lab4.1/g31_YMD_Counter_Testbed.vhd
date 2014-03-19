library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity g31_YMD_Counter_Testbed is 
	PORT(	clock			: in std_logic; -- master clock
			reset			: in std_logic; -- master reset
			day_count_en	: in std_logic; -- pulse from HMS
			load_enable		: in std_logic; -- master load_enable
			show1			: in std_logic;
			show2			: in std_logic;
			load_y			: in std_logic;
			load_m			: in std_logic;
			load_d			: in std_logic;
			Initial_Set		: in std_logic_vector(4 downto 0);
			segments1	: out std_logic_vector(6 downto 0); -- lsb 7 seg
			segments2	: out std_logic_vector(6 downto 0);
			segments3	: out std_logic_vector(6 downto 0);
			segments4	: out std_logic_vector(6 downto 0)	-- msb 7 seg
		);

end g31_YMD_Counter_Testbed;

architecture behavior of g31_YMD_Counter_Testbed is
	component g31_basic_timer
	PORT(
			reset	: in std_logic;
			clock	: in std_logic;
			enable	: in std_logic;
			EPULSE	: out std_logic;
			MPULSE	: out std_logic
	);
	end component;
	component g31_YMD_Counter
	PORT(	clock			: in std_logic; -- master clock
			reset			: in std_logic; -- master reset
			day_count_en	: in std_logic; -- pulse from HMS
			load_enable		: in std_logic; -- master load_enable
			M_Set			: in std_logic_vector(3 downto 0);
			Y_Set			: in std_logic_vector(11 downto 0);
			D_Set			: in std_logic_vector(4 downto 0);
			Months			: out std_logic_vector(3 downto 0);
			Years			: out std_logic_vector(11 downto 0);
			Days			: out std_logic_vector(4 downto 0)
		);
	end component;
	component g31_binary_to_seven_segment
	PORT(	clock		: in std_logic;
			bin			: in unsigned(11 downto 0);
			segments1	: out std_logic_vector(6 downto 0); -- lsb 7 seg
			segments2	: out std_logic_vector(6 downto 0);
			segments3	: out std_logic_vector(6 downto 0);
			segments4	: out std_logic_vector(6 downto 0)	-- msb 7 seg
		); 
	end component;
	
	signal not_reset : 			std_logic;
	signal not_count_enable : 	std_logic;
	signal not_load_enable: 	std_logic;
	
	signal switch: 		std_logic_vector(1 downto 0);
	signal epulse: 		std_logic;
	signal display: 	std_logic_vector(11 downto 0);
	signal days: 		std_logic_vector(4 downto 0);
	signal months:		std_logic_vector(3 downto 0);
	signal years: 		std_logic_vector(11 downto 0);
	
	signal year_set: 	std_logic_vector(11 downto 0);
	signal month_set: 	std_logic_vector(3 downto 0);
	signal day_set: 	std_logic_vector(4 downto 0);
begin
	
	not_reset <= not reset;
	not_count_enable <= day_count_en;
	not_load_enable <= load_enable;
	
	process_input: process(load_d, load_m, load_y)
	begin
		if load_y = '0' then year_set <= "0000000" & Initial_Set;
		else year_set <= year_set;
		end if;
		
		if load_m = '0' then month_set <= Initial_Set(3 downto 0);
		else month_set <= month_set;
		end if;
		
		if load_d = '0' then day_set <= Initial_Set;
		else day_set <= day_set;
		end if;
	end process;
	
	
	timer : g31_basic_timer
	PORT MAP(
		reset => not_reset,
		clock => clock,
		enable => not_count_enable,
		EPULSE => epulse
	);
	
	counter : g31_YMD_Counter
	PORT MAP(
		clock => clock,
		reset => not_reset,
		day_count_en  => epulse,
		load_enable => not_load_enable,
		M_Set => month_set,
		Y_Set => year_set,
		D_Set => day_set,
		Months => months,
		Years => years,
		Days => days
	);
	
	--TODO: Load initial values.
	
	switch <= show2 & show1;
	with switch select
		display <= 	"0000000" & Days 	when "01",
					"00000000" & Months when "10",
					Years 				when "11",
					"000000000000" 		when others;
					
	displayer : g31_binary_to_seven_segment
	PORT MAP(
		clock => clock,
		bin => UNSIGNED(display),
		segments1 => segments1,
		segments2 => segments2,
		segments3 => segments3,
		segments4 => segments4
	);
	
end behavior;