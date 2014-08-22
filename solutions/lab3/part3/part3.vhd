LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part3 is
PORT (SW: IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		HEX3, HEX5, HEX7: OUT STD_LOGIC_VECTOR(0 TO 6);
		LEDG: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
		LEDR: OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END part3;

ARCHITECTURE Structure OF part3 IS
	COMPONENT fulladder
		PORT (A, B, Cin: IN STD_LOGIC;
				S, Cout: OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT mux4to1
		PORT (i0, i1, i2, i3	: IN	STD_LOGIC;
				sel: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				f : OUT	STD_LOGIC);
	END COMPONENT;

	COMPONENT bcd7seg
		PORT (C	: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);
				H	: OUT	STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	SIGNAL A, B, S : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL D0, D1, D2, D3, Zero : STD_LOGIC;
	SIGNAL C : STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	SIGNAL Ain, Bin : STD_LOGIC_VECTOR(3 DOWNTO 0); --intermediate signal
BEGIN	
	
	A(3 DOWNTO 0) <= SW(3 DOWNTO 0);
	B(3 DOWNTO 0) <= SW(7 DOWNTO 4);
	D0 <= SW(8);
	D1 <= SW(9);
	
	D2 <= SW(10);
	D3 <= SW(11);
	
	
	m40: mux4to1 PORT MAP (A(0), NOT A(0), '0', 'X', D1 & D0, Ain(0));
	m41: mux4to1 PORT MAP (A(1), NOT A(1), '0', 'X', D1 & D0, Ain(1));
	m42: mux4to1 PORT MAP (A(2), NOT A(2), '0', 'X', D1 & D0, Ain(2));
	m43: mux4to1 PORT MAP (A(3), NOT A(3), '0', 'X', D1 & D0, Ain(3));
	
	m44: mux4to1 PORT MAP (B(0), NOT A(0), '0', 'X', D3 & D2, Bin(0));
	m45: mux4to1 PORT MAP (B(1), NOT A(1), '0', 'X', D3 & D2, Bin(1));
	m46: mux4to1 PORT MAP (B(2), NOT A(2), '0', 'X', D3 & D2, Bin(2));
	m47: mux4to1 PORT MAP (B(3), NOT A(3), '0', 'X', D3 & D2, Bin(3));
	
	C(0) <= SW(12);
	
	fa0: fulladder PORT MAP (Ain(0), Bin(0), C(0), S(0), C(1));
	fa1: fulladder PORT MAP (Ain(1), Bin(1), C(1), S(1), C(2));
	fa2: fulladder PORT MAP (Ain(2), Bin(2), C(2), S(2), C(3));
	fa3: fulladder PORT MAP (Ain(3), Bin(3), C(3), S(3), C(4));
	
	LEDG(0) <= C(4);
	LEDR(1) <= '1' WHEN (S(3 DOWNTO 0) = "0000") ELSE '0';
	
	displayA: bcd7seg PORT MAP(Ain, HEX7);
	displayB: bcd7seg PORT MAP(Bin, HEX5);
	displayS: bcd7seg PORT MAP(S, HEX3);	
END Structure;

-- full adder
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY fulladder IS
PORT ( A, B, Cin: IN STD_LOGIC;
		 S, Cout: OUT STD_LOGIC);
END fulladder;

ARCHITECTURE Structure OF fulladder IS
BEGIN
	S <= A XOR B XOR Cin;
	
	Cout <= (A AND B) OR ((A XOR B) AND Cin);
END Structure;

-- mux4to1
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux4to1 IS
	PORT (i0, i1, i2, i3	: IN	STD_LOGIC;
			sel: IN STD_LOGIC_VECTOR(0 TO 1);
			f : OUT	STD_LOGIC);
END mux4to1;

ARCHITECTURE Structure of mux4to1 IS
BEGIN
	PROCESS(i0, i1, i2, i3, sel)
	BEGIN
		CASE sel IS
			WHEN "00" => f <= i0;
			WHEN "01" => f <= i1;
			WHEN "10" => f <= i2;
			WHEN OTHERS => f <= i3;
		END CASE;
	END PROCESS;
END Structure;

-- 7 seg display
LIBRARY ieee;
USE ieee.std_logic_1164.all;

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