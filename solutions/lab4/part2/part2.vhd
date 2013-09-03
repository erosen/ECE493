-- User-Encoded State Machine
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity part2 is
	port(SW : in std_logic_vector(17 downto 0);
		KEY  : in std_logic_vector(3 downto 0);
		LEDR	  : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(8 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out std_logic_vector(0 to 6));
end part2;

architecture Structure of part2 is
	COMPONENT hexdisplay
		PORT (C	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
			  H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	-- Build an enumerated type for the state machine
	type count_state is (IDLE, PRODUCT_SELECT, DISPENSE);
	
	-- Registers to hold the current state and the next state
	signal present_state, next_state	   : count_state;
	-- Attribute to declare a specific encoding for the states
	attribute syn_encoding				  : string;
	attribute syn_encoding of count_state : type is "00 01 10";
	
	SIGNAL Clock : STD_LOGIC;
	SIGNAL COIN_RETURN, DISPENSE_READY : STD_LOGIC;
	SIGNAL SODA_CAN, CHIPS, CHOCOLATE, BUBBLE_GUM : STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL QUARTERS: INTEGER range 0 to 40;
	SIGNAL COST : INTEGER range 0 to 40;
	SIGNAL COSTvect, QUARTERvect : STD_LOGIC_VECTOR (5 downto 0);
	SIGNAL displayb0, displayb1, displayb2, displayb3, displayb4,
		displayb5, displayb6, displayb7 : STD_LOGIC_VECTOR(4 downto 0);
	
begin
	
	Clock <= KEY(0);
	COIN_RETURN <= KEY(1);
	
	SODA_CAN(3 downto 0) <= SW(15 downto 12);
	CHIPS(3 downto 0) <= SW(11 downto 8);
	CHOCOLATE(3 downto 0) <= SW(7 downto 4);
	BUBBLE_GUM(3 downto 0) <= SW(3 downto 0);
	
	-- Move to the next state
	process(Clock, COIN_RETURN)
	begin
	
		if (COIN_RETURN='1') then
			present_state <= IDLE;
		elsif (Clock='0' and Clock'event) then
			present_state <= next_state;
		end if;
	end process;

	-- Determine what the next state will be, and set the output bits
	process (present_state, KEY(3 downto 2))
	begin
		case present_state is
			when IDLE =>
			
				QUARTERS <= 0;
				COST <= 0;
				DISPENSE_READY <= '0';
				LEDR(17 downto 0) <= "000000000000000000";
				LEDG(8 downto 1) <= "00000000";
				LEDG(0) <= '1';
				
				displayb0 <= "10000";
				displayb1 <= "10000";
				displayb2 <= "10000";
				displayb3 <= "10000";
				displayb4 <= "10000";
				displayb5 <= "10000";
				displayb6 <= "10000";
				displayb7 <= "10000";
				
				if (SW(15 downto 0) = "0000000000000000") then
					next_state <= IDLE;
				else
					next_state <= PRODUCT_SELECT;
				end if;
				
			when PRODUCT_SELECT =>
				
				if (SODA_CAN(0) = '1') then
					COST <= COST + 4;
				elsif(SODA_CAN(1) = '1') then
					COST <= COST + 4;
				elsif(SODA_CAN(2) = '1') then
					COST <= COST + 4;
				elsif(SODA_CAN(3) = '1') then
					COST <= COST + 4;
				elsif(CHIPS(0) = '1') then
					COST <= COST + 3;
				elsif(CHIPS(1) = '1') then
					COST <= COST + 3;
				elsif(CHIPS(2) = '1') then
					COST <= COST + 3;
				elsif(CHIPS(3) = '1') then
					COST <= COST + 3;
				elsif(CHOCOLATE(0) = '1') then
					COST <= COST + 2;
				elsif(CHOCOLATE(1) = '1') then
					COST <= COST + 2;
				elsif(CHOCOLATE(2) = '1') then
					COST <= COST + 2;
				elsif(CHOCOLATE(3) = '1') then
					COST <= COST + 2;
				elsif(BUBBLE_GUM(0) = '1') then
					COST <= COST + 1;
				elsif(BUBBLE_GUM(1) = '1') then
					COST <= COST + 1;
				elsif(BUBBLE_GUM(2) = '1') then
					COST <= COST + 1;
				elsif(BUBBLE_GUM(3) = '1') then
					COST <= COST + 1;
				end if;
				
				COSTvect <= std_logic_vector(to_unsigned(COST, COSTvect'length));
				
				displayb5 <= "000"&COSTvect(5 downto 4);
				displayb4 <= '0'&COSTvect(3 downto 0);
				
				if(KEY(3)='1') then
					QUARTERS <= QUARTERS + 4;
				elsif(KEY(2)='1') then
					QUARTERS <= QUARTERS + 1;
				end if;
				
				QUARTERvect <= std_logic_vector(to_unsigned(QUARTERS, QUARTERvect'length));
				
				displayb1 <= "000"&QUARTERvect(5 downto 4);
				displayb0 <= '0'&QUARTERvect(3 downto 0);
				
				if(COST = QUARTERS) then
					next_state <= DISPENSE;
					DISPENSE_READY <= '1';	
				else
					next_state <= PRODUCT_SELECT;
					DISPENSE_READY <= '0';
				end if;
				
				LEDG(0) <= '0';
				LEDG(1) <= '1';
				LEDG(2) <= '0';
				LEDG(8) <= DISPENSE_READY;
				
				displayb2 <= "10001";
				displayb3 <= "10001";
				displayb6 <= "10001";
				displayb7 <= "10001";
				
			when DISPENSE =>
			
				next_state <= IDLE;
				LEDR(17 downto 0) <= "000000000000000000";
				LEDG(2) <= '1';
				LEDG(1 downto 0) <= "00";
				
		end case;
	end process;
	
	display0: hexdisplay PORT MAP (displayb0, HEX0);
	display1: hexdisplay PORT MAP (displayb1, HEX1);
	display2: hexdisplay PORT MAP (displayb2, HEX2);
	display3: hexdisplay PORT MAP (displayb3, HEX3);
	display4: hexdisplay PORT MAP (displayb4, HEX4);
	display5: hexdisplay PORT MAP (displayb5, HEX5);
	display6: hexdisplay PORT MAP (displayb6, HEX6);
	display7: hexdisplay PORT MAP (displayb7, HEX7);
	
end Structure;

-- 7 seg display
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY hexdisplay IS
	PORT (C	: IN	STD_LOGIC_VECTOR(4 DOWNTO 0);
			H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END hexdisplay;

ARCHITECTURE Structure OF hexdisplay IS
BEGIN
	PROCESS (C)
	BEGIN
		CASE C IS
			WHEN "00000" => H <= "0000001";
			WHEN "00001" => H <= "1001111";
			WHEN "00010" => H <= "0010010";  
			WHEN "00011" => H <= "0000110";
			WHEN "00100" => H <= "1001100"; 
			WHEN "00101" => H <= "0100100"; 
			WHEN "00110" => H <= "0100000"; 
			WHEN "00111" => H <= "0001111"; 
			WHEN "01000" => H <= "0000000"; 
			WHEN "01001" => H <= "0000100"; 
			WHEN "01010" => H <= "0001000"; 
			WHEN "01011" => H <= "1100000"; 
			WHEN "01100" => H <= "1110010"; 
			WHEN "01101" => H <= "1000010"; 
			WHEN "01110" => H <= "0110000"; 
			WHEN "01111" => H <= "0111000"; 
			WHEN "10000" => H <= "1111110";
			WHEN "10001" => H <= "1111111";
			WHEN OTHERS => H <= "ZZZZZZZ";
		END CASE;
	END PROCESS;
END Structure;