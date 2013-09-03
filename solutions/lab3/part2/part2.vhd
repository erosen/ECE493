LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part2 is
PORT (A: IN STD_LOGIC_VECTOR(3 DOWNTO 0):= "0110";
		B: IN STD_LOGIC_VECTOR(3 DOWNTO 0):= "0101";
		S: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		Cout: OUT STD_LOGIC);
END part2;

ARCHITECTURE Structure OF part2 IS
	COMPONENT fulladder
		PORT (A, B, Cin: IN STD_LOGIC;
				S, Cout: OUT STD_LOGIC);
	END COMPONENT;
	
	SIGNAL C : STD_LOGIC_VECTOR(2 DOWNTO 0);
BEGIN	
	fa0: fulladder PORT MAP (A(0), B(0), '0', S(0), C(0));
	fa1: fulladder PORT MAP (A(1), B(1), C(0), S(1), C(1));
	fa2: fulladder PORT MAP (A(2), B(2), C(1), S(2), C(2));
	fa3: fulladder PORT MAP (A(3), B(3), C(2), S(3), Cout);	
END Structure;

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