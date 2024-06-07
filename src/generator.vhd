library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity generator is 
	port (
		clk  :  in std_logic;
		form :  in std_logic_vector(1 downto 0);
		step :  in std_logic_vector(7 downto 0);
		data : out std_logic_vector(7 downto 0);
		-- lcd output
		rw   	 : out std_logic;
		rs   	 : out std_logic;
		e    	 : out std_logic;
		lcd_on   : out std_logic;
		lcd_blon : out std_logic;
		lcd_data : out std_logic_vector(7 downto 0)
	);
end entity;

architecture arch of generator is 
	component rom is 
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
	end component;
	
	component step_counter is 
		generic (
			data_width : integer := 32
		);
		port (
			reset :  in std_logic;
			clk   :  in std_logic;
			step  :  in std_logic_vector(data_width-1 downto 0);
			count : out std_logic_vector(data_width-1 downto 0)
		);
	end component;
	
	component lcd_user_logic is
		port (
			signal_form : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			clk         : IN STD_LOGIC;
			lcd_data    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			rw, rs, e	: OUT STD_LOGIC;
			lcd_on 		: OUT STD_LOGIC;
			lcd_blon 	: OUT STD_LOGIC
		);
	end component;
	
	signal count : std_logic_vector(31 downto 0);
	signal step32 : std_logic_vector(31 downto 0);
	signal data2, data3, data4, data5 : std_logic_vector(7 downto 0);
begin
	step32 <= "0000" & step & "00000000000000000000";
	U1: step_counter 
		port map (reset => '0', clk => clk, step => step32, count => count);
	
	U2: rom -- sin
		generic map (init_file => "U2.mif") 
		port map (clk => clk, addr => count(31 downto 24), data => data2);
	U3: rom -- square
		generic map (init_file => "U3.mif") 
		port map (clk => clk, addr => count(31 downto 24), data => data3);
	U4: rom -- sawtooth
		generic map (init_file => "U4.mif") 
		port map (clk => clk, addr => count(31 downto 24), data => data4);
	U5: rom -- triangle
		generic map (init_file => "U5.mif") 
		port map (clk => clk, addr => count(31 downto 24), data => data5);
	with form select data <=
		data2 when "00",
		data3 when "01",
		data4 when "10",
		data5 when "11";
		
	U6: lcd_user_logic
		port map (
			signal_form => form,
			clk => clk,
			rw => rw, 
			rs => rs, 
			e => e, 
			lcd_on => lcd_on,
			lcd_blon => lcd_blon, 
			lcd_data => lcd_data
		);
end architecture;