LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY lcd_controller IS
	PORT(
		clk : IN STD_LOGIC;
		reset_n : IN STD_LOGIC;
		lcd_enable : IN STD_LOGIC;
		lcd_bus : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		busy : OUT STD_LOGIC := '1';
		rw, rs, e : OUT STD_LOGIC;
		lcd_data : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		lcd_on : OUT std_logic;
		lcd_blon : OUT std_logic
	);
END lcd_controller;

ARCHITECTURE controller OF lcd_controller IS
    TYPE CONTROL IS(power_up, initialize, ready, send);
    SIGNAL state : CONTROL;
    CONSTANT freq : INTEGER := 50; -- в МГц
BEGIN
    lcd_on <= '1';
    lcd_blon<='1';

    PROCESS(clk)
        VARIABLE clk_count : INTEGER := 0;
    BEGIN

    IF(clk'EVENT and clk = '1') THEN
    CASE state IS
        WHEN power_up =>
            busy <= '1';
            IF(clk_count < (50000 * freq)) THEN
                clk_count := clk_count + 1;
                state <= power_up;
            ELSE
                clk_count := 0;
                rs <= '0';
                rw <= '0';
                lcd_data <= "00110000";
                state <= initialize;
            END IF;

        WHEN initialize =>
            busy <= '1';
            clk_count := clk_count + 1;
            IF(clk_count < (10 * freq)) THEN
                -- lcd_data <= "00111100"; --2-line mode, display on
                lcd_data <= "00110100"; --1-line mode, display on
                --lcd_data <= "00110000"; --1-line mdoe, display off
                --lcd_data <= "00111000"; --2-line mode, display off
                e <= '1';
                state <= initialize;
            ELSIF(clk_count < (60 * freq)) THEN --wait 50 us
                lcd_data <= "00000000";
                e <= '0';
                state <= initialize;
            ELSIF(clk_count < (70 * freq)) THEN
                --lcd_data <= "00001100"; --display on, cursor off, blink off
                lcd_data <= "00001101"; --display on, cursor off, blink on
                --lcd_data <= "00001110"; --display on, cursor on, blink off
                --lcd_data <= "00001111"; --display on, cursor on, blink on
                --lcd_data <= "00001000"; --display off, cursor off, blink off
                --lcd_data <= "00001001"; --display off, cursor off, blink on
                --lcd_data <= "00001010"; --display off, cursor on, blink off
                --lcd_data <= "00001011"; --display off, cursor on, blink on
                e <= '1';
                state <= initialize;
            ELSIF(clk_count < (120 * freq)) THEN
                lcd_data <= "00000000";
                e <= '0';
                state <= initialize;
            ELSIF(clk_count < (130 * freq)) THEN
                lcd_data <= "00000001";
                e <= '1';
                state <= initialize;
            ELSIF(clk_count < (2130 * freq)) THEN
                lcd_data <= "00000000";
                e <= '0';
                state <= initialize;
            ELSIF(clk_count < (2140 * freq)) THEN
                lcd_data <= "00000110";
                e <= '1';
                state <= initialize;
            ELSIF(clk_count < (2200 * freq)) THEN
                lcd_data <= "00000000";
                e <= '0';
                state <= initialize;
            ELSE
                clk_count := 0;
                busy <= '0';
                state <= ready;
            END IF;

    WHEN ready =>
        IF(lcd_enable = '1') THEN
            busy <= '1';
            rs <= lcd_bus(9);
            --rs<= lcd_rs;
            rw <= lcd_bus(8);
            --rw <= lcd_rw;
            lcd_data <= lcd_bus(7 DOWNTO 0);
            --lcd_data <= lcd_bus;
            clk_count := 0;
            state <= send;
        ELSE
            busy <= '0';
            rs <= '0';
            rw <= '0';
            lcd_data <= "00000000";
            clk_count := 0;
            state <= ready;
        END IF;

        WHEN send =>
            busy <= '1';
            IF(clk_count < (50 * freq)) THEN 
                busy <= '1';
            IF(clk_count < freq) THEN
                e <= '0';
            ELSIF(clk_count < (14 * freq)) THEN
                e <= '1';
            ELSIF(clk_count < (27 * freq)) THEN
                e <= '0';
            END IF;
                clk_count := clk_count + 1;
                state <= send;
            ELSE
                clk_count := 0;
                state <= ready;
            END IF;
        END CASE;

        IF(reset_n = '0') THEN
            state <= power_up;
        END IF;
    END IF;
    END PROCESS;
END controller;