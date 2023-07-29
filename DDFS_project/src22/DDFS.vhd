
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DDFS is
	generic (
		N : positive := 8;
		M : positive := 8
	);
	port(
		clk   : in  std_logic;                      -- clk @ 125 MHz
		reset : in  std_logic;                      -- async reset
		wave  : in  std_logic_vector(1 downto 0);   -- Generated waveform.
		fw    : in  std_logic_vector(N-1 downto 0); -- frequency word
		yq    : out std_logic_vector(M-1 downto 0)  -- sin quantized. M is the size
	);
end entity DDFS;

architecture struct of DDFS is

	component PhaseAccumulator is
		generic (
			N : positive --:= 12
		);	
		port(
			clk    : in  std_logic;
			rst    : in  std_logic;
			pa_in  : in  std_logic_vector(N-1 downto 0);
			pa_out : out std_logic_vector(N-1 downto 0)
		);
	end component;
		

	component LUT_DDFS is
		port (
			LUT_line : in  std_logic_vector(7 downto 0);
			LUT_data : out std_logic_vector(7 downto 0) 
		);
	end component;

	signal pa_to_LUT  : std_logic_vector(N-1 downto 0); -- intermediate wire between PA and LUT
    signal lut_output : std_logic_vector(N-1 downto 0);

	begin

		i_PA: PhaseAccumulator generic map (N=>N) port map(clk, reset, fw, pa_to_LUT);
		i_LUT: LUT_DDFS port map(pa_to_LUT, lut_output);

		with wave select
			yq <= pa_to_LUT and std_logic_vector(to_unsigned(192, pa_to_LUT'length)) when "00", --stair wave
		
			      lut_output                                                           when "01", -- Sine wave.
				  pa_to_LUT and std_logic_vector(to_unsigned(64, pa_to_LUT'length)+to_unsigned(187, pa_to_LUT'length)) when "10",-- saw tooth
				  -- -- "11" stair
				  pa_to_LUT and std_logic_vector(to_unsigned(64, pa_to_LUT'length)) when "11", --triangle and square waves 
				  std_logic_vector(to_unsigned(0, yq'length))                          when others;
				  
				  

end struct;

