LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part1 IS
PORT ( A, B: IN STD_LOGIC;
		 S, C: OUT STD_LOGIC);
END part1;


ARCHITECTURE Structure OF part1 IS
BEGIN
	S <= A XOR B;
	
	C <= A AND B;
END Structure;