--part3
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part3 IS
	PORT (	KEY	: IN	STD_LOGIC_VECTOR (0 DOWNTO 0);
				HEX1, HEX0	: OUT	STD_LOGIC_VECTOR(0 TO 6);
				LEDR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0));
END part3;

ARCHITECTURE Structure OF part3 IS
	COMPONENT JK
		PORT (	Clk, J, K	: IN	STD_LOGIC;
			Q, Qbar	: OUT	STD_LOGIC);
	END COMPONENT;
	
	COMPONENT bcd7seg
		PORT (	C	: IN 	STD_LOGIC_VECTOR(3 DOWNTO 0);
					H	: OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	SIGNAL Count: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL Clock: STD_LOGIC;
BEGIN
	Clock <= KEY(0);
	
	bit0: JK PORT MAP (Clock, '1', '1', Count(0), OPEN);
	bit1: JK PORT MAP (Clock, Count(0), Count(0), Count(1), OPEN);
	bit2: JK PORT MAP (Clock, Count(0) AND Count(1), Count(0) AND Count(1), Count(2), OPEN);
	bit3: JK PORT MAP (Clock, Count(0) AND Count(1) AND Count(2), Count(0) AND Count(1) AND Count(2), Count(3), OPEN);
	bit4: JK PORT MAP (Clock, Count(0) AND Count(1) AND Count(2) AND Count(3), Count(0) AND Count(1) AND Count(2) AND Count(3), Count(4), OPEN);
	bit5: JK PORT MAP (Clock, Count(0) AND Count(1) AND Count(2) AND Count(3) AND Count(4), Count(0) AND Count(1) AND Count(2) AND Count(3) AND Count(4), Count(5), OPEN);
	bit6: JK PORT MAP (Clock, Count(0) AND Count(1) AND Count(2) AND Count(3) AND Count(4) AND Count(5), Count(0) AND Count(1) AND Count(2) AND Count(3) AND Count(4) AND Count(5), Count(6), OPEN);
	bit7: JK PORT MAP (Clock, Count(0) AND Count(1) AND Count(2) AND Count(3) AND Count(4) AND Count(5) AND Count(6), Count(0) AND Count(1) AND Count(2) AND Count(3) AND Count(4) AND Count(5) AND Count(6), Count(7), OPEN);
	
	display1: bcd7seg PORT MAP (Count(7 DOWNTO 4), HEX1);
	display0: bcd7seg PORT MAP (Count(3 DOWNTO 0), HEX0);
	
	LEDR(7 DOWNTO 0) <= Count(7 DOWNTO 0);
	LEDR(8) <= Clock;
END Structure;

-- JK Module
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY JK IS
	PORT (	Clk, J, K	: IN	STD_LOGIC;
			Q, Qbar	: OUT	STD_LOGIC);
END JK;

ARCHITECTURE Structure OF JK IS
	SIGNAL Qa, Qb: STD_LOGIC;
BEGIN
	PROCESS(Clk,J,K)
    BEGIN
		IF (Clk='1' and Clk'event) THEN
        IF (J='0' and K='0') THEN
				Qa <= Qa;
            Qb <=Qb;
        ELSIF (J='0' and K='1') THEN
            Qa <= '1';
            Qb <= '0';
        ELSIF (J='1' and K='0') THEN
            Qa <= '0';
            Qb <= '1';
        ELSIF(J='1' and K='1') THEN
            Qa <= NOT Qa;
            Qb <= NOT Qb;
        END IF;
        END IF;
	END PROCESS;

		Q <= Qa;
		Qbar <= Qb;
END Structure;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- 7seg display decoder
ENTITY bcd7seg IS
	PORT (	C	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
END bcd7seg;

ARCHITECTURE Structure OF bcd7seg IS
BEGIN
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