 -- Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY part2 IS
PORT ( SW: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: OUT STD_LOGIC_VECTOR(0 TO 6)); -- output
END part2;

-- Define characteristics of the entity
ARCHITECTURE Structure OF part2 IS
	COMPONENT bcd7seg
		PORT (	C	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					H	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	SIGNAL C : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
	C(3 DOWNTO 0) <= SW(3 DOWNTO 0);

	-- drive the displays through 7-seg decoders
	digit7: bcd7seg PORT MAP (C, HEX7);
	digit6: bcd7seg PORT MAP (C, HEX6);
	digit5: bcd7seg PORT MAP (C, HEX5);
	digit4: bcd7seg PORT MAP (C, HEX4);	
	digit3: bcd7seg PORT MAP (C, HEX3);
	digit2: bcd7seg PORT MAP (C, HEX2);
	digit1: bcd7seg PORT MAP (C, HEX1);
	digit0: bcd7seg PORT MAP (C, HEX0);	
END Structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY bcd7seg IS
	PORT (	C	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE Structure OF bcd7seg IS
BEGIN
	--
	--       0  
	--      ---  
	--     |   |
	--    5|   |1
	--     | 6 |
	--      ---  
	--     |   |
	--    4|   |2
	--     |   |
	--      ---  
	--       3  
	--
	PROCESS (C)
	BEGIN
		CASE C IS
			WHEN "0000" => H <= "0000001";
			WHEN "0001" => H <= "1001111";
			WHEN "0010" => H <= "0010010";  
			WHEN "0011" => H <= "0000110";
			WHEN "0100" => H <= "1001100"; 
			WHEN "0101" => H <= "0100100"; 
			WHEN "0110" => H <= "0100000"; 
			WHEN "0111" => H <= "0001111"; 
			WHEN "1000" => H <= "0000000"; 
			WHEN "1001" => H <= "0000100"; 
			WHEN "1010" => H <= "0001000"; 
			WHEN "1011" => H <= "1100000"; 
			WHEN "1100" => H <= "1110010"; 
			WHEN "1101" => H <= "1000010"; 
			WHEN "1110" => H <= "0110000"; 
			WHEN "1111" => H <= "0111000"; 
			WHEN OTHERS => H <= "ZZZZZZZ";
		END CASE;
	END PROCESS;
END Structure;