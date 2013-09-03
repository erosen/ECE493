-- A gated D latch
LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY part1 IS
	PORT (	Clk, R, S	: IN	STD_LOGIC;
			Q, Qbar	: OUT	STD_LOGIC);
END part1;

ARCHITECTURE Structure OF part1 IS

	SIGNAL R1, S1, Qa, Qb : STD_LOGIC; -- Intermediate signals
	ATTRIBUTE keep: boolean; -- For waveform results
	ATTRIBUTE keep of R1, S1, Qa, Qb : signal is true;
	
BEGIN
	
	R1 <= R AND CLK;
	S1 <= S AND CLK;
	Qa <= R1 NOR Qb;
	Qb <= S1 NOR Qa;

	Q <= Qa;
	Qbar <=Qb;
	
END Structure;