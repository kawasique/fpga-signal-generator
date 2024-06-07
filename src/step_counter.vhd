library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity step_counter is 
	generic (
		data_width : integer := 32
	);
	port (
		reset :  in std_logic;
		clk   :  in std_logic;
		step  :  in std_logic_vector(data_width-1 downto 0);
		count : out std_logic_vector(data_width-1 downto 0)
	);
end entity;

architecture arch of step_counter is 
	signal cnt : std_logic_vector(data_width-1 downto 0) := (others => '0');
begin
	process (clk, reset)
	begin
		if reset = '1' then
			cnt <= (others => '0');
		elsif rising_edge(clk) then
			cnt <= cnt + step;
		end if;
	end process;
	count <= cnt;
end architecture;