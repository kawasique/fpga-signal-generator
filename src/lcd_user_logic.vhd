LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY lcd_user_logic IS
    PORT(
        signal_form : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        clk         : IN STD_LOGIC;
		lcd_data    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		rw, rs, e	: OUT STD_LOGIC;
		lcd_on 		: OUT STD_LOGIC;
		lcd_blon 	: OUT STD_LOGIC
    );
END lcd_user_logic;

ARCHITECTURE behavior OF lcd_user_logic IS
	COMPONENT lcd_controller IS
		PORT(
			clk 		: IN STD_LOGIC;
			reset_n 	: IN STD_LOGIC;
			lcd_enable 	: IN STD_LOGIC;
			lcd_bus 	: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			busy 		: OUT STD_LOGIC := '1';
			rw, rs, e 	: OUT STD_LOGIC;
			lcd_data 	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			lcd_on 		: OUT STD_LOGIC;
			lcd_blon 	: OUT STD_LOGIC
		);
	END COMPONENT;
	
	SIGNAL lcd_bus    : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0');
	SIGNAL reset_n    : STD_LOGIC := '0';
	SIGNAL lcd_busy   : STD_LOGIC := '0';
	SIGNAL lcd_enable : STD_LOGIC; 
BEGIN
	U1: lcd_controller
		PORT MAP(
			clk => clk,
			reset_n => reset_n, 
			lcd_bus => lcd_bus, 
			lcd_enable => lcd_enable,
			busy => lcd_busy,
			rw => rw,
			rs => rs,
			e => e,
			lcd_data => lcd_data,
			lcd_on => lcd_on,
			lcd_blon => lcd_blon
		);

    PROCESS(clk)
    VARIABLE char : INTEGER RANGE 0 TO 15 := 0;
    BEGIN
        IF(clk'EVENT AND clk = '1') THEN
            IF(lcd_busy = '0' AND lcd_enable = '0') THEN
                lcd_enable <= '1';

                IF(char < 15) THEN
                    char := char + 1;
                END IF;

                CASE signal_form IS
                -- sine
                WHEN "00" =>
                    -- RS:RW:DATA8BIT
                    CASE char IS
                        WHEN  1 => lcd_bus <= "1001000110"; -- F
                        WHEN  2 => lcd_bus <= "1001001111"; -- O
                        WHEN  3 => lcd_bus <= "1001010010"; -- R
                        WHEN  4 => lcd_bus <= "1001001101"; -- M
                        WHEN  5 => lcd_bus <= "1000111010"; -- :
                        WHEN  6 => lcd_bus <= "1000100000"; -- [SPACE]
                        WHEN  7 => lcd_bus <= "1001010011"; -- S
                        WHEN  8 => lcd_bus <= "1001001001"; -- I
                        WHEN  9 => lcd_bus <= "1001001110"; -- N
                        WHEN 10 => lcd_bus <= "1001000101"; -- E
                        WHEN OTHERS => lcd_enable <= '0';
                    END CASE;
                -- square
                WHEN "01" =>
                    CASE char IS
                        WHEN  1 => lcd_bus <= "1001000110"; -- F
                        WHEN  2 => lcd_bus <= "1001001111"; -- O
                        WHEN  3 => lcd_bus <= "1001010010"; -- R
                        WHEN  4 => lcd_bus <= "1001001101"; -- M
                        WHEN  5 => lcd_bus <= "1000111010"; -- :
                        WHEN  6 => lcd_bus <= "1000100000"; -- [SPACE]
                        WHEN  7 => lcd_bus <= "1001010011"; -- S
                        WHEN  8 => lcd_bus <= "1001010001"; -- Q
                        WHEN  9 => lcd_bus <= "1001010101"; -- U
                        WHEN 10 => lcd_bus <= "1001000001"; -- A
                        WHEN 11 => lcd_bus <= "1001010010"; -- R
                        WHEN 12 => lcd_bus <= "1001000101"; -- E
                        WHEN OTHERS => lcd_enable <= '0';
                    END CASE;
                -- sawtooth
                WHEN "10" =>
                    CASE char IS
                        WHEN  1 => lcd_bus <= "1001000110"; -- F
                        WHEN  2 => lcd_bus <= "1001001111"; -- O
                        WHEN  3 => lcd_bus <= "1001010010"; -- R
                        WHEN  4 => lcd_bus <= "1001001101"; -- M
                        WHEN  5 => lcd_bus <= "1000111010"; -- :
                        WHEN  6 => lcd_bus <= "1000100000"; -- [SPACE]
                        WHEN  7 => lcd_bus <= "1001010011"; -- S
                        WHEN  8 => lcd_bus <= "1001000001"; -- A
                        WHEN  9 => lcd_bus <= "1001010111"; -- W
                        WHEN 10 => lcd_bus <= "1001010100"; -- T
                        WHEN 11 => lcd_bus <= "1001001111"; -- O
                        WHEN 12 => lcd_bus <= "1001001111"; -- O
                        WHEN 13 => lcd_bus <= "1001010100"; -- T
                        WHEN 14 => lcd_bus <= "1001001000"; -- H
                        WHEN OTHERS => lcd_enable <= '0';
                    END CASE;
                -- triangle
                WHEN "11" =>
                    CASE char IS
                        WHEN  1 => lcd_bus <= "1001000110"; -- F
                        WHEN  2 => lcd_bus <= "1001001111"; -- O
                        WHEN  3 => lcd_bus <= "1001010010"; -- R
                        WHEN  4 => lcd_bus <= "1001001101"; -- M
                        WHEN  5 => lcd_bus <= "1000111010"; -- :
                        WHEN  6 => lcd_bus <= "1000100000"; -- [SPACE]
                        WHEN  7 => lcd_bus <= "1001010100"; -- T
                        WHEN  8 => lcd_bus <= "1001010010"; -- R
                        WHEN  9 => lcd_bus <= "1001001001"; -- I
                        WHEN 10 => lcd_bus <= "1001000001"; -- A
                        WHEN 11 => lcd_bus <= "1001001110"; -- N
                        WHEN 12 => lcd_bus <= "1001000111"; -- G
                        WHEN 13 => lcd_bus <= "1001001100"; -- L
                        WHEN 14 => lcd_bus <= "1001000101"; -- E
                        WHEN OTHERS => lcd_enable <= '0';
                    END CASE;
                END CASE;
            ELSE
                lcd_enable <= '0';
            END IF;
        END IF;
    END PROCESS;

    reset_n <= '1';
END behavior;