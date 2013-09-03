 -- Truth Table:
 -- X Y | F
 -- 0 0 | 1
 -- 0 1 | 0
 -- 1 0 | 1
 -- 1 1 | 1
 
 -- Import logic primitives
LIBRARY ieee;
USE ieee.std_logic_1164.all;


ENTITY part1 IS
PORT ( SW: IN STD_LOGIC_VECTOR(2 DOWNTO 1);
		 LEDG: OUT STD_LOGIC_VECTOR(0 DOWNTO 0)); -- output
END part1;

-- Define characteristics of the entity lab1
ARCHITECTURE Structure OF part1 IS
	SIGNAL X, Y, F : STD_LOGIC;
BEGIN
	
	X <= SW(1);
	Y <= SW(2);
	
	F <= (X NOR (NOT Y)) NAND (Y AND (NOT X));
	
	LEDG(0) <=  F; -- Assign each switch to one red LED
END Structure;