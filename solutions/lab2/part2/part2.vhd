LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part2 IS
	PORT (	Clk, J, K	: IN	STD_LOGIC;
			Q, Qbar	: OUT	STD_LOGIC);
END part2;

ARCHITECTURE Structure OF part2 IS

	SIGNAL J1, K1, Qa, Qb : STD_LOGIC; -- Intermediate signals
	ATTRIBUTE keep: boolean; -- For waveform results
	ATTRIBUTE keep of J1, K1, Qa, Qb : signal is true;
	
BEGIN
	
	J1 <= NOT (J AND CLK AND Qb);
	K1 <= NOT (K AND CLK AND Qa);
	Qa <= J1 NAND Qb;
	Qb <= K1 NAND Qa;

	Q <= Qa;
	Qbar <=Qb;
	
END Structure;