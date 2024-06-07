library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is
	generic (
		init_file  : string  := "rom.mif";
		addr_width : integer := 8;
		data_width : integer := 8
	);
	port (
		clk  :  in std_logic;
		addr :  in std_logic_vector(addr_width-1 downto 0);
		data : out std_logic_vector(data_width-1 downto 0)
	);
end entity;

architecture arch of rom is 
	subtype word_t is std_logic_vector(data_width-1 downto 0);
	type rom_t is array (0 to 2**ADDR_WIDTH-1) of word_t;

	signal rom_s : rom_t; 
	attribute ram_init_file : string;
	attribute ram_init_file of rom_s : signal is init_file;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			data <= rom_s(to_integer(unsigned(addr)));
		end if;
	end process;
end architecture;